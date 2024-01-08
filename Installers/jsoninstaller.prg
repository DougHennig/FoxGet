* JSONINSTALLER.PRG
* INSTALLER HOOK FOR FOXGET PACKAGE MANAGER
*
define class JSONInstaller as FoxGet of FoxGet.prg
    cBaseURL = 'https://raw.githubusercontent.com/vespina/json/main/'

    function Setup
        This.AddFile('json.prg', .T., This.cPackagePath)
    endfunc
enddefine