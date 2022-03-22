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

unit uCommon;

interface

uses
  SFML;

procedure Pause;
function  Vector2f(aX, aY: Single): sfVector2f;
procedure SetLetterBoxView(aView: PsfView; aWindowWidth, aWindowHeight: Integer);
function  CreateView(aWindowWidth, aWindowHeight: Integer): PsfView;
procedure ScaleWindowToMonitor(aWindow: PsfRenderWindow; aDefaultDPI: Integer=96);
function  GetScreenWorkAreaSize: sfVector2i;
procedure SetDefaultIcon(aWindow: PsfRenderWindow);

implementation

uses
  SysUtils,
  Windows,
  Messages
  {$IFNDEF FPC}
  ,VCL.Graphics
  {$ENDIF}
  ;

{$IFDEF FPC}
function GetDpiForWindow(hwnd: HWND): UINT; stdcall; external user32 name 'GetDpiForWindow';
{$ENDIF}

procedure Pause;
begin
  WriteLn;
  Write('Press ENTER to continue...');
  ReadLn;
end;

function Vector2f(aX, aY: Single): sfVector2f;
begin
  Result.x := aX;
  Result.y := aY;
end;

procedure SetLetterBoxView(aView: PsfView; aWindowWidth, aWindowHeight: Integer);
var
  LWindowRatio: Single;
  LViewRatio: Single;
  LViewPort: sfFloatRect;
  LHorizontalSpacing: Boolean;
begin
  LWindowRatio := aWindowWidth / aWindowHeight;
  LViewRatio := sfView_getSize(aView).x / sfView_getSize(aView).y;
  LHorizontalSpacing := True;

  LViewPort.left := 0;
  LViewPort.top := 0;
  LViewPort.width := 1;
  LViewPort.height := 1;

  if LWindowRatio < LViewRatio then
    LHorizontalSpacing := false;

  if LHorizontalSpacing then
    begin
      LViewPort.width := LViewRatio / LWindowRatio;
      LViewPort.left := (1 - LViewPort.width) / 2.0;
    end
  else
    begin
      LViewPort.height := LWindowRatio / LViewRatio;
      LViewPort.top := (1 - LViewPort.height) / 2.0;
    end;

  sfView_setViewport(aView, LViewPort);
end;

function CreateView(aWindowWidth, aWindowHeight: Integer): PsfView;
begin
  Result := sfView_create;
  sfView_setSize(Result, Vector2f(aWindowWidth, aWindowHeight));
  sfView_setCenter(Result, Vector2f(sfView_getSize(Result).x/2, sfView_getSize(Result).y/2));
  SetLetterBoxView(Result, aWindowWidth, aWindowHeight);
end;

procedure ScaleWindowToMonitor(aWindow: PsfRenderWindow; aDefaultDPI: Integer);
var
  LDpi: UINT;
  LSize: sfVector2u;
  LScaleSize: sfVector2u;
  LPos: sfVector2i;
  LScreenSize: sfVector2i;
begin
  if aWindow = nil then Exit;

  // get window DPI
  LDpi := GetDpiForWindow(HWND(sfRenderWindow_getSystemHandle(aWindow)));

  // get window size
  LSize := sfRenderWindow_getSize(aWindow);

  // get scaled widow size
  LScaleSize.x := MulDiv(LSize.x, LDPI, aDefaultDPI);
  LScaleSize.y := MulDiv(LSize.y, LDpi, aDefaultDPI);

  // get center window position
  LScreenSize := GetScreenWorkAreaSize;

  LPos.x := (Cardinal(LScreenSize.X) - LScaleSize.x) div 2;
  LPos.y := (Cardinal(LScreenSize.Y) - LScaleSize.y) div 2;

  // set new postion
  sfRenderWindow_setPosition(aWindow, LPos);

  // set new scale
  sfRenderWindow_setSize(aWindow, LScaleSize);
end;

function GetScreenWorkAreaSize: sfVector2i;
var
  LRect: Windows.TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @LRect, 0);
  Result.X := LRect.Width;
  Result.Y := LRect.Height;
end;

{$IFNDEF FPC}
procedure SetDefaultIcon(aWindow: PsfRenderWindow);
var
  LHnd: THandle;
  LIco: TIcon;
begin
  if FindResource(HInstance, 'MAINICON', RT_GROUP_ICON) <> 0 then
  begin
    LIco := TIcon.Create;
    LIco.LoadFromResourceName(HInstance, 'MAINICON');
    SendMessage(HWND(sfRenderWindow_getSystemHandle(aWindow)),
      WM_SETICON, ICON_BIG, LIco.Handle);
    FreeAndNil(LIco);
  end;
end;
{$ELSE}
procedure SetDefaultIcon(aWindow: PsfRenderWindow);
begin
end;
{$ENDIF}


end.
