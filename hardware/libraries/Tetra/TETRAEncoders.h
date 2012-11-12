#ifndef TETRA_ENCODERS_H__
#define TETRA_ENCODERS_H__

#include <GUI.h>
#include <TETRA.h>

#ifndef HOST_MIDIDUINO

/** Encoder handling function to send a NRPN value (enc has to be of class NRPNEncoder). **/
void NRPNEncoderHandle(Encoder *enc);

/**
 * Generic NRPN Encoder Class
 **/
class NRPNEncoder : public RangeEncoder {
	
public:
  /** The NRPN number used when the NRPN message is sent. **/
  uint8_t nrpn;
  /** The MIDI channel number (from 0 to 15) to use when sending the NRPN message. **/
  uint8_t channel;
    
virtual uint8_t getNRPN() {
    return nrpn;
  }
  virtual uint8_t getChannel() {
    return channel;
  }
  
  virtual void setNrpn(uint8_t _nrpn){
        nrpn = _nrpn;
  }    
  
  virtual void setChannel(uint8_t _channel){
        channel = _channel;
  }      
  
  virtual void init() {
    nrpn = 0;
    channel = 0;
    setName("___");
    clear();
  }  
  
  /** Create a NRPN encoder sending NRPN messages with number _nrpn on _channel. **/
  NRPNEncoder(uint8_t _nrpn = 0, uint8_t _channel = 0, const char *_name = NULL, int _min = 0, int _max = 127, int init = 0) :
    RangeEncoder(_max, _min, _name, init, NRPNEncoderHandle) {
    nrpn = _nrpn;
    channel = _channel;
  }

};


/**
 * NRPN Encoder Class customised for Tetra
 **/
class TetraNRPNEncoder : public NRPNEncoder {  
  	
public:
  /** Encoder Long name. **/
  const char *longName;
  uint8_t paramNumber;

  /** Set the encoder long name (max 16 characters). **/
  virtual void setLongName(const char *_longName){
        longName = _longName;
  }  
  
  virtual void init() {
    paramNumber = 255;
    setLongName("------");
    nrpn = 0;
    channel = 0;
    setName("___");
    clear();
  }    
  
  /** Set the encoder long name (max 16 characters). **/
  virtual void setLongName(const char *_groupName, const char *_paramName){
  		uint8_t cnt = 16;
		  while (cnt && *_groupName) {
		    *((uint8_t *)longName++) = *((uint8_t *)_groupName++);
		    cnt--;
		  }
		  /*
		  if (cnt > 1) {
		    cnt--;
		    *((uint8_t *)longName++) = ' ';
		  }
		  while (cnt && *_paramName) {
		    *((uint8_t *)longName++) = *((uint8_t *)_paramName++);
		    cnt--;
		  }
		  if (cnt > 0){
		    *((uint8_t *)longName++) = 0;
		  }
		  */
  }    
  
  virtual void displayAt(int i){
          
      if (hasChanged() || isPressed) {
        // Flash Long Encoder Name on GUI.LINE1
        GUI.setLine(GUI.LINE1);
        GUI.flash_string_fill(longName);
      }

      // Display Encoder value on GUI.LINE2        
      GUI.setLine(GUI.LINE2);
      GUI.put_value(i, getValue());
      redisplay = false;      
  }  

  /** Create a NRPN encoder sending NRPN messages with number _nrpn on _channel. **/
  TetraNRPNEncoder(uint8_t _paramNumber = 0, uint8_t _nrpn = 0, uint8_t _channel = 0, const char *_name = NULL, const char *_longName = NULL, int _min = 0, int _max = 127, int init = 0) :
    NRPNEncoder(_nrpn, _channel, _name, _min, _max, init) {
    setLongName(_longName);
    paramNumber = _paramNumber;
  }

};



#endif

#endif /* TETRA_ENCODERS_H__ */
