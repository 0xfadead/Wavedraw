// (c) Theo Meßner 2023

public class Wavedraw.Window : Gtk.Window {
  private bool cursor_in_surface = false;
  public Gtk.DrawingArea pdrawing_area;
  public uint8 window_scale = 3;

  public Wavedraw.wdata wdata;

  public Window(Wavedraw.wdata wdata) {
    this.wdata = wdata;
  }

  // NOTE: since the documentation of drawing programs in GTK is terrible, this code was partially (names of EventMotion and EventButton) generated by https://perplexity.ai 
  // (Query: "May you write a simple drawing app in gtk3+ for me?" && "May you please rewrite this code in the vala language?")
  construct {
    set_position(Gtk.WindowPosition.CENTER);
    set_default_size(256 * window_scale, 256 * window_scale);
    set_resizable(false);

    var drawing_area = new Gtk.DrawingArea();
    
    drawing_area.set_size_request(256 * window_scale, 256 * window_scale);
    drawing_area.set_events(Gdk.EventMask.ALL_EVENTS_MASK);
    
    drawing_area.draw.connect(on_draw);
    drawing_area.button_press_event.connect(on_mouse_down);
    drawing_area.motion_notify_event.connect(on_mouse_motion);

    drawing_area.enter_notify_event.connect(() => {
#if debug
      print("Cursor entered surface\n");
#endif
      cursor_in_surface = true;
    });
    drawing_area.leave_notify_event.connect(() => {
#if debug
      print("Cursor left surface\n");
#endif
      cursor_in_surface = false;
    });

    this.pdrawing_area = drawing_area;

    add(drawing_area);
  }

  bool check_overflow(uint32 input, uint32 addition) { return (Math.pow(2, 32)-1 - addition < input); }
  
  // activates when a mouse button is pressed
  private bool on_mouse_down(Gtk.Widget widget, Gdk.EventButton event) {
    // check if it's the left mouse button
    if (event.button == 1) {
      if (check_overflow(this.wdata.length, 44+2)) {
        print("Maximum length reached!\n");
        return true;
      }
      
      // allocate more memory in the buffers if needed
      if (this.wdata.length == this.wdata.rlength) {
        this.wdata.rlength   += 2;
        this.wdata.data       = Posix.realloc(this.wdata.data,       sizeof(uint8)  * this.wdata.rlength); 
      }
      if (this.wdata.steps  == this.wdata.rsteps) { 
        this.wdata.rsteps++;
        this.wdata.steps_back = Posix.realloc(this.wdata.steps_back, sizeof(uint16) * this.wdata.rsteps); 
      }
      
      // put the coordinates into the buffer
      this.wdata.data[this.wdata.length-2]    = (uint8)(event.x/window_scale);
      this.wdata.data[this.wdata.length-1]    = (uint8)(event.y/window_scale);
      // update the steps (for the undo/redo system)
      this.wdata.steps_back[this.wdata.steps] = 1;

#if debug
      print("Button pressed at %u, %u\n", this.wdata.data[this.wdata.length-2], this.wdata.data[this.wdata.length-1]);
#endif

      // update the length and length
      this.wdata.length += 2;
      this.wdata.steps++;

      // update the display
      widget.queue_draw();
    }

    return false;
  } 

  // activates when the cursor is moved
  private bool on_mouse_motion(Gtk.Widget widget, Gdk.EventMotion event) {
    // Check if the mouse is down (256 = MOUSE_DOWN) and if the cursor is in the surface 
    if (event.state == 256 && cursor_in_surface) {
      if (check_overflow(this.wdata.length, 44+2)) {
        print("Maximum length reached!\n");
        return true;
      }
      
      if (this.wdata.length == this.wdata.rlength) {
        this.wdata.rlength += 2;
        this.wdata.data = Posix.realloc(this.wdata.data, sizeof(uint8) * this.wdata.length); 
      }
      
      this.wdata.data[this.wdata.length-2] = (uint8)(event.x/window_scale);
      this.wdata.data[this.wdata.length-1] = (uint8)(event.y/window_scale);

#if debug
      print("Movement at %u, %u\n", this.wdata.data[this.wdata.length-2], this.wdata.data[this.wdata.length-1]);
#endif

      this.wdata.length  += 2;
      this.wdata.steps_back[this.wdata.steps-1] += 1;


      
      // update the display
      widget.queue_draw();
    }

    return false;
  }
  
  // activates when Gtk says it's time to sketch some doodles
  private bool on_draw(Gtk.Widget widget, Cairo.Context cr) {
#if debug
    print("Redrawing...\n");
#endif
    
    // set colour to black
    cr.set_source_rgb(0, 0, 0);
    // apply on background
    cr.paint();

    // set colour to green (eyeball sinching guaranteed)
    cr.set_source_rgb(0, 255, 0);

#if debug
    print("Length: %lu\n", this.wdata.length);
#endif
    
    // iterate over every point
    for (uint32 i = 3; i < this.wdata.length-2; i += 2) {
      cr.move_to(this.wdata.data[i-3] * window_scale, this.wdata.data[i-2] * window_scale);
      cr.line_to(this.wdata.data[i-1] * window_scale, this.wdata.data[i]   * window_scale);
      // have a stroke and quit this stupid language, hrrmm...I mean wonderful languages without any LS bugs at all...
      cr.stroke();
    } 

    return false;
  }
}
