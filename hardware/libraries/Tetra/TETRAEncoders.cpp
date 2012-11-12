#include "TETRAEncoders.h"
#include "Platform.h"
#include "Encoders.hh"
#include "MidiTools.h"
#include "Midi.h"

#ifndef HOST_MIDIDUINO

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

