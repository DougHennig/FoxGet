lcPath = addbs(justpath(sys(16)))
set procedure to (lcPath + 'foxget.prg') additive
loInstaller = createobject('ErrorHandlerInstaller')
loInstaller.Install()

define class ErrorHandlerInstaller as FoxGet of FoxGet.prg

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('https://raw.githubusercontent.com/DougHennig/ErrorHandler/master/ThorUpdater/ErrorHandler.zip')
	endfunc

* Custom installation tasks: copy the files from the extraction folder to the
* package folder and add some of them to the project.

	function InstallPackage
		local llOK
		llOK = This.CopyExtractedFiles('*.*')
		llOK = llOK and This.AddFileToProject('sferrormgr.vcx')
		llOK = llOK and This.AddFileToProject('sflocalize.vcx')
		llOK = llOK and This.AddFileToProject('sfconsole.vcx')
		llOK = llOK and This.AddFileToProject('sfmail.prg')
		llOK = llOK and This.AddFileToProject('wwdotnetbridge.prg')
		llOK = llOK and This.AddFileToProject('errorheader.gif')
		llOK = llOK and This.AddFileToProject('resource.dbf')
		if llOK
			erase (This.cPackagePath + 'sample.*')
			erase (This.cPackagePath + '*.??2')
		endif llOK
		return llOK
	endfunc
enddefine
