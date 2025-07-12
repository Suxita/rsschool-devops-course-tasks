# Run as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$ip = minikube ip
$hostEntry = "$ip flask-app.local"
$hostsPath = "$env:windir\System32\drivers\etc\hosts"

# Add or update entry
$content = Get-Content $hostsPath
if ($content -match "flask-app\.local") {
    $content = $content -replace ".*flask-app\.local.*", $hostEntry
} else {
    $content += $hostEntry
}
$content | Set-Content $hostsPath

Write-Host "Hosts file updated: $hostEntry" -ForegroundColor Green