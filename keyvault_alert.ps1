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
