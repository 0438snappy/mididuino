#include <Platform.h>
//#include <WProgram.h>
#include <MNM.h>
#include <Scales.h>

#define CONTROL_INPUT_MIDI_CHANNEL (16 - 1)  // Midi Channel 16
#define MAX_NUMBER_NOTES 4
#define NOTE_SPREAD_MAX_NUMBER_ELEMENTS (MAX_NUMBER_NOTES - 1)
#define NOTE_SPREAD_SUM_MAX_NUMBER_ELEMENTS (NOTE_SPREAD_MAX_NUMBER_ELEMENTS - 1)
#define NOTE 0
#define CHANNEL 1
#define NUM_SCALES 18

typedef enum {
  MODE_TRANSPOSE,
  MODE_FORCE_TO_SCALE,
  MODE_ENSEMBLE_POLY,
  MODE_COUNT
} mode_t;


class MNMTransposeSketch : public Sketch, public MidiCallback{  

public:
  bool muted;
  EnumEncoder modeEncoder;
  mode_t mode;
  SwitchPage switchPage;
  static const char *modeNames[MODE_COUNT];
  static const char *modeLongNames[MODE_COUNT];
  
  // Ensemble Poly objects
  EncoderPage ensemblePolyConfigPage;
  BoolEncoder ensemblePolyModeEnabledEncoder, resetEnsembleParamsEnabledEncoder, justIntonationEnabledEncoder, sendNoteOnEnabledEncoder;
  uint8_t orderedNotes[MAX_NUMBER_NOTES];
  uint8_t noteSpread[NOTE_SPREAD_MAX_NUMBER_ELEMENTS];
  uint8_t noteSpreadSum[NOTE_SPREAD_SUM_MAX_NUMBER_ELEMENTS];
  uint8_t numberNotes, rootNoteIndex;
  int track;
  bool ensemblePolyModeEnabled, resetEnsembleParamsEnabled, justIntonationEnabled, sendNoteOnEnabled;
  
  // Transpose objects
  EncoderPage transposeConfigPage;
  RangeEncoder transposeAmountEncoder;
  BoolEncoder transposeEnabledEncoder;
  int transposeAmount;
  uint8_t numberTransposedNotes;
  bool transposeEnabled;
  
  // Force To Scale objects
  EncoderPage scaleConfigPage;
  ScaleEncoder scaleEncoder;
  NotePitchEncoder basePitchEncoder;
  static const scale_t *scales[NUM_SCALES];
  uint8_t scaleCount, basePitch;
  bool forceToScaleEnabled;
  const scale_t *currentScale;


  MNMTransposeSketch() 
  {
  }  

  void getName(char *n1, char *n2) {
    m_strncpy_p(n1, PSTR("MNM "), 5);
    m_strncpy_p(n2, PSTR("TRN "), 5);
  }   

  void setup() {
    muted = false;
    setupEnsemblePoly();
    setupMnmTranspose();
    setupForceToScale();
    modeEncoder.initEnumEncoder(modeNames, (int)MODE_COUNT, "0-|");
    switchPage.initPages(&transposeConfigPage, &scaleConfigPage, &ensemblePolyConfigPage, NULL);    
    switchPage.parent = this;    
    Midi2.addOnNoteOnCallback(this, (midi_callback_ptr_t)&MNMTransposeSketch::onNoteOnCallback);
    Midi2.addOnProgramChangeCallback(this, (midi_callback_ptr_t)&MNMTransposeSketch::onProgramChangeCallback);
    Midi2.addOnNoteOffCallback(this, (midi_callback_ptr_t)&MNMTransposeSketch::onNoteOffCallback);  
    Midi.addOnControlChangeCallback(this, (midi_callback_ptr_t)&MNMTransposeSketch::onControlChange);        
  }
  
