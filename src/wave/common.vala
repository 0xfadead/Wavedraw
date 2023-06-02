// (c) 2023 Awildidiot

public struct Wavedraw.wheader {
  public char    RIFF[4];       // RIFF
  public uint32  filesize;
  public char    WAVE[4];       // WAVE
  public char    FMT[4];        // fmt 
  public uint32  headersize; 

  public uint16  format;        // 1 = PCM
  public uint16  channels;      // 2
  public uint32  samplerate;    // 44100
  public uint32  byterate;      // (samplerate * bitspersample * channels)/8
  public uint16  blockalign;    // (channels * bitspersample)/8
  public uint16  bitspersample; // 1 byte = 8
  public char    DATA[4];       // data
  public uint32  datasize;
}


public struct Wavedraw.wdata {
  public Wavedraw.wheader header;
  public uint8  *data;
  public uint32  length;
  public uint32  rlength;
  public uint16 *steps_back;
  public uint32  steps;
  public uint32  rsteps;
}
