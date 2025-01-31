
/*------------------CONSULTAS PARA EXTRACCIÓN Y TRANSFORMACIÓN DE DATOS--------------------------*/

/*-----------CONSULTAS PARA SABER CANTIDAD DE NULOS POR CADA COLUMNA ORDENADOS DE FORMA DESCENDENTE-----------------*/

----- Creando Variables para usar una consulta dinámica
DECLARE @TableName NVARCHAR(MAX) = 'L_ACCIDENTS';
DECLARE @SQL NVARCHAR(MAX);

-- Construcción dinámica de la consulta
SET @SQL = 
    'SELECT ColumnName, SUM(NullCount) AS NullCount ' +
    'FROM (' +
    STUFF((SELECT 
        ' UNION ALL SELECT ''' + c.name + ''' AS ColumnName, COUNT(1) AS NullCount ' +
        'FROM ' + @TableName + ' WHERE [' + c.name + '] IS NULL ' +
        CASE 
            -- Validación adicional si es de tipo DATETIME
            WHEN c.system_type_id IN (61, 58) THEN 
                'OR TRY_CAST([' + c.name + '] AS DATETIME) IS NULL '
            -- Para columnas de texto
            WHEN c.system_type_id IN (167, 175, 231, 239) THEN
                'OR [' + c.name + '] = '''' ' 
            ELSE
                '' -- No se agrega validación extra para otros tipos de datos
        END
    FROM sys.columns c
    INNER JOIN sys.tables t ON c.object_id = t.object_id
    WHERE t.name = @TableName
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 11, '') +
    ') AS Results ' +
    'GROUP BY ColumnName ' +
    'ORDER BY NullCount DESC';

-- Ejecución de la consulta resultante
EXEC sp_executesql @SQL;
-------------------------------------------------------------------------------------------------

----CONSULTA PARA VALIDEZ DE COORDENADAS-----
select * from STAGING_ACCIDENTS.dbo.S_ACCIDENTS
where (Start_Lat < -90 OR Start_Lat >90) OR
	  (Start_Lng < -180 OR Start_Lng >180)

/*----------------------------------------------------------------------------------------------*/
/*CREANDO LA BASE DE DATOS STAGING_ACCIDENTS*/
/*EN ESTA BD SE CARGARAN LOS DATOS LIMPIOS DE LOAD_ACCIDENTS*/

CREATE DATABASE STAGING_ACCIDENTS
/*CREANDO LA TABLA L_ACCIDENTS*/
CREATE TABLE S_ACCIDENTS (
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
    Astronomical_Twilight VARCHAR(10),
	Start_Time_Date date,
	Start_Time_Hour time,
	End_Time_Date date,
	End_Time_hour time,
	Weather_Timestamp_Date date,
	Weather_Timestamp_Hour time
);

