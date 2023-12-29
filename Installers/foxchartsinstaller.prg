lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('FoxChartsInstaller')
loInstaller.Install()

define class FoxChartsInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/FoxCharts/master/FoxCharts1.47b/Source/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('System.app',    .F., This.cPackagePath)
		This.AddFile('foxcharts.vct', .F., This.cPackagePath)
		This.AddFile('foxcharts.vcx', .T., This.cPackagePath)
		This.AddFile('gdiplusx.VCT',  .F., This.cPackagePath)
		This.AddFile('gdiplusx.vcx',  .T., This.cPackagePath)
	endfunc
enddefine
