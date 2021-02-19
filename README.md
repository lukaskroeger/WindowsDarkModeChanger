# WindowsDarkModeChanger
 This scripts schedules jobs, which change the windows display mode from dark to light at sunrise and from light to dark at sunset. Therefore the following API is used: https://sunrise-sunset.org/api

# Usage
If you want to use the script, you need to know the coordinates of your place. To get your coordinates you can use Google Maps. Navigate to your place and right click it. Than Google Maps will show the coordinates. Copy&Paste these coordinates to a new environment variable named COORDINATES.

Now you should create a scheduled job, which starts the script at windows startup.
Therefor excute the following commands in an admin powershell window:
```
$trigger=New-JobTrigger -AtLogon
Register-ScheduledJob -Name WindowsDarkModeChanger -ScriptBlock {<PathToScript>/WindowsDarkModeChanger.ps1} -Trigger $trigger
```
