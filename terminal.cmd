@echo off

:: Define the commands to run in each pane
set "Pane1_Command=ssh -i ~/.ssh/devops_key devops@192.168.56.10"
set "Pane2_Command=ssh -i ~/.ssh/devops_key devops@192.168.56.11"
set "Pane3_Command=ssh -i ~/.ssh/devops_key devops@192.168.56.12"
set "Pane4_Command=ssh -i ~/.ssh/devops_key devops@192.168.56.20"
set "Pane5_Command=ssh -i ~/.ssh/devops_key devops@192.168.56.40"

:: Launch Windows Terminal with 4 equal splits
wt -p "Windows PowerShell" -d . powershell.exe -NoExit -Command "%Pane1_Command%" ^
; move-focus up ^
; move-focus up ^
; move-focus up ^
; split-pane -H -s 0.5 -p "Windows PowerShell" -d . powershell.exe -NoExit -Command "%Pane5_Command%" ^
; split-pane -H -s 0.5 -p "Windows PowerShell" -d . powershell.exe -NoExit -Command "%Pane4_Command%" ^
; move-focus up ^
; move-focus up ^
; move-focus up ^
; split-pane -V -s 0.5 -p "Windows PowerShell" -d . powershell.exe -NoExit -Command "%Pane3_Command%" ^
; move-focus up ^
; move-focus up ^
; move-focus up ^
; split-pane -V -s 0.5 -p "Windows PowerShell" -d . powershell.exe -NoExit -Command "%Pane2_Command%"