#include <MD.h>
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
  MDEncoder realEncoders[4];
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
  virtual void loop();

  void learnEncoder(uint8_t i);
  void autoLearnLast4();
  void displayRecLengthEncoders();
  void displayRecLengthEncoders(bool _display);

  virtual bool handleEvent(gui_event_t *event);
};


void AutoCCEncoderPage::setup() {

  muted = false;
  guiInRecordMode = true;
  recLengthEncodersDisplayed = false;
  for (uint8_t i = 0; i < 4; i++) {
    realEncoders[i].setName("___");
    recEncoders[i].initRecordingEncoder(&realEncoders[i]);
    encoders[i] = &recEncoders[i];
    ccHandler.addEncoder(&realEncoders[i]);
    recLengthEncoders[i].initRangeEncoder(RECORDING_LENGTH, 2, "LEN", RECORDING_LENGTH);
  }  
  MidiClock.addOn32Callback(this, (midi_clock_callback_ptr_t)&AutoCCEncoderPage::on32Callback);
  EncoderPage::setup();
}

/*
 * Using the page loop() method to look for changes to the recordingLengthEncoders
 */
void AutoCCEncoderPage::loop() {
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
void AutoCCEncoderPage::displayRecLengthEncoders() {

  recLengthEncodersDisplayed = !recLengthEncodersDisplayed;
  displayRecLengthEncoders(recLengthEncodersDisplayed);

}

void AutoCCEncoderPage::displayRecLengthEncoders(bool _display) {
  
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

void AutoCCEncoderPage::on32Callback(uint32_t counter) {
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



/*
*
*  The autoencoder page has two "modes" of operation:  
*  1)  Record mode: gui is used to learn / assign incoming CC's to the encoders, record encoder movements
*  2)  Playback mode: gui is used to start / stop / modify recording playback options
*
*/
bool AutoCCEncoderPage::handleEvent(gui_event_t *event) {

  
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
      *  LEARN MODE FUNCTIONS - activated by pressing button 4 + something else...
      *
      */
      if (BUTTON_UP(Buttons.BUTTON2) && EVENT_PRESSED(event, Buttons.BUTTON4)) {
          GUI.flash_strings_fill("CLICK AN ENCODER", "TO LEARN CC");        
      }
      
      if (BUTTON_UP(Buttons.BUTTON2) && BUTTON_DOWN(Buttons.BUTTON4) ) {
        
          // Button 4 + encoder = assign last incoming CC to Encoder  
          for (uint8_t i = Buttons.ENCODER1; i <= Buttons.ENCODER4; i++) {
            if (EVENT_PRESSED(event, i)) {
                GUI.setLine(GUI.LINE1);
                GUI.flash_string_fill("LEARNED ENC:");
                GUI.setLine(GUI.LINE2);
                GUI.flash_put_value(0, i + 1);      
        	learnEncoder(i);
        	return true;
            } 
          }
        
          // Button 4 + Button 3 = assign last 4 incoming CCs to Encoders  
          if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
            GUI.flash_strings_fill("AUTO LEARNED", "LAST 4 CCs");
            autoLearnLast4();
            return true;
          }          
      }
      
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


