//
//  TOP LEVEL SKETCH
//
//#include <MidiClockPage.h>
#include <Merger.h>
Merger merger;
AutoEncoderSketch sketch;
SketchSwitchPage sketchSwitchPage(NULL, &sketch, NULL, NULL, NULL);

void setup() {
  initMNMTask();
  sketch.setupMonster(true); 
  GUI.setSketch(&_defaultSketch);
  GUI.setPage(&sketchSwitchPage);
  GUI.addEventHandler(handleEvent);

  // Can't afford the space for a midiclock page, so manually set MidiClock settings...
//  initClockPage();
  MidiClock.stop();
  MidiClock.mode = MidiClock.EXTERNAL_MIDI;
  MidiClock.transmit = false;
  MidiClock.useImmediateClock = true;
  merger.setMergeMask(7); //MERGE_ALL
  MidiClock.start();
}

bool handleEvent(gui_event_t *event) {
       return sketchSwitchPage.handleGlobalEvent(event);
}

void loop() {
}
