#include <Platform.h>
#include "TETRAMessages.hh"
#include "TETRAParams.hh"
#include "helpers.h"
//#include "DSI.hh"

#ifdef HOST_MIDIDUINO
#include <stdio.h>
#endif

/***************************************************************************
 *
 * Tetra Program message
 *
 ***************************************************************************/

/**
 * Decode a Tetra Program message from a sysex buffer.
 **/
bool TETRAProgram::fromSysex(uint8_t *data, uint16_t len) {
  
  if (MidiSysex.recordLen != 442) {
#ifdef MIDIDUINO
    GUI.setLine(GUI.LINE1);
    GUI.flash_string_fill("WRONG MSG LEN:");  
    GUI.setLine(GUI.LINE2);
    GUI.flash_printf_fill("%B", MidiSysex.len);            
#endif
    return false;
  }
	
  TETRASysexDecoder decoder(DATA_ENCODER_INIT(data, len));
  
  decoder.get((uint8_t *)parameters, 184);  
  decoder.get((uint8_t *)name, 17);
  name[16] = '\0';

  return true;
}




