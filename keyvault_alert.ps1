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