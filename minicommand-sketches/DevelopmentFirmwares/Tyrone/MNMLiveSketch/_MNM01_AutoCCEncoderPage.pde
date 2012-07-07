#include <MNM.h>
#include "Platform.h"
//#include "WProgram.h"
#include "GUI.h"
#include "CCHandler.h"


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
template <typename EncoderType> 
class AutoCCEncoderPage : public EncoderPage, public ClockCallback {
 public:
  EncoderType realEncoders[4];
  const static int RECORDING_LENGTH = 64; // recording length in 32th
  RecordingEncoder<RECORDING_LENGTH> recEncoders[4];

  bool muted;
  uint8_t button1, button2, button3, button4;
  void on32Callback(uint32_t counter);
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


template <typename EncoderType>
void AutoCCEncoderPage<EncoderType>::setup() {

  muted = false;
  button1 = Buttons.BUTTON1;
  button2 = Buttons.BUTTON2; 
  button3 = Buttons.BUTTON3;
  button4 = Buttons.BUTTON4;
  for (uint8_t i = 0; i < 4; i++) {
    realEncoders[i].setName("___");
    recEncoders[i].initRecordingEncoder(&realEncoders[i]);
    encoders[i] = &recEncoders[i];
    ccHandler.addEncoder(&realEncoders[i]);
  }
  MidiClock.addOn32Callback(this, (midi_clock_callback_ptr_t)&AutoCCEncoderPage<EncoderType>::on32Callback);
  EncoderPage::setup();
}

template <typename EncoderType>
void AutoCCEncoderPage<EncoderType>::on32Callback(uint32_t counter) {
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

template <typename EncoderType>
void AutoCCEncoderPage<EncoderType>::startRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].startRecording();
  }
}

template <typename EncoderType>
void AutoCCEncoderPage<EncoderType>::stopRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].stopRecording();
  }
}

template <typename EncoderType>
void AutoCCEncoderPage<EncoderType>::clearRecording() {
  for (uint8_t i = 0; i < 4; i++) {
    recEncoders[i].clearRecording();
  }
}

template <typename EncoderType>
void AutoCCEncoderPage<EncoderType>::clearRecording(uint8_t i) {
  recEncoders[i].clearRecording();
}


template <typename EncoderType>
void AutoCCEncoderPage<EncoderType>::clearEncoder(uint8_t i) {
	
        realEncoders[i].cc = 0;
      	realEncoders[i].channel = 0;
      	realEncoders[i].initMNMEncoder(0, 0, "___", 0);
      	ccHandler.incomingCCs.clear();
        recEncoders[i].clearRecording();
}

// assigns the last incoming cc in the cchandler buffer to the specified encoder
template <typename EncoderType>
void AutoCCEncoderPage<EncoderType>::learnEncoder(uint8_t i) {
	  
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

template <typename EncoderType>
void AutoCCEncoderPage<EncoderType>::autoLearnLast4() {
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

template <typename EncoderType>
bool AutoCCEncoderPage<EncoderType>::handleEvent(gui_event_t *event) {
  /*
  *
  *  LEARN MODE FUNCTIONS - activated by pressing button 4 + something else...
  *
  */
  if (BUTTON_UP(Buttons.BUTTON3) && BUTTON_DOWN(Buttons.BUTTON4) ) {
    
      // Button 4 + encoder = assign last incoming CC to Encoder  
      for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
        if (EVENT_PRESSED(event, i)) {
            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill("LEARN ENCODER CC");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);      
      	    learnEncoder(i);
      	    return true;
        } 
      }
    
      // Button 4 + Button 2 = assign last 4 incoming CCs to Encoders  
      if (EVENT_PRESSED(event, Buttons.BUTTON2)) {
        GUI.flash_strings_fill("AUTO LEARN", "LAST 4 CCs");
        autoLearnLast4();
        return true;
      }
  }
  
  /*
  *
  *  REC MODE - toggled on/off by pressing button 3 without any other buttons
  *
  */
  if (BUTTON_UP(Buttons.BUTTON2)) {
     if (BUTTON_UP(Buttons.BUTTON4)) {
        if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
          GUI.flash_strings_fill("RECORD MODE ON", "");
          startRecording();
          return true;
        }
        if (EVENT_RELEASED(event, Buttons.BUTTON3)) {
          GUI.flash_strings_fill("RECORD MODE OFF", "");
          stopRecording();
          return true;
        }
     }
  }
  
  /*
  *
  * CLEAR MODE FUNCTIONS - activated by pressing button 2 + something else...
  *
  */
  if (BUTTON_DOWN(Buttons.BUTTON2)) {
    
      // Pressing Button2 + Encoder = Clear Encoder Recording
      for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
        if (EVENT_PRESSED(event, i)) {
            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill("CLEAR RECORDING:");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);
            clearRecording(i);
        }
      }
        
      // Pressing Button2 + Button 3 + Encoder = Clear CC assigned to Encoder
      if (BUTTON_DOWN(Buttons.BUTTON3)) {
        for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
          if (EVENT_PRESSED(event, i)) {
            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill("CLEAR ENCODER CC");
            GUI.setLine(GUI.LINE2);
            GUI.flash_put_value(0, i + 1);
            clearEncoder(i);            
          }
        }
      }
  }
  return false;
}


