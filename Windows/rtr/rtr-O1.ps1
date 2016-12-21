# Creer VHDx de Diff, creer VM avec trois cartes réseau

# Suite specialisation - Renommer Windows

Rename-Computer -NewName RTR-01

# Identifier les cartes en les branchant une a une puis les nommer

Rename-NetAdapter -Name "Ethernet" -NewName "CLI"
Rename-NetAdapter -Name "Ethernet 2" -NewName "WAN"
Rename-NetAdapter -Name "Ethernet 3" -NewName "SRV"

# Configuration IP des interfaces
# Attention les cartes doivent etres nommees AVANT

netsh int ipv4 set address "CLI" source=static 10.59.1.1/24
netsh int ipv4 set address "SRV" source=static 10.59.0.1/24
netsh int ipv4 set address "WAN" source=static 10.0.59.0/16

netsh int ip set dns WAN s=s 10.59.0.16

# Ajout de la route vers BOULOGNE et route par defaut

route add -p 0.0.0.0/0 10.0.0.1
route add -p 10.62.0.0/18 10.0.62.0

# Autoriser le ping entrant - ATTENTION aux composants d'integration

# netsh adv fire set ru name="Partage de fichiers et d’imprimantes (Demande d’écho - Trafic entrant ICMPv4)" new enable=yes

Get-NetFirewallRule *erq-in | Enable-NetFirewallRule

# Activer le routage sur les interfaces

# netsh int ipv4 set interface "SRV" forwarding=enabled
# netsh int ipv4 set interface "CLI" forwarding=enabled
# netsh int ipv4 set interface "WAN" forwarding=enabled

# Installer Role Routage et le démarrer

Install-WindowsFeature Routing -IncludeManagementTools

Set-Service RemoteAccess -StartupType Automatic
Start-Service RemoteAccess

# VERIF - Get-Service RemoteAccess

# Installer protocole routage (DHCP Relay)

netsh routing ip relay install

netsh routing ip relay add dhcpserver 10.59.0.16
netsh routing ip relay add interface "CLI"
netsh routing ip relay set interface "CLI" min=0

# VERIF - netsh routing ip relay sh global
# VERIF - netsh routing ip relay sh int

