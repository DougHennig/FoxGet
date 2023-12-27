*** Foxget package manager.
* Adds files to pjx, checks for missing files and updates, call package manager at startup to set path in ide,
* does whatever to download and install eg vfpxeorkbook has to be unzipped, has keywords to search for.
* Installer prg for each tool sort of like Thor updater. Based on class with properties like url and methods like
* beforegetfile and aftergetfile. Ui can search, download, remove, or go to tool website.

*** NOTE: subclass must have same name as PRG


#define ccCRLF	chr(13) + chr(10)


define class FoxGet as Custom
	oFiles          = NULL
		&& a collection to hold files to download/process
	oDependencies   = NULL
		&& a collection of other packages this depends on
	oProject        = NULL
		&& a reference to the active project
	cWorkingPath    = ''
		&& a temporary path for working files
	cExtractionPath = ''
		&& the path to extract files into
	cPackagesPath   = ''
		&& the path for packages for the project
	cPackageName    = ''
		&& the name of the package to install
	cPackagePath    = ''
		&& the path for the package
	cVersion        = ''
		&& the package version
	cProjectFolder  = ''
		&& the folder for the project
	cLogFile        = ''
		&& the log file
	cBaseURL        = ''
		&& the base URL to download files from.


* Initialize the class.

	function Init

* Get a reference to the active project; bug out if there isn't one.

		if type('_vfp.ActiveProject') <> 'O'
			lcMessage = 'No active project'
			messagebox(lcMessage, 16, 'FoxGet')
			This.Log(lcMessage)
			return .F.
		endif type('_vfp.ActiveProject') <> 'O'
		This.oProject = _vfp.ActiveProject

* Create collections to hold files to download/process and dependencies.

		This.oFiles        = createobject('Collection')
		This.oDependencies = createobject('Collection')

* Define the locations of some folders and set the default package name.

		This.cWorkingPath    = addbs(sys(2023)) + 'FoxGet\'
		This.cExtractionPath = This.cWorkingPath + 'Extraction\'
		This.cPackageName    = strtran(This.Name, 'Installer', '', -1, -1, 1)
		This.cProjectFolder = addbs(justpath(This.oProject.Name))
			&& we use Name not HomeDir since HomeDir could point to an older location
		This.cPackagesPath  = This.cProjectFolder + 'Packages\'
		This.cPackagePath   = This.cPackagesPath + addbs(This.cPackageName)

* Allow the subclass to do its own setup tasks.

		This.Setup()
	endfunc


* Abstract method overridden in a subclass.

	function Setup
	endfunc


* Add a file to the collection of files to download. tcFolder is optional:
* the user's Temp files folder is used if it isn't specified.

	function AddFile(tcURL, tlAddToProject, tcFolder)
		local loFile
		loFile               = createobject('FoxGetFile')
		loFile.cURL          = iif('http' $ tcURL, '', This.cBaseURL) + tcURL
		loFile.lAddToProject = tlAddToProject
		loFile.cLocalFile    = evl(tcFolder, This.cWorkingPath) + This.Decode(justfname(tcURL))
		This.oFiles.Add(loFile)
		return loFile
	endfunc


* Add a dependency on another package.

	function AddDependency(tcPackage)
		This.oDependencies.Add(tcPackage)
	endfunc


* Install the package. Custom work (anything other than downloading and extracting
* files, such as copying files from the working or extraction folder to the package
* folder) is done by the InstallPackage method, which is overridden in a subclass.

	function Install
		local lcMessage, ;
			llOK, ;
			loException

* Create our working folder if necessary.

		lcMessage = '===== Installing ' + This.cPackageName
		raiseevent(This, 'Update', lcMessage)
		This.Log(lcMessage)
		llOK = .T.
		if not directory(This.cWorkingPath)
			try
				md (This.cWorkingPath)
			catch to loException
				lcMessage = 'Cannot create ' + This.cWorkingPath + ': ' + ;
					loException.Message
				raiseevent(This, 'Update', lcMessage)
				This.Log(lcMessage)
				llOK = .F.
			endtry
		endif not directory(This.cWorkingPath)
		if not llOK
			return .F.
		endif not llOK

