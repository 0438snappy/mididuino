#include <MelodyHelperSketch.h>
#include <MidiClockPage.h>

MDLivePatchSketch sketch;
MelodyHelperSketch sketch2;
//SketchSwitchPage sketchSwitchPage(NULL, &sketch, &sketch2, &sketch3, &sketch4);
SketchSwitchPage sketchSwitchPage(NULL, &sketch, &sketch2, NULL, NULL);

void setup() {
  initMDTask();
  
  sketch.setupMonster(true);
  sketch2.setupMonster(true);
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
