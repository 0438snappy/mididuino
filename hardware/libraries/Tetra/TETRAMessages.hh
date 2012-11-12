#ifndef TETRA_MESSAGES_H__
#define TETRA_MESSAGES_H__

#include <inttypes.h>
#include "TETRADataEncoder.hh"

class TETRAProgram {
public:
  uint8_t parameters[196];  
  char name[17];
  
  TETRAProgram() {
  }
 
  bool fromSysex(uint8_t *sysex, uint16_t len);
};



#endif /* TETRA_MESSAGES_H__ */
