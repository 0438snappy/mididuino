//   MNM Mono/Poly Sketch 

// Note - this sketch assumes that you have:
//    MNM set up in "mono" mode with a seperate midi channel allocated for each of the 6 mnm tracks.  i.e. midi channel span = 6 (i think this is how it's configured in the MNM global settings?)
//    MNM Midi Out ==> Minicommand Midi In 1
//    MNM Midi In ==> Minicommand Midi Out
//    Are sending the midi notes to be "dispatched" / forwarded to Minicommand Midi In 2.  

// General Notes - Firmware has two configuration pages:  
// 1.0  Config Page 1
// 1.01 Encoder "O-|" - this is the on/off switch for the sketch
// 1.02 Encoder "SPR" - paramter spread for Poly track sync mode.  E.g. set SPR to "2", with 3 poly tracks.  Setting Poly Track #1 FLTW to value 64 will set Poly Track #1 FLTW to 66 and Poly Track #3 FLTW to 68.  etc...
// 1.03 Encoder "PSN" - turn Parameter sync ON or OFF
// 1.03.01 When "PSN" is switched "ON", if you turn an encoder on the MNM UI for one of the "poly" tracks, the parameter change will be forwarded to all of the other "poly" tracks
// 1.04 Encoder "MSN" - turn Machine syncing for Poly tracks on/off.  
// 1.04.01 When "MSN" is switched "ON", the machine on the first MNM poly track will be copied over to all of the other MNM Poly tracks.  It's still a little clunky and i'll try and get it working a bit better as it doesn't detect if you edit the kit and change the machine.

// 2.0  Config Page 2
// 2.01 Encoder "O-|" - this is the on/off switch for the sketch
// 2.02 Encoder "ST" - select the Poly "start" track
// 2.02.01 Changing the value for the Poly "start" track will reload the kit and then copy the MNM machine from the specified "start" track to all tracks until the "end" track
// 2.03 Encoder "END" - select the Poly "end" track
// 2.03.01 Changing the value for the Poly "end" track will reload the kit and then copy the MNM machine from the specified "start" track to all tracks until the "end" track



