#include <Scales.h>
#include <MNM.h>

typedef struct mnm_voice_s {
  uint8_t note;
  bool active;
} mnm_voice_t;


class MNMMonoPolySketch : public Sketch, public MNMCallback, public MidiCallback  {

public:
    bool muted, sketchEnabled, parameterSyncEnabled, machineSyncEnabled;               
    EncoderPage page1, page2;
    SwitchPage switchPage;
    RangeEncoder polyStartTrackEncoder, polyEndTrackEncoder, parameterSpreadEncoder;
    BoolEncoder sketchEnabledEncoder, parameterSyncEnabledEncoder, machineSyncEnabledEncoder;
    uint8_t polyStartTrack, polyEndTrack, polyTotalNumberVoices, parameterSpread;    
    mnm_voice_t mnmVoicePool[6];    
    uint8_t lastUsedMnMVoice[6];
          
    void getName(char *n1, char *n2) {
        m_strncpy_p(n1, PSTR("MNO "), 5);
        m_strncpy_p(n2, PSTR("PLY "), 5);
      }   
   
    void setup() {
       muted = false;
       sketchEnabled = false;
       machineSyncEnabled = false;
       parameterSyncEnabled = true;       
       parameterSpread = 0;
       polyStartTrack = (1 - 1);  // track 1
       polyEndTrack = (4 -1);     // track 4
       setupPages();
       setMnmMachineForPolyTracks();
       MNMTask.addOnKitChangeCallback(this, (mnm_callback_ptr_t)&MNMMonoPolySketch::onKitChanged);       
       Midi2.addOnNoteOnCallback(this, (midi_callback_ptr_t)&MNMMonoPolySketch::onNoteOn);
       Midi2.addOnNoteOffCallback(this, (midi_callback_ptr_t)&MNMMonoPolySketch::onNoteOff);             
       Midi.addOnControlChangeCallback(this, (midi_callback_ptr_t)&MNMMonoPolySketch::onControlChange);  
       Midi2.addOnControlChangeCallback(this, (midi_callback_ptr_t)&MNMMonoPolySketch::onControlChange);  
       Midi2.addOnProgramChangeCallback(this, (midi_callback_ptr_t)&MNMMonoPolySketch::onProgramChange);

    }   

    void setupPages(){
       sketchEnabledEncoder.initBoolEncoder("O-|", sketchEnabled);
       polyStartTrackEncoder.initRangeEncoder(6, 1, "ST ", (polyStartTrack + 1));
       polyEndTrackEncoder.initRangeEncoder(6, 1, "END", (polyEndTrack + 1));
       machineSyncEnabledEncoder.initBoolEncoder("MSN", machineSyncEnabled);
       parameterSyncEnabledEncoder.initBoolEncoder("PSN", parameterSyncEnabled);
       parameterSpreadEncoder.initRangeEncoder(64, 0, "SPR", parameterSpread);
       page1.setEncoders(&sketchEnabledEncoder, &parameterSpreadEncoder, &parameterSyncEnabledEncoder, &machineSyncEnabledEncoder);
       page1.setShortName("PG1");
       page2.setEncoders(&sketchEnabledEncoder, &polyStartTrackEncoder, &polyEndTrackEncoder, NULL);
       page2.setShortName("PG2");      
       switchPage.initPages(&page1, &page2, NULL, NULL);    
       switchPage.parent = this;
    }
    
      void onProgramChange(uint8_t *msg) {

          // If we haven't already returned, then ccho the message out on the same midi channel
          MidiUart.sendMessage(msg[0], msg[1]);  
          
      }    
   
    virtual void show() {
        if (currentPage() == &switchPage){
            popPage(&switchPage);
        }      
        if (currentPage() == NULL){
            setPage(&page1);                        
        }
    }     
    
    virtual void hide() {
      if (currentPage() == &switchPage){
          popPage(&switchPage);
      }
    }        
     
      virtual void mute(bool pressed) {
        if (pressed) {
            muted = !muted;
            if (muted) {
                sketchEnabled = false;
                GUI.flash_strings_fill("MNM MONO/POLY:", "MUTED");
            } else {
                sketchEnabled = sketchEnabledEncoder.getValue();
                GUI.flash_strings_fill("MNM MONO/POLY:", "UNMUTED");
            }
        }
      }
      
