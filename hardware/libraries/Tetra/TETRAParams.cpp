#include "Platform.h"
#include "helpers.h"
#include "TETRAParams.hh"
//#include "DSI.hh"
#include "TETRA.h"

#define read_byte(a) (uint8_t)((*a))

uint8_t tetra_sysex_hdr[2] = {
  0x01,	 /*  DSI ID  */
  0x26   /*  Tetra ID  */
};

tetra_parameter_t tetra_parameters[] = { 
{ 0x00, 0 ,"FRQ", 0, 120 },
{ 0x01, 1 ,"TUN", 0, 100 },
{ 0x02, 2 ,"SHP", 0, 103 },
{ 0x03, 3 ,"GLI", 0, 127 },
{ 0x04, 4 ,"KEY", 0, 1 },
{ 0x05, 114 ,"SB1", 0, 127 },
{ 0x06, 5 ,"FRQ", 0, 120 },
{ 0x07, 6 ,"TUN", 0, 100 },
{ 0x08, 7 ,"SHP", 0, 103 },
{ 0x09, 8 ,"GLI", 0, 127 },
{ 0x0A, 9 ,"KEY", 0, 1 },
{ 0x0B, 115 ,"SB2", 0, 127 },
{ 0x0C, 10 ,"SYN", 0, 1 },
{ 0x0D, 11 ,"GMD", 0, 3 },
{ 0x0E, 12 ,"SLP", 0, 5 },
{ 0x0F, 93 ,"PBR", 0, 12 },
{ 0x10, 13 ,"MIX", 0, 127 },
{ 0x11, 14 ,"NOI", 0, 127 },
{ 0x12, 116 ,"FBV", 0, 127 },
{ 0x13, 110 ,"FBG", 0, 127 },
{ 0x14, 15 ,"CUT", 0, 164 },
{ 0x15, 16 ,"RES", 0, 127 },
{ 0x16, 17 ,"FKY", 0, 127 },
{ 0x17, 18 ,"MOD", 0, 127 },
{ 0x18, 19 ,"POL", 0, 1 },
{ 0x19, 20 ,"AMT", 0, 254 },
{ 0x1A, 21 ,"VEL", 0, 127 },
{ 0x1B, 22 ,"DEL", 0, 127 },
{ 0x1C, 23 ,"ATK", 0, 127 },
{ 0x1D, 24 ,"DCY", 0, 127 },
{ 0x1E, 25 ,"SUS", 0, 127 },
{ 0x1F, 26 ,"REL", 0, 127 },
{ 0x20, 27 ,"LEV", 0, 127 },
{ 0x21, 30 ,"AMT", 0, 127 },
{ 0x22, 31 ,"VEL", 0, 127 },
{ 0x23, 32 ,"DEL", 0, 127 },
{ 0x24, 33 ,"ATK", 0, 127 },
{ 0x25, 34 ,"DCY", 0, 127 },
{ 0x26, 35 ,"SUS", 0, 127 },
{ 0x27, 36 ,"REL", 0, 127 },
{ 0x28, 28 ,"SPR", 0, 127 },
{ 0x29, 29 ,"VOL", 0, 127 },
{ 0x2A, 37 ,"FRQ", 0, 166 },
{ 0x2B, 38 ,"SHP", 0, 4 },
{ 0x2C, 39 ,"AMT", 0, 127 },
{ 0x2D, 40 ,"DST", 0, 43 },
{ 0x2E, 41 ,"SYN", 0, 1 },
{ 0x2F, 42 ,"FRQ", 0, 166 },
{ 0x30, 43 ,"SHP", 0, 4 },
{ 0x31, 44 ,"AMT", 0, 127 },
{ 0x32, 45 ,"DST", 0, 43 },
{ 0x33, 46 ,"SYN", 0, 1 },
{ 0x34, 47 ,"FRQ", 0, 166 },
{ 0x35, 48 ,"SHP", 0, 4 },
{ 0x36, 49 ,"AMT", 0, 127 },
{ 0x37, 50 ,"DST", 0, 43 },
{ 0x38, 51 ,"SYN", 0, 1 },
{ 0x39, 52 ,"FRQ", 0, 166 },
{ 0x3A, 53 ,"SHP", 0, 4 },
{ 0x3B, 54 ,"AMT", 0, 127 },
{ 0x3C, 55 ,"DST", 0, 43 },
{ 0x3D, 56 ,"SYN", 0, 1 },
{ 0x3E, 57 ,"DST", 0, 43 },
{ 0x3F, 58 ,"AMT", 0, 254 },
{ 0x40, 59 ,"VEL", 0, 127 },
{ 0x41, 60 ,"DEL", 0, 127 },
{ 0x42, 61 ,"ATK", 0, 127 },
{ 0x43, 62 ,"DCY", 0, 127 },
{ 0x44, 63 ,"SUS", 0, 127 },
{ 0x45, 64 ,"REL", 0, 127 },
{ 0x46, 98 ,"EMD", 0, 1 },
{ 0x47, 65 ,"SRC", 0, 20 },
{ 0x48, 66 ,"AMT", 0, 254 },
{ 0x49, 67 ,"DST", 0, 47 },
{ 0x4A, 68 ,"SRC", 0, 20 },
{ 0x4B, 69 ,"AMT", 0, 254 },
{ 0x4C, 70 ,"DST", 0, 47 },
{ 0x4D, 71 ,"SRC", 0, 20 },
{ 0x4E, 72 ,"AMT", 0, 254 },
{ 0x4F, 73 ,"DST", 0, 47 },
{ 0x50, 74 ,"SRC", 0, 20 },
{ 0x51, 75 ,"AMT", 0, 254 },
{ 0x52, 76 ,"DST", 0, 47 },
{ 0x53, 81 ,"AMT", 0, 254 },
{ 0x54, 82 ,"DST", 0, 47 },
{ 0x55, 83 ,"AMT", 0, 254 },
{ 0x56, 84 ,"DST", 0, 47 },
{ 0x57, 85 ,"AMT", 0, 254 },
{ 0x58, 86 ,"DST", 0, 47 },
{ 0x59, 87 ,"AMT", 0, 254 },
{ 0x5A, 88 ,"DST", 0, 47 },
{ 0x5B, 89 ,"AMT", 0, 254 },
{ 0x5C, 90 ,"DST", 0, 47 },
{ 0x5D, 96 ,"UMD", 0, 4 },
{ 0x5E, 95 ,"KMD", 0, 5 },
{ 0x5F, 99 ,"UNI", 0, 1 },
{ 0x60, 111 ,"NOT", 0, 127 },
{ 0x61, 112 ,"VEL", 0, 127 },
{ 0x62, 113 ,"MOD", 0, 1 },
{ 0x63, 118 ,"SPL", 0, 127 },
{ 0x64, 119 ,"KMD", 0, 2 },
{ 0x65, 91 ,"BPM", 30, 250 },
{ 0x66, 92 ,"CLK", 0, 12 },
{ 0x67, 97 ,"AMD", 0, 3 },
{ 0x68, 100 ,"ARP", 0, 1 },
{ 0x69, 94 ,"TRG", 0, 4 },
{ 0x6A, 101 ,"GAT", 0, 1 },
{ 0x6B, 77 ,"DST", 0, 47 },
{ 0x6C, 78 ,"DST", 0, 47 },
{ 0x6D, 79 ,"DST", 0, 47 },
{ 0x6E, 80 ,"DST", 0, 47 },
{ 0x6F, 105 ,"P1", 0, 183 },
{ 0x70, 106 ,"P2", 0, 183 },
{ 0x71, 107 ,"P3", 0, 183 },
{ 0x72, 108 ,"P4", 0, 183 },
//XXX hack - need to figure out an elegant way of skipping these empty params :-)
{ 0x73, 255, "", 0 , 0 },
{ 0x74, 255, "", 0 , 0 },
{ 0x75, 117 ,"", 0,  0 },  //EDITOR BYTE
{ 0x76, 255, "", 0 , 0 },
{ 0x76, 255, "", 0 , 0 },
{ 0x77, 255, "", 0 , 0 },
//XXX - TODO refactor names below to be generated programatically...
{ 0x78, 120 ,"A01", 0, 127 },
{ 0x79, 121 ,"A02", 0, 127 },
{ 0x7A, 122 ,"A03", 0, 127 },
{ 0x7B, 123 ,"A04", 0, 127 },
{ 0x7C, 124 ,"A05", 0, 127 },
{ 0x7D, 125 ,"A06", 0, 127 },
{ 0x7E, 126 ,"A07", 0, 127 },
{ 0x7F, 127 ,"A08", 0, 127 },
{ 0x80, 128 ,"A09", 0, 127 },
{ 0x81, 129 ,"A10", 0, 127 },
{ 0x82, 130 ,"A11", 0, 127 },
{ 0x83, 131 ,"A12", 0, 127 },
{ 0x84, 132 ,"A13", 0, 127 },
{ 0x85, 133 ,"A14", 0, 127 },
{ 0x86, 134 ,"A15", 0, 127 },
{ 0x87, 135 ,"A16", 0, 127 },
{ 0x88, 136 ,"B01", 0, 126 },
{ 0x89, 137 ,"B02", 0, 127 },
{ 0x8A, 138 ,"B03", 0, 127 },
{ 0x8B, 139 ,"B04", 0, 127 },
{ 0x8C, 140 ,"B05", 0, 127 },
{ 0x8D, 141 ,"B06", 0, 127 },
{ 0x8E, 142 ,"B07", 0, 127 },
{ 0x8F, 143 ,"B08", 0, 127 },
{ 0x90, 144 ,"B09", 0, 127 },
{ 0x91, 145 ,"B10", 0, 127 },
{ 0x92, 146 ,"B11", 0, 127 },
{ 0x93, 147 ,"B12", 0, 127 },
{ 0x94, 148 ,"B13", 0, 127 },
{ 0x95, 149 ,"B14", 0, 127 },
{ 0x96, 150 ,"B15", 0, 127 },
{ 0x97, 151 ,"B16", 0, 127 },
{ 0x98, 152 ,"C01", 0, 126 },
{ 0x99, 153 ,"C02", 0, 127 },
{ 0x9A, 154 ,"C03", 0, 127 },
{ 0x9B, 155 ,"C04", 0, 127 },
{ 0x9C, 156 ,"C05", 0, 127 },
{ 0x9D, 157 ,"C06", 0, 127 },
{ 0x9E, 158 ,"C07", 0, 127 },
{ 0x9F, 159 ,"C08", 0, 127 },
{ 0xA0, 160 ,"C09", 0, 127 },
{ 0xA1, 161 ,"C10", 0, 127 },
{ 0xA2, 162 ,"C11", 0, 127 },
{ 0xA3, 163 ,"C12", 0, 127 },
{ 0xA4, 164 ,"C13", 0, 127 },
{ 0xA5, 165 ,"C14", 0, 127 },
{ 0xA6, 166 ,"C15", 0, 127 },
{ 0xA7, 167 ,"C16", 0, 127 },
{ 0xA8, 168 ,"D01", 0, 126 },
{ 0xA9, 169 ,"D02", 0, 127 },
{ 0xAA, 170 ,"D03", 0, 127 },
{ 0xAB, 171 ,"D04", 0, 127 },
{ 0xAC, 172 ,"D05", 0, 127 },
{ 0xAD, 173 ,"D06", 0, 127 },
{ 0xAE, 174 ,"D07", 0, 127 },
{ 0xAF, 175 ,"D08", 0, 127 },
{ 0xB0, 176 ,"D09", 0, 127 },
{ 0xB1, 177 ,"D10", 0, 127 },
{ 0xB2, 178 ,"D11", 0, 127 },
{ 0xB3, 179 ,"D12", 0, 127 },
{ 0xB4, 180 ,"D13", 0, 127 },
{ 0xB5, 181 ,"D14", 0, 127 },
{ 0xB6, 182 ,"D15", 0, 127 },
{ 0xB7, 183 ,"D16", 0, 127 },
{ 0xB8, 184 ,"N01", 32, 127 },
{ 0xB9, 185 ,"N02", 32, 127 },
{ 0xBA, 186 ,"N03", 32, 127 },
{ 0xBB, 187 ,"N04", 32, 127 },
{ 0xBC, 188 ,"N05", 32, 127 },
{ 0xBD, 189 ,"N06", 32, 127 },
{ 0xBE, 190 ,"N07", 32, 127 },
{ 0xBF, 191 ,"N08", 32, 127 },
{ 0xC0, 192 ,"N09", 32, 127 },
{ 0xC1, 193 ,"N10", 32, 127 },
{ 0xC2, 194 ,"N11", 32, 127 },
{ 0xC3, 195 ,"N12", 32, 127 },
{ 0xC4, 196 ,"N13", 32, 127 },
{ 0xC5, 197 ,"N14", 32, 127 },
{ 0xC6, 198 ,"N15", 32, 127 },
{ 0xC7, 199 ,"N16", 32, 127 },
{255, 255, "", 0 , 0 }
};

