#define ADD_MODE_DELAY_TIME_INCREMENT_STEPS 10
#define ADD_MODE_EQ_INCREMENT_STEPS 4


#define OT_TRACK_1_MIDI_CHANNEL (1 - 1)  // OT Track / Midi Channel 1
#define OT_TRACK_2_MIDI_CHANNEL (2 - 1)  // OT Track / Midi Channel 2 
#define OT_TRACK_3_MIDI_CHANNEL (3 - 1)  // OT Track / Midi Channel 3 
#define OT_TRACK_4_MIDI_CHANNEL (4 - 1)  // OT Track / Midi Channel 4
#define OT_TRACK_5_MIDI_CHANNEL (5 - 1)  // OT Track / Midi Channel 5
#define OT_TRACK_6_MIDI_CHANNEL (6 - 1)  // OT Track / Midi Channel 6 
#define OT_TRACK_7_MIDI_CHANNEL (7 - 1)  // OT Track / Midi Channel 7 
#define OT_TRACK_8_MIDI_CHANNEL (8 - 1)  // OT Track / Midi Channel 8

#define OT_PLAYBACK_PARAM1 16
#define OT_PLAYBACK_PARAM2 17
#define OT_PLAYBACK_PARAM3 18
#define OT_PLAYBACK_PARAM4 19
#define OT_PLAYBACK_PARAM5 20
#define OT_PLAYBACK_PARAM6 21

#define OT_FX1_PARAM1 34
#define OT_FX1_PARAM2 35
#define OT_FX1_PARAM3 36
#define OT_FX1_PARAM4 37
#define OT_FX1_PARAM5 38
#define OT_FX1_PARAM6 39

#define OT_FX2_PARAM1 40
#define OT_FX2_PARAM2 41
#define OT_FX2_PARAM3 42
#define OT_FX2_PARAM4 43
#define OT_FX2_PARAM5 44
#define OT_FX2_PARAM6 45

#define DELAY_TIMES_COUNT 5

const char *delayTimeNames[DELAY_TIMES_COUNT] = {
    "/2 ",
    "/4 ",
    "/8 ",
    "/16",
    "/32"   
  };

const uint8_t delayTimeValues[DELAY_TIMES_COUNT] = {
    128 -1,
    64 - 1,
    32 - 1,
    16 - 1,
    8 - 1
};  

const char *delayTimeTripletNames[DELAY_TIMES_COUNT] = {
    "/3 ",
    "/6 ",
    "/12",
    "/24",
    "/48"   
  };

const uint8_t delayTimeTripletValues[DELAY_TIMES_COUNT] = {
    96 - 1,
    48 - 1,
    24 - 1,
    12 - 1,
    6 - 1
};  

class OTCutAddEncoder : public CCEncoder {
	
public:

  bool addMode, killMode, tripletsMode;
  uint8_t feedbackBase, feedbackWidth;

  OTCutAddEncoder(uint8_t _track = 0, uint8_t _param = 0, char *_name = NULL, uint8_t init = 0)
  {
    cc = _param;
    channel = _track;      
    min = 0;
    max = 127;
    handler = OTCutAddHandle;
    feedbackWidth = 42;
    addMode = false;
    killMode = false;
  }
  
  void displayAt(int i) {
    char *string;
    int val = getValue();
    if (val > 64){
       uint8_t delayTimeIdx = MIN((getValue() - 64) / ADD_MODE_DELAY_TIME_INCREMENT_STEPS, (DELAY_TIMES_COUNT - 1));
       if(tripletsMode){
           GUI.put_string_at(i * 4, delayTimeTripletNames[delayTimeIdx]);
       } else {
           GUI.put_string_at(i * 4, delayTimeNames[delayTimeIdx]);
       }
    } else {
        val -= 64;
        GUI.put_value_at(i * 4, val);
    }    
    redisplay = false;
  }  

};


void OTCutAddHandle(Encoder *enc) {
  OTCutAddEncoder *otCutAddEnc = (OTCutAddEncoder *)enc;
  
  uint8_t eqValue = otCutAddEnc->getValue();
  uint8_t channel = otCutAddEnc->channel;
  uint8_t eqParam = otCutAddEnc->cc;
  otCutAddEnc->addMode=false;
  
  // only increment 1 step in every 4 for values > 63.  also set addMode to true for values > 63.
  if (eqValue > 63){
    eqValue = 63 + ((eqValue - 63)/ ADD_MODE_EQ_INCREMENT_STEPS);
    otCutAddEnc->addMode=true;
  }  
  MidiUart.sendCC(channel, eqParam, eqValue);

}


class OTCutAddPage : public EncoderPage, public ClockCallback  {

