[CmdletBinding()]
param()

$ErrorActionPreference = "SilentlyContinue"

Write-Host "[1/3] Terminating existing OpenVPN processes..." -ForegroundColor Cyan
Stop-Process -Name "openvpn", "openvpn-gui" -Force

Write-Host "[2/3] Reconfiguring and restarting OpenVPN service..." -ForegroundColor Cyan
Set-Service -Name "OpenVPNServiceInteractive" -StartupType Automatic
Restart-Service -Name "OpenVPNServiceInteractive" -Force

Write-Host "[3/3] Launching OpenVPN GUI with elevated privileges..." -ForegroundColor Cyan
$openVpnBinary = "C:\Program Files\OpenVPN\bin\openvpn-gui.exe"

if (Test-Path -Path $openVpnBinary) {
    Start-Process -FilePath $openVpnBinary -Verb RunAs
    Write-Host "Service restarted and OpenVPN GUI launched successfully." -ForegroundColor Green
} else {
    Write-Warning "OpenVPN binary not found at: $openVpnBinary"
}
