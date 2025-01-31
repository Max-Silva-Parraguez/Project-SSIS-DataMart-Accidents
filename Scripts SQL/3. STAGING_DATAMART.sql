----CREACION DE BASE DE DATOS DATAMART_ACCIDENTS
USE master
GO

IF EXISTS(SELECT NAME FROM SYS.databases WHERE NAME='DATAMART_NORTHWND')
BEGIN
	DROP DATABASE DATAMART_ACCIDENTS
END
GO

CREATE DATABASE DATAMART_ACCIDENTS
GO

USE DATAMART_ACCIDENTS
GO

----CREACION DE DIMENSIONES Y TABLA HECHO
----MOEDELO DE ESTRELLA

-- Dimensión: Ubicación
CREATE TABLE Dim_Location (
    Location_Key INT PRIMARY KEY IDENTITY(1,1),
	Location_Codigo INT,
    City VARCHAR(100),
    State VARCHAR(50),
    County VARCHAR(100),
	Street VARCHAR(500),
	Zipcode VARCHAR(50),
	Start_Latitude FLOAT,
	Start_Longitude FLOAT,
	End_Latitude FLOAT,
	End_Longitude FLOAT,
	Timezone VARCHAR(50),
	Airport_Code VARCHAR(50)
);

-- Dimensión: Clima
CREATE TABLE Dim_Weather (
    Weather_Key INT PRIMARY KEY IDENTITY(1,1),
	Weather_Codigo INT,
	Temperature FLOAT,
	Wind_Chill FLOAT,
    Humidity FLOAT,
	Pressure FLOAT,
	Visibility FLOAT,
	Wind_Direction VARCHAR(50),
    Wind_Speed FLOAT,
	Precipitation FLOAT,
	Weather_Condition VARCHAR(100)
);

-- Dimensión: Características de la Carretera
CREATE TABLE Dim_Road_Features (
    Road_Features_Key INT PRIMARY KEY IDENTITY(1,1),
	Road_Features_Codigo INT,
    Bump VARCHAR(10),
    Crossing VARCHAR(10),
	Give_Way VARCHAR(10),
    Junction VARCHAR(10),
	No_Exit VARCHAR(10),
	Roundabout VARCHAR(10),
	Stop VARCHAR(10),
    Traffic_Signal VARCHAR(10),
	Turning_Loop VARCHAR(10)
);

-- Dimensión: Descripcion de Accidentes
CREATE TABLE Dim_Description_Accidents (
    Description_Accidents_Key INT PRIMARY KEY IDENTITY(1,1),
	Description_Accidents_Codigo INT,
    Description VARCHAR(800)
);


-- Dimensión: Tiempo
CREATE TABLE [DATAMART_ACCIDENTS].[dbo].[Dim_Time](
	[Tiempo_Skey] INT PRIMARY KEY IDENTITY(1,1),
	[Tiempo_Codigo] INT,
	[Tiempo_FechaInicio] DATETIME,
	[Tiempo_FechaFin] DATETIME,
	[Tiempo_Anio] INT,
	[Tiempo_Trimestre] INT,
	[Tiempo_Mes] INT,
	[Tiempo_Semana] INT,
	[Tiempo_DiaDeAnio] INT,
	[Tiempo_DiaDeMes] INT,
	[Tiempo_DiaDeSemana] INT,
	[Tiempo_EsFinSemana] INT,
	[Tiempo_EsFeriado] INT,
	[Tiempo_SemanaCalendario] INT,
	[Tiempo_SemanasDelAnioLaborales] INT,
	[Tiempo_AnioBisiesto] INT,
	[Hour_Inicio] TIME,
	[Hour_Fin] TIME
);


