lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('OOPMenuInstaller')
loInstaller.Install()

define class OOPMenuInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/OOPMenu/master/Source/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('copyxpsmall.bmp',   .T., This.cPackagePath)
		This.AddFile('copyxpsmall.msk',   .T., This.cPackagePath)
		This.AddFile('cutxpsmall.bmp',    .T., This.cPackagePath)
		This.AddFile('helpxpsmall.bmp',   .T., This.cPackagePath)
		This.AddFile('pastexpsmall.bmp',  .T., This.cPackagePath)
		This.AddFile('redoxpsmall.bmp',   .T., This.cPackagePath)
		This.AddFile('sfctrls.h',         .F., This.cPackagePath)
		This.AddFile('sfdynamicmenu.vcx', .T., This.cPackagePath)
		This.AddFile('sfdynamicmenu.vct', .F., This.cPackagePath)
		This.AddFile('sfmenu.vcx',        .T., This.cPackagePath)
		This.AddFile('sfmenu.vct',        .F., This.cPackagePath)
		This.AddFile('undoxpsmall.bmp',   .T., This.cPackagePath)
	endfunc
enddefine
