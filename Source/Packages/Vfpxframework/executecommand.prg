lparameters tcCommand, ;
	tcFolder, ;
	tcWindowMode
local lcFolder, ;
	loAPI, ;
	lcMessage, ;
	lnResult, ;
	llResult
if vartype(tcFolder) <> 'C' or empty(tcFolder)
	lcFolder = fullpath('')
else
	lcFolder = tcFolder
endif vartype(tcFolder) <> 'C' or empty(tcFolder)
if right(lcFolder, 1) = '\'
	lcFolder = left(lcFolder, len(lcFolder) - 1)
endif right(lcFolder, 1) = '\'
loAPI = newobject('API_AppRun', 'API_AppRun.prg', '', tcCommand, lcFolder, ;
	evl(tcWindowMode, 'HID'))
do case
	case not empty(loAPI.icErrorMessage)
		lcMessage = loAPI.icErrorMessage
	case loAPI.LaunchAppAndWait()
		lnResult  = nvl(loAPI.CheckProcessExitCode(), -1)
		llResult  = lnResult = 0
		lcMessage = iif(llResult, '', ;
			evl(loAPI.icErrorMessage, 'The error code is ' + transform(lnResult)))
	otherwise
		lcMessage = loAPI.icErrorMessage
endcase
return lcMessage
