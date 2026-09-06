[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$P12SourcePath,

    [Parameter(Mandatory = $true)]
    [System.Security.SecureString]$UserPassword,

    [Parameter(Mandatory = $true)]
    [System.Security.SecureString]$ExportPassphrase
)

$targetDir = Join-Path -Path $env:USERPROFILE -ChildPath "OpenVPN\config\$Username"

if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

$bstrUser = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($UserPassword)
$plainUserPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrUser)

$bstrCert = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ExportPassphrase)
$plainCertPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstrCert)

[System.IO.File]::WriteAllLines((Join-Path $targetDir "auth.cfg"), @($Username, $plainUserPass), [System.Text.Encoding]::ASCII)
[System.IO.File]::WriteAllLines((Join-Path $targetDir "keypass.cfg"), @($plainCertPass), [System.Text.Encoding]::ASCII)

Copy-Item -Path $P12SourcePath -Destination (Join-Path $targetDir "$Username.p12") -Force

$baseConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "..\client\company_gateway.ovpn.template"
$configContent = Get-Content -Path $baseConfigPath -Raw
$configContent = $configContent -replace 'pkcs12 client\.p12', "pkcs12 $Username.p12"

[System.IO.File]::WriteAllText((Join-Path $targetDir "client.ovpn"), $configContent, [System.Text.Encoding]::ASCII)

Write-Host "Profile bundle for '$Username' successfully deployed to: $targetDir" -ForegroundColor Green