* Create the packages folder if necessary.

		if not directory(This.cPackagesPath)
			try
				md (This.cPackagesPath)
			catch to loException
				lcMessage = 'Error creating packages folder: ' + loException.Message
				raiseevent(This, 'Update', lcMessage)
				This.Log(lcMessage)
				llOK = .F.
			endtry
		endif not directory(This.cPackagesPath)
		if not llOK
			return .F.
		endif not llOK

* Delete the package folder if it exists (there may be obsolete files from an
* earlier install) then create it.

		llOK = This.RemovePackagePath()
		if not llOK
			return .F.
		endif not llOK
		try
			md (This.cPackagePath)
		catch to loException
			lcMessage = 'Error creating package folder ' + This.cPackageName + ': ' + ;
				loException.Message
			raiseevent(This, 'Update', lcMessage)
			This.Log(lcMessage)
			llOK = .F.
		endtry
		if not llOK
			return .F.
		endif not llOK

* Erase the log file.

		This.cLogFile = This.cPackagesPath + 'log.txt'
		try
			erase (This.cLogFile)
		catch
		endtry

* Do the installation.

		llOK = This.DownloadFiles()
		llOK = llOK and This.ExtractFiles()
		llOK = llOK and This.InstallPackage()
		llOK = llOK and This.UpdatePackages()
		llOK = llOK and This.AddFilesToProject()
		if llOK
			messagebox(This.cPackageName + ' was installed successfully.', 64, 'FoxGet')
		else
			messagebox(This.cPackageName + ' was not installed. ' + ;
				'The log file will be displayed.', 64, 'FoxGet')
			modify file (This.cLogFile) nowait
		endif llOK
		return llOK
	endfunc


* Abstract method overridden in a subclass.

	function InstallPackage
	endfunc


* Deletes the package folder and its contents.

	function RemovePackagePath(tlUpdate)
		local llOK
		if directory(This.cPackagePath)
			if tlUpdate
				raiseevent(This, 'Update', 'Deleting folder ' + This.cPackagePath)
			endif tlUpdate
			llOK = FileOperation(This.cPackagePath, '', 'DELETE')
			if not llOK
				lcMessage = 'Cannot delete package folder ' + This.cPackagePath
				raiseevent(This, 'Update', lcMessage)
				This.Log(lcMessage)
			endif not llOK
		else
			llOK = .T.
		endif directory(This.cPackagePath)
		return llOK
	endfunc


* Download all files.

	function DownloadFiles()
		local loInternet, ;
			llReturn
		loInternet = newobject('Internet', 'Internet.prg')
		bindevent(loInternet, 'Update', This, 'Update')
		llReturn = loInternet.Download(This.oFiles)
		if not llReturn
			raiseevent(This, 'Update', loInternet.cErrorMessage)
			This.Log(loInternet.cErrorMessage)
		endif not llReturn
		return llReturn
	endfunc


* Extract all zip files.

	function ExtractFiles()
		local llResult, ;
			loException, ;
			loFile

* Delete all files in the extraction folder: PowerShell Expand-Archive gets
* cranky if the files already exist.

		llResult = .T.
		if directory(This.cExtractionPath)
			llResult = FileOperation(This.cExtractionPath, '', 'DELETE')
			if not llResult
				This.Log('Error deleting files in ' + This.cExtractionPath)
				return .F.
			endif not llResult
		endif directory(This.cExtractionPath)

* Create the extraction folder.

		try
			md (This.cExtractionPath)
		catch to loException
			This.Log('Error creating ' + This.cExtractionPath + ': ' + ;
				loException.Message)
			llResult = .F.
		endtry
		if not llResult
			return .F.
		endif not llResult

