class MDFXSketch : 
public Sketch, public MDCallback {
public:
  MDFXEncoder flfEncoder, flwEncoder, fbEncoder, levEncoder;
  AutoMDFXEncoderPage delayPage;

  MDFXEncoder timEncoder, frqEncoder, modEncoder;  
  AutoMDFXEncoderPage delayPage2;
 
  MDFXEncoder reverbDecEncoder, reverbHpEncoder, reverbLpEncoder, reverbLevEncoder;  
  AutoMDFXEncoderPage reverbPage;  

  MDFXEncoder eqPeakQEncoder, eqPeakFreqEncoder, eqPeakGainEncoder, eqHighGainEncoder;  
  AutoMDFXEncoderPage eqPage;  

  SwitchPage switchPage;

  bool muted ;

  void getName(char *n1, char *n2) {
    m_strncpy_p(n1, PSTR("MD  "), 5);
    m_strncpy_p(n2, PSTR("LIV "), 5);
  }

  void setupPages() {
    flfEncoder.initMDFXEncoder(MD_ECHO_FLTF, MD_FX_ECHO, "FLF", 0);
    flwEncoder.initMDFXEncoder(MD_ECHO_FLTW, MD_FX_ECHO, "FLW", 127);
    fbEncoder.initMDFXEncoder( MD_ECHO_FB,   MD_FX_ECHO, "FB",  32);
    levEncoder.initMDFXEncoder(MD_ECHO_LEV,  MD_FX_ECHO, "LEV", 100);
    delayPage.setShortName("DL1");
    delayPage.setup(&flfEncoder, &flwEncoder, &fbEncoder, &levEncoder);    

    timEncoder.initMDFXEncoder(MD_ECHO_TIME, MD_FX_ECHO, "TIM", 24);
    frqEncoder.initMDFXEncoder(MD_ECHO_MFRQ, MD_FX_ECHO, "FRQ", 0);
    modEncoder.initMDFXEncoder(MD_ECHO_MOD,  MD_FX_ECHO, "MOD", 0);
    delayPage2.setShortName("DL2");
    delayPage2.setup(&timEncoder, &frqEncoder, &modEncoder, &fbEncoder);    
    
    eqPeakFreqEncoder.initMDFXEncoder(MD_EQ_PF,  MD_FX_EQ, "PF", 63);
    eqPeakGainEncoder.initMDFXEncoder(MD_EQ_PG,  MD_FX_EQ, "PG", 63);
    eqPeakQEncoder.initMDFXEncoder(MD_EQ_PQ, MD_FX_EQ, "PQ", 63);
    eqHighGainEncoder.initMDFXEncoder(MD_EQ_HG, MD_FX_EQ, "HI", 63);
    eqPage.setShortName("EQ");       
    eqPage.setup(&eqPeakFreqEncoder, &eqPeakGainEncoder, &eqPeakQEncoder, &eqHighGainEncoder);        

    reverbDecEncoder.initMDFXEncoder(MD_REV_DEC, MD_FX_REV, "DEC", 63);
    reverbHpEncoder.initMDFXEncoder(MD_REV_HP, MD_FX_REV, "HP", 0);
    reverbLpEncoder.initMDFXEncoder(MD_REV_LP,  MD_FX_REV, "LP", 127);
    reverbLevEncoder.initMDFXEncoder(MD_REV_LEV,  MD_FX_REV, "LEV", 100);
    reverbPage.setShortName("REV");       
    reverbPage.setup(&reverbDecEncoder, &reverbHpEncoder, &reverbLpEncoder, &reverbLevEncoder);        
    
    switchPage.initPages(&delayPage, &delayPage2, &reverbPage, &eqPage);
    switchPage.parent = this;
  }

  virtual void setup() {
    muted = false;
    setupPages();
    MDTask.addOnKitChangeCallback(this, (md_callback_ptr_t)&MDFXSketch::onKitChanged);
  }

  virtual void show() {
      if (currentPage() == NULL){
          setPage(&delayPage);
      }
  }

  virtual void hide() {
      if (currentPage() == &switchPage) {
	popPage(&switchPage);
      }
  }

  virtual void mute(bool pressed) {
    if (pressed) {
      muted = !muted;
      delayPage.muted = muted;
      delayPage2.muted = muted;
      eqPage.muted = muted;      
      reverbPage.muted = muted;
      if (muted) {
	  GUI.flash_strings_fill("MD FX", "MUTED");
      } else {
	  GUI.flash_strings_fill("MD FX", "UNMUTED");
      }
    }
  }

  virtual bool handleEvent(gui_event_t *event) {
    if (EVENT_PRESSED(event, Buttons.BUTTON1)) {
      pushPage(&switchPage);
    } else if (EVENT_RELEASED(event, Buttons.BUTTON1)) {
      popPage(&switchPage);
    }        
    return true;
  }

  virtual Page *getPage(uint8_t i) {
    if (i == 0) {
      return &delayPage;
    } else if (i == 1) {
      return &delayPage2;
    } else if (i == 2) {
      return &eqPage;
    } else if (i == 3) {
      return &reverbPage;
    } else {
      return NULL;
    }
  }
  
  void onKitChanged() {    
    for (int i = 0; i < 4; i++) {
      ((MDFXEncoder *)delayPage.realEncoders[i])->loadFromKit();
      ((MDFXEncoder *)delayPage2.realEncoders[i])->loadFromKit();
      ((MDFXEncoder *)eqPage.realEncoders[i])->loadFromKit(); 
      ((MDFXEncoder *)reverbPage.realEncoders[i])->loadFromKit();       
    }
  }  
};


