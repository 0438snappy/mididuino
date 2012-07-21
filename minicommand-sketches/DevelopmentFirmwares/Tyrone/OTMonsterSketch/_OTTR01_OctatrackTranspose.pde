

#define INTERNAL_TRACK_1_MIDI_CHANNEL (1 - 1)  // OT Track / Midi Channel 1
#define INTERNAL_TRACK_2_MIDI_CHANNEL (2 - 1)  // OT Track / Midi Channel 2
#define INTERNAL_TRACK_3_MIDI_CHANNEL (3 - 1)  // OT Track / Midi Channel 3
#define INTERNAL_TRACK_4_MIDI_CHANNEL (4 - 1)  // OT Track / Midi Channel 4
#define INTERNAL_TRACK_5_MIDI_CHANNEL (5 - 1)  // OT Track / Midi Channel 5
#define INTERNAL_TRACK_6_MIDI_CHANNEL (6 - 1)  // OT Track / Midi Channel 6
#define INTERNAL_TRACK_7_MIDI_CHANNEL (7 - 1)  // OT Track / Midi Channel 7
#define INTERNAL_TRACK_8_MIDI_CHANNEL (8 - 1)  // OT Track / Midi Channel 8
#define OCTATRACK_TRANSPOSE_MIDI_CHANNEL (16 - 1)  // Midi Channel 16
#define MIDI_TRACK_1_MIDI_CHANNEL (8 - 1)  // MIDI Track 1 / Midi Channel 9  (MNM-1)
#define MIDI_TRACK_2_MIDI_CHANNEL (10 - 1)  // MIDI Track 2 / Midi Channel 10  (MNM-2)
#define MIDI_TRACK_3_MIDI_CHANNEL (11 - 1)  // MIDI Track 3 / Midi Channel 11  (MNM-3)
#define MIDI_TRACK_4_MIDI_CHANNEL (12 - 1)  // MIDI Track 4 / Midi Channel 12  (MNM-4 - MNM-6)
#define MIDI_TRACK_5_MIDI_CHANNEL (15 - 1)  // MIDI Track 5 / Midi Channel 15  (TETRA)
#define MIDI_TRACK_6_MIDI_CHANNEL (15 - 1)  // MIDI Track 6 / Midi Channel 15  (TETRA)
#define MIDI_TRACK_7_MIDI_CHANNEL (15 - 1)  // MIDI Track 7 / Midi Channel 15  (TETRA)
#define MIDI_TRACK_8_MIDI_CHANNEL (15 - 1)  // MIDI Track 8 / Midi Channel 15  (TETRA)
#define CC_TRANSPOSE_INTERNAL_TRACK 16  //Playback param 1
#define CC_TRANSPOSE_MIDI_TRACK 22  //Arpeggiator param 1
#define INTERNAL_TRACKS 0  //Array index
#define MIDI_TRACKS 1  //Array index


class OctatrackTransposeClass: public MidiCallback{

  public: 
        int offset[2][8];
        uint8_t transposeCCs[2];
        uint8_t midiChannels[2][8];
        uint8_t transposeTrackEnabled[2][8];
        bool transposeEnabled;
        int transposeMode;
   
        OctatrackTransposeClass
        (
        )
        {
	}

        void setup(){      
            setupOffset();   
            setupTransposeCCs();  
            setupTransposeTrackEnabled();
            setTransposeEnabled(true);
            setupMidiChannels();
            Midi2.addOnNoteOnCallback(this, (midi_callback_ptr_t)&OctatrackTransposeClass::onNoteOn);
        }      
        
        void setupOffset(){
            for (int i=INTERNAL_TRACKS; i<=MIDI_TRACKS; i++){
                for (int j=0; j<8; j++){
                    offset[i][j] = 0;
                }
            }                        
        }
        
        void setupTransposeCCs(){
            transposeCCs[INTERNAL_TRACKS] = CC_TRANSPOSE_INTERNAL_TRACK;
            transposeCCs[MIDI_TRACKS] = CC_TRANSPOSE_MIDI_TRACK;
        }
        
