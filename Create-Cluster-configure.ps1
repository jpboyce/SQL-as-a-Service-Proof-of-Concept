$AD_User = $AD_User                      # User with rights to create the object
$AD_Password = $AD_Password                   # Password of the user
$FSW_Node = $fswnode_name                   # File Share Witness Node Name
# We need to change the FSW Node to FQDN format
$FSW_Node.Trim()
$FSW_Node = $FSW_Node.Replace("\s","")
$FSW_Node = $FSW_Node.Replace(" ","")
$FSW_Node = $FSW_Node+".contoso.com"

$convertedpassword = $AD_Password | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($AD_User,$convertedpassword)

$session = New-PSSession -ComputerName $FSW_Node -Credential $credential -EnableNetworkAccess -Authentication Credssp 

$ClusterName = Get-Content -Path c:\ClusterName.txt
$ClusterSplit = $ClusterName.Split("`.")

$ClusterShortName = $ClusterSplit[0]
Write-Output "Cluster Short Name is $ClusterShortName"

$ClusterObjectDN = "CN=$ClusterName,OU=Clusters,OU=vRealize,DC=contoso,DC=com"
$ClusterGroupDN = "CN=Create Computer Objects,OU=Groups,OU=vRealize,DC=contoso,DC=com"
Write-Output "`nAdding Cluster Object $ClusterShortName to AD Group $ClusterGroupDN"

Invoke-Command -Session $session -ScriptBlock { 
	#Write-Output $args[0]
	#Write-Output $args[1]
	$group = Get-ADGroup $args[0] -Verbose
	$comp = Get-ADComputer $args[1] -Verbose
write-output "`nAdding group member now..."
Add-ADGroupMember $group -members (Get-ADComputer $args[1]) -Verbose
write-output "Group membership completed" } -ArgumentList $ClusterGroupDN,$ClusterShortName
