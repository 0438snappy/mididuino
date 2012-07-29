

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
  if (muted)
    return;

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

// assigns the last incoming cc in the cchandler buffer to the specified encoder

void AutoNRPNEncoderPage::learnEncoder(uint8_t i, TetraNRPNEncoder *enc) {

    realEncoders[i].paramNumber = enc->paramNumber;
    realEncoders[i].nrpn = enc->nrpn; 
    realEncoders[i].channel = enc->channel;
    realEncoders[i].setName(enc->name);
    realEncoders[i].longName = enc->longName;
    realEncoders[i].min = enc->min;
    realEncoders[i].max = enc->max;
    realEncoders[i].setValue(enc->getValue());	 	  

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

            tetraParameterSelectPage.targetEncoderIndex = i;
            tetraParameterSelectPage.targetPage = this;
            tetraParameterSelectPage.setEditorPage(&tetraEditorPageEncoders[pageIndex]);

            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill("LEARN ENC NRPN");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);                
            GUI.pushPage(&tetraParameterSelectPage);
      	    return true;
        } 
      }
    
  }
  
  /*
  *
  *  REC MODE - toggled on/off by pressing button 3 without any other buttons
  *
  */
  if (BUTTON_UP(Buttons.BUTTON3)) {
     if (BUTTON_UP(Buttons.BUTTON4)) {
        if (EVENT_PRESSED(event, Buttons.BUTTON2)) {
          GUI.flash_strings_fill("RECORD MODE ON", "");
          startRecording();
          return true;
        }
        if (EVENT_RELEASED(event, Buttons.BUTTON2)) {
          GUI.flash_strings_fill("RECORD MODE OFF", "");
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
            GUI.flash_string_fill("CLEAR RECORDING:");
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
            GUI.flash_string_fill("CLEAR ENCODER:");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);
            clearEncoder(i);            
          }
        }
      }
  }
  return false;
}
