/*CREANDO LA BASE DE DATOS LOAD_ACCIDENTS*/
/*EN ESTA BD SE CARGARAN LOS DATOS TAL CUAL EL CSV*/

USE master
GO

IF EXISTS(SELECT NAME FROM SYS.databases WHERE NAME='LOAD_ACCIDENTS')
BEGIN
	DROP DATABASE LOAD_ACCIDENTS
END
GO

CREATE DATABASE LOAD_ACCIDENTS
GO

USE LOAD_ACCIDENTS
GO


SET ANSI_NULLS ON /*CONTROL Y MANEJO CORRECTO DE LOS VALORES NULL EN LAS COMPARACIONES*/
GO

SET QUOTED_IDENTIFIER ON /*PERMITE NOMBRES DE OBJETOS MAS FLEXIBLES Y EVITA PROBLEMAS CON PALABRAS RESERVADAS*/
GO

CREATE DATABASE LOAD_ACCIDENTS

/*CREANDO LA TABLA L_ACCIDENTS*/
CREATE TABLE L_ACCIDENTS (
	Id_Staging int identity primary key not null,
    ID varchar(50),
    Source VARCHAR(50),
    Severity int,
    Start_Time DATETIME2,
    End_Time DATETIME2,
    Start_Lat FLOAT,
    Start_Lng FLOAT,
    End_Lat FLOAT,
    End_Lng FLOAT,
    Distance_mi FLOAT,
    Description VARCHAR(800),
    Street VARCHAR(500),
    City VARCHAR(100),
    County VARCHAR(100),
    State VARCHAR(50),
    Zipcode VARCHAR(50),
    Country VARCHAR(50),
    Timezone VARCHAR(50),
    Airport_Code VARCHAR(50),
    Weather_Timestamp DATETIME2,
    Temperature_F FLOAT,
    Wind_Chill_F FLOAT,
    Humidity FLOAT,
    Pressure_in FLOAT,
    Visibility_mi FLOAT,
    Wind_Direction VARCHAR(50),
    Wind_Speed_mph FLOAT,
    Precipitation_in FLOAT,
    Weather_Condition VARCHAR(100),
    Amenity VARCHAR(10),
    Bump VARCHAR(10),
    Crossing VARCHAR(10),
    Give_Way VARCHAR(10),
    Junction VARCHAR(10),
    No_Exit VARCHAR(10),
    Railway VARCHAR(10),
    Roundabout VARCHAR(10),
    Station VARCHAR(10),
    Stop VARCHAR(10),
    Traffic_Calming VARCHAR(10),
    Traffic_Signal VARCHAR(10),
    Turning_Loop VARCHAR(10),
    Sunrise_Sunset VARCHAR(10),
    Civil_Twilight VARCHAR(10),
    Nautical_Twilight VARCHAR(10),
    Astronomical_Twilight VARCHAR(10)
);


/*CREANDO E INSERTANDO DATOS EN TABLA STATE_REFERENCE PARA EL CRUCE DE NOMBRES DE ESTADOS Y REEMPLAZAR SU NOMBRE EN LUGAR DE SU ABREVIACION*/

CREATE TABLE STATE_REFERENCE (
    State_Abbreviation CHAR(2) PRIMARY KEY,
    State_Name VARCHAR(50)
);

INSERT INTO STATE_REFERENCE (State_Abbreviation, State_Name)
VALUES 
('AL', 'Alabama'), ('AK', 'Alaska'), ('AZ', 'Arizona'),('AR', 'Arkansas'),
('CA', 'California'),('CO', 'Colorado'),('CT', 'Connecticut'),
('DE', 'Delaware'),('FL', 'Florida'),('GA', 'Georgia'),
('HI', 'Hawaii'),('ID', 'Idaho'),('IL', 'Illinois'),
('IN', 'Indiana'),('IA', 'Iowa'),('KS', 'Kansas'),
('KY', 'Kentucky'),('LA', 'Louisiana'),('ME', 'Maine'),
('MD', 'Maryland'),('MA', 'Massachusetts'),('MI', 'Michigan'),
('MN', 'Minnesota'),('MS', 'Mississippi'),('MO', 'Missouri'),
('MT', 'Montana'),('NE', 'Nebraska'),('NV', 'Nevada'),
('NH', 'New Hampshire'),('NJ', 'New Jersey'),('NM', 'New Mexico'),
('NY', 'New York'),('NC', 'North Carolina'),('ND', 'North Dakota'),
('OH', 'Ohio'),('OK', 'Oklahoma'),('OR', 'Oregon'),
('PA', 'Pennsylvania'),('RI', 'Rhode Island'),('SC', 'South Carolina'),
('SD', 'South Dakota'),('TN', 'Tennessee'),('TX', 'Texas'),
('UT', 'Utah'),('VA', 'Virginia'),('VT', 'Vermont'),
('WA', 'Washington'),('WI', 'Wisconsin'),('WV', 'West Virginia'),
('WY', 'Wyoming');


