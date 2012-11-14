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

tetra_parameter_name_t tetra_parameter_names[] PROGMEM = { 
{ "FRQ", 0x00 },
{ "TUN", 0x01 },
{ "SHP", 0x02 },
{ "GLI", 0x03 },
{ "KEY", 0x04 },
{ "SB1", 0x05 },
{ "FRQ", 0x06 },
{ "TUN", 0x07 },
{ "SHP", 0x08 },
{ "GLI", 0x09 },
{ "KEY", 0x0A },
{ "SB2", 0x0B },
{ "SYN", 0x0C },
{ "GMD", 0x0D },
{ "SLP", 0x0E },
{ "PBR", 0x0F },
{ "MIX", 0x10 },
{ "NOI", 0x11 },
{ "FBV", 0x12 },
{ "FBG", 0x13 },
{ "CUT", 0x14 },
{ "RES", 0x15 },
{ "FKY", 0x16 },
{ "MOD", 0x17 },
{ "POL", 0x18 },
{ "AMT", 0x19 },
{ "VEL", 0x1A },
{ "DEL", 0x1B },
{ "ATK", 0x1C },
{ "DCY", 0x1D },
{ "SUS", 0x1E },
{ "REL", 0x1F },
{ "LEV", 0x20 },
{ "AMT", 0x21 },
{ "VEL", 0x22 },
{ "DEL", 0x23 },
{ "ATK", 0x24 },
{ "DCY", 0x25 },
{ "SUS", 0x26 },
{ "REL", 0x27 },
{ "SPR", 0x28 },
{ "VOL", 0x29 },
{ "FRQ", 0x2A },
{ "SHP", 0x2B },
{ "AMT", 0x2C },
{ "DST", 0x2D },
{ "SYN", 0x2E },
{ "FRQ", 0x2F },
{ "SHP", 0x30 },
{ "AMT", 0x31 },
{ "DST", 0x32 },
{ "SYN", 0x33 },
{ "FRQ", 0x34 },
{ "SHP", 0x35 },
{ "AMT", 0x36 },
{ "DST", 0x37 },
{ "SYN", 0x38 },
{ "FRQ", 0x39 },
{ "SHP", 0x3A },
{ "AMT", 0x3B },
{ "DST", 0x3C },
{ "SYN", 0x3D },
{ "DST", 0x3E },
{ "AMT", 0x3F },
{ "VEL", 0x40 },
{ "DEL", 0x41 },
{ "ATK", 0x42 },
{ "DCY", 0x43 },
{ "SUS", 0x44 },
{ "REL", 0x45 },
{ "EMD", 0x46 },
{ "SRC", 0x47 },
{ "AMT", 0x48 },
{ "DST", 0x49 },
{ "SRC", 0x4A },
{ "AMT", 0x4B },
{ "DST", 0x4C },
{ "SRC", 0x4D },
{ "AMT", 0x4E },
{ "DST", 0x4F },
{ "SRC", 0x50 },
{ "AMT", 0x51 },
{ "DST", 0x52 },
{ "AMT", 0x53 },
{ "DST", 0x54 },
{ "AMT", 0x55 },
{ "DST", 0x56 },
{ "AMT", 0x57 },
{ "DST", 0x58 },
{ "AMT", 0x59 },
{ "DST", 0x5A },
{ "AMT", 0x5B },
{ "DST", 0x5C },
{ "UMD", 0x5D },
{ "KMD", 0x5E },
{ "UNI", 0x5F },
{ "NOT", 0x60 },
{ "VEL", 0x61 },
{ "MOD", 0x62 },
{ "SPL", 0x63 },
{ "KMD", 0x64 },
{ "BPM", 0x65 },
{ "CLK", 0x66 },
{ "AMD", 0x67 },
{ "ARP", 0x68 },
{ "TRG", 0x69 },
{ "GAT", 0x6A },
{ "DST", 0x6B },
{ "DST", 0x6C },
{ "DST", 0x6D },
{ "DST", 0x6E },
{ "P1", 0x6F },
{ "P2", 0x70 },
{ "P3", 0x71 },
{ "P4", 0x72 },
//XXX hack - need to figure out an elegant way of skipping these empty params :-)
{ "", 0x73 },
{ "", 0x74 },
{ "", 0x75 },  //EDITOR BYTE
{ "", 0x76 },
{ "", 0x76 },
{ "", 0x77 },
//XXX - TODO refactor names below to be generated programatically...
{ "A01", 0x78 },
{ "A02", 0x79 },
{ "A03", 0x7A },
{ "A04", 0x7B },
{ "A05", 0x7C },
{ "A06", 0x7D },
{ "A07", 0x7E },
{ "A08", 0x7F },
{ "A09", 0x80 },
{ "A10", 0x81 },
{ "A11", 0x82 },
{ "A12", 0x83 },
{ "A13", 0x84 },
{ "A14", 0x85 },
{ "A15", 0x86 },
{ "A16", 0x87 },
{ "B01", 0x88 },
{ "B02", 0x89 },
{ "B03", 0x8A },
{ "B04", 0x8B },
{ "B05", 0x8C },
{ "B06", 0x8D },
{ "B07", 0x8E },
{ "B08", 0x8F },
{ "B09", 0x90 },
{ "B10", 0x91 },
{ "B11", 0x92 },
{ "B12", 0x93 },
{ "B13", 0x94 },
{ "B14", 0x95 },
{ "B15", 0x96 },
{ "B16", 0x97 },
{ "C01", 0x98 },
{ "C02", 0x99 },
{ "C03", 0x9A },
{ "C04", 0x9B },
{ "C05", 0x9C },
{ "C06", 0x9D },
{ "C07", 0x9E },
{ "C08", 0x9F },
{ "C09", 0xA0 },
{ "C10", 0xA1 },
{ "C11", 0xA2 },
{ "C12", 0xA3 },
{ "C13", 0xA4 },
{ "C14", 0xA5 },
{ "C15", 0xA6 },
{ "C16", 0xA7 },
{ "D01", 0xA8 },
{ "D02", 0xA9 },
{ "D03", 0xAA },
{ "D04", 0xAB },
{ "D05", 0xAC },
{ "D06", 0xAD },
{ "D07", 0xAE },
{ "D08", 0xAF },
{ "D09", 0xB0 },
{ "D10", 0xB1 },
{ "D11", 0xB2 },
{ "D12", 0xB3 },
{ "D13", 0xB4 },
{ "D14", 0xB5 },
{ "D15", 0xB6 },
{ "D16", 0xB7 },
{ "N01", 0xB8 },
{ "N02", 0xB9 },
{ "N03", 0xBA },
{ "N04", 0xBB },
{ "N05", 0xBC },
{ "N06", 0xBD },
{ "N07", 0xBE },
{ "N08", 0xBF },
{ "N09", 0xC0 },
{ "N10", 0xC1 },
{ "N11", 0xC2 },
{ "N12", 0xC3 },
{ "N13", 0xC4 },
{ "N14", 0xC5 },
{ "N15", 0xC6 },
{ "N16", 0xC7 },
{ "", 255 }
};

