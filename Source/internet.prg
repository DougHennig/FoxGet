#define cnBUFFER_SIZE					32767
#define INTERNET_OPEN_TYPE_PRECONFIG	0
#define INTERNET_OPEN_TYPE_DIRECT		1
#define INTERNET_OPEN_TYPE_PROXY		3
#define SYNCHRONOUS						0
#define INTERNET_FLAG_RELOAD			2147483648

define class Internet as Custom
	cErrorMessage = ''

	function Download(toFiles)
		local lhInternetSession, ;
			llReturn, ;
			loFile, ;
			lcURL, ;
			lhURL, ;
			lcReturn, ;
			llOK, ;
			lcReadBuffer, ;
			lnBytesRead, ;
			loException as Exception

* Declare the Win32API functions we need.

		declare integer InternetOpen in wininet.dll ;
			string sAgent, ;
			integer lAccessType, ;
			string sProxyName,	;
			string sProxyBypass, ;
			integer lFlags
		declare integer InternetOpenUrl in wininet.dll ;
			integer hInternetSession, ;
			string sUrl, ;
			string sHeaders,	;
			integer lHeadersLength, ;
			integer lFlags, ;
			integer lContext
		declare integer InternetReadFile in wininet.dll ;
			integer hfile, ;
			string @sBuffer, ;
			integer lNumberofBytesToRead, ;
			integer @lBytesRead
		declare short InternetCloseHandle in wininet.dll ;
			integer hInst

* Connect to the internet.

		lcMessage = 'Contacting server'
		raiseevent(This, 'Update', lcMessage)
		lhInternetSession = InternetOpen('VFP', INTERNET_OPEN_TYPE_PRECONFIG, ;
			'', '', SYNCHRONOUS)
		if lhInternetSession = 0
			This.cErrorMessage = 'Internet session cannot be established'
			return .F.
		endif lhInternetSession = 0

* Download each file. Start by connecting to the URL.

		llReturn = .T.
		for each loFile in toFiles foxobject
			lcURL = loFile.cURL
			lhURL = InternetOpenUrl(lhInternetSession, lcURL, '', 0, ;
				INTERNET_FLAG_RELOAD, 0)
			if lhURL = 0
				This.cErrorMessage = lcURL + ' cannot be opened'
				llReturn = .F.
				exit
			else
				lcMessage = 'Downloading file ' + justfname(lcURL)
				raiseevent(This, 'Update', lcMessage)
			endif lhURL = 0

* Download the file.

			lcReturn = ''
			llOK	 = .T.
			do while llOK
				lcReadBuffer = space(cnBUFFER_SIZE)
				lnBytesRead	 = 0
				lnOK		 = InternetReadFile(lhURL, @lcReadBuffer, cnBUFFER_SIZE, ;
					@lnBytesRead)
				if lnBytesRead > 0
					if empty(lcReturn) and lnBytesRead < 50 and ;
						left(lcReadBuffer, 3) = '404'
						This.cErrorMessage = 'URL not found'
						llReturn = .F.
						exit
					endif empty(lcReturn) ...
					lcReturn = lcReturn + left(lcReadBuffer, lnBytesRead)
				endif lnBytesRead > 0
				llOK = lnOK = 1 and lnBytesRead > 0
			enddo while llOK
			InternetCloseHandle(lhURL)

* Write the download file.

			if llReturn
				try
					erase (loFile.cLocalFile)
					strtofile(lcReturn, loFile.cLocalFile)
				catch to loException
					llReturn = .F.
					This.cErrorMessage = 'Error saving file: ' + loException.Message
				endtry
			else
				exit
			endif llReturn
		next loFile

* Close the internet handle.

		InternetCloseHandle(lhInternetSession)
		return llReturn
	endfunc

* This method is here so we can use RAISEEVENT to tell anything listening what's
* happening.

	function Update(tcMessage)
	endfunc
enddefine
