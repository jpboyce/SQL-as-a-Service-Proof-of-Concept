
$ClusterName = Get-Content -Path C:\ClusterName.txt
$AD_User = $AD_User                      # User with rights to create the object
$AD_Password = $AD_Password                   # Password of the user
$FSW_Node = $fswnode_name                   # File Share Witness Node Name
# We need to change the FSW Node to FQDN format
$FSW_Node.Trim()
$FSW_Node = $FSW_Node.Replace("\s","")
$FSW_Node = $FSW_Node.Replace(" ","")
$FSW_Node = $FSW_Node+".contoso.com"
$FSW_Share = $FSW_Share

$convertedpassword = $AD_Password | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($AD_User,$convertedpassword)

$session = New-PSSession -ComputerName $FSW_Node -Credential $credential -EnableNetworkAccess -Authentication Credssp 

# Set Quorum Configuration
$FSW_Quorum_Path = "$FSW_Node\$FSW_Share"
Write-Output "`nSetting Cluster to use File Share Witness path of $FSW_Quorum_Path for Cluster $ClusterName"
#Invoke-Command -Session $session -ScriptBlock { Set-ClusterQuorum -Cluster $args[0] -NodeAndFileShareMajority $args[1] -Verbose } -ArgumentList $clustername, $FSW_Quorum_Path
Invoke-Command -Session $session -ScriptBlock { Get-Cluster -Name $args[0]  |  Set-ClusterQuorum -NodeAndFileShareMajority $args[1] -Verbose | Out-File -FilePath C:\SetClusterQuorumResults.txt } -ArgumentList $clustername, $FSW_Quorum_Path
#Invoke-Command -Session $session -ScriptBlock { Get-Cluster -Name $args[0] | Out-File -FilePath C:\SetClusterQuorumResults.txt } -ArgumentList $clustername, $FSW_Quorum_Path
Write-Output "Cluster Quorum completed."
