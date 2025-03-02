Clear-Host
Write-Verbose "Setting Arguments" -Verbose
$StartDTM = (Get-Date)

$Source = "C:\Source"
$Target = "C:\Hydration"
$WDS = "C:\WDS"
$Logs = "C:\Logs"
$LogsShare = "Logs$"
$Share  = "Hydration$"
$DriveSRV19 = "D:"
$WIMSRV = "$DriveSRV" + "\Sources\install.wim"
$DriveW10 = "E:"
$WIM10 = "$DriveW10" + "\Sources\install.wim"
$DriveW11 = "F:"
$WIM11 = "$DriveW11" + "\Sources\install.wim"



$VMWDrivers = "C:\Program Files\Common Files\VMware\Drivers"
$XENDrivers = "C:\Program Files\Citrix\XenTools\Drivers"
$NTXDrivers = "C:\Program Files\Nutanix\VirtIO"

CD $Source

# Speed up the download - disable progress bar
$ProgressPreference = 'SilentlyContinue'

Write-Verbose "Checking if install media exists" -Verbose
if (!(Test-Path $WIMSRV)) {
			Stop-Process "WIM file $WIM not found" }

Write-Verbose "Disable IE Security" -Verbose
reg add "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /v IsInstalled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /v IsInstalled /t REG_DWORD /d 0 /f

# Windows ADK for Windows 11
$Vendor = "Microsoft"
$Product = "ADK for Windows 11"
$Version = "10.1.22000.1"
$uri = "https://go.microsoft.com/fwlink/?linkid=2196127"
$PackageName = "adksetup.exe"
$UnattendedArgs1 = '/quiet /layout .\'
$UnattendedArgs2 = '/Features OptionId.DeploymentTools /norestart /quiet /ceip off'

Write-Verbose "Downloading $Vendor $Product $Version" -Verbose
 If (!(Test-Path -Path $PackageName)) {
            Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
            (Start-Process "$PackageName" $UnattendedArgs1 -Wait -Passthru).ExitCode
            }
        Else {
            Write-Verbose "File exists. Skipping Download." -Verbose
        }

Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process "$PackageName" $UnattendedArgs2 -Wait -Passthru).ExitCode

# Windows PE Add-on for ADK

$Vendor = "Microsoft"
$Product = "Windows PE add-on for ADK"
$Version = "10.1.22000.1"
$uri = "https://go.microsoft.com/fwlink/?linkid=2196224"
$PackageName = "adkwinpesetup.exe"
$UnattendedArgs = '/Features OptionId.WindowsPreinstallationEnvironment /norestart /quiet /ceip off'

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process "$PackageName" $UnattendedArgs -Wait -Passthru).ExitCode

# Microsoft Deployment Toolkit
$Vendor = "Microsoft"
$Product = "Deployment Toolkit"
$Version = "6.3.8456.1000"
$uri = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName ALLUSERS=1 /qn /liewa $LogApp"

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

# System Center 2012 R2 Configuration Manager Toolkit
$Vendor = "Microsoft"
$Product = "System Center 2012 R2 Configuration Manager Toolkit"
$Version = "4.00.6221.1035"
$uri = "https://download.microsoft.com/download/5/0/8/508918E1-3627-4383-B7D8-AA07B3490D21/ConfigMgrTools.msi"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName ALLUSERS=1 /qn /liewa $LogApp"

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

Write-Verbose "Set $Vendor $Product $Version as default Log Viewer" -Verbose
$registryPath = "HKCU:\Software\Classes\Log.File\shell\open\command"
$name = "(Default)"
$value = "`"C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\CMTrace.exe`" `"%1`""

cmd /c "Reg add HKCU\Software\Classes\.lo /ve /d Log.File /f"
cmd /c "Reg add HKCU\Software\Classes\.log /ve /d Log.File /f"
cmd /c "Reg add HKCU\Software\Classes\Log.File\shell\open\command /f"
cmd /c "Reg add HKCU\Software\Microsoft\Trace32 /v "Register File Types" /t REG_SZ /d 1 /f"

