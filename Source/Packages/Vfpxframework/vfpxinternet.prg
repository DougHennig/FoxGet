define class VFPXInternet as Custom
	cErrorMessage = ''
		&& The error message if the operation failed
	cWindowMode   = 'HID'
		&& the window mode

	function DownloadFile(tcRemoteFile, tcLocalFile, tcServer, tcUserName, tcPassword)
		local lcCommand, ;
			lcMessage, ;
			llReturn
		do case

* Ensure we have valid parameters.

			case vartype(tcRemoteFile) <> 'C' or empty(tcRemoteFile)
				This.cErrorMessage = 'The remote file was not specified'
			case vartype(tcLocalFile) <> 'C' or empty(tcLocalFile)
				This.cErrorMessage = 'The local file was not specified'

* Download the file using curl.

			otherwise
				lcCommand = 'curl.exe -o "' + tcLocalFile + '" -L ' + ;
					iif(empty(tcServer), '', 'ftp://' + tcServer + ;
						iif(right(tcServer, 1) = '/' or left(tcRemoteFile, 1) = '/', '', '/')) + ;
					tcRemoteFile + iif(empty(tcUserName), '', ' -u ' + tcUserName + ':' + ;
					tcPassword)
				lcMessage = ExecuteCommand(lcCommand, , This.cWindowMode)
				llReturn  = empty(lcMessage)
				if not llReturn
					This.cErrorMessage = lcMessage
				endif not llReturn
		endcase
		return llReturn
	endfunc

	function UploadFile(tcRemoteFile, tcLocalFile, tcServer, tcUserName, tcPassword)
		local lcCommand, ;
			lcMessage, ;
			llReturn
		do case

* Ensure we have valid parameters.

			case vartype(tcRemoteFile) <> 'C' or empty(tcRemoteFile)
				This.cErrorMessage = 'The remote file was not specified'
			case vartype(tcLocalFile) <> 'C' or empty(tcLocalFile)
				This.cErrorMessage = 'The local file was not specified'
			case vartype(tcServer) <> 'C' or empty(tcServer)
				This.cErrorMessage = 'The server was not specified'
			case empty(tcUserName)
				This.cErrorMessage = 'The user name was not specified'
			case empty(tcPassword)
				This.cErrorMessage = 'The password was not specified'

* Upload the file using curl.

			otherwise
				lcCommand = 'curl.exe -T "' + tcLocalFile + '" ftp://' + tcServer + ;
					iif(right(tcServer, 1) = '/' or left(tcRemoteFile, 1) = '/', '', '/') + ;
					tcRemoteFile + ' -u ' + tcUserName + ':' + tcPassword
				lcMessage = ExecuteCommand(lcCommand, , This.cWindowMode)
				llReturn  = empty(lcMessage)
				if not llReturn
					This.cErrorMessage = lcMessage
				endif not llReturn
		endcase
		return llReturn
	endfunc
enddefine
