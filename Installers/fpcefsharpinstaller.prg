lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath))) additive
loInstaller = createobject('fpCefSharpInstaller')
loInstaller.Install()

define class fpCefSharpInstaller as FoxGet of FoxGet.prg

* Define the file to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('https://github.com/cwollenhaupt/fpCefSharp/releases/download/v97.1.61.3/fpCefSharp.v97.1.61.3.core.zip')
	endfunc

* Custom installation tasks: copy all the extracted files from the extraction
* folder to the package folder and add a couple of PRGs to the project.

	function InstallPackage
		local llOK
		llOK = This.CopyExtractedFiles('*.*')
		llOK = llOK and This.AddFileToProject('cefsharpbrowser.prg')
		llOK = llOK and This.AddFileToProject('wwdotnetbridge.prg')
		return llOK
	endfunc

* Custom uninstallation tasks: remove the PRGs from the project.

	function UninstallPackage
		local llOK
		llOK = This.RemoveFileFromProject('cefsharpbrowser.prg')
		llOK = llOK and This.RemoveFileFromProject('wwdotnetbridge.prg')
		return llOK
	endfunc
enddefine
