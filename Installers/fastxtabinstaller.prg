lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('FastXTabInstaller')
loInstaller.Install()

define class FastXTabInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/FastXTab/master/fastxtab%201.6/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('fastxtab.PRG', .T., This.cPackagePath)
		This.AddFile('fastxtaben.h', .F., This.cPackagePath)
		This.AddFile('fastxtabro.h', .F., This.cPackagePath)
		This.AddFile('fastxtabru.h', .F., This.cPackagePath)
	endfunc
enddefine
