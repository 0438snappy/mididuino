class MDLivePatchSketch : 
public Sketch, public MDCallback {
public:
  MDFXEncoder flfEncoder, flwEncoder, fbEncoder, levEncoder;
  AutoMDFXEncoderPage page;

  MDFXEncoder timEncoder, frqEncoder, modEncoder;  
  AutoMDFXEncoderPage page2;
  
  MDFXEncoder eqLowGainEncoder, eqHighGainEncoder, eqPeakFreqEncoder, eqPeakGainEncoder;  
  AutoMDFXEncoderPage page3;  
 
  AutoCCEncoderPage autoCCPage;
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
    page.setShortName("DL1");
//    page.setEncoders(&flfEncoder, &flwEncoder, &fbEncoder, &levEncoder);
    page.setup(flfEncoder, flwEncoder, fbEncoder, levEncoder);    

    timEncoder.initMDFXEncoder(MD_ECHO_TIME, MD_FX_ECHO, "TIM", 24);
    frqEncoder.initMDFXEncoder(MD_ECHO_MFRQ, MD_FX_ECHO, "FRQ", 0);
    modEncoder.initMDFXEncoder(MD_ECHO_MOD,  MD_FX_ECHO, "MOD", 0);
    page2.setShortName("DL2");
//    page2.setEncoders(&timEncoder, &frqEncoder, &modEncoder, &fbEncoder);
    page2.setup(timEncoder, frqEncoder, modEncoder, fbEncoder);    
    
    eqLowGainEncoder.initMDFXEncoder(MD_EQ_LG, MD_FX_EQ, "LOW", 63);
    eqHighGainEncoder.initMDFXEncoder(MD_EQ_HG, MD_FX_EQ, "HI", 63);
    eqPeakFreqEncoder.initMDFXEncoder(MD_EQ_PF,  MD_FX_EQ, "PF", 63);
    eqPeakGainEncoder.initMDFXEncoder(MD_EQ_PG,  MD_FX_EQ, "PG", 63);
    page3.setShortName("EQ");       
//    page3.setEncoders(&eqLowGainEncoder, &eqPeakFreqEncoder, &eqPeakGainEncoder, &eqHighGainEncoder);    
    page3.setup(eqLowGainEncoder, eqPeakFreqEncoder, eqPeakGainEncoder, eqHighGainEncoder);        

    autoCCPage.setup();
    autoCCPage.setShortName("AUT");
    
    switchPage.initPages(&page, &page2, &page3, &autoCCPage);
    switchPage.parent = this;
  }

  virtual void setup() {
    muted = false;
    setupPages();
    ccHandler.setup();    
    MDTask.addOnKitChangeCallback(this, (md_callback_ptr_t)&MDLivePatchSketch::onKitChanged);

  }

  virtual void show() {
      if (currentPage() == NULL){
          setPage(&page);
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
      page.muted = muted;
      page2.muted = muted;
      page3.muted = muted;      
      autoCCPage.muted = muted;
      if (muted) {
	  GUI.flash_strings_fill("MD LIVE", "MUTED");
      } else {
	  GUI.flash_strings_fill("MD LIVE", "UNMUTED");
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
      return &page;
    } else if (i == 1) {
      return &page2;
    } else if (i == 2) {
      return &page3;
    } else if (i == 3) {
      return &autoCCPage;
    } else {
      return NULL;
    }
  }
  
  void onKitChanged() {
    
    for (int i = 0; i < 4; i++) {
      ((MDFXEncoder *)page.encoders[i])->loadFromKit();
      ((MDFXEncoder *)page2.encoders[i])->loadFromKit();
      ((MDFXEncoder *)page3.encoders[i])->loadFromKit();      
    }
  }  
};


