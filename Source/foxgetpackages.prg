#define FOXGETPACKAGES_TARGET ..\Installers\FoxGetPackages.dbf

LOCAL loFoxGetPackages
loFoxGetPackages = NEWOBJECT("FoxGetPackages")
IF VARTYPE(loFoxGetPackages) = "O"
    loFoxGetPackages.UpdateFromThor()
ENDIF    



DEFINE CLASS FoxGetPackages as Custom 

    cWorkingPath    = '' && a temporary path for working files
        
    lOpenFoxGetPackages = .F.

    FUNCTION Init
        This.cWorkingPath  = addbs(sys(2023)) + 'FoxGetPackages\'
        
        LOCAL llOK
        llOK = .T.
        
        IF DIRECTORY(This.cWorkingPath) = .F.
            LOCAL loException
            loException = .F.
            TRY
                MD (This.cWorkingPath)
            CATCH TO loException
                lcMessage = 'Cannot create ' + This.cWorkingPath + ': ' + loException.Message

                WAIT WINDOW lcMessage
                
                llOK = .F.
            ENDTRY
        ENDIF
        
        RETURN llOK
        
    ENDFUNC
    
    FUNCTION Destroy
        IF USED("FoxGetPackages") AND This.lOpenFoxGetPackages
            USE IN FoxGetPackages
        ENDIF
    ENDFUNC


    HIDDEN FUNCTION Download
        * Download the FoxGet packages list.

        loInternet  = newobject('VFPXInternet', 'VFPXInternet.prg')
        lcURL       = 'https://raw.githubusercontent.com/DougHennig/FoxGet/main/Installers/foxgetpackages.dbf'
        lcLocalFile = This.cWorkingPath + 'foxgetpackages.dbf'
        llOK = loInternet.DownloadFile(lcURL, lcLocalFile)
        IF not llOK
            messagebox(loInternet.cErrorMessage, 16, 'FoxGet')
            return .F.
        ENDIF
        lcURL       = 'https://raw.githubusercontent.com/DougHennig/FoxGet/main/Installers/foxgetpackages.fpt'
        lcLocalFile = This.cWorkingPath + 'foxgetpackages.fpt'
        llOK = loInternet.DownloadFile(lcURL, lcLocalFile)
        IF not llOK
            MESSAGEBOX(loInternet.cErrorMessage, 16, 'FoxGet')
            return .F.
        ENDIF
        
        USE (This.cWorkingPath + 'foxgetpackages')
        
        This.lOpenFoxGetPackages = .T.
        
    ENDFUNC


    FUNCTION UpdateFromThor
        IF PEMSTATUS(_Screen, "cThorDispatcher", 5) = .F.
            WAIT WINDOW "Thor isn't running"
            RETURN .F.
        ENDIF
        
        IF This.Download() = .F.
            RETURN .F.
        ENDIF

        LOCAL lSaveArea
        lSaveArea = SELECT()

        LOCAL lcLocalVersionFile
        lcLocalVersionFile = This.cWorkingPath + "PackageVersion" + SYS(2015) + ".txt"


        LOCAL loUpdateList as Collection

        LOCAL loErr
        loErr = .F.
        TRY
            loUpdateList = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetUpdateList', .F.)
        CATCH TO loErr
            WAIT WINDOW loErr.Message + ' ' + loErr.LineContents
        ENDTRY

        IF VARTYPE(loErr) = "O"
            SELECT (lSaveArea)
            RETURN .F.
        ENDIF


        LOCAL liUpdate, loUpdateInfo
        FOR liUpdate = 1 TO loUpdateList.Count
            
            loUpdateInfo = loUpdateList.Item(liUpdate)
            
            IF loUpdateInfo.NeverUpdate = 'Y'
                LOOP
            ENDIF

            LOCAL loErr
            loErr = .F.
            
            TRY
                IF FILE(lcLocalVersionFile,1)
                    DELETE FILE (lcLocalVersionFile)
                ENDIF

                IF EMPTY(loUpdateInfo.VersionFileUrl)
                    EXIT
                ENDIF
                
                IF EMPTY(loUpdateInfo.Link)
                    EXIT
                ENDIF

                LOCAL llDownloadRes
                llDownloadRes = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_DownloadFileFromURL', loUpdateInfo.VersionFileUrl, m.lcLocalVersionFile)
                
                IF llDownloadRes = .F.
                    WAIT WINDOW 'Error getting version information for ' + loUpdateInfo.ApplicationName + ' from URL: ' + loUpdateInfo.VersionFileUrl
                    EXIT
                ENDIF
                
                loUpdateInfo = Execscript (FILETOSTR(lcLocalVersionFile), m.loUpdateInfo)
                
                LOCAL lcVerNum, ldVerDate
                lcVerNum = ""
                ldVerDate = {.}
                
                DO CASE
                CASE EMPTY(NVL(loUpdateInfo.AvailableVersion,"")) = .F.
                    LOCAL laVerTokens[1], lnVerTokens
                    lnVerTokens = Alines (laVerTokens, ALLTRIM(loUpdateInfo.AvailableVersion), 1+4, '-')

                    DO CASE
                    CASE lnVerTokens = 1
                        lcVerNum = laVerTokens[1]

                    CASE lnVerTokens = 2
                        lcVerNum = laVerTokens[2]

                    CASE lnVerTokens = 3
                        lcVerNum = laVerTokens[2]
                    
                    CASE lnVerTokens > 3
                        lcVerNum = laVerTokens[2]
                        TRY
                            ldVerDate = laVerTokens[lnVerTokens]
                            ldVerDate = Date (Val (Substr (ldVerDate, 1, 4)), Val (Substr (ldVerDate, 5, 2)), Val (Substr (ldVerDate, 7, 2)))
                        CATCH
                            ldVerDate = {.}
                        ENDTRY
                    ENDCASE
                    
                CASE EMPTY(NVL(loUpdateInfo.VersionNumber,"")) = .F.
                    lcVerNum = TRANSFORM(loUpdateInfo.VersionNumber)
                    ldVerDate = NVL(loUpdateInfo.VersionDate, {.})
                    DO CASE
                     CASE VARTYPE(ldVerDate) = "T"
                         ldVerDate = TTOD(ldVerDate)
                     CASE VARTYPE(ldVerDate) <> "D"
                         ldVerDate = {.}
                    ENDCASE
                ENDCASE
                
                IF EMPTY(lcVerNum)
                    EXIT
                ENDIF
                
                
                SELECT FoxGetPackages
                GO TOP
                LOCATE FOR ALLTRIM(Homeurl) == ALLTRIM(loUpdateInfo.Link)

                IF FOUND()
                    REPLACE Version WITH lcVerNum, PubDate WITH ldVerDate
                ENDIF
                
                GO TOP
            
            CATCH TO loErr
                WAIT WINDOW loErr.Message + ' ' + loErr.LineContents
                
            FINALLY
                IF FILE(lcLocalVersionFile,1)
                    DELETE FILE (lcLocalVersionFile)
                ENDIF
            ENDTRY
            
        ENDFOR

        WAIT CLEAR

        SELECT (lSaveArea)

        SELECT * FROM FoxGetPackages INTO TABLE FOXGETPACKAGES_TARGET
        
    ENDFUNC
    
ENDDEFINE
    