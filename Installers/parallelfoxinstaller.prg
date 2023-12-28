lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('ParallelFoxInstaller')
loInstaller.Install()

define class ParallelFoxInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/ParallelFox/master/'

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('parallelfox.VCT', .F., This.cPackagePath)
		This.AddFile('parallelfox.vcx', .T., This.cPackagePath)
		This.AddFile('parallelfox.exe', .F., This.cPackagePath)
		This.AddFile('install.PRG',     .F., This.cPackagePath)
		This.AddFile('ffi/parfoxcode.DBF')
		This.AddFile('ffi/parfoxcode.FPT')
	endfunc

* Custom installation tasks: copy just the class library and EXE from
* the download folder to the package folder and add the VCX to the project.

	function InstallPackage
		local llOK
		md (This.cPackagePath + 'ffi')
		llOK = This.CopyFile(This.cWorkingPath + 'parfoxcode.*', This.cPackagePath + 'ffi')
		if llOK
			do (This.cPackagePath + 'install')
			erase (This.cPackagePath + 'install.*')
			This.FileOperation(This.cPackagePath + 'ffi', '', 'DELETE')
		endif llOK
		return llOK
	endfunc
enddefine
