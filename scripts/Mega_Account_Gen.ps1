cd C:/Users/$env:USERNAME/MEGA-Account-Generator
$a = Read-Host -Prompt "Wie viele Accounts?"
python generate_accounts.py -n $a -p Banana
python signin_accounts.py
open (.\accounts.csv)