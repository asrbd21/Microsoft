# on se place dans le repertoire contenant les scripts et les fichiers de donnees
    $script_location = Split-Path $MyInvocation.MyCommand.Path       # on lit le chemin + nom de fichier du script et on le split pour ne garder que le chemin
    Set-Location -Path $script_location                              # on se déplace
# --------------------------------------------------------------------------------------------------------------
clear-host
Import-Module NTFSSecurity

# --------------------------------------------------------------------------------------------------------------
# ------------------------ On prépare la racine de partage pour les données utilisateurs du domaine ------------
# --------------------------------------------------------------------------------------------------------------
$cim = new-CimSession -ComputerName $srvfic                     # on crée une session cim pour executer des commandes localement a un serveur
#Remove-SmbShare -Force -Name $root_data -CimSession $cim       #on supprime le partage (pour tester le script)

$rep = "\\" + $srvfic + "\" + $local_drive + "$"                #on designe la racine du disque du serveur de fichier (chemin local)
If (-not (Test-Path $rep\$root_data))                           #si le repertoire qui sert de racine de partage n'existe pas
    {
    New-Item -ItemType Directory -Name $root_data -Path $rep # on crée le repertoire
    }

# --------------------------------------------------------------------------------------------------------------
# on definit les droits ntfs
# --------------------------------------------------------------------------------------------------------------
Add-ntfsAccess     -Path $rep\$root_data -Account BUILTIN\Administrateurs -AccessRights FullControl #admin FC
Disable-NTFSAccessInheritance -RemoveInheritedAccessRules -Path $rep\$root_data
#Add-ntfsAccess     -Path $rep\$root_data -Account BUILTIN\utilisateurs -AccessRights modify    #users M
# --------------------------------------------------------------------------------------------------------------

If (-not (Test-Path $data_path)) # si le partage sur le repertoire racine de partage n'existe pas
    {
    # "on crée le partage"
    New-SmbShare -Name $root_data -Path $local_share -FullAccess Administrateurs -ChangeAccess utilisateurs -CimSession $cim
    }

clear-host
# -------------------- on verrifie l'état du partage et de ses droits -----------------------------------------
Get-SmbShareAccess -Name donnees -CimSession $cim                      #lire les droits reseau sur partage distant
Get-NTFSAccess -Path $rep\$root_data | Format-Table -AutoSize          #lire les droits NTFS sur rep distant
# --------------------------------------------------------------------------------------------------------------


$var = @($grp_path,$users_path,$pub_path)                              # on liste les repertoires devant etre traités

foreach ($rep in $var) 
 {
    write-host "----------------------------------------------------------------"
    write-host " on traite le chemin de : " $rep
    If (-not (Test-Path $rep)) 
        { 
        New-Item -Force -Path $rep -ItemType Directory
        write-host -BackgroundColor Black -ForegroundColor Green "   --> le dossier est créé"
        }
        else 
            {
            write-host -BackgroundColor Black -ForegroundColor Yellow "   --> le dossier existe déja"
            }
    write-host "----------------------------------------------------------------`n"
}


<#
Get-ChildItem -Path $data_path | Format-Table



clear-host
$rep = ".\toto"
remove-NTFSAccess -Path $rep -Account BUILTIN\Administrateurs -AccessRights FullControl
Get-NTFSAccess -Path $rep | Format-Table -AutoSize
Write-Host "----------------------------------------------------------------"
Add-NTFSAccess -Path $rep -Account BUILTIN\Administrateurs -AccessRights FullControl
Get-NTFSAccess -Path $rep | Format-Table -AutoSize

AUTORITE NT\Utilisateurs authentifiés 
FORMATION\administrateur              
AUTORITE NT\Système                   
BUILTIN\Administrateurs               
FORMATION\administrateur           

#>
