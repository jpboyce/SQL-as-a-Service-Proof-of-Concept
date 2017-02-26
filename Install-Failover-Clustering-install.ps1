# Install Windows Failover Clustering
# This will install the Windows Failover Clustering components on the system

# Check State for logging
write-host "Checking component status..."
Get-WindowsFeature -Name "Failover-clustering" -Verbose

# Start Install
write-host "`nStarting installation...."
Install-WindowsFeature -Name Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools -Verbose

# Re-running check for logging
write-host "Checking status again..."
Get-WindowsFeature -Name "Failover-clustering" -Verbose
