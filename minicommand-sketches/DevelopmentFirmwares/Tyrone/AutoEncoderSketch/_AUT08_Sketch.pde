class AutoEncoderSketch : 
public Sketch{  

public:
  bool muted;
  AutoNRPNEncoderPage autoNRPNPages[NRPN_AUTO_PAGES_CNT]; 
  AutoCCEncoderPage autoMNMPages[MNM_AUTO_PAGES_CNT];
  SwitchPage switchPage;

  AutoEncoderSketch() 
  {
  }  

  void setupPages(){

    // Set up Tetra Auto Encoder pages    
    tetraParameterSelectPage.setup();    
    for (int i = 0; i < NRPN_AUTO_PAGES_CNT; i++) {
      autoNRPNPages[i].setup();
      autoNRPNPages[i].setShortName("T ");
      autoNRPNPages[i].shortName[1] = '0' + i + 1;
    }
    
    // Set up MNM Auto Encoder pages
    for (int i = 0; i < MNM_AUTO_PAGES_CNT; i++) {
      autoMNMPages[i].setup();
      autoMNMPages[i].setShortName("M ");
      autoMNMPages[i].shortName[1] = '0' + i + 1;
    }
    
    switchPage.initPages(&autoNRPNPages[0], &autoNRPNPages[1], &autoMNMPages[0], &autoMNMPages[1]);
    switchPage.parent = this;        
  }

  void getName(char *n1, char *n2) {
    m_strncpy_p(n1, PSTR("AUT "), 5);
    m_strncpy_p(n2, PSTR("ENC "), 5);
  }   

  void setup() {
    muted = false;
    setupPages();
    ccHandler.setup();
  }

  virtual void show() {
    if (currentPage() == &switchPage){
        popPage(&switchPage);
    }
    if (currentPage() == NULL){
      setPage(&autoNRPNPages[0]);
    }
  }   

  virtual void hide() {
      if (currentPage() == &switchPage){
          popPage(&switchPage);
      }
  }    

  virtual void mute(bool pressed) {
    if (pressed) {
      muted = !muted;
      // Set muted on Auto NRPN pages
      for (int i = 0; i < NRPN_AUTO_PAGES_CNT; i++) {
        autoNRPNPages[i].muted = muted;
      }
      // Set muted on MNM NRPN pages
      for (int i = 0; i < MNM_AUTO_PAGES_CNT; i++) {
        autoMNMPages[i].muted = muted;
      }      
      if (muted) {
        GUI.flash_strings_fill("AUTO ENCODER:", "MUTED");
      } 
      else {
        GUI.flash_strings_fill("AUTO ENCODER:", "UNMUTED");
      }
    }
  }  

  virtual Page *getPage(uint8_t i) {
    if (i == 0) {
        return &autoNRPNPages[0];
    } else if (i == 1) {
        return &autoNRPNPages[1];
    } else if (i == 2) {
        return &autoMNMPages[0];
    } else if (i == 3) {  
        return &autoMNMPages[1];
    } else {
      return NULL;
    }
  }  


  virtual bool handleEvent(gui_event_t *event) {       

    if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
      pushPage(&switchPage);
    } 
    else if (EVENT_RELEASED(event, Buttons.BUTTON1)) {
      popPage(&switchPage);
    }  

    if (BUTTON_DOWN(Buttons.BUTTON3)) {
      if (EVENT_PRESSED(event, Buttons.BUTTON4)) {
        MNM.revertToCurrentKit(true);
        GUI.flash_strings_fill("REVERT TO KIT:", MNM.kit.name);
      } 
      else if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
        MNM.revertToCurrentTrack(true);
        GUI.flash_strings_fill("REVERT TO TRK ", "");
        GUI.setLine(GUI.LINE1);
        GUI.flash_put_value_at(14, MNM.currentTrack + 1);
        GUI.setLine(GUI.LINE2);
        GUI.flash_p_string_fill(MNM.getMachineName(MNM.kit.models[MNM.currentTrack]));
      }
      return true;
    }     
    return false;
  }   

};


