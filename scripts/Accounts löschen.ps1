# Pfad zur CSV-Datei
$dateiPfad = "C:\Users\$env:USERNAME\MEGA-Account-Generator\accounts.csv"

# Dateiinhalt anzeigen (optional)
Write-Host "Die Datei '$dateiPfad' wird bereinigt (nur die Kopfzeile bleibt erhalten)."

# Sicherheitsabfrage
$antwort = Read-Host "Bist du sicher, dass du alle Einträge außer der Kopfzeile löschen möchtest? (ja/nein)"

if ($antwort -eq "ja") {
    # Nur die erste Zeile (Kopfzeile) lesen
    $kopfzeile = Get-Content $dateiPfad | Select-Object -First 1

    # Die Datei mit nur der Kopfzeile überschreiben
    $kopfzeile | Set-Content $dateiPfad

    Write-Host "Die Datei wurde bereinigt."
} else {
    Write-Host "Abgebrochen. Die Datei wurde nicht verändert."
}