  public: 
	OTCutAddEncoder otCutAddEncoders[3]; 
        CCEncoder otDelayFeedbackEncoder;
        uint8_t eqSettings[3];
        uint8_t otTrack;
        bool delayTripletsMode, restorePlayback, supaTriggaActive;
   
        OTCutAddPage()        
        {
	    encoders[0] = &otCutAddEncoders[0];
	    encoders[1] = &otCutAddEncoders[1];
	    encoders[2] = &otCutAddEncoders[2];
	    encoders[3] = &otDelayFeedbackEncoder;
	}

	virtual void loop() {
	
	    for (int i=0;i<3;i++){
                if (otCutAddEncoders[i].hasChanged()){
                    addDelay();   
                }
            }
	
	    }

        void setup(uint8_t track){
            otTrack = track;
            setup();
        }
        
        void setup(){         
            otCutAddEncoders[0].initCCEncoder(otTrack, OT_FX1_PARAM4); 
            otCutAddEncoders[0].setName("LOW");
            otCutAddEncoders[0].setValue(64);
            otCutAddEncoders[0].feedbackBase = 0;
            otCutAddEncoders[1].initCCEncoder(otTrack, OT_FX1_PARAM5);  
            otCutAddEncoders[1].setName("MID");
            otCutAddEncoders[1].setValue(64);   
            otCutAddEncoders[1].feedbackBase = 43;      
            otCutAddEncoders[2].initCCEncoder(otTrack, OT_FX1_PARAM6);  
            otCutAddEncoders[2].setName("HI");
            otCutAddEncoders[2].setValue(64);   
            otCutAddEncoders[2].feedbackBase = 85;                               
            otDelayFeedbackEncoder.initCCEncoder(otTrack, OT_FX2_PARAM2);
            otDelayFeedbackEncoder.setName("FBK");
            otDelayFeedbackEncoder.setValue(63, true);     
            restorePlayback = supaTriggaActive = false;

            // set Delay Volume to 0            
            MidiUart.sendCC(OT_TRACK_5_MIDI_CHANNEL, OT_FX2_PARAM3, 0);                 
            for (int i=0;i<3;i++){
                eqSettings[i]=otCutAddEncoders[i].getValue();
            }
            delayTripletsMode = false;
            MidiClock.addOn16Callback(this, (midi_clock_callback_ptr_t)&OTCutAddPage::on16Callback);
            isSetup = true;
        }      
      
        void toggleEqKill(OTCutAddEncoder *encoder, uint8_t& value){
            uint8_t channel = encoder->getChannel();
            uint8_t cc = encoder->getCC();
            encoder->killMode = !encoder->killMode;

            if(encoder->killMode){
                value = encoder->getValue();  
                encoder->setValue(0, true); 
                encoder->name[3] = '*';      
            } else {
                encoder->setValue(value, true);
                encoder->name[3] = ' ';      
            }           
            redisplayPage ();
        }  
        
        void centreEq(OTCutAddEncoder *encoder){
            encoder->killMode = false;
            encoder->addMode = false;
            encoder->setValue(64, true);  
            encoder->name[3] = ' ';        
            redisplayPage ();            
        }
        
        void addDelay(){
            if (otCutAddEncoders[0].addMode || otCutAddEncoders[1].addMode || otCutAddEncoders[2].addMode){
                uint8_t feedbackBase = 127;
                uint8_t feedbackWidth = 0;
                uint8_t delayVol = 0;
                uint8_t delayTime = 127;
                uint8_t delayTimeIdx = 0;
                uint8_t valIncrement = 0;
                uint8_t counter = 0;
                
                for (int i=0;i<3;i++){
                    if (otCutAddEncoders[i].addMode){
                        counter+=1;
                        feedbackBase = MIN(feedbackBase, otCutAddEncoders[i].feedbackBase);
                        feedbackWidth = (counter * otCutAddEncoders[i].feedbackWidth);
                        
                        // delay volume increases with each successive enc in addMode
                        delayVol = 58 + (counter * 23);
                        
                        // only increment 1 "step" of delay time for every 10 steps of the encoder.  take the smallest delay time from all encs in addMode.
                        delayTimeIdx = MIN((otCutAddEncoders[i].getValue() - 63) / ADD_MODE_DELAY_TIME_INCREMENT_STEPS, (DELAY_TIMES_COUNT - 1));
                        if (delayTripletsMode){
                            delayTime = MIN(delayTime, delayTimeTripletValues[delayTimeIdx]);
                        } else {
                            delayTime = MIN(delayTime, delayTimeValues[delayTimeIdx]);
                        }                             
                        redisplayPage ();
                    }
                }
                
                // Send Delay CCs
                MidiUart.sendCC(otTrack, OT_FX2_PARAM1, delayTime);         // Delay Time
//                    MidiUart.sendCC(otTrack, OT_FX2_PARAM2, delayTime);    // Feedback                    
                MidiUart.sendCC(otTrack, OT_FX2_PARAM3, delayVol);          // Delay vol
                MidiUart.sendCC(otTrack, OT_FX2_PARAM4, feedbackBase);      // Feedback Base
                MidiUart.sendCC(otTrack, OT_FX2_PARAM5, feedbackWidth);     // Feedback Width             
//                    MidiUart.sendCC(otTrack, OT_FX2_PARAM6, delayTime);    // Send 
            } else {
                MidiUart.sendCC(otTrack, OT_FX2_PARAM3, 0);  // Delay vol
            }
        }
        
