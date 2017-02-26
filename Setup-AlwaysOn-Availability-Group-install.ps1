# SQL AAG Setup

# Setup Variables
$sql_nodes = $sql_nodes
$FSW_node = $fsw_node
$SQL_InstanceName = $SQL_InstanceName
$AD_User = $AD_User                     # User with rights to create the object
$AD_Password = $AD_Password                   # Password of the user
$convertedpassword = $AD_Password | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($AD_User,$convertedpassword)

# IPAM Variables
$ClusterName = Get-Content -Path C:\ClusterShortName.txt
$ClusterListener = $ClusterName.Replace("C_","CL_")
$ClusterListenerIP = Get-Content -Path c:\ClusterListenerIP.txt

Write-Output "Listener Name is $ClusterListener"
Write-Output "Listener IP is $ClusterListenerIP" 

Write-Output "Importing SQL Powershell Module..."
Import-Module -Name SQLPS -DisableNameChecking -Verbose
Write-Output "Confirming its loaded..."
Get-Module -Name SQLPS

Write-Output "`nCreating new Session to $FSW_node"
$session = New-PSSession -ComputerName $FSW_node -Credential $credential -EnableNetworkAccess -Authentication Credssp 

Write-Output "`nStarting commands..."
Invoke-Command -Session $session -ScriptBlock {

$dnsFullName = $args[4]
$dnsShortName = $dnsFullName.Substring(0,15)
$dnscreationdate = Get-Date
write-output $dnscreationdate
Add-DNSServerResourceRecordA -Name $dnsShortName -ZoneName "contoso.com" -IPv4Address $args[3] -ComputerName "dnssvr.contoso.com" -AllowUpdateAny -CreatePtr -Verbose | Out-File c:\ListenerDNS.txt

$SQL_Replicas = @()
$SQL_EndpointPort = "5022"
$SQL_AGName = $args[2]
$SQL_DBName = "AdventureWorks2012"

foreach ($node in $args[0])
    {
    $instances = $args[1]
    $SQL_Path = "SQLSERVER:SQL\"+$node+"\"+$instances[0]
write-output "`nThe SQL Path being used is $SQL_path"
    $SQL_ServerInstance = $node+"\"+$instances[0]
write-output "The SQL Instance being used is $SQL_serverinstance"
    $SQL_EndpointURL = "TCP://"+$node+":5022"
write-output "The Endpoint URL being used is $SQL_EndpointURL"
    # Enable AlwaysOn
    Write-Output "`nEnabling Always On for $SQL_ServerInstance"
    Enable-SqlAlwaysOn -ServerInstance $SQL_ServerInstance -Force

    # Create Endpoint
    Write-Output "`nCreating Endpoint on $SQL_Path"
    New-SqlHADREndpoint -Name "AlwaysOn_Endpoint" -Port 5022 -Path $SQL_Path
$endpointpath = "$SQL_Path\Endpoints\AlwaysOn_Endpoint"
    Write-Output "Starting endpoint on path $endpointpath..."
    Set-SQLHADREndpoint -Path $endpointpath -State "Started"
    # Creating replica
    Write-Output "`nCreating replica using endpoint $SQL_EndpointURL using $SQL_ServerInstance"
    $SQL_Replicas += (New-SqlAvailabilityReplica -Name $SQL_ServerInstance -EndpointUrl $SQL_EndpointURL -AvailabilityMode SynchronousCommit -FailoverMode Automatic -ConnectionModeInSecondaryRole AllowReadIntentConnectionsOnly -AsTemplate -Version 11)

    } 

    Write-Output "Replicas generated:"
    $SQL_Replicas | ft

    # Create Availability Group
    $primarypath= "SQLSERVER:SQL\"+$SQL_Replicas[0].Name
    Write-Output "`nCreating availablity group $args[2] using primary path $primarypath"
    #New-SqlAvailabilityGroup -Name $SQL_AGName -Path $primarypath -AvailabilityReplica ($SQL_Replicas) -Database $SQL_DBName -Verbose 
    New-SqlAvailabilityGroup -Name $args[2] -Path $primarypath -AvailabilityReplica ($SQL_Replicas) -Verbose 
    
    # Join the other replicas
    $secondaries = $SQL_Replicas | select -skip 1
    Write-Output "`nAdding other replicas $secondaries "
    foreach ($replica in $secondaries)
    {
    $replicapath = "SQLSERVER:SQL\"+$replica.name
    Write-Output "Joining $replicapath to Availability Group"
    Join-SqlAvailabilityGroup -Name $args[2] -Path $replicapath -Verbose

    #$databasepath = $replicapath +"\AvailabilityGroups\"+$SQL_AGName
    #Write-Output "Adding Database $SQL_DBName to path $databasepath"
    #Add-SqlAvailabilityDatabase -Path $databasepath -Database $SQL_DBName -Verbose
    }
    $listenerpath = $primarypath+"\AvailabilityGroups\"+$SQL_AGName
    Write-Output "Args 3 is below"
    Write-Output $args[3]
$listenerstaticip = $args[3]+"/255.255.255.0"
write-output "Creating New Listener on path $listenerpath with static IP $listenerstaticip"
    New-SqlAvailabilityGroupListener -Name $args[4] -StaticIp $listenerstaticip -Path $listenerpath -Verbose -ErrorAction Continue
#start-sleep -seconds 10000
    # Test AG
    #Test-SqlAvailabilityGroup -Path $databasepath
    
    # Create Quorum
Write-Output "Setting Quorum"
$FSW_Name = $args[6]
$FSW_Name2 = $FSW_Name.Substring(0,6)
#$FSW_Name2 = $FSW_Name2+".boyce.local"

$FSW_Quorum_Path = "\\"+ $FSW_Name2 +"\FSW" 
write-output "Quroum Path is going to be on $FSW_Name2 as $FSW_Quorum_Path"
    Get-Cluster $args[5] | Set-ClusterQuorum -NodeAndFileShareMajority $FSW_Quorum_Path -Verbose
} -ArgumentList $sql_nodes, $SQL_InstanceName, $SQL_AvailabilityGroupName, $ClusterListenerIP, $ClusterListener, $ClusterName, $FSW_node
