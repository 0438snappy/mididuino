#include <Platform.h>  //Midi-Ctrl 0018
//#include <WProgram.h>  //Midi-Ctrl 0017
#include <TETRA.h>
#include <TETRAEncoders.h>

#define TETRA_MIDI_CHANNEL (15 - 1) // Midi Channel 15
#define NUM_TETRA_EDITOR_PAGES 41
#define NRPN_AUTO_PAGES_CNT 3

int mod(int x, int m) {
    int r = x%m;
    return r<0 ? r+m : r;
}


typedef struct tetra_editor_page_t {
  const char* longname;
  uint8_t parameterNumbers[4];
};

/**
 *
 * GLOBAL VARIABLE TO HOLD THE CURRENTLY SELECTED TETRA EDITOR PAGE
 *
 **/
int pageIndex;
tetra_editor_page_t tetraEditorPages[NUM_TETRA_EDITOR_PAGES] = {
    { "OSC1 PARMS", { 0x00, 0x01, 0x02, 0x03 } },
    { "OSC2 PARMS", { 0x06, 0x07, 0x08, 0x09 } },
    { "OSC LVLS", { 0x05, 0x0B, 0x10, 0x11 } },
    { "OSC VOL", { 0x12, 0x13, 0x28, 0x29 } },
    { "OSC SYNC SLOP", { 0x04, 0x0A, 0x0C, 0x0E } },
    { "VCF ENV", { 0x1C, 0x1D, 0x1E, 0x1F } },
    { "VCF MOD", { 0x16, 0x17, 0x19, 0x1A } },
    { "OSC VCF OPTNS", { 0x18, 0x1B, 0x5D, 0x5F } },
    { "VCA ENV", { 0x24, 0x25, 0x26, 0x27 } },
    { "VCA MOD", { 0x20, 0x21, 0x22, 0x23 } },
    { "ENV3 ENV", { 0x42, 0x43, 0x44, 0x45 } },
    { "ENV3 MOD", { 0x3E, 0x3F, 0x41, 0x46 } },
    { "LFO1 PARMS", { 0x2A, 0x2B, 0x2C, 0x2D } },
    { "LFO2 PARMS", { 0x2F, 0x30, 0x31, 0x32 } },
    { "LFO3 PARMS", { 0x34, 0x35, 0x36, 0x37 } },
    { "LFO4 PARMS", { 0x39, 0x3A, 0x3B, 0x3C } },
    { "LFO KEY SYNC", { 0x2E, 0x33, 0x38, 0x3D } },
    { "MOD1 PARMS", { 0x47, 0x48, 0x49, 0xFF } },
    { "MOD2 PARMS", { 0x4A, 0x4B, 0x4C, 0xFF } },
    { "MOD3 PARMS", { 0x4D, 0x4E, 0x4F, 0xFF } },
    { "MOD4 PARMS", { 0x50, 0x51, 0x52, 0xFF } },
    { "CTRLRS 1", { 0x55, 0x56, 0x59, 0x5A } },
    { "CTRLRS 2", { 0x0F, 0x53, 0x54, 0xFF } },
    { "CLK & ARP", { 0x65, 0x66, 0x67, 0x68 } },
    { "SEQ DEST", { 0x6B, 0x6C, 0x6D, 0x6E } },
    { "SEQ1 1-4", { 0x78, 0x79, 0x7A, 0x7B } },
    { "SEQ1 5-8", { 0x7C, 0x7D, 0x7E, 0x7F } },
    { "SEQ1 9-12", { 0x80, 0x81, 0x82, 0x83 } },
    { "SEQ1 13-16", { 0x84, 0x85, 0x86, 0x87 } },
    { "SEQ2 1-4", { 0x88, 0x89, 0x8A, 0x8B } },
    { "SEQ2 5-8", { 0x8C, 0x8D, 0x8E, 0x8F } },
    { "SEQ2 9-12", { 0x90, 0x91, 0x92, 0x93 } },
    { "SEQ2 13-16", { 0x94, 0x95, 0x96, 0x97 } },
    { "SEQ3 1-4", { 0x98, 0x99, 0x9A, 0x9B } },
    { "SEQ3 5-8", { 0x9C, 0x9D, 0x9E, 0x9F } },
    { "SEQ3 9-12", { 0xA0, 0xA1, 0xA2, 0xA3 } },
    { "SEQ3 13-16", { 0xA4, 0xA5, 0xA6, 0xA7 } },
    { "SEQ4 1-4", { 0xA8, 0xA9, 0xAA, 0xAB } },
    { "SEQ4 5-8", { 0xAC, 0xAD, 0xAE, 0xAF } },
    { "SEQ4 9-12", { 0xB0, 0xB1, 0xB2, 0xB3 } },
    { "SEQ4 13-16", { 0xB4, 0xB5, 0xB6, 0xB7 } }
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
class TetraEditorPage : public EncoderPage, public TETRACallback {

  public:         
        TetraNRPNEncoder tetraEditorEncoders[4];
        bool sysexLoaded;
        
        TetraEditorPage()
        {
          encoders[0] = &tetraEditorEncoders[0]; 
          encoders[1] = &tetraEditorEncoders[1]; 
          encoders[2] = &tetraEditorEncoders[2]; 
          encoders[3] = &tetraEditorEncoders[3];
	}

        void setup(){    
          if (!isSetup){          
              setEditorPage(false);          
              isSetup = true;
              sysexLoaded = false;
              TETRASysexListener.setup();
              TETRASysexListener.addOnProgramEditBufferMessageCallback(this, (tetra_callback_ptr_t)&TetraEditorPage::onProgramEditBufferMessageCallback);              
          }
        }      
        
        void onProgramEditBufferMessageCallback(){
            TETRA.loadedProgram = false;          
            if (TETRA.program.fromSysex(MidiSysex.data + 3, MidiSysex.recordLen - 3)) {
                GUI.flash_strings_fill("LOADED TETRA PGM", TETRA.program.name);
                TETRA.loadedProgram = true;
                setEditorPage(false);
            }                                    
        }
        
        void setEditorPage(bool verbose = true){ 
                      
            if (verbose){
              GUI.setLine(GUI.LINE1);
              GUI.flash_string_fill(tetraEditorPages[pageIndex].longname);
            }
                        
            for (int i=0; i<4; i++){
              uint8_t idx;
              idx = tetraEditorPages[pageIndex].parameterNumbers[i];
              if (idx != 0xFF){
                  tetraEditorEncoders[i].initTETRAEncoder(idx);
              } else {
                  tetraEditorEncoders[i].init();
              }
            }                        
            redisplayPage ();           
        }

	bool handleEvent(gui_event_t *event) {
  
  
//            // Pressing button 1 (top left) displays "shortcuts" to osc, vcf, env pages.  
//            if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
//                GUI.setLine(GUI.LINE1);
//                GUI.put_string_fill("SELECT PAGE:");
//                GUI.setLine(GUI.LINE2);
//                GUI.put_string_fill("VC1 VC2 VCF ENV");
//            } else if (EVENT_RELEASED(event, Buttons.BUTTON1)) {
//                redisplayPage (); 
//            }
//            
//            if (BUTTON_DOWN(Buttons.BUTTON1)) {
//                for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER4; i++){
//                    if (EVENT_PRESSED(event, i)) {
//                        uint8_t shortcutPageIndex[4] = {0,1,5,8};
//                        pageIndex = shortcutPageIndex[i];
//                        setEditorPage();
//                        return true;
//                    }
//                }                                   
//            } 
            
            // Holding button 2 then pressing (well actually releasing) button 3 will request sysex dump of Program Edit Buffer from the Tetra
            if (BUTTON_DOWN(Buttons.BUTTON2)) {    
                if (EVENT_RELEASED(event, Buttons.BUTTON3)) {
                    TETRA.requestProgramEditBuffer();       
                }
            }    
  
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
            
            // Pressing Button 4 (top right) + encoder "selects" the encoder to be assigned to Tetra Assignable Param
            if (BUTTON_DOWN(Buttons.BUTTON4)) {
                for (int i = Buttons.ENCODER1; i<=  Buttons.ENCODER4; i++){
                    if (EVENT_PRESSED(event, i)) {
                      
                        // set param & channel (if one exists for the encoder that was pressed - some pages only have 3 encs)                        
                        if (tetraEditorEncoders[i].paramNumber != 0xFF){
                            tetraParameterAssignPage.paramNumber = tetraEditorEncoders[i].paramNumber;
                            tetraParameterAssignPage.channel = tetraEditorEncoders[i].channel;
                            
                            // push page
                            GUI.pushPage(&tetraParameterAssignPage);
                        } else {
                            GUI.flash_strings_fill("CAN'T ASSIGN", "NULL PARAM");
                        }
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



