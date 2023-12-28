lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('wwDotNetBridgeInstaller')
loInstaller.Install()

define class wwDotNetBridgeInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/RickStrahl/wwDotnetBridge/master/Distribution/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('ClrHost.dll',        .F., This.cPackagePath)
		This.AddFile('wwDotNetBridge.dll', .F., This.cPackagePath)
		This.AddFile('wwDotnetBridge.PRG', .T., This.cPackagePath)
	endfunc
enddefine
