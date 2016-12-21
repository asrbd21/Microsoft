# Attention les cartes doivent etres nommees AVANT

# Suite specialisation - Renommer Windows

Rename-Computer -NewName RTR-02

# Identifier les cartes en les branchant une a une puis les nommer

Rename-NetAdapter -Name "Ethernet" -NewName "Boulogne"
Rename-NetAdapter -Name "Ethernet 2" -NewName "WAN"

netsh int ipv4 set address "Boulogne" source=static 10.62.1.1/24
netsh int ipv4 set address "WAN" source=static 10.0.62.0/16

netsh int ip set dns WAN s=s 10.59.0.16

# Ajout de la route vers LILLE et route par defaut

route add -p 0.0.0.0/0 10.0.0.1
route add -p 10.59.0.0/18 10.0.59.0

# Autoriser le ping entrant

# netsh adv fire set ru name="Partage de fichiers et d’imprimantes (Demande d’écho - Trafic entrant ICMPv4)" new enable=yes

Get-NetFirewallRule *erq-in | Enable-NetFirewallRule

# Activer le routage sur les interfaces

# netsh int ipv4 set interface "Boulogne" forwarding=enabled
# netsh int ipv4 set interface "WAN" forwarding=enabled

Install-WindowsFeature Routing -IncludeManagementTools

Set-Service RemoteAccess -StartupType Automatic
Start-Service RemoteAccess


netsh routing ip relay install

netsh routing ip relay add dhcpserver 10.59.0.16
netsh routing ip relay add interface "Boulogne"
netsh routing ip relay set interface "Boulogne" min=0

# VERIF - netsh routing ip relay sh global
# VERIF - netsh routing ip relay sh int
