//
//  TOP LEVEL SKETCH
//
#include <MidiClockPage.h>
MNMTransposeSketch sketch;
TetraEditorSketch sketch2;
MNMLiveSketch sketch3;
SketchSwitchPage sketchSwitchPage(NULL, &sketch, &sketch2, &sketch3, NULL);
//SketchSwitchPage sketchSwitchPage(NULL, &sketch, NULL, NULL, NULL);

void setup() {
  initMNMTask();
  sketch.setupMonster(true);    
  sketch2.setupMonster(true);
  sketch3.setupMonster(true);  
  GUI.setSketch(&_defaultSketch);
  GUI.setPage(&sketchSwitchPage);
  GUI.addEventHandler(handleEvent);

  initClockPage();
}

bool handleEvent(gui_event_t *event) {
  return sketchSwitchPage.handleGlobalEvent(event);
}

void loop() {
}
