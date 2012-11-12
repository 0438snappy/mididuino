/*
 * MidiCtrl - Interface class to the DSI Tetra
 *
 */

#ifndef TETRA_H__
#define TETRA_H__

#include <inttypes.h>

#include "Platform.h"
#include "TETRAMessages.hh"
#include "TETRAParams.hh"

#include "TETRAEncoders.h"

class TETRAClass {
 public:
  TETRAClass();

  uint8_t midiChannel;
  bool loadedMidiChannel;
  
  int currentProgram;
  bool loadedProgram;
  TETRAProgram program;

  void sendSysex(uint8_t *bytes, uint8_t cnt);
  void sendRequest(uint8_t type, uint8_t param);
  void sendRequest(uint8_t type);
  void requestProgramEditBuffer();
  
  uint8_t getParameterNrpn(uint8_t parameterNumber);    
  static const char* getParameterName(uint8_t parameterNumber);  
  static const char* getParameterGroupName(uint8_t parameterNumber);    
  uint8_t getParameterMin(uint8_t parameterNumber);    
  uint8_t getParameterMax(uint8_t parameterNumber);        

};

extern TETRAClass TETRA;

//#include "DSI.hh"
#include "TETRASysex.hh"
//#include "TETRATask.hh"

#endif /* TETRA_H__ */