-- Tabla de Hechos
CREATE TABLE Fact_Accidents (
    Fact_Accidents_Key INT PRIMARY KEY IDENTITY(1,1),
    Location_Key INT NOT NULL,
    Weather_Key INT NOT NULL,
    Road_Features_Key INT NOT NULL,
    Description_Accidents_Key INT NOT NULL,
    Tiempo_Skey INT NOT NULL,
	Distance FLOAT,
    Severity INT,
	Duration_minutes INT
    FOREIGN KEY (Location_Key) REFERENCES Dim_Location(Location_Key),
    FOREIGN KEY (Weather_Key) REFERENCES Dim_Weather(Weather_Key),
    FOREIGN KEY (Road_Features_Key) REFERENCES Dim_Road_Features(Road_Features_Key),
    FOREIGN KEY (Description_Accidents_Key) REFERENCES Dim_Description_Accidents(Description_Accidents_Key),
    FOREIGN KEY (Tiempo_Skey) REFERENCES Dim_Time(Tiempo_Skey)
);


------------------------------------------------------------------------------------------------------------
/*CONSULTAS PARA POBLAMIENTO DE DIMENSIONES Y TABLA HECHOS*/
------------------------------------------------------------------------------------------------------------
/*1.A CONSULTA PARA EXTRAER DATOS DE S_ACCIDENTS PARA DIM_LOCATION*/
--------------------------------------------------------------
SELECT
	Id_Staging,
	City,
	State,
	County,
	Street,
	Zipcode,
	Start_Lat,
	Start_Lng,
	End_Lat,
	End_Lng,
	Timezone,
	Airport_Code
FROM STAGING_ACCIDENTS.dbo.S_ACCIDENTS
ORDER BY Id_Staging

--------------------------------------------------------------
/*1.B. CONSULTA PARA VISUALIZAR DATOS DE DIM_LOCATION */
--------------------------------------------------------------

SELECT 
	   [Location_Key]
      ,[Location_Codigo]
      ,[City]
      ,[State]
      ,[County]
      ,[Street]
      ,[Zipcode]
      ,[Start_Latitude]
      ,[Start_Longitude]
      ,[End_Latitude]
      ,[End_Longitude]
      ,[Timezone]
      ,[Airport_Code]
  FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Location]
  ORDER BY Location_Codigo

----------------------------------------------------------------
/*1.C. CREANDO TABLA MODIFICADOS DE LOCATION EN BD STAGING_ACCIDENTS */
----------------------------------------------------------------
CREATE TABLE [STAGING_ACCIDENTS].[dbo].[Dim_Location_Mod] (
    Location_Key INT PRIMARY KEY IDENTITY(1,1),
	Location_Codigo INT,
    City VARCHAR(100),
    State VARCHAR(50),
    County VARCHAR(100),
	Street VARCHAR(500),
	Zipcode VARCHAR(50),
	Start_Latitude FLOAT,
	Start_Longitude FLOAT,
	End_Latitude FLOAT,
	End_Longitude FLOAT,
	Timezone VARCHAR(50),
	Airport_Code VARCHAR(50),
	ETL_DateLoad DATETIME
);

----------------------------------------------------------------
/*1.D. INSERTAR REGISTROS EN LA TABLA Dim_Location_Mod */
----------------------------------------------------------------

INSERT INTO [STAGING_ACCIDENTS].[dbo].[Dim_Location_Mod]
([Location_Codigo],[City],[State],[County],[Street],[Zipcode],[Start_Latitude],[Start_Longitude],[End_Latitude],[End_Longitude],[Timezone],[Airport_Code],[ETL_DateLoad])
VALUES
(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())

----------------------------------------------------------------
/*1.E. Actualizar la tabla Dim_Location */
----------------------------------------------------------------

UPDATE DT
SET DT.City = ST.City,
	DT.State = ST.State,
	DT.County = ST.County,
	DT.Street = ST.Street,
	DT.Zipcode = ST.Zipcode,
	DT.Start_Latitude = ST.Start_Lat,
	DT.Start_Longitude = ST.Start_Lng,
	DT.End_Latitude = ST.End_Lat,
	DT.End_longitude = ST.End_Lng,
	DT.Timezone = ST.Timezone,
	DT.Airport_Code = ST.Airport_Code
FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Location] AS DT
JOIN
	[STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS] AS ST
	ON DT.Location_Codigo = ST.Id_Staging
WHERE DT.Location_Key = ?

