class TetraEditorSketch : 
public Sketch{  

public:
  bool muted;
  TetraEditorPage tetraEditorPage;  
  AutoNRPNEncoderPage autoNRPNPages[NRPN_AUTO_PAGES_CNT]; 
  SwitchPage switchPage;

  TetraEditorSketch() 
  {
  }  

  void setupPages(){

    // Set up Tetra Editor pages
    pageIndex = 0;    
    tetraEditorPage.setup();
    tetraEditorPage.setShortName("TET");
    tetraParameterAssignPage.setup();    

    // Set up Tetra Auto Encoder pages    
    tetraParameterSelectPage.setup();    
    for (int i = 0; i < NRPN_AUTO_PAGES_CNT; i++) {
      autoNRPNPages[i].setup();
      autoNRPNPages[i].setShortName("A ");
      autoNRPNPages[i].shortName[1] = '0' + i + 1;
    }
    // TODO:  set up "defaults" for the autoNRPNPages?
    
    switchPage.initPages(&autoNRPNPages[0], &autoNRPNPages[1], &autoNRPNPages[2], &tetraEditorPage);
//    switchPage.initPages(&tetraEditorPage, &autoNRPNPages[0], NULL, NULL);    
//    switchPage.initPages(&tetraEditorPage, NULL, NULL, NULL);     
    switchPage.parent = this;        
  }

  void getName(char *n1, char *n2) {
    m_strncpy_p(n1, PSTR("TET "), 5);
    m_strncpy_p(n2, PSTR(" RA "), 5);
  }   

  void setup() {
    muted = false;
    setupPages();
  }

  virtual void show() {
    if (currentPage() == &switchPage){
        popPage(&switchPage);
    }
    if (currentPage() == NULL){
      setPage(&tetraEditorPage);
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
      if (muted) {
        GUI.flash_strings_fill("TETRA EDITOR:", "MUTED");
      } 
      else {
        GUI.flash_strings_fill("TETRA EDITOR:", "UNMUTED");
      }
    }
  }  

  virtual Page *getPage(uint8_t i) {
    if (i == 0) {
      return &tetraEditorPage;
    } 
    else {
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
    return false;
  }   

};