      virtual void loop(){
          if (sketchEnabledEncoder.hasChanged()) {
                sketchEnabled = sketchEnabledEncoder.getValue();
                if (!sketchEnabled){
                    setAllPolyVoicesOff();
                }
	  }
          if (polyStartTrackEncoder.hasChanged()) {
            
                // make sure value is <= polyEndTrackEncoder
                polyStartTrack = MIN((polyStartTrackEncoder.getValue() - 1), polyEndTrack);
                polyStartTrackEncoder.setValue(polyStartTrack + 1, true);                                
                
                // all notes off...
                setAllPolyVoicesOff();
                
                // reload mnm kit
                MNM.revertToCurrentKit(false);                
                
                // copy mnm machine from start track to all other poly tracks
                setMnmMachineForPolyTracks();
                
                // calculate total number of poly tracks
                setPolyTotalNumberVoices ();
	  }
          if (polyEndTrackEncoder.hasChanged()) {
                // make sure value is >= polyEndTrackEncoder
                polyEndTrack = MAX((polyEndTrackEncoder.getValue() - 1), polyStartTrack);
                polyEndTrackEncoder.setValue(polyEndTrack + 1, true);

                // all notes off...
                setAllPolyVoicesOff();
                
                // reload mnm kit
                MNM.revertToCurrentKit(false);
                
                // copy mnm machine from start track to all other poly tracks
                setMnmMachineForPolyTracks();
                
                // calculate total number of poly tracks
                setPolyTotalNumberVoices ();
	  }
          if (parameterSyncEnabledEncoder.hasChanged()) {
                GUI.setLine(GUI.LINE1);
                GUI.flash_string_fill("PARAMETER SYNC");
                parameterSyncEnabled = parameterSyncEnabledEncoder.getValue();
	  }
          if (parameterSpreadEncoder.hasChanged()) {
                GUI.setLine(GUI.LINE1);
                GUI.flash_string_fill("PARAMETER SPREAD");
                parameterSpread = parameterSpreadEncoder.getValue();
	  }
          if (machineSyncEnabledEncoder.hasChanged()) {
                GUI.setLine(GUI.LINE1);
                GUI.flash_string_fill("MACHINE SYNC");
                machineSyncEnabled = machineSyncEnabledEncoder.getValue();
                setMnmMachineForPolyTracks();
	  }
      }
         
      void setPolyTotalNumberVoices (){
          polyTotalNumberVoices = polyEndTrack - polyStartTrack;
      }
      
      void setAllPolyVoicesOff(){
          for (uint8_t mnmTrack = polyStartTrack; mnmTrack <= polyEndTrack; mnmTrack++){
             setNoteOff(mnmTrack, 0);
          }
      }
            
      void setMnmMachineForPolyTracks(){
          if (machineSyncEnabled){
              for (uint8_t mnmTrack = polyStartTrack; mnmTrack <= polyEndTrack; mnmTrack++){
                 MNM.setMachine(mnmTrack, polyStartTrack);
              }
          }
      }
         
      void onNoteOn(uint8_t *msg) {       
        
          if (sketchEnabled){
        
              // FILTER FOR Poly Track MIDI CHANNELS
              uint8_t channel = MIDI_VOICE_CHANNEL(msg[0]);
              uint8_t note = msg[1];
              uint8_t velocity = msg[2];
              
              if (((channel >= polyStartTrack + MNM.global.baseChannel) && (channel <= polyEndTrack + MNM.global.baseChannel)) || ((channel == MNM.global.autotrackChannel) && ((MNM.currentTrack >= polyStartTrack) && (MNM.currentTrack <= polyEndTrack)))) {            
              
                  uint8_t voice = 0xff;                    
                
                  // Look for a voice currently playing this note 
                  for (uint8_t i = polyStartTrack; i <= polyEndTrack; ++i) {
                    if (mnmVoicePool[i].note == note) {
                      voice = i;
                      break;
                    }
                  }
                  
                  // If no voice currently playing this note, then look for a free voice 
                  if (voice == 0xff) {
                    for (uint8_t i = polyStartTrack; i <= polyEndTrack; ++i) {
                      if (!mnmVoicePool[i].active) {
                        voice = i; 
                        break;
                      }
                    }
                  }
                  
                  // If no free voices then find the oldest
                  if (voice == 0xff) {
                    for (uint8_t i = 0; i < polyTotalNumberVoices; ++i) {
                      if ((lastUsedMnMVoice[i] >= polyStartTrack) && (lastUsedMnMVoice[i] <= polyEndTrack)) {
                          voice = lastUsedMnMVoice[i];
                      }
                    }  
                  }
                  
                  // If by some miracle we still haven't found a voice then just use the polyStartTrack
                  if (voice == 0xff) {
                      voice = polyStartTrack;
                  }          
                  
                  // Forward message to the specified MnM Voice
                  MNM.sendNoteOn(voice, note, velocity);                        
        
                  // Add details of newest voice to mnmVoicePool & lastUsedMnMVoice
                  mnmVoicePool[voice].note = note;
                  mnmVoicePool[voice].active = true;
                  setLastUsedMnMVoice(voice);        
                  
                  return;
              }
          
          }
          
          // If we haven't already returned, then echo the message out on the same midi channel
          // MidiUart.sendMessage(msg[0], msg[1], msg[2]);      
          
      }      
      
