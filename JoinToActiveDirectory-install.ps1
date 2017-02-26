# Join AD Script
# This script will perform the following actions
# 1. Turn off the Windows Firewall
# 2. Join the computer to the domain in a pre-determined Organisational Unit

# Create vRA Event Log Source
New-EventLog -LogName Application -Source "vRealize Automation" -ErrorAction SilentlyContinue
Write-EventLog -LogName Application -Source "vRealize Automation" -EventId 999 -EntryType Information -Message "Starting vRealize Automation Script, Pre-SQL Install."

# Turn Firewall Off
Write-Output "Attempting to turn off Windows Filewall for all Profiles"
Set-NetFirewallProfile -Profile * -Enabled False -Verbose
Write-Output "Reporting back Profile status for logging"
$firewallstatus = Get-NetFirewallProfile | select Name, Enabled | ft | Out-String
$firewallstatusmsg = "Current Firewall Status: " + $firewallstatus
Write-EventLog -LogName Application -Source "vRealize Automation" -EventId 999 -EntryType Information -Message $firewallstatusmsg

# Create Computer Object
$domain = $AD_Domain
$username = $AD_Username
$password = $AD_Password
$convertedpassword = $password | ConvertTo-SecureString -AsPlainText -Force
$OUPath = $AD_OUPath

$credential = New-Object System.Management.Automation.PSCredential($username,$convertedpassword)
$domainjoinmsg = "This computer will join $domain at $OUPath using account $username"
Write-Output $domainjoinmsg
Write-EventLog -LogName Application -Source "vRealize Automation" -EventId 999 -EntryType Information -Message $domainjoinmsg
Add-Computer -DomainName $domain -Credential $credential -OUPath $OUPath

Write-Output "Script Finished"
Write-EventLog -LogName Application -Source "vRealize Automation" -EventId 999 -EntryType Information -Message "Script Finished"

# END
