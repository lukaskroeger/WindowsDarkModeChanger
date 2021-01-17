function Convert-UTCtoLocal{ 
    param( [parameter(Mandatory=$true)] [String] $UTCTime )
    $strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
    $TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
    $LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
    return $LocalTime
}

$coordinates=$env:COORDINATES.replace(' ', '').split(',')
$lat=$coordinates[0]
$lang=$coordinates[1]
$sunriseSunsetData=curl.exe "https://api.sunrise-sunset.org/json?lat=$lat&lng=$lang" | ConvertFrom-Json
$sunriseTime=Convert-UTCtoLocal $sunriseSunsetData.results.sunrise
$sunsetTime=Convert-UTCtoLocal $sunriseSunsetData.results.sunset

$currentTime = Get-Date

if($currentTime -ge $sunsetTime ){
    #Set DarkMode
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 0 /f 
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f
}
else{
    #Schedule DarkMode job
    if(-Not (Get-ScheduledJob -Name "SetDarkMode")){
        $trigger = New-JobTrigger -Once -At $sunsetTime
        Register-ScheduledJob -Name SetDarkMode -Trigger $trigger -ScriptBlock {reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 0 /f; reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f}
    }
    else{
        Get-JobTrigger -Name "SetDarkMode" | Set-JobTrigger -Once -At $sunsetTime
    }

    if ($currentTime -ge $sunriseTime)     {
        #set LightMode
        reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 1 /f 
        reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 1 /f
    }
    else {
        #dark mode
        reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 0 /f 
        reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f
        #schedule sunrise job
        if(-Not (Get-ScheduledJob -Name "SetDarkMode")){
            $trigger = New-JobTrigger -Once -At $sunriseTime
            Register-ScheduledJob -Name SetLightMode -ScriptBlock {reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 1 /f; reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 1 /f}
        }
        else{
            Get-JobTrigger -Name "SetLightMode" | Set-JobTrigger -Once -At $sunriseTime
        }
    }
}



