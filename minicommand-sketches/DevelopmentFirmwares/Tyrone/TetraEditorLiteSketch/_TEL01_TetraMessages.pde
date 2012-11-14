#include "DataEncoder.hh"


extern uint8_t tetra_sysex_hdr[5];
#define MNM_KIT_REQUEST_ID      0x53

uint8_t tetra_sysex_hdr[5] = {
  0x00,
  0x20,
  0x3c,
  0x03, /* monomachine ID */
  0x00 /* base channel padding */
};


/** Class to hold Tetra Program Data **/ 
class TetraProgram {
public:
  uint8_t origPosition;
  char name[17];
  uint8_t levels[6];
  uint8_t parameters[6][72];
  uint8_t models[6];
  uint8_t types[6];
  uint16_t patchBusIn;
  uint8_t mirrorLR;
  uint8_t mirrorUD;
  uint8_t destPages[6][6][2];
  uint8_t destParams[6][6][2];
  int8_t destRanges[6][6][2];
  uint8_t lpKeyTrack;
  uint8_t hpKeyTrack;

  uint8_t trigPortamento;
  uint8_t trigTracks[6];
  uint8_t trigLegatoAmp;
  uint8_t trigLegatoFilter;
  uint8_t trigLegatoLFO;
	
  static const uint8_t MULTIMODE_ALL = 0;
  static const uint8_t MULTIMODE_SPLIT_KEY = 1;
  static const uint8_t MULTIMODE_SEQ_START = 2;
  static const uint8_t MULTIMODE_SEQ_TRANSPOSE = 3;
  uint8_t commonMultimode;
  uint8_t commonTiming;

  uint8_t splitKey;
  uint8_t splitRange;

  TetraProgram() {
  }

  bool fromSysex(uint8_t *sysex, uint16_t len);
  void print();
};

/** Class to decode 7-bit encoded and compressed sysex data. **/
class TetraSysexDecoder : public DataDecoder {
public:
  uint8_t cnt7;
  uint8_t bits;
  uint8_t tmpData[7];
  uint16_t cnt;
  uint8_t repeatCount;
  uint8_t repeatByte;
  uint16_t totalCnt;
	
public:
  TetraSysexDecoder(DATA_ENCODER_INIT(uint8_t *_data = NULL, uint16_t _maxLen = 0)) {
    init(DATA_ENCODER_INIT(_data, _maxLen));
  }
	
  virtual void init(DATA_ENCODER_INIT(uint8_t *_data, uint16_t _maxLen));
  virtual DATA_ENCODER_RETURN_TYPE get8(uint8_t *c);
  virtual DATA_ENCODER_RETURN_TYPE getNextByte(uint8_t *c);
};


/** Interface Class to DSI Tetra **/
class TetraClass {
 public:
  TetraClass();

  uint8_t midiChannel;
  bool loadedMidiChannel;
  
  int currentProgram;
  bool loadedProgram;
  TetraProgram program;

  void sendSysex(uint8_t *bytes, uint8_t cnt);
  void sendRequest(uint8_t type, uint8_t param);
  void requestProgramEditBuffer();

};

extern TetraClass TETRA;

TetraClass::TetraClass() {
  midiChannel = (15 - 1);
  currentProgram = -1;
  loadedProgram = loadedMidiChannel = false;
}

void TetraClass::sendSysex(uint8_t *bytes, uint8_t cnt) {
  MidiUart.putc(0xF0);
  MidiUart.sendRaw(tetra_sysex_hdr, sizeof(tetra_sysex_hdr));
  MidiUart.sendRaw(bytes, cnt);
  MidiUart.putc(0xF7);
}

void TetraClass::sendRequest(uint8_t type, uint8_t param) {
  uint8_t data[] = { type, param };
  TETRA.sendSysex(data, countof(data));
}

void TetraClass::requestProgram(uint8_t _kit) {
  sendRequest(MNM_KIT_REQUEST_ID, _kit);
}

/***************************************************************************
 *
 * Tetra Program message
 *
 ***************************************************************************/

