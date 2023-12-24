lcPath = addbs(justpath(sys(16)))
set procedure to (lcPath + 'foxget.prg') additive
loInstaller = createobject('DPIAwareManagerInstaller')
loInstaller.Install()

define class DPIAwareManagerInstaller as FoxGet of FoxGet.prg

* Define the file to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add the file to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('https://raw.githubusercontent.com/atlopes/DPIAwareManager/master/source/dpiawaremanager.prg', ;
			.T., This.cPackagePath)
	endfunc
enddefine