* Extract each compressed file.

		for each loFile in This.oFiles foxobject
			if inlist(upper(justext(loFile.cLocalFile)), 'ZIP', '7Z')
				llResult = This.ExtractFile(loFile.cLocalFile, This.cExtractionPath)
				if not llResult
					exit
				endif not llResult
			endif inlist(upper(justext(loFile.cLocalFile)) ...
		next lcFile
		return llResult
	endfunc


* Extract a file.

	function ExtractFile(tcSource, tcDestination)
		local loShell, ;
			loFiles, ;
			loException as Exception, ;
			llResult, ;
			lcCommand, ;
			loAPI, ;
			lcMessage

* Try to use Shell.Application to extract files.

		raiseevent(This, 'Update', 'Extracting ' + justfname(tcSource))
		This.Log('Extracting ' + tcSource)
		try
			loShell = createobject('Shell.Application')
			loFiles = loShell.NameSpace(tcSource).Items
			if loFiles.Count > 0
				loShell.NameSpace(tcDestination).CopyHere(loFiles)
				llResult = .T.
				This.Log('Extraction complete')
			endif loFiles.Count > 0
		catch to loException
			This.Log('Error extracting from zip using Shell.Application: ' + ;
				loException.Message)
		endtry

* If that failed, use PowerShell.

		if not llResult
			This.Log('Attempting extracting with PowerShell')
			lcCommand = 'cmd /c %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe ' + ;
				'Microsoft.Powershell.Archive\Expand-Archive ' + ;
				"-Path '" + tcSource + "' " + ;
				"-DestinationPath '" + tcDestination + "'"
			loAPI = createobject('API_AppRun', lcCommand, This.cWorkingPath, 'HID')
			do case
				case not empty(loAPI.icErrorMessage)
					lcMessage = loAPI.icErrorMessage
				case loAPI.LaunchAppAndWait()
					llResult  = nvl(loAPI.CheckProcessExitCode(), -1) = 0
					lcMessage = evl(loAPI.icErrorMessage, 'API_AppRun failed on execution')
				otherwise
					lcMessage = loAPI.icErrorMessage
			endcase
			if llResult
				This.Log('Extraction complete')
			else
				raiseevent(This, 'Update', 'Extraction failed: see log file for details')
				This.Log('Error extracting from zip via PowerShell: ' + lcMessage)
			endif llResult
		endif not llResult
		return llResult
	endfunc


* Copy the specified file(s) to the package folder.

	function CopyExtractedFiles(tcSource)
		local llOK, ;
			lcMessage
		llOK = This.CopyFile(This.cExtractionPath + tcSource, This.cPackagePath)
		if llOK
			This.Log('Copying files complete')
			This.AddToRepository(tcSource)
		endif llOK
		return llOK
	endfunc


* Copies the specified file to the specified location.

	function CopyFile(tcSource, tcDestination)
		local lcDestination, ;
			lcMessage, ;
			loException as Exception, ;
			llReturn

* Strip any trailing backslash as it prevents COPY FILE from working.

		if right(tcDestination, 1) = '\'
			lcDestination = left(tcDestination, len(tcDestination) - 1)
		else
			lcDestination = tcDestination
		endif right(tcDestination, 1) = '\'
		lcMessage = 'Copying ' + tcSource + ' to ' + lcDestination
		raiseevent(This, 'Update', lcMessage)
		This.Log(lcMessage)
		try
			copy file (tcSource) to (lcDestination)
			llReturn = .T.
		catch to loException
			raiseevent(This, 'Update', 'Copying failed: see log file for details')
			This.Log('Error copying file: ' + loException.Message)
		endtry
		return llReturn
	endfunc


* Add the specified file(s) to the project repository if there is one.

	function AddToRepository(tcSource)
*** TODO
	endfunc


* Update the packages file.

	function UpdatePackages(tlRemove)
		local lcPackagesFile, ;
			lnSelect, ;
			llResult, ;
			loException as Exception
		lcPackagesFile = This.cPackagesPath + 'packages.xml'
		lnSelect       = select()
		llResult       = .T.
		This.Log('Updating packages file')
		create cursor Packages (Name C(60), Version C(10), Date D)
		if file(lcPackagesFile)
			try
				xmltocursor(lcPackagesFile, 'Packages', 512 + 8192)
			catch
				This.Log('Invalid packages.xml file')
				llResult = .F.
			endtry
		endif file(lcPackagesFile)
		if llResult
			locate for upper(Name) = upper(This.cPackageName)
			do case
				case found() and tlRemove
					delete
				case tlRemove
				case not found()
					insert into Packages ;
						values ;
							(This.cPackageName, ;
							This.cVersion, ;
							date())
			endcase
			try
				cursortoxml('Packages', lcPackagesFile, 1, 512)
			catch to loException
				This.Log('Cannot write packages.xml: ' + loException.Message)
			endtry
		endif llResult
		if not llResult
			raiseevent(This, 'Update', 'Cannot update packages file: see log file for details')
		endif not llResult
		use in select('Packages')
		select (lnSelect)
		return llResult
	endfunc


* Add the package files to the project.

	function AddFilesToProject()
		local llReturn, ;
			loFile
		llReturn = .T.
		for each loFile in This.oFiles foxobject
			if loFile.lAddToProject
				llReturn = This.AddFileToProject(loFile.cLocalFile)
				if not llReturn
					exit
				endif not llReturn
			endif loFile.lAddToProject
		next loFile
		return llReturn
	endfunc


* Add the specified file to the project.

	function AddFileToProject(tcFile)
		local lcMessage, ;
			lcFile, ;
			llReturn
		lcMessage = 'Adding ' + tcFile + ' to project'
		raiseevent(This, 'Update', lcMessage)
		This.Log(lcMessage)
		lcFile = tcFile
		if empty(justpath(lcFile))
			lcFile = This.cPackagePath + lcFile
		endif empty(justpath(lcFile))
		try
			loFile = This.oProject.Files.Add(lcFile)
			loFile.Exclude = .F.
			llReturn = .T.
		catch to loException
			raiseevent(This, 'Update', 'Adding file to project failed: see log file for details')
			This.Log('Error adding ' + lcFile + ' to project: ' + ;
				loException.Message)
		endtry
		return llReturn
	endfunc


* Uninstall the package: remove the files from the project and delete the package folder.

	function Uninstall
		local lcMessage, ;
			llOK
		lcMessage = '===== Uninstalling ' + This.cPackageName
		raiseevent(This, 'Update', lcMessage)
		This.Log(lcMessage)
		llOK = This.RemoveFilesFromProject()
		llOK = llOK and This.UninstallPackage()
		llOK = llOK and This.UpdatePackages(.T.)
		llOK = llOK and This.RemovePackagePath(.T.)
		llOK = llOK and This.RemoveFromRepository()
		if llOK
			messagebox(This.cPackageName + ' was uninstalled successfully.', 64, 'FoxGet')
		else
			messagebox(This.cPackageName + ' was not uninstalled. ' + ;
				'The log file will be displayed.', 64, 'FoxGet')
			modify file (This.cLogFile) nowait
		endif llOK
		return llOK
	endfunc


* Abstract method overridden in a subclass.

	function UninstallPackage
	endfunc


* Remove the package files from the project.

	function RemoveFilesFromProject()
		local llReturn, ;
			loFile
		llReturn = .T.
		for each loFile in This.oFiles foxobject
			if loFile.lAddToProject
				llReturn = This.RemoveFileFromProject(loFile.cLocalFile)
				if not llReturn
					exit
				endif not llReturn
			endif loFile.lAddToProject
		next loFile
		return llReturn
	endfunc


* Remove the specified file from the project.

	function RemoveFileFromProject(tcFile)
		local lcMessage, ;
			lcFile, ;
			llReturn
		lcMessage = 'Removing ' + tcFile + ' from project'
		raiseevent(This, 'Update', lcMessage)
		This.Log(lcMessage)
		lcFile = tcFile
		if empty(justpath(lcFile))
			lcFile = This.cPackagePath + lcFile
		endif empty(justpath(lcFile))
		try
			loFile = This.oProject.Files.Item(lcFile)
			loFile.Remove()
			This.RemoveFromRepository(lcFile)
			llReturn = .T.
		catch to loException
			raiseevent(This, 'Update', 'Removing file from project failed: see log file for details')
			This.Log('Error removing ' + lcFile + ' from project: ' + ;
				loException.Message)
		endtry
		return llReturn
	endfunc


* Remove the specified file from the project repository if there is one.

	function RemoveFromRepository(tcSource)
*** TODO
	endfunc


* Decode an HTML-encoded filename.

	function Decode(tcFile)
		local lcFile
		lcFile = strtran(tcFile, '%20', '')
			&& PowerShell Extract-Archive can't handle spaces in filenames so
			&& we'll strip them out
*** TODO: handle others
		return lcFile
	endfunc


* This method is here so we can use RAISEEVENT to tell anything listening what's
* happening.

	function Update(tcMessage)
	endfunc


* Write to the log file.
	
	function Log(tcMessage)
		strtofile(tcMessage + ccCRLF, This.cLogFile, .T.)
	endfunc
enddefine

define class FoxGetFile as Custom
	cURL          = ''
	cLocalFile    = ''
	lAddToProject = .F.
enddefine
 