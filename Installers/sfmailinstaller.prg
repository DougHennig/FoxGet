lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('SFMailInstaller')
loInstaller.Install()

define class SFMailInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/DougHennig/SFMail/master/'

* Define the files to download. Note that URLs are case-sensitive. Note that we
* don't download the wwDotNetBridge files; they'll be installed as a
* dependency.

	function Setup
		This.AddFile('BouncyCastle.Crypto.dll', .F., This.cPackagePath)
		This.AddFile('MailKit.dll',             .F., This.cPackagePath)
		This.AddFile('MimeKit.dll',             .F., This.cPackagePath)
		This.AddFile('SMTPLibrary2.dll',        .F., This.cPackagePath)
		This.AddFile('sfmail.prg',              .T., This.cPackagePath)
		This.AddFile('vfpexmapi.fll',           .T., This.cPackagePath)
	endfunc
enddefine
