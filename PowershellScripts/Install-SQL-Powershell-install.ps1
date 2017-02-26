# Install SQL Powershell 

$FileSourceUser = $FileSourceUser
$FileSourcePassword = "Password123"
$SQL2012SP1Source = $SQL2012Source
$SQL2012Installer = "$SQL2012SP1Source\setup.exe"

# Generate the Config File
$SQLConfigFile = @'
;SQL Server 2012 Configuration File
[OPTIONS]
; Required to acknowledge acceptance of the license terms.
IACCEPTSQLSERVERLICENSETERMS="True"
; Specifies a Setup work flow, like INSTALL, UNINSTALL, or UPGRADE. This is a required parameter. 
ACTION="Install"
; Detailed help for command line argument ENU has not been defined yet. 
ENU="True"
; Parameter that controls the user interface behavior. Valid values are Normal for the full UI,AutoAdvance for a simplied UI, and EnableUIOnServerCore for bypassing Server Core setup GUI block. 
;UIMODE="Normal"
; Setup will not display any user interface. 
QUIET="True"
; Setup will display progress only, without any user interaction. 
QUIETSIMPLE="False"
; Specify whether SQL Server Setup should discover and include product updates. The valid values are True and False or 1 and 0. By default SQL Server Setup will include updates that are found. 
UpdateEnabled="False"
; Specifies features to install, uninstall, or upgrade. The list of top-level features include SQL, AS, RS, IS, MDS, and Tools. The SQL feature will install the Database Engine, Replication, Full-Text, and Data Quality Services (DQS) server. The Tools feature will install Management Tools, Books online components, SQL Server Data Tools, and other shared components. 
FEATURES=SSMS
; Specify the location where SQL Server Setup will obtain product updates. The valid values are "MU" to search Microsoft Update, a valid folder path, a relative path such as .\MyUpdates or a UNC share. By default SQL Server Setup will search Microsoft Update or a Windows Update service through the Window Server Update Services. 
UpdateSource="MU"
; Displays the command line parameters usage 
HELP="False"
; Specifies that the detailed Setup log should be piped to the console. 
INDICATEPROGRESS="False"
; Specifies that Setup should install into WOW64. This command line argument is not supported on an IA64 or a 32-bit system. 
X86="False"
; Specify the root installation directory for shared components.  This directory remains unchanged after shared components are already installed. 
INSTALLSHAREDDIR="C:\Program Files\Microsoft SQL Server"
; Specify the root installation directory for the WOW64 shared components.  This directory remains unchanged after WOW64 shared components are already installed. 
INSTALLSHAREDWOWDIR="C:\Program Files (x86)\Microsoft SQL Server"
; Specify that SQL Server feature usage data can be collected and sent to Microsoft. Specify 1 or True to enable and 0 or False to disable this feature. 
SQMREPORTING="False"
; Specify if errors can be reported to Microsoft to improve future SQL Server releases. Specify 1 or True to enable and 0 or False to disable this feature. 
ERRORREPORTING="False"
; Specify the installation directory. 
INSTANCEDIR="C:\Program Files\Microsoft SQL Server"
'@

$SQLConfigFilename = "c:\SQLAAS.ini"
Write-Output "Configuration file will be located in $SQLConfigFilename"
$SQLConfigFile | Out-File $SQLConfigFilename
Write-Output "Configuration file has been written out"

$AD_User = $AD_User                      # User with rights to create the object
$AD_Password = $AD_Password                   # Password of the user
$convertedpassword = $AD_Password | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($AD_User,$convertedpassword)

$session = New-PSSession -ComputerName $fsw_node -Credential $credential -EnableNetworkAccess -Authentication Credssp 

Invoke-Command -Session $session -ScriptBlock {

#Write-Output "Connecting to File Store on PSDrive X with user $args[1] to $args[3]"
$psdrivepassword = $args[2] | ConvertTo-SecureString -AsPlainText -Force
$psdrivecredential = New-Object System.Management.Automation.PSCredential($args[1],$psdrivepassword)
New-PSDrive -Name X -PSProvider FileSystem -Root $args[3] -Credential $psdrivecredential -Verbose
Get-PSDrive -Verbose

Write-Output "`nStarting SQL Install with Config File"
#write-output $args[4]
#write-output $args[0]
$starttime = get-date
Write-Output "Starting at $starttime"
& $args[4] /ConfigurationFile=c:\SQLAAS.ini | out-null
$endtime = get-date
Write-Output "Finished at $endtime"
} -ArgumentList $SQLConfigFilename, $FileSourceUser, $FileSourcePassword, $FileSourceRoot, $SQL2012Installer

Write-Output "`nChecking Powershell Cmdlets..."
Get-Module -ListAvailable

