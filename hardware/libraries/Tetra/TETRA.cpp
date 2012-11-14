#include <Platform.h>
#include <GUI.h>
#include <MidiUartParent.hh>
#include "TETRA.h"

TETRAClass::TETRAClass() {
  midiChannel = (15 - 1);  //HARDCODED AWESOMENESS :-)
  currentProgram = -1;
  loadedProgram = loadedGlobal = false;
}

void TETRAClass::sendSysex(uint8_t *bytes, uint8_t cnt) {
  MidiUart.putc(0xF0);
  MidiUart.sendRaw(tetra_sysex_hdr, sizeof(tetra_sysex_hdr));
  MidiUart.sendRaw(bytes, cnt);
  MidiUart.putc(0xF7);
}

void TETRAClass::sendRequest(uint8_t type, uint8_t param) {
  uint8_t data[] = { type, param };
  TETRA.sendSysex(data, countof(data));
}

void TETRAClass::sendRequest(uint8_t type) {
  uint8_t data[] = { type };
  TETRA.sendSysex(data, countof(data));
}

void TETRAClass::requestProgramEditBuffer() {
  sendRequest(TETRA_PROGRAM_EDIT_BUFFER_REQUEST_ID);
}

TETRAClass TETRA;
