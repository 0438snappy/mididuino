class TransposeConfigPage : public EncoderPage {

  public: 
	RangeEncoder trackSelectEncoder, offsetEncoder;
	EnumEncoder transposeModeEncoder;
        BoolEncoder trackTransposeEnabledEncoder;
        OctatrackTransposeClass *octatrackTranspose;
        int trackType, trackIndex;
        bool updateAllTracksMode;
        static const char *trackTypeNames[2];
           
        TransposeConfigPage
        (
            OctatrackTransposeClass *_octatrackTranspose
        ):
            octatrackTranspose(_octatrackTranspose),       
            trackSelectEncoder(8, 1, "TRK", 1), 
            trackTransposeEnabledEncoder("TRN", octatrackTranspose->transposeTrackEnabled[trackType][trackIndex]),            
            offsetEncoder(12, -12, "OFS", 0),
            transposeModeEncoder(trackTypeNames, countof(trackTypeNames), "TYP")
        {
	    encoders[0] = &transposeModeEncoder;          
	    encoders[1] = &trackSelectEncoder;
	    encoders[2] = &trackTransposeEnabledEncoder;
	    encoders[3] = &offsetEncoder;
	}

	virtual void loop() {
            if (trackSelectEncoder.hasChanged()) {
                trackIndex = (trackSelectEncoder.getValue() - 1);
                updateEncoders();
	    }
            if (trackTransposeEnabledEncoder.hasChanged()) {
                if(updateAllTracksMode){
                    // Update value for all tracks
                    for (int trackNumber=0; trackNumber<8; trackNumber++){
                        octatrackTranspose->setTransposeTrackEnabled(trackType, trackNumber, trackTransposeEnabledEncoder.getValue());     
                    } 
                } else {
                    // Just update the track selected by the Track Encoder
                    octatrackTranspose->setTransposeTrackEnabled(trackType, trackIndex, trackTransposeEnabledEncoder.getValue());    
                }
	    }
            if (offsetEncoder.hasChanged()) {
                if(updateAllTracksMode){
                    // Update value for all tracks
                    for (int trackNumber=0; trackNumber<8; trackNumber++){
                        octatrackTranspose->setOffset(trackType, trackNumber, offsetEncoder.getValue());    
                    } 
                } else {                
                    // Just update the track selected by the Track Encoder
                    octatrackTranspose->setOffset(trackType, trackIndex, offsetEncoder.getValue());    
                }
	    }
            if (transposeModeEncoder.hasChanged()) {
                trackType = transposeModeEncoder.getValue();
                octatrackTranspose->setTransposeMode(trackType); 
                updateEncoders();
            }
	}

        void setup(){         
            updateAllTracksMode = false;
            trackIndex = (trackSelectEncoder.getValue() - 1);           
            trackType = MIDI_TRACKS;
            transposeModeEncoder.setValue(trackType, true);
            octatrackTranspose->setTransposeMode(trackType); 
            updateEncoders();           
        }        
        
        void updateEncoders(){
            trackTransposeEnabledEncoder.setValue(octatrackTranspose->getTransposeTrackEnabled(trackType,trackIndex), true);   
            offsetEncoder.setValue(octatrackTranspose->getOffset(trackType,trackIndex), true);  
        }
        
        void setUpdateAllTracksMode(bool _value){
            updateAllTracksMode = _value;
            if(updateAllTracksMode){
                GUI.flash_strings_fill("UPDATE ALL TRKS:", "ON", 400);              
            } else {
                GUI.flash_strings_fill("UPDATE ALL TRKS:", "OFF", 400);                            
            }
        }
    
	bool handleEvent(gui_event_t *event) {
  
            if (EVENT_PRESSED(event, Buttons.BUTTON2)) {
                setUpdateAllTracksMode(true);
                return true;                 
            } else if (EVENT_RELEASED(event, Buttons.BUTTON2)) {  
                setUpdateAllTracksMode(false);
                return true; 
            } 
              
            return false;

	}

};

const char *TransposeConfigPage::trackTypeNames[2] = {
  "INT",           // INTERNAL_TRACKS
  "MID"            // MIDI_TRACKS
};   

