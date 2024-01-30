#include VFPXBaseLibrary.h

* Registry constants.

#define cnSUCCESS					0
#define cnERROR_EOF				259
	&& no more entries in key
#define cnRESERVED				0
#define cnBUFFER_SIZE				256
	&& the size of the buffer for the key value

* Registry key values.

#define cnHKEY_CLASSES_ROOT		-2147483648
#define cnHKEY_CURRENT_USER		-2147483647
#define cnHKEY_LOCAL_MACHINE		-2147483646
#define cnHKEY_USERS				-2147483645

* Data types.

#define cnREG_SZ					1
	&& String
#define cnREG_EXPAND_SZ			2
	&& String containing unexpanded references to environment variables
#define cnREG_BINARY				3
	&& Binary
#define cnREG_DWORD				4
	&& 32-bit number
#define cnREG_MULTI_SZ				7
	&& Multi-value

* Restrictions.

#define cnRRF_RT_ANY				0x0000FFFF
	&& no data type restriction
#define cnRRF_SUBKEY_WOW6464KEY	0x00010000
#define cnRRF_SUBKEY_WOW6432KEY	0x00020000		
