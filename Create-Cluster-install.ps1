# Create Windows Clustering Service Cluster

# Variables
$ClusterIP = Get-Content -Path C:\ClusterIP.txt
$ClusterIP = $ClusterIP.ToString()
$SQL_Node_array = @("")
$SQL_Node_String = ""
$SQL_Node_array = $sqlnode_names
# We need to change the SQL node names to FQDN format
for ($i=0; $i -le $SQL_Node_array.Length-1; $i++)
{
    $SQL_Node_array[$i] = $SQL_Node_array[$i]+".contoso.com"
}
$SQL_Node_array | %{$SQL_Node_String += ($(if($SQL_Node_String){","}) + $_ + $t)}   # Convert the SQL node array to a comma seperated string for easier handling later on
$FSW_Node = $fswnode_name                   # File Share Witness Node Name
# We need to change the FSW Node to FQDN format
$FSW_Node.Trim()
$FSW_Node = $FSW_Node.Replace("\s","")
$FSW_Node = $FSW_Node.Replace(" ","")
$FSW_Node = $FSW_Node+".contoso.com"
$FSW_Share = $FSW_Share
$AD_OU = $AD_OU                        # OU to create the cluster object
$AD_Domain =   "boyce.local"                  # Domain to create the object in
$AD_User = $AD_User                      # User with rights to create the object
$AD_Password = $AD_Password                   # Password of the user
$DNS_Server = $DNS_Server

$convertedpassword = $AD_Password | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($AD_User,$convertedpassword)

# Install AD Powershell
Write-Output "`nInstalling AD Powershell..."
Install-WindowsFeature -Name RSAT-AD-PowerShell -Verbose
# Generate randomised cluster name
# Going to use GUID function for this
$guid = [GUID]::NewGuid()
$guid = $guid.ToString()
$guid = $guid.Split("-")
$clustername = "C_"+ $guid[4]     # You can change this prefix.  The [4] block gives 12 characters, so your prefix probably should be limited to 3 characters
$ClusterNameFQDN = $clustername+".contoso.com"
$ClusterNameFQDN | Out-File c:\ClusterName.txt
$clusterName | Out-File C:\ClusterShortName.txt

# Create Cluster
$Cluster_DN = "CN=$clustername,$AD_OU"
Write-Output "`nThe Cluster will be created as $Cluster_DN with SQL Nodes $SQL_Node_array and FSW Node $FSW_Node"
Write-Output "Starting cluster creation..."
Write-Output "Connecting PS Session to $FSW_Node"
$session = New-PSSession -ComputerName $FSW_Node -Credential $credential -EnableNetworkAccess -Authentication Credssp 
Write-Output "Creating Cluster..."
Invoke-Command -Session $session -ScriptBlock {New-Cluster -Name $args[0] -Node $args[1] -AdministrativeAccessPoint ActiveDirectoryAndDns -StaticAddress $args[2] -NoStorage -Verbose | Out-File -FilePath C:\CreateClusterResult.txt } -ArgumentList $Cluster_DN, $SQL_Node_array, $ClusterIP
Write-Output "`nCreating DNS record, A Record for $ClusterName on IP $ClusterIP on DNS server $DNS_Server for DNS Zone $AD_Domain"
Invoke-Command -Session $session -ScriptBlock {Add-DnsServerResourceRecordA -Name $args[0] -ZoneName $args[1] -IPv4Address $args[2] -ComputerName $args[3] -Verbose  | Out-File -FilePath C:\CreateDNSResult.txt } -ArgumentList $ClusterName,$AD_Domain,$ClusterIP,$DNS_Server
#New-Cluster -Name $Cluster_DN -Node $SQL_Node_String -AdministrativeAccessPoint ActiveDirectoryAndDns -NoStorage -whatif -Verbose
#Get-PSSession | Remove-PSSession

Write-Output "`n----------------------------------------------------------------------------------------------------------"