      void onNoteOff(uint8_t *msg) {

          if (sketchEnabled){
        
              // FILTER FOR Poly Track MIDI CHANNELS
              uint8_t channel = MIDI_VOICE_CHANNEL(msg[0]);           
            
              if (((channel >= polyStartTrack + MNM.global.baseChannel) && (channel <= polyEndTrack + MNM.global.baseChannel)) || ((channel == MNM.global.autotrackChannel) && ((MNM.currentTrack >= polyStartTrack) && (MNM.currentTrack <= polyEndTrack)))) {            
        
                  uint8_t note = msg[1];
                  uint8_t velocity = msg[2];                   
                  uint8_t voice = 0xff;          
                
                  // Look for a voice currently playing this note 
                  for (uint8_t i = polyStartTrack; i <= polyEndTrack; ++i) {
                    if (mnmVoicePool[i].note == note) {
                      voice = i;
                      break;
                    }
                  }
                  
                  if (voice != 0xff) {          
                       setNoteOff(voice, velocity);          
                  }    
                  
                  return;
              } 
              
          } 
          
          // If we haven't already returned, then ccho the message out on the same midi channel
          // MidiUart.sendMessage(msg[0], msg[1], msg[2]);  
          
      }
      
      void setLastUsedMnMVoice(uint8_t _voice){
          int8_t source = polyTotalNumberVoices;
          int8_t destination = polyTotalNumberVoices;
          while (source >= 0) {
            if (lastUsedMnMVoice[source] != _voice) {
              lastUsedMnMVoice[destination--] = lastUsedMnMVoice[source];
            }
            --source;
          }
          lastUsedMnMVoice[0] = _voice;        
      }
      
      void setNoteOff(uint8_t _voice, uint8_t _velocity){
                
          // Forward message to the specified MnM Voice
          MNM.sendNoteOff(_voice, mnmVoicePool[_voice].note, _velocity);         
        
          // Remove details of voice from mnmVoicePool
          mnmVoicePool[_voice].note = 0xff;
          mnmVoicePool[_voice].active = false;     
          setLastUsedMnMVoice(_voice);

      }      
            
      void onControlChange(uint8_t *msg) {
        
          if(parameterSyncEnabled && sketchEnabled){
              
              uint8_t channel = MIDI_VOICE_CHANNEL(msg[0]);
              uint8_t cc = msg[1];
              uint8_t value = msg[2];
              uint8_t track, param;
              int8_t spread;
              MNM.parseCC(channel, cc, &track, &param);
                                            
              // If params edited via MNM UI, then keep other poly Track params synced
              if ((track >= polyStartTrack) && (track <= polyEndTrack)){            
                 for (uint8_t i = polyStartTrack; i <= polyEndTrack; ++i) {
                     
                     // Apply spread
                     spread = (i - track) * parameterSpread;
                     
                     // Update the internal representation of the kit data
                     MNM.kit.parameters[i][param] = value + spread;
                     
                     // Update the MNM track itself
                     MNM.setParam(i, param, value + spread);                 
                  }
                  return;
              }      
          }
          
          // If we haven't already returned, then echo the message out on the same midi channel
          // MidiUart.sendMessage(msg[0], msg[1], msg[2]);
          
      }                      
    
      virtual void doExtra(bool pressed) {
      }              
        
      virtual void destroy() {
      }

   
    virtual bool handleEvent(gui_event_t *event) {  
          if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
            pushPage(&switchPage);
          } 
          else if (EVENT_RELEASED(event, Buttons.BUTTON1)) {
            popPage(&switchPage);
          }          
          return false;
    }   
   
    void onKitChanged() {
  
      GUI.setLine(GUI.LINE1);
      GUI.flash_p_string_fill(PSTR("LOADED MNM KIT:"));
      GUI.setLine(GUI.LINE2);
      GUI.flash_string_fill(MNM.kit.name);
      
      // copy mnm machine from start track to all other poly tracks
      setMnmMachineForPolyTracks();
    }  
 
};
