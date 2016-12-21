#ajouter l’interface graphique sur 2012R2
Import-Module ServerManager
Add-WindowsFeature Server-Gui-Shell
Shutdown /r /t 0
