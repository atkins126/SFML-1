{==============================================================================
    ____  _____ __  __ _
   / ___||  ___|  \/  | |
   \___ \| |_  | |\/| | |
    ___) |  _| | |  | | |___
   |____/|_|   |_|  |_|_____|
  Simple Fast Multimedia Layer

 Bindings that allow you to use SFML and other useful C libraries
 with Pascal.

 Copyright © 2020-2022 tinyBigGAMES™ LLC
 All Rights Reserved.

 Website: https://tinybiggames.com
 Email  : support@tinybiggames.com

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software in
    a product, an acknowledgment in the product documentation would be
    appreciated but is not required.
 2. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

 3. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

 4. Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.

 5. All video, audio, graphics and other content accessed through the
    software in this distro is the property of the applicable content owner
    and may be protected by applicable copyright law. This License gives
    Customer no rights to such content, and Company disclaims any liability
    for misuse of content.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
============================================================================= }

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

program Video;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Math,
  SFML,
  uCommon;

const
  SampleBuffSize  = 2304;

var
  Mode: sfVideoMode;
  RenderWindow: PsfRenderWindow;
  Event: sfEvent;
  View: PsfView;
  Texture: PsfTexture;
  Sprite: PsfSprite;
  Image: PsfImage;
  SampleRate: Integer;
  AudioSpec: SDL_AudioSpec;
  AudioDevice: SDL_AudioDeviceID;
  VideoWidth: integer;
  VideoHeight: integer;
  VideoVolume: Single;
  Plm: Pplm_t;

procedure OnDecodeVideo(aPplm: pplm_t; aFrame: pplm_frame_t; aUserData: pointer); cdecl;
begin
  plm_frame_to_rgba(aFrame, Pointer(sfImage_getPixelsPtr(Image)), 4*VideoWidth);
  sfTexture_updateFromImage(Texture, Image, 0, 0);
end;

procedure OnDecodeAudio(aPlm: pplm_t; aSamples: pplm_samples_t; aUserData: Pointer); cdecl;
var
  LSize: Cardinal;
  LGaindB: Single;
  LFactor: Single;
  LCount: Integer;
  LPtr: PSingle;
begin
  LSize := SizeOf(Single) * aSamples.count * 2;
  LGaindB := (EnsureRange(VideoVolume, 0.0, 1.0) * 50) - 50;
  LFactor := Power(10, LGaindB * 0.05);

  LCount := 0;
  LPtr := @aSamples.interleaved[0];
  while LCount < SampleBuffSize do
  begin
    LPtr^ := EnsureRange(LPtr^ * LFactor, -1.0, 1.0);
    Inc(LPtr);
    Inc(LCount);
  end;

  SDL_QueueAudio(AudioDevice, @aSamples.interleaved[0], LSize);
end;

begin
  SDL_Init(SDL_INIT_AUDIO);

  Plm := plm_create_with_filename('arc/videos/tinyBigGAMES.mpg');
  plm_set_audio_enabled(Plm, sfTrue);
  plm_set_audio_stream(Plm, 0);
  plm_set_loop(Plm, sfTrue);
  //plm_set_loop(Plm, sfFalse);
  SampleRate := plm_get_samplerate(Plm);

  FillChar(AudioSpec, sizeof(AudioSpec), 0);
  AudioSpec.freq := SampleRate;
  AudioSpec.format := AUDIO_F32;
  AudioSpec.channels := 2;
  AudioSpec.samples := SampleBuffSize;
  AudioDevice := SDL_OpenAudioDevice(nil, 0, @AudioSpec, nil, 0);
  SDL_PauseAudioDevice(AudioDevice, 0);
  plm_set_audio_lead_time(Plm, (AudioSpec.samples*AudioSpec.channels)/SampleRate);

  VideoWidth := plm_get_width(Plm);
  VideoHeight := plm_get_height(Plm);
  VideoVolume := 1.0;

  Mode.Width :=  VideoWidth;
  Mode.Height := VideoHeight;
  Mode.BitsPerPixel := 32;

  RenderWindow := sfRenderWindow_create(Mode, 'SFML Video', sfResize or sfClose, nil);
  SetDefaultIcon(RenderWindow);
  ScaleWindowToMonitor(RenderWindow);
  sfRenderWindow_setFramerateLimit(RenderWindow, 60);

  View := CreateView(Mode.width, Mode.height);

  Image := sfImage_create(VideoWidth, VideoHeight);
  Texture := sfTexture_create(VideoWidth, VideoHeight);
  Sprite := sfSprite_create;
  sfSprite_setTexture(Sprite, Texture, sfTrue);

  plm_set_video_decode_callback(Plm, OnDecodeVideo, nil);
  plm_set_audio_decode_callback(Plm, OnDecodeAudio, nil);

  while sfRenderWindow_isOpen(RenderWindow) = sfTrue do
  begin
    while sfRenderWindow_pollEvent(RenderWindow, @Event) = sfTrue do
    begin
      case Event.kind of
        sfEvtClosed:
          begin
            sfRenderWindow_close(RenderWindow);
          end;

        sfEvtResized:
          begin
            SetLetterBoxView(View, Event.size.width, Event.size.height);
          end;
      end;
    end;

    plm_decode(Plm, 1.0/60.0);
    if plm_has_ended(Plm) = sfTrue then
      sfRenderWindow_close(RenderWindow);

    sfRenderWindow_clear(RenderWindow, DARKSLATEBROWN);

    sfRenderWindow_setView(RenderWindow, View);
    sfRenderWindow_drawSprite(RenderWindow, Sprite, nil);

    sfRenderWindow_display(RenderWindow);
  end;

  plm_destroy(Plm);
  sfSprite_destroy(Sprite);
  sfTexture_destroy(Texture);
  sfView_destroy(View);
  sfRenderWindow_destroy(RenderWindow);
  SDL_Quit;

end.
