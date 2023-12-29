lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('Log4VFPInstaller')
loInstaller.Install()

define class Log4VFPInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/Log4VFP/master/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('Log4VFP.dll',    .F., This.cPackagePath)
		This.AddFile('compact.config', .F., This.cPackagePath)
		This.AddFile('log4net.dll',    .F., This.cPackagePath)
		This.AddFile('log4vfp.prg',    .T., This.cPackagePath)
	endfunc
enddefine
