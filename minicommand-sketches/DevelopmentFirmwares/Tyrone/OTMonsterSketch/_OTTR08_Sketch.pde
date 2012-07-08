#include <Platform.h>
//#include <WProgram.h>

class OctatrackTransposeSketch : public Sketch, public MidiCallback{  

    public:
    bool muted;
//    bool debug;
    OctatrackTransposeClass octatrackTranspose;
    TransposeConfigPage internalTrackConfigPage;
//    SwitchPage switchPage;
    
    OctatrackTransposeSketch() : 
    internalTrackConfigPage(&octatrackTranspose, INTERNAL_TRACKS)
    {
    }  
       
//    void setupSwitchPage(){
//       switchPage.initPages(&djEqPage, &filterPage, &recorderPage, NULL);
//       switchPage.parent = this;
//    }
      
    void setupPages(){
//        djEqPage.setup();
//        djEqPage.setShortName("EQ");
//        filterPage.setup();
//        filterPage.setShortName("FLT");
//        recorderPage.setup();
//        recorderPage.setShortName("REC");        
    }
       
    void getName(char *n1, char *n2) {
        m_strncpy_p(n1, PSTR("OT  "), 5);
        m_strncpy_p(n2, PSTR("TRN "), 5);
      }   
     
    void setup() {
       muted = false;
       octatrackTranspose.setup();
       Midi.addOnNoteOnCallback(this, (midi_callback_ptr_t)&OctatrackTransposeSketch::on3ByteCallback);
       Midi.addOnNoteOffCallback(this, (midi_callback_ptr_t)&OctatrackTransposeSketch::on3ByteCallback);       
       Midi.addOnControlChangeCallback(this, (midi_callback_ptr_t)&OctatrackTransposeSketch::on3ByteCallback);              
//       setupPages();
//       setupSwitchPage();
    }
        
    virtual void show() {
//        if (currentPage() == &switchPage){
//            popPage(&switchPage);
//        }
        if (currentPage() == NULL){
            setPage(&internalTrackConfigPage);
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
              GUI.flash_strings_fill("OT TRANSPOSE:", "MUTED");
          } else {
              GUI.flash_strings_fill("OT TRANSPOSE:", "UNMUTED");
          }
      }
    }  
  
    virtual Page *getPage(uint8_t i) {
      if (i == 0) {
        return &internalTrackConfigPage;
//      } 
//      if (i == 1) {
//        return &midiTrackConfigPage;
      } else {
        return NULL;
      }
    }  
       
    bool handleEvent(gui_event_t *event) {       

//       if (EVENT_PRESSED(event, Buttons.ENCODER4)) {
//           if(debug){
//               debug = false;               
//               GUI.popPage(&debugPage);                     
//           } else {
//               GUI.pushPage(&debugPage);
//               debug = true;  
//           }           
//       } 
       return false;
    }   
    
  void on3ByteCallback(uint8_t *msg) {
    if (MIDI_VOICE_CHANNEL(msg[0]==AUTO_TRACK_MIDI_CHANNEL)) {
        MidiUart.sendMessage(msg[0], msg[1], msg[2]);
    }
  }

  void on2ByteCallback(uint8_t *msg) {
    if (MIDI_VOICE_CHANNEL(msg[0]==AUTO_TRACK_MIDI_CHANNEL)) {    
        MidiUart.sendMessage(msg[0], msg[1]);
    }
  }    

};

