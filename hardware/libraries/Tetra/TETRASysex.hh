/*
 * MidiCtrl - TETRA sysex listeners
 *
 */


#ifndef TETRA_SYSEX_H__
#define TETRA_SYSEX_H__

#include "PlatformConfig.h"
#include "Midi.h"
#include "MidiSysex.hh"
#include "Vector.hh"
//#include "DSI.hh"
//#include "Circular.hh"
#include "TETRADataEncoder.hh"

typedef void(TETRACallback::*tetra_callback_ptr_t)();

class TETRASysexListenerClass : public MidiSysexListenerClass {
public:
  CallbackVector<TETRACallback,8> onGlobalMessageCallbacks;
  CallbackVector<TETRACallback,8> onProgramEditBufferMessageCallbacks;
  
  bool isTETRAMessage;
  uint8_t msgType;
  
  TETRASysexListenerClass() : MidiSysexListenerClass() {
    ids[0] = DSI_SYSEX_ID;
    ids[1] = TETRA_SYSEX_ID;
  }
  
  virtual void start();
  virtual void handleByte(uint8_t byte);
  virtual void end();

  void setup();

  void addOnGlobalMessageCallback(TETRACallback *obj, tetra_callback_ptr_t func) {
    onGlobalMessageCallbacks.add(obj, func);
  }
  void removeOnGlobalMessageCallback(TETRACallback *obj, tetra_callback_ptr_t func) {
    onGlobalMessageCallbacks.remove(obj, func);
  }
  void removeOnGlobalMessageCallback(TETRACallback *obj) {
    onGlobalMessageCallbacks.remove(obj);
  }
  
  void addOnProgramEditBufferMessageCallback(TETRACallback *obj, tetra_callback_ptr_t func) {
    onProgramEditBufferMessageCallbacks.add(obj, func);
  }
  void removeOnProgramEditBufferMessageCallback(TETRACallback *obj, tetra_callback_ptr_t func) {
    onProgramEditBufferMessageCallbacks.remove(obj, func);
  }
  void removeOnProgramEditBufferMessageCallback(TETRACallback *obj) {
    onProgramEditBufferMessageCallbacks.remove(obj);
  }  
  
  
};

extern TETRASysexListenerClass TETRASysexListener;

#endif /* TETRA_SYSEX_H__ */
