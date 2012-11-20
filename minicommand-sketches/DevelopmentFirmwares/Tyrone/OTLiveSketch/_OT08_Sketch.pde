#include <Platform.h>
#include <CCHandler.h>

#define AUTO_ENC_PAGE_COUNT 2
#define CUT_ADD_PAGE_COUNT 2


class OctatrackLiveSketch : public Sketch{  

    public:
    bool muted;
    
    /*  Stores which CutAdd pages the sketch is currently displaying  */
    uint8_t caPagesIdx[CUT_ADD_PAGE_COUNT];  
    uint8_t activeCaPage;
    
    OTCutAddPage otCutAddPages[8];
    AutoCCEncoderPage autoCCEncoderPages[AUTO_ENC_PAGE_COUNT];
    OTLiveSwitchPage otLiveSwitchPage;    
    
    OctatrackLiveSketch(){
    }  
             
    void setupPages(){
        for (int i = 0; i < CUT_ADD_PAGE_COUNT; i++){
             caPagesIdx[i] = OT_TRACK_5_MIDI_CHANNEL + i;
        }      
        for (int i = OT_TRACK_1_MIDI_CHANNEL; i <= OT_TRACK_8_MIDI_CHANNEL; i++){
            otCutAddPages[i].setup(i);
            otCutAddPages[i].setShortName("OT ");
            otCutAddPages[i].setName("OT TRACK ");
            otCutAddPages[i].name[9] = '0' + i + 1;            
            otCutAddPages[i].shortName[2] = '0' + i + 1;
            otLiveScrollSwitchPage.addPage(&otCutAddPages[i]);
        }      
        for (int i = 0; i <= AUTO_ENC_PAGE_COUNT; i++){
            autoCCEncoderPages[i].setup();
            autoCCEncoderPages[i].setShortName(" A ");
            autoCCEncoderPages[i].shortName[2] = '0' + i + 1;
        }    
        
        otLiveScrollSwitchPage.parent = this;
        otLiveScrollSwitchPage.setName("SELECT TRACK:");
        
        otLiveSwitchPage.initPages(&otCutAddPages[caPagesIdx[0]], &otCutAddPages[caPagesIdx[1]], &autoCCEncoderPages[0], &autoCCEncoderPages[1]);        
        otLiveSwitchPage.parent = this;
    }
       
    void getName(char *n1, char *n2) {
        m_strncpy_p(n1, PSTR("OT  "), 5);
        m_strncpy_p(n2, PSTR("LIV "), 5);
      }   
     
    void setCaPageIdx(uint8_t value){
       caPagesIdx[activeCaPage]=value;
       
       // Refresh the Slot Select page
       otLiveSwitchPage.pages[activeCaPage]=&otCutAddPages[caPagesIdx[activeCaPage]];
    } 
    
    void setActiveCaPage(uint8_t value){
       activeCaPage=value; 
    }    
     
    void setup() {
       muted = false;
       activeCaPage = 0;
       ccHandler.setup();
       setupPages();
    }
        
    virtual void show() {
        if (currentPage() == &otLiveSwitchPage){
            popPage(&otLiveSwitchPage);
        }
        if (currentPage() == &otLiveScrollSwitchPage){
            popPage(&otLiveScrollSwitchPage);
        }         
        if (currentPage() == NULL){
            setPage(&otCutAddPages[caPagesIdx[activeCaPage]]);
        }
    }   
    
    virtual void hide() {
        if (currentPage() == &otLiveSwitchPage){
            popPage(&otLiveSwitchPage);
        }
        if (currentPage() == &otLiveScrollSwitchPage){
            popPage(&otLiveScrollSwitchPage);
        }        
    }    
    
    virtual void mute(bool pressed) {
      if (pressed) {
          muted = !muted;
          if (muted) {
              GUI.flash_strings_fill("OCTATRACK LIVE:", "MUTED");
          } else {
              GUI.flash_strings_fill("OCTATRACK LIVE:", "UNMUTED");
          }
      }
    }  
  
    // contains hardcoded awesomeness!  
    virtual Page *getPage(uint8_t i) {
      if (i <= 1) {
        return &otCutAddPages[caPagesIdx[i]];
      } 
      if (i > 1 && i<=3){
        return &autoCCEncoderPages[i];
      } else {
        return NULL;
      }
    }  
    
    
    
    bool handleEvent(gui_event_t *event) {       
      
        if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
          pushPage(&otLiveSwitchPage);
        } 
        else if (EVENT_RELEASED(event, Buttons.BUTTON1)) {
          popPage(&otLiveSwitchPage);
        }     

       return false;
    }   
    
    

};


bool OTLiveSwitchPage::handleEvent(gui_event_t *event) {
  for (int i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
    if (pages[i] != NULL && EVENT_PRESSED(event, i)) {
      if (parent != NULL) {
        parent->setPage(pages[i]);
        // contains hardcoded awesomeness!          
        if (i<=Buttons.ENCODER2){
            parent->setActiveCaPage(i);
        }
      }
      return true;
    }
  }
  return false;
}


bool OTLiveScrollSwitchPage::handleEvent(gui_event_t *event) {
  Page *page = pages.arr[pageEncoder.getValue()];
  if (page != NULL) {
    if (EVENT_PRESSED(event, Buttons.ENCODER1)) {
      if (parent != NULL) {
        parent->setPage(page);
        parent->setCaPageIdx(pageEncoder.getValue());
      }
      return true;
    }
  }
  
  if (EVENT_RELEASED(event, Buttons.BUTTON4)) {
     GUI.popPage(this);
     return true;               
  } 
  return false;
}
    
