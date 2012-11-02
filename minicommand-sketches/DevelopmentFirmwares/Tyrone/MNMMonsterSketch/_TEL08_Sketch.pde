

class TetraEditorSketch : 
public Sketch{  

public:
  bool muted;
  TetraEditorPage tetraEditorPage;  

  TetraEditorSketch() : 
  tetraEditorPage(){

  }  

  void getName(char *n1, char *n2) {
    m_strncpy_p(n1, PSTR("TET "), 5);
    m_strncpy_p(n2, PSTR(" RA "), 5);
  }   

  void setup() {
    muted = false;
    tetraEditorPage.setup();
    tetraParameterAssignPage.setup();
  }  

  virtual void show() {
    if (currentPage() == NULL){
      setPage(&tetraEditorPage);
    }
  }   

//  virtual void mute(bool pressed) {
//    if (pressed) {
//      muted = !muted;
//      if (muted) {
//        GUI.flash_strings_fill("TETRA:", "MUTED");
//      } 
//      else {
//        GUI.flash_strings_fill("TETRA:", "UNMUTED");
//      }
//    }
//  }  

//  virtual Page *getPage(uint8_t i) {
//    if (i == 0) {
//      return &tetraEditorPage;
//    } 
//    else {
//      return NULL;
//    }
//  }  


  virtual bool handleEvent(gui_event_t *event) {      

    // Pressing button 1 (top left) displays "shortcuts" to osc, vcf, env pages.  
    if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
        GUI.setLine(GUI.LINE1);
        GUI.put_string_fill("SELECT PAGE:");
        GUI.setLine(GUI.LINE2);
        GUI.put_string_fill("VC1 VC2 VCF ENV");
    } else if (EVENT_RELEASED(event, Buttons.BUTTON1)) {
        tetraEditorPage.redisplayPage (); 
    }
    
    if (BUTTON_DOWN(Buttons.BUTTON1)) {
        for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER4; i++){
            if (EVENT_PRESSED(event, i)) {
                uint8_t shortcutPageIndex[4] = {0,1,5,8};
                tetraEditorPage.pageIndex = shortcutPageIndex[i];
                tetraEditorPage.setEditorPage(&tetraEditorPageEncoders[tetraEditorPage.pageIndex]);
                return true;
            }
        }                                   
    } 
    
    //return false;
  }   



};


