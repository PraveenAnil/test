
function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

Disable-InternetExplorerESC

Function Enable-IEFileDownload
{
$HKLM = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
$HKCU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
Set-ItemProperty -Path $HKLM -Name "1803" -Value 0
Set-ItemProperty -Path $HKCU -Name "1803" -Value 0
Set-ItemProperty -Path $HKLM -Name "1604" -Value 0
Set-ItemProperty -Path $HKCU -Name "1604" -Value 0
}
Enable-IEFileDownload


New-Item C:\HOL -Type Directory
$WebClient1 = New-Object System.Net.WebClient
$WebClient1.DownloadFile("https://www.dropbox.com/s/sx91sjcn63t980j/StudentFiles.zip?dl=1","C:\HOL\StudentFiles.zip")

#Download SQL Server Express
$WebClient1 = New-Object System.Net.WebClient
$WebClient1.DownloadFile("https://experienceazure.blob.core.windows.net/software/SQLServer2017-SSEI-Expr.exe","C:\HOL\SQLServer2017.exe");

#Download SQL Server Management Studio
$WebClient1 = New-Object System.Net.WebClient
$WebClient1.DownloadFile("https://experienceazure.blob.core.windows.net/software/SSMS-Setup-ENU.exe","C:\Users\Public\Desktop\SSMS-Setup-ENU.exe");

#Download Chrome
$WebClient1 = New-Object System.Net.WebClient
$WebClient1.DownloadFile("http://dl.google.com/chrome/install/375.126/chrome_installer.exe","C:\Users\Public\Desktop\chromesetup.exe");


#---------------------------------------------------------
#              INSTALL SQL SERVER EXPRESS EDITION
#---------------------------------------------------------

$instanceName = "SQLExpress"


$serviceAccount = "NT Service\MSSQL`$$($instanceName)"
if ($instanceName -eq "MSSQLSERVER")
{
    $serviceAccount = "NT Service\MSSQLSERVER"
}
write-host "Installing"
#$cmd  = @"
C:\HOL\SQLServer2017.exe /Q /IACCEPTSQLSERVERLICENSETERMS /ACTION=install  /ROLE=AllFeatures_WithDefaults  /INSTANCENAME=$instanceName /SQLSVCACCOUNT=$serviceAccount 
#"@

#write-host $cmd
#& cmd.exe /c $cmd

function Expand-ZIPFile($file, $destination)
{
$shell = new-object -com shell.application
$zip = $shell.NameSpace($file)
foreach($item in $zip.items())
{
$shell.Namespace($destination).copyhere($item)
}
}


Expand-ZIPFile -File "C:\HOL\StudentFiles.zip" -Destination "C:\HOL\"


#Install SQL Server Management Studio
C:\Users\Public\Desktop\SSMS-Setup-ENU.exe /silent /install


#Install Chrome
C:\Users\Public\Desktop\chromesetup.exe /silent /install

sleep 60

Import-Module "sqlps" -DisableNameChecking
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
		$sqlesq = new-object ('Microsoft.SqlServer.Management.Smo.Server') Localhost\SQLEXPRESS
		$sqlesq.Settings.LoginMode = [Microsoft.SqlServer.Management.Smo.ServerLoginMode]::Mixed
		$sqlesq.Alter() 


Restart-Service -Name "SQL SERVER (SQLEXPRESS)" -Force


# Re-enable the sa account and set a new password to enable login
Invoke-Sqlcmd -ServerInstance Localhost\SQLEXPRESS -Database "master" -Query "ALTER LOGIN sa ENABLE"
Invoke-Sqlcmd -ServerInstance Localhost\SQLEXPRESS -Database "master" -Query "ALTER LOGIN sa WITH PASSWORD = 'demo@pass123'"

# Add local administrators group as sysadmin
		Invoke-Sqlcmd -ServerInstance Localhost\SQLEXPRESS -Database "master" -Query "CREATE LOGIN [BUILTIN\Administrators] FROM WINDOWS"
		Invoke-Sqlcmd -ServerInstance Localhost\SQLEXPRESS -Database "master" -Query "ALTER SERVER ROLE sysadmin ADD MEMBER [BUILTIN\Administrators]


Restart-Service -Name "SQL SERVER (SQLEXPRESS)" -Force
