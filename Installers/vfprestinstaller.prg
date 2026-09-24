lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('VFPRESTInstaller')
loInstaller.Install()

define class VFPRESTInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/DougHennig/VFPREST/main/'

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('FoxGet/Source.zip')
	endfunc

* Custom installation tasks: copy the files from the extraction folder to the
* package folder and add them to the project.

	function InstallPackage
		local llOK
		llOK = This.CopyExtractedFiles('*.*')
		llOK = llOK and This.AddFileToProject('baserest.prg')
		llOK = llOK and This.AddFileToProject('foxcryptong.prg')
		llOK = llOK and This.AddFileToProject('jsonformat.prg')
		llOK = llOK and This.AddFileToProject('nfjsoncreate.prg')
		llOK = llOK and This.AddFileToProject('nfjsonread.prg')
		llOK = llOK and This.AddFileToProject('readini.prg')
		return llOK
	endfunc

* Custom uninstallation tasks: remove files from the project. Note that we don't remove
* nfJSON, FoxCryptoNG, or ReadINI.prg since they may used for other things.

	function UninstallPackage
		local llOK
		llOK = This.RemoveFileFromProject('baserest.prg')
		return llOK
	endfunc
enddefine
