{==============================================================================
    ____  _____ __  __ _
   / ___||  ___|  \/  | |
   \___ \| |_  | |\/| | |
    ___) |  _| | |  | | |___
   |____/|_|   |_|  |_|_____|
  Simple Fast Multimedia Layer

 Pascal bindings that allow you to use SFML and other useful C libraries
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

program Example;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  SFML,
  uCommon;

var
  Mode: sfVideoMode;
  RenderWindow: PsfRenderWindow;
  Event: sfEvent;
begin
  Mode.Width := 800;
  Mode.Height := 600;
  Mode.BitsPerPixel := 32;

  RenderWindow := sfRenderWindow_create(Mode, 'SFML Example', sfResize or sfClose, nil);
  SetDefaultIcon(RenderWindow);

  while sfRenderWindow_isOpen(RenderWindow) = sfTrue do
  begin
    while sfRenderWindow_pollEvent(RenderWindow, @Event) = sfTrue do
    begin
      if Event.kind = sfEvtClosed then
        sfRenderWindow_close(RenderWindow);
    end;

    sfRenderWindow_clear(RenderWindow, DARKSLATEBROWN);
    sfRenderWindow_display(RenderWindow);
  end;

  sfRenderWindow_destroy(RenderWindow);
end.
