// (c) 2023 Awildidiot

int createwaveheader(Wavedraw.wdata *wdata) {
  wdata.header = Wavedraw.wheader() {
    RIFF = {'R', 'I', 'F', 'F'},
    filesize = wdata.length + 44 - 2,
    WAVE = {'W', 'A', 'V', 'E'},
    FMT  = {'f', 'm', 't', ' '},
    headersize = 16,
    
    format = 1,
    channels = 2,
    samplerate = 44100,
    bitspersample = 8,
    byterate = (44100 * 8 * 2) / 8, // have to use constants because it won't except the other parameters
    blockalign = (2 * 8) / 8,       // same here
    DATA = {'d', 'a', 't', 'a'},
    datasize = wdata.length - 2,
  };
  
  return 0;
}