New-ItemProperty -Path $registryPath `
    -Name $name `
    -Value $value `
    -PropertyType String `
    -Force | Out-Null

# Microsoft System CLR Types for SQL Server 2012
$Vendor = "Microsoft"
$Product = "System CLR Types for SQL Server 2012 (x64)"
$Version = "11.0.2100.60"
$uri = "http://go.microsoft.com/fwlink/?LinkID=239644&clcid=0x409"
$PackageName = "SQLSysClrTypes.msi"
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName ALLUSERS=1 /qn /liewa $LogApp"

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

# Microsoft Report Viewer 2012 Runtime
$Vendor = "Microsoft"
$Product = "Report Viewer 2012 Runtime"
$Version = "11.1.3452.0"
$uri = "https://download.microsoft.com/download/F/B/7/FB728406-A1EE-4AB5-9C56-74EB8BDDF2FF/ReportViewer.msi"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName ALLUSERS=1 /qn /liewa $LogApp"

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

# NotePad ++
$Vendor = "Misc"
$Product = "Notepad++"
$Version = "8.4.1"
$uri = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.1/npp.8.4.1.Installer.x64.exe"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
$UnattendedArgs = '/S'

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Product $Version" -Verbose
(Start-Process "$PackageName" $UnattendedArgs -Wait -Passthru).ExitCode

Write-Verbose "Configuring Microsoft Deployment Toolkit" -Verbose

Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

If (!(Test-Path -Path $Logs)) {New-Item -Path $Logs -Type Directory -ErrorAction SilentlyContinue | Out-Null }

New-Item -Path $Target -Type Directory -ErrorAction SilentlyContinue
New-SmbShare -Name $Share -Path $Target -FullAccess "JEDER" -ErrorAction SilentlyContinue
New-SmbShare -Name $LogsShare -Path $Logs -FullAccess "JEDER" -ErrorAction SilentlyContinue

Write-Verbose "Importing Windows 2022 x64" -Verbose
Remove-PSDrive -Name "DS001" -Force -ErrorAction SilentlyContinue
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root $Target -NetworkPath "\\$ENV:COMPUTERNAME\$Share" -Description "Hydration" | Add-MDTPersistentDrive

# Use Custom WIM - Remember to Change under Task Sequences as well
# $OS = import-mdtoperatingsystem -path "DS001:\Operating Systems" -SourceFile "C:\Source\WS22.wim" -DestinationFolder "WS22" -Move -Verbose
# $OSGUID = (Get-ItemProperty "DS001:\Operating Systems\WS22DDrive in WS22 WS22.wim").guid

New-Item -Path $Target\USMT -Type Directory -ErrorAction SilentlyContinue
New-SmbShare -Name USMT$ -Path $Target\USMT -FullAccess "JEDER" -ErrorAction SilentlyContinue

<#
if(-not(Test-path $WIM11 -PathType leaf))
 {
$user = 'oneict'
$pass = 'ca228ffca20d54e486aa7d16a2881caa'
$pair = "$($user):$($pass)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{
    Authorization = $basicAuthValue
}

Write-Verbose "Downloading Windows Server 2019" -Verbose
$uri = "https://chocoserver:8443/repository/oneict/SW_DVD9_Win_Server_STD_CORE_2019_1809.18_64Bit_German_DC_STD_MLF_X22-74332.ISO"
# Invoke-WebRequest -Uri $uri -OutFile "C:\Source\SW_DVD9_Win_Server_STD_CORE_2019_1809.18_64Bit_German_DC_STD_MLF_X22-74332.ISO" -Headers $Headers

# Mount ISOs
$MountSrv19 = Mount-DiskImage -ImagePath "C:\Source\SW_DVD9_Win_Server_STD_CORE_2019_1809.18_64Bit_German_DC_STD_MLF_X22-74332.ISO"
$DriveSrv19 = ($MountSrv19 | Get-Volume).DriveLetter+":"
Write-Verbose 'Finished Mounting Srv19'