  void setupEnsemblePoly(){
      ensemblePolyModeEnabled = false;
      resetEnsembleParamsEnabled = false;
      justIntonationEnabled = true;
      sendNoteOnEnabled = true;
      numberNotes = 0;
      for (int i = 0; i < MAX_NUMBER_NOTES; i++) {
        orderedNotes[i] = 128;
      }
      ensemblePolyModeEnabledEncoder.initBoolEncoder("PLY", ensemblePolyModeEnabled);
      resetEnsembleParamsEnabledEncoder.initBoolEncoder("RST", resetEnsembleParamsEnabled);
      justIntonationEnabledEncoder.initBoolEncoder("JI ", justIntonationEnabled);
      sendNoteOnEnabledEncoder.initBoolEncoder("NTE", sendNoteOnEnabled);
      ensemblePolyConfigPage.setEncoders(&modeEncoder, &resetEnsembleParamsEnabledEncoder, &justIntonationEnabledEncoder, &sendNoteOnEnabledEncoder);
      ensemblePolyConfigPage.setShortName("ENS");      
  }
  
  void setupMnmTranspose(){
      transposeEnabled = true;    
      transposeAmount = 0;
      transposeEnabledEncoder.initBoolEncoder("TRN", transposeEnabled);      
      transposeAmountEncoder.initRangeEncoder(-63, 63, "AMT", transposeAmount);
      transposeConfigPage.setEncoders(&modeEncoder, &transposeAmountEncoder, NULL, NULL);      
      transposeConfigPage.setShortName("TRN");      
  }
  
  void setupForceToScale(){
      forceToScaleEnabled = false;
      scaleEncoder.scales = scales;
      scaleEncoder.numScales = NUM_SCALES;     
      scaleEncoder.initRangeEncoder(0, NUM_SCALES, "SCL"); 

      basePitchEncoder.setName("BAS");
      scaleConfigPage.setEncoders(&modeEncoder, &scaleEncoder, &basePitchEncoder, NULL);      
      scaleConfigPage.setShortName("SCL"); 
  }

  virtual void show() {
    if (currentPage() == &switchPage){
        popPage(&switchPage);
    }
    if (currentPage() == NULL){
      setPage(&transposeConfigPage);
    }
  }   

  virtual void loop() {
    if (modeEncoder.hasChanged()) {        
        setMode((mode_t) modeEncoder.getValue());
        setAllNotesOff();
        GUI.setLine(GUI.LINE1);    
        GUI.flash_strings_fill("MODE:", modeLongNames[mode]);                  
    }   
    if (transposeAmountEncoder.hasChanged()) {
        transposeAmount = transposeAmountEncoder.getValue();
    }  
    if (resetEnsembleParamsEnabledEncoder.hasChanged()) {
        resetEnsembleParamsEnabled = resetEnsembleParamsEnabledEncoder.getValue();                                  
    }
    if (justIntonationEnabledEncoder.hasChanged()) {
        justIntonationEnabled = justIntonationEnabledEncoder.getValue();                   
    }
    if (sendNoteOnEnabledEncoder.hasChanged()) {
        sendNoteOnEnabled = sendNoteOnEnabledEncoder.getValue();                           
    }    
    if (scaleEncoder.hasChanged()) {
        currentScale = scaleEncoder.getScale();
        setAllNotesOff();        
    }
    if (basePitchEncoder.hasChanged()){
        basePitch = basePitchEncoder.getValue();
        setAllNotesOff();
    }
  }      
  
  void setMode(mode_t modeValue){
    
     mode = modeValue;     
     transposeEnabled = false;
     ensemblePolyModeEnabled = false;
     forceToScaleEnabled = false;
     
     switch (mode){
         case MODE_TRANSPOSE:
             transposeEnabled = true;
             setPage(&transposeConfigPage);
             break;
             
         case MODE_FORCE_TO_SCALE:
             forceToScaleEnabled = true;
             setPage(&scaleConfigPage);
             break;
        
         case MODE_ENSEMBLE_POLY:
             ensemblePolyModeEnabled = true;
             setPage(&ensemblePolyConfigPage);
             break;
             
     } 
  }

  virtual void hide() {
    if (currentPage() == &switchPage){
        popPage(&switchPage);
    }
  }    

//  virtual void mute(bool pressed) {
//    if (pressed) {
//      muted = !muted;
//      if (muted) {
//          transposeEnabled = muted;
//          ensemblePolyModeEnabled = muted;
//          forceToScaleEnabled = muted;
//          GUI.flash_strings_fill("MNM TRN:", "MUTED");                
//      } else {
//          GUI.flash_strings_fill("MNM TRN:", "UNMUTED");         
//      }
//    }
//  }  

//  virtual Page *getPage(uint8_t i) {
//    if (i == 0) {
//        return &transposeConfigPage;
//    } else if (i == 1) {
//        return &scaleConfigPage;
//    } else if (i == 2){
//        return &ensemblePolyConfigPage;
//    } else {
//      return NULL;
//    }
//  }  

