lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('ErrorHandlerInstaller')
loInstaller.Install()

define class ErrorHandlerInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/DougHennig/ErrorHandler/master/ThorUpdater/'

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('ErrorHandler.zip')
		This.AddDependency('SFMail')
	endfunc

* Custom installation tasks: copy the files from the extraction folder to the
* package folder, add some of them to the project, and erase the ones we don't
* want.

	function InstallPackage
		local llOK
		llOK = This.CopyExtractedFiles('*.*')
		llOK = llOK and This.AddFileToProject('sferrormgr.vcx')
		llOK = llOK and This.AddFileToProject('sflocalize.vcx')
		llOK = llOK and This.AddFileToProject('sfconsole.vcx')
*		llOK = llOK and This.AddFileToProject('sfmail.prg')
*		llOK = llOK and This.AddFileToProject('wwdotnetbridge.prg')
		llOK = llOK and This.AddFileToProject('errorheader.gif')
		llOK = llOK and This.AddFileToProject('resource.dbf')
		if llOK
			erase (This.cPackagePath + 'sample.*')
			erase (This.cPackagePath + '*.??2')
		endif llOK
		return llOK
	endfunc

* Custom uninstallation tasks: remove files from the project.

	function UninstallPackage
		local llOK
		llOK = This.RemoveFileFromProject('sferrormgr.vcx')
		llOK = llOK and This.RemoveFileFromProject('sflocalize.vcx')
		llOK = llOK and This.RemoveFileFromProject('sfconsole.vcx')
*** TODO: only remove if we added it
		llOK = llOK and This.RemoveFileFromProject('sfmail.prg')
*** TODO: only remove if we added it
		llOK = llOK and This.RemoveFileFromProject('wwdotnetbridge.prg')
		llOK = llOK and This.RemoveFileFromProject('errorheader.gif')
		llOK = llOK and This.RemoveFileFromProject('resource.dbf')
		return llOK
	endfunc
enddefine
