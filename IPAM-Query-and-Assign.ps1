# IPAM Query and Assignment Script
# This script will perform the following:
# 1. Create a remote powershell session to the IPAM server
# 2. Query the vRealize IP pool for the next available address
# 3. Create an assignment in IPAM for this address
#
# This allows the safe and automated allocation of IPs for the SQL-as-a-service cluster object

Write-Output "Initialising variables..."
Write-Output ""
$Server = $IPAM_Server
$connectionURI = $IPAM_ConnectionURI
$Password = $IPAM_Password
$username = $IPAM_username
$convertedpassword = $password | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username,$convertedpassword)
$devicename = $IPAM_devicename
$forwardlookupzone = $IPAM_forwardlookupzone
$forwardlookupserver = $IPAM_forwardlookupserver
$SessionOptions = New-PSSessionOption –SkipCACheck –SkipCNCheck –SkipRevocationCheck

Write-Output "Creating Powershell session to IPAM server..."
$session = New-PSSession -Credential $credential -ConnectionUri $connectionURI –SessionOption $SessionOptions
write-output "Active Sessions"
Get-PSSession

Write-Output "Retrieving next free IP address for Cluster Object..."
$freeIP = Invoke-Command -Session $session -ScriptBlock { Get-IpamRange -AddressFamily IPv4  | where {$_.owner -eq "vRealize"} | Find-IpamFreeAddress | Select-Object -ExpandProperty IPAddress } 
Write-Output "The next free IP is: " $freeip.IPAddressToString
$IPAMAddress = $freeip.IPAddressToString
Write-Output "Adding assignment of IP address $IPAMAddress ..."
Invoke-Command -Session $session -ScriptBlock { Add-IpamAddress -IpAddress $args[0] -DeviceName $args[1]  -AssignmentType Static -Description "SQLAAS Cluster Object" -Owner "vRealize" -ForwardLookupZone $args[2] -ForwardLookupPrimaryServer $args[3] -PassThru -Verbose } -ArgumentList $IPAMAddress,$devicename,$forwardlookupzone,$forwardlookupserver 
Write-Output "Writing out IP $IPAMAddress  value to temp folder"
$IPAMAddress  | Out-File c:\ClusterIP.txt

Write-Output "Retrieving next free IP address for Cluster Listener Object..."
$freeIP2 = Invoke-Command -Session $session -ScriptBlock { Get-IpamRange -AddressFamily IPv4  | where {$_.owner -eq "vRealize"} | Find-IpamFreeAddress | Select-Object -ExpandProperty IPAddress } 
Write-Output "The next free IP is: " $freeip2.IPAddressToString
$IPAMAddress2 = $freeip2.IPAddressToString
Write-Output "Adding assignment of IP address $IPAMAddress2..."
Invoke-Command -Session $session -ScriptBlock { Add-IpamAddress -IpAddress $args[0] -DeviceName $args[1]  -AssignmentType Static -Description "SQLAAS Cluster Listener Object" -Owner "vRealize" -ForwardLookupZone $args[2] -ForwardLookupPrimaryServer $args[3] -PassThru -Verbose } -ArgumentList $IPAMAddress2,$devicename,$forwardlookupzone,$forwardlookupserver 
Write-Output "Writing out IP value $IPAMAddress2 to temp folder"
$IPAMAddress2 | Out-File c:\ClusterListenerIP.txt

Write-Output "Closing Powershell session"
Get-PSSession | Remove-PSSession -Verbose
# END
