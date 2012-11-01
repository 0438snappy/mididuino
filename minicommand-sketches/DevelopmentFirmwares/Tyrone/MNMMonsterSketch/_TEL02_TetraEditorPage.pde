int mod(int x, int m) {
    int r = x%m;
    return r<0 ? r+m : r;
}


typedef struct tetra_editor_page_t {
  //const char* shortname;
  const char* longname;
  TetraNRPNEncoder *encoders[4];
};

tetra_editor_page_t tetraEditorPageEncoders[NUM_TETRA_EDITOR_PAGES] = {
  {"OSC1 PARMS", {&tetraOsc1FreqEncoder, &tetraOsc1TuneEncoder, &tetraOsc1ShapeEncoder, &tetraOsc1GlideEncoder}}, 
  {"OSC2 PARMS", {&tetraOsc2FreqEncoder, &tetraOsc2TuneEncoder, &tetraOsc2ShapeEncoder, &tetraOsc2GlideEncoder}}, 
  {"OSC LVLS", {&tetraOscMixEncoder, &tetraNoiseLvlEncoder, &tetraSubOsc1LevelEncoder, &tetraSubOsc2LevelEncoder}}, 
  {"OSC VOL", {&tetraOutputSpreadEncoder, &tetraVoiceVolumeEncoder, &tetraFeedbackGainEncoder, &tetraFeedbackVolEncoder}}, 
  {"OSC SYNC SLOP", {&tetraOsc1KeyboardEncoder, &tetraOsc2KeyboardEncoder, &tetraSyncEncoder, &tetraOscSlopEncoder}}, 
  {"VCF ENV", {&tetraVcfEnvAttackEncoder, &tetraVcfEnvDecayEncoder, &tetraVcfEnvSustainEncoder, &tetraVcfEnvReleaseEncoder}}, 
  {"VCF MOD", {&tetraVcfKeyboardAmtEncoder, &tetraVcfAudioModEncoder, &tetraVcfEnvAmtEncoder, &tetraVcfVelAmtEncoder}}, 
  {"OSC VCF OPTNS", {&tetraVcfPolesEncoder, &tetraVcfEnvDelayEncoder, &tetraUnisonModeEncoder, &tetraUnisonOnOffEncoder}}, 
  {"VCA ENV", {&tetraVcaEnvAttackEncoder, &tetraVcaEnvDecayEncoder, &tetraVcaEnvSustainEncoder, &tetraVcaEnvReleaseEncoder}}, 
  {"VCA MOD", {&tetraVcaLevelEncoder, &tetraVcaEnvAmtEncoder, &tetraVcaVelAmtEncoder, &tetraVcaEnvDelayEncoder}}, 
  {"ENV3 ENV", {&tetraEnv3AttackEncoder, &tetraEnv3DecayEncoder, &tetraEnv3SustainEncoder, &tetraEnv3ReleaseEncoder}}, 
  {"ENV3 MOD", {&tetraEnv3DestinationEncoder, &tetraEnv3AmtEncoder, &tetraEnv3DelayEncoder, &tetraEnv3RepeatModeEncoder}}, 
  {"LFO1 PARMS", {&tetraLfo1FreqEncoder, &tetraLfo1ShapeEncoder, &tetraLfo1AmtEncoder, &tetraLfo1DestinationEncoder}}, 
  {"LFO2 PARMS", {&tetraLfo2FreqEncoder, &tetraLfo2ShapeEncoder, &tetraLfo2AmtEncoder, &tetraLfo2DestinationEncoder}}, 
//  {"LFO3 PARMS", {&tetraLfo3FreqEncoder, &tetraLfo3ShapeEncoder, &tetraLfo3AmtEncoder, &tetraLfo3DestinationEncoder}}, 
//  {"LFO4 PARMS", {&tetraLfo4FreqEncoder, &tetraLfo4ShapeEncoder, &tetraLfo4AmtEncoder, &tetraLfo4DestinationEncoder}}, 
//  {"LFO KEY SYNC", {&tetraLfo1KeySyncEncoder, &tetraLfo2KeySyncEncoder, &tetraLfo3KeySyncEncoder, &tetraLfo4KeySyncEncoder}}, 
  {"LFO KEY SYNC", {&tetraLfo1KeySyncEncoder, &tetraLfo2KeySyncEncoder, NULL, NULL}},   
  {"MOD1 PARMS", {&tetraMod1SourceEncoder, &tetraMod1AmtEncoder, &tetraMod1DestinationEncoder, NULL}} 
//  {"MOD2 PARMS", {&tetraMod2SourceEncoder, &tetraMod2AmtEncoder, &tetraMod2DestinationEncoder, NULL}} 
//  {"P20", "MOD3 PARAMS", {&tetraMod3SourceEncoder, &tetraMod3AmtEncoder, &tetraMod3DestinationEncoder, NULL}}, 
//  {"P21", "MOD4 PARAMS", {&tetraMod4SourceEncoder, &tetraMod4AmtEncoder, &tetraMod4DestinationEncoder, NULL}}
//  {"P22", "CONTROLLERS 1", {&tetraPressureAmtEncoder, &tetraPressureDestEncoder, &tetraVelocityAmtEncoder, &tetraVelocityDestEncoder}}, 
//  {"P23", "CONTROLLERS 2", {&tetraModWheelAmtEncoder, &tetraModWheelDestEncoder, &tetraPitchBendRangeEncoder, NULL}}, 
//  {"P24", "CLOCK & ARP", {&tetraBpmTempoEncoder, &tetraClockDivideEncoder, &tetraArpeggiatorModeEncoder, &tetraArpeggiatorOIEncoder}} 
//  {"P25", "SEQ DESTINATIONS", {&tetraSeq1DestinationEncoder, &tetraSeq2DestinationEncoder, &tetraSeq3DestinationEncoder, &tetraSeq4DestinationEncoder}}, 
//  {"P26", "SEQ1 STEP 1-4", {&tetraSeqTrk1Step1Encoder, &tetraSeqTrk1Step2Encoder, &tetraSeqTrk1Step3Encoder, &tetraSeqTrk1Step4Encoder}}, 
//  {"P27", "SEQ1 STEP 5-8", {&tetraSeqTrk1Step5Encoder, &tetraSeqTrk1Step6Encoder, &tetraSeqTrk1Step7Encoder, &tetraSeqTrk1Step8Encoder}}, 
//  {"P28", "SEQ1 STEP 9-12", {&tetraSeqTrk1Step9Encoder, &tetraSeqTrk1Step10Encoder, &tetraSeqTrk1Step11Encoder, &tetraSeqTrk1Step12Encoder}}, 
//  {"P29", "SEQ1 STEP 13-16", {&tetraSeqTrk1Step13Encoder, &tetraSeqTrk1Step14Encoder, &tetraSeqTrk1Step15Encoder, &tetraSeqTrk1Step16Encoder}}, 
//  {"P30", "SEQ2 STEP 1-4", {&tetraSeqTrk2Step1Encoder, &tetraSeqTrk2Step2Encoder, &tetraSeqTrk2Step3Encoder, &tetraSeqTrk2Step4Encoder}}, 
//  {"P31", "SEQ2 STEP 5-8", {&tetraSeqTrk2Step5Encoder, &tetraSeqTrk2Step6Encoder, &tetraSeqTrk2Step7Encoder, &tetraSeqTrk2Step8Encoder}}, 
//  {"P32", "SEQ2 STEP 9-12", {&tetraSeqTrk2Step9Encoder, &tetraSeqTrk2Step10Encoder, &tetraSeqTrk2Step11Encoder, &tetraSeqTrk2Step12Encoder}}, 
//  {"P33", "SEQ2 STEP 13-16", {&tetraSeqTrk2Step13Encoder, &tetraSeqTrk2Step14Encoder, &tetraSeqTrk2Step15Encoder, &tetraSeqTrk2Step16Encoder}}, 
//  {"P34", "SEQ3 STEP 1-4", {&tetraSeqTrk3Step1Encoder, &tetraSeqTrk3Step2Encoder, &tetraSeqTrk3Step3Encoder, &tetraSeqTrk3Step4Encoder}}, 
//  {"P35", "SEQ3 STEP 5-8", {&tetraSeqTrk3Step5Encoder, &tetraSeqTrk3Step6Encoder, &tetraSeqTrk3Step7Encoder, &tetraSeqTrk3Step8Encoder}}, 
//  {"P36", "SEQ3 STEP 9-12", {&tetraSeqTrk3Step9Encoder, &tetraSeqTrk3Step10Encoder, &tetraSeqTrk3Step11Encoder, &tetraSeqTrk3Step12Encoder}}, 
//  {"P37", "SEQ3 STEP 13-16", {&tetraSeqTrk3Step13Encoder, &tetraSeqTrk3Step14Encoder, &tetraSeqTrk3Step15Encoder, &tetraSeqTrk3Step16Encoder}}, 
//  {"P38", "SEQ4 STEP 1-4", {&tetraSeqTrk4Step1Encoder, &tetraSeqTrk4Step2Encoder, &tetraSeqTrk4Step3Encoder, &tetraSeqTrk4Step4Encoder}}, 
//  {"P39", "SEQ4 STEP 5-8", {&tetraSeqTrk4Step5Encoder, &tetraSeqTrk4Step6Encoder, &tetraSeqTrk4Step7Encoder, &tetraSeqTrk4Step8Encoder}}, 
//  {"P40", "SEQ4 STEP 9-12", {&tetraSeqTrk4Step9Encoder, &tetraSeqTrk4Step10Encoder, &tetraSeqTrk4Step11Encoder, &tetraSeqTrk4Step12Encoder}}, 
//  {"P41", "SEQ4 STEP 13-16", {&tetraSeqTrk4Step13Encoder, &tetraSeqTrk4Step14Encoder, &tetraSeqTrk4Step15Encoder, &tetraSeqTrk4Step16Encoder}} 
};


