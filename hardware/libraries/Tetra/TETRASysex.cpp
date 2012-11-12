/*
 * MidiCtrl - Encode and decode TETRA sysex messages
 *
 * (c) July 2011 - Manuel Odendahl - wesen@ruinwesen.com
 */

#include "Platform.h"
#include "helpers.h"
#include "TETRAParams.hh"
#include "TETRASysex.hh"
#include "TETRAMessages.hh"

TETRASysexListenerClass TETRASysexListener;

void TETRASysexListenerClass::start() {
  isTETRAMessage = false;
}

void TETRASysexListenerClass::handleByte(uint8_t byte) {

  if (MidiSysex.len == 1) {
    if (byte == TETRA_SYSEX_ID) {
      isTETRAMessage = true;
    } else {
      isTETRAMessage = false;
    }
    return;
  }
  
  if (isTETRAMessage) {
 	if (MidiSysex.len == sizeof(tetra_sysex_hdr)) {
  	    msgType = byte;
    }
  }
}

void TETRASysexListenerClass::end() {
  if (!isTETRAMessage){
    return;
  }

  switch (msgType) {
    
  case TETRA_GLOBAL_MESSAGE_ID:
    onGlobalMessageCallbacks.call();
    break;
    
  case TETRA_PROGRAM_EDIT_BUFFER_MESSAGE_ID:
    onProgramEditBufferMessageCallbacks.call();
    break;
    
  }
}

void TETRASysexListenerClass::setup() {
  MidiSysex.addSysexListener(this);
}
