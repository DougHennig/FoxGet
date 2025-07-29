lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('DocumentInstaller')
loInstaller.Install()

define class DocumentInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/DougHennig/Document/main/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('AWSSDK.Core.dll', .F., This.cPackagePath)
		This.AddFile('AWSSDK.S3.dll',   .F., This.cPackagePath)
		This.AddFile('Document.dll',    .F., This.cPackagePath)
		This.AddFile('document.vct',    .F., This.cPackagePath)
		This.AddFile('document.vcx',    .T., This.cPackagePath)
	endfunc
enddefine
