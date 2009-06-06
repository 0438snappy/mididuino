#ifndef HELPERS_H__
#define HELPERS_H__

  /** Bit-level access and test macros. **/
#define SET_BIT(port, bit)   ((port) |= (1 << (bit)))
#define CLEAR_BIT(port, bit) ((port) &= ~(1 << (bit)))
#define TOGGLE_BIT(port, bit) ((port) ^= (1 << (bit)))
#define IS_BIT_SET(port, bit) (((port) & (1 << (bit))) ? 1 : 0)
#define IS_BIT_CLEAR(port, bit) (((port) & (1 << (bit))) == 0 ? 1 : 0)

#define SET_BIT8(port, bit)   ((port) |= (uint8_t)(1 << (bit)))
#define CLEAR_BIT8(port, bit) ((port) &= (uint8_t)~(1 << (bit)))
#define IS_BIT_SET8(port, bit) (((port) & (uint8_t)(1 << (bit))) ? 1 : 0)
#define IS_BIT_CLEAR8(port, bit) (((port) & (uint8_t)(1 << (bit))) == 0 ? 1 : 0)

#define GET_FLASH(a)        (pgm_read_byte((uint16_t)(a)))
#define GET_FLASH_U16(a)    (256u*(pgm_read_byte((uint16_t)(a)))+(pgm_read_byte(((uint16_t)(a))+1)))
#define GET_FLASH_U16_LE(a) (pgm_read_byte((uint16_t)(a))+256u*(pgm_read_byte(((uint16_t)(a))+1)))
#define GET_FLASH_IDX(a,b)  (pgm_read_byte((uint16_t)(a)+(uint16_t)(b)))

#define GET_FLASH_PTR(a)    (void*)(pgm_read_byte((uint16_t)(a))+256u*(pgm_read_byte(((uint16_t)(a))+1)))

/** Define commonly used C symbols. **/
#ifndef NULL
#define NULL 0
#endif
#define FALSE 0
#define TRUE 1

#define countof(arr) ((sizeof(arr)/sizeof(arr[0])))
  
/** Compile-time assertion in C. **/
#define C_ASSERT(e) extern char __C_ASSERT__[(e)?1:-1]

/** Compress a C structure to byte aligned boundaries. **/
#define PACKED __attribute__ ((packed))

/** put data in external ram section **/
#define EXTRAM __attribute__ ((section(".bss.extram")))

/** Math macros. **/
#define MIN(x, y) ((x) > (y) ? (y) : (x))
#define MAX(x, y) ((x) > (y) ? (x) : (y))
#define ABS(x) ((x) < 0 ? -(x) : (x))

#ifdef __cplusplus
#include "BitArray.hh"

extern "C" {
#endif
  
#include <inttypes.h>
#include <avr/pgmspace.h>

#ifdef MIDIDUINO
#define constrain(amt,low,high) ((amt)<(low)?(low):((amt)>(high)?(high):(amt)))
#define round(x)     ((x)>=0?(long)((x)+0.5):(long)((x)-0.5))

  long map(long x, long in_min, long in_max, long out_min, long out_max);
  
  void delay(unsigned int ms);
  void delayMicroseconds(unsigned int us);
#endif


void m_memcpy(void *dst, void *src, uint16_t cnt);
void m_strncpy(void *dst, char *src, uint16_t cnt);
void m_strncpy_fill(void *dst, char *src, uint16_t cnt);
void m_memcpy_p(void *dst, PGM_P src, uint16_t cnt);
void m_strncpy_p(void *dst, PGM_P src, uint16_t cnt);
void m_strncpy_p_fill(void *dst, PGM_P src, uint16_t cnt);
void m_memclr(void *dst, uint16_t cnt);
void m_str16cpy_fill(void *dst, char *src);
void m_str16cpy_p_fill(void *dst, PGM_P src);
void m_str16cpy_p(void *dst, PGM_P src);


extern uint16_t read_clock(void);
extern uint16_t read_slowclock(void);
extern volatile uint16_t clock;
extern volatile uint16_t slowclock;

uint16_t clock_diff(uint16_t old_clock, uint16_t new_clock);
uint8_t u_limit_value(uint8_t value, int8_t encoder, uint8_t min, uint8_t max);
int limit_value(int value, int encoder, int min, int max);

#ifdef __cplusplus
}
#endif
  
#endif /* HELPERS_H__ */
