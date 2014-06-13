;使用AutoHotkey编写的自动安装脚本
;Authotkey Version: v1.1.09.01

#SingleInstance Force
#NoEnv
SetTitleMatchMode, Slow

;Function
InstallProgram( "git.ini")

;Ini Reader
InstallProgram( iniFile = "" ) 
{
	configLocation := "InstallConfig"
	mediaLocation := "Media"
	configFile := A_ScriptDir . "\" . configLocation . "\" . iniFile
	
	if (not iniFile) or (not FileExist(configFile))
	{
		MsgBox, 2, Error, Cannot Locate setup ini file:[ . %configFile% . ]
		return
	}
		

	IniRead, command, % configFile, SetupStarter, CommandLine
	IniRead, winTitle, % configFile, SetupStarter, SetupWinTitle
	IniRead, counter, % configFile, SetupStarter, StepCounter

	Run % mediaLocation . "/" . command

	;跳过Windows的文件运行安全警告
	;Loop
	IfWinExist, 打开文件 - 安全警告
	{
		;是否需要确认打开文件警告属于指定的运行程序？
		WinActivate
		WinGetText, winText
		;MsgBox, %winText%
		;点击运行
		Sleep 100
		ControlClick 运行(&R)
		;break		
	}
	Sleep 300

	WinWait, % winTitle
	WinActivate
	i := 0
	finishSection := "Step" . counter
	IniRead, finishStr, % configFile, % finishSection, Comments
	Loop
	{
		installerWinText := ""
		IfLess, i, counter
			i := i+1
		sectionName := "Step" . i
		IniRead, ButtonName, % configFile, % sectionName, ButtonClick
		IniRead, OptionName, % configFile, % sectionName, Option
		IniRead, Comments, % configFile, % sectionName, Comments
		;wait for Screen
		WinGetText, installerWinText, %winTitle%
		if not instr( installerWinText, Comments )
		{
			if i=1
				i := 0
			else
				i := i-2 ;重试上一步的工作
			continue
		}
		
		If OptionName
		{
			ControlClick %OptionName%, %winTitle%
			Sleep, 300
		}
		ListVars
		Pause

		ControlClick %ButtonName%, %winTitle%
		sleep, 300
		IfEqual, i, % counter-1
		{
			;需要等待安装完成
			Loop
			{
				WinGetText, installerWinText, %winTitle%
				if instr( installerWinText, finishStr )
					break
			}
		}
		IfEqual, i, counter
			break
	}
}