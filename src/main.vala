// (c) 2023 Awildidiot

int main(string[] args) {
  if ((args.length == 2) & (args[1] == "help" || args[1] == "-h" || args[1] == "--help")) {
    print(
    "(c) 2023 Theo Messner
    Wavedraw
    Eine Mal-Applikation fuer das WAV-Format/Oscilloskope.
    Logs nur in Englisch verfuegbar."
    );

    return 0;
  }

  Gtk.init(ref args);
  
  Wavedraw.wdata wdata = Wavedraw.wdata() {
    data    = Posix.malloc(sizeof(uint8) * 2),
    length  = 2,
    rlength = 2,
    steps_back = Posix.malloc(sizeof(uint16)),
    steps  = 0,
    rsteps = 0,
  };

  var window    = new Wavedraw.Window(wdata);

  var headerbar = new Wavedraw.HeaderBar(window);
  
  // set the headerbar
  window.set_titlebar(headerbar);
  
  // set exit function
  window.destroy.connect(() => {
#if debug
    print("Freeing data buffer...\n");
#endif
    Posix.free(window.wdata.data);

#if debug
    print("Freeing steps_back buffer...\n");
#endif
  Posix.free(window.wdata.steps_back); 
    
    Gtk.main_quit();
  });
  
  // show window
  window.show_all();
  
  // start gtk
  Gtk.main(); 
  
  return 0;
}
