# === MEGA-Upload erstellen ===
$ordnerPfad = "C:\$env:USERNAME\Desktop"

if (-not (Test-Path $ordnerPfad)) {
    New-Item -ItemType Directory -Path $ordnerPfad
}


# === Vorbereitungen ===
cd C:/Users/$env:USERNAME/MEGA-Account-Generator
python read.py

# Zurück auf Desktop
cd C:/Users/$env:USERNAME/Desktop
mega-put Mega_Upload
Start-Sleep -Seconds 2

# === mega-export in separatem Fenster starten ===
Start-Process powershell -ArgumentList '-NoExit', '-Command', 'mega-export -a /Mega_Upload/neccessity.txt' -WindowStyle Normal

# Kurz warten, bis mega-export Eingabe erwartet
Start-Sleep -Seconds 2

# === "a" + Enter senden ===
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("a{ENTER}")

# Beispiel: Dein Befehl, der die Ausgabe erzeugt
$output = mega-export -a Mega_Upload

# Link extrahieren und in Zwischenablage kopieren
if ($output -match 'https://mega\.nz/\S+') {
    $matches[0] | Set-Clipboard
    Write-Host "Link wurde in die Zwischenablage kopiert: $($matches[0])"
} else {
    Write-Host "Kein MEGA-Link gefunden."
}



