lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('FoxBarCodeQRInstaller')
loInstaller.Install()

define class FoxBarCodeQRInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/VFPX/FoxBarCodeQR/master/FoxBarcodeQR_v_2_10/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

	function Setup
		This.AddFile('foxbarcodeqr.prg',   .T., This.cPackagePath)
		This.AddFile('BarCodeLibrary.dll', .F., This.cPackagePath)
		This.AddFile('qrcodelib.dll',      .F., This.cPackagePath)
	endfunc
enddefine
