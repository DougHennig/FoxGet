lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('cboMultiSelInstaller')
loInstaller.Install()

define class cboMultiSelInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/cboMultiSel/master/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('cboMultiSel.VCT', .F., This.cPackagePath)
		This.AddFile('cboMultiSel.VCX', .T., This.cPackagePath)
	endfunc
enddefine