/**
 * Creates a page displaying some static text and 4 encoder options, designed to be used as a modal GUI.  
 *
 * Before this page can be used, the caller page must set the Tetra paramNumber and midi channel.
 *
 * The user has the option to either:
 *     -  click an encoder, which will send a NRPN message to assign the paramNumber to the corresponding AssignableParameter pot on the Tetra
 *     -  click any button, which will "cancel" the operation and return display to the calling page.
 *
 **/
class TetraParameterAssignPage : public EncoderPage {

  public: 
        uint16_t paramNumber;
        uint8_t channel;
    
        TetraParameterAssignPage()
        {
	}


        void setup(){   
          if (!isSetup){ 
              paramNumber = 0;    
              channel = 127;
              isSetup = true;
          }
        }      
        
        void display() {
            GUI.setLine(GUI.LINE1); 
            GUI.put_string_fill("ASSIGN -> TETRA ");
            GUI.setLine(GUI.LINE2); 
            GUI.put_string_fill("  1   2   3   4 ");            
        }
        
	bool handleEvent(gui_event_t *event) {
   
            // Pressing an encoder will assign the param to the tetra
            for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER4; i++){
                if (EVENT_PRESSED(event, i)) {
                    uint8_t nrpn = 105 + i;
                    MidiUart.sendNRPN(channel, nrpn, paramNumber);
                    GUI.setLine(GUI.LINE1);
                    GUI.flash_string_fill("ASSIGNED TO", 1000);
                    GUI.setLine(GUI.LINE2);
                    GUI.flash_printf_fill("TETRA ENC: %b", i);
                    GUI.popPage(this);
                }
            }
            
