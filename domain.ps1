param(

   
    [Alias("Address")]
    [string] $ip,

    [Alias("Pass")]

    [string] $Password,


    [Alias("User")]

    [string] $username,


    [Alias("Domain_Name")]

    [string] $domain

)

netsh interface ip set dns name='Ethernet' static $ip

Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Now join the domain..."

$hostname = $(hostname)

$domain_user = $domain + '\' + $username

$user = $domain_user

$pass = ConvertTo-SecureString $Password -AsPlainText -Force

$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass

$Oupath = ''

foreach($subdomain in $domain.Split('.'))

{$Oupath += "dc=" + $subdomain + ','}

# Place the ou to servers and workstations

$Oupath = $Oupath.Substring(0,$Oupath.Length - 1)

$Workstation = 'ou=Workstations,' + $Oupath

$server = 'ou=Servers,' + $Oupath

# Place the computer in the correct OU based on hostname

If ($hostname -eq "win10") {

  Add-Computer -DomainName $domain -credential $DomainCred -OUPath $server -PassThru

  # Attempt to fix Issue #517

  Set-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'WaitToKillServiceTimeout' -Value '500' -Type String -Force -ea SilentlyContinue

  New-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name 'AutoEndTasks' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue

  Set-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\SessionManager\Power' -Name 'HiberbootEnabled' -Value 0 -Type DWord -Force -ea SilentlyContinue

} ElseIf ($hostname -eq "win10") {

  Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Adding Win10 to the domain. Sometimes this step times out. If that happens, just run 'vagrant reload win10 --provision'" #debug

  Add-Computer -DomainName $domain -credential $DomainCred -OUPath $Workstation

} Else {

  Add-Computer -DomainName $domain -credential $DomainCred -PassThru

}


# Set auto login

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $username

Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value $Password
timeout /t 12
#disable defender for good
Set-MpPreference -DisableRealtimeMonitoring $true
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force



Enable-PSRemoting –force
#add Wdegest creds registry path
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential /t REG_DWORD /d 1  

#add user "jrobinson" to the RDP enabled group
net localgroup "Remote Desktop Users" JRobinson /add
net localgroup administrators /add david
#Add clear text password to the unattend.xml file
$conten = Get-Content -Path 'C:\Windows\Panther\unattend.xml'
$newConten = $conten -replace '</Administrator', 'Hacker@7263</david'
$newConten | Set-Content -Path 'C:\Windows\Panther\unattend.xml'
$fill = Get-Content -Path 'C:\Windows\Panther\unattend.xml'
$newFill = $fill -replace '<Administrator', '<david'
$newFill | Set-Content -Path 'C:\Windows\Panther\unattend.xml'

#stop windows defender for good

cmdkey /generic:$ip /user:"adminuser" /pass:"P@ssw0rd1234"
mstsc /v:$ip
Start-Sleep -s 140
Stop-Process -name mstsc