Write-Verbose "Downloading Windows 10" -Verbose
$uri = "https://chocoserver:8443/repository/oneict/Windows10AIO.ISO"
# Invoke-WebRequest -Uri $uri -OutFile "C:\Source\Windows10AIO.ISO" -Headers $Headers

# Mount ISOs
$MountW10 = Mount-DiskImage -ImagePath "C:\Source\Windows10AIO.ISO"
$DriveW10 = ($MountW10 | Get-Volume).DriveLetter+":"
Write-Verbose 'Finished Mounting Win10'

Write-Verbose "Downloading Windows 11" -Verbose
$uri = "https://chocoserver:8443/repository/oneict/Windows11AIO.ISO"
# Invoke-WebRequest -Uri $uri -OutFile "C:\Source\Windows11AIO.ISO" -Headers $Headers

# Mount ISOs
$MountW11 = Mount-DiskImage -ImagePath "C:\Source\Windows11AIO.ISO"
$DriveW11 = ($MountW11 | Get-Volume).DriveLetter+":"
Write-Verbose 'Finished Mounting Win11'

}
#>

if(Test-path "\\vmware-host\Shared Folders\-vagrant\Windows10AIO.ISO" -PathType leaf){
Copy-Item -Path "\\vmware-host\Shared Folders\-vagrant\*.iso" -Destination "C:\tmp\"
# Mount SRV19
$MountSrv19 = Mount-DiskImage -ImagePath "C:\tmp\SW_DVD9_Win_Server_STD_CORE_2019_1909.4_64Bit_German_DC_STD_MLF_X22-29335.ISO"
$DriveSrv19 = ($MountSrv19 | Get-Volume).DriveLetter+":"
Write-Verbose 'Finished Mounting Srv19'

# Mount Win10
$MountW10 = Mount-DiskImage -ImagePath "C:\tmp\Windows10AIO.ISO"
$DriveW10 = ($MountW10 | Get-Volume).DriveLetter+":"
Write-Verbose 'Finished Mounting Win10'

# Mount Win11
$MountW11 = Mount-DiskImage -ImagePath "C:\tmp\Windows11AIO.ISO"
$DriveW11 = ($MountW11 | Get-Volume).DriveLetter+":"
Write-Verbose 'Finished Mounting Win11'
}   


# Use Windows 2022 Evaluation WIM
Import-MDTOperatingSystem -Path "DS001:\Operating Systems" -SourcePath "$Drive" -DestinationFolder "Windows 2022 X64"
$OSGUID = (Get-ItemProperty "DS001:\Operating Systems\Windows Server 2022 SERVERSTANDARD in Windows 2022 X64 install.wim").guid
Import-MDTOperatingSystem -Path "DS001:\Operating Systems" -SourcePath "$DriveW10" -DestinationFolder "Windows 10"
$OSGUID10 = (Get-ItemProperty "DS001:\Operating Systems\Windows 10 Pro in Windows 10 install.wim").guid
Import-MDTOperatingSystem -Path "DS001:\Operating Systems" -SourcePath "$DriveW11" -DestinationFolder "Windows 11"
$OSGUID11 = (Get-ItemProperty "DS001:\Operating Systems\Windows 11 Pro in Windows 11 install.wim").guid

Write-Verbose "Creating Task Sequences" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 10 - Client Rollout" -Template "Client.xml" -Comments "" -ID "Win10" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 10 Pro in Windows 10 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 11 - Client Rollout" -Template "Client.xml" -Comments "" -ID "Win11" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 11 Pro in Windows 11 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "User State -Backup USMT" -Template "ClientReplace.xml" -Comments "" -ID "USMT" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 11 Pro in Windows 11 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Standard" -Template "Server.xml" -Comments "" -ID "CTS-001" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Parallels RAS" -Template "Server.xml" -Comments "" -ID "CTS-002" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Parallels RDSH" -Template "Server.xml" -Comments "" -ID "CTS-003" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Domain Controller" -Template "Server.xml" -Comments "" -ID "CTS-004" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Citrix XenApp DDC SF DIR LIC" -Template "Server.xml" -Comments "" -ID "CTS-005" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Citrix Provisioning Services" -Template "Server.xml" -Comments "" -ID "CTS-006" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Standard with SQL Server" -Template "Server.xml" -Comments "" -ID "CTS-007" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Citrix XenApp VDA PVS" -Template "Server.xml" -Comments "" -ID "CTS-008" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Citrix XenApp VDA MCS" -Template "Server.xml" -Comments "" -ID "CTS-009" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - VMware Horizon Connection Server" -Template "Server.xml" -Comments "" -ID "CTS-010" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - VMware Horizon RDSH" -Template "Server.xml" -Comments "" -ID "CTS-011" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Citrix Receiver, VMware Horizon and Parallels Client" -Template "Server.xml" -Comments "" -ID "CTS-012" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Microsoft RDSH" -Template "Server.xml" -Comments "" -ID "CTS-013" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Automation Framework" -Template "Server.xml" -Comments "" -ID "CTS-014" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Additional Domain Controller" -Template "Server.xml" -Comments "" -ID "CTS-015" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
Import-MDTTaskSequence -Path "DS001:\Task Sequences" -Name "Windows 2022 x64 - Certification Authority" -Template "Server.xml" -Comments "" -ID "CTS-016" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows Server 2019 SERVERSTANDARD in Windows 2019 X64 install.wim" -FullName "xenappblog" -OrgName "xenappblog" -HomePage "https://xenappblog.com/blog" -Verbose
import-mdttasksequence -path "DS001:\Task Sequences" -Name "Cloud - Domain Controller" -Template "StateRestore.xml" -Comments "" -ID "CTX-015" -Version "1.0" -Verbose
import-mdttasksequence -path "DS001:\Task Sequences" -Name "Cloud - Automation Framework" -Template "StateRestore.xml" -Comments "" -ID "CTX-016" -Version "1.0" -Verbose


new-item -path "DS001:\Packages" -enable "True" -Name "Windows 2022 x64" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Selection Profiles" -enable "True" -Name "Windows 2022 x64" -Comments "" -Definition "<SelectionProfile><Include path=`"Packages\Windows 2019 x64`" /></SelectionProfile>" -ReadOnly "False" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Adobe" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Bundles" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Citrix" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Google" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Microsoft" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Misc Vendors" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Mozilla" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Nutanix" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Parallels" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Scripts" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "VMware" -Comments "" -ItemType "folder" -Verbose

$user = 'oneict'
$pass = 'ca228ffca20d54e486aa7d16a2881caa'
$pair = "$($user):$($pass)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{
    Authorization = $basicAuthValue
}


Write-Verbose "Downloading Applications" -Verbose
$uri = "https://chocoserver:8443/repository/oneict/Applications.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName" -Headers $Headers
Expand-Archive -Force -Path $PackageName -DestinationPath .
Remove-Item $Target\Applications
Move-Item -Path $Source\Applications\ -Destination $Target -Force


$uri = "https://chocoserver:8443/repository/oneict/Control.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName" -Headers $Headers
Expand-Archive -Path $PackageName -DestinationPath .
cmd /C "xcopy $Source\Control $Target\Control /E /Y /S /Q"

$uri = "https://chocoserver:8443/repository/oneict/OEM.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName" -Headers $Headers
Expand-Archive -Path $PackageName -DestinationPath .
Remove-Item $Target\"`$OEM`$\"
Move-Item -Path $Source\"`$OEM`$\" -Destination $Target -Force 

$uri = "https://chocoserver:8443/repository/oneict/Tools.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName" -Headers $Headers
Expand-Archive -Path $PackageName -DestinationPath .
cmd /C "xcopy $Source\Tools $Target\Tools /E /Y /S /Q"

$uri = "https://chocoserver:8443/repository/oneict/Scripts.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName" -Headers $Headers
Expand-Archive -Path $PackageName -DestinationPath .
cmd /C "xcopy $Source\Scripts $Target\Scripts /E /Y /S /Q"

new-item -path "DS001:\Out-of-Box Drivers" -enable "True" -Name "WinPE 5.0 x64" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Selection Profiles" -enable "True" -Name "WinPE 5.0 x64" -Comments "" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE 5.0 x64`" /></SelectionProfile>" -ReadOnly "False" -Verbose

$uri = "https://chocoserver:8443/repository/oneict/Drivers.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName" -Headers $Headers
Expand-Archive -Path $PackageName -DestinationPath .\

if( (Test-Path -Path $VMWDrivers ) )
{
    import-mdtdriver -path "DS001:\Out-of-Box Drivers\WinPE 5.0 x64" -SourcePath "$VMWDrivers" -Verbose
}

if( (Test-Path -Path $XENDrivers ) )
{
    import-mdtdriver -path "DS001:\Out-of-Box Drivers\WinPE 5.0 x64" -SourcePath "$XENDrivers" -Verbose
}

if( (Test-Path -Path $NTXDrivers ) )
{
    import-mdtdriver -path "DS001:\Out-of-Box Drivers\WinPE 5.0 x64" -SourcePath "$NTXDrivers" -Verbose
}

$uri = "https://chocoserver:8443/repository/oneict/Templates.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName" -Headers $Headers
Expand-Archive -Path $PackageName -DestinationPath .\ -Force
copy-item $Source\Templates\* "C:\Program Files\Microsoft Deployment Toolkit\Templates" -Force
copy-item $Source\Samples\* "C:\Program Files\Microsoft Deployment Toolkit\Samples" -Force

# Invoke-WebRequest -UseBasicParsing -Uri "http://xenapptraining.s3.amazonaws.com/Background.bmp" -OutFile "C:\Program Files\Microsoft Deployment Toolkit\Samples\Background.bmp"

Write-Verbose "Downloading EverGreen Applications from Github" -Verbose
$uri = "https://github.com/haavarstein/Applications/archive/master.zip"
$PackageName = "Applications-master.zip"
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Expand-Archive -Path $PackageName -DestinationPath . -Force
cmd /C "xcopy $Source\Applications-master $Target\Applications\ /h/i/c/k/e/r/y/q"

