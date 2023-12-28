lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('SFMailInstaller')
loInstaller.Install()

define class SFMailInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/DougHennig/SFMail/master/ThorUpdater/'

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('SFMail.zip')
	endfunc

* Custom installation tasks: copy the files from the extraction folder to the
* package folder and add SFMail.prg to the project.

	function InstallPackage
		local llOK
		llOK = This.CopyExtractedFiles('*.*')
		llOK = llOK and This.AddFileToProject('sfmail.prg')
		return llOK
	endfunc

* Custom uninstallation tasks: remove SFMail.prg from the project.

	function UninstallPackage
		local llOK
		llOK = This.RemoveFileFromProject('sfmail.prg')
		return llOK
	endfunc
enddefine
