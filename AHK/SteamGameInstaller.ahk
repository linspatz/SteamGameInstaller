;Variables> 	http://ahkscript.org/docs/Variables.htm#Cursor
;Gendocs >   	https://github.com/fincs/GenDocs
;OutPutDebug 	http://www.autohotkey.com/docs/commands/OutputDebug.htm
/*!
	Script: Steam Bulk Installker 1.0
		This script/macro allows you to activate steam keys in bulk,
		up to 25 keys at once (steam limit)

	Author: colingg 
	License: Apache License, Version 2.0
*/
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn All, Off  ; Disable warnings (error dialog boxes being shown to user)
#singleinstance force ;force looping
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;#----------------------------------------- End of header ------------------------------------------------------ 
;#----------------------------------------- Methods / functions below  ----------------------------------------- 

;mouse and keyboard interactions

steam_click_next(){							;click the next button 
	steam_activate_install()
	MouseClick, left,  320,  375 ;click next
	installlog("Clicked next.")
	Sleep,100
	return
}

steam_click_finish(){						;click the finish button
	steam_activate_install()
	MouseClick, left,  422,  375 ;click finish.
	installlog("Installation finished.")
	Sleep,100
	return
}




steam_wait_for_allocation(){			;Waits for file allocation to be over.
	installlog("Waiting for game to fully allocate.")
	steam_activate_install()
	Sleep,100
	PixelGetColor, pixelcheck, 376, 138, RGB	
	Sleep,100
	While pixelcheck = 0x595959
	{
	Sleep, 1000
	PixelGetColor, pixelcheck, 376, 138, RGB	
	}
}



steam_open_window(){						;opens steam/games/list mode
SetTitleMatchMode 3
	installlog("Opening Steam to Games in List Mode")
	Run, steam://nav/games/list									;Sets steam to open yo library andin list mode
	WinWait, Steam,
	IfWinNotActive, Steam, , WinActivate, Steam,
	WinWaitActive, Steam
	installlog("Moving Steam to top left corner and setting resolution to 900x647")
	WinMove, Steam, , 0, 0, 900, 647							;Moves window and sets size
	Sleep, 250
	SetTitleMatchMode 1
	installlog("Sorting list by Status")
	PixelGetColor, pixelcheck, 587, 111, RGB					;Placing Uninstalled games at top of list
	While pixelcheck = 0x3A3A3A
	{
		MouseClick, left, 587, 111
		Sleep, 250
		PixelGetColor, pixelcheck, 587, 111, RGB	
	}
	Sleep, 250
	SendInput {Home}
}

steam_activate(){					;activates steam
SetTitleMatchMode 3
	installlog("Finding next game to install")
	IfWinNotActive, Steam, , WinActivate, Steam,
	WinWaitActive, Steam
	WinMove, Steam, , 0, 0, 900, 647							;Moves window and sets size
	Sleep, 250
	SetTitleMatchMode 1
	MouseClick, left, 780, 136
	Sleep, 250
	SendInput {Home}
}

steam_activate_install(){					;activate the installer window
	WinWait, Install -, 
	IfWinNotActive, Install -, , WinActivate, Install -, 
	WinWaitActive, Install -, 
	WinMove, 0, 0 ;lets move the window to the left.
	Sleep, 250
}




;Logging Functions
installlog(text){								;log to WorkingDir\steaminstall.log
	FormatTime, Time,, dd/MM/yyyy HH:mm:ss tt
	FileAppend, %Time% %text%`n, %A_WorkingDir%\steaminstall.log
}
steam_game_name(){
	WinActivate, Install -, 
	WinGetTitle, WindowTitle,
	StringTrimLeft,gameTitle,WindowTitle,10
	spacer := "                       "
	installlog("  |----------------------------------------------------------------------|")
	installlog("  |                                                                      |")
	installlog("  |                              Installing                              |")
	installlog("   " . spacer . "" . spacer3 . "" . gameTitle . "" . spacer . "")
	installlog("  |                                                                      |")
	installlog("  |----------------------------------------------------------------------|")
	Sleep, 250 
}

;#----------------------------------------- Methods / functions above  ----------------------------------------- 
;Main code goes here !
installlog("")
installlog("")
installlog("")
installlog(" ----- Install All Games Started ------")
installlog(" -----    System Information     ------")
installlog("AHK version =>" . A_AhkVersion)
installlog("OS Type     =>" . A_OSType)
installlog("OS Version  =>" . A_OSVersion)
installlog("is x64      =>" . A_Is64bitOS)
installlog("is elevated =>" . A_IsAdmin)
installlog(" ----          Macro Log          -----")
MsgBox, 64, Automation, Please do not touch the keyboard or mouse while the macro is running.`n(Press escape at any time to stop the macro.)

Sleep 5000

steam_open_window()

PixelGetColor, pixelcheck, 572, 147, RGB
While	pixelcheck = 0xA8A8A8
{
	SendInput {Enter}
	steam_activate_install()
	steam_game_name()
	steam_click_next()
	steam_click_next() ;In case of eula
	steam_wait_for_allocation()
	steam_click_finish()	
	steam_activate()
	Sleep, 1000
	PixelGetColor, pixelcheck, 572, 147, RGB	
}


installlog("All games installed, ending macro.")
installlog(" ----- App End ------")
ExitApp

Escape::
;#----------------------------------------- Escape Pressed -----------------------------------------
installlog("Game installation canceled because escape was pressed.")
installlog(" ----- App End ------")
ExitApp
Return

F6::
Pause
Sleep, 2500