tetra_parameter_detail_t tetra_parameter_details[] = { 
{ 0x00, 0 ,0, 120 },
{ 0x01, 1 ,0, 100 },
{ 0x02, 2 ,0, 103 },
{ 0x03, 3 ,0, 127 },
{ 0x04, 4 ,0, 1 },
{ 0x05, 114 ,0, 127 },
{ 0x06, 5 ,0, 120 },
{ 0x07, 6 ,0, 100 },
{ 0x08, 7 ,0, 103 },
{ 0x09, 8 ,0, 127 },
{ 0x0A, 9 ,0, 1 },
{ 0x0B, 115 ,0, 127 },
{ 0x0C, 10 ,0, 1 },
{ 0x0D, 11 ,0, 3 },
{ 0x0E, 12 ,0, 5 },
{ 0x0F, 93 ,0, 12 },
{ 0x10, 13 ,0, 127 },
{ 0x11, 14 ,0, 127 },
{ 0x12, 116 ,0, 127 },
{ 0x13, 110 ,0, 127 },
{ 0x14, 15 ,0, 164 },
{ 0x15, 16 ,0, 127 },
{ 0x16, 17 ,0, 127 },
{ 0x17, 18 ,0, 127 },
{ 0x18, 19 ,0, 1 },
{ 0x19, 20 ,0, 254 },
{ 0x1A, 21 ,0, 127 },
{ 0x1B, 22 ,0, 127 },
{ 0x1C, 23 ,0, 127 },
{ 0x1D, 24 ,0, 127 },
{ 0x1E, 25 ,0, 127 },
{ 0x1F, 26 ,0, 127 },
{ 0x20, 27 ,0, 127 },
{ 0x21, 30 ,0, 127 },
{ 0x22, 31 ,0, 127 },
{ 0x23, 32 ,0, 127 },
{ 0x24, 33 ,0, 127 },
{ 0x25, 34 ,0, 127 },
{ 0x26, 35 ,0, 127 },
{ 0x27, 36 ,0, 127 },
{ 0x28, 28 ,0, 127 },
{ 0x29, 29 ,0, 127 },
{ 0x2A, 37 ,0, 166 },
{ 0x2B, 38 ,0, 4 },
{ 0x2C, 39 ,0, 127 },
{ 0x2D, 40 ,0, 43 },
{ 0x2E, 41 ,0, 1 },
{ 0x2F, 42 ,0, 166 },
{ 0x30, 43 ,0, 4 },
{ 0x31, 44 ,0, 127 },
{ 0x32, 45 ,0, 43 },
{ 0x33, 46 ,0, 1 },
{ 0x34, 47 ,0, 166 },
{ 0x35, 48 ,0, 4 },
{ 0x36, 49 ,0, 127 },
{ 0x37, 50 ,0, 43 },
{ 0x38, 51 ,0, 1 },
{ 0x39, 52 ,0, 166 },
{ 0x3A, 53 ,0, 4 },
{ 0x3B, 54 ,0, 127 },
{ 0x3C, 55 ,0, 43 },
{ 0x3D, 56 ,0, 1 },
{ 0x3E, 57 ,0, 43 },
{ 0x3F, 58 ,0, 254 },
{ 0x40, 59 ,0, 127 },
{ 0x41, 60 ,0, 127 },
{ 0x42, 61 ,0, 127 },
{ 0x43, 62 ,0, 127 },
{ 0x44, 63 ,0, 127 },
{ 0x45, 64 ,0, 127 },
{ 0x46, 98 ,0, 1 },
{ 0x47, 65 ,0, 20 },
{ 0x48, 66 ,0, 254 },
{ 0x49, 67 ,0, 47 },
{ 0x4A, 68 ,0, 20 },
{ 0x4B, 69 ,0, 254 },
{ 0x4C, 70 ,0, 47 },
{ 0x4D, 71 ,0, 20 },
{ 0x4E, 72 ,0, 254 },
{ 0x4F, 73 ,0, 47 },
{ 0x50, 74 ,0, 20 },
{ 0x51, 75 ,0, 254 },
{ 0x52, 76 ,0, 47 },
{ 0x53, 81 ,0, 254 },
{ 0x54, 82 ,0, 47 },
{ 0x55, 83 ,0, 254 },
{ 0x56, 84 ,0, 47 },
{ 0x57, 85 ,0, 254 },
{ 0x58, 86 ,0, 47 },
{ 0x59, 87 ,0, 254 },
{ 0x5A, 88 ,0, 47 },
{ 0x5B, 89 ,0, 254 },
{ 0x5C, 90 ,0, 47 },
{ 0x5D, 96 ,0, 4 },
{ 0x5E, 95 ,0, 5 },
{ 0x5F, 99 ,0, 1 },
{ 0x60, 111 ,0, 127 },
{ 0x61, 112 ,0, 127 },
{ 0x62, 113 ,0, 1 },
{ 0x63, 118 ,0, 127 },
{ 0x64, 119 ,0, 2 },
{ 0x65, 91 ,30, 250 },
{ 0x66, 92 ,0, 12 },
{ 0x67, 97 ,0, 3 },
{ 0x68, 100 ,0, 1 },
{ 0x69, 94 ,0, 4 },
{ 0x6A, 101 ,0, 1 },
{ 0x6B, 77 ,0, 47 },
{ 0x6C, 78 ,0, 47 },
{ 0x6D, 79 ,0, 47 },
{ 0x6E, 80 ,0, 47 },
{ 0x6F, 105 ,0, 183 },
{ 0x70, 106 ,0, 183 },
{ 0x71, 107 ,0, 183 },
{ 0x72, 108 ,0, 183 },
//XXX hack - need to figure out an elegant way of skipping these empty params :-)
{ 0x73, 0 ,0, 0 },
{ 0x74, 0 ,0, 0 },
{ 0x75, 0 ,0, 0 },
{ 0x76, 0 ,0, 0 },
{ 0x77, 0 ,0, 0 },
{ 0x78, 120 ,0, 127 },
{ 0x79, 121 ,0, 127 },
{ 0x7A, 122 ,0, 127 },
{ 0x7B, 123 ,0, 127 },
{ 0x7C, 124 ,0, 127 },
{ 0x7D, 125 ,0, 127 },
{ 0x7E, 126 ,0, 127 },
{ 0x7F, 127 ,0, 127 },
{ 0x80, 128 ,0, 127 },
{ 0x81, 129 ,0, 127 },
{ 0x82, 130 ,0, 127 },
{ 0x83, 131 ,0, 127 },
{ 0x84, 132 ,0, 127 },
{ 0x85, 133 ,0, 127 },
{ 0x86, 134 ,0, 127 },
{ 0x87, 135 ,0, 127 },
{ 0x88, 136 ,0, 126 },
{ 0x89, 137 ,0, 127 },
{ 0x8A, 138 ,0, 127 },
{ 0x8B, 139 ,0, 127 },
{ 0x8C, 140 ,0, 127 },
{ 0x8D, 141 ,0, 127 },
{ 0x8E, 142 ,0, 127 },
{ 0x8F, 143 ,0, 127 },
{ 0x90, 144 ,0, 127 },
{ 0x91, 145 ,0, 127 },
{ 0x92, 146 ,0, 127 },
{ 0x93, 147 ,0, 127 },
{ 0x94, 148 ,0, 127 },
{ 0x95, 149 ,0, 127 },
{ 0x96, 150 ,0, 127 },
{ 0x97, 151 ,0, 127 },
{ 0x98, 152 ,0, 126 },
{ 0x99, 153 ,0, 127 },
{ 0x9A, 154 ,0, 127 },
{ 0x9B, 155 ,0, 127 },
{ 0x9C, 156 ,0, 127 },
{ 0x9D, 157 ,0, 127 },
{ 0x9E, 158 ,0, 127 },
{ 0x9F, 159 ,0, 127 },
{ 0xA0, 160 ,0, 127 },
{ 0xA1, 161 ,0, 127 },
{ 0xA2, 162 ,0, 127 },
{ 0xA3, 163 ,0, 127 },
{ 0xA4, 164 ,0, 127 },
{ 0xA5, 165 ,0, 127 },
{ 0xA6, 166 ,0, 127 },
{ 0xA7, 167 ,0, 127 },
{ 0xA8, 168 ,0, 126 },
{ 0xA9, 169 ,0, 127 },
{ 0xAA, 170 ,0, 127 },
{ 0xAB, 171 ,0, 127 },
{ 0xAC, 172 ,0, 127 },
{ 0xAD, 173 ,0, 127 },
{ 0xAE, 174 ,0, 127 },
{ 0xAF, 175 ,0, 127 },
{ 0xB0, 176 ,0, 127 },
{ 0xB1, 177 ,0, 127 },
{ 0xB2, 178 ,0, 127 },
{ 0xB3, 179 ,0, 127 },
{ 0xB4, 180 ,0, 127 },
{ 0xB5, 181 ,0, 127 },
{ 0xB6, 182 ,0, 127 },
{ 0xB7, 183 ,0, 127 },
{ 0xB8, 184 ,32, 127 },
{ 0xB9, 185 ,32, 127 },
{ 0xBA, 186 ,32, 127 },
{ 0xBB, 187 ,32, 127 },
{ 0xBC, 188 ,32, 127 },
{ 0xBD, 189 ,32, 127 },
{ 0xBE, 190 ,32, 127 },
{ 0xBF, 191 ,32, 127 },
{ 0xC0, 192 ,32, 127 },
{ 0xC1, 193 ,32, 127 },
{ 0xC2, 194 ,32, 127 },
{ 0xC3, 195 ,32, 127 },
{ 0xC4, 196 ,32, 127 },
{ 0xC5, 197 ,32, 127 },
{ 0xC6, 198 ,32, 127 },
{ 0xC7, 199 ,32, 127 },
{ 255, 0 , 0, 0 }
};


