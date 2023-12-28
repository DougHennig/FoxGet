lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('SFMailInstaller')
loInstaller.Install()

define class SFMailInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/DougHennig/SFMail/master/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform. Also, we don't install wwDotNetBridge files;
* they'll be installed as a dependency.

	function Setup
		This.AddFile('BouncyCastle.Crypto.dll', .F., This.cPackagePath)
		This.AddFile('MailKit.dll',             .F., This.cPackagePath)
		This.AddFile('MimeKit.dll',             .F., This.cPackagePath)
		This.AddFile('SMTPLibrary2.dll',        .F., This.cPackagePath)
		This.AddFile('sfmail.prg',              .T., This.cPackagePath)
		This.AddFile('vfpexmapi.fll',           .F., This.cPackagePath)
	endfunc
enddefine
