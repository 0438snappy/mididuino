/**
 * Creates a page feature 4 encoders that are overlayed with
 * recording encoder to provide recording functionality. 
 *
 * Redefinition of Manuel's AutoEncoderPage with some changes to 
 * button configurations, plus a couple of new methods to learn and clear CCs
 * for specific encoders
 *
 * This version of the page is specialised for MDFXEncoders and does not contain the usual autolearn CC functionality.
 * Use the setup(MDFXEncoder *e1, *e2, etc...) method to assign pointers to pre-initialised MDFX encoders to this page
 *
 **/

class AutoMDFXEncoderPage : public EncoderPage, public ClockCallback {
 public:
  MDFXEncoder *realEncoders[4];
  const static int RECORDING_LENGTH = 128; // recording length in 32th
  RecordingEncoder<RECORDING_LENGTH> recEncoders[4];  
  RangeEncoder recLengthEncoders[4];

  bool muted;
  bool guiInRecordMode;
  bool recLengthEncodersDisplayed;
  void on32Callback(uint32_t counter);
  void startRecording();
  void stopRecording();
  void clearRecording();
  void clearRecording(uint8_t i);
  virtual void setup();
  virtual void setup(MDFXEncoder *e1, MDFXEncoder *e2, MDFXEncoder *e3, MDFXEncoder *e4);  
  virtual void loop();
  void displayRecLengthEncoders();
  void displayRecLengthEncoders(bool _display);

  virtual bool handleEvent(gui_event_t *event);
};


void AutoMDFXEncoderPage::setup(MDFXEncoder *e1, MDFXEncoder *e2, MDFXEncoder *e3, MDFXEncoder *e4) {
  realEncoders[0] = e1;
  realEncoders[1] = e2;
  realEncoders[2] = e3;
  realEncoders[3] = e4;
  setup();
}


void AutoMDFXEncoderPage::setup() {

  muted = false;
  guiInRecordMode = true;
  recLengthEncodersDisplayed = false;
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].initRecordingEncoder(realEncoders[i]);
    encoders[i] = &recEncoders[i];
    recLengthEncoders[i].initRangeEncoder(RECORDING_LENGTH, 2, "LEN", RECORDING_LENGTH);
  }  
  MidiClock.addOn32Callback(this, (midi_clock_callback_ptr_t)&AutoMDFXEncoderPage::on32Callback);
  EncoderPage::setup();
}

/*
 * Using the page loop() method to look for changes to the recordingLengthEncoders
 */
void AutoMDFXEncoderPage::loop() {
  if (!recLengthEncodersDisplayed){
     return; 
  }
  
  for (uint8_t i = 0; i < 4; i++) {
      if (recLengthEncoders[i].hasChanged()){
          recEncoders[i].setRecordingLength(recLengthEncoders[i].getValue());          
      }
  }
}

/*
 * Toggles display between the normal recording encoders, or the recordingLength config encoders
 */
void AutoMDFXEncoderPage::displayRecLengthEncoders() {

  recLengthEncodersDisplayed = !recLengthEncodersDisplayed;
  displayRecLengthEncoders(recLengthEncodersDisplayed);

}

void AutoMDFXEncoderPage::displayRecLengthEncoders(bool _display) {
  
  recLengthEncodersDisplayed = _display;

  if (recLengthEncodersDisplayed){
      for (uint8_t i = 0; i < 4; i++) {
          encoders[i] = &recLengthEncoders[i];     
      } 
  } else {
      for (uint8_t i = 0; i < 4; i++) {
          encoders[i] = &recEncoders[i];     
      }    
  }  
  redisplayPage ();  
}

void AutoMDFXEncoderPage::on32Callback(uint32_t counter) {
  if (muted){
    return;
  }

  /*
   * The following code just copies the handling of recording encoders in order to save CPU time.
   * This callback is called from the clock callback and thus needs to be quick.
   */
  uint8_t pos = counter & 0xFF; 
  for (uint8_t i = 0; i < 4; i++) {
    RecordingEncoder<RECORDING_LENGTH> *encoder = recEncoders + i;
    if (!encoder->playing){
        continue;
    }
    uint8_t currentPos = pos % encoder->recordingLength;   
    
    // Normal Recording Encoder handling
    encoder->currentPos = currentPos;  
    if (encoder->value[currentPos] != -1) {
        if (!(encoder->recording && encoder->recordChanged)) {    
            encoder->realEnc->setValue(encoder->value[currentPos], true);
            encoder->redisplay = encoder->realEnc->redisplay;
        }
    }
  }
}


void AutoMDFXEncoderPage::startRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].startRecording();
  }
}


void AutoMDFXEncoderPage::stopRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].stopRecording();
  }
}


void AutoMDFXEncoderPage::clearRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].clearRecording();
  }
}


void AutoMDFXEncoderPage::clearRecording(uint8_t i) {
  recEncoders[i].clearRecording();
}