tetra_parameter_groupname_t tetra_parameter_groupnames[] PROGMEM = { 
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

static PGM_P getTetraParameterGroupName(const tetra_parameter_groupname_t *parameter_groupnames, uint8_t parameterNumber) {
  uint8_t i = 0;
  uint8_t x = 255;
  uint8_t id;
  if (parameter_groupnames == NULL){
    return NULL;
  }

  // The groupname is the same for all subsequent params, until the paramNumber in the struct changes
  while ((id = pgm_read_byte(&parameter_groupnames[i].parameterNumber)) != 255) {
    if (id <= parameterNumber) {   	
   		x = i;
    }
    i++;
  }  
  
  if (x!=255){
	  return parameter_groupnames[x].groupname;
  } else {
	  return NULL;
  }
}


static PGM_P getTetraParameterName(const tetra_parameter_name_t *parameter_names, uint8_t parameterNumber) {
  uint8_t i = 0;
  uint8_t id;
  if (parameter_names == NULL){
    return NULL;
  }

  while ((id = pgm_read_byte(&parameter_names[i].parameterNumber)) != 255) {
    if (id == parameterNumber) { 
   		return parameter_names[i].name;
    }
    i++;
  }  
  
  return NULL;
}

uint8_t getTetraParameterValue(const tetra_parameter_detail_t *parameter_details, uint8_t parameterNumber, tetra_parameter_properties_t propertyName) {
  uint8_t i = 0;
  uint8_t id;
  if (parameter_details == NULL){
    return 0;
  }

  while ((id = read_byte(&parameter_details[i].parameterNumber)) != 255) {
    if (id == parameterNumber) {   	
    	switch(propertyName){
    		case TETRA_PARAMETER_NRPN:
	      		return parameter_details[i].nrpn;
	      		    		
    		case TETRA_PARAMETER_MIN:
	      		return parameter_details[i].min;
	      		
    		case TETRA_PARAMETER_MAX:
	      		return parameter_details[i].max;	      		
      	}
    }
    i++;
  }  
  
  return 0;
}

uint8_t TETRAClass::getParameterNrpn(uint8_t parameterNumber) {
	return getTetraParameterValue(tetra_parameter_details, parameterNumber, TETRA_PARAMETER_NRPN);
}

PGM_P TETRAClass::getParameterName(uint8_t parameterNumber) {
	return getTetraParameterName(tetra_parameter_names, parameterNumber);
}

PGM_P TETRAClass::getParameterGroupName(uint8_t parameterNumber) {
	return getTetraParameterGroupName(tetra_parameter_groupnames, parameterNumber);
}


uint8_t TETRAClass::getParameterMin(uint8_t parameterNumber) {	
	return getTetraParameterValue(tetra_parameter_details, parameterNumber, TETRA_PARAMETER_MIN);
}

uint8_t TETRAClass::getParameterMax(uint8_t parameterNumber) {
	return getTetraParameterValue(tetra_parameter_details, parameterNumber, TETRA_PARAMETER_MAX);
}
