"
dependances :
Module NTFSSecurity 3.2.2  
AD_Variables.ps1
    AD_variables.csv
    AD_rep.ps1
    AD_RAZ_01.ps1
"
"
I phase préliminaire modalité d'éxécution
    a : verrifier ExecutionPolicy
    b : verrifier ExecutionPolicy
    c : se placer dans le repertoire du script

II création des fonctions

III declaration des variables

IV  phase netoyage preliminaire a l'execution du script
    a : suppretion - créarion de l'OU de base
    b : suppretion - créarion des repertoires de donnees

V création des utilisateurs (foreach)
    a : declaration des variables
    b : création de l'OU si elle n'éxiste pas
    c : verrification création du Groupe Global
        c1 : création du groupe si il n'existe pas
        c2 : création du repertoire de goupe avec droits

    d : création de l'utilisateur
        d1 : création de l'utilisateur
        d2 : integration aux groupes
        d3 : création du repertoire perso avec droits
"
$exec_deb = Get-Date

Clear-Host

<#
    #----------------------------------------------------------------------------------------
    # autoriser l'execution de scrip powershell (a daisir une fois dans la console) :
        #Set-ExecutionPolicy unrestricted -force
    # verrifier l'execution de scrip powershell :
        #Get-ExecutionPolicy
    #----------------------------------------------------------------------------------------
    # Chargement du module Active Directory
    # ne fonctionne que sur un serveur "enlever le #"
        #Import-Module ActiveDirectory
        #import-module NTFSSecurity     # version 3.2.2
    #----------------------------------------------------------------------------------------
#>
# on se place dans le repertoire contenant les scripts et les fichiers de donnees
    $script_location = Split-Path $MyInvocation.MyCommand.Path       # on lit le chemin + nom de fichier du script et on le split pour ne garder que le chemin
    Set-Location -Path $script_location                              # on se déplace


#--------- liste des fonctions ----------------------------------------------------------
function suppr-accent([string]$String){

    $objD = $String.Normalize([Text.NormalizationForm]::FormD)
    $sb = New-Object Text.StringBuilder

    for ($i = 0; $i -lt $objD.Length; $i++) {
        $c = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($objD[$i])
        if($c -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
          [void]$sb.Append($objD[$i])
        }
      }

    return("$sb".Normalize([Text.NormalizationForm]::FormC))
}
#----------------------------------------------------------------------------------------


#----------- Traitement des dépendances (voir au début) --------------------
# --------------- variables communes ---------------------------------------
    . ".\AD_Variables.ps1"
# --------------- creation des repertoires sur le serveur de fichiers ------
    . ".\AD_rep.ps1"
# --------------- RAZ OU power et suppr rep users et groupes ---------------
    . ".\AD_RAZ_01.ps1"
# --------------------------------------------------------------------------

# -------------------- variables locales au script -------------------------
# lecture du fichier CSV
    write-host -ForegroundColor Green "----------------------------lecture du fichier CSV---------------------------------------"
    write-host -ForegroundColor Green "----------------------integration des donnees dans la variable ImportCSV ----------------"

    $ImportCSV = import-csv -path "$fichier" -delimiter ";"          # Importation du fichier CSV dans la variable $ImportCSV
# --------------------------------------------------------------------------
clear-host

# --------------------- Création des l'utilisateurs et des groupes ---------------------------------------------------------------
write-host -ForegroundColor Green "------------------------Création des l'utilisateurs et des groupes------------------------------"
write-host -ForegroundColor Green "------------------------------------------------------------------------------------------------"
write-host
write-host

