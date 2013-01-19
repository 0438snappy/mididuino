/* Copyright (c) 2009 - http://ruinwesen.com/ */

#ifndef RECORDING_ENCODER_H__
#define RECORDING_ENCODER_H__

/**
 * \addtogroup GUI
 *
 * @{
 *
 * \addtogroup gui_encoders 
 *
 * @{
 *
 * \addtogroup gui_recording_encoder Recording Encoder Class
 *
 * @{
 *
 * \file
 * Recording Encoder implementation
 **/
 
 /*
 *  NOTE 19/01/2013:  Didn't really find the REV/PENDULUM/ONESHOT functionality that useful so have commented it out for now.  May come back to it later.
 */  
 /*  
#define REC_ENC_PLAYBACK_FORWARD 0
#define REC_ENC_PLAYBACK_REVERSE 1
#define REC_ENC_PLAYBACK_PENDULUM 2
#define REC_ENC_PLAYBACK_MODE_CNT 3 
*/

/**
 * Create a recording encoder recording N values. The RecordingEncoder
 * is actually a frontend simulating an encoder, delegating most calls
 * to the actual encoder. However, it can be used to record movements
 * of this encoder and play them back.
 **/
template <int N>
class RecordingEncoder : public Encoder {
  /**
   * \addtogroup gui_recording_encoder
   * @{
   **/
	
public:
  Encoder *realEnc;
  int value[N];
  bool recording;
  bool recordChanged;
  bool playing;
  int currentPos;
  int recordingLength;
  bool reversePlayback;
  bool loopPlayback;
  bool pendulumPlayback;
  int playbackMode;

  /** Create a recording encoder wrapper for the actual encoder _realEnc. **/
  RecordingEncoder(Encoder *_realEnc = NULL) {
    initRecordingEncoder(_realEnc);
  }
  
  void initRecordingEncoder(Encoder *_realEnc);

  void startRecording();
  void stopRecording();
  void clearRecording();
  void playback(uint8_t pos);
  void halveRecordingLength();
  void doubleRecordingLength();
  void setRecordingLength(int _recLength);
  
  /*
  *  NOTE 19/01/2013:  Didn't really find the REV/PENDULUM/ONESHOT functionality that useful so have commented it out for now.  May come back to it later.
  */  
  /*   
  void incrementPlaybackMode();
  void toggleLoopPlayback();
  void updatePlaybackModeParams();
  */

  virtual char *getName() {
    return realEnc->getName();
  }

  virtual void setName(char *_name) {
    realEnc->setName(_name);
  }
  virtual int update(encoder_t *enc);
  virtual void checkHandle() {
    realEnc->checkHandle();
  }
  virtual bool hasChanged() {
    return realEnc->hasChanged();
  }

  virtual int getValue() {
    return realEnc->getValue();
  }
  virtual int getOldValue() {
    return realEnc->getOldValue();
  }
  virtual void setValue(int _value, bool handle = false) {
    realEnc->setValue(_value, handle);
    redisplay = realEnc->redisplay;
  }

  virtual void displayAt(int i) {
    realEnc->displayAt(i);
  }

  /* @} */
};

/* RecordingEncoder */
template <int N>
void RecordingEncoder<N>::initRecordingEncoder(Encoder *_realEnc) {
  realEnc = _realEnc;
  recording = false;
  playing = true;
  clearRecording();
  currentPos = 0;
  recordingLength = N;
  
  /*
  *  NOTE 19/01/2013:  Didn't really find the REV/PENDULUM/ONESHOT functionality that useful so have commented it out for now.  May come back to it later.
  */  
  /* 
  reversePlayback = false;
  loopPlayback = true;
  pendulumPlayback = false;  
  playbackMode = REC_ENC_PLAYBACK_FORWARD;
  */
}

template <int N>
void RecordingEncoder<N>::startRecording() {
  recordChanged = false;
  recording = true;
}

template <int N>
void RecordingEncoder<N>::stopRecording() {
  recordChanged = false;
  recording = false;
}

template <int N>
void RecordingEncoder<N>::clearRecording() {
  for (int i = 0; i < N; i++) {
    value[i] = -1;
  }  
  playing = false;
}

template <int N>
int RecordingEncoder<N>::update(encoder_t *enc) {
  USE_LOCK();
  //  SET_LOCK();

  cur = realEnc->update(enc);
  redisplay = realEnc->redisplay;

  if (recording) {
    if (!recordChanged) {
      if (enc->normal != 0 || enc->button != 0) {
        recordChanged = true;
      }
    }
    if (recordChanged) {
      int pos = currentPos;
      value[pos] = cur;
      playing = true;
    }
  }
  // CLEAR_LOCK();
  return cur;
}  

template <int N>
void RecordingEncoder<N>::playback(uint8_t pos) {
  if (!playing){
    return;
  }

  currentPos = (pos % recordingLength);
  
  /*
  *  NOTE 19/01/2013:  Didn't really find the REV/PENDULUM/ONESHOT functionality that useful so have commented it out for now.  May come back to it later.
  */
  /*  
  uint8_t endPoint = recordingLength - 1;
    
  // Reverse Playback
  if (encoder->reversePlayback){
      currentPos = encoder->recordingLength - currentPos - 1; 
      endPoint = 0;
  } 
  
  if (currentPos == endPoint){
      // Pendulum Playback
      if (encoder->pendulumPlayback){
          encoder->reversePlayback = !encoder->reversePlayback;
      }
      // One-Shot Playback
      if (!encoder->loopPlayback){
          encoder->playing = false;
      }
  } 
  */     
  
  if (value[currentPos] != -1) {
    if (!(recording && recordChanged)) {
      realEnc->setValue(value[currentPos], true);
      redisplay = realEnc->redisplay;
    }
    // check if real encoder has change value XXX
  }
}

/*
*  NOTE 19/01/2013:  Didn't really find the REV/PENDULUM/ONESHOT functionality that useful so have commented it out for now.  May come back to it later.
*/  
/*  
template <int N>
void RecordingEncoder<N>::incrementPlaybackMode(){
    playbackMode = (playbackMode + 1) % REC_ENC_PLAYBACK_MODE_CNT;
    updatePlaybackModeParams(); 
}

template <int N>
void RecordingEncoder<N>::updatePlaybackModeParams(){
    switch(playbackMode){
        case REC_ENC_PLAYBACK_REVERSE:
            reversePlayback = true;
            pendulumPlayback = false;
            break;
                       
        case REC_ENC_PLAYBACK_PENDULUM:
        	reversePlayback = false;
            pendulumPlayback = true;
            break;
                    
        // REC_ENC_PLAYBACK_FORWARD
        default:
            reversePlayback = false;
            pendulumPlayback = false;
            break;
    }
    if (!playing){
        playing = true;
    }
}

template <int N>
void RecordingEncoder<N>::toggleLoopPlayback(){
    loopPlayback = !loopPlayback;
    if (!playing){
        playing = true;
    }
}
*/

template <int N>
void RecordingEncoder<N>::halveRecordingLength(){
	recordingLength = MAX((recordingLength/2), 2);
}

template <int N>
void RecordingEncoder<N>::doubleRecordingLength(){
	recordingLength = MIN((recordingLength*2), N);
}

template <int N>
void RecordingEncoder<N>::setRecordingLength(int _recLength){
	recordingLength = constrain(_recLength, 2, N);
}


/* @} @} @} */

#endif /* RECORDING_ENCODER_H__ */
