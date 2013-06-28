#include <Platform.h>  //Midi-Ctrl 0018
//#include <WProgram.h>  //Midi-Ctrl 0017
#include <TETRA.h>
#include <TETRAEncoders.h>

#define NRPN_AUTO_PAGES_CNT 3



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
              GUI.flash_string_fill(TETRAEditor.currentPage->longname);
            }
                        
            for (int i=0; i<4; i++){
              uint8_t idx;
              idx = TETRAEditor.currentPage->parameterNumbers[i];
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
//                        TETRAEditor.setPage(shortcutPageIndex[i]);
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
                TETRAEditor.setPageDown();
                setEditorPage ();
                return true;
            }  
            
            // Pressing Button 3 (bottom right) displays "next" editor page
            if (EVENT_PRESSED(event, Buttons.BUTTON3)) {
                TETRAEditor.setPageUp();
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
TetraEditorPage tetraEditorPage; 



