lcPath = addbs(justpath(sys(16)))
set procedure to (lcPath + 'foxget.prg') additive
loInstaller = createobject('ParallelFoxInstaller')
loInstaller.Install()

define class ParallelFoxInstaller as FoxGet of FoxGet.prg

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
*** TODO: have a zip file instead
		This.AddFile('https://raw.githubusercontent.com/VFPX/ParallelFox/master/parallelfox.VCT')
		This.AddFile('https://raw.githubusercontent.com/VFPX/ParallelFox/master/parallelfox.vcx', .T.)
		This.AddFile('https://raw.githubusercontent.com/VFPX/ParallelFox/master/parallelfox.exe')
		This.AddFile('https://raw.githubusercontent.com/VFPX/ParallelFox/master/install.PRG')
		This.AddFile('https://raw.githubusercontent.com/VFPX/ParallelFox/master/ffi/parfoxcode.DBF')
		This.AddFile('https://raw.githubusercontent.com/VFPX/ParallelFox/master/ffi/parfoxcode.FPT')
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
