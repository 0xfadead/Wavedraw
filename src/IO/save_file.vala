// (c) Theo Meßner 2023

static inline void flip_y(Wavedraw.wdata wdata) {
  // TODO: find more optimized solution (Fix 2 is actually faster, since it only edits every second value)
  //       Fixes tried:
  //           - Flipping y axis on writing (stupid stuff with dos.write only accepting uint8[])
  //           - reversing the reversal made here
  //               1. pretty unclean
  //               2. slower (since none of the memcpy optimization were made here)

  // flip on the y axis, because the WAVE-Format is just weird like that
  for (uint32 i = 1; i < wdata.header.datasize; i += 2) {
    wdata.data[i] ^= 0xff;
  }

  return;
} 

int _write_to_file(File ifile, Wavedraw.wdata wdata, uint32 extend_to) {
  if (wdata.header.datasize == 0) wdata.header.datasize = 1;

  print("Saving:\n");

  // declare the OutputStream
  FileOutputStream nfile = null;
  
  // create the file with try & catch because vala is just quirky like that
  try { nfile = ifile.create(FileCreateFlags.NONE); }
  catch (Error e) { stderr.printf("\x1b[31mError whilst creating the file: %s\n\x1b[0m", e.message); return 2; }
  
  // create the "handle" to write to
  var dos = new DataOutputStream(nfile);
  
  print("\tFormatting data...\n");
  
  flip_y(wdata);


  // how much has been written (redundant comment)
  uint32 written = 0;
  try {
    print("\tWriting header:\n");
    
    // loops for writing the header
    print("\t\tWriting RIFF...\n");
    while (written < 4) 
      written += (uint32)dos.write((uint8[])(wdata.header.RIFF)[written]);
    written = 0;
    print("\t\tWriting filesize...\n");
    uint32 fsize = wdata.header.datasize * (extend_to / wdata.header.datasize) + 44;
    while (written < 4)
      written += (uint32)dos.write((uint8[])((char *)&fsize)[written]);
    written = 0;
    print("\t\tWriting WAVE...\n");
    while (written < 4) 
      written += (uint32)dos.write((uint8[])(wdata.header.WAVE)[written]);
    written = 0;
    print("\t\tWriting FMT...\n");
    while (written < 4) 
      written += (uint32)dos.write((uint8[])(wdata.header.FMT)[written]);
    written = 0;
    print("\t\tWriting headersize...\n");
    while (written < 4) 
      written += (uint32)dos.write((uint8[])((char *)&wdata.header.headersize)[written]);
    written = 0;
    print("\t\tWriting format...\n");
    while (written < 2) 
      written += (uint32)dos.write((uint8[])((char *)&wdata.header.format)[written]);
    written = 0;
    print("\t\tWriting channels...\n");
    while (written < 2) 
      written += (uint32)dos.write((uint8[])((char *)&wdata.header.channels)[written]);
    written = 0;
    print("\t\tWriting samplerate...\n");
    while (written < 4) 
      written += (uint32)dos.write((uint8[])((char *)&wdata.header.samplerate)[written]);
    written = 0;
    print("\t\tWriting byterate...\n");
    while (written < 4) 
      written += (uint32)dos.write((uint8[])((char *)&wdata.header.byterate)[written]);
    written = 0;
    print("\t\tWriting blockalign...\n");
    while (written < 2) 
      written += (uint32)dos.write((uint8[])((char *)&wdata.header.blockalign)[written]);
    written = 0;
    print("\t\tWriting bitspersample...\n");
    while (written < 2) 
      written += (uint32)dos.write((uint8[])((char *)&wdata.header.bitspersample)[written]);
    written = 0;
    print("\t\tWriting DATA...\n");
    while (written < 4) 
      written += (uint32)dos.write((uint8[])(wdata.header.DATA)[written]);
    written = 0;
    print("\t\tWriting datasize...\n");
    fsize -= 44;
    while (written < 4) 
      written += (uint32)dos.write((uint8[])((char *)&fsize)[written]);
    written = 0;
    

    print("\tWriting data...\n");
    
    for (uint32 i = 0; i < extend_to / wdata.length; i++) {
      // loop for the writing the data
      while (written < wdata.header.datasize) {
        written += (uint32)dos.write((uint8[])(wdata.data)[written]);
      }
      written = 0;
    }

  } catch (Error e) {
    stderr.printf("\x1b[31mError whilst writing to the file: %s\n\x1b[0m", e.message);
    
    // undoing the y-flip
    print("Deformatting data...\n");
    flip_y(wdata);
    
    return 3;
  }
  
  // undoing the y-flip
  print("Deformatting data...\n");
  flip_y(wdata);

  return 0;
}

int save_file(Wavedraw.wdata wdata, Wavedraw.Window window) {
  uint32 final_dsize = 44100;
  int returnvalue = 0;
  bool does_file_exist = false;
  bool msgbox_answered = false;
  
  // create the FileChooserDialog
  var fchooser = new Gtk.FileChooserDialog(
    "Save", window, Gtk.FileChooserAction.SAVE,
    "_Cancel", Gtk.ResponseType.CANCEL,
    "_Save", Gtk.ResponseType.ACCEPT
  );
  
  // start it
  fchooser.run(); 
  // close it after it's unfortunate demise
  fchooser.close();

  // if the name is null the dialog was aborted
  if (fchooser.get_filename() == null) return -1;
  
  // create a file with the appropriate filename
  var outfile = File.new_for_path(fchooser.get_filename());

  createwaveheader(&wdata);

  // check if the file already exists
  if (outfile.query_exists()) {
    does_file_exist = true;

    // create a messagebox for asking the user
    var msgbox = new Gtk.MessageDialog(window, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, 
                                        Gtk.ButtonsType.YES_NO, "The file already exists!\nContinue anyway?");
    
    // set the code to run when it's interacted with
    msgbox.response.connect((response_id) => {
      // filter the response
      switch(response_id) {
        case Gtk.ResponseType.YES:
          try { outfile.delete(); }
          catch(Error e) { stderr.printf("\x1b[31mError whilst deleting old file: %s\n\x1b[0m", e.message); }
          returnvalue = _write_to_file(outfile, wdata, final_dsize);
          break;
        case Gtk.ResponseType.NO:
          returnvalue = 1;
          break;
        case Gtk.ResponseType.CANCEL:
          returnvalue = 1;
          break;
        default:
          stderr.printf("\x1b[33mWarning: Unknown answer in messagebox: %i\n\x1b[0m", response_id);
          break;
      }
      
      // destroy the messagebox
      msgbox.destroy();
      msgbox_answered = true;
    });
    
    // show the messagebox
    msgbox.show();
  }
  
  // destroy the FileChooserDialog
  fchooser.destroy();

  // wait until the messagebox is answered
  while (!msgbox_answered && does_file_exist) Gtk.main_iteration();
  
  // just return if the file already has been saved or aborted
  if (msgbox_answered) return returnvalue;
  
  // write the wdata to the file
  returnvalue = _write_to_file(outfile, wdata, final_dsize);

#if debug
  if (returnvalue == 0) print("\x1b[32mFile written successfully.\n\x1b[0m");
#endif
  

  return returnvalue;
}
