# File Share Witness Config

$FSW_Local_Path = "C:\FSW\"
$FSW_Share_Name = "FSW"
$FSW_Share_Users = ""
$FSW_Share_Users_List = ""
$FSW_Share_Users = "Users"
$FSW_NTFS_Users = $sqlnode_hosts
$AD_User = $AD_User
$AD_Password = $AD_Password

Write-Output "The SQL Nodes IPs are:"
Write-Output $sqlnode_ips

Write-Output "The SQL Nodes Names are:"
Write-Output $sqlnode_hosts

# Creat FSW Folder
Write-Output "`nCreating $FSW_Local_Path"
New-Item -ItemType Directory -Path $FSW_Local_Path

# Create File Share
Write-Output "`nCreating File Share $FSW_Share_Name at $FSW_Local_Path with Full Access for $FSW_Share_Users"
New-SmbShare -Name $FSW_Share_Name -Path $FSW_Local_Path -Description "File Share Witness Share" -FullAccess $FSW_Share_Users

# Grant SQL Computer Accounts full NTFS Access to Share Local Path
Write-Output "`nGranting SQL Servers access to NTFS..."
$FSW_Local_Path_ACL = (Get-Item -Path $FSW_Local_Path).GetAccessControl('Access')
foreach ($user in $FSW_Share_Users)
    {
    $FSW_Local_Path_ACL_Rule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $FSW_Local_Path_ACL.SetAccessRule($FSW_Local_Path_ACL_Rule)
    Set-Acl -Path $FSW_Local_Path -AclObject $FSW_Local_Path_ACL -Verbose

    }


Install-WindowsFeature -Name "RSAT-DNS-Server" -Verbose
