# Wavedraw
A simple xy-oscilloscope drawing application.

## Building
  ### Prerequisites
   - Vala
   - Make
   - Gtk3+
   - Gio-2.0
   - Glib
  
  ### Commands
    git clone github.com/ProjektOpensource/Wavedraw
    cd Wavedraw
    make
   **NOTE: `make debug` will build the application with extra debugging and `make run` will run the application in the build directory.**
   
## Usage
It's just a normal drawing application, with undo/redo.
To save use `File -> Save` and choose a location with a suitable name.
To see the drawing after saving, just use a xy-oscilloscope or xy-oscilloscope emulator (recommendation: `dood.al/oscilloscope`).
