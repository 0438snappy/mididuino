/**
 * Creates a page feature 4 encoders that can be configured using a
 * template class parameter. These 4 encoders are overlayed with
 * recording encoder to provide recording functionality. 
 *
 * Redefinition of Manuel's AutoEncoderPage with some changes to 
 * button configurations, plus a couple of new methods to learn and clear CCs
 * for specific encoders, plus updated to handle TetraNRPN encoders
 *
 * Encoders are not autolearned, but need to be selected manually from the TetraEditorPage
 *
 **/
class AutoNRPNEncoderPage : public EncoderPage, public ClockCallback {
 public:
  TetraNRPNEncoder realEncoders[4];
  const static int RECORDING_LENGTH = 32; // recording length in 16th
  RecordingEncoder<RECORDING_LENGTH> recEncoders[4];

  bool muted;
  void on16Callback(uint32_t counter);
  void startRecording();
  void stopRecording();
  void clearRecording();
  void clearRecording(uint8_t i);
  virtual void setup();

  void clearEncoder(uint8_t i);
  void learnEncoder(uint8_t target_idx, uint8_t source_idx);

  virtual bool handleEvent(gui_event_t *event);
};



/**
 * Creates a page displaying some static text and 4 encoder options, designed to be used as a modal GUI to assign parameters back to the TetraAutoEncoderPages.  
 *
 * The user has the option to either:
 *     -  click an encoder, which will "select" the parameter and assign it back to the TetraAutoEncoderPage
 *     -  click any button, which will "cancel" the operation and return display to the calling page.
 *
 **/
class TetraParameterSelectPage : public EncoderPage {

  public: 
          
        TetraParameterSelectPage()
        {
      	}
        
        uint8_t targetEncoderIndex;
        AutoNRPNEncoderPage * targetPage;

        void setup(){   
          if (!isSetup){ 
              targetEncoderIndex = 0;
              targetPage = NULL;
              isSetup = true;
          }
        }      
        
        void display() {
            GUI.setLine(GUI.LINE1); 
            GUI.put_string_fill("-> SELECT PARAM:");
            GUI.setLine(GUI.LINE2); 
            for (int i=0; i<4; i++){
              uint8_t idx;
              idx = tetraEditorPages[pageIndex].parameterNumbers[i];
              if (idx != 0xFF){
                  PGM_P name= NULL;     
                  name = TETRA.getParameterName(idx);
                  GUI.put_p_string_at((i * 4), name);
              }
            }         
        } 
 
       void setEditorPage(){             
            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill(tetraEditorPages[pageIndex].longname);                        
            redisplayPage ();           
        }       
        
	bool handleEvent(gui_event_t *event) {
   
            // Pressing an encoder will assign the param to the auto encoder page
            for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER4; i++){
                if (EVENT_PRESSED(event, i)) {
                    
                    if (targetPage != NULL) {
                      targetPage->learnEncoder(targetEncoderIndex, i); 
                      targetPage->redisplayPage();
                    }                    
                    
                    GUI.popPage(this);
                }
            }
            
            // 
            // Pressing Button 2 (bottom left) displays "previous" editor page
            if (EVENT_PRESSED(event, Buttons.BUTTON2)) {
                pageIndex = mod(pageIndex-1, NUM_TETRA_EDITOR_PAGES);
                setEditorPage ();
                return true;
            }  
            
            // Pressing Button 3 (bottom right) displays "next" editor page
            if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
                pageIndex = mod(pageIndex + 1, NUM_TETRA_EDITOR_PAGES);
                setEditorPage ();
                return true;
            } 
            
            // Pressing Button 1 or 4 will "Cancel" the assign and pop back to the auto encoder page
            if ((EVENT_PRESSED(event, Buttons.BUTTON1)) || (EVENT_PRESSED(event, Buttons.BUTTON4))){
                GUI.popPage(this);
                return true;
            }                                       
            
            return false;

	}

};
TetraParameterSelectPage tetraParameterSelectPage;



void AutoNRPNEncoderPage::setup() {
  muted = false;
  for (uint8_t i = 0; i < 4; i++) {
    realEncoders[i].setName("___");
    recEncoders[i].initRecordingEncoder(&realEncoders[i]);
    encoders[i] = &recEncoders[i];
  }
  MidiClock.addOn16Callback(this, (midi_clock_callback_ptr_t)&AutoNRPNEncoderPage::on16Callback);
  EncoderPage::setup();
}