--------------------------------------------------------------
/*2.A CONSULTA PARA EXTRAER DATOS DE S_ACCIDENTS PARA DIM_WEATHER */
--------------------------------------------------------------
SELECT
	Id_Staging,
	Temperature_F,
	Wind_Chill_F,
	Humidity,
	Pressure_in,
	Visibility_mi,
	Wind_Direction,
	Wind_Speed_mph,
	Precipitation_in,
	Weather_Condition
FROM STAGING_ACCIDENTS.dbo.S_ACCIDENTS
ORDER BY Id_Staging


--------------------------------------------------------------
/*2.B. CONSULTA PARA CONSULTAR DATOS DE DIM_WEATHER */
--------------------------------------------------------------

SELECT 
	   [Weather_Key]
      ,[Weather_Codigo]
      ,[Temperature]
      ,[Wind_Chill]
      ,[Humidity]
      ,[Pressure]
      ,[Visibility]
      ,[Wind_Direction]
      ,[Wind_Speed]
      ,[Precipitation]
      ,[Weather_Condition]
 FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Weather]
 ORDER BY Weather_Codigo

 ----------------------------------------------------------------
/*2.C. CREANDO TABLA MODIFICADOS DE WEATHER EN BD STAGING_ACCIDENTS */
----------------------------------------------------------------
CREATE TABLE [STAGING_ACCIDENTS].[dbo].[Dim_Weather_Mod] (
    Weather_Key INT PRIMARY KEY IDENTITY(1,1),
	Weather_Codigo INT,
	Temperature FLOAT,
	Wind_Chill FLOAT,
    Humidity FLOAT,
	Pressure FLOAT,
	Visibility FLOAT,
	Wind_Direction VARCHAR(50),
    Wind_Speed FLOAT,
	Precipitation FLOAT,
	Weather_Condition VARCHAR(100),
	ETL_DateLoad DATETIME
);

----------------------------------------------------------------
/*2.D. INSERTAR REGISTROS EN LA TABLA Dim_Weather_Mod */
----------------------------------------------------------------

INSERT INTO [STAGING_ACCIDENTS].[dbo].[Dim_Weather_Mod]
([Weather_Codigo],[Temperature],[Wind_Chill],[Humidity],[Pressure],[Visibility],[Wind_Direction],[Wind_Speed],[Precipitation],[Weather_Condition],[ETL_DateLoad])
VALUES
(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())

----------------------------------------------------------------
/*2.E. Actualizar la tabla Dim_Weather */
----------------------------------------------------------------

UPDATE DT
SET DT.Temperature = ST.Temperature_F,
	DT.Wind_Chill = ST.Wind_Chill_F,
	DT.Humidity = ST.Humidity,
	DT.Pressure = ST.Pressure_in,
	DT.Visibility = ST.Visibility_mi,
	DT.Wind_Direction = ST.Wind_Direction,
	DT.Wind_Speed = ST.Wind_Speed_mph,
	DT.Precipitation = ST.Precipitation_in,
	DT.Weather_Condition = ST.Weather_Condition
FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Weather] AS DT
JOIN
	[STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS] AS ST
	ON DT.Weather_Codigo = ST.Id_Staging
WHERE DT.Weather_Key = ?

--------------------------------------------------------------
/*3.A CONSULTA PARA EXTRAER DATOS DE S_ACCIDENTS PARA DIM_ROAD_FEATURES */
--------------------------------------------------------------
SELECT
	Id_Staging,
	Bump,
	Crossing,
	Give_Way,
	Junction,
	No_Exit,
	Roundabout,
	Stop,
	Traffic_Signal,
	Turning_Loop
FROM STAGING_ACCIDENTS.dbo.S_ACCIDENTS
ORDER BY Id_Staging

--------------------------------------------------------------
/*3.B. CONSULTA PARA CONSULTAR DATOS DE DIM_ROAD_FEATURES */
--------------------------------------------------------------

SELECT
	   [Road_Features_Key]
      ,[Road_Features_Codigo]
      ,[Bump]
      ,[Crossing]
      ,[Give_Way]
      ,[Junction]
      ,[No_Exit]
      ,[Roundabout]
      ,[Stop]
      ,[Traffic_Signal]
      ,[Turning_Loop]
 FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Road_Features]
 ORDER BY [Road_Features_Codigo]

  ----------------------------------------------------------------
