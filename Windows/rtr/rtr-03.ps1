# Attention les cartes doivent etres nommees AVANT

# Suite specialisation - Renommer Windows

Rename-Computer -NewName RTR-03

# Identifier les cartes en les branchant une a une puis les nommer

Rename-NetAdapter -Name "Ethernet" -NewName "Salle"
Rename-NetAdapter -Name "Ethernet 2" -NewName "WAN"

netsh int ipv4 set address "Salle" source=dhcp
netsh int ipv4 set address "WAN" source=static 10.0.0.1/16

netsh int ip set dns WAN s=s 10.59.0.16

# Ajout des routes vers LILLE et BOULOGNE
# Pas de route par defaut - fournie par le DHCP du fournisseur (Salle)

route add -p 10.62.0.0/18 10.0.62.0
route add -p 10.59.0.0/18 10.0.59.0

# Autoriser le ping entrant


Get-NetFirewallRule *erq-in | Enable-NetFirewallRule


# Activer le routage sur les interfaces


Install-WindowsFeature Routing -IncludeManagementTools

Set-Service RemoteAccess -StartupType Automatic
Start-Service RemoteAccess

# Configuration NAT

netsh routing ip nat install

netsh routing ip nat add interface "Salle" mode=FULL
netsh routing ip nat add interface "WAN" mode=PRIVATE

# VERIF - netsh routing ip nat sh int