Write-Verbose "Customizing CS and Bootstrap" -Verbose
$ipV4 = Test-Connection -ComputerName (hostname) -Count 1  | Select-Object -ExpandProperty IPV4Address
$ip = $ipV4.IPAddressToString
$MDTServer = $env:ComputerName
$File = "$Target\Control\CustomSettings.ini"
Add-Content $File "[Settings]"
Add-Content $File "Priority=Default, Init, ByWDS,ByVirtual, ByDesktop, ByLaptop,"
Add-Content $File "Properties=MyCustomProperty,ComputerSerialNumber, ComputerTypeName"
Add-Content $File ""
Add-Content $File "[Init]"
Add-Content $File 'ComputerSerialNumber=#Right("%SerialNumber%",5)#'
Add-Content $File ""
Add-Content $File "[ByWDS]"
Add-Content $File "SubSection=WDS-%WDSServer%"
Add-Content $File ""
Add-Content $File "[ByLaptop]"
Add-Content $File "Subsection=Laptop-%IsLaptop%"
Add-Content $File ""
Add-Content $File "[ByDesktop]"
Add-Content $File "Subsection=Desktop-%IsDesktop%"
Add-Content $File ""
Add-Content $File "[ByVirtual]"
Add-Content $File "Subsection=Virtual-%IsVM%"
Add-Content $File ""
Add-Content $File "[Default]"
Add-Content $File "' Skip Sysprep"
Add-Content $File "SLSHARE=\\$ip\logs$"
Add-Content $File ""
Add-Content $File "' Computer Name"
Add-Content $File "OSDComputerName=%ComputerTypeName%-%ComputerSerialNumber%-W10"
Add-Content $File ""
Add-Content $File "' Skip Locale Settings"
Add-Content $File "SkipLocaleSelection=YES"
Add-Content $File "KeyboardLocale=de-CH"
Add-Content $File "KeyboardLocalePE=de-CH"
Add-Content $File "KeyboardLocale=0807:00000807"
Add-Content $File "KeyboardLocalePE=0807:00000807"
Add-Content $File "UserLocale=de-CH"
Add-Content $File "UILanguage=de-DE"
Add-Content $File ""
Add-Content $File "SkipTimeZone=YES"
Add-Content $File "TimeZone=110"
Add-Content $File "TimeZoneName=W. Europe Standard Time"
Add-Content $File ""
Add-Content $File "SkipProductKey=YES"
Add-Content $File "' Skip Admin Password"
Add-Content $File "UserID=wksadmin"
Add-Content $File "AdminPassword=P@ssw0rd"
Add-Content $File "SkipAdminPassword=YES"
Add-Content $File "' Default Task"
Add-Content $File "' TaskSequenceID=01"
Add-Content $File ""
Add-Content $File "_SMSTSOrgName=oneICT Rollout"
Add-Content $File "' DoNotCreateExtraPartition=YES"
Add-Content $File ""
Add-Content $File "SkipDomainMemberShip=NO"
Add-Content $File "JoinDomain=mylab.com"
Add-Content $File "DomainAdmin=Administrator"
Add-Content $File "DomainAdminDomain=mylab.com"
Add-Content $File "DomainAdminPassword=P@ssw0rd"
Add-Content $File ""
Add-Content $File "SkipTimeZone=YES"
Add-Content $File "TimeZone=110"
Add-Content $File "TimeZoneName=W. Europe Standard Time"
Add-Content $File ""
Add-Content $File "' Name MDT"
Add-Content $File "OSInstall=Y"
Add-Content $File "SkipAdminPassword=YES"
Add-Content $File "SkipApplications=NO"
Add-Content $File "SkipBDDWelcome=YES"
Add-Content $File "SkipBitLocker=YES"
Add-Content $File "'SkipComputerName=YES"
Add-Content $File "'SkipDeploymentType=YES"
Add-Content $File "'SkipDomainMembership=YES"
Add-Content $File "SkipFinalSummary=YES"
Add-Content $File "'SkipLocaleSelection=YES"
Add-Content $File "'SkipPackageDisplay=YES"
Add-Content $File "'SkipProductKey=YES"
Add-Content $File "'SkipRoles=YES"
Add-Content $File "SkipSummary=NO"
Add-Content $File "'SkipTaskSequence=YES"
Add-Content $File ""
Add-Content $File "'UserExit=UserExit.vbs"
Add-Content $File "'OSDComputerName=#GetOfflineComputername()#"
Add-Content $File ""
Add-Content $File "SkipUserData=NO"
Add-Content $File "UserDataLocation=NETWORK"
Add-Content $File "UDShare=\\$ip\Hydration$\USMT"
Add-Content $File "'UDDir=%Username%"
Add-Content $File "'UDDir=%ComputerTypeName%-%ComputerSerialNumber%-W10"
Add-Content $File "UDDir=%hostname%"
Add-Content $File ""
Add-Content $File "'https://docs.microsoft.com/en-us/windows/deployment/usmt/usmt-loadstate-syntax"
Add-Content $File "'https://docs.microsoft.com/en-us/windows/deployment/usmt/usmt-scanstate-syntax"
Add-Content $File ""
Add-Content $File "UserDataLocation=%UDShare%\%Hostname%"
Add-Content $File "ScanStateArgs=/v:5 /o /c /all"
Add-Content $File "'ScanStateArgs=/v:5 /o /c /uel:365"
Add-Content $File "LoadStateArgs=/v:5 /c /lac"
Add-Content $File "'LoadStateArgs=/v:5 /mu:customer\sto:customer\oneict /lac"
Add-Content $File ""
Add-Content $File "USMTMigFiles001=MigApp.xml"
Add-Content $File "USMTMigFiles002=MigUser.xml"
Add-Content $File "USMTMigFiles003=MigDocs.xml"
Add-Content $File "USMTMigFiles004=Exclude.xml"
Add-Content $File "USMTMigFiles005=ExcludeSystemFolders.xml"
Add-Content $File "'USMTMigFiles006=MigAppO2019.xml -> error"
Add-Content $File "'USMTMigFiles007="
Add-Content $File "'USMTMigFiles008=MigUser_Including_Downloads.xml"
Add-Content $File "'USMTMigFiles009=Win7and8toWin10StickyNotes.xml"
Add-Content $File "'USMTMigFiles010=Win10.xml"
Add-Content $File ""
Add-Content $File "SkipComputerBackup=NO"
Add-Content $File "ComputerBackuplocation=NETWORK"
Add-Content $File "BackupShare=\\$ip\Hydration$"
Add-Content $File "BackupDir=Backup"
Add-Content $File "BackupFile=%computername%.wim"
Add-Content $File "'BackupFile=%hostname%_#day(date) & '-' & month(date) & '-' & year(date)#.wim"
Add-Content $File ""
Add-Content $File "Administrators001=customer.local\WKS_Admin"
Add-Content $File ""
Add-Content $File (-join("EventService=http://$ip",":9800"))
Add-Content $File ""
Add-Content $File "[Laptop-True] "
Add-Content $File "ComputerTypeName=NB"
Add-Content $File ""
Add-Content $File "[Desktop-True]"
Add-Content $File "ComputerTypeName=PC"
Add-Content $File ""
Add-Content $File "[Virtual-True]"
Add-Content $File "ComputerTypeName=VM"


