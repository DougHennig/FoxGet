lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('XLSXWorkbookInstaller')
loInstaller.Install()

define class XLSXWorkbookInstaller as FoxGet of FoxGet.prg
	cBaseURL = 'https://raw.githubusercontent.com/ggreen86/XLSX-Workbook-Class/master/'

* Define the file to download. Note that URLs are case-sensitive.

	function Setup
		This.AddFile('WorkbookXLSX%20R39.zip')
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
