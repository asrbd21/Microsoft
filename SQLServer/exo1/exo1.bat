# On importe le fichier de creation de la base
sqlcmd.exe -u sa -i ./genese.sql
# On regarde les différentes tables qui existe afin de savoir ou chercher l'info
SELECT TABLE_NAME FROM AF.INFORMATION_SCHEMA.Tables WHERE TABLE_TYPE = 'BASE TABLE'
go
#1a Quel est l'âge du pilote de matricule 2 ? 
SELECT * FROM pilote WHERE matricule=2
go
#1b Quels sont les pilotes de la compagnie aérienne ? 
SELECT * FROM pilote
go
