#include <inttypes.h>
#include <unistd.h>
#include <stdlib.h>

#include "WProgram.h"
#include "MidiSysex.hh"

#include "MidiUartOSX.h"

#include <stdio.h>

// MidiUartOSXClass MidiUart;
MidiUartOSXClass MidiUart2;

char *file = NULL;

bool printFirst = false;
bool printSecond = true;

int main(int argc, char *argv[]) {
  MidiUart.init(0, 0);
  MidiUart2.init(1, 1);

  for (;;) {
    MidiUart.runLoop();
    MidiUart2.runLoop();
    bool startPrint;
    
    startPrint = false;
    while (MidiUart.avail()) {
      uint8_t c = MidiUart.getc();
      if (printFirst) {
	if (!MIDI_IS_REALTIME_STATUS_BYTE(c)) {
	  if (!startPrint) {
	    startPrint = true;
	    printf("1 -> 2: ");
	  }
	  printf("%.2x ", c);
	}
      }
      MidiUart2.putc(c);
    }
    if (startPrint && printFirst)
      printf("\n");
    startPrint = false;
    while (MidiUart2.avail()) {
      uint8_t c = MidiUart2.getc();
      if (printSecond) {
	if (!MIDI_IS_REALTIME_STATUS_BYTE(c)) {
	  if (!startPrint) {
	    startPrint = true;
	    printf("2 -> 1: ");
	  }
	  printf("%.2x ", c);
	}
      }

      MidiUart.putc(c);
    }

    if (startPrint && printSecond)
      printf("\n");

    usleep(1000);
  }

  return 0;
}