Foreach($user IN $ImportCSV) {
    # déclaration des variables
    # on lit les données du CSV qui ont été injectées dans la variable $USER
    $pass = $user.Password
    $nom = $user.Surname
    $prenom = $user.GivenName
    $displayname = $user.GivenName +" "+ $user.Surname
    $login = $user.SamAccountName
    $Userlogon = $user.Userlogon    
    $OUName = $user.OU
    $description = $user.Description
    $Group = $user.Groupe
    $group_rep = $Group
    $Group = "GG_" + $user.Groupe

# création de l'OU si elle n'éxiste pas
# -------------------------------------
    #New-ADOrganizationalUnit -Name musiciens -ProtectedFromAccidentalDeletion $false -Path "ou=power,DC=caen,DC=lan"
    $path = "OU=" + $oubase + ",DC=" + $domaine + ",DC=" + $tld
    $ldap_path = "OU=" + $OUName + "," + $path 
write-host "path = " $path
write-host "ldap_path = " $ldap_path
write-host "ouname = " $OUName
set-location AD:/                                                   # on se place dans l'Ad à la racine


    If (-not (Test-Path .\$ldap_path))     # on test si l'OU de base existe
        {
#        Write-Host "l'OU $ouname n'existe pas"
#        Write-Host New-ADOrganizationalUnit -Name $OUName -ProtectedFromAccidentalDeletion $false -Path $path
            New-ADOrganizationalUnit -Name $OUName -ProtectedFromAccidentalDeletion $false -Path $path
        }
        else 
            {
            write-host "l'OU $ouname existe"
            }

Set-Location -Path $script_location

    # on recherche le nom de l'OU dans l'AD pour en lire le distinguishedName (chemin LDAP)
    $OUSearch = Get-ADOrganizationalUnit -Filter 'Name -like $OUName'
    $OUDN = $OUSearch.distinguishedName # OU=OUdestination,OU=...,DC=xx,DC=xx

write-host "path =              " $path
write-host "OUName =            " $OUName
write-host "OUDN =              " $oudn




write-host "création du groupe si il n'existe pas"
write-host " -------------------------------------"
$group = suppr-accent $Group
write-host $Group
    $gg = Get-ADGroup -filter {samAccountName -like $group}
    if ( !$gg ) 
        { 
write-host -ForegroundColor Green création du groupe $group
                   New-ADGroup -Name $Group        -SamAccountName $Group     -GroupCategory Security -GroupScope Global -DisplayName $Group                -Path $path -Description "description du groupe $group"  
write-host -ForegroundColor Green le groupe $group est créé dans $OUDN

write-host creation du dossier pour le groupe $group
        New-Item $grp_path\$group_rep -type directory

write-host puis nous attriburons les droits NTFS sur ce dossier
        Add-ntfsAccess     -Path $grp_path\$group_rep -Account $domaine\$Group -AccessRights Modify
write-host
        } 
        else
            {
            write-host -ForegroundColor yellow le groupe $group existe déja donc on ne fait rien
            }

# création de l'utilisateur
# -------------------------
write-host -ForegroundColor Green "Création de l'utilisateur en cours : $displayname ($login) dans $OUDN"

$login = suppr-accent $login.ToLower()             #on supprime les accents etc....
$Userlogon = suppr-accent $Userlogon.ToLower()     #on supprime les accents etc....

#   Remove-ADUser -Identity $login -Confirm:$false

    New-ADUser `
        -Name $displayname `
        -Surname $nom `
        -GivenName $prenom `
        -DisplayName $displayname `
        -SamAccountName $login `
        -UserPrincipalName $Userlogon@$domaine.$tld `
        -HomeDirectory $users_path\$login\homedir `
        -HomeDrive p: `
        -AccountPassword (convertto-securestring $pass -asplaintext -force) `
        -PasswordNeverExpires $true `
        -PasswordNotRequired $true `
        -Path $OUDN `
        -enabled $true `
        -Description $description `
<##>
    Add-ADGroupMember -Identity $group -Members $login

write-host creation du dossier perso de $displayname
    New-Item $users_path\$login\homedir -type directory

write-host attribution des droits NTFS sur le dossier
    Add-ntfsAccess     -Path $users_path\$login -Account $domaine\$login -AccessRights Modify
write-host
write-host
#Read-Host "fin de la boucle foreach"
}
$exec_fin = Get-Date
$exec_duree = ((Get-Date $exec_fin) - (Get-Date $exec_deb)).tostring()

Write-Host -ForegroundColor Green "--------------------------------------------------------------------------------------------"
Write-Host -ForegroundColor Green "----------------------------- durée du script :" $exec_duree
write-Host -ForegroundColor Green "--------------------------------------------------------------------------------------------"
read-Host



