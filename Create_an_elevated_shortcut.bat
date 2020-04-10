:: This script was created by Matthew Wai on TenForums at http://www.tenforums.com/
:: http://www.tenforums.com/tutorials/57690-create-elevated-shortcut-without-uac-prompt-windows-10-a.html       
:: ************************************************************************************/
@echo off & Title Create an elevated shortcut without a UAC prompt & mode con cols=90 lines=22 & color 17
Set "【Ø】=0" & if exist "%temp%\(+).vbs" (Del "%temp%\(+).vbs")
fsutil dirty query %systemdrive%  >nul 2>&1 && goto :(Privileges_got)
If "%1"=="%【Ø】%" (echo. &echo. Please right-click on the file.&echo. Then ^
select "Run as administrator". &echo. Press any key to exit. &pause>nul 2>&1& exit)
cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "%~0", "%【Ø】%", "", "runas", 1 > "%temp%\(+).vbs"&cscript //nologo "%temp%\(+).vbs" & exit
:(Privileges_got)
:: ************************************************************************************/
cd /d "%~dp0"
@ECHO OFF & setlocal
echo. & echo.
SET /P "【Name】= --> Please key in the name (without special characters) of the application you want to        run as an administrator (for example Elevated command prompt) and then press [Enter]:     "
echo. & echo.
SET /P "【Path】= --> Please key in (or copy and paste) the full path (without quotation marks) of the          application file (for example %windir%\System32\cmd.exe) and then press [Enter]:        " 

echo.
echo       The script is creating an elevated task with highest privileges.
echo       Please wait for a while.
echo.
:: ************************************************************************************/
(wmic useraccount where name='%username%' get SID) > "%temp%\SID.txt"
for /f "usebackq delims=" %%f in (`More "%temp%\SID.txt"`) do set "SID=%%f"
Del "%temp%\SID.txt"

Set "【Task_name】=%【Name】: =_%"
IF EXIST "%temp%\%【Task_name】%.xml" (DEL "%temp%\%【Task_name】%.xml")
IF EXIST "%temp%\Task.vbs" (DEL "%temp%\Task.vbs")

echo Set X=CreateObject("Scripting.FileSystemObject") >> "%temp%\Task.vbs"
echo Set Z=X.CreateTextFile("%temp%\%【Task_name】%.xml",True,True)>> "%temp%\Task.vbs"
Set "W=echo Z.writeline "
(	
%W%"<?xml version=""1.0"" encoding=""UTF-16""?>"
%W%"<Task version=""1.4"" xmlns=""http://schemas.microsoft.com/windows/2004/02/mit/task"">"
%W%"<RegistrationInfo>"
%W%"<Date>2000-01-01T00:00:00</Date>"
%W%"<Author>%username%</Author>"
%W%"<Description>To run the application/CMD script as an administrator with no UAC prompt.</Description>"
%W%"</RegistrationInfo>"
%W%"<Triggers />"
%W%"<Principals>"
%W%"<Principal id=""Author"">"
%W%"<UserId>%SID%</UserId>"
%W%"<LogonType>InteractiveToken</LogonType>"
%W%"<RunLevel>HighestAvailable</RunLevel>"
%W%"</Principal>"
%W%"</Principals>"
%W%"<Settings>"
%W%"<MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>"
%W%"<DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>"
%W%"<StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>"
%W%"<AllowHardTerminate>true</AllowHardTerminate>"
%W%"<StartWhenAvailable>false</StartWhenAvailable>"
%W%"<RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>"
%W%"<IdleSettings>"
%W%"<StopOnIdleEnd>true</StopOnIdleEnd>"
%W%"<RestartOnIdle>false</RestartOnIdle>"
%W%"</IdleSettings>"
%W%"<AllowStartOnDemand>true</AllowStartOnDemand>"
%W%"<Enabled>true</Enabled>"
%W%"<Hidden>false</Hidden>"
%W%"<RunOnlyIfIdle>false</RunOnlyIfIdle>"
%W%"<DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>"
%W%"<UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>"
%W%"<WakeToRun>false</WakeToRun>"
%W%"<ExecutionTimeLimit>PT72H</ExecutionTimeLimit>"
%W%"<Priority>7</Priority>"
%W%"</Settings>"
%W%"<Actions Context=""Author"">"
%W%"<Exec>"
%W%"<Command>""%【Path】%""</Command>"
%W%"</Exec>"
%W%"</Actions>"
%W%"</Task>"
)>> "%temp%\Task.vbs"	
echo Z.Close >> "%temp%\Task.vbs"	
"%temp%\Task.vbs"	
Del "%temp%\Task.vbs"	
schtasks /create /xml "%temp%\%【Task_name】%.xml" /tn "Apps\%【Task_name】%"  
If errorlevel 1 (DEL "%temp%\%【Task_name】%.xml" & echo.
echo  =======================================================================================
echo     The script has failed to create the task. You may have entered a name already 
echo     used in Task Scheduler or a name containing special characters/punctuation marks.
echo     Otherwise, you may have entered a file path that contains special characters or 
echo     punctuation marks. Please re-run the script and enter a different/valid name/file
echo     path. Press any key to close this message. 
echo  =======================================================================================
pause > nul & Exit) else (DEL "%temp%\%【Task_name】%.xml")

IF EXIST "%temp%\Shortcut.vbs" (DEL "%temp%\Shortcut.vbs")
(echo Set A = CreateObject^("WScript.Shell"^) & echo Desktop = A.SpecialFolders^("Desktop"^) & echo Set B = A.CreateShortcut^(Desktop ^& "\%【Name】%.lnk"^) & echo B.IconLocation = "%【Path】%" & echo B.TargetPath = "%windir%\System32\schtasks.exe" & echo B.Arguments = "/run /tn ""Apps\%【Task_name】%""" & echo B.Save & echo WScript.Quit)> "%temp%\Shortcut.vbs"
"%temp%\Shortcut.vbs"

If errorlevel 1 (Del "%temp%\Shortcut.vbs" & echo.
echo  ====================================================================================
echo      The script has failed to complete the operation.
echo      Please press any key to close this message.
echo  ====================================================================================
pause > nul & Exit) else (Del "%temp%\Shortcut.vbs" & echo.
echo  ====================================================================================
echo      The shortcut "%【Name】%" has been created on the desktop.
echo      You may double-click on it to run the application.
echo      Please press any key to close this message.
echo  ====================================================================================
pause > nul & Exit)
