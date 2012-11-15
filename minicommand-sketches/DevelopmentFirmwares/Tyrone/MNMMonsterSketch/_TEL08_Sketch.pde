class TetraEditorSketch : 
public Sketch{  

public:
  bool muted;
  TetraEditorPage tetraEditorPage;  

  TetraEditorSketch() 
  {
  }  

  void setupPages(){

    // Set up Tetra Editor pages
    tetraEditorPage.setup();
    tetraEditorPage.setShortName("TET");
    tetraParameterAssignPage.setup();    
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
    if (currentPage() == NULL){
      setPage(&tetraEditorPage);
    }
  }   

  virtual void mute(bool pressed) {
    if (pressed) {
      muted = !muted;
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
       
    return false;
  }   

};


