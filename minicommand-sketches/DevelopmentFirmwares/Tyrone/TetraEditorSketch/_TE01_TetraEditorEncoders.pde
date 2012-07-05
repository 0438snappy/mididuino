#include <Platform.h>
//#include <WProgram.h>
//#include<avr/pgmspace.h>

#define TETRA_MIDI_CHANNEL (13 - 1) // Midi Channel 13
#define NUM_TETRA_EDITOR_PAGES 24
#define OSC_SHAPES_CNT 5
#define LFO_FREQS_CNT 17


/**
 * Generic NRPN Encoder Class
 **/
class NRPNEncoder : public RangeEncoder {
	
public:
  /** The NRPN number used when the NRPN message is sent. **/
  uint16_t nrpn;
  /** The MIDI channel number (from 0 to 15) to use when sending the NRPN message. **/
  uint8_t channel;
    
  virtual uint16_t getNRPN() {
    return nrpn;
  }
  virtual uint8_t getChannel() {
    return channel;
  }
  
  virtual void initNRPNEncoder(uint8_t _channel, uint16_t _nrpn) {
    nrpn = _nrpn;
    channel = _channel;
  }  

  /** Create a NRPN encoder sending NRPN messages with number _nrpn on _channel. **/
  NRPNEncoder(uint16_t _nrpn = 0, uint8_t _channel = 0, const char *_name = NULL, int _min = 0, int _max = 127, int init = 0) :
    RangeEncoder(_max, _min, _name, init) {
    initNRPNEncoder(_channel, _nrpn);
    handler = NRPNEncoderHandle;
  }

};

/**
 * Handle a change in a NRPNEncoder by sending out the NRPN, using the
 * channel and nrpn out of the NRPNEncoder object.
 **/
void NRPNEncoderHandle(Encoder *enc) {
  NRPNEncoder *nrpnEnc = (NRPNEncoder *)enc;
  uint8_t channel = nrpnEnc->getChannel();
  uint16_t nrpn = nrpnEnc->getNRPN();
  uint16_t value = nrpnEnc->getValue();
	
  MidiUart.sendNRPN(channel, nrpn, value);
}


/**
 * NRPN Encoder Class customised for Tetra
 **/
class TetraNRPNEncoder : public NRPNEncoder {  
  	
public:
  /** Encoder Long name. **/
  char *longName;
  uint16_t paramNumber;

  /** Set the encoder long name (max 16 characters). **/
  virtual void setLongName(char *_longName){
        longName = _longName;
  }  
  
  virtual void displayAt(int i){
      // Display Encoder value on GUI.LINE2        
      GUI.setLine(GUI.LINE2);
      GUI.put_value(i, getValue());    
    
      if (hasChanged() || isPressed) {
        // Flash Long Encoder Name on GUI.LINE1
        GUI.setLine(GUI.LINE1);
        GUI.flash_string_fill(longName);
      }
  }  

  /** Create a NRPN encoder sending NRPN messages with number _nrpn on _channel. **/
  TetraNRPNEncoder(uint16_t _paramNumber, uint16_t _nrpn = 0, uint8_t _channel = 0, const char *_name = NULL, char *_longName = NULL, int _min = 0, int _max = 127, int init = 0) :
    NRPNEncoder(_nrpn, _channel, _name, _min, _max, init) {
    setLongName(_longName);
    paramNumber = _paramNumber;
  }

};

/**
 * NRPN Enum Encoder Class customised for Tetra
 **/
class TetraNRPNEnumEncoder : public TetraNRPNEncoder {
	
public:

  const char **enumShortStrings;
  const char **enumLongStrings;
  int cnt;

	/**
	 * Create an enumeration encoder allowing to choose between _cnt
	 * different options. Each option should be described by a 3
	 * character string in the shortStrings[] array. Turning the encoder will
	 * display the correct shortString on the encoder as well as flash the enum value from the longStrings array.
	 **/
  TetraNRPNEnumEncoder(const char *shortStrings[] = NULL, const char *longStrings[] = NULL, int _cnt = 0, uint16_t _paramNumber = 0, uint16_t _nrpn = 0, uint8_t _channel = 0, const char *_name = NULL, char *_longName = NULL, int _min = 0, int _max = 127, int init = 0) :
      TetraNRPNEncoder(_paramNumber, _nrpn, _channel, _name, _longName, _min, _max, init) {
      enumShortStrings = shortStrings;
      enumLongStrings = longStrings;
      cnt = _cnt;
  }

  virtual void displayAt(int i){
    GUI.put_string_at(i * 4, enumShortStrings[getValue()]);
    redisplay = false;
    if (hasChanged() || isPressed) {
        // Flash Long Encoder Name on GUI.LINE1
        GUI.setLine(GUI.LINE1);
        GUI.flash_string_fill(longName);
        // Flash Enum Long Value on GUI.LINE2        
        GUI.setLine(GUI.LINE2);
        GUI.flash_string_fill(enumLongStrings[getValue()]);        
    }
  }


};




/**
 * NRPN Enum Encoder Class customised for Tetra Oscillator Shapes
 *
 * encoder values 4 - 103 display as "PULSE WIDTH nn"
 **/
class TetraOscShapeNRPNEnumEncoder : public TetraNRPNEncoder {
	
public:

  char **enumShortStrings;
  char **enumLongStrings;
  int cnt;
	
