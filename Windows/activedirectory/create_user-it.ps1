Import-module ActiveDirectory

# Création des Utilisateurs dans active directory, basé sur le fichier "Fichier RH Type - Aston.csv"
# Ce script s'appuie sur la variable $comptes, qui doit contenir le résultat de l'import du fichier csv.
# Exemple de commande d'import : $comptes = Import-Csv '.\Fichier RH Type - Aston.csv'
$comptes = Import-Csv '.\liste_users-it.csv'
# S'assurer que la variable $comptes contiens bien l'import avant de lancer la script
# S'assurer de lancer le script en tant qu'admin activé (UAC)

# GESTION DES MOTS DE PASSE

# Commenter / décommenter les lignes qui correspondent à votre politique de mot de passe
# En test, on peut souhaiter créer tous les comptes avec le même mot de passe

$mdp = read-host 'Mot de passe pour tous les utilisateurs' | ConvertTo-SecureString -AsPlainText -Force

$comptes | foreach { `
    # En production, chaque utilisateur doit avoir son propre mot de passe d'initialisation de compte.
    # $mdp = $_.'mot de passe initial' | ConvertTo-SecureString -AsPlainText -Force
    
    # check if OU exists, otherwise create it 
    Write-Host "Creation OU" $_.site
    try {New-ADOrganizationalUnit $_.Site -Path "DC=aston,DC=Local"} catch {"OU Existe Déjà"}
    
    #Create User
    
    New-ADUser -name ($_.Prenom + " " + $_.Nom) `
        -Path ('OU=' + $_.Site + ',dc=aston,dc=Local')`
        -AccountPassword $mdp `
        -ChangePasswordAtLogon $true `
        -City $_.Site `
        -Company "Aston" `
        -Country "FR" `
        -Description $_.Fonction`
        -Department $_.Service `
        -EmailAddress $_.Mail`
        -Enabled $true `
        -Fax $_.'No Fax'`
        -MobilePhone $_.Portable`
        -OfficePhone $_.'No Telephone'`
        -SamAccountName $_.Login`
        -Surname $_.Nom`
        -GivenName $_.Prenom`
        -UserPrincipalName $_.mail`
        
     #Create Groups
     
     try { `
     New-ADGroup -Name $_.service -SamAccountName $_.service`
        -DisplayName $_.Service `
        -Description ("Utilisateurs du service " + $_.Service) `
        -GroupScope Global `
        -Path ('OU=' + $_.Site + ',dc=aston,dc=Local')`
      }
     Catch {Write-Host "Le groupe "$_.service" existe"}
       
     #Add User to Groups
     Add-ADGroupMember -Identity $_.service  -Members $_.login
     }

