Install-Module -Name Az.Profile -RequiredVersion 0.7.0 -AllowClobber -Scope CurrentUser -Force

Write-Host 'Importing Az.Profile'
try {
    $m = Get-Module -ListAvailable Az.Profile
    Import-Module -ModuleInfo $m
}
catch [System.Reflection.ReflectionTypeLoadException] {
    $_.Exception.GetBaseException().loaderexceptions
    exit
}

Install-Module -Name Az.KeyVault -RequiredVersion 3.4.0 -AllowClobber -Scope CurrentUser -Force

Write-Host 'Importing Az.KeyVault'
try {
    $m = Get-Module -ListAvailable Az.KeyVault
    Import-Module -ModuleInfo $m
}
catch [System.Reflection.ReflectionTypeLoadException] {
    $_.Exception.GetBaseException().loaderexceptions
    exit
}