  TetraOscShapeNRPNEnumEncoder(char *shortStrings[] = NULL, char *longStrings[] = NULL, int _cnt = 0, uint16_t _paramNumber = 0, uint16_t _nrpn = 0, uint8_t _channel = 0, const char *_name = NULL, char *_longName = NULL, int _min = 0, int _max = 127, int init = 0) :
        TetraNRPNEncoder(_paramNumber, _nrpn, _channel, _name, _longName, _min, _max, init) {
            enumShortStrings = shortStrings;
            enumLongStrings = longStrings;
            cnt = _cnt;
   }

  virtual void displayAt(int i){
    int enumValue = MIN(getValue(), (OSC_SHAPES_CNT - 1));
    char *shortStringValue;  
    char *longStringValue;
   
    shortStringValue = enumShortStrings[enumValue];
    longStringValue = enumLongStrings[enumValue];     
    
    int pulseWidthValue = getValue() - (OSC_SHAPES_CNT - 1);
    if (pulseWidthValue >= 0){
       // Re-use the display implementation from GUI.cpp::suppress_zero      
       shortStringValue[2] = pulseWidthValue % 10 + '0';
       longStringValue[13] = pulseWidthValue % 10 + '0';
       pulseWidthValue /= 10;
       shortStringValue[1] = pulseWidthValue ? (pulseWidthValue % 10 + '0') : ' ';
       longStringValue[12] = pulseWidthValue ? (pulseWidthValue % 10 + '0') : ' ';
    } 
    
    GUI.put_string_at(i * 4, shortStringValue);
    redisplay = false;
    if (hasChanged() || isPressed) {
        // Flash Long Encoder Name on GUI.LINE1
        GUI.setLine(GUI.LINE1);
        GUI.flash_string_fill(longName);
        // Flash Enum Long Value on GUI.LINE2        
        GUI.setLine(GUI.LINE2);
        GUI.flash_string_fill(longStringValue);        
    }
  }
};

/**
 * NRPN Enum Encoder Class customised for Tetra LFO Frequencies
 *
 * encoder values 0 - 150 display as "UNSYNCED nnn"
 **/
class TetraLFOFrequencyNRPNEnumEncoder : public TetraNRPNEncoder {
	
public:

  char **enumShortStrings;
  char **enumLongStrings;
  int cnt;
	
  TetraLFOFrequencyNRPNEnumEncoder(char *shortStrings[] = NULL, char *longStrings[] = NULL, int _cnt = 0, uint16_t _paramNumber = 0, uint16_t _nrpn = 0, uint8_t _channel = 0, const char *_name = NULL, char *_longName = NULL, int _min = 0, int _max = 127, int init = 0) :
        TetraNRPNEncoder(_paramNumber, _nrpn, _channel, _name, _longName, _min, _max, init) {
            enumShortStrings = shortStrings;
            enumLongStrings = longStrings;
            cnt = _cnt;
   }

  virtual void displayAt(int i){
    int enumValue = MAX(getValue(), 150) - 150;
    char *shortStringValue;  
    char *longStringValue;
   
    shortStringValue = enumShortStrings[enumValue];
    longStringValue = enumLongStrings[enumValue];     
    
    int lfoFreqValue = getValue();
    if (lfoFreqValue <= 150){
       // Re-use the display implementation from GUI.cpp::suppress_zero      
       shortStringValue[2] = lfoFreqValue % 10 + '0';
       longStringValue[11] = lfoFreqValue % 10 + '0';
       lfoFreqValue /= 10;
       shortStringValue[1] = lfoFreqValue ? (lfoFreqValue % 10 + '0') : ' ';
       longStringValue[10] = lfoFreqValue ? (lfoFreqValue % 10 + '0') : ' ';
       lfoFreqValue /= 10;
       shortStringValue[0] = lfoFreqValue ? (lfoFreqValue % 10 + '0') : ' ';
       longStringValue[9] = lfoFreqValue ? (lfoFreqValue % 10 + '0') : ' ';       
    } 
    
    GUI.put_string_at(i * 4, shortStringValue);
    redisplay = false;
    if (hasChanged() || isPressed) {
        // Flash Long Encoder Name on GUI.LINE1
        GUI.setLine(GUI.LINE1);
        GUI.flash_string_fill(longName);
        // Flash Enum Long Value on GUI.LINE2        
        GUI.setLine(GUI.LINE2);
        GUI.flash_string_fill(longStringValue);        
    }
  }
};


char* oscShapeShortNames[OSC_SHAPES_CNT] = {
"OFF", 
"SAW", 
"TRI", 
"S/T", 
"P  "
};

char* oscShapeLongNames[OSC_SHAPES_CNT] = {
  "OFF", 
  "SAWTOOTH", 
  "TRIANGLE", 
  "SAW/TRIANGLE MIX", 
  "PULSE WIDTH   "
};

char* lfoFrequencyShortNames[LFO_FREQS_CNT] = {
    "   ", 
    "/32", 
    "/16", 
    "/8", 
    "/6", 
    "/4", 
    "/3", 
    "/2", 
    "/15", 
    "1xS", 
    "2/3", 
    "2xS", 
    "1/3", 
    "4xS", 
    "6xS", 
    "8xS", 
    "16x"
};

char* lfoFrequencyLongNames[LFO_FREQS_CNT] = {
    "UNSYNCED    ", 
    "SEQ SPD / 32", 
    "SEQ SPD / 16", 
    "SEQ SPD / 8", 
    "SEQ SPD / 6", 
    "SEQ SPD / 4", 
    "SEQ SPD / 3", 
    "SEQ SPD / 2", 
    "SEQ SPD / 1.5", 
    "1 CYCLE / STEP", 
    "2 CYCLE / 3 STEP", 
    "2 CYCLE / STEP", 
    "1 CYCLE / 3 STEP", 
    "4 CYCLE / STEP", 
    "6 CYCLE / STEP", 
    "8 CYCLE / STEP", 
    "16 CYCLE / STEP" 
};





TetraNRPNEncoder tetraOsc1FreqEncoder(0, 0, TETRA_MIDI_CHANNEL, "FRQ", "OSC1 FREQ", 0, 120, 0);
TetraNRPNEncoder tetraOsc1TuneEncoder(1, 1, TETRA_MIDI_CHANNEL, "TUN", "OSC1 TUNE", 0, 100, 0);
TetraNRPNEncoder tetraOsc1ShapeEncoder(2, 2, TETRA_MIDI_CHANNEL, "SHP", "OSC1 SHAPE", 0, 103, 0);
//TetraOscShapeNRPNEnumEncoder tetraOsc1ShapeEncoder(oscShapeShortNames, oscShapeLongNames, OSC_SHAPES_CNT, 2, 2, TETRA_MIDI_CHANNEL, "SHP", "OSC1 SHAPE", 0, 103, 0);
TetraNRPNEncoder tetraOsc1GlideEncoder(3, 3, TETRA_MIDI_CHANNEL, "GLI", "OSC1 GLIDE", 0, 127, 0);
TetraNRPNEncoder tetraOsc1KeyboardEncoder(4, 4, TETRA_MIDI_CHANNEL, "KEY", "OSC1 KEYBOARD", 0, 1, 0);
TetraNRPNEncoder tetraOsc2FreqEncoder(6, 5, TETRA_MIDI_CHANNEL, "FRQ", "OSC2 FREQ", 0, 120, 0);
TetraNRPNEncoder tetraOsc2TuneEncoder(7, 6, TETRA_MIDI_CHANNEL, "TUN", "OSC2 TUNE", 0, 100, 0);
TetraNRPNEncoder tetraOsc2ShapeEncoder(8, 7, TETRA_MIDI_CHANNEL, "SHP", "OSC2 SHAPE", 0, 103, 0);
//TetraOscShapeNRPNEnumEncoder tetraOsc2ShapeEncoder(oscShapeShortNames, oscShapeLongNames, OSC_SHAPES_CNT, 8, 7, TETRA_MIDI_CHANNEL, "SHP", "OSC2 SHAPE", 0, 103, 0);
TetraNRPNEncoder tetraOsc2GlideEncoder(9, 8, TETRA_MIDI_CHANNEL, "GLI", "OSC2 GLIDE", 0, 127, 0);
TetraNRPNEncoder tetraOsc2KeyboardEncoder(10, 9, TETRA_MIDI_CHANNEL, "KEY", "OSC2 KEYBOARD", 0, 1, 0);
TetraNRPNEncoder tetraSyncEncoder(12, 10, TETRA_MIDI_CHANNEL, "SYN", "SYNC", 0, 1, 0);
TetraNRPNEncoder tetraGlideModeEncoder(13, 11, TETRA_MIDI_CHANNEL, "GMD", "GLIDE MODE", 0, 3, 0);
TetraNRPNEncoder tetraOscSlopEncoder(14, 12, TETRA_MIDI_CHANNEL, "SLP", "OSC SLOP", 0, 5, 0);
TetraNRPNEncoder tetraOscMixEncoder(16, 13, TETRA_MIDI_CHANNEL, "MIX", "OSC MIX", 0, 127, 0);
TetraNRPNEncoder tetraNoiseLvlEncoder(17, 14, TETRA_MIDI_CHANNEL, "NOI", "NOISE LVL", 0, 127, 0);
TetraNRPNEncoder tetraVcfFreqEncoder(20, 15, TETRA_MIDI_CHANNEL, "CUT", "VCF FREQ", 0, 164, 0);
TetraNRPNEncoder tetraVcfResonanceEncoder(21, 16, TETRA_MIDI_CHANNEL, "RES", "VCF RESONANCE", 0, 127, 0);
TetraNRPNEncoder tetraVcfKeyboardAmtEncoder(22, 17, TETRA_MIDI_CHANNEL, "FKY", "VCF KEYBOARD AMT", 0, 127, 0);
TetraNRPNEncoder tetraVcfAudioModEncoder(23, 18, TETRA_MIDI_CHANNEL, "MOD", "VCF AUDIO MOD", 0, 127, 0);
TetraNRPNEncoder tetraVcfPolesEncoder(24, 19, TETRA_MIDI_CHANNEL, "POL", "VCF POLES", 0, 1, 0);
TetraNRPNEncoder tetraVcfEnvAmtEncoder(25, 20, TETRA_MIDI_CHANNEL, "AMT", "VCF ENV AMT", 0, 254, 0);
TetraNRPNEncoder tetraVcfVelAmtEncoder(26, 21, TETRA_MIDI_CHANNEL, "VEL", "VCF VEL AMT", 0, 127, 0);
TetraNRPNEncoder tetraVcfEnvDelayEncoder(27, 22, TETRA_MIDI_CHANNEL, "DEL", "VCF ENV DELAY", 0, 127, 0);
TetraNRPNEncoder tetraVcfEnvAttackEncoder(28, 23, TETRA_MIDI_CHANNEL, "ATK", "VCF ENV ATTACK", 0, 127, 0);
TetraNRPNEncoder tetraVcfEnvDecayEncoder(29, 24, TETRA_MIDI_CHANNEL, "DCY", "VCF ENV DECAY", 0, 127, 0);
TetraNRPNEncoder tetraVcfEnvSustainEncoder(30, 25, TETRA_MIDI_CHANNEL, "SUS", "VCF ENV SUSTAIN", 0, 127, 0);
TetraNRPNEncoder tetraVcfEnvReleaseEncoder(31, 26, TETRA_MIDI_CHANNEL, "REL", "VCF ENV RELEASE", 0, 127, 0);
TetraNRPNEncoder tetraVcaLevelEncoder(32, 27, TETRA_MIDI_CHANNEL, "LEV", "VCA LEVEL", 0, 127, 0);
TetraNRPNEncoder tetraOutputSpreadEncoder(40, 28, TETRA_MIDI_CHANNEL, "SPR", "OUTPUT SPREAD", 0, 127, 0);
TetraNRPNEncoder tetraVoiceVolumeEncoder(41, 29, TETRA_MIDI_CHANNEL, "VOL", "VOICE VOLUME", 0, 127, 0);
TetraNRPNEncoder tetraVcaEnvAmtEncoder(33, 30, TETRA_MIDI_CHANNEL, "AMT", "VCA ENV AMT", 0, 127, 0);
TetraNRPNEncoder tetraVcaVelAmtEncoder(34, 31, TETRA_MIDI_CHANNEL, "VEL", "VCA VEL AMT", 0, 127, 0);
TetraNRPNEncoder tetraVcaEnvDelayEncoder(35, 32, TETRA_MIDI_CHANNEL, "DEL", "VCA ENV DELAY", 0, 127, 0);
TetraNRPNEncoder tetraVcaEnvAttackEncoder(36, 33, TETRA_MIDI_CHANNEL, "ATK", "VCA ENV ATTACK", 0, 127, 0);
TetraNRPNEncoder tetraVcaEnvDecayEncoder(37, 34, TETRA_MIDI_CHANNEL, "DCY", "VCA ENV DECAY", 0, 127, 0);
TetraNRPNEncoder tetraVcaEnvSustainEncoder(38, 35, TETRA_MIDI_CHANNEL, "SUS", "VCA ENV SUSTAIN", 0, 127, 0);
TetraNRPNEncoder tetraVcaEnvReleaseEncoder(39, 36, TETRA_MIDI_CHANNEL, "REL", "VCA ENV RELEASE", 0, 127, 0);
TetraNRPNEncoder tetraLfo1FreqEncoder(42, 37, TETRA_MIDI_CHANNEL, "FRQ", "LFO1 FREQ", 0, 166, 0);
//TetraLFOFrequencyNRPNEnumEncoder tetraLfo1FreqEncoder(lfoFrequencyShortNames, lfoFrequencyLongNames, LFO_FREQS_CNT, 42, 37, TETRA_MIDI_CHANNEL, "FRQ", "LFO1 FREQ", 0, 166, 0);
TetraNRPNEncoder tetraLfo1ShapeEncoder(43, 38, TETRA_MIDI_CHANNEL, "SHP", "LFO1 SHAPE", 0, 4, 0);
TetraNRPNEncoder tetraLfo1AmtEncoder(44, 39, TETRA_MIDI_CHANNEL, "AMT", "LFO1 AMT", 0, 127, 0);
TetraNRPNEncoder tetraLfo1DestinationEncoder(45, 40, TETRA_MIDI_CHANNEL, "DST", "LFO1 DESTINATION", 0, 43, 0);
TetraNRPNEncoder tetraLfo1KeySyncEncoder(46, 41, TETRA_MIDI_CHANNEL, "SYN", "LFO1 KEY SYNC", 0, 1, 0);
TetraNRPNEncoder tetraLfo2FreqEncoder(47, 42, TETRA_MIDI_CHANNEL, "FRQ", "LFO2 FREQ", 0, 166, 0);
//TetraLFOFrequencyNRPNEnumEncoder tetraLfo2FreqEncoder(lfoFrequencyShortNames, lfoFrequencyLongNames, LFO_FREQS_CNT, 47, 42, TETRA_MIDI_CHANNEL, "FRQ", "LFO2 FREQ", 0, 166, 0);
TetraNRPNEncoder tetraLfo2ShapeEncoder(48, 43, TETRA_MIDI_CHANNEL, "SHP", "LFO2 SHAPE", 0, 4, 0);
TetraNRPNEncoder tetraLfo2AmtEncoder(49, 44, TETRA_MIDI_CHANNEL, "AMT", "LFO2 AMT", 0, 127, 0);
TetraNRPNEncoder tetraLfo2DestinationEncoder(50, 45, TETRA_MIDI_CHANNEL, "DST", "LFO2 DESTINATION", 0, 43, 0);
TetraNRPNEncoder tetraLfo2KeySyncEncoder(51, 46, TETRA_MIDI_CHANNEL, "SYN", "LFO2 KEY SYNC", 0, 1, 0);
TetraNRPNEncoder tetraLfo3FreqEncoder(52, 47, TETRA_MIDI_CHANNEL, "FRQ", "LFO3 FREQ", 0, 166, 0);
//TetraLFOFrequencyNRPNEnumEncoder tetraLfo3FreqEncoder(lfoFrequencyShortNames, lfoFrequencyLongNames, LFO_FREQS_CNT, 52, 47, TETRA_MIDI_CHANNEL, "FRQ", "LFO3 FREQ", 0, 166, 0);
TetraNRPNEncoder tetraLfo3ShapeEncoder(53, 48, TETRA_MIDI_CHANNEL, "SHP", "LFO3 SHAPE", 0, 4, 0);
TetraNRPNEncoder tetraLfo3AmtEncoder(54, 49, TETRA_MIDI_CHANNEL, "AMT", "LFO3 AMT", 0, 127, 0);
TetraNRPNEncoder tetraLfo3DestinationEncoder(55, 50, TETRA_MIDI_CHANNEL, "DST", "LFO3 DESTINATION", 0, 43, 0);
TetraNRPNEncoder tetraLfo3KeySyncEncoder(56, 51, TETRA_MIDI_CHANNEL, "SYN", "LFO3 KEY SYNC", 0, 1, 0);
TetraNRPNEncoder tetraLfo4FreqEncoder(57, 52, TETRA_MIDI_CHANNEL, "FRQ", "LFO4 FREQ", 0, 166, 0);
//TetraLFOFrequencyNRPNEnumEncoder tetraLfo4FreqEncoder(lfoFrequencyShortNames, lfoFrequencyLongNames, LFO_FREQS_CNT, 57, 52, TETRA_MIDI_CHANNEL, "FRQ", "LFO4 FREQ", 0, 166, 0);
TetraNRPNEncoder tetraLfo4ShapeEncoder(58, 53, TETRA_MIDI_CHANNEL, "SHP", "LFO4 SHAPE", 0, 4, 0);
TetraNRPNEncoder tetraLfo4AmtEncoder(59, 54, TETRA_MIDI_CHANNEL, "AMT", "LFO4 AMT", 0, 127, 0);
TetraNRPNEncoder tetraLfo4DestinationEncoder(60, 55, TETRA_MIDI_CHANNEL, "DST", "LFO4 DESTINATION", 0, 43, 0);
TetraNRPNEncoder tetraLfo4KeySyncEncoder(61, 56, TETRA_MIDI_CHANNEL, "SYN", "LFO4 KEY SYNC", 0, 1, 0);
TetraNRPNEncoder tetraEnv3DestinationEncoder(62, 57, TETRA_MIDI_CHANNEL, "DST", "ENV3 DESTINATION", 0, 43, 0);
TetraNRPNEncoder tetraEnv3AmtEncoder(63, 58, TETRA_MIDI_CHANNEL, "AMT", "ENV3 AMT", 0, 254, 0);
TetraNRPNEncoder tetraEnv3VelAmtEncoder(64, 59, TETRA_MIDI_CHANNEL, "VEL", "ENV3 VEL AMT", 0, 127, 0);
TetraNRPNEncoder tetraEnv3DelayEncoder(65, 60, TETRA_MIDI_CHANNEL, "DEL", "ENV3 DELAY", 0, 127, 0);
TetraNRPNEncoder tetraEnv3AttackEncoder(66, 61, TETRA_MIDI_CHANNEL, "ATK", "ENV3 ATTACK", 0, 127, 0);
TetraNRPNEncoder tetraEnv3DecayEncoder(67, 62, TETRA_MIDI_CHANNEL, "DCY", "ENV3 DECAY", 0, 127, 0);
TetraNRPNEncoder tetraEnv3SustainEncoder(68, 63, TETRA_MIDI_CHANNEL, "SUS", "ENV3 SUSTAIN", 0, 127, 0);
TetraNRPNEncoder tetraEnv3ReleaseEncoder(69, 64, TETRA_MIDI_CHANNEL, "REL", "ENV3 RELEASE", 0, 127, 0);
TetraNRPNEncoder tetraMod1SourceEncoder(71, 65, TETRA_MIDI_CHANNEL, "SRC", "MOD1 SOURCE", 0, 20, 0);
TetraNRPNEncoder tetraMod1AmtEncoder(72, 66, TETRA_MIDI_CHANNEL, "AMT", "MOD1 AMT", 0, 254, 0);
TetraNRPNEncoder tetraMod1DestinationEncoder(73, 67, TETRA_MIDI_CHANNEL, "DST", "MOD1 DESTINATION", 0, 47, 0);
TetraNRPNEncoder tetraMod2SourceEncoder(74, 68, TETRA_MIDI_CHANNEL, "SRC", "MOD2 SOURCE", 0, 20, 0);
TetraNRPNEncoder tetraMod2AmtEncoder(75, 69, TETRA_MIDI_CHANNEL, "AMT", "MOD2 AMT", 0, 254, 0);
TetraNRPNEncoder tetraMod2DestinationEncoder(76, 70, TETRA_MIDI_CHANNEL, "DST", "MOD2 DESTINATION", 0, 47, 0);
TetraNRPNEncoder tetraMod3SourceEncoder(77, 71, TETRA_MIDI_CHANNEL, "SRC", "MOD3 SOURCE", 0, 20, 0);
TetraNRPNEncoder tetraMod3AmtEncoder(78, 72, TETRA_MIDI_CHANNEL, "AMT", "MOD3 AMT", 0, 254, 0);
TetraNRPNEncoder tetraMod3DestinationEncoder(79, 73, TETRA_MIDI_CHANNEL, "DST", "MOD3 DESTINATION", 0, 47, 0);
TetraNRPNEncoder tetraMod4SourceEncoder(80, 74, TETRA_MIDI_CHANNEL, "SRC", "MOD4 SOURCE", 0, 20, 0);
TetraNRPNEncoder tetraMod4AmtEncoder(81, 75, TETRA_MIDI_CHANNEL, "AMT", "MOD4 AMT", 0, 254, 0);
TetraNRPNEncoder tetraMod4DestinationEncoder(82, 76, TETRA_MIDI_CHANNEL, "DST", "MOD4 DESTINATION", 0, 47, 0);
//TetraNRPNEncoder tetraSeq1DestinationEncoder(107, 77, TETRA_MIDI_CHANNEL, "DST", "SEQ1 DESTINATION", 0, 47, 0);
//TetraNRPNEncoder tetraSeq2DestinationEncoder(108, 78, TETRA_MIDI_CHANNEL, "DST", "SEQ2 DESTINATION", 0, 47, 0);
//TetraNRPNEncoder tetraSeq3DestinationEncoder(109, 79, TETRA_MIDI_CHANNEL, "DST", "SEQ3 DESTINATION", 0, 47, 0);
//TetraNRPNEncoder tetraSeq4DestinationEncoder(110, 80, TETRA_MIDI_CHANNEL, "DST", "SEQ4 DESTINATION", 0, 47, 0);
TetraNRPNEncoder tetraModWheelAmtEncoder(83, 81, TETRA_MIDI_CHANNEL, "AMT", "MOD WHEEL AMT", 0, 254, 0);
TetraNRPNEncoder tetraModWheelDestEncoder(84, 82, TETRA_MIDI_CHANNEL, "DST", "MOD WHEEL DEST", 0, 47, 0);
TetraNRPNEncoder tetraPressureAmtEncoder(85, 83, TETRA_MIDI_CHANNEL, "AMT", "PRESSURE AMT", 0, 254, 0);
TetraNRPNEncoder tetraPressureDestEncoder(86, 84, TETRA_MIDI_CHANNEL, "DST", "PRESSURE DEST", 0, 47, 0);
TetraNRPNEncoder tetraBreathAmtEncoder(87, 85, TETRA_MIDI_CHANNEL, "AMT", "BREATH AMT", 0, 254, 0);
TetraNRPNEncoder tetraBreathDestEncoder(88, 86, TETRA_MIDI_CHANNEL, "DST", "BREATH DEST", 0, 47, 0);
TetraNRPNEncoder tetraVelocityAmtEncoder(89, 87, TETRA_MIDI_CHANNEL, "AMT", "VELOCITY AMT", 0, 254, 0);
TetraNRPNEncoder tetraVelocityDestEncoder(90, 88, TETRA_MIDI_CHANNEL, "DST", "VELOCITY DEST", 0, 47, 0);
TetraNRPNEncoder tetraFootCtrlAmtEncoder(91, 89, TETRA_MIDI_CHANNEL, "AMT", "FOOT CTRL AMT", 0, 254, 0);
TetraNRPNEncoder tetraFootCtrlDestEncoder(92, 90, TETRA_MIDI_CHANNEL, "DST", "FOOT CTRL DEST", 0, 47, 0);
TetraNRPNEncoder tetraBpmTempoEncoder(101, 91, TETRA_MIDI_CHANNEL, "BPM", "BPM TEMPO", 30, 250, 0);
TetraNRPNEncoder tetraClockDivideEncoder(102, 92, TETRA_MIDI_CHANNEL, "CLK", "CLOCK DIVIDE", 0, 12, 0);
TetraNRPNEncoder tetraPitchBendRangeEncoder(15, 93, TETRA_MIDI_CHANNEL, "PBR", "PITCH BEND RANGE", 0, 12, 0);
TetraNRPNEncoder tetraSeqTriggerEncoder(105, 94, TETRA_MIDI_CHANNEL, "TRG", "SEQ TRIGGER", 0, 4, 0);
TetraNRPNEncoder tetraKeyModeEncoder(94, 95, TETRA_MIDI_CHANNEL, "KMD", "KEY MODE", 0, 5, 0);
TetraNRPNEncoder tetraUnisonModeEncoder(93, 96, TETRA_MIDI_CHANNEL, "UMD", "UNISON MODE", 0, 4, 0);
TetraNRPNEncoder tetraArpeggiatorModeEncoder(103, 97, TETRA_MIDI_CHANNEL, "AMD", "ARPEGGIATOR MODE", 0, 3, 0);
TetraNRPNEncoder tetraEnv3RepeatModeEncoder(70, 98, TETRA_MIDI_CHANNEL, "EMD", "ENV3 REPEAT MODE", 0, 1, 0);
TetraNRPNEncoder tetraUnisonOnOffEncoder(95, 99, TETRA_MIDI_CHANNEL, "UNI", "UNISON ON/OFF", 0, 1, 0);
TetraNRPNEncoder tetraArpeggiatorOIEncoder(104, 100, TETRA_MIDI_CHANNEL, "ARP", "ARPEGGIATOR O-I", 0, 1, 0);
TetraNRPNEncoder tetraGatedSeqOnOffEncoder(106, 101, TETRA_MIDI_CHANNEL, "GAT", "GATED SEQ ON/OFF", 0, 1, 0);
TetraNRPNEncoder tetraAssignParam1Encoder(111, 105, TETRA_MIDI_CHANNEL, "P1", "ASSIGN PARAM 1", 0, 183, 0);
TetraNRPNEncoder tetraAssignParam2Encoder(112, 106, TETRA_MIDI_CHANNEL, "P2", "ASSIGN PARAM 2", 0, 183, 0);
TetraNRPNEncoder tetraAssignParam3Encoder(113, 107, TETRA_MIDI_CHANNEL, "P3", "ASSIGN PARAM 3", 0, 183, 0);
TetraNRPNEncoder tetraAssignParam4Encoder(114, 108, TETRA_MIDI_CHANNEL, "P4", "ASSIGN PARAM 4", 0, 183, 0);
TetraNRPNEncoder tetraFeedbackGainEncoder(19, 110, TETRA_MIDI_CHANNEL, "FBG", "FEEDBACK GAIN", 0, 127, 0);
TetraNRPNEncoder tetraPushItNoteEncoder(96, 111, TETRA_MIDI_CHANNEL, "NOT", "PUSH IT NOTE", 0, 127, 0);
TetraNRPNEncoder tetraPushItVelEncoder(97, 112, TETRA_MIDI_CHANNEL, "VEL", "PUSH IT VEL", 0, 127, 0);
TetraNRPNEncoder tetraPushItModeEncoder(98, 113, TETRA_MIDI_CHANNEL, "MOD", "PUSH IT MODE", 0, 1, 0);
TetraNRPNEncoder tetraSubOsc1LevelEncoder(5, 114, TETRA_MIDI_CHANNEL, "SB1", "SUB OSC1 LEVEL", 0, 127, 0);
TetraNRPNEncoder tetraSubOsc2LevelEncoder(11, 115, TETRA_MIDI_CHANNEL, "SB2", "SUB OSC2 LEVEL", 0, 127, 0);
TetraNRPNEncoder tetraFeedbackVolEncoder(18, 116, TETRA_MIDI_CHANNEL, "FBV", "FEEDBACK VOL", 0, 127, 0);
//TetraNRPNEncoder tetraEditorByteEncoder(117, 117, TETRA_MIDI_CHANNEL, "", "EDITOR BYTE", , , 0);
TetraNRPNEncoder tetraSplitPointEncoder(99, 118, TETRA_MIDI_CHANNEL, "SPL", "SPLIT POINT", 0, 127, 0);
TetraNRPNEncoder tetraKeyboardModeEncoder(100, 119, TETRA_MIDI_CHANNEL, "KMD", "KEYBOARD MODE", 0, 2, 0);
//TetraNRPNEncoder tetraSeqTrk1Step1Encoder(120, 120, TETRA_MIDI_CHANNEL, "A01", "SEQ TRK1 STEP1", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step2Encoder(121, 121, TETRA_MIDI_CHANNEL, "A02", "SEQ TRK1 STEP2", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step3Encoder(122, 122, TETRA_MIDI_CHANNEL, "A03", "SEQ TRK1 STEP3", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step4Encoder(123, 123, TETRA_MIDI_CHANNEL, "A04", "SEQ TRK1 STEP4", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step5Encoder(124, 124, TETRA_MIDI_CHANNEL, "A05", "SEQ TRK1 STEP5", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step6Encoder(125, 125, TETRA_MIDI_CHANNEL, "A06", "SEQ TRK1 STEP6", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step7Encoder(126, 126, TETRA_MIDI_CHANNEL, "A07", "SEQ TRK1 STEP7", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step8Encoder(127, 127, TETRA_MIDI_CHANNEL, "A08", "SEQ TRK1 STEP8", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step9Encoder(128, 128, TETRA_MIDI_CHANNEL, "A09", "SEQ TRK1 STEP9", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step10Encoder(129, 129, TETRA_MIDI_CHANNEL, "A10", "SEQ TRK1 STEP10", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step11Encoder(130, 130, TETRA_MIDI_CHANNEL, "A11", "SEQ TRK1 STEP11", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step12Encoder(131, 131, TETRA_MIDI_CHANNEL, "A12", "SEQ TRK1 STEP12", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step13Encoder(132, 132, TETRA_MIDI_CHANNEL, "A13", "SEQ TRK1 STEP13", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step14Encoder(133, 133, TETRA_MIDI_CHANNEL, "A14", "SEQ TRK1 STEP14", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step15Encoder(134, 134, TETRA_MIDI_CHANNEL, "A15", "SEQ TRK1 STEP15", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk1Step16Encoder(135, 135, TETRA_MIDI_CHANNEL, "A16", "SEQ TRK1 STEP16", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step1Encoder(136, 136, TETRA_MIDI_CHANNEL, "B01", "SEQ TRK2 STEP1", 0, 126, 0);
//TetraNRPNEncoder tetraSeqTrk2Step2Encoder(137, 137, TETRA_MIDI_CHANNEL, "B02", "SEQ TRK2 STEP2", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step3Encoder(138, 138, TETRA_MIDI_CHANNEL, "B03", "SEQ TRK2 STEP3", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step4Encoder(139, 139, TETRA_MIDI_CHANNEL, "B04", "SEQ TRK2 STEP4", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step5Encoder(140, 140, TETRA_MIDI_CHANNEL, "B05", "SEQ TRK2 STEP5", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step6Encoder(141, 141, TETRA_MIDI_CHANNEL, "B06", "SEQ TRK2 STEP6", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step7Encoder(142, 142, TETRA_MIDI_CHANNEL, "B07", "SEQ TRK2 STEP7", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step8Encoder(143, 143, TETRA_MIDI_CHANNEL, "B08", "SEQ TRK2 STEP8", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step9Encoder(144, 144, TETRA_MIDI_CHANNEL, "B09", "SEQ TRK2 STEP9", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step10Encoder(145, 145, TETRA_MIDI_CHANNEL, "B10", "SEQ TRK2 STEP10", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step11Encoder(146, 146, TETRA_MIDI_CHANNEL, "B11", "SEQ TRK2 STEP11", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step12Encoder(147, 147, TETRA_MIDI_CHANNEL, "B12", "SEQ TRK2 STEP12", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step13Encoder(148, 148, TETRA_MIDI_CHANNEL, "B13", "SEQ TRK2 STEP13", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step14Encoder(149, 149, TETRA_MIDI_CHANNEL, "B14", "SEQ TRK2 STEP14", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step15Encoder(150, 150, TETRA_MIDI_CHANNEL, "B15", "SEQ TRK2 STEP15", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk2Step16Encoder(151, 151, TETRA_MIDI_CHANNEL, "B16", "SEQ TRK2 STEP16", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step1Encoder(152, 152, TETRA_MIDI_CHANNEL, "C01", "SEQ TRK3 STEP1", 0, 126, 0);
//TetraNRPNEncoder tetraSeqTrk3Step2Encoder(153, 153, TETRA_MIDI_CHANNEL, "C02", "SEQ TRK3 STEP2", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step3Encoder(154, 154, TETRA_MIDI_CHANNEL, "C03", "SEQ TRK3 STEP3", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step4Encoder(155, 155, TETRA_MIDI_CHANNEL, "C04", "SEQ TRK3 STEP4", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step5Encoder(156, 156, TETRA_MIDI_CHANNEL, "C05", "SEQ TRK3 STEP5", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step6Encoder(157, 157, TETRA_MIDI_CHANNEL, "C06", "SEQ TRK3 STEP6", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step7Encoder(158, 158, TETRA_MIDI_CHANNEL, "C07", "SEQ TRK3 STEP7", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step8Encoder(159, 159, TETRA_MIDI_CHANNEL, "C08", "SEQ TRK3 STEP8", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step9Encoder(160, 160, TETRA_MIDI_CHANNEL, "C09", "SEQ TRK3 STEP9", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step10Encoder(161, 161, TETRA_MIDI_CHANNEL, "C10", "SEQ TRK3 STEP10", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step11Encoder(162, 162, TETRA_MIDI_CHANNEL, "C11", "SEQ TRK3 STEP11", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step12Encoder(163, 163, TETRA_MIDI_CHANNEL, "C12", "SEQ TRK3 STEP12", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step13Encoder(164, 164, TETRA_MIDI_CHANNEL, "C13", "SEQ TRK3 STEP13", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step14Encoder(165, 165, TETRA_MIDI_CHANNEL, "C14", "SEQ TRK3 STEP14", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step15Encoder(166, 166, TETRA_MIDI_CHANNEL, "C15", "SEQ TRK3 STEP15", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk3Step16Encoder(167, 167, TETRA_MIDI_CHANNEL, "C16", "SEQ TRK3 STEP16", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step1Encoder(168, 168, TETRA_MIDI_CHANNEL, "D01", "SEQ TRK4 STEP1", 0, 126, 0);
//TetraNRPNEncoder tetraSeqTrk4Step2Encoder(169, 169, TETRA_MIDI_CHANNEL, "D02", "SEQ TRK4 STEP2", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step3Encoder(170, 170, TETRA_MIDI_CHANNEL, "D03", "SEQ TRK4 STEP3", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step4Encoder(171, 171, TETRA_MIDI_CHANNEL, "D04", "SEQ TRK4 STEP4", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step5Encoder(172, 172, TETRA_MIDI_CHANNEL, "D05", "SEQ TRK4 STEP5", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step6Encoder(173, 173, TETRA_MIDI_CHANNEL, "D06", "SEQ TRK4 STEP6", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step7Encoder(174, 174, TETRA_MIDI_CHANNEL, "D07", "SEQ TRK4 STEP7", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step8Encoder(175, 175, TETRA_MIDI_CHANNEL, "D08", "SEQ TRK4 STEP8", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step9Encoder(176, 176, TETRA_MIDI_CHANNEL, "D09", "SEQ TRK4 STEP9", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step10Encoder(177, 177, TETRA_MIDI_CHANNEL, "D10", "SEQ TRK4 STEP10", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step11Encoder(178, 178, TETRA_MIDI_CHANNEL, "D11", "SEQ TRK4 STEP11", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step12Encoder(179, 179, TETRA_MIDI_CHANNEL, "D12", "SEQ TRK4 STEP12", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step13Encoder(180, 180, TETRA_MIDI_CHANNEL, "D13", "SEQ TRK4 STEP13", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step14Encoder(181, 181, TETRA_MIDI_CHANNEL, "D14", "SEQ TRK4 STEP14", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step15Encoder(182, 182, TETRA_MIDI_CHANNEL, "D15", "SEQ TRK4 STEP15", 0, 127, 0);
//TetraNRPNEncoder tetraSeqTrk4Step16Encoder(183, 183, TETRA_MIDI_CHANNEL, "D16", "SEQ TRK4 STEP16", 0, 127, 0);
