// (c) 2023 Theo Meßner

public class Wavedraw.HeaderBar : Gtk.HeaderBar {
  Wavedraw.Window window;

  public HeaderBar(Wavedraw.Window window) {
    this.window = window;
  }

  construct {
    show_close_button   = true;
    title               = "Wavedraw";

    var MenuBar         = new Gtk.MenuBar();
    pack_start(MenuBar);

    var file_menu_entry = new Gtk.MenuItem.with_label("File");
    MenuBar.add(file_menu_entry);

    var file_menu       = new Gtk.Menu();
    var save_item       = new Gtk.MenuItem.with_label("Save");
    var exit_item       = new Gtk.MenuItem.with_label("Close");

    save_item.activate.connect(() => {
      int rvalue = save_file(this.window.wdata, this.window);

      switch (rvalue) {
        case -1:
          print("\x1b[33mSaving aborted.\x1b[0m\n");
          break;
        case 0:
          print("\x1b[32mSaving successful.\x1b[0m\n");
          break;
        case 1:
          print("\x1b[33mSaving aborted.\x1b[0m\n");
        case 2:
          print("\x1b[31mError while creating the file.\x1b[0m\n");
          break;
        case 3:
          print("\x1b[31mError while writing to the file.\x1b[0m\n");
          break;
        default:
          stderr.printf("\x1b[33mWarning: Unknown return value from savefile: %i\n\x1b[0m", rvalue);
      }
    });

    exit_item.activate.connect(() => {
#if debug
      print("Freeing data buffer...\n");
#endif
      Posix.free(this.window.wdata.data);

#if debug
      print("Freeing steps_back buffer...\n");
#endif
      Posix.free(this.window.wdata.steps_back); 
    
      Gtk.main_quit();
    });

    file_menu.add(save_item);
    file_menu.add(exit_item);
    file_menu_entry.set_submenu(file_menu);

    var undo_button = new Gtk.Button.with_label("undo");
    var redo_button = new Gtk.Button.with_label("redo");

    undo_button.clicked.connect(() => {
      if (this.window.wdata.steps < 1) return;

    #if debug
      print("steps_back: %lu\n", this.window.wdata.steps_back[this.window.wdata.steps-1]);
    #endif 
      
      this.window.wdata.length -= this.window.wdata.steps_back[this.window.wdata.steps-1] * 2;
      this.window.wdata.steps--;

      this.window.pdrawing_area.queue_draw();
    });

    redo_button.clicked.connect(() => {
      if (this.window.wdata.rsteps <= this.window.wdata.steps) return;

    #if debug
      print("steps_back: %lu\n", this.window.wdata.steps_back[this.window.wdata.steps]);
    #endif
      
      this.window.wdata.length += this.window.wdata.steps_back[this.window.wdata.steps] * 2;
      this.window.wdata.steps++;

      this.window.pdrawing_area.queue_draw();
    });

    pack_start(undo_button);
    pack_start(redo_button);
  }
}
