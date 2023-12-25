lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('ParallelFoxInstaller')
loInstaller.Install()

define class ParallelFoxInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/ParallelFox/master/'

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
*** TODO: have a zip file instead
		This.AddFile('parallelfox.VCT')
		This.AddFile('parallelfox.vcx', .T.)
		This.AddFile('parallelfox.exe')
		This.AddFile('install.PRG')
		This.AddFile('ffi/parfoxcode.DBF')
		This.AddFile('ffi/parfoxcode.FPT')
*** TODO: need DMULT.DLL?
	endfunc

	function InstallPackage
		local llOK
*** TODO: because ParallelFox is a COM object, either use COM-free or install in a common folder
		llOK = This.CopyFile(This.cWorkingPath + 'parallelfox.*', This.cPackagePath)
		llOK = llOK and This.CopyFile(This.cWorkingPath + 'install.prg', This.cPackagePath)
		if llOK
			md (This.cPackagePath + 'ffi')
			llOK = This.CopyFile(This.cWorkingPath + 'parfoxcode.*', This.cPackagePath + 'ffi')
			if llOK
				do (This.cPackagePath + 'install')
				erase (This.cPackagePath + 'install.*')
				This.FileOperation(This.cPackagePath + 'ffi', '', 'DELETE')
			endif llOK
		endif llOK
		return llOK
	endfunc
enddefine
