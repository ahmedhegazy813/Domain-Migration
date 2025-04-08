# Ensure the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator!"
    exit
}

# Step 1: Create local admin user if not exists
$Username = "Write local admin user-name account"
$Password = ConvertTo-SecureString 'Write local admin account Password ' -AsPlainText -Force

if (-not (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $Username -Password $Password -FullName "Vagrant Admin" -Description "Local Admin Account"
    Add-LocalGroupMember -Group "Administrators" -Member $Username
    Write-Output "User 'vagrant' created and added to Administrators group."
} else {
    Write-Output "User 'vagrant' already exists and is assumed configured."
}

# Step 2: Disable all other local users except vagrant and Administrator
$AllUsers = Get-LocalUser | Where-Object { $_.Name -ne $Username -and $_.Name -ne "Administrator" }
foreach ($user in $AllUsers) {
    Disable-LocalUser -Name $user.Name
    Write-Output "Disabled user: $($user.Name)"
}

# Step 3: Set DNS to 10.50.0.17
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "10.50.0.17"
Write-Output "DNS server set to 10.50.0.17"

# Step 4: Ask for the new computer name
$NewComputerName = Read-Host "Enter the new computer name"
$OldComputerName = $env:COMPUTERNAME

# Step 5: Unjoin from old domain
$OldDomainUser = "MEDNET.LOCAL\Your Domain Admin User Name"
$OldDomainPassword = ConvertTo-SecureString "Your Domain Admin Password" -AsPlainText -Force
$OldCred = New-Object System.Management.Automation.PSCredential($OldDomainUser, $OldDomainPassword)

Try {
    Remove-Computer -UnjoinDomainCredential $OldCred -PassThru -Force
    Write-Output "Successfully unjoined from old domain."
} Catch {
    Write-Error "Failed to unjoin old domain: $_"
    exit
}

# Step 6: Join new domain (without rename)
$NewDomain = "Mednet.net"
$NewDomainUser = "Mednet.net\Your Domain Admin User Name"
$NewDomainPassword = ConvertTo-SecureString "Your Domain Admin Password" -AsPlainText -Force
$NewCred = New-Object System.Management.Automation.PSCredential($NewDomainUser, $NewDomainPassword)

$domainJoinSucceeded = $false
Try {
    Add-Computer -DomainName $NewDomain -Credential $NewCred -Force -ErrorAction Stop
    $domainJoinSucceeded = $true
    Write-Output "Successfully joined domain $NewDomain"
} Catch {
    Write-Error "Failed to join domain: $_"
}

# Step 7: Save rename instruction to execute after restart
if ($domainJoinSucceeded) {
    $scriptPath = "C:\Scripts\RenameAfterJoin.ps1"
    $renameScript = @'
Start-Sleep -Seconds 30
$current = $env:COMPUTERNAME
if ($current -ne "<<<NEWNAME>>>") {
    Rename-Computer -NewName "<<<NEWNAME>>>" -Force -ErrorAction SilentlyContinue
    Write-Output "Renamed computer to <<<NEWNAME>>>"
    Remove-Item -Path "$PSCommandPath" -Force -ErrorAction SilentlyContinue
    Restart-Computer -Force
}
'@

    # Replace placeholder with actual name safely
    $renameScript = $renameScript -replace '<<<NEWNAME>>>', [regex]::Escape($NewComputerName)

    # Save the rename script
    $renameScript | Out-File -Encoding UTF8 -FilePath $scriptPath

    # Schedule script to run after restart using RunOnce
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
      -Name "RenameAfterJoin" -Value "powershell.exe -ExecutionPolicy Bypass -File $scriptPath" -PropertyType String -Force

    Write-Output "Scheduled rename script to run on next boot."
    Restart-Computer -Force
} else {
    Write-Warning "Join domain failed. No restart will happen."
}
