# current Direcotry
$toolsDir  = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

#region " Adding registry values
# Log generation
$Log = @{
    Path    = "$env:windir\SoftwareDistribution\ChocolateyOneICT.log"
    Append  = $true
    Force   = $true
    Confirm = $false
    Verbose = $true
 }
Start-Transcript @Log

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$ENV:ALLUSERSPROFILE\chocolatey\bin", "Machine")
# add tcp rout to oneICT Server
if((Get-Content $env:windir\System32\drivers\etc\hosts |?{$_ -match "195.49.62.108"}) -eq $null){
Add-Content $ENV:WinDir\System32\Drivers\etc\hosts "## oneICT chocolatey repo"
Add-Content $ENV:WinDir\System32\Drivers\etc\hosts "195.49.62.108 chocoserver"
}
# add selfsign certificate
CertUtil -AddStore TrustedPeople $toolsDir\choclatey.cer
#$downloader = New-Object -TypeName System.Net.WebClient
#Invoke-Expression ($downloader.DownloadString('http://chocoserver:80/Import-ChocoServerCertificate.ps1'))
# add oneICT repositroy to chocolaty framework
C:\ProgramData\chocolatey\bin\choco.exe source add --name="'oneICT'" --source="'https://chocoserver:8443/repository/ChocolateyInternal/'" --allow-self-service --user="'chocolatey'" --password="'wVGULoJGh1mxbRpChJQV'" --priority=1
C:\ProgramData\chocolatey\bin\choco.exe source add --name="'Chocolatey'" --source="'https://chocolatey.org/api/v2/'" --allow-self-service --priority=2
C:\ProgramData\chocolatey\bin\choco.exe install chocolateygui -y --source="'oneICT'" --no-progress

#choco source remove --name="'ChocolateyOneICT'"
#choco list -n=ChocolateyInternal
#choco list -n=oneICT
Stop-Transcript
#endregion

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

wget -uri https://github.com/JorgaWetzel/Automation-Framework-Community-Edition/archive/master.zip -OutFile C:\Windows\Temp\Master.zip
Expand-Archive -Path C:\Windows\Temp\Master.zip -DestinationPath C:\
ren "C:\Automation-Framework-Community-Edition-master" "C:\Source"
