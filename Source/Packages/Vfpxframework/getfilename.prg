lparameters tcExtensions, ;
	tcFileName, ;
	tcTitleCaption, ;
	tlSave, ;
	tlMultiSelect
local lcFileExt, ;
	lcExtensions, ;
	loDialog, ;
	lnExtensions, ;
	laExtensions[1], ;
	lnI, ;
	lcExtension, ;
	lnPos, ;
	lcDescription, ;
	lcExt, ;
	lnJ, ;
	lcFileName
lcFileExt    = iif(empty(tcFileName), '', upper(justext(tcFileName)))
lcExtensions = evl(tcExtensions, 'All Files (*.*):*')
loDialog     = newobject('VFPXCommonDialog', 'VFPXCommonDialog.vcx')	
with loDialog
	.ClearFilters(.T.)
	.nFilterIndex = 0
	lnExtensions  = alines(laExtensions, lcExtensions, 5, ';')
	for lnI = 1 to lnExtensions
		lcExtension = laExtensions[lnI]
		lnPos       = at(':', lcExtension)
		if lnPos > 0
			lcDescription = left(lcExtension, lnPos - 1)
			lcExt         = substr(lcExtension, lnPos + 1)
		else
			lcDescription = ''
			lcExt         = lcExtension
		endif lnPos > 0
		if ',' $ lcExt
			lcExtension = lcExt
			lcExt       = ''
			for lnJ = 1 to alines(laExt, lcExtension, 4, ',')
				lcExt = lcExt + iif(empty(lcExt), '', ';') + '*.' + laExt[lnJ]
			next lnJ
		else
			lcExt = '*.' + lcExt
		endif ',' $ loOutput.FileExtension
		.AddFilter(lcDescription, lcExt)
		if not empty(tcFileName) and lcFileExt $ upper(lcExt)
			.nFilterIndex = lnI
		endif not empty(tcFileName) ...
	next lnI
	.cTitleBarText = icase(not empty(tcTitleCaption), tcTitleCaption, ;
		tlSave, 'Save', 'Open')
	if not empty(tcFileName)
		.cInitialDirectory = justpath(tcFileName)
		.cFileName         = tcFileName
	endif not empty(tcFileName)
	.lSaveDialog       = tlSave
	.lOverwritePrompt  = .T.
	.lAllowMultiSelect = tlMultiSelect
	.ShowDialog()
	if tlMultiSelect
		lcFileName = ''
		for lnI = 1 to .nFileCount
			lcFileName = lcFileName + iif(empty(lcFileName), '', ',') + ;
				addbs(.cFilePath) + .aFileNames[lnI]
		next lnI
	else
		lcFileName = addbs(.cFilePath) + .cFileTitle
	endif tlMultiSelect
endwith
return lcFileName
 