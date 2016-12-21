DROP DATABASE AF
GO
CREATE DATABASE AF
GO
USE AF
GO
CREATE TABLE avion
(
  numav int CONSTRAINT pk_avion PRIMARY KEY identity(1,1),
  capacite int,
  type VARCHAR(20),
  entrepot VARCHAR(30)
)

CREATE TABLE pilote
(
  matricule int CONSTRAINT pk_pilote PRIMARY KEY identity(1,1),
  nom VARCHAR(25) NOT NULL,
  ville VARCHAR(30),
  age int,
  salaire int
)

CREATE TABLE passager
(
  numab int CONSTRAINT pk_passager PRIMARY KEY identity(1,1),
  nomab VARCHAR(30)
)

CREATE TABLE vol
(
  numvol VARCHAR(10) CONSTRAINT pk_vol PRIMARY KEY,
  heure_depart datetime,
  heure_arrivee datetime,
  ville_depart VARCHAR(30),
  ville_arrivee VARCHAR(30)
)

CREATE TABLE depart
(
  numvol VARCHAR(10),
  date_dep datetime,
  numav int,
  matricule int,
  CONSTRAINT pk_depart PRIMARY KEY (numvol, date_dep)
)

CREATE TABLE Reservation
(
  numab int,
  numvol VARCHAR(10),
  date_dep datetime,
  CONSTRAINT pk_reservation PRIMARY KEY ( numvol, date_dep, numab)
)
GO
ALTER TABLE depart
ADD CONSTRAINT fk_depart_vol
	FOREIGN KEY(numvol)
	REFERENCES Vol(numvol)
	ON DELETE CASCADE
	
ALTER TABLE depart
ADD CONSTRAINT fk_depart_avion
	FOREIGN KEY(numav)
	REFERENCES Avion(numav)
	ON DELETE SET NULL
	
ALTER TABLE depart
ADD CONSTRAINT fk_depart_pilote
	FOREIGN KEY(matricule)
	REFERENCES Pilote(matricule)
	ON DELETE SET NULL

ALTER TABLE Reservation
ADD CONSTRAINT fk_reservation_depart
  	FOREIGN KEY(numvol, date_dep)
  	REFERENCES Depart(numvol, date_dep)
  	ON DELETE CASCADE
	
ALTER TABLE Reservation
ADD CONSTRAINT fk_reservation_passager
  	FOREIGN KEY(numab)
  	REFERENCES Passager(numab)
  	ON DELETE CASCADE
GO
/* Index sur les clés étrangères de Depart */
CREATE INDEX Ind_Matricule_Depart
ON Depart (Matricule)

CREATE INDEX Ind_Numav_Depart
ON Depart (Numav)
/* Index sur les clés étrangères de Reservation */
CREATE INDEX Ind_Passager_Reservation
ON Reservation (Numab)
GO