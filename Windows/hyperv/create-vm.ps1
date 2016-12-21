# Les disques durs doivent être crées au préalable au format VHDX
# Le Chemin des Disques est en dur dans la commande

$VMName = Read-Host "Nom de la VM"

[Int]$NICs = Read-Host "Nombre de NICs"

[Int]$RAM = Read-Host "RAM (en Mo)"

[Int]$VMRAM = ($RAM * 1MB)

$VMPath = "D:\Hyper-V\VHDs\$VMName.vhdx"

New-VM -Name $VMName -MemoryStartupBytes $VMRAM -Generation 1 -VHDPath $VMPath

Set-VM $VMName -ProcessorCount 2 -DynamicMemory

[Int]$NIC = 1

# Do execute toujours la commande, puis évalue si il doit toujours continuer à éxécuter.
# Pas bon pour les VMs à une carte. (On peut contourner avec un IF avant)
# Do { $NIC++ ; Write-Host $val } while ($NIC -ne )

for(;$NIC -lt $NICs; $NIC++){Add-VMNetworkAdapter $VMName}