/*3.C. CREANDO TABLA MODIFICADOS DE ROAD_FEATURES EN BD STAGING_ACCIDENTS */
----------------------------------------------------------------
CREATE TABLE [STAGING_ACCIDENTS].[dbo].[Dim_Road_Features_Mod] (
    Road_Features_Key INT PRIMARY KEY IDENTITY(1,1),
	Road_Features_Codigo INT,
    Bump VARCHAR(10),
    Crossing VARCHAR(10),
	Give_Way VARCHAR(10),
    Junction VARCHAR(10),
	No_Exit VARCHAR(10),
	Roundabout VARCHAR(10),
	Stop VARCHAR(10),
    Traffic_Signal VARCHAR(10),
	Turning_Loop VARCHAR(10),
	ETL_DateLoad DATETIME
);


----------------------------------------------------------------
/*3.D. INSERTAR REGISTROS EN LA TABLA Dim_Road_Features_Mod */
----------------------------------------------------------------

INSERT INTO [STAGING_ACCIDENTS].[dbo].[Dim_Road_Features_Mod]
([Road_Features_Codigo],[Bump],[Crossing],[Give_Way],[Junction],[No_Exit],[Roundabout],[Stop],[Traffic_Signal],[Turning_Loop],[ETL_DateLoad])
VALUES
(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())


----------------------------------------------------------------
/*3.E. Actualizar la tabla Dim_Road_Feature */
----------------------------------------------------------------

UPDATE DT
SET DT.Bump = ST.Bump,
	DT.Crossing = ST.Crossing,
	DT.Give_Way = ST.Give_Way,
	DT.Junction = ST.Junction,
	DT.No_Exit = ST.No_Exit,
	DT.Roundabout = ST.Roundabout,
	DT.Stop = ST.Stop,
	DT.Traffic_Signal = ST.Traffic_Signal,
	DT.Turning_Loop = ST.Turning_Loop
FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Road_Features] AS DT
JOIN
	[STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS] AS ST
	ON DT.Road_Features_Codigo = ST.Id_Staging
WHERE DT.Road_Features_Key = ?


--------------------------------------------------------------
/*4.A CONSULTA PARA EXTRAER DATOS DE S_ACCIDENTS PARA DIM_DESCRIPTION_ACCIDENTS*/
--------------------------------------------------------------
SELECT
	Id_Staging,
	Description
FROM STAGING_ACCIDENTS.dbo.S_ACCIDENTS
ORDER BY Id_Staging

--------------------------------------------------------------
/*4.B. CONSULTA PARA CONSULTAR DATOS DE DIM_DESCRIPTION_ACCIDENTS */
--------------------------------------------------------------

SELECT
       [Description_Accidents_Key]
      ,[Description_Accidents_Codigo]
      ,[Description]
  FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Description_Accidents]
 ORDER BY [Description_Accidents_Codigo]

   ----------------------------------------------------------------
/*4.C. CREANDO TABLA MODIFICADOS DE DIM_DESCRIPTION_ACCIDENTS EN BD STAGING_ACCIDENTS */
----------------------------------------------------------------
CREATE TABLE [STAGING_ACCIDENTS].[dbo].[Dim_Description_Accidents_Mod] (
    Description_Accidents_Key INT PRIMARY KEY IDENTITY(1,1),
	Description_Accidents_Codigo INT,
    Description VARCHAR(800),
	ETL_DateLoad DATETIME
);

----------------------------------------------------------------
/*4.D. INSERTAR REGISTROS EN LA TABLA Dim_Description_Accidents_Mod */
----------------------------------------------------------------

INSERT INTO [STAGING_ACCIDENTS].[dbo].[Dim_Description_Accidents_Mod]
([Description_Accidents_Codigo],[Description],[ETL_DateLoad])
VALUES
(?,?, GETDATE())

----------------------------------------------------------------
/*4.E. Actualizar la tabla Dim_Description_Accidents */
----------------------------------------------------------------

UPDATE DT
SET DT.Description = ST.Description
FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Description_Accidents] AS DT
JOIN
	[STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS] AS ST
	ON DT.Description_Accidents_Codigo = ST.Id_Staging
WHERE DT.Description_Accidents_Key = ?


select * from Dim_Description_Accidents


--------------------------------------------------------------
/*5.A. CONSULTA PARA EXTRAER DATOS DE S_ACCIDENTS PARA DIM_TIME*/
--------------------------------------------------------------
SELECT
	(Id_Staging),
	(Start_Time), 
	(End_Time),
    YEAR(Start_Time) AS Anio,
    DATEPART(QUARTER, Start_Time) AS Trimestre,
    DATEPART(MONTH, Start_Time) AS Mes,
    DATEPART(WEEK, Start_Time) AS Semana,
    DATEPART(DAYOFYEAR, Start_Time) AS DiaDeAnio,
    DATEPART(DAY, Start_Time) AS DiaDeMes,
    DATEPART(WEEKDAY, DATEADD(DAY, -1, Start_Time)) AS DiaDeSemana,
    IIF((DATEPART(WEEKDAY, DATEADD(DAY, -1, Start_Time)) = 6 OR DATEPART(WEEKDAY, DATEADD(DAY, -1, Start_Time)) = 7), 1, 0) AS EsFinSemana,
    IIF((DATEPART(MONTH, Start_Time) = 1 AND DATEPART(DAY, Start_Time) = 1) OR
        (DATEPART(MONTH, Start_Time) = 1 AND DATEPART(DAY, Start_Time) = 18) OR
        (DATEPART(MONTH, Start_Time) = 2 AND DATEPART(DAY, Start_Time) = 15) OR
        (DATEPART(MONTH, Start_Time) = 3 AND DATEPART(DAY, Start_Time) = 27) OR
        (DATEPART(MONTH, Start_Time) = 5 AND DATEPART(DAY, Start_Time) = 30) OR
        (DATEPART(MONTH, Start_Time) = 7 AND DATEPART(DAY, Start_Time) = 4) OR
        (DATEPART(MONTH, Start_Time) = 9 AND DATEPART(DAY, Start_Time) = 5) OR
		(DATEPART(MONTH, Start_Time) = 10 AND DATEPART(DAY, Start_Time) = 10) OR
        (DATEPART(MONTH, Start_Time) = 11 AND DATEPART(DAY, Start_Time) = 11) OR
        (DATEPART(MONTH, Start_Time) = 11 AND DATEPART(DAY, Start_Time) = 24) OR
        (DATEPART(MONTH, Start_Time) = 12 AND DATEPART(DAY, Start_Time) = 25),
        1, 0) AS EsFeriado,
    DATEPART(WEEK, Start_Time) AS SemanaCalendario,
    DATEPART(WEEK, Start_Time) AS SemanasDelAnioLaborales,
    IIF(DATEPART(DAYOFYEAR, Start_Time) = 366, 1, 0) AS AnioBisiesto,
    CAST(Start_Time AS TIME(0)) AS Hour_Inicio, -- Extrae solo la hora y minutos de Start_Time
    CAST(End_Time AS TIME(0)) AS Hour_Fin      -- Extrae solo la hora y minutos de End_Time
FROM [STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS]
ORDER BY Id_Staging


--------------------------------------------------------------
/*5.B. CONSULTA PARA CONSULTAR DATOS DE DIM_TIME */
--------------------------------------------------------------

SELECT [Tiempo_Skey]
      ,[Tiempo_Codigo]
      ,[Tiempo_FechaInicio]
      ,[Tiempo_FechaFin]
      ,[Tiempo_Anio]
      ,[Tiempo_Trimestre]
      ,[Tiempo_Mes]
      ,[Tiempo_Semana]
      ,[Tiempo_DiaDeAnio]
      ,[Tiempo_DiaDeMes]
      ,[Tiempo_DiaDeSemana]
      ,[Tiempo_EsFinSemana]
      ,[Tiempo_EsFeriado]
      ,[Tiempo_SemanaCalendario]
      ,[Tiempo_SemanasDelAnioLaborales]
      ,[Tiempo_AnioBisiesto]
      ,[Hour_Inicio]
      ,[Hour_Fin]
  FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Time]
 ORDER BY [Tiempo_Codigo]


 --------------------------------------------------------------
/*6.A. CONSULTA PARA EXTRAER DATOS DE S_ACCIDENTS PARA FACT_ACCIDENTS*/
--------------------------------------------------------------

SELECT
	DL.Location_Key,
	DW.Weather_Key,
	DR.Road_Features_Key,
	DD.Description_Accidents_Key,
	DT.Tiempo_Skey,
	SA.Distance_mi,
	SA.Severity,
	(SELECT 
    (DATEDIFF(MINUTE, SA.Start_Time, SA.End_Time) / 60)*60 + 
    (DATEDIFF(MINUTE, SA.Start_Time, SA.End_Time) % 60)) AS Duration_Minutes
FROM [STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS] AS SA

JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Location] as DL
	ON SA.Id_Staging = DL.Location_Key
JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Weather] AS DW
	ON SA.Id_Staging = DW.Weather_Key
JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Road_Features] AS DR
	ON SA.Id_Staging = DR.Road_Features_Key
JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Description_Accidents] AS DD
	ON SA.Id_Staging = DD.Description_Accidents_Key
JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Time] AS DT
	ON SA.Id_Staging = DT.Tiempo_Skey
ORDER BY DL.Location_Key,DW.Weather_Key,DR.Road_Features_Key,DD.Description_Accidents_Key,DT.Tiempo_Skey


--------------------------------------------------------------
/*6.B. CONSULTA PARA CONSULTAR DATOS DE FACT_ACCIDENTS */
--------------------------------------------------------------
SELECT 
	   [Fact_Accidents_Key]
      ,[Location_Key]
      ,[Weather_Key]
      ,[Road_Features_Key]
      ,[Description_Accidents_Key]
      ,[Tiempo_Skey]
      ,[Distance]
      ,[Severity]
      ,[Duration_minutes]
  FROM [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents]
ORDER BY Location_Key,Weather_Key,Road_Features_Key,Description_Accidents_Key,Tiempo_Skey


---------------------------------------------------------------------------------
/*6.C. consulta para LOOKUP Dim_Location de Registros Nuevos y Modificados  */
---------------------------------------------------------------------------------
SELECT 
[Location_Key]
FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Location]
ORDER BY [Location_Key]

----------------------------------------------------------------------------------
/*6.D. consulta para LOOKUP Dim_Weather de Registros Nuevos y Modificados  */
----------------------------------------------------------------------------------

SELECT 
[Weather_Key]
FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Weather]
ORDER BY [Weather_Key]

----------------------------------------------------------------------------------
/*6.D. consulta para LOOKUP Dim_Road_Features de Registros Nuevos y Modificados  */
----------------------------------------------------------------------------------

SELECT 
[Road_Features_Key]
FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Road_Features]
ORDER BY [Road_Features_Key]


----------------------------------------------------------------------------------
/*6.E. consulta para LOOKUP Dim_Descripcion_Accidents de Registros Nuevos y Modificados  */
----------------------------------------------------------------------------------

SELECT 
[Description_Accidents_Key]
FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Description_Accidents]
ORDER BY [Description_Accidents_Key]


----------------------------------------------------------------------------------
/*6.F. consulta para LOOKUP Dim_Time de Registros Nuevos y Modificados  */
----------------------------------------------------------------------------------

SELECT 
[Tiempo_Skey]
FROM [DATAMART_ACCIDENTS].[dbo].[Dim_Time]
ORDER BY [Tiempo_Skey]


----------------------------------------------------------------
/*6.G. CREANDO TABLA MODIFICADOS DE FACT_ACCIDENTS EN BD STAGING_ACCIDENTS */
----------------------------------------------------------------

CREATE TABLE [STAGING_ACCIDENTS].[dbo].[Fact_Accidents_Mod] (
    Fact_Accidents_Key INT PRIMARY KEY IDENTITY(1,1),
    Location_Key INT NOT NULL,
    Weather_Key INT NOT NULL,
    Road_Features_Key INT NOT NULL,
    Description_Accidents_Key INT NOT NULL,
    Tiempo_Skey INT NOT NULL,
	Distance FLOAT,
    Severity INT,
	Duration_minutes INT,
	ETL_DateLoad DATETIME
);


