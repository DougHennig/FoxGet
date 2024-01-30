#define MONITOR_DEFAULTTONULL    0 
#define MONITOR_DEFAULTTOPRIMARY 1 
#define MONITOR_DEFAULTTONEAREST 2 

#define SM_XVIRTUALSCREEN  76	&& virtual left
#define SM_YVIRTUALSCREEN  77	&& virtual top
#define SM_CXVIRTUALSCREEN 78	&& virtual width
#define SM_CYVIRTUALSCREEN 79	&& virtual height
#define SM_CMONITORS       80	&& number of monitors

#define SPI_GETWORKAREA 48

* Size object.

define class SFSize as Custom
	nLeft   = -1
	nRight  = -1
	nTop    = -1
	nBottom = -1
	nWidth  = 0
	nHeight = 0

	function nLeft_Assign(tnValue)
		This.nLeft = tnValue
		This.SetWidth()
	endfunc

	function nRight_Assign(tnValue)
		This.nRight = tnValue
		This.SetWidth()
	endfunc

	function nTop_Assign(tnValue)
		This.nTop = tnValue
		This.SetHeight()
	endfunc

	function nBottom_Assign(tnValue)
		This.nBottom = tnValue
		This.SetHeight()
	endfunc

	function SetWidth
		with This
			.nWidth  = .nRight - .nLeft
		endwith
	endfunc

	function SetHeight
		with This
			.nHeight = .nBottom - .nTop
		endwith
	endfunc
enddefine

define class SFMonitors as SFSize
	nMonitors = 0
		&& the number of monitors available

	function Init
		local loSize

* Declare the Windows API functions we'll need.

		declare integer MonitorFromPoint in Win32API ;
			long x, long y, integer dwFlags
		declare integer GetMonitorInfo in Win32API ;
			integer hMonitor, string @lpmi
		declare integer SystemParametersInfo in Win32API ;
			integer uiAction, integer uiParam, string @pvParam, integer fWinIni
		declare integer GetSystemMetrics in Win32API integer nIndex

* Determine how many monitors there are. If there's only one, get its size. If
* there's more than one, get the size of the virtual desktop.

		with This
			.nMonitors = GetSystemMetrics(SM_CMONITORS)
			if .nMonitors = 1
				loSize   = .GetPrimaryMonitorSize()
				.nRight  = loSize.nRight
				.nBottom = loSize.nBottom
				store 0 to .nLeft, .nTop
			else
				.nLeft   = GetSystemMetrics(SM_XVIRTUALSCREEN)
				.nTop    = GetSystemMetrics(SM_YVIRTUALSCREEN)
				.nRight  = GetSystemMetrics(SM_CXVIRTUALSCREEN) - abs(.nLeft)
				.nBottom = GetSystemMetrics(SM_CYVIRTUALSCREEN) - abs(.nTop)
			endif .nMonitors = 1
		endwith
	endfunc

* Return an SFSize object containing the usable size of the primary monitor,
* accounting for the taskbar.

	function GetPrimaryMonitorSize
		local lcBuffer, ;
			loSize
		lcBuffer = replicate(chr(0), 16)
		SystemParametersInfo(SPI_GETWORKAREA, 0, @lcBuffer, 0)
		loSize = createobject('SFSize')
		with loSize
			.nLeft   = ctobin(substr(lcBuffer,  1, 4), '4RS')
			.nTop    = ctobin(substr(lcBuffer,  5, 4), '4RS')
			.nRight  = ctobin(substr(lcBuffer,  9, 4), '4RS')
			.nBottom = ctobin(substr(lcBuffer, 13, 4), '4RS')
			if type('oLogger') = 'O'
				oLogger.LogElapsedMilestone('SFMonitors.GetPrimaryMonitorSize: left=' + ;
					transform(.nLeft) + ', top=' + transform(.nTop) + ', right=' + ;
					transform(.nRight) + ', bottom=' + transform(.nBottom))
			endif type('oLogger') = 'O'
		endwith
		return loSize
	endfunc

* Return an SFSize object containing the usable size of the monitor the
* specified point falls on, accounting for the taskbar. Note that the SFSize
* properties will be -1 if the specified point doesn't fall on any monitor.

	function GetMonitorSize(tnX, tnY)
		local loSize, ;
			lhMonitor, ;
			lcBuffer
		loSize    = createobject('SFSize')
		lhMonitor = MonitorFromPoint(tnX, tnY, MONITOR_DEFAULTTONEAREST)
		if lHMonitor > 0
			lcBuffer = bintoc(40, '4RS') + replicate(chr(0), 36)
			GetMonitorInfo(lhMonitor, @lcBuffer)
			with loSize
				.nLeft   = ctobin(substr(lcBuffer, 21, 4), '4RS')
				.nTop    = ctobin(substr(lcBuffer, 25, 4), '4RS')
				.nRight  = ctobin(substr(lcBuffer, 29, 4), '4RS')
				.nBottom = ctobin(substr(lcBuffer, 33, 4), '4RS')
				if type('oLogger') = 'O'
					oLogger.LogElapsedMilestone('SFMonitors.GetMonitorSize: x=' + ;
						transform(tnX) + ', y=' + transform(tnY) + ', left=' + ;
						transform(.nLeft) + ', top=' + transform(.nTop) + ', right=' + ;
						transform(.nRight) + ', bottom=' + transform(.nBottom))
				endif type('oLogger') = 'O'
			endwith
		else

* Under some conditions, MonitorFromPoint returns a negative number, so let's
* use the primary monitor in that case.

			if type('oLogger') = 'O'
				oLogger.LogElapsedMilestone('SFMonitors.GetMonitorSize: using GetPrimaryMonitorSize')
			endif type('oLogger') = 'O'
			loSize = This.GetPrimaryMonitorSize()
		endif lHMonitor > 0
		return loSize
	endfunc
enddefine
