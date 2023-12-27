lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('GaugeInstaller')
loInstaller.Install()

define class GaugeInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/Gauge/master/ThorUpdater'

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('Gauge.zip')
	endfunc

* Custom installation tasks: copy the files from the extraction folder to the
* package folder, add some of them to the project, and erase the ones we don't
* want. Note we don't install SFMail files; they'll be installed as a
* dependency.

	function InstallPackage
		local llOK
		llOK = This.CopyFile(This.cExtractionPath + 'Source\clrhost.dll', ;
			This.cPackagePath)
		llOK = llOK and This.CopyFile(This.cExtractionPath + 'Source\gauge.*', ;
			This.cPackagePath)
		llOK = llOK and This.CopyFile(This.cExtractionPath + 'Source\wwdotnetbridge.*', ;
			This.cPackagePath)
		llOK = llOK and This.AddFileToProject('gauge.vcx', ;
			This.cPackagePath)
		llOK = llOK and This.AddFileToProject('wwdotnetbridge.prg', ;
			This.cPackagePath)
		if llOK
			erase (This.cPackagePath + '*.??2')
		endif llOK
		return llOK
	endfunc

* Custom uninstallation tasks: remove files from the project.

	function UninstallPackage
		local llOK
		llOK = This.RemoveFileFromProject('gauge.vcx')
*** TODO: dependency on wwDNB: don't remove!
		llOK = llOK and This.RemoveFileFromProject('wwdotnetbridge.prg')
		return llOK
	endfunc
enddefine
