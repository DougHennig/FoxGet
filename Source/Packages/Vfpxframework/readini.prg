*==============================================================================
* Function:			ReadINI
* Purpose:			Reads an entry from a section in an INI file
* Author:			Doug Hennig
* Last revision:	01/27/2024
* Parameters:		tcINIFile - the INI file to look in
*					tcSection - the section to look for
*					tuEntry   - the entry to look for (pass 0 and taEntries
*						to enumerate all entries in the section)
*					tcDefault - the default value to use if the entry isn't
*						found
*					taEntries - an array to hold all entries in the section
*						(only needed if tuEntry is 0)
* Returns:			if tuEntry is a string (the entry), the value of the entry
*						or tcDefault if the entry isn't found
*					if tuEntry is 0, the number of entries in the array
* Environment in:	none
* Environment out:	none
* Note:				if the value starts with "0x", it's converted from
*						hexBinary because WriteINI does that
*==============================================================================

lparameters tcINIFile, ;
	tcSection, ;
	tuEntry, ;
	tcDefault, ;
	taEntries
#include VFPXRegistry.h
local lcBuffer, ;
	lcDefault, ;
	lnSize, ;
	luReturn, ;
	lnI, ;
	lcValue
declare integer GetPrivateProfileString in Win32API string cSection, ;
	string cEntry, string cDefault, string @ cBuffer, integer nBufferSize, ;
	string cINIFile
lcBuffer  = replicate(ccNULL, cnBUFFER_SIZE)
lcDefault = iif(vartype(tcDefault) <> 'C', '', tcDefault)
lnSize    = GetPrivateProfileString(tcSection, tuEntry, lcDefault, @lcBuffer, ;
	cnBUFFER_SIZE, lower(fullpath(tcINIFile)))
lcBuffer  = left(lcBuffer, lnSize)
luReturn  = lcBuffer
do case
	case vartype(tuEntry) = 'N'
		luReturn = alines(taEntries, lcBuffer, 4, ccNULL, ccCR)
		if luReturn = 1 and empty(taEntries[1])
			luReturn = 0
		endif luReturn = 1 ...
		for lnI = 1 to luReturn
			lcValue = taEntries[lnI]
			if left(lcValue, 2) = '0x'
				taEntries[lnI] = strconv(substr(lcValue, 3), 16)
			endif left(lcValue, 2) = '0x'
		next lnI
	case left(luReturn, 2) = '0x'
		luReturn = strconv(substr(luReturn, 3), 16)
endcase
return luReturn
