*==============================================================================
* Method:			GetValue
* Purpose:			A replacement for the VFP INPUTBOX function
* Author:			Doug Hennig
* Last Revision:	02/19/2022
* Parameters:		tcPrompt      - the prompt for the dialog
*					tcCaption     - the caption for the dialog
*					tuDefault     - the default value
*					tuCancelValue - the value to return if the user cancelled
*						(optional: blank is returned if not specified)
* Returns:			the value the user entered if they clicked OK or the value
*						in tcCancelValue if not
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcPrompt, ;
	tcCaption, ;
	tuDefault, ;
	tuCancelValue
local loForm, ;
	loObject, ;
	luValue, ;
	lcType, ;
	luCancel, ;
	luReturn

* Create a form and center it in _screen or the current screen if reasonable.

loForm = createobject('ModalForm')
with loForm
	.Caption = evl(tcCaption, 'Input Value')
	do case
		case type('_screen.ActiveForm.Name') = 'C'
			loObject = _screen.ActiveForm
		case _screen.Visible and _screen.WindowState <> 1
			loObject = _screen
	endcase
	if vartype(loObject) = 'O'
		.Top  = max(loObject.Top  + (loObject.Height - .Height)/2, 0)
		.Left = loObject.Left + (loObject.Width  - .Width)/2
	endif vartype(loObject) = 'O'
endwith

* Create a label.

loForm.AddObject('lblPrompt', 'Label')
with loForm.lblPrompt
	.AutoSize  = .T.
	.BackStyle = 0				&& transparent
	.Caption   = tcPrompt
	.FontName  = 'Segoe UI'
	.Left      = 10
	.Top       = 10
	.Visible   = .T.
endwith
luValue  = iif(pcount() > 2, tuDefault, '')
lcType   = vartype(luValue)
luCancel = iif(pcount() > 3, tuCancelValue, NULL)
do case
	case not isnull(luCancel)
	case lcType $ 'NFIBY'
		luCancel = 0
	case lcType = 'D'
		luCancel = {}
	case lcType = 'T'
		luCancel = {/:}
	otherwise
		luCancel = ''
endcase

* Create a textbox.

loForm.AddObject('txtValue', 'TextBox')
with loForm.txtValue
	.FontName      = 'Segoe UI'
	.Height        = 23
	.Left          = 10
	.SelectOnEntry = .T.
	.Top           = loForm.lblPrompt.Top + loForm.lblPrompt.Height + 5
	.Value         = luValue
	.Visible       = .T.
	do case
		case lcType $ 'NFIBY'
			.Width = 40
		case lcType = 'D'
			.Width = 70
		case lcType = 'T'
			.Width = 140
		otherwise
			.Width = 380
	endcase
endwith
loForm.Width = max(loForm.txtValue.Width + 2 * loForm.txtValue.Left, 200)

* Create OK and Cancel buttons.

loForm.AddObject('cmdOK', 'OKButton')
with loForm.cmdOK
	.Left    = (loForm.Width - (.Width * 2 + 5))/2
	.Top     = loForm.txtValue.Top + loForm.txtValue.Height + 10
	.Visible = .T.
endwith

loForm.AddObject('cmdCancel', 'CancelButton')
with loForm.cmdCancel
	.Left    = loForm.cmdOK.Left + loForm.cmdOK.Width + 5
	.Top     = loForm.cmdOK.Top
	.Visible = .T.
endwith

* Display the form.

loForm.Height = loForm.cmdOK.Top + loForm.cmdOK.Height + 6
loForm.Show()
do case
	case vartype(loForm) <> 'O'
		luReturn = luCancel
	case lcType = 'C'
		luReturn = trim(loForm.txtValue.Value)
	otherwise
		luReturn = loForm.txtValue.Value
endcase
return luReturn

define class ModalForm as Form
	AutoCenter  = .T.
	BorderStyle = 2			&& fixed dialog
	DeskTop     = .T.
	MaxButton   = .F.
	MinButton   = .F.
	ShowWindow  = 1			&& in top-level form
	WindowType  = 1			&& modal
enddefine

define class OKButton as CommandButton
	Caption  = 'OK'
	Default  = .T.
	FontName = 'Segoe UI'
	Height   = 27
	Width    = 84

	procedure Click
		Thisform.Hide()
	endproc
enddefine

define class CancelButton as CommandButton
	Cancel   = .T.
	Caption  = 'Cancel'
	FontName = 'Segoe UI'
	Height   = 27
	Width    = 84

	procedure Click
		Thisform.Release()
	endproc
enddefine
