lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('VFPCompressionFLLInstaller')
loInstaller.Install()

define class VFPCompressionFLLInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/VFPCompressionFLL/main/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('vfpcompressionfll.prg', .T., This.cPackagePath)
		This.AddFile('zlibwapi.dll', .F., This.cPackagePath)
	endfunc
enddefine
