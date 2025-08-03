# setup-mega-union.ps1

# ==============================
# Automatische MEGA-Remote-Erstellung mit rclone
# ==============================

# Konfiguration
$rclonePath = "C:\RCLONE\rclone-v1.69.1-windows-amd64\rclone.exe"  # Pfad zu rclone.exe
$csvPath = "C:\Users\$env:USERNAME\MEGA-Account-Generator\accounts.csv"  # Pfad zur CSV mit Zugangsdaten (email,password)
$baseRemoteName = "mega"
$unionRemoteName = "megabundle"

# CSV-Datei einlesen
$accounts = Import-Csv -Delimiter "," -Header "Email","Password" -Path $csvPath | Select-Object -Skip 1

# Liste der Remote-Namen sammeln
$remoteNames = @()
$index = 1

foreach ($account in $accounts) {
    $remoteName = "$baseRemoteName$index"
    $remoteNames += "${remoteName}:"

    Write-Host "Erstelle Remote: $remoteName für $($account.Email)"

    # rclone Remote anlegen
    & $rclonePath config create $remoteName mega user "$($account.Email)" pass "$($account.Password)" --obscure

    $index++
}

# Union-Remote erstellen
Write-Host "Erstelle union-Remote: $unionRemoteName"

# Vorherigen union-Remote löschen, falls vorhanden
& $rclonePath config delete $unionRemoteName -q 2>$null

# Kombinierten Remote erstellen
$upstreams = $remoteNames -join " "
& $rclonePath config create $unionRemoteName union upstreams "$upstreams" create_policy "epmfs"

Write-Host "✅ Einrichtung abgeschlossen. Zugriff auf kombinierten Speicher mit: rclone ls ${unionRemoteName}:"

# Fenster offen halten
Read-Host -Prompt "Druecke [Enter], um fortzufahren"

Add-Type -AssemblyName System.Windows.Forms

$wahl = Read-Host "Möchtest du eine Datei (d) oder einen Ordner (o) hochladen? [d/o]"

if ($wahl -eq "d") {
    # Datei-Auswahl
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "Datei(en) auswählen"
    $dialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $dialog.Filter = "Alle Dateien (*.*)|*.*"
    $dialog.Multiselect = $true

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $auswahl = $dialog.FileNames

        $zielordner = Read-Host "Bitte gib den Zielordner auf Mega an (wird erstellt, falls nicht vorhanden)"
        $ziel = "${unionRemoteName}:${zielordner}"

        foreach ($pfad in $auswahl) {
            Write-Host "Kopiere Datei: $pfad nach $ziel"
            & "$rclonePath" copy "$pfad" "$ziel" --progress
        }
    }
}
elseif ($wahl -eq "o") {
    # Ordner-Auswahl
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Ordner auswählen"
    $dialog.ShowNewFolderButton = $true

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $ordner = $dialog.SelectedPath

        $zielordner = Read-Host "Bitte gib den Zielordner auf Mega an (wird erstellt, falls nicht vorhanden)"
        $ziel = "${unionRemoteName}:${zielordner}"

        Write-Host "Kopiere Ordner: $ordner nach $ziel"
        & "$rclonePath" copy "$ordner" "$ziel" --progress
    }
}
else {
    Write-Host "Ungültige Eingabe. Bitte d oder o eingeben."
}

Read-Host -Prompt "Druecke [Enter], um den Upload zu beenden"

