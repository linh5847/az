$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
Install-Module -Name AzureRM -RequiredVersion 6.13.1 -AllowClobber -Scope AllUsers -Force
Install-Module -Name AzureRM.profile -RequiredVersion 5.8.3 -AllowClobber -Scope AllUsers -Force

Write-Host 'Importing AzureRM.profile'
try {
    $m = Get-Module -ListAvailable AzureRM.profile
    Import-Module -ModuleInfo $m
}
catch [System.Reflection.ReflectionTypeLoadException] {
    $_.Exception.GetBaseException().loaderexceptions
    exit
}

Install-Module -Name AzureRM.KeyVault -RequiredVersion 5.2.1 -AllowClobber -Scope AllUsers -Force

Write-Host 'Importing AzureRM.KeyVault'
try {
    $m = Get-Module -ListAvailable AzureRM.KeyVault
    Import-Module -ModuleInfo $m
}
catch [System.Reflection.ReflectionTypeLoadException] {
    $_.Exception.GetBaseException().loaderexceptions
    exit
}
#Install-Module -Name Azure -RequiredVersion 5.3.0 -AllowClobber -Scope AllUsers -Force


$VaultName = 'kv-ste-test01'
$IncludeAllKeyVersions = $true
$IncludeAllSecretVersions = $true
$AlertBeforeDays = 1

Function New-KeyVaultObject
{
    param
    (
        [string]$Id,
        [string]$Name,
        [string]$Version,
        [System.Nullable[DateTime]]$Expires
    )

    $server = New-Object -TypeName PSObject
    $server | Add-Member -MemberType NoteProperty -Name Id -Value $Id
    $server | Add-Member -MemberType NoteProperty -Name Name -Value $Name
    $server | Add-Member -MemberType NoteProperty -Name Version -Value $Version
    $server | Add-Member -MemberType NoteProperty -Name Expires -Value $Expires

    return $server
}

Function Get-AzureKeyVaultObjectKeys
{
    param
    (
        [string]$VaultName,
        [bool]$IncludeAllkeyVersions
    )

    $vaultKeyObjects = [System.Collections.ArrayList]@()
    $allKeys = Get-AzureKeyVaultKey -VaultName $VaultName
    foreach($key in $allKeys) {
        if($IncludeAllkeyVersions) {
            $allKeyVersion = Get-AzureKeyVaultKey -VaultName $VaultName -IncludeVersions -Name $key.Name
            foreach($key in $allKeyVersion) {
                $vaultKeyObject = New-KeyVaultObject -Id $key.Id -Name $key.Name -Version $key.Version -Expires $key.Expires
                $vaultKeyObjects.Add($vaultKeyObject)
            }
        }
        else {
            $vaultKeyObject = New-KeyVaultObject -Id $key.Id -Name $key.Name -Version $key.Version -Expires $key.Expires
            $vaultKeyObjects.Add($vaultKeyObject)
        }
    }

    return $vaultKeyObjects
}

$allKeyVaultKeyObjects = [System.Collections.ArrayList]@()
$allKeyVaultKeyObjects.AddRange((Get-AzureKeyVaultObjectKeys -VaultName $VaultName -IncludeAllVersions $IncludeAllKeyVersions))

$today = (Get-Date).Date
$expiredKeyVaultKeyObjects = [System.Collections.ArrayList]@()
foreach($vaultKeyObject in $allKeyVaultKeyObjects) {
    if($vaultKeyObject.Expires -and $vaultKeyObject.Expires.AddDays(-$AlertBeforeDays).Date -lt $today) {
        $expiredKeyVaultKeyObjects.Add($vaultKeyObject) | Out-Null
        $ExpiresName = "Write-Output 'Name of Key-Vault Key's Expiring' $vaultKeyObject.Name"

        $User = "linhnguyen76@hotmail.com"
        $PWord = ConvertTo-SecureString -String "N!ght8ng@le" -AsPlainText -Force
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

        $MailParameters = @{
            From = 'linhnguyen76@hotmail.com'
            To = 'linhnguyen76@hotmail.com'
            Subject = 'List of Key-Vault Keys expired!!!'
            Body = "$ExpiresName"
            SmtpServer = 'smtp.office365.com'
            Port = '587'
            Credential = Get-Credential $Credential
            UseSsl = $true
        }

        Send-MailMessage @MailParameters
    }
}

Function Get-AzureKeyVaultObjectSecrets
{
    param
    (
        [string]$VaultName,
        [bool]$IncludeAllsecretVersions
    )

    $vaultSecretObjects = [System.Collections.ArrayList]@()
    $allSecrets = Get-AzureKeyVaultSecret -VaultName $VaultName
    foreach($secret in $allSecrets) {
        if($IncludeAllsecretVersions) {
            $allSecretVersion = Get-AzureKeyVaultSecret -VaultName $VaultName -IncludeVersions -Name $secret.Name
            foreach($secret in $allSecretVersion) {
                $vaultSecretObject = New-KeyVaultObject -Id $secret.Id -Name $secret.Name -Version $secret.Version -Expires $servet.Expires
                $vaultSecretObjects.Add($vaultSecretObject)
            }
        }
        else {
            $vaultSecretObject = New-KeyVaultObject -Id $secret.Id -Name $secret.Name -Version $secret.Version -Expires $secret.Expires
            $vaultSecretObjects.Add($vaultSecretObject)
        }
    }

    return $vaultSecretObjects
}

$allKeyVaultSecretObjects = [System.Collections.ArrayList]@()
$allKeyVaultSecretObjects.AddRange((Get-AzureKeyVaultObjectSecrets -VaultName $VaultName -IncludeAllVersions $IncludeAllSecretVersions))

$today = (Get-Date).Date
$expiredKeyVaultSecretObjects = [System.Collections.ArrayList]@()
foreach($vaultSecretObject in $allKeyVaultSecretObjects) {
    if($vaultSecretObject.Expires -and $vaultSecretObject.Expires.AddDays(-$AlertBeforeDays).Date -lt $today) {
        $expiredKeyVaultSecretObjects.Add($vaultSecretObject) | Out-Null
        $ExpiresName = "Write-Output 'Name of Key-Vault Secret's Expiring' $vaultSecretObject.Name" 

        $User = "linhnguyen76@hotmail.com"
        $PWord = ConvertTo-SecureString -String "N!ght8ng@le" -AsPlainText -Force
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

        $MailParameters = @{
            From = 'linhnguyen76@hotmail.com'
            To = 'linhnguyen76@hotmail.com'
            Subject = 'List of Key-Vault Secrets expired!!!'
            Body = "$ExpiresName"
            SmtpServer = 'smtp.office365.com'
            Port = '587'
            Credential = Get-Credential $Credential
            UseSsl = $true
        }

        Send-MailMessage @MailParameters
    }
}
