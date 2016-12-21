# Creer VHDx de Diff, creer VM avec trois cartes réseau

# Suite specialisation - Renommer Windows

Rename-Computer -NewName SRV-01

netsh int ipv4 set address "Ethernet" source=static 10.59.0.16/24

# Ajout de la route vers BOULOGNE et route par defaut

route add -p 0.0.0.0/0 10.59.0.1

# Autoriser le ping entrant - ATTENTION aux composants d'integration

# netsh adv fire set ru name="Partage de fichiers et d’imprimantes (Demande d’écho - Trafic entrant ICMPv4)" new enable=yes

Get-NetFirewallRule *erq-in | Enable-NetFirewallRule

# Instal des roles 

Restart-computer -force
