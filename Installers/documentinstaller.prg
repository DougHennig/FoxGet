lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('DocumentInstaller')
loInstaller.Install()

define class DocumentInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/DougHennig/Document/main/'

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('FoxGet/source.zip')
	endfunc

* Custom installation tasks: copy the files from the extraction folder to the package folder.

	function InstallPackage
		local llOK
		llOK = This.CopyExtractedFiles('*.*')
		llOK = llOK and This.AddFileToProject('document.vcx')
		return llOK
	endfunc
enddefine
