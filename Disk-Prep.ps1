# SQLAAS Install Disk Prep
# This script will create a partition on Disk 1 (SCSI ID) / VMDK 2 and format it
# While the 2nd disk is added as part of the deployment, it doesn't seem to get formatted and assigned a disk letter
# This script resolves that

# Create Event Log Source
# New-EventLog -LogName Application -Source "vRealize Automation" -ErrorAction SilentlyContinue

# Setting variables
$driveletter = $Disk_SQLInstall_Letter
$drivelabel = $Disk_SQLInstall_Label

Write-Output "SQLAAS Install Disk Prep Script starting..."
# Write-EventLog -LogName Application -Source "vRealize Automation" -EventId 999 -EntryType Information -Message "Starting vRealize Automation Script, Disk Prep."
Write-Output "This script will create a partition on Disk 0:1 and assign a drive letter of $Disk_SQLInstall_Letter and a label of $Disk_SQLInstall_Label"

Write-Output "Initialising Disk 1.."
Initialize-Disk 1 -Verbose

Write-Output "Creating Partition on Disk 1 and formatting..."
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter $driveletter -Verbose | Format-Volume -Force -FileSystem NTFS -NewFileSystemLabel $drivelabel -Confirm:$false -Verbose

# Output Results
Write-Output ""
Write-Output "------------------"
$partitionlist = Get-Partition -DiskNumber 1
Write-Output "Partition List"
Write-Output $partitionlist
$volumelist = Get-Volume | Where-Object {$_.DriveLetter -ne 0}
Write-Output "Volume List"
Write-Output $volumelist
Write-Output "SQLAAS Install Disk Prep Script finished."
# Write-EventLog -LogName Application -Source "vRealize Automation" -EventId 999 -EntryType Information -Message "SQLAAS Install Disk Prep Script finished."

# END
