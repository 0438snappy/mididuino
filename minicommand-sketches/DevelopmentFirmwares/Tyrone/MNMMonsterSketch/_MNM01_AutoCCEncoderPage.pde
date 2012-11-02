#include <MNM.h>
#include "Platform.h"
//#include "WProgram.h"
#include "GUI.h"
#include "CCHandler.h"
#include "RecordingEncoder.hh"


/**
 * Creates a page feature 4 encoders that can be configured using a
 * template class parameter. These 4 encoders are overlayed with
 * recording encoder to provide recording functionality. The page also
 * provides autolearning functionality to MIDI learn 4 encoders on the
 * fly.
 *
 * Redefinition of Manuel's AutoEncoderPage with some changes to 
 * button configurations, plus a couple of new methods to learn and clear CCs
 * for specific encoders
 *
 **/

class AutoCCEncoderPage : public EncoderPage, public ClockCallback {
 public:
  MNMEncoder realEncoders[4];
  const static int RECORDING_LENGTH = 32; // recording length in 32th
  RecordingEncoder<RECORDING_LENGTH> recEncoders[4];

  bool muted;
  void on16Callback(uint32_t counter);
  void startRecording();
  void stopRecording();
  void clearRecording();
  void clearRecording(uint8_t i);
  virtual void setup();

  void clearEncoder(uint8_t i);
  void learnEncoder(uint8_t i);
  void autoLearnLast4();

  virtual bool handleEvent(gui_event_t *event);
};



void AutoCCEncoderPage::setup() {

  muted = false;
  for (uint8_t i = 0; i < 4; i++) {
    realEncoders[i].setName("___");
    recEncoders[i].initRecordingEncoder(&realEncoders[i]);
    encoders[i] = &recEncoders[i];
    ccHandler.addEncoder(&realEncoders[i]);
  }
  MidiClock.addOn16Callback(this, (midi_clock_callback_ptr_t)&AutoCCEncoderPage::on16Callback);
  EncoderPage::setup();
}


void AutoCCEncoderPage::on16Callback(uint32_t counter) {
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


void AutoCCEncoderPage::startRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].startRecording();
  }
}


void AutoCCEncoderPage::stopRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].stopRecording();
  }
}


void AutoCCEncoderPage::clearRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].clearRecording();
  }
}


void AutoCCEncoderPage::clearRecording(uint8_t i) {
  recEncoders[i].clearRecording();
}



void AutoCCEncoderPage::clearEncoder(uint8_t i) {
	
        realEncoders[i].cc = 0;
      	realEncoders[i].channel = 0;
      	realEncoders[i].setName("___");
      	realEncoders[i].setValue(0);      
        GUI.redisplay();
      	ccHandler.incomingCCs.clear();
        recEncoders[i].clearRecording();
}

// assigns the last incoming cc in the cchandler buffer to the specified encoder

void AutoCCEncoderPage::learnEncoder(uint8_t i) {
	  
  incoming_cc_t cc;	
  uint8_t count = ccHandler.incomingCCs.size();	
  for (uint8_t j = 0; j < count; j++) {
  	  if (j == 0){
	    ccHandler.incomingCCs.getCopy(j, &cc);
	    realEncoders[i].initCCEncoder(cc.channel, cc.cc);
	    realEncoders[i].setValue(cc.value);	    
	  }
  }
}


void AutoCCEncoderPage::autoLearnLast4() {
  /* maps from received CC indexes to encoder indexes */
  int8_t ccAssigned[4] = { -1, -1, -1, -1 };
  /* maps from encoder indexes to last received CCs */
  int8_t encoderAssigned[4] = { -1, -1, -1, -1 };
  incoming_cc_t ccs[4];

  uint8_t count = ccHandler.incomingCCs.size();
  for (uint8_t i = 0; i < count; i++) {
    ccHandler.incomingCCs.getCopy(i, &ccs[i]);
    incoming_cc_t *cc = &ccs[i];
    for (uint8_t j = 0; j < 4; j++) {
      if ((realEncoders[j].getCC() == cc->cc) &&
          (realEncoders[j].getChannel() == cc->channel)) {
        ccAssigned[i] = j;
        encoderAssigned[j] = i;
        break;
      }
    }
  }

  for (uint8_t i = 0; i < count; i++) {
    incoming_cc_t *cc = &ccs[i];
    int8_t idx = ccAssigned[i];
    if(idx != -1) {
      /* this check is probably redundant XXX */
      if ((realEncoders[idx].getChannel() != cc->channel) ||
          (realEncoders[idx].getCC() != cc->cc)) {
        realEncoders[idx].initCCEncoder(cc->channel, cc->cc);
        realEncoders[idx].setValue(cc->value);
        clearRecording(idx);
      }
    } else {
      for (uint8_t j = 0; j < 4; j++) {
        if (encoderAssigned[j] == -1) {
          idx = ccAssigned[i] = j;
          encoderAssigned[j] = i;
          realEncoders[idx].initCCEncoder(cc->channel, cc->cc);
          realEncoders[idx].setValue(cc->value);
          clearRecording(idx);
          break;
        }
      }
    }
  }
}


bool AutoCCEncoderPage::handleEvent(gui_event_t *event) {
  /*
  *
  *  LEARN MODE FUNCTIONS - activated by pressing button 4 + something else...
  *
  */
  if (BUTTON_UP(Buttons.BUTTON2) && BUTTON_DOWN(Buttons.BUTTON4) ) {
    
      // Button 4 + encoder = assign last incoming CC to Encoder  
      for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
        if (EVENT_PRESSED(event, i)) {
            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill("LEARN CC:");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);      
      	    learnEncoder(i);
      	    return true;
        } 
      }
    
      // Button 4 + Button 2 = assign last 4 incoming CCs to Encoders  
      if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
        GUI.flash_strings_fill("LEARN", "LAST 4 CCs");
        autoLearnLast4();
        return true;
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
          GUI.flash_strings_fill("REC ON", "");
          startRecording();
          return true;
        }
        if (EVENT_RELEASED(event, Buttons.BUTTON2)) {
          GUI.flash_strings_fill("REC OFF", "");
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
            GUI.flash_string_fill("CLEAR CC:");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);
            clearEncoder(i);            
          }
        }
      }
  }
  return false;
}


