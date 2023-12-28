lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('GaugeInstaller')
loInstaller.Install()

define class GaugeInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/Gauge/master/Source/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform. Also, we don't install wwDotNetBridge files;
* they'll be installed as a dependency.

	function Setup
		This.AddFile('Gauge.dll', .F., This.cPackagePath)
		This.AddFile('gauge.VCT', .F., This.cPackagePath)
		This.AddFile('gauge.vcx', .T., This.cPackagePath)
	endfunc
enddefine