/**
 * Decode a Tetra Program message from a sysex buffer.
 **/
bool TetraProgram::fromSysex(uint8_t *data, uint16_t len) {
  // TODO - implement checksum check
  
//  if (!ElektronHelper::checkSysexChecksum(data, len)) {
//#ifdef MIDIDUINO
//    GUI.flash_strings_fill("WRONG CHECK", "");
//#endif
//    return false;
//  }

  origPosition = data[3];
  TetraSysexDecoder decoder(DATA_ENCODER_INIT(data + 4, len - 4));
  decoder.get((uint8_t *)name, 11);
  name[15] = '\0';

  decoder.get(levels, 6);
  decoder.get((uint8_t *)parameters, 6 * 72);
  decoder.get(models, 6);
  decoder.get(types, 6);
  decoder.get16(&patchBusIn);
  decoder.get8(&mirrorLR);
  decoder.get8(&mirrorUD);

  decoder.get((uint8_t *)destPages, 6 * 6 * 2);
  decoder.get((uint8_t *)destParams, 6 * 6 * 2);
  decoder.get((uint8_t *)destRanges, 6 * 6 * 2);
  decoder.get8(&lpKeyTrack);
  decoder.get8(&hpKeyTrack);

  decoder.get8(&trigPortamento);
  decoder.get(trigTracks, 6);
  decoder.get8(&trigLegatoAmp);
  decoder.get8(&trigLegatoFilter);
  decoder.get8(&trigLegatoLFO);

  decoder.get8(&commonMultimode);
  uint8_t byte;
  decoder.get8(&byte);
  if (byte == 0) {
    commonTiming = 0;
  } else {
    commonTiming = 1 << (1 - byte);
  }
  decoder.get8(&splitKey);
  decoder.get8(&splitRange);

  return true;
}

void TetraProgram::print() {
  GUI.printf("MNM Kit %s (position %d)\n", name, origPosition);
  for (uint8_t i = 0; i < 6; i++) {
    //GUI.printf("Machine %d: %s\n", i, MNMClass::getMachineName(models[i]));
    GUI.printf("Level: %d\n", levels[i]);
    /*
    GUI.printf("Params: ");
    for (uint8_t j = 0; j < 72; j++) {
      if (j % 8 == 0) {
        GUI.printf("\n");
      }
      GUI.printf("%.2x ", parameters[i][j]);
    }
    */
    GUI.printf("\n");
  }
}




/***************************************************************************
 *
 * Tetra Sysex Decoder
 *
 ***************************************************************************/
void TetraSysexDecoder::init(DATA_ENCODER_INIT(uint8_t *_data, uint16_t _maxLen)) {
  DataDecoder::init(DATA_ENCODER_INIT(_data, _maxLen));
  cnt7 = 0;
  cnt = 0;
  repeatCount = 0;
  repeatByte = 0;
  totalCnt = 0;
}

DATA_ENCODER_RETURN_TYPE TetraSysexDecoder::getNextByte(uint8_t *c) {
  if ((cnt % 8) == 0) {
    bits = *(ptr++);
    cnt++;
  }
  bits <<= 1;
  *c = *(ptr++) | (bits & 0x80);
  cnt++;

  DATA_ENCODER_TRUE();
}

DATA_ENCODER_RETURN_TYPE TetraSysexDecoder::get8(uint8_t *c) {
  uint8_t byte;

  totalCnt++;

 again:
  if (repeatCount > 0) {
    repeatCount--;
    *c = repeatByte;
    DATA_ENCODER_TRUE();
  }

  DATA_ENCODER_CHECK(getNextByte(&byte));
//  printf("%x (%c)\n", byte, byte);

  if (IS_BIT_SET(byte, 7)) {
    repeatCount = byte & 0x7F;
    DATA_ENCODER_CHECK(getNextByte(&repeatByte));
//    printf("%x (%c)\n", repeatByte, repeatByte);    
    goto again;
  } else {
    *c = byte;
    DATA_ENCODER_TRUE();
  }
}
