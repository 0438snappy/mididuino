//
//  TOP LEVEL SKETCH
//
#include <MidiClockPage.h>
MNMLiveSketch sketch2;
TetraEditorSketch sketch;
//MNMMonoPolySketch sketch4;
MNMTransposeSketch sketch3;
SketchSwitchPage sketchSwitchPage(NULL, &sketch, &sketch2, &sketch3, NULL);

void setup() {
  initMNMTask();
  sketch.setupMonster(true);    
  sketch2.setupMonster(true);
  sketch3.setupMonster(true);  
  //sketch4.setupMonster(true);    
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
