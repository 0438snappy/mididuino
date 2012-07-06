
class TetraEditorSketch : public Sketch{  

    public:
    bool muted;
    TetraEditorPage tetraEditorPage;
    SketchSwitchPage switchPage;
    
    TetraEditorSketch() : tetraEditorPage(){
      
    }  
       
//    void setupSwitchPage(){

//    }
      
    void setupPages(){
        tetraEditorPage.setup();
        switchPage.initPages(NULL, NULL, NULL, &tetraEditorPage);
        switchPage.parent = this;        
        
    }
       
    void getName(char *n1, char *n2) {
        m_strncpy_p(n1, PSTR("TET "), 5);
        m_strncpy_p(n2, PSTR(" RA "), 5);
      }   
     
    void setup() {
       muted = false;
       setupPages();
       //setupSwitchPage();
    }
        
    virtual void show() {
//        if (currentPage() == &switchPage){
//            popPage(&switchPage);
//        }
        if (currentPage() == NULL){
            setPage(&tetraEditorPage);
        }
    }   
    
    virtual void hide() {
//        if (currentPage() == &switchPage){
//            popPage(&switchPage);
//        }
    }    
    
    virtual void mute(bool pressed) {
      if (pressed) {
          muted = !muted;
          if (muted) {
              GUI.flash_strings_fill("TETRA EDITOR:", "MUTED");
          } else {
              GUI.flash_strings_fill("TETRA EDITOR:", "UNMUTED");
          }
      }
    }  
  
    virtual Page *getPage(uint8_t i) {
      if (i == 0) {
        return &tetraEditorPage;
      } else {
        return NULL;
      }
    }  

       
    bool handleEvent(gui_event_t *event) {       
      
           
//           // Top Left button
//           if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
//               displayPageGroupA();
//               return true;
//           }
//           
//           // Top Right button
//           if (EVENT_PRESSED(event, Buttons.BUTTON4)) {
//               displayPageGroupB();
//               return true;
//           }           
//           
//           // Bottom Right button
//           if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
//                recorderPage.startSupatrigga();
//           } else if (EVENT_RELEASED(event, Buttons.BUTTON3)) {
//                recorderPage.stopSupatrigga();
//           }         
       return false;
    }   
    
    

};
    