----------------------------------------------------------------
/*6.H. INSERTAR REGISTROS EN LA TABLA Dim_Road_Features_Mod */
----------------------------------------------------------------

INSERT INTO [STAGING_ACCIDENTS].[dbo].[Fact_Accidents_Mod]
([Location_Key],[Weather_Key],[Road_Features_Key],[Description_Accidents_Key],[Tiempo_Skey],[Distance],[Severity],[Duration_minutes],[ETL_DateLoad])
VALUES
(?, ?, ?, ?, ?, ?, ?, ?, GETDATE())


----------------------------------------------------------------
/*6.I. Actualizar la tabla Dim_Road_Feature */
----------------------------------------------------------------
UPDATE [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents]
SET [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].Distance = SA.Distance_mi,
	[DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].Severity = SA.Severity,
	[DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].Duration_minutes = (SELECT 
    (DATEDIFF(MINUTE, SA.Start_Time, SA.End_Time) / 60)*60 + 
    (DATEDIFF(MINUTE, SA.Start_Time, SA.End_Time) % 60))
FROM [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents]
JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Location] AS DL
	ON [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Location_Key] = DL.Location_Key
JOIN 
	[STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS] AS SA
	ON DL.Location_Key = SA.Id_Staging
JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Weather] AS DW
	ON [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Weather_Key] = DW.Weather_Key
JOIN
	[STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS] AS SA1
	ON DW.Weather_Key = SA1.Id_Staging
JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Road_Features] AS DR
	ON [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Road_Features_Key] = DR.Road_Features_Key
JOIN
	[STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS] AS SA2
	ON DR.Road_Features_Key = SA2.Id_Staging
JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Description_Accidents] AS DD
	ON [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Description_Accidents_Key] = DD.Description_Accidents_Key
JOIN
	[STAGING_ACCIDENTS].[dbo].[S_ACCIDENTS] AS SA3
	ON DD.Description_Accidents_Key = SA2.Id_Staging
JOIN
	[DATAMART_ACCIDENTS].[dbo].[Dim_Time] AS DT
	ON [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Tiempo_Skey] = DT.Tiempo_Skey
WHERE
([DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Location_Key] = ? AND
[DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Weather_Key] = ? AND
[DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Road_Features_Key] = ? AND
[DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Road_Features_Key] = ? AND
[DATAMART_ACCIDENTS].[dbo].[Fact_Accidents].[Tiempo_Skey] = ?)


Truncate table [STAGING_ACCIDENTS].[dbo].[Fact_Accidents_Mod]
truncate table [DATAMART_ACCIDENTS].[dbo].[Fact_Accidents]




--------------------------------------------------------------------------------------------------------
/*----LIMPIEZA DE DATOS INICIAL*/
----------------------------------------------------------------------------------------------------
/*BORRO LOS REGISTROS DE TODAS LAS TABLAS, NO USO TRUNCATE POR PROBLEMAS CON LAS CLAVES FORÁNEAS*/
DELETE FROM Fact_Accidents
DELETE FROM Dim_Location
DELETE FROM Dim_Weather
DELETE FROM Dim_Road_Features
DELETE FROM Dim_Description_Accidents
DELETE FROM Dim_Time

/*REINICIO DE LOS ID IDENTIY PARA QUE COMIENCEN DESDE 0*/
DBCC CHECKIDENT ('[dbo].[Fact_Accidents]',RESEED,0)
DBCC CHECKIDENT ('[dbo].[Dim_Location]',RESEED,0)
DBCC CHECKIDENT ('[dbo].[Dim_Road_Features]',RESEED,0)
DBCC CHECKIDENT ('[dbo].[Dim_Time]',RESEED,0)
DBCC CHECKIDENT ('[dbo].[Dim_Weather]',RESEED,0)
DBCC CHECKIDENT ('[dbo].[Dim_Description_Accidents]',RESEED,0)


