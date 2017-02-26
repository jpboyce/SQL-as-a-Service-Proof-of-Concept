# SQL 2012 Install

$FileSourceRoot = $FileSourceRoot
$FileSourceUser = $FileSourceUser
$FileSourcePassword = "Password123"
$Win2012Source = $Win2012Source
$SQL2012SP1Source = $SQL2012Source
$SQL2012Installer = "$SQL2012SP1Source\setup.exe"
$InstallDisk = "D"

# SQL Install Settings
$SQL_Features = $SQL_Features
$SQL_INSTALLSHAREDDIR = $SQL_INSTALLSHAREDDIR
$SQL_INSTALLSHAREDWOWDIR = $SQL_INSTALLSHAREDWOWDIR
$SQL_INSTANCENAME=$SQL_INSTANCENAME
$SQL_INSTANCEID=$SQL_INSTANCEID
$SQL_INSTANCEDIR=$SQL_INSTANCEDIR
# Agent Service Account Name
$SQL_AGTSVCACCOUNT=$SQL_AGTSVCACCOUNT
$SQL_AGTSVCPASSWORD=$SQL_AGTSVCPASSWORD
$SQL_AGTSVCSTARTUPTYPE="Automatic"
$SQL_SQLSVCSTARTUPTYPE="Automatic"
$SQL_SQLCOLLATION=$SQL_SQLCOLLATION
$SQL_SQLSVCACCOUNT=$SQL_SQLSVCACCOUNT
$SQL_SQLSVCPASSWORD=$SQL_SQLSVCPASSWORD
$SQL_SQLSYSADMINACCOUNTS=$SQL_SQLSYSADMINACCOUNTS
$SQL_SECURITYMODE=$SQL_SECURITYMODE
$SQL_ADDCURRENTUSERASSQLADMIN="False"
$SQL_BROWSERSVCSTARTUPTYPE="Automatic"

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
FEATURES=SQLENGINE
; Specify the location where SQL Server Setup will obtain product updates. The valid values are "MU" to search Microsoft Update, a valid folder path, a relative path such as .\MyUpdates or a UNC share. By default SQL Server Setup will search Microsoft Update or a Windows Update service through the Window Server Update Services. 
UpdateSource="MU"
; Displays the command line parameters usage 
HELP="False"
; Specifies that the detailed Setup log should be piped to the console. 
INDICATEPROGRESS="False"
; Specifies that Setup should install into WOW64. This command line argument is not supported on an IA64 or a 32-bit system. 
X86="False"
; Specify the root installation directory for shared components.  This directory remains unchanged after shared components are already installed. 
INSTALLSHAREDDIR="[PH-INSTALLSHAREDDIR]"

; Specify the root installation directory for the WOW64 shared components.  This directory remains unchanged after WOW64 shared components are already installed. 
INSTALLSHAREDWOWDIR="[PH-INSTALLSHAREDWOWDIR]"

; Specify a default or named instance. MSSQLSERVER is the default instance for non-Express editions and SQLExpress for Express editions. This parameter is required when installing the SQL Server Database Engine (SQL), Analysis Services (AS), or Reporting Services (RS). 
INSTANCENAME="[PH-INSTANCENAME]"

; Specify the Instance ID for the SQL Server features you have specified. SQL Server directory structure, registry structure, and service names will incorporate the instance ID of the SQL Server instance. 
INSTANCEID="[PH-INSTANCEID]"

; Specify that SQL Server feature usage data can be collected and sent to Microsoft. Specify 1 or True to enable and 0 or False to disable this feature. 
SQMREPORTING="False"
; Specify if errors can be reported to Microsoft to improve future SQL Server releases. Specify 1 or True to enable and 0 or False to disable this feature. 
ERRORREPORTING="False"
; Specify the installation directory. 
INSTANCEDIR="[PH-INSTANCEDIR]"

; Agent account name 
AGTSVCACCOUNT="[PH-AGTSVCACCOUNT]"
AGTSVCPASSWORD="[PH-AGTSVCPASSWORD]"

; Auto-start service after installation.  
AGTSVCSTARTUPTYPE="Automatic"

; CM brick TCP communication port 
COMMFABRICPORT="0"
; How matrix will use private networks 
COMMFABRICNETWORKLEVEL="0"
; How inter brick communication will be protected 
COMMFABRICENCRYPTION="0"
; TCP port used by the CM brick 
MATRIXCMBRICKCOMMPORT="0"
; Startup type for the SQL Server service. 
SQLSVCSTARTUPTYPE="Automatic"
; Level to enable FILESTREAM feature at (0, 1, 2 or 3). 
FILESTREAMLEVEL="0"
; Set to "1" to enable RANU for SQL Server Express. 
ENABLERANU="False"

; Specifies a Windows collation or an SQL collation to use for the Database Engine. 
SQLCOLLATION="[PH-SQLCOLLATION]"

; Account for SQL Server service: Domain\User or system account. 
SQLSVCACCOUNT="[PH-SQLSVCACCOUNT]"
SQLSVCPASSWORD="[PH-SQLSVCPASSWORD]"

; Windows account(s) to provision as SQL Server system administrators. 
SQLSYSADMINACCOUNTS="[PH-SQLSYSADMINACCOUNTS]" "CONTOSO\vRA-CL-Admin"

; The default is Windows Authentication. Use "SQL" for Mixed Mode Authentication. 
; SECURITYMODE="SQL"
; Provision current user as a Database Engine system administrator for SQL Server 2012 Express. 
ADDCURRENTUSERASSQLADMIN="False"
; Specify 0 to disable or 1 to enable the TCP/IP protocol. 
TCPENABLED="1"
; Specify 0 to disable or 1 to enable the Named Pipes protocol. 
NPENABLED="0"
; Startup type for Browser Service. 
BROWSERSVCSTARTUPTYPE="Automatic"
'@

$SQLConfigFile = $SQLConfigFile.Replace("[PH-INSTALLSHAREDDIR]", $SQL_INSTALLSHAREDDIR)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-INSTALLSHAREDWOWDIR]", $SQL_INSTALLSHAREDWOWDIR)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-INSTANCENAME]", $SQL_INSTANCENAME)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-INSTANCEID]", $SQL_INSTANCEID)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-INSTANCEDIR]", $SQL_INSTANCEDIR)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-AGTSVCACCOUNT]", $SQL_AGTSVCACCOUNT)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-AGTSVCPASSWORD]", $SQL_AGTSVCPASSWORD)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-SQLCOLLATION]", $SQL_SQLCOLLATION)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-SQLSVCACCOUNT]", $SQL_SQLSVCACCOUNT)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-SQLSVCPASSWORD]", $SQL_SQLSVCPASSWORD)
$SQLConfigFile = $SQLConfigFile.Replace("[PH-SQLSYSADMINACCOUNTS]", $SQL_SQLSYSADMINACCOUNTS)

# $SQLConfigFileTimestamp = Get-date -UFormat "%Y%m%d%H%M"
$SQLConfigFilename = "c:\SQLAAS.ini"
Write-Output "Configuration file will be located in $SQLConfigFilename"
$SQLConfigFile | Out-File $SQLConfigFilename
Write-Output "Configuration file has been written out"


# Start SQL Install
Write-Output "Starting SQL Installer..."

$AD_User = "CONTOSO\vRA-CL-Admin"                      # User with rights to create the object
$AD_Password = "Password123"                   # Password of the user
$convertedpassword = $AD_Password | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($AD_User,$convertedpassword)

$session = New-PSSession -ComputerName . -Credential $credential -EnableNetworkAccess -Authentication Credssp 

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



