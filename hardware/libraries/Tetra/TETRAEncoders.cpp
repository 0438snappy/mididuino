#include "TETRAEncoders.h"
#include "Platform.h"
#include "Encoders.hh"
#include "MidiTools.h"
#include "Midi.h"

#ifndef HOST_MIDIDUINO

void TetraNRPNEncoder::initTETRAEncoder(uint8_t _paramNumber = 0xFF){

  // Set param number
  paramNumber = _paramNumber;
  
  // Set name
  PGM_P name= NULL;     
  name = TETRA.getParameterName(paramNumber);
  char myName[4];
  m_strncpy_p(myName, name, 4);
  setName(myName);   
  
  // Set longname as encoder: groupname + ' ' + name
  PGM_P groupName= NULL;     
  groupName = TETRA.getParameterGroupName(paramNumber);
  char myLongName[16];
  m_strncat_p(myLongName,groupName, name, 16); 
  setLongName(myLongName);    
  
  // Set min
  min = TETRA.getParameterMin(paramNumber);
  
  // Set max
  max = TETRA.getParameterMax(paramNumber);

  // Set nrpn
  nrpn = TETRA.getParameterNrpn(paramNumber);

  // Set Channel
  channel = TETRA.midiChannel;   
  
  // Set Value
  if (TETRA.loadedProgram) {
      setValue(TETRA.program.parameters[paramNumber]);
  }        
  
  // Refresh gui
  GUI.redisplay();
}

void TetraNRPNEncoder::setLongName(const char *_longName) {
  if (_longName != NULL){
    m_strncpy_fill(longName, _longName, 16);
   }
   longName[15] = '\0';
}


/***************************************************************************
 *
 * Encoder handlers
 *
 ***************************************************************************/
 
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



#endif /* HOST_MIDIDUINO */

