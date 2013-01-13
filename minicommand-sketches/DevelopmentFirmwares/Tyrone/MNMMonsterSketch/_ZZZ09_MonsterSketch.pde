//
//  TOP LEVEL SKETCH
//
#include <MidiClockPage.h>
//#include <Merger.h>
//Merger merger;
//MNMTransposeSketch sketch;
MNMLiveSketch sketch;
TetraEditorSketch sketch2;
//SketchSwitchPage sketchSwitchPage(NULL, &sketch, &sketch2, &sketch3, NULL);
SketchSwitchPage sketchSwitchPage(NULL, &sketch, &sketch2, NULL, NULL);


void setup() {

  sketch.setupMonster(true);    
  sketch2.setupMonster(true);
//  sketch3.setupMonster(true);  
  GUI.setSketch(&_defaultSketch);
  GUI.setPage(&sketchSwitchPage);
  GUI.addEventHandler(handleEvent);

  // Can't afford the space for a midiclock page, so manually set MidiClock settings...
  initClockPage();
//  MidiClock.stop();
//  MidiClock.mode = MidiClock.EXTERNAL_MIDI;
//  MidiClock.transmit = false;
//  MidiClock.useImmediateClock = true;
//  merger.setMergeMask(7); //MERGE_ALL
//  MidiClock.start();
  
  initMNMTask();
}

bool handleEvent(gui_event_t *event) {
  return sketchSwitchPage.handleGlobalEvent(event);
}

void loop() {
}
