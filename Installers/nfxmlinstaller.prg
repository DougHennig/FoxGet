lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('nfXMLInstaller')
loInstaller.Install()

define class nfXMLInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/nfJson/master/nfXML/nfXml/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('NFXML.H',         .F., This.cPackagePath)
		This.AddFile('nfXmlCreate.PRG', .T., This.cPackagePath)
		This.AddFile('nfXmnlRead.prg',  .T., This.cPackagePath)
		This.AddFile('nfxpaths.prg',    .T., This.cPackagePath)
	endfunc
enddefine
