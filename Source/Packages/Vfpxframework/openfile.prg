lparameters tcFile
declare integer ShellExecute in Shell32.dll ;
	integer hwnd, ;
	string lpVerb, ;
	string lpFile, ;
	string lpParameters, ;
	string lpDirectory, ;
	long nShowCmd 
ShellExecute(0, 'Open', tcFile, '', '', 0)