        void setTransposeEnabled(bool _value){
            transposeEnabled = _value;            
        }
        
        void setTransposeTrackEnabled(int _transposeMode, int _trackNumber, bool _value){
            transposeTrackEnabled[_transposeMode][_trackNumber] = _value;  
        }
        
        void setOffset(int _transposeMode, int _trackNumber, int _value){
            offset[_transposeMode][_trackNumber] = _value;  
//            GUI.setLine(GUI.LINE1);
//            GUI.flash_printf_fill ("IN %b %b %b", _transposeMode, _trackNumber, _value);               
//            GUI.setLine(GUI.LINE2);
//            GUI.flash_printf_fill("STORED %b", offset[_transposeMode][_trackNumber]);            
        }      
      
        void setTransposeMode (int _value){
            transposeMode = _value;
        }
        
        bool getTransposeTrackEnabled(uint8_t _transposeMode, uint8_t _trackNumber){
            return transposeTrackEnabled[_transposeMode][_trackNumber];  
        }
        
        int getOffset(uint8_t _transposeMode, uint8_t _trackNumber){
            return offset[_transposeMode][_trackNumber];  
        }        
      
        void setupTransposeTrackEnabled(){
            // OT Internal Tracks
            transposeTrackEnabled[INTERNAL_TRACKS][0] = true;  //Track 1    
            transposeTrackEnabled[INTERNAL_TRACKS][1] = true;    
            transposeTrackEnabled[INTERNAL_TRACKS][2] = true;    
            transposeTrackEnabled[INTERNAL_TRACKS][3] = true;    
            transposeTrackEnabled[INTERNAL_TRACKS][4] = false;    
            transposeTrackEnabled[INTERNAL_TRACKS][5] = false;    
            transposeTrackEnabled[INTERNAL_TRACKS][6] = false;    
            transposeTrackEnabled[INTERNAL_TRACKS][7] = false;  //Track 8
        
            // Midi Tracks    
            transposeTrackEnabled[MIDI_TRACKS][0] = true;  //Track 1    
            transposeTrackEnabled[MIDI_TRACKS][1] = true;    
            transposeTrackEnabled[MIDI_TRACKS][2] = true;    
            transposeTrackEnabled[MIDI_TRACKS][3] = true;    
            transposeTrackEnabled[MIDI_TRACKS][4] = true;    
            transposeTrackEnabled[MIDI_TRACKS][5] = true;    
            transposeTrackEnabled[MIDI_TRACKS][6] = true;    
            transposeTrackEnabled[MIDI_TRACKS][7] = true;  //Track 8            
        }
        
