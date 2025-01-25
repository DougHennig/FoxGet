lcPath = addbs(justpath(sys(16)))
set procedure to (forcepath('foxget.prg', fullpath('..\Source\', lcPath)))  additive
loInstaller = createobject('PdfiumVfpInstaller')
loInstaller.Install()

define class PdfiumVfpInstaller as FoxGet of FoxGet.prg
    cBaseURL = 'https://raw.githubusercontent.com/dmitriychunikhin/pdfium-vfp/main/Release/'

* Define the files to download. Note that URLs are case-sensitive. Also, we'll
* download directly to the package folder since there's nothing to unzip, and
* we'll add certain files to the project. Since FoxGet does all that, there are
* no custom tasks to perform.

    function Setup
        This.AddFile('pdfium-vfp.vcx',         .F., This.cPackagePath)
        This.AddFile('pdfium-vfp.vct',         .F., This.cPackagePath)
        This.AddFile('pdfiumreport.app',       .F., This.cPackagePath)
        This.AddFile('pdfium.dll',             .F., This.cPackagePath)
        This.AddFile('pdfium-vfp.dll',         .F., This.cPackagePath)
        This.AddFile('pdfium64.dll',           .F., This.cPackagePath)
        This.AddFile('pdfium-vfp64.dll',       .F., This.cPackagePath)
    endfunc
enddefine
