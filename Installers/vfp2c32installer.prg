lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('VFP2C32Installer')
loInstaller.Install()

define class VFP2C32Installer as FoxGet of FoxGet.prg

* Define the file to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('https://github.com/ChristianEhlscheid/vfp2c32/releases/download/v2.0.0.41/vfp2c32.zip')
	endfunc

* Custom installation tasks: copy just the contents of the VFP2C32 subdirectory of  the extraction folder to the package folder.

	function InstallPackage
		local llOK
		llOK = This.CopyExtractedFiles('vfp2c32/*.*')
		return llOK
	endfunc
enddefine
