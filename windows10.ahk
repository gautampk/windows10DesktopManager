if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}


;Press windows key + a number will switch to that desktop
#1::
#2::
#3::
#4::
#5::
#6::
#7::
#8::
#9::
#0::
{
	StringTrimLeft, count, A_ThisHotkey, 1
	send #{tab}
	WinWait, ahk_class MultitaskingViewFrame
	moveToDesktop(count)
	return
}
#IfWinActive ahk_class MultitaskingViewFrame
;Pressing windows + tab puts you in the MultitaskingViewFrame. Then pressing a number will switch to that desktop
1::
2::
3::
4::
5::
6::
7::
8::
9::
0::
{
	moveToDesktop(A_ThisHotkey)
	return
}


#if

;pressing windows + shift + a number should send the active window to that desktop
+#1::
+#2::
+#3::
+#4::
+#5::
+#6::
+#7::
+#8::
+#9::
+#0::
{
	;setting this to true will make you follow the active window to its new desktop
	follow := false
	StringTrimLeft, newDesktopNumber, A_ThisHotkey, 2
	moveActiveWindowToDesktop(newDesktopNumber)
	return	
}

moveToDesktop(desktopNumber)
{
	;after the left 10 it will be on window 1 so decrement the count by 1 to compensate
	desktopNumber--
	send {tab}{left 10}{right %desktopNumber%}{return}
	return
}

moveActiveWindowToDesktop(newDesktopNumber, follow)
{
	desktopNumber := newDesktopNumber
	
	monitorNumber := getCurrentMonitor()
	SysGet, primaryMonitor, MonitorPrimary
	
	currentDesktopNumber := getCurrentDesktopNumber()
	if(currentDesktopNumber == newDesktopNumber)
	{
		return
	}
	;desktop starts at 1 so decrement the new desktopNumber by 1
	newDesktopNumber--
	if(currentDesktopNumber <= newDesktopNumber)
	{
		newDesktopNumber--
	}
	
	if(monitorNumber <> primaryMonitor)
	{
		send {Esc}{tab 2}{AppsKey}
	}
	
	send m{down %newDesktopNumber%}{return}
	
	if(follow == true) 
	{
		send #{tab}
		WinWait, ahk_class MultitaskingViewFrame
		moveToDesktop(desktopNumber)
	}
	return	
}

/*
 * Gets the current desktop number by processing the contents of the right click context menu in 
 * the multitasking view frame (the view after pressing Windows key + tab)
 *
 * Pass false as the first parameter to close with multitasking view after getting the desktop number
 *
 * returns 0 if there was an error
 */
getCurrentDesktopNumber(leaveWinTabOpen := true)
{
	currentDesktopNumber := 0
	send #{tab}
	winwait, ahk_class MultitaskingViewFrame
	send {Appskey}
	menuString := getMenuString(getContextMenuHwnd())

	while(instr(menuString, "Desktop"))
	{
		if(! regexMatch(menuString, ",Desktop " A_index ","))
		{
			currentDesktopNumber := A_Index
			break
		}
	}
	if(!leaveWinTabOpen)
	{
		send #{tab}
	}
	return currentDesktopNumber
}

GetCurrentMonitor() {
	SysGet, numberOfMonitors, MonitorCount
	WinGetPos, winX, winY, winWidth, winHeight, A
	winMidX := winX + winWidth / 2
	winMidY := winY + winHeight / 2
	Loop %numberOfMonitors%
	{
	SysGet, monArea, Monitor, %A_Index%
	if (winMidX > monAreaLeft && winMidX < monAreaRight && winMidY < monAreaBottom && winMidY > monAreaTop)
		return %A_Index%
	}
	return
}

#Include contextMenu.ahk
