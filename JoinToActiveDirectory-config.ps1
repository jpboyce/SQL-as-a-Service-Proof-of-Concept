# Reset WinRM service
# Put this in to restart the WinRM service and hopefully fix the SPN record issue

Get-Service -Name "WinRM" -verbose | Restart-Service -verbose

# Enable WSMANCred
write-output "`nCurrent Settings:"
Get-WSManCredSSP -Verbose

write-output "`nEnabling WSMAN Credssp..."
enable-wsmancredssp -role server -force -Verbose

write-output "`nChecking settings again..."
Get-WSManCredSSP -Verbose

write-output "`nPerforming GPUpdate for Fresh Credential Delegation..."
GPUpdate /force

write-output "`nDoing GPResult..."
gpresult /R /V


Write-Output "`nSetting CredSSP Registry Setting..."
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Credssp\PolicyDefaults\AllowFreshCredentialsDomain -Name WSMan -Value "WSMAN/*.<CHANGEME>.local" -Force -Verbose

Write-Output "`nConfirming Setting..."
Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Credssp\PolicyDefaults\AllowFreshCredentialsDomain -Name WSMan

Write-Output "`nSetting Service CredSSP Auth to True..."
Set-item "WSMan:\localhost\Service\Auth\CredSSP" -Value $true -Verbose
Write-Output "Confirming..."
get-item "WSMan:\localhost\Service\Auth\CredSSP"

Write-Output "`nSetting Client CredSSP Auth to True..."
Set-item "WSMan:\localhost\Client\Auth\CredSSP" -Value $true -Verbose
Write-Output "Confirming..."
get-item "WSMan:\localhost\Client\Auth\CredSSP"

Write-Output "`nGetting trusted hosts..."
get-item "WSMan:\localhost\Client\TrustedHosts"

