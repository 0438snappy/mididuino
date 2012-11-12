/*
 * MidiCtrl - Encoder for MNM sysex messages
 *
 */

#ifndef TETRA_DATA_ENCODER_H__
#define TETRA_DATA_ENCODER_H__

#include "PlatformConfig.h"
//#include "DSIDataEncoder.hh"
#include "DataEncoder.hh"

/**
 * \addtogroup DSI
 *
 * @{
 *
 * \addtogroup dsi_tetraencoder TETRA Encoders
 *
 * @{
 *
 * \file
 * DSI Tetra encoding and decoding routines
 **/


/**
 * \addtogroup dsi_tetra_sysex_to_data_encoder DSI Tetra Sysex to Data Encoder
 *
 * @{
 *
 **/

/** Class to encode 7-bit and compressed sysex data to normal 8-bit data. **/
/*
class TETRASysexToDataEncoder : public DSISysexToDataEncoder {
public:
  uint8_t repeat;
  uint16_t totalCnt;
  
  TETRASysexToDataEncoder(DATA_ENCODER_INIT(uint8_t *_data = NULL, uint16_t _maxLen = 0)) {
    init(DATA_ENCODER_INIT(_data, _maxLen));
  }

  virtual void init(DATA_ENCODER_INIT(uint8_t *_data, uint16_t _maxLen));
  virtual DATA_ENCODER_RETURN_TYPE pack8(uint8_t inb);
  DATA_ENCODER_RETURN_TYPE unpack8Bit();
  virtual uint16_t finish();
};
*/

/** @} **/

/**
 * \addtogroup dsi_tetra_sysex_decoder Tetra Sysex Decoder
 *
 * @{
 *
 **/

/** Class to decode 7-bit encoded and compressed sysex data. **/
class TETRASysexDecoder : public DataDecoder {
public:
  uint8_t cnt7;
  uint8_t bits;
  uint8_t tmpData[7];
  uint16_t cnt;
  uint8_t repeatCount;
  uint8_t repeatByte;
  uint16_t totalCnt;
	
public:
  TETRASysexDecoder(DATA_ENCODER_INIT(uint8_t *_data = NULL, uint16_t _maxLen = 0)) {
    init(DATA_ENCODER_INIT(_data, _maxLen));
  }
	
  virtual void init(DATA_ENCODER_INIT(uint8_t *_data, uint16_t _maxLen));
  virtual DATA_ENCODER_RETURN_TYPE get8(uint8_t *c);
  virtual DATA_ENCODER_RETURN_TYPE getNextByte(uint8_t *c);
};

#endif /* TETRA_DATA_ENCODER_H__ */