tetra_parameter_groupname_t tetra_parameter_groupnames[] = { 
{ 0x00, "OSC1"},
{ 0x06, "OSC2"},
{ 0x0C, "OSC"},
{ 0x12, "FEEDBK"},
{ 0x14, "VCF"},
{ 0x1B, "VCF ENV"},
{ 0x20, "VCA"},
{ 0x23, "VCA ENV"},
{ 0x28, NULL},
{ 0x2A, "LFO1"},
{ 0x2F, "LFO2"},
{ 0x34, "LFO3"},
{ 0x39, "LFO4"},
{ 0x3E, "ENV3"},
{ 0x47, "MOD1"},
{ 0x4A, "MOD2"},
{ 0x4D, "MOD3"},
{ 0x50, "MOD4"},
{ 0x53, NULL},
{ 0x60, "PUSH IT"},
{ 0x63, NULL},
{ 0x67, "ARPGIATR"},
{ 0x69, "SEQ"},
{ 0x6F, "ASSN PRM"},
{ 0x77, NULL},
{ 0x78, "SEQ TRK1"},
{ 0x88, "SEQ TRK2"},
{ 0x98, "SEQ TRK3"},
{ 0xA8, "SEQ TRK4"},
{ 0xB8, "NAME CHR"},
{ 255, ""}
};