            // Pressing any Button will "Cancel" the assign and pop back to the TetraEditor Page
            for (int i = Buttons.BUTTON1; i<=  Buttons.BUTTON4; i++){
                if (EVENT_PRESSED(event, i)) {
                    GUI.flash_strings_fill("ASSIGN PARAM", "CANCELLED");
                    GUI.popPage(this);
                    return true;
                }
            }                               
            
            return false;

	}

};
TetraParameterAssignPage tetraParameterAssignPage;





/**
 *
 * Creates a page displaying 4 NRPN encoders, designed to be used as the main page for the Tetra Editor
 *
 * GUI/Button configuration:
 *     -  Pressing Button 2 (bottom left) displays "previous" editor page
 *     -  Pressing Button 3 (bottom right) displays "next" editor page
 *     -  Pressing Button 4 (top right) + encoder "selects" the encoder to be assigned to Tetra Assignable Param, and displays the TetraParameterAssignPage
 *
 **/
class TetraEditorPage : public EncoderPage {

  public:         

        /**
         *
         * VARIABLE TO HOLD THE CURRENTLY SELECTED TETRA EDITOR PAGE
         *
         **/
        int pageIndex;
    
        TetraEditorPage()
        {
	}

        void setup(){    
          if (!isSetup){ 
              pageIndex = 0;         
              setEditorPage (&tetraEditorPageEncoders[pageIndex]);          
              isSetup = true;
          }
        }      
        
        void setEditorPage(tetra_editor_page_t *page){ 
            GUI.setLine(GUI.LINE1);
            GUI.flash_string_fill(page->longname);
            encoders[0] = page->encoders[0];
            encoders[1] = page->encoders[1];
            encoders[2] = page->encoders[2];
            encoders[3] = page->encoders[3];
            redisplayPage ();           
        }

	bool handleEvent(gui_event_t *event) {
   
            // Pressing Button 2 (bottom left) displays "previous" editor page
            if (EVENT_PRESSED(event, Buttons.BUTTON2)) {
                pageIndex = mod(pageIndex-1, NUM_TETRA_EDITOR_PAGES);
                setEditorPage (&tetraEditorPageEncoders[pageIndex]);
                return true;
            }  
            
            // Pressing Button 3 (bottom right) displays "next" editor page
            if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
                pageIndex = mod(pageIndex + 1, NUM_TETRA_EDITOR_PAGES);
                setEditorPage (&tetraEditorPageEncoders[pageIndex]);
                return true;
            }  
            
            // Pressing Button 4 (top right) + encoder "selects" the encoder to be assigned to Tetra Assignable Param
            if (BUTTON_DOWN(Buttons.BUTTON4)) {
                for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER4; i++){
                    if (EVENT_PRESSED(event, i)) {
                      
                        // set param & channel
                        tetraParameterAssignPage.paramNumber = tetraEditorPageEncoders[pageIndex].encoders[i]->paramNumber;
                        tetraParameterAssignPage.channel = tetraEditorPageEncoders[pageIndex].encoders[i]->channel;
                        
                        // push page
                        GUI.pushPage(&tetraParameterAssignPage);
                        return true;
                    }
                }                              
                GUI.flash_strings_fill("CHOOSE PARAM", "TO ASSIGN");                
            }  
            
            // Pressing an Encoder will flash the long name (and enum value if exists)
            for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER4; i++){
                if (EVENT_PRESSED(event, i)) {  
                    // call DisplayAt to flash long strings
                    encoders[i]->isPressed = true;
                    encoders[i]->displayAt(i);
                } else if (EVENT_RELEASED(event, i)) {
                    encoders[i]->isPressed = false;
                }
            }
            
            return false;

	}

};