        void sliceTrack32(uint8_t midiChannel, uint8_t from, uint8_t to, bool correct = true) {
            uint8_t pfrom, pto;
            if (from > to) {
                pfrom = MIN(127, from * 4 + 1);
                //pto = MIN(127, to * 4);
                pto = 0;
            } else {
                pfrom = MIN(127, from * 4);
                //pto = MIN(127, to * 4);
                pto = 127;
                if (correct && pfrom >= 64)
                  pfrom++;
            }
            MidiUart.sendCC(midiChannel, OT_PLAYBACK_PARAM2, pfrom);
            MidiUart.sendCC(midiChannel, OT_PLAYBACK_PARAM4, pto);
            MidiUart.sendNoteOn(midiChannel, MIDI_NOTE_C3, 127);
        }
        
        void doSupatrigga() {
            uint8_t val = (MidiClock.div16th_counter) % 32;
            if ((val % 4) == 0) {
                uint8_t from = 0, to = 0;
                if (random(100) > 50) {
                  from = random(0, 6);
                  to = random(from + 2, 8);
                } 
                else {
                  from = random(2, 8);
                  to = random(0, from - 2);
                }
                sliceTrack32(otTrack, from * 4, to * 4);
            }
        }
        
        void on16Callback() {

            if (restorePlayback) {
                uint8_t val = (MidiClock.div16th_counter) % 32;
                if ((val % 4) == 0) {
                  restorePlayback = false;
                  sliceTrack32(otTrack, val, 127, true);
                  return;
                }
            }
            if (supaTriggaActive) {
                doSupatrigga();
            }                    
        }
        
        void startSupatrigga() {
            supaTriggaActive = true;
        }
        
        void stopSupatrigga() {
            restorePlayback = true;
            supaTriggaActive = false;
        }

    
	    bool handleEvent(gui_event_t *event) {
   
            if (BUTTON_DOWN(Buttons.BUTTON2)) {
                // Press Button2 + Button 1 + Enc to "reset" EQ
                if (BUTTON_DOWN(Buttons.BUTTON1)) {
                  for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER3; i++){
                      if (EVENT_PRESSED(event, i)) {
                          centreEq(&otCutAddEncoders[i]);
                          return true;
                      }
                  }
                // Press Button2 + Button 3 to "reset" all EQs and delay 
                } else if(EVENT_PRESSED(event, Buttons.BUTTON3)){
                  for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER3; i++){
                      centreEq(&otCutAddEncoders[i]);                  
                      otDelayFeedbackEncoder.setValue(63, true);    
                      MidiUart.sendCC(otCutAddEncoders[i].channel, OT_FX2_PARAM3, 0);   // Delay vol                   
                  }
                  return true;
                } else {
                  // Press Button2 + Enc 1-3 to toggle EQ "kill"   
                  for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER3; i++){
                      if (EVENT_PRESSED(event, i)) {
                          toggleEqKill(&otCutAddEncoders[i], eqSettings[i]);
                          return true;
                      }
                  } 
                  // Press Button2 + Enc4 to toggle between triplets delay mode
                  if (EVENT_PRESSED(event, Buttons.ENCODER4)) {
                      delayTripletsMode = !delayTripletsMode;
                      for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER3; i++){
                          otCutAddEncoders[i].tripletsMode = delayTripletsMode;
                          otCutAddEncoders[i].displayAt(i);
                      } 
                      if (delayTripletsMode){
                          GUI.flash_strings_fill("DELAY TIMES:", "TRIPLETS ON");   
                      } else {
                          GUI.flash_strings_fill("DELAY TIMES:", "TRIPLETS OFF"); 
                      }
                      addDelay();
                      return true;
                  }
                }
            }
            
            // Bottom Right button
            if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
                startSupatrigga();
            } else if (EVENT_RELEASED(event, Buttons.BUTTON3)) {
                stopSupatrigga();
            }
            
            return false;

	}

};