## $default = Get-Content $File
## $default.Replace('SkipAdminPassword=NO','SkipAdminPassword=YES') | Out-File $File -Encoding ascii

## $default = Get-Content $File
## $default.Replace('MyCustomProperty','WindowsUpdate') | Out-File $File -Encoding ascii

## $default = Get-Content $Target\Scripts\Custom\ComputerRename.ps1
## $default.Replace('192.168.5.101',$ip) | Out-File $File -Encoding ascii


$File = "$Target\Control\Bootstrap.ini"
Get-Content $File | ForEach-Object {$_ -replace "*", ""} | Out-File $File
Add-Content $File "[Settings]"
Add-Content $File "Priority=Default"
Add-Content $File ""
Add-Content $File "[Default]"
Add-Content $File "SkipBDDWelcome=YES"
Add-Content $File "DeployRoot=\\$IP\$Share"
Add-Content $File ""
Add-Content $File "UserID=Administrator"
Add-Content $File "UserPassword=P@ssw0rd"
Add-Content $File "UserDomain=mylab.com"
Add-Content $File "KeyboardLocalePE=0807:00000807"

$xmlfile = "$Target\Control\Settings.xml"
$xml = [xml](Get-Content $xmlfile)
$xml.Settings.'Boot.x64.LiteTouchISOName' = "$env:computername.iso"
$xml.Settings.'Boot.x64.IncludeAllDrivers' = "True"
$xml.Settings.'Boot.x64.SelectionProfile' = "WinPE 5.0 x64"
$xml.Settings.'Boot.x64.FeaturePacks' = "winpe-mdac,winpe-netfx,winpe-powershell"
$xml.Settings.'Boot.x64.ExtraDirectory' = "%DEPLOYROOT%\Applications\Extras\x64"
$xml.Settings.'SupportX86' = "False"
$xml.Settings.'UNCPath' = "\\$IP\$Share"
$xml.Save($xmlfile)

