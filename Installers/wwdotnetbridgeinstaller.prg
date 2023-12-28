lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('wwDotNetBridgeInstaller')
loInstaller.Install()

define class wwDotNetBridgeInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/RickStrahl/wwDotnetBridge/master/Distribution/'

* Define the files to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('ClrHost.dll',        .F., This.cPackagePath)
		This.AddFile('wwDotNetBridge.dll', .F., This.cPackagePath)
		This.AddFile('wwDotnetBridge.PRG', .T., This.cPackagePath)
	endfunc
enddefine
