#include <Platform.h>
//#include <WProgram.h>
#define MNM_TRANSPOSE_INPUT_MIDI_CHANNEL (16 - 1)  // Midi Channel 16
#define MNM_TRANSPOSE_OUTPUT_MIDI_CHANNEL (7 - 1)  // Midi Channel 7

class MNMTransposeSketch : public Sketch, public MidiCallback{  

    public:
    bool muted;
    Page mnmTransposePage;
    
    MNMTransposeSketch() 
    {
    }  
       
    void getName(char *n1, char *n2) {
        m_strncpy_p(n1, PSTR("MNM "), 5);
        m_strncpy_p(n2, PSTR("TRN "), 5);
      }   
     
    void setup() {
       muted = false;
       Midi2.addOnNoteOnCallback(this, (midi_callback_ptr_t)&MNMTransposeSketch::onNoteOnCallback);
       Midi2.addOnNoteOffCallback(this, (midi_callback_ptr_t)&MNMTransposeSketch::onNoteOffCallback);  
    }
        
    virtual void show() {
        if (currentPage() == NULL){
            setPage(&mnmTransposePage);
        }
    }   
    
    virtual void loop() {      
        GUI.setLine(GUI.LINE1);
        GUI.put_string_fill("MNM TRANSPOSE:");          
    }      
    
    virtual void hide() {
    }    
    
    virtual void mute(bool pressed) {
      if (pressed) {
          muted = !muted;
          if (muted) {
              GUI.flash_strings_fill("MNM TRANSPOSE:", "MUTED");
          } else {
              GUI.flash_strings_fill("MNM TRANSPOSE:", "UNMUTED");         
          }
      }
    }  
  
    virtual Page *getPage(uint8_t i) {
      if (i == 0) {
        return &mnmTransposePage;
      } else {
        return NULL;
      }
    }  
       
    bool handleEvent(gui_event_t *event) {       
        return false;
    }   

    void onNoteOnCallback(uint8_t *msg) {
      
        // FILTER FOR MNM_TRANSPOSE_INPUT_MIDI_CHANNEL MIDI CHANNEL      
        if (MIDI_VOICE_CHANNEL(msg[0]) == MNM_TRANSPOSE_INPUT_MIDI_CHANNEL) { 
            
            // Echo the message out on the MNM_TRANSPOSE_OUTPUT_MIDI_CHANNEL 
            MidiUart.sendNoteOn(MNM_TRANSPOSE_OUTPUT_MIDI_CHANNEL, msg[1], msg[2]);
            
            // Flash a message to the screen        
            GUI.setLine(GUI.LINE2);
            GUI.flash_printf_fill("NOTE ON: %b", msg[1]);
        }
    }

    void onNoteOffCallback(uint8_t *msg) {
        // FILTER FOR MNM_TRANSPOSE_INPUT_MIDI_CHANNEL MIDI CHANNEL      
        if (MIDI_VOICE_CHANNEL(msg[0]) == MNM_TRANSPOSE_INPUT_MIDI_CHANNEL) { 
           // Do nothing, just absorb the note off... 
        }
    }
    

};

