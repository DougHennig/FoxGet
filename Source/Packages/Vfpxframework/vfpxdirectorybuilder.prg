lparameters toObject, tcParameter
aselobj(laObjects)
loObject = laObjects[1]
with loObject
	lcCaption = inputbox('Caption:', 'Directory Builder', .lblFolder.Caption)
	if not empty(lcCaption)
		.lblFolder.Caption = lcCaption
	endif not empty(lcCaption)
	.txtFolder.Left    = .lblFolder.Width + 5
	.cmdGetFolder.Left = .Width - .cmdGetFolder.Width
	.txtFolder.Width   = .cmdGetFolder.Left - .txtFolder.Left
endwith
