lcPath = addbs(justpath(sys(16)))
set procedure to (lcPath + 'foxget.prg') additive
loInstaller = createobject('VFPXWorkbookXLSXInstaller')
loInstaller.Install()

define class VFPXWorkbookXLSXInstaller as FoxGet of FoxGet.prg

* Define the file to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('https://raw.githubusercontent.com/ggreen86/XLSX-Workbook-Class/master/WorkbookXLSX%20R39.zip')
	endfunc

* Custom installation tasks: copy just the class library and include file from
* the extraction folder to the package folder and add the VCX to the project.

	function InstallPackage
		local llOK
		llOK = This.CopyExtractedFiles('vfpxworkbookxlsx.*')
		llOK = llOK and This.AddFileToProject('vfpxworkbookxlsx.vcx')
		return llOK
	endfunc
enddefine