void AutoNRPNEncoderPage::on16Callback(uint32_t counter) {
  if (muted){
      return;
  }

  /*
   * The following code just copies the handling of recording encoders in order to save CPU time.
   * This callback is called from the clock callback and thus needs to be quick.
   */
  uint8_t pos = counter & 0xFF;
  uint8_t currentPos = pos % RECORDING_LENGTH;
  for (uint8_t i = 0; i < 4; i++) {
    RecordingEncoder<RECORDING_LENGTH> *encoder = recEncoders + i;
    encoder->currentPos = currentPos;
    if (encoder->value[currentPos] != -1) {
      if (!(encoder->recording && encoder->recordChanged)) {
        encoder->realEnc->setValue(encoder->value[currentPos], true);
        encoder->redisplay = encoder->realEnc->redisplay;
      }
    }
  }
}


void AutoNRPNEncoderPage::startRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].startRecording();
  }
}


void AutoNRPNEncoderPage::stopRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].stopRecording();
  }
}


void AutoNRPNEncoderPage::clearRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].clearRecording();
  }
}


void AutoNRPNEncoderPage::clearRecording(uint8_t i) {
  recEncoders[i].clearRecording();
}



void AutoNRPNEncoderPage::clearEncoder(uint8_t i) {	
    realEncoders[i].init();
    recEncoders[i].clearRecording();
}


void AutoNRPNEncoderPage::learnEncoder(uint8_t target_idx, uint8_t source_idx) {

    uint8_t idx;
    idx = tetraEditorPages[pageIndex].parameterNumbers[source_idx];
    if (idx != 0xFF){
        realEncoders[target_idx].initTETRAEncoder(idx);
    }
}



bool AutoNRPNEncoderPage::handleEvent(gui_event_t *event) {
  /*
  *
  *  LEARN MODE FUNCTIONS - activated by pressing button 4 + something else...
  *
  */
  if (BUTTON_UP(Buttons.BUTTON2) && BUTTON_DOWN(Buttons.BUTTON4) ) {
    
    
      // Button 4 + encoder = display TetraEditorEncoderSelect page  (user then clicks an encoder to assign it back to this page)
      for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
        if (EVENT_PRESSED(event, i)) {
            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill("LEARN ENC:");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);                          
            tetraParameterSelectPage.targetEncoderIndex = i;
            tetraParameterSelectPage.targetPage = this;
            tetraParameterSelectPage.setEditorPage();
            GUI.pushPage(&tetraParameterSelectPage);
      	    return true;
        } 
      }

      GUI.setLine(GUI.LINE1);
      GUI.flash_string_fill("CHOOSE ENC:");
  }
  
  /*
  *
  *  REC MODE - toggled on/off by pressing button 3 without any other buttons
  *
  */
  if (BUTTON_UP(Buttons.BUTTON3)) {
     if (BUTTON_UP(Buttons.BUTTON4)) {
        if (EVENT_PRESSED(event, Buttons.BUTTON2)) {
          GUI.flash_strings_fill("REC MODE ON", "");
          startRecording();
          return true;
        }
        if (EVENT_RELEASED(event, Buttons.BUTTON2)) {
          GUI.flash_strings_fill("REC MODE OFF", "");
          stopRecording();
          return true;
        }
     }
  }
  
  /*
  *
  * CLEAR MODE FUNCTIONS - activated by pressing button 3 + something else...
  *
  */
  if (BUTTON_DOWN(Buttons.BUTTON3)) {
    
      // Pressing Button3 + Encoder = Clear Encoder Recording
      for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
        if (EVENT_PRESSED(event, i)) {
            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill("CLEAR REC:");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);
            clearRecording(i);
        }
      }
        
      // Pressing Button3 + Button 2 + Encoder = Clear CC assigned to Encoder
      if (BUTTON_DOWN(Buttons.BUTTON2)) {
        for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
          if (EVENT_PRESSED(event, i)) {
            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill("CLEAR ENC:");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);
            clearEncoder(i);            
          }
        }
      }
  }
  return false;
}
