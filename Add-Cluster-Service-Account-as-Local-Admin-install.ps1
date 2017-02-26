# Add Local Admin

$srvgroup = [ADSI]("WinNT://"+$env:COMPUTERNAME+"/administrators, group")

write-output "Adding User"
$srvgroup.add("WinNT://contoso.com/vRA-CL-Admin,user")

write-output "`nReporting local admins..."
$srvgroup.Invoke("members") | foreach {$_.GetType().InvokeMember("Name",'GetProperty',$null,$_,$null)}


write-output "`nPerforming GPUpdate for Fresh Credential Delegation..."
GPUpdate /force

write-output "`nDoing GPResult..."
gpresult /scope computer /v

Write-Output "`nSetting CredSSP Registry Setting..."
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Credssp\PolicyDefaults\AllowFreshCredentialsDomain -Name WSMan -Value "WSMAN/*.contoso.com" -Force -Verbose

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

