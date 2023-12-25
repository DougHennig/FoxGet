lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
 loInstaller = createobject('DPIAwareManagerInstaller')
loInstaller.Install()

define class DPIAwareManagerInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/atlopes/DPIAwareManager/master/source/'

* Define the file to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add the file to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('dpiawaremanager.prg', .T., This.cPackagePath)
	endfunc
enddefine
