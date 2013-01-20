#define MD_AUTO_PAGES_CNT 4

class MDLiveSketch : 
public Sketch, public MDCallback, public ClockCallback, public MidiCallback {
public:  
  AutoCCEncoderPage autoMDPages[MD_AUTO_PAGES_CNT];
  SwitchPage switchPage;

  void setupPages() {
    for (int i = 0; i < MD_AUTO_PAGES_CNT; i++) {
      autoMDPages[i].setup();
      autoMDPages[i].setShortName("  ");
      autoMDPages[i].shortName[2] = '0' + i + 1;
    }

    switchPage.initPages(&autoMDPages[0], &autoMDPages[1], &autoMDPages[2], &autoMDPages[3]);
    switchPage.parent = this;
  }

  virtual void setup() {
    setupPages();
    ccHandler.setup();
    setPage(&autoMDPages[0]);
  }

  virtual bool handleEvent(gui_event_t *event) {
    if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
      pushPage(&switchPage);
    } 
    else if (EVENT_RELEASED(event, Buttons.BUTTON1)) {
      popPage(&switchPage);
    } 
    return true;
  }

  void getName(char *n1, char *n2) {
    m_strncpy_p(n1, PSTR("MD "), 5);
    m_strncpy_p(n2, PSTR("LIV "), 5);
  }

  virtual void show() {
    if (currentPage() == NULL)
      setPage(&autoMDPages[0]);
  }

  virtual void hide() {
      if (currentPage() == &switchPage){
          popPage(&switchPage);
      }
  }

  virtual void mute(bool pressed) {
    if (pressed) {
      muted = !muted;
      for (int i = 0; i < MD_AUTO_PAGES_CNT; i++) {
        autoMDPages[i].muted = muted;
      }
      if (muted) {
	  GUI.flash_strings_fill("MD LIVE", "MUTED");
      } else {
	  GUI.flash_strings_fill("MD LIVE", "UNMUTED");
      }
    }
  }

//  virtual void doExtra(bool pressed) {
//  }

  virtual Page *getPage(uint8_t i) {
    if (i < MD_AUTO_PAGES_CNT) {
      return &autoMDPages[i];
    } else {
      return NULL;
    }
  }
  
};