/*
*
*  The autoencoder page has two "modes" of operation:  
*  1)  Record mode: gui is used to learn / assign incoming CC's to the encoders, record encoder movements
*  2)  Playback mode: gui is used to start / stop / modify recording playback options
*
*/
bool AutoMDFXEncoderPage::handleEvent(gui_event_t *event) {

  
  /*
  *
  *  TOGGLE BETWEEN RECORD AND PLAYBACK MODE - activated by pressing button 2 then button 1
  *
  */
  if (BUTTON_DOWN(Buttons.BUTTON2)) {
      if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
          guiInRecordMode = !guiInRecordMode;
          if (guiInRecordMode){
                displayRecLengthEncoders(false);
                GUI.flash_strings_fill("GUI CONFIG:", "RECORD MODE");            
          } else {
                GUI.flash_strings_fill("GUI CONFIG:", "PLAYBACK MODE");          
          }
          return true;
      }        
  }  
  
  /*
  *  RECORD MODE BUTTON OPERATIONS
  */
  if (guiInRecordMode){
      
      /*
      *
      *  REC MODE - toggled on/off by pressing button 2 without any other buttons
      *
      */
      if (BUTTON_UP(Buttons.BUTTON3)) {
         if (BUTTON_UP(Buttons.BUTTON4)) {
            if (EVENT_PRESSED(event, Buttons.BUTTON2)) {
              GUI.flash_strings_fill("REC: START", "");
              startRecording();
              return true;
            }
            if (EVENT_RELEASED(event, Buttons.BUTTON2)) {
              GUI.flash_strings_fill("REC: STOP", "");
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
      if(EVENT_PRESSED(event, Buttons.BUTTON3)) {
          GUI.flash_strings_fill("CLICK AN ENCODER", "TO CLEAR REC");    
      }          
      if (BUTTON_DOWN(Buttons.BUTTON3)) {
        
          // Pressing Button3 + Encoder = Clear Encoder Recording
          for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
            if (EVENT_PRESSED(event, i)) {
                GUI.setLine(GUI.LINE1);
                GUI.flash_string_fill("CLEARED REC:");
                GUI.setLine(GUI.LINE2);
                GUI.flash_put_value(0, i + 1);
                clearRecording(i);
                return true;
            }
          }
            
          // Pressing Button3 + Button 2 = Clear all Encoder Recordings
          if (EVENT_PRESSED(event, Buttons.BUTTON2)) {
                GUI.setLine(GUI.LINE1);
                GUI.flash_string_fill("CLEARED ALL RECS");
                clearRecording();
                ccHandler.incomingCCs.clear();        
                return true;                
          }                                
      }

  /*
  *  PLAYBACK MODE BUTTON OPERATIONS
  */
  } else {
      /*
      *
      *  PLAYBACK OF ENCODER RECORDINGS - toggled on/off by pressing button 4 + encoder
      *
      */     
      if(EVENT_PRESSED(event, Buttons.BUTTON4)) {      
          GUI.flash_strings_fill("CLICK AN ENCODER", "STOP/START PLAY");                 
      }
      if (BUTTON_DOWN(Buttons.BUTTON4)) {
          for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
              if (EVENT_PRESSED(event, i)) {
                  recEncoders[i].playing = !recEncoders[i].playing;                  
                  GUI.setLine(GUI.LINE1);
                  char *encoderName;
                  encoderName = "ENC X PLAYBACK:";
                  encoderName[4] = '0' + i + 1;
                  GUI.flash_string_fill(encoderName);               
                  GUI.setLine(GUI.LINE2);
                  if (recEncoders[i].playing){
                      GUI.flash_string_fill("ON");
                  } else {
                      GUI.flash_string_fill("OFF");                    
                  }
                  return true;
              }
          }    
      }
      /*
      *
      *  HALVE PLAYBACK LENGTH - press button 2 + encoder
      *
      */        
      if(EVENT_PRESSED(event, Buttons.BUTTON2)) {      
              GUI.flash_strings_fill("CLICK AN ENCODER", "TO 1/2 LOOP");      
      }      
      if (BUTTON_DOWN(Buttons.BUTTON2)) {
          for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
              if (EVENT_PRESSED(event, i)) {
                  recEncoders[i].halveRecordingLength();  
                  recLengthEncoders[i].setValue(recEncoders[i].recordingLength);                  
                  GUI.setLine(GUI.LINE1);
                  char *encoderName;
                  encoderName = "ENC X LOOP LEN:";
                  encoderName[4] = '0' + i + 1;
                  GUI.flash_string_fill(encoderName);               
                  GUI.setLine(GUI.LINE2);
                  GUI.flash_printf_fill("%b 32nd Notes", recEncoders[i].recordingLength);
                  return true;
              }        
          }
          
          /*
          *
          *  TOGGLE DISPLAY OF REC LENGTH CONFIG ENCODERS - press button 2 + button 3
          *
          */ 
          if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
              displayRecLengthEncoders();
              return true;
          }
      }
      /*
      *
      *  DOUBLE PLAYBACK LENGTH - press button 3 + encoder
      *
      */        
      if(EVENT_PRESSED(event, Buttons.BUTTON3)) {      
              GUI.flash_strings_fill("CLICK AN ENCODER", "TO x2 LOOP");      
      }            
      if (BUTTON_DOWN(Buttons.BUTTON3)) {
          for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
              if (EVENT_PRESSED(event, i)) {
                  recEncoders[i].doubleRecordingLength();  
                  recLengthEncoders[i].setValue(recEncoders[i].recordingLength);                                    
                  GUI.setLine(GUI.LINE1);
                  char *encoderName;
                  encoderName = "ENC X LOOP LEN:";
                  encoderName[4] = '0' + i + 1;
                  GUI.flash_string_fill(encoderName);               
                  GUI.setLine(GUI.LINE2);
                  GUI.flash_printf_fill("%b 32nd Notes", recEncoders[i].recordingLength);
              }
          }
      }      
 
  }
  return false;
}

