lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('VFP_RegExpInstaller')
loInstaller.Install()

define class VFP_RegExpInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/atlopes/VFP_RegExp/main/src/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('regexvfp_pcre.prg', .T., This.cPackagePath)
		This.AddFile('libpcre2-8.dll', .F., This.cPackagePath)
	endfunc
enddefine
