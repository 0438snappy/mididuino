#ifndef WProgram_h
#define WProgram_h

#define MIDIDUINO 1
#define SYSEX_BUF_SIZE 8192

#ifdef __cplusplus
extern "C" {
#endif
#include <inttypes.h>
#include <avr/interrupt.h>
#include "helpers.h"

  void delayMicroseconds(unsigned int us);
  void delay(unsigned int ms);
#ifdef __cplusplus
}
#endif

/* default config flags */
#define MIDIDUINO_POLL_GUI     1
#define MIDIDUINO_POLL_GUI_IRQ 1
#define MIDIDUINO_HANDLE_SYSEX 1
#define MIDIDUINO_MIDI_CLOCK   1
#define MIDIDUINO_USE_GUI      1
// #define MIDIDUINO_EXTERNAL_RAM 1
// #define MDIIDUINO_SD_CARD      1

#include "mididuino_private.h"

#ifdef __cplusplus
#include "LCD.h"
#include "GUI_private.h"
#include "MidiUart.h"
#include "MidiClock.h"
#include "Stack.h"
#include "GUI.h"
#include "Midi.h"
#include "WMath.h"
#endif

#endif /* WProgram_h */
