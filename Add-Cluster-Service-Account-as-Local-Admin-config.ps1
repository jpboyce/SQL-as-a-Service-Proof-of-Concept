Write-Output "`nSetting CredSSP Registry Setting..."
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Credssp\PolicyDefaults\AllowFreshCredentialsDomain -Name WSMan -Value "WSMAN/*.boyce.local" -Force -Verbose

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

GPResult /R /V
