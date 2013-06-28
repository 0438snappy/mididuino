/*
*  As the NRPN implementation on the Novation Remote SL controller is buggy as hell (sends data values via "data entry coarse"  instead of "data entry fine")
*  this class will allow mapping/translation of CCs received on the Tetra Midi channel at Midi In 2, into the correct NRPN values.
*/
class TetraCcToNrpnTranslator : public MidiCallback{  

public:
  
  TetraCcToNrpnTranslator() 
  {
  }  
  
  void setup() {
      Midi2.addOnControlChangeCallback(this, (midi_callback_ptr_t)&TetraCcToNrpnTranslator::onControlChange);      
  }
  
  void onControlChange(uint8_t *msg) {         
   
      uint8_t channel = MIDI_VOICE_CHANNEL(msg[0]);
      uint8_t cc = msg[1];
      uint8_t ccValue = msg[2]; 
    
      // Translate the CC into a TETRA NRPN.  CC Number received = the Tetra Parameter number to be transmitted.
      if (channel == TETRA.midiChannel){
          uint16_t nrpn = TETRA.getParameterNrpn(cc);
          uint8_t nrpnMaxValue = TETRA.getParameterMax(cc);
          if(nrpn < 255){              
              
              // Scale the value and send NRPN
              uint16_t value = (ccValue * nrpnMaxValue) / 127;
              MidiUart.sendNRPN(channel, nrpn, value);
              
              // Keep internal representation of program data in sync.  Refresh tetraEditorPage to show any changes in values.
              if (TETRA.loadedProgram) {
                  TETRA.program.parameters[cc] = value;
                  tetraEditorPage.setEditorPage();
              }
              
              // Flash some text to the screen to alert user to translation
              GUI.setLine(GUI.LINE1);
              GUI.flash_printf_fill("CC %b NRPN %b", cc, nrpn);
              GUI.setLine(GUI.LINE2);
              GUI.flash_printf_fill("VAL %b -> %b", ccValue, value);
              return;
          }
      }
    
      // If we haven't returned already, then echo the message out on the same midi channel
      MidiUart.sendMessage(msg[0], msg[1], msg[2]);          
  } 
  
};