Write-Verbose "Setting Correct OS for all Task Sequences" -Verbose
$TargetPath = "$Target\Control"
$TargetFilter = "CTS"

#Get the list of folder-objects that match the filter
$Targets = Get-ChildItem -Directory -Path $TargetPath | Where-Object -FilterScript {$_.FullName -match "$TargetFilter"}

Foreach ($Target in $Targets){
    Write-Verbose "Working on $($Target.FullName)\ts.xml" -Verbose

    #Load XML data for the current file
    $TSPath = "$($Target.FullName)\ts.xml"
	[xml]$TSXML = Get-Content -Path "$($Target.fullname)\ts.xml"
    $TSXML.sequence.globalVarList.variable | Where {$_.name -eq "OSGUID"} | ForEach-Object {$_."#text" = $OSGUID}
    $TSXML.sequence.group | Where {$_.Name -eq "Install"} | ForEach-Object {$_.step} | Where {
	$_.Name -eq "Install Operating System"} | ForEach-Object {$_.defaultVarList.variable} | Where {
	$_.name -eq "OSGUID"} | ForEach-Object {$_."#text" = $OSGUID}
    $TSXML.Save($TSPath)
}


Write-Verbose "Working on C:\Hydration\Control\WIN10\ts.xml" -Verbose
#Load XML data for the current file
$TSPath = "C:\Hydration\Control\WIN10\ts.xml"
[xml]$TSXML = Get-Content -Path "C:\Hydration\Control\WIN10\ts.xml"
$TSXML.sequence.globalVarList.variable | Where {$_.name -eq "OSGUID"} | ForEach-Object {$_."#text" = $OSGUID10}
$TSXML.sequence.group | Where {$_.Name -eq "Install"} | ForEach-Object {$_.step} | Where {
$_.Name -eq "Install Operating System"} | ForEach-Object {$_.defaultVarList.variable} | Where {
$_.name -eq "OSGUID"} | ForEach-Object {$_."#text" = $OSGUID10}
$TSXML.Save($TSPath)

Write-Verbose "Working on C:\Hydration\Control\WIN11\ts.xml" -Verbose
#Load XML data for the current file
$TSPath = "C:\Hydration\Control\WIN11\ts.xml"
[xml]$TSXML = Get-Content -Path "C:\Hydration\Control\WIN11\ts.xml"
$TSXML.sequence.globalVarList.variable | Where {$_.name -eq "OSGUID"} | ForEach-Object {$_."#text" = $OSGUID11}
$TSXML.sequence.group | Where {$_.Name -eq "Install"} | ForEach-Object {$_.step} | Where {
$_.Name -eq "Install Operating System"} | ForEach-Object {$_.defaultVarList.variable} | Where {
$_.name -eq "OSGUID"} | ForEach-Object {$_."#text" = $OSGUID11}
$TSXML.Save($TSPath)


Write-Verbose "Enable Monitoring" -Verbose
New-NetFirewallRule -Name "MDT_Monitor (Inbound,TCP)" -DisplayName "MDT_Monitor (Inbound,TCP)" -Description "Inbound rules for the TCP protocol for MDT_Monitor" -LocalPort 9800 -Protocol "TCP" -Direction "Inbound" -Action "Allow" -ErrorAction SilentlyContinue
Set-ItemProperty DS001: -Name MonitorHost -Value $IP
Set-ItemProperty DS001: -Name MonitorEventPort -Value 9800
Set-ItemProperty DS001: -Name MonitorDataPort -Value 9801
New-Service -Name "MDT_Monitor" -Description "Microsoft Deployment Toolkit Monitor Service" -BinaryPathName "C:\Program Files\Microsoft Deployment Toolkit\Monitor\Microsoft.BDD.MonitorService.exe" -DisplayName "Microsoft Deployment Toolkit Monitor Service" -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service -Name "MDT_Monitor"

Write-Verbose "Updating Deployment Share" -Verbose
update-MDTDeploymentShare -path "DS001:" -Force

Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose