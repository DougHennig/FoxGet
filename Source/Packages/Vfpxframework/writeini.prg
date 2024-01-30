*==============================================================================
* Function:			WriteINI
* Purpose:			Writes an entry to a section in an INI file
* Author:			Doug Hennig
* Last revision:	05/09/2023
* Parameters:		tcINIFile  - the INI file to look in
*					tcSection  - the section to look for
*					tcEntry    - the entry to look for (pass .NULL. to remove
*						the section)
*					tuValue    - the value to write (pass .NULL. to remove
*						the entry)
* Returns:			.T. if the INI file was updated
* Environment in:	none
* Environment out:	the specified INI file was created or updated
* Note:				- if the value contains any binary characters, it's written
*						out as "0x" + the value converted to hexBinary because
*						binary values may not be read in correctly
*					- logical values are converted to Y or N
*					- non-string values are converted to strings
*==============================================================================

lparameters tcINIFile, ;
	tcSection, ;
	tcEntry, ;
	tuValue
local lcEntry, ;
	lcType, ;
	lcValue, ;
	lnI, ;
	llBinary, ;
	llReturn
declare integer WritePrivateProfileString in Win32API string cSection, ;
	string cEntry, string cValue, string cINIFile
lcEntry = tcEntry
lcType  = vartype(tuValue)
do case

* If the entry is null, use a null value means remove the entry.

	case isnull(tcEntry)
		lcValue = NULL

* If the value is a string and any character is < ASC 32, we'll use HexBinary
* to encode the value.

	case lcType = 'C' and not isnull(tuValue)
		for lnI = 1 to len(tuValue)
			llBinary = asc(substr(tuValue, lnI, 1)) < 32
			if llBinary
				exit
			endif llBinary
		next lnI
		if llBinary
			lcValue = '0x' + strconv(tuValue, 15)
		else
			lcValue = alltrim(tuValue)
		endif llBinary

* Convert logical to Y or N.

	case lcType = 'L'
		lcValue = iif(tuValue, 'Y', 'N')

* Convert all other data types to string.

	otherwise
		lcValue = transform(tuValue)
endcase
llReturn = WritePrivateProfileString(tcSection, lcEntry, lcValue, ;
	lower(fullpath(tcINIFile))) = 1
return llReturn
