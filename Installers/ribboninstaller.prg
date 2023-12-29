lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('RibbonInstaller')
loInstaller.Install()

define class RibbonInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/DougHennig/Ribbon/master/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('ribbonthemes.xml',       .T., This.cPackagePath)
		This.AddFile('sfgdimeasurestring.prg', .T., This.cPackagePath)
		This.AddFile('sfribbon.vct',           .F., This.cPackagePath)
		This.AddFile('sfribbon.vcx',           .T., This.cPackagePath)
		This.AddFile('sfribboncheck.png',      .T., This.cPackagePath)
		This.AddFile('sfribbondown.png',       .T., This.cPackagePath)
		This.AddFile('sfribbondownlarge.png',  .T., This.cPackagePath)
		This.AddFile('sfribbonright.png',      .T., This.cPackagePath)
		This.AddFile('system.app',             .T., This.cPackagePath)
	endfunc
enddefine
