![SFML](media/sfml-logo.png)  

[![Chat on Discord](https://img.shields.io/discord/754884471324672040.svg?logo=discord)](https://discord.gg/tPWjMwK) [![Twitter Follow](https://img.shields.io/twitter/follow/tinyBigGAMES?style=social)](https://twitter.com/tinyBigGAMES)
# SFML
### Simple Fast Multimedia Layer

Pascal bindings that allow you to use **SFML** and other useful C libraries with Pascal. 

### Included
- **CSFML** (https://github.com/SFML/CSFML)
- **pl_mpeg** (https://github.com/phoboslab/pl_mpeg)
- **Nuklear** (https://github.com/Immediate-Mode-UI/Nuklear)
- **physfs** (https://github.com/icculus/physfs)
- **minizip** (https://github.com/madler/zlib)
- **SDL** (https://github.com/libsdl-org/SDL)

### Minimum Requirements 
- Windows 10+ (64 bits)
- <a href="https://www.embarcadero.com/products/delphi/starter" target="_blank">Delphi Community Edition</a> (Win64 target only)
- <a href="https://freepascal.org" target="_blank">FreePascal</a> 3.2.2 (Win64 target only)


### Usage
- Add `SFML` to your uses section to access all the aforementioned libraries.
- You link to SFML dynamically by default and will look for the SFML DLL in your application path. You can also call `InitSFML`, before any other routine, with a the path to the DLL location.
- Define `SFML_STATIC` in `SFML.pas` to statically link to SFML and the DLL will not have to be included in your application distro. InitSFML will have no effect and you can leave it in your sources so that you can switch between static and dynamic linking during development.

```Pascal
uses
  System.SysUtils,
  SFML;

var
  Mode: sfVideoMode;
  Window: PsfRenderWindow;
  Event: sfEvent;
  Music: PsfMusic;
  
begin
  Mode.Width := 800;
  Mode.Height := 600;
  Mode.BitsPerPixel := 32;
  
  Window := sfRenderWindow_create(Mode, 'Hello SFML', sfResize or sfClose, nil);

  Music := sfMusic_createFromFile('arc/audio/music/song01.ogg');
  sfMusic_play(Music);

  while sfRenderWindow_isOpen(Window) = sfTrue do
  begin
    while sfRenderWindow_pollEvent(Window, @Event) = sfTrue do
    begin
      if Event.kind = sfEvtClosed then
        sfRenderWindow_close(Window);
    end;

    sfRenderWindow_clear(Window, DARKSLATEBROWN);
    sfRenderWindow_display(Window);
  end;

  sfMusic_stop(Music);
  sfMusic_destroy(Music);
  sfRenderWindow_destroy(Window);
end.
```
### Support
- <a href="https://github.com/tinyBigGAMES/SFML/issues" target="_blank">Issues</a>
- <a href="https://github.com/tinyBigGAMES/SFML/discussions" target="_blank">Discussions</a>
- <a href="https://www.sfml-dev.org/" target="_blank">SFML website</a>
- <a href="https://www.youtube.com/results?search_query=SFML&sp=CAI%253D" target="_blank">SFML on YouTube</a>

<p align="center">
<img src="media/delphi.png" alt="Delphi">
</p>
<h5 align="center">

Made with :heart: in Delphi
</h5>