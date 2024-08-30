#define _CRLF CHR(13)+CHR(10)
#define FOXGETPACKAGES_PATH "..\..\..\Installers\FoxGetPackages.dbf"
#define THOR_UPDATES_PATH "_Temp_Thor\Updates\"
#define ERRORLOG "_TempErrorLog.txt"
#define THOR_UPDATES_ERRORLOG "_TempThorUpdatesErrorLog.txt"

SYS(2335, 0) && Unattended mode

SET SAFETY OFF
SET CONSOLE OFF
SET PRINTER OFF

LOCAL lcPath
lcPath = ADDBS(JUSTPATH(SYS(16)))
SET DEFAULT TO (lcPath)

LOCAL lcWorkingPath
lcWorkingPath  = ADDBS("_Temp"+SYS(2015)) && a temporary path for working files


LOCAL loErr as Exception 
loErr = .F.
TRY

    USE FOXGETPACKAGES_PATH IN 0
    

    IF DIRECTORY(THOR_UPDATES_PATH, 1) = .F.
        LOCAL lcMessage
        lcMessage = "Directory " + THOR_UPDATES_PATH + " doesn't exist"
        THROW lcMessage
    ENDIF
    

    LOCAL lnThorUpdatesCnt, laThorUpdates[1], liThorUpdates
    lnThorUpdatesCnt = ADIR(laThorUpdates, THOR_UPDATES_PATH + 'Thor_Update_*.PRG')
    
    IF EMPTY(lnThorUpdatesCnt)
        LOCAL lcMessage
        lcMessage = "Files Thor_Update_*.PRG were not found in " + THOR_UPDATES_PATH
        THROW lcMessage
    ENDIF
    
    COMPILE Thor_Proc_GetUpdaterObject2.PRG NODEBUG

    FOR liThorUpdates = 1 TO lnThorUpdatesCnt
    
        LOCAL lcUpdateFile
        lcUpdateFile = THOR_UPDATES_PATH + laThorUpdates[liThorUpdates, 1]

        LOCAL lcUpdateCode
        lcUpdateCode = FILETOSTR(lcUpdateFile)
        
        LOCAL loUpdateInfo
        loUpdateInfo = NEWOBJECT("clsUpdaterObject", "Thor_Proc_GetUpdaterObject2.PRG")
       
        LOCAL lcUpdateName
        lcUpdateName = lcUpdateFile
        
        
        *************************************
        * Execute Thor's Update script
        *************************************
        LOCAL loUpdateErr as Exception
        loUpdateErr = .F.
    
        TRY
            loUpdateInfo  = EXECSCRIPT(lcUpdateCode, loUpdateInfo)
        CATCH TO loUpdateErr
            LOCAL lcMessage
            lcMessage = lcUpdateName + " Execute : " + IIF(loUpdateErr.ErrorNo = 2071, NVL(loUpdateErr.UserValue,""), loUpdateErr.Message)

            STRTOFILE(lcMessage + REPLICATE(_CRLF,2), THOR_UPDATES_ERRORLOG, 1)
        ENDTRY
        
        IF VARTYPE(loUpdateErr) = "O"
            LOOP
        ENDIF
        

        *************************************
        * Download and execute Thor's Update version file
        * Update version in FoxGetPackages.dbf
        *************************************
        LOCAL loUpdateErr
        loUpdateErr = .F.

        LOCAL lcUpdateName
        lcUpdateName = EVL(loUpdateInfo.VersionFileUrl, lcUpdateFile + " Version file")
        
        TRY
            LOCAL lcLocalVersionFile
            lcLocalVersionFile = "_TempThorUpdateVersion.txt"

            IF FILE(lcLocalVersionFile,1)
                DELETE FILE (lcLocalVersionFile)
            ENDIF

            IF EMPTY(loUpdateInfo.VersionFileUrl)
                EXIT
            ENDIF
            
            IF EMPTY(loUpdateInfo.Link)
                EXIT
            ENDIF

            
            LOCAL loHttpReq
            loHttpReq = CREATEOBJECT("WinHttp.WinHttpRequest.5.1")
            loHttpReq.Open("GET", loUpdateInfo.VersionFileUrl, 0)
            loHttpReq.Send()
            
            LOCAL loHttpStream
            loHttpStream = CREATEOBJECT("ADODB.Stream")
            loHttpStream.Type = 1
            loHttpStream.Open()
            loHttpStream.Write(loHttpReq.ResponseBody)
            loHttpStream.SaveToFile(FULLPATH(lcLocalVersionFile))
            
            IF FILE(lcLocalVersionFile,1) = .F.
                LOCAL lcMessage
                lcMessage = 'Error getting version information for ' + loUpdateInfo.ApplicationName + ' from URL: ' + loUpdateInfo.VersionFileUrl
                THROW lcMessage
            ENDIF
            
            loUpdateInfo = EXECSCRIPT(FILETOSTR(lcLocalVersionFile), m.loUpdateInfo)
            
            LOCAL lcVerNum, ldVerDate
            lcVerNum = ""
            ldVerDate = {.}
            
            DO CASE
            CASE EMPTY(NVL(loUpdateInfo.AvailableVersion,"")) = .F.
                LOCAL laVerTokens[1], lnVerTokens
                lnVerTokens = ALINES(laVerTokens, ALLTRIM(loUpdateInfo.AvailableVersion), 1+4, '-')

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
                
            CASE EMPTY(NVL(loUpdateInfo.VersionNumber,"")) = .F. OR EMPTY(NVL(loUpdateInfo.VersionDate, {.})) = .F.
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
        
        CATCH TO loUpdateErr
            LOCAL lcMessage
            lcMessage = lcUpdateName + " Execute: " + IIF(loUpdateErr.ErrorNo = 2071, NVL(loUpdateErr.UserValue,""), loUpdateErr.Message)

            STRTOFILE(lcMessage + REPLICATE(_CRLF,2), THOR_UPDATES_ERRORLOG, 1)
        ENDTRY
       
    ENDFOR

CATCH TO loErr
    LOCAL lcMessage
    lcMessage = IIF(loErr.ErrorNo = 2071, NVL(loErr.UserValue,""), loErr.Message)

    STRTOFILE(lcMessage + REPLICATE(_CRLF,2), ERRORLOG, 1)
ENDTRY


SET DEBUGOUT TO

IF USED("FoxGetPackages")
    USE IN FoxGetPackages
ENDIF
