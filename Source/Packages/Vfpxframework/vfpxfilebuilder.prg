lparameters toObject, tcParameter
aselobj(laObjects)
loObject = laObjects[1]
with loObject
	lcCaption = inputbox('Caption:', 'File Builder', .lblFile.Caption)
	if not empty(lcCaption)
		.lblFile.Caption = lcCaption
	endif not empty(lcCaption)
	.txtFile.Left    = .lblFile.Width + 5
	.cmdGetFile.Left = .Width - .cmdGetFile.Width
	.txtFile.Width   = .cmdGetFile.Left - .txtFile.Left
endwith
