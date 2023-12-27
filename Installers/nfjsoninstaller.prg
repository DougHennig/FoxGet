lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('nfJSONInstaller')
loInstaller.Install()

define class nfJSONInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/nfJson/master/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('jsonFormat.prg',         .T., This.cPackagePath)
		This.AddFile('nfCursorToJson4vfp.PRG', .T., This.cPackagePath)
		This.AddFile('nfOpenJson.PRG',         .T., This.cPackagePath)
		This.AddFile('nfcursortojson.prg',     .T., This.cPackagePath)
		This.AddFile('nfcursortoobject.prg',   .T., This.cPackagePath)
		This.AddFile('nfjsoncreate.PRG',       .T., This.cPackagePath)
		This.AddFile('nfjsonread.PRG',         .T., This.cPackagePath)
		This.AddFile('nfjsontocursor.PRG',     .T., This.cPackagePath)
	endfunc
enddefine
