/* Copyright (c) 2009 - http://ruinwesen.com/ */

//#include "DSI.hh"
//#include "DSIDataEncoder.hh"
#include "TETRADataEncoder.hh"

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
 * DSI TETRA encoding and decoding routines
 **/

/*
void TETRASysexToDataEncoder::init(DATA_ENCODER_INIT(uint8_t *_data, uint16_t _maxLen)) {
  DSISysexToDataEncoder::init(DATA_ENCODER_INIT(_data, _maxLen));
  repeat = 0;
  totalCnt = 0;
}

DATA_ENCODER_RETURN_TYPE TETRASysexToDataEncoder::pack8(uint8_t inb) {
  //  printf("pack: %x\n", inb);
  totalCnt++;
  if ((cnt % 8) == 0) {
    bits = inb;
  } else {
    bits <<= 1;
    tmpData[cnt7++] = inb | (bits & 0x80);
  }
  cnt++;

  if (cnt7 == 7) {
    DATA_ENCODER_CHECK(unpack8Bit());
  }

  DATA_ENCODER_TRUE();
}

DATA_ENCODER_RETURN_TYPE TETRASysexToDataEncoder::unpack8Bit() {
  for (uint8_t i = 0; i < cnt7; i++) {
    //    printf("tmpdata[%d]: %x\n", i, tmpData[i]);
    if (repeat == 0) {
      if (tmpData[i] & 0x80) {
        repeat = tmpData[i] & 0x7F;
      } else {
#ifdef DATA_ENCODER_CHECKING
        DATA_ENCODER_CHECK(retLen <= maxLen);
#endif
        *(ptr++) = tmpData[i];
        retLen++;
      }
    } else {
      for (uint8_t j = 0; j < repeat; j++) {
#ifdef DATA_ENCODER_CHECKING
        DATA_ENCODER_CHECK(retLen <= maxLen);
#endif
        *(ptr++) = tmpData[i];
        retLen++;
      }
      repeat = 0;
    }
  }
  cnt7 = 0;

  DATA_ENCODER_TRUE();
}

uint16_t TETRASysexToDataEncoder::finish() {
#ifdef DATA_ENCODER_CHECKING
  //  printf("cnt7: %d\n", cnt7);
  if (!unpack8Bit()) {
    return 0;
  }
#else
  unpack8Bit();
#endif
  return retLen;
	
}
*/
/***************************************************************************
 *
 * Tetra Sysex Decoder
 *
 ***************************************************************************/
void TETRASysexDecoder::init(DATA_ENCODER_INIT(uint8_t *_data, uint16_t _maxLen)) {
  DataDecoder::init(DATA_ENCODER_INIT(_data, _maxLen));
  cnt7 = 0;
  cnt = 0;
  repeatCount = 0;
  repeatByte = 0;
  totalCnt = 0;
}

DATA_ENCODER_RETURN_TYPE TETRASysexDecoder::getNextByte(uint8_t *c) {
  if ((cnt % 8) == 0) {
    bits = *(ptr++);
    cnt++;
  }
  bits <<= 1;
  *c = *(ptr++) | (bits & 0x80);
  cnt++;

  DATA_ENCODER_TRUE();
}

DATA_ENCODER_RETURN_TYPE TETRASysexDecoder::get8(uint8_t *c) {
  uint8_t byte;

  totalCnt++;

 again:
  if (repeatCount > 0) {
    repeatCount--;
    *c = repeatByte;
    DATA_ENCODER_TRUE();
  }

  DATA_ENCODER_CHECK(getNextByte(&byte));
  
//  printf("%x (%c)\n", byte, byte);
/*
  if (IS_BIT_SET(byte, 7)) {
    repeatCount = byte & 0x7F;
    DATA_ENCODER_CHECK(getNextByte(&repeatByte));
//    printf("%x (%c)\n", repeatByte, repeatByte);    
    goto again;
  } else {
    *c = byte;
    DATA_ENCODER_TRUE();
  }
*/
   *c = byte;
    DATA_ENCODER_TRUE();  
  
}