        void setupMidiChannels(){
            // OT Internal Tracks
            midiChannels[INTERNAL_TRACKS][0] = INTERNAL_TRACK_1_MIDI_CHANNEL;  //Track 1    
            midiChannels[INTERNAL_TRACKS][1] = INTERNAL_TRACK_2_MIDI_CHANNEL;    
            midiChannels[INTERNAL_TRACKS][2] = INTERNAL_TRACK_3_MIDI_CHANNEL;    
            midiChannels[INTERNAL_TRACKS][3] = INTERNAL_TRACK_4_MIDI_CHANNEL;    
            midiChannels[INTERNAL_TRACKS][4] = INTERNAL_TRACK_5_MIDI_CHANNEL;    
            midiChannels[INTERNAL_TRACKS][5] = INTERNAL_TRACK_6_MIDI_CHANNEL;    
            midiChannels[INTERNAL_TRACKS][6] = INTERNAL_TRACK_7_MIDI_CHANNEL;    
            midiChannels[INTERNAL_TRACKS][7] = INTERNAL_TRACK_8_MIDI_CHANNEL;  //Track 8
        
            // Midi Tracks    
            midiChannels[MIDI_TRACKS][0] = MIDI_TRACK_1_MIDI_CHANNEL;  //Track 1    
            midiChannels[MIDI_TRACKS][1] = MIDI_TRACK_2_MIDI_CHANNEL;    
            midiChannels[MIDI_TRACKS][2] = MIDI_TRACK_3_MIDI_CHANNEL;    
            midiChannels[MIDI_TRACKS][3] = MIDI_TRACK_4_MIDI_CHANNEL;    
            midiChannels[MIDI_TRACKS][4] = MIDI_TRACK_5_MIDI_CHANNEL;    
            midiChannels[MIDI_TRACKS][5] = MIDI_TRACK_6_MIDI_CHANNEL;    
            midiChannels[MIDI_TRACKS][6] = MIDI_TRACK_7_MIDI_CHANNEL;    
            midiChannels[MIDI_TRACKS][7] = MIDI_TRACK_8_MIDI_CHANNEL;  //Track 8            
        }
        
        
        void onNoteOn(uint8_t *msg) {
        
            if (transposeEnabled && MIDI_VOICE_CHANNEL(msg[0]) == OCTATRACK_TRANSPOSE_MIDI_CHANNEL){
                doTranspose(msg[1]);                          
            } 

            // Echo Not required when using the MOTU MTP AV USB
//            else {              
//                // Echo the note out on the same midi channel
//                MidiUart.sendNoteOn(MIDI_VOICE_CHANNEL(msg[0]), msg[1], msg[2]);
//            }
    
        }
        
        void doTranspose(uint8_t rawNoteNumber){    
          
            uint8_t baseNoteNumber, scaledNoteNumber;
          
                for (int trackNumber = 0; trackNumber < 8; trackNumber++){
                  
                    if(transposeTrackEnabled[transposeMode][trackNumber]){
                        
                        baseNoteNumber = rawNoteNumber + offset[transposeMode][trackNumber];
                        scaledNoteNumber = baseNoteNumber % 24; 
                         
//                        GUI.setLine(GUI.LINE1);
//                        GUI.flash_printf_fill ("%b %b %b", transposeMode, rawNoteNumber, offset[transposeMode][trackNumber]);               
//                        GUI.setLine(GUI.LINE2);
//                        GUI.flash_printf_fill("%b %b", baseNoteNumber, scaledNoteNumber);            
//                         
                         
                       if (transposeMode == INTERNAL_TRACKS){                           
                            // FOR INTERNAL TRACKS
                           if ((baseNoteNumber == 24) || (baseNoteNumber == 72) || (baseNoteNumber == 120)){
                               // Hack to allow transpose up by one full octave.  Novation Remote must be set to oct range -4, 0 or +4 to work properly.
                               MidiUart.sendCC(midiChannels[transposeMode][trackNumber], transposeCCs[transposeMode], 127);    
                           } else if (scaledNoteNumber == 12){
                               MidiUart.sendCC(midiChannels[transposeMode][trackNumber], transposeCCs[transposeMode], 64);    
                           }  else if (scaledNoteNumber == 0){
                               MidiUart.sendCC(midiChannels[transposeMode][trackNumber], transposeCCs[transposeMode], 0);    
                           }  else {
                               MidiUart.sendCC(midiChannels[transposeMode][trackNumber], transposeCCs[transposeMode], (scaledNoteNumber * 5) + 4);    
                           }             
            
                       } else {
                           // FOR MIDI TRACKS
                           if ((baseNoteNumber == 24) || (baseNoteNumber == 72) || (baseNoteNumber == 120)){
                               // Hack to allow transpose up by one full octave.  Novation Remote must be set to oct range -4, 0 or +4 to work properly.
                               MidiUart.sendCC(midiChannels[transposeMode][trackNumber], transposeCCs[transposeMode], 76);    
                           } else {
                               MidiUart.sendCC(midiChannels[transposeMode][trackNumber], transposeCCs[transposeMode], (scaledNoteNumber + 52));    
                           }     

                       }
                    }        
                    
                }       
          
            }       

};
