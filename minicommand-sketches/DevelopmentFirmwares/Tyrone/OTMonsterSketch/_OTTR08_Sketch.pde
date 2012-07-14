#include <Platform.h>
//#include <WProgram.h>

class OctatrackTransposeSketch : public Sketch, public MidiCallback{  

    public:
    bool muted;
    OctatrackTransposeClass octatrackTranspose;
    TransposeConfigPage internalTrackConfigPage;
    
    OctatrackTransposeSketch() : 
    internalTrackConfigPage(&octatrackTranspose, INTERNAL_TRACKS)
    {
    }  
       
    void getName(char *n1, char *n2) {
        m_strncpy_p(n1, PSTR("OT  "), 5);
        m_strncpy_p(n2, PSTR("TRN "), 5);
      }   
     
    void setup() {
       muted = false;
       octatrackTranspose.setup();
//       Midi.addOnNoteOnCallback(this, (midi_callback_ptr_t)&OctatrackTransposeSketch::on3ByteCallback);
//       Midi.addOnNoteOffCallback(this, (midi_callback_ptr_t)&OctatrackTransposeSketch::on3ByteCallback);       
//       Midi.addOnControlChangeCallback(this, (midi_callback_ptr_t)&OctatrackTransposeSketch::on3ByteCallback);              
    }
        
    virtual void show() {
        if (currentPage() == NULL){
            setPage(&internalTrackConfigPage);
        }
    }   
    
    virtual void hide() {
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

       return false;
    }   
    
//  void on3ByteCallback(uint8_t *msg) {
//    MidiUart.sendMessage(msg[0], msg[1], msg[2]);
//  }
//
//  void on2ByteCallback(uint8_t *msg) {
//    MidiUart.sendMessage(msg[0], msg[1]);
//  }    

};

