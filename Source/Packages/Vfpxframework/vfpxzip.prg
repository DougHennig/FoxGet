#include VFPXBaseLibrary.h
#define cnSHELL_YES_TO_ALL	  16

define class VFPXZip as Custom
	cErrorMessage = ''
		&& The error message if the operation failed
	cWindowMode   = 'HID'
		&& the window mode

	function Init

* Declare the Sleep API function.

		declare Sleep in Win32API integer nMilliseconds
	endfunc

	function UnZip(tcZipFile, tcFolder)
		local lcFolder, ;
			llResult, ;
			lcZipFile, ;
			loException as Exception, ;
			loShell, ;
			loFiles, ;
			lcCommand, ;
			lcMessage

* Ensure we have valid parameters.

		do case
			case vartype(tcZipFile) <> 'C' or empty(tcZipFile)
				This.cErrorMessage = 'The zip file was not specified'
			case vartype(tcFolder) <> 'C' or empty(tcFolder)
				This.cErrorMessage = 'The folder was not specified'

* Ensure the file exists.

			case not file(tcZipFile)
				This.cErrorMessage = tcZipFile + ' does not exist'

* Create the extraction folder if necessary.

			otherwise
				lcFolder = GetProperFileCase(fullpath(tcFolder))
				if not directory(lcFolder)
					try
						md (lcFolder)
						llResult = .T.
					catch to loException
						This.cErrorMessage = 'Error creating ' + lcFolder + ': ' + ;
							loException.Message
					endtry
					if not llResult
						return .F.
					endif not llResult
				endif not directory(lcFolder)

* Try to use Shell.Application to extract files.

				llResult  = .F.
				lcZipFile = fullpath(tcZipFile)
				try
					loShell = createobject('Shell.Application')
					loFiles = loShell.NameSpace(lcZipFile).Items
					if loFiles.Count > 0
						loShell.NameSpace(lcFolder).CopyHere(loFiles, cnSHELL_YES_TO_ALL)
						llResult = .T.
					endif loFiles.Count > 0
				catch to loException
				endtry

* If that failed, use PowerShell.

				if not llResult
					lcCommand = 'cmd /c %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe ' + ;
						'Microsoft.Powershell.Archive\Expand-Archive -Force ' + ;
						"-Path '" + lcZipFile + "' " + ;
						"-DestinationPath '" + lcFolder + "'"
					lcMessage = ExecuteCommand(lcCommand, lcFolder, This.cWindowMode)
					llResult  = empty(lcMessage)
					if not llResult
						This.cErrorMessage = lcMessage
					endif not llResult
				endif not llResult
		endcase
		return llResult
	endfunc

	function Zip(tcFiles, tcZipFile, tlOverwrite)
		local laFiles[1], ;
			lnFiles, ;
			lcFiles, ;
			lnI, ;
			lcTarget, ;
			llOK, ;
			lnHandle, ;
			loShell, ;
			loZipFile, ;
			lcFile, ;
			llResult, ;
			loException as Exception, ;
			lcCommand, ;
			lcMessage

* Ensure we have valid parameters.

		do case
			case vartype(tcFiles) <> 'C' or empty(tcFiles)
				This.cErrorMessage = 'The files were not specified'
			case vartype(tcZipFile) <> 'C' or empty(tcZipFile)
				This.cErrorMessage = 'The zip file was not specified'

* Create an empty Zip file if we're supposed to, then try to use Shell.Application
* to add files to it.

			otherwise
				lnFiles = alines(laFiles, tcFiles, 1 + 4, ccCR, ccLF, ',')
				lcFiles = ''
				for lnI = 1 to lnFiles
					lcFile  = GetProperFileCase(fullpath(laFiles[lnI]))
					lcFiles = lcFiles + iif(empty(lcFiles), '', ',') + "'" + lcFile + "'"
					if not file(lcFile)
						This.cErrorMessage = lcFile + ' does not exist'
						return .F.
					endif not file(lcFile)
				next lnI
				try
					lcTarget = GetProperFileCase(fullpath(tcZipFile))
					llOK     = .T.
					if not file(lcTarget) or tlOverwrite
						lnHandle = fcreate(lcTarget)
						if lnHandle > 0
							fclose(lnHandle)
						else
							llOK = .F.
						endif lnHandle > 0
					endif not file(lcTarget) ...
					if llOK
						loShell   = createobject('Shell.Application')
						loZipFile = loShell.NameSpace(lcTarget)
						for lnI = 1 to lnFiles
							lcFile = GetProperFileCase(fullpath(laFiles[lnI]))
							loZipFile.CopyHere(lcFile)
							do while loZipFile.Items.Count < lnI
								Sleep(1000)
							enddo while loZipFile.Items.Count < lnI
						next lnI
						llResult = .T.
					endif llOK
				catch to loException
				endtry
				if not llOK
					This.cErrorMessage = 'Cannot create ' + lcTarget + '.'
					return .F.
				endif not llOK

* If that failed, use PowerShell.

				if not llResult
					lcCommand = 'cmd /c %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe ' + ;
						'Microsoft.Powershell.Archive\Compress-Archive ' + ;
						'-Path @(' + lcFiles + ') ' + ;
						"-DestinationPath '" + lcTarget + "'" + ;
						iif(tlOverwrite, '', ' -Update')
					lcMessage = ExecuteCommand(lcCommand, justpath(lcTarget), This.cWindowMode)
					llResult  = empty(lcMessage)
					if not llResult
						This.cErrorMessage = lcMessage
					endif not llResult
				endif not llResult
		endcase
		return llResult
	endfunc
enddefine