const char* getTetraParameterGroupName(const tetra_parameter_groupname_t *parameterGroupnames, uint8_t parameterNumber) {
  uint8_t i = 0;
  uint8_t x = 255;
  uint8_t id;
  if (parameterGroupnames == NULL){
    return NULL;
  }

  // The groupname is the same for all subsequent params, until the paramNumber in the struct changes
  while ((id = read_byte(&parameterGroupnames[i].parameterNumber)) != 255) {
    if (id <= parameterNumber) {   	
   		x = i;
    }
    i++;
  }  
  
  if (x!=255){
	  return parameterGroupnames[x].groupname;
  } else {
	  return NULL;
  }
}


const char* getTetraParameterName(const tetra_parameter_t *parameters, uint8_t parameterNumber) {
  uint8_t i = 0;
  uint8_t id;
  if (parameters == NULL){
    return NULL;
  }

  while ((id = read_byte(&parameters[i].parameterNumber)) != 255) {
    if (id == parameterNumber) {   	
   		return parameters[i].name;
    }
    i++;
  }  
  
  return NULL;
}

uint8_t getTetraParameterValue(const tetra_parameter_t *parameters, uint8_t parameterNumber, tetra_parameter_properties_t propertyName) {
  uint8_t i = 0;
  uint8_t id;
  if (parameters == NULL){
    return 0;
  }

  while ((id = read_byte(&parameters[i].parameterNumber)) != 255) {
    if (id == parameterNumber) {   	
    	switch(propertyName){
    		case TETRA_PARAMETER_NRPN:
	      		return parameters[i].nrpn;
	      		    		
    		case TETRA_PARAMETER_MIN:
	      		return parameters[i].min;
	      		
    		case TETRA_PARAMETER_MAX:
	      		return parameters[i].max;	      		
      	}
    }
    i++;
  }  
  
  return 0;
}

uint8_t TETRAClass::getParameterNrpn(uint8_t parameterNumber) {
	return getTetraParameterValue(tetra_parameters, parameterNumber, TETRA_PARAMETER_NRPN);
}

const char* TETRAClass::getParameterName(uint8_t parameterNumber) {
	return getTetraParameterName(tetra_parameters, parameterNumber);
}

const char* TETRAClass::getParameterGroupName(uint8_t parameterNumber) {
	return getTetraParameterGroupName(tetra_parameter_groupnames, parameterNumber);
}

uint8_t TETRAClass::getParameterMin(uint8_t parameterNumber) {	
	return getTetraParameterValue(tetra_parameters, parameterNumber, TETRA_PARAMETER_MIN);
}

uint8_t TETRAClass::getParameterMax(uint8_t parameterNumber) {
	return getTetraParameterValue(tetra_parameters, parameterNumber, TETRA_PARAMETER_MAX);
}
