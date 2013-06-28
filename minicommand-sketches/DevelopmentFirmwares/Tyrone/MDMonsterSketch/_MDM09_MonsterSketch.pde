#include <MelodyHelperSketch.h>
#include <MidiClockPage.h>

MDLiveSketch sketch;
MDFXSketch sketch2;
MelodyHelperSketch sketch3;
//SketchSwitchPage sketchSwitchPage(NULL, &sketch, &sketch2, &sketch3, &sketch4);
SketchSwitchPage sketchSwitchPage(NULL, &sketch, &sketch2, &sketch3, NULL);

void setup() {
  initMDTask();
  
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
