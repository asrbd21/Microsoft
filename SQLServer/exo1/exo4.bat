use af 
go
SELECT * FROM pilote WHERE ville LIKE 'L%'AND (age < 20) AND (salaire > 60000)
go
SELECT numav, entrepot FROM avion WHERE entrepot NOT IN ('Marolles-en-Hurepoix') AND (capacite > 200) ORDER BY capacite desc
go
