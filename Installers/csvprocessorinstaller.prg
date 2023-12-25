lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('CSVProcessorInstaller')
loInstaller.Install()

define class CSVProcessorInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/atlopes/csv/master/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('csv-processor.prg', .T., This.cPackagePath)
		This.AddFile('csv.prg', .T., This.cPackagePath)
		This.AddFile('https://raw.githubusercontent.com/atlopes/names/master/namer.prg', ;
			.T., This.cPackagePath)
		This.AddFile('https://raw.githubusercontent.com/atlopes/names/master/vfp-names.prg', ;
			.T., This.cPackagePath)
	endfunc
enddefine