  bool handleEvent(gui_event_t *event) {       
    if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
      pushPage(&switchPage);
    } 
    else if (EVENT_RELEASED(event, Buttons.BUTTON1)) {
      popPage(&switchPage);
    }          
    return false;
  }   

  void onNoteOnCallback(uint8_t *msg) {

    uint8_t channel = MIDI_VOICE_CHANNEL(msg[0]); 
    uint8_t note = msg[1];
    uint8_t velocity = msg[2];

    // FILTER FOR CONTROL MIDI CHANNEL      
    if (channel == CONTROL_INPUT_MIDI_CHANNEL) { 
        if(transposeEnabled){
            
            // Set the transpose amount
            transposeAmount = note - MIDI_NOTE_C5;
            transposeAmountEncoder.setValue(transposeAmount);
            
            // Ensure all transposed notes are turned off
            setAllNotesOff();            
                     
            return;       
        }  
   
        if(forceToScaleEnabled){
           basePitch = note;
           basePitchEncoder.setValue(basePitch);  
           setAllNotesOff();           
           return;
        }     
    }
    
    // Do Ensemble Poly
    if(ensemblePolyModeEnabled){
    
        // Filter for a track that contains an Ensemble machine.  
        if (trackContainsEnsembleMachine(channel)){            
          addEnsembleNote(note);
          calculateNoteSpread();
          setEnsembleMachineParams();    
          if (sendNoteOnEnabled){
              MNM.sendNoteOn(track, orderedNotes[rootNoteIndex], 127);   
          }
          return;
        } 
    } 
    
    // Do Transpose
    if(transposeEnabled){
        note += transposeAmount;        
    }
    
    // Force To Scale
    if(forceToScaleEnabled){
        note = scalePitch(note, basePitch, currentScale->pitches);        
    }    
        
    // If we haven't already done something and returned, then send out the message;
    MidiUart.sendNoteOn(channel, note, velocity);
    
  }

  void onNoteOffCallback(uint8_t *msg) {

    uint8_t channel = MIDI_VOICE_CHANNEL(msg[0]); 
    uint8_t note = msg[1];
    uint8_t velocity = msg[2];

    // Do Ensemble Poly
    if(ensemblePolyModeEnabled){
       
        // Filter for a track that contains an Ensemble machine.  
        if (trackContainsEnsembleMachine(channel)){
          removeEnsembleNote(note);            
          if(resetEnsembleParamsEnabled){
            if(numberNotes == 0){
                resetEnsembleMachineParams();
            } else {
                setEnsembleMachineParams();
            }
          } 
          MNM.sendNoteOff(track, note, velocity);
          return;
        } 
    }

    // Do Transpose  
    if(transposeEnabled){        
        note += transposeAmount;
    } 
    
    // Force To Scale
    if(forceToScaleEnabled){
        note = scalePitch(note, basePitch, currentScale->pitches);        
    }      

    // If we haven't already done something and returned, then send out the message;
    MidiUart.sendNoteOff(channel, note, velocity);
  }
  
  void onControlChange(uint8_t *msg) {
        
        uint8_t channel = MIDI_VOICE_CHANNEL(msg[0]);
        uint8_t cc = msg[1];
        uint8_t value = msg[2];
        uint8_t mnmTrack, mnmParam;
        if (MNM.parseCC(channel, cc, &mnmTrack, &mnmParam)){
                                            
            // Update the internal representation of the kit data
            MNM.kit.parameters[mnmTrack][mnmParam] = value;
            return;
        
        } 
         
        // If we haven't already returned, echo the message out on the same midi channel
        // CHECK FOR CONFLICTS WITH OTHER SKETCHES...
        //MidiUart.sendMessage(msg[0], msg[1], msg[2]);
       
  }
  
  void onProgramChangeCallback(uint8_t *msg){
      MidiUart.sendMessage(msg[0], msg[1]);  
  }

  void addEnsembleNote(uint8_t _note){

    //  Do nothing if note already exists in the Array
    for (int i = 0; i < MAX_NUMBER_NOTES; i++) {
      if (orderedNotes[i] == _note) {
        return;
      }
    }

    // If at maximum number of allowed notes, then clear the lowest
    if (numberNotes == MAX_NUMBER_NOTES) {
      orderedNotes[0] = 128;
      numberNotes--;
      reorderNotes();
    }

    orderedNotes[numberNotes] = _note;
    numberNotes++;
    sortEnsembleNotesAscending();           
  }
    
  void setAllNotesOff(){
     for (int i = 0; i < 16; i++) {
          track = i - MNM.global.baseChannel;     
          // Send CC #120 for MNM tracks, otherwise CC #123 
          if ((track <= 5) && (track >= 0)){
              MidiUart.sendCC(i, 120, 1); 
          } else {
              MidiUart.sendCC(i, 123, 1);                 
          }
     }
  }

  void removeEnsembleNote(uint8_t _note){

    for (int i = 0; i < MAX_NUMBER_NOTES; i++) {
      if (orderedNotes[i] == _note) {
        orderedNotes[i] = 128;
        reorderNotes();
        numberNotes--;
        break;
      }
    }
  }

  void reorderNotes(){

    uint8_t write = 0;
    for (int i = 0; i < MAX_NUMBER_NOTES; i++) {
      if (orderedNotes[i] != 128) {
        orderedNotes[write] = orderedNotes[i];
        if (i != write){
          orderedNotes[i] = 128;
        }
        write++;
      }
    }
  }

  void sortEnsembleNotesAscending() {
    bool completed = true;
    do {
      completed = true;
      for (int i = 0; i < numberNotes-1; i++) {
        if (orderedNotes[i] > orderedNotes[i+1]) {
          completed = false;
          uint8_t tmp = orderedNotes[i];
          orderedNotes[i] = orderedNotes[i+1];
          orderedNotes[i+1] = tmp;
        }
      }
    } 
    while (!completed);
  }
  
  void resetEnsembleMachineParams(){
  
      // Reset Params for the Ensemble Pitches as per stored kit settings
      for (int i = 0; i < NOTE_SPREAD_MAX_NUMBER_ELEMENTS; i++) {
                    
              MNM.setParam(track, i, MNM.kit.parameters[track][i]);                        
         
      }
  
  }

  void setEnsembleMachineParams(){
    
      int interval;
    
      // determine the index of root note, and set params for the other notes
      switch (numberNotes){

          // 0 notes to sound, so return
          case 0:
            return;
            
          // If 1 or 2 notes, then use the first note as the root index
          case 1:
          case 2:
            rootNoteIndex = 0;
            break;
            
          // If 3 notes, then use the second (middle) note as the root index  
          case 3:
            rootNoteIndex = 1;
            break;
        
          default:
            // If any of the note spreads are > 12 then do not choose those notes as there is only +/-12 range
            if (noteSpread[0] > 12){
                // use note 3
                rootNoteIndex = 2;
                break;
            } else if (noteSpread[2] > 12) {
                // use note 2
                rootNoteIndex = 1;
                break;
            // Otherwise use noteSpreadSum to choose...   
            } else if (noteSpreadSum[0] < noteSpreadSum[1]){
                rootNoteIndex = 2;
                break;
            } else {
                rootNoteIndex = 1;
                break;
            }                    
      }
      
      // Override rootNoteIndex if sendNoteOnEnabled = false (just set the interval pitches as per the actual keys pressed)
      if (!sendNoteOnEnabled){
          rootNoteIndex = 0;
      }
      
      // Set Params for the Ensemble Pitches.
      // Set -ve interval for those notes below the rootIndex
      interval = 0;
      for (int i = rootNoteIndex-1; i >= 0; i--) {     
          interval -= noteSpread[i];       
          MNM.setParam(track, i, mapIntervalToCC(interval));                                  
      }   
   
      // Set +ve interval for those notes above the rootIndex  
      interval = 0;      
      for (int i = rootNoteIndex; i < NOTE_SPREAD_MAX_NUMBER_ELEMENTS; i++) {
          interval += noteSpread[i];
          MNM.setParam(track, i, mapIntervalToCC(interval));
      }   
      
  }
  
  uint8_t mapIntervalToCC(int noteInterval){
      
      switch(noteInterval){
          
          case -12:
              return 1;
          
          case -11:
              return 4;
          
          case -10:
              return 8;
          
          case -9:
              return 12;
          
          case -8:
              return 16;
          
//          case 2/3:
//              return 20;
          
          case -7:
              if (justIntonationEnabled) {
                  return 20;
              } else {
                  return 24;
              }
          
          case -6:
              return 28;
          
          case -5:
              if (justIntonationEnabled) {
                  return 36;
              } else {
                  return 32;
              }
          
//          case 3/4:
//          return 36;
          
          case -4:
              if (justIntonationEnabled) {
                  return 43;
              } else {
                  return 39;
              }
          
//          case 4/5:
//              return 43;
//          
//          case 5/6:
//              return 47;
          
          case -3:
              if (justIntonationEnabled) {
                  return 47;
              } else {
                  return 51;
              }
          
          case -2:
              return 55;
          
          case -1:
              return 59;
          
          case 0:
              return 63;
          
          case 1:
              return 66;
          
          case 2:
              return 70;
          
          case 3:
              if (justIntonationEnabled) {
                  return 78;
              } else {
                  return 74;
              }
          
//          case 6/5:
//              return 78;
//          
//          case 5/4:
//              return 82;
          
          case 4:
              if (justIntonationEnabled) {
                  return 82;
              } else {
                  return 86;
              }
          
//          case 4/3:
//              return 90;
          
          case 5:
              if (justIntonationEnabled) {
                  return 90;
              } else {
                  return 94;
              }
          
          case 6:
              return 97;
          
          case 7:
              if (justIntonationEnabled) {
                  return 105;
              } else {
                  return 101;
              }
          
//          case 3/2:
//              return 105;
          
          case 8:
              return 109;
          
          case 9:
              return 113;
          
          case 10:
              return 117;
          
          case 11:
              return 121;
          
          case 12:
              return 125;  
              
          default:
              return 63;
      }
  }

  void calculateNoteSpread(){

    // Initialise the noteSpread array
    for (int i = 0; i < NOTE_SPREAD_MAX_NUMBER_ELEMENTS; i++) {
      noteSpread[i] = 0;
    }

    // noteSpread[index 0 to 2] = spread between orderedNotes[n] and orderedNotes[n+1]
    for (int i = 0; i < numberNotes - 1; i++) {
      noteSpread[i] = orderedNotes[i+1] - orderedNotes[i];
    }
    
    // noteSpreadSum[index 0 to 1] = sum of noteSpread[n] and noteSpread[n + 1]          
    for (int i = 0; i < NOTE_SPREAD_SUM_MAX_NUMBER_ELEMENTS; i++) {
      noteSpreadSum[i] = noteSpread[i] + noteSpread[i+1];
    }

  }
  
  bool trackContainsEnsembleMachine(uint8_t _channel){

      track = _channel - MNM.global.baseChannel;
      
      if ((track <= 5) && (track >= 0)){
          if (MNM.kit.models[track] == MNM_SWAVE_ENS_MODEL || MNM.kit.models[track] == MNM_DPRO_DENS_MODEL){
              return true; 
          } else {
              return false;
          }
      }                        
  }


};

const scale_t *MNMTransposeSketch::scales[NUM_SCALES] = {
    &ionianScale,
    &aeolianScale,
  
    &harmonicMinorScale,
    &melodicMinorScale,
    &lydianDominantScale,
  
    &wholeToneScale,
    &wholeHalfStepScale,
    &halfWholeStepScale,
  
    &bluesScale,
    &majorPentatonicScale,
    &minorPentatonicScale,
    &suspendedPentatonicScale,
    &inSenScale,
  
//    &majorBebopScale,
//    &dominantBebopScale,
//    &minorBebopScale,
  
    &majorArp,
    &minorArp,
    &majorMaj7Arp,
    &majorMin7Arp,
    &minorMin7Arp
};

const char *MNMTransposeSketch::modeNames[MODE_COUNT] = {
      "TRN", 
      "SCL", 
      "ENS"
};

const char *MNMTransposeSketch::modeLongNames[MODE_COUNT] = {
      "TRANSPOSE", 
      "FORCE TO SCALE", 
      "ENSEMBLE POLY"
};
