*==============================================================================
* Method:			FileOperation
* Status:			Public
* Purpose:			Performs a file operation (copy, move, delete) with the
*					Windows progress dialog
* Author:			Sergey Berezniker, posted at
*					http://www.berezniker.com/file-operations-progressbar
* Last revision:	12/25/2023
* Parameters:		tcSource       - the source file
*					tcDestination  - the destination
*					tcAction       - the action to perform: "move", "copy",
*						"delete", or "rename"
*					tlUserCanceled - passed by reference, this will contain
*						.T. if the user canceled the operation
*					tlFilesOnly    - if .T., only process files, not folders
*					tlQuiet        - .T. to not display a progress dialog
* Returns:			.T. if the operation succeeded
* Environment in:	none
* Environment out:	if it was passed by reference, tlUserCanceled contains
*						the appropriate value
*==============================================================================

#define ccNULL							chr(0)
#define FOF_SILENT						0x0004	&& don't create progress/report
#define FOF_NOCONFIRMATION				0x0010	&& Don't prompt the user.
#define FOF_FILESONLY					0x0080	&& on *.*, do only files
#define FOF_NOCONFIRMMKDIR				0x0200	&& don't confirm making any needed dirs
#define FOF_NOERRORUI					0x0400	&& don't put up error UI

lparameters tcSource, ;
	tcDestination, ;
	tcAction, ;
	tlUserCanceled, ;
	tlFilesOnly, ;
	tlQuiet
local loHeap, ;
	lcAction, ;
	laActionList[1], ;
	lnAction, ;
	lcSourceString, ;
	lcDestString, ;
	lnStringBase, ;
	lnFlag, ;
	lcFileOpStruct, ;
	lnRetCode

* Declare the Windows API function we need and create a Heap object.
 
declare integer SHFileOperation in Shell32.dll string @ lpSHFileOpStruct
loHeap = newobject('Heap', 'ClsHeap.prg')

* Ensure we have a valid action.

lcAction = upper(iif(empty(tcAction) or vartype(tcAction) <> 'C', 'COPY', ;
	tcAction))
alines(laActionList, 'MOVE,COPY,DELETE,RENAME', ',')
lnAction = ascan(laActionList, lcAction)
if lnAction = 0
	return NULL
endif lnAction = 0

* Perform the operation.
 
lcSourceString = tcSource + ccNULL + ccNULL
lcDestString   = tcDestination + ccNULL + ccNULL
lnStringBase   = loHeap.AllocBlob(lcSourceString + lcDestString)
lnFlag         = FOF_NOCONFIRMATION + FOF_NOCONFIRMMKDIR + FOF_NOERRORUI + ;
	iif(tlFilesOnly, FOF_FILESONLY, 0) + iif(tlQuiet, FOF_SILENT, 0)
lcFileOpStruct = loHeap.NumToLong(_screen.hWnd) + ;
	loHeap.NumToLong(lnAction) + ;
	loHeap.NumToLong(lnStringBase) + ;
	loHeap.NumToLong(lnStringBase + len(lcSourceString)) + ;
	loHeap.NumToLong(lnFlag) + ;
	loHeap.NumToLong(0) + loHeap.NumToLong(0) + loHeap.NumToLong(0)
lnRetCode = SHFileOperation(@lcFileOpStruct) 

* Flag if the user cancel the operation and return success or failure.

tlUserCanceled = substr(lcFileOpStruct, 19, 4) <> loHeap.NumToLong(0)
return lnRetCode = 0
