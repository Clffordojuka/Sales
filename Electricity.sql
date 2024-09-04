show tables;
use solar_generation;

select * from solarelectricity

#Average Solar Electricity Generation and Electricity Usage per Hour
SELECT
    HOUR(DateHourStart) AS Hour,
    AVG(SolarElectricityGeneration) AS AvgSolarGeneration,
    AVG(ElectricityUsage) AS AvgElectricityUsage
FROM 
    solarelectricity
GROUP BY 
    HOUR(DateHourStart)
ORDER BY 
    Hour;

#Calculate Electricity Needed to be Bought
SELECT 
    *,
    GREATEST(ElectricityUsage - SolarElectricityGeneration, 0) AS ElectricityBought
FROM 
    solarelectricity;

#Calculate Excess Solar Generation
SELECT 
    *,
    GREATEST(SolarElectricityGeneration - ElectricityUsage, 0) AS ExcessSolarGeneration
FROM 
    (
    SELECT 
        *,
        GREATEST(ElectricityUsage - SolarElectricityGeneration, 0) AS ElectricityBought
    FROM 
        solarelectricity
    ) AS subquery;

#Analyze Excess Solar Generation
SELECT 
    DateHourStart,
    ExcessSolarGeneration
FROM 
    (
    SELECT 
        *,
        GREATEST(SolarElectricityGeneration - ElectricityUsage, 0) AS ExcessSolarGeneration
    FROM 
        solarelectricity
    ) AS subquery
WHERE 
    ExcessSolarGeneration > 0
ORDER BY 
    DateHourStart;
    
#Model the Cumulative Battery Charge Level
WITH BatteryCharge AS (
    SELECT 
        DateHourStart,
        ExcessSolarGeneration,
        @battery_charge := LEAST(@battery_charge + ExcessSolarGeneration, 12.5) AS BatteryChargeLevel
    FROM 
        (SELECT 
            DateHourStart,
            GREATEST(SolarElectricityGeneration - ElectricityUsage, 0) AS ExcessSolarGeneration
        FROM 
            solarelectricity) AS subquery,
        (SELECT @battery_charge := 0) AS init
    ORDER BY 
        DateHourStart
)
SELECT 
    *
FROM 
    BatteryCharge;

#Calculate Electricity Bought with Battery
SELECT 
    *,
    GREATEST(ElectricityBought - BatteryChargeLevel, 0) AS ElectricityBoughtWithBattery
FROM 
    (
    SELECT 
        *,
        GREATEST(ElectricityUsage - SolarElectricityGeneration, 0) AS ElectricityBought,
        LEAST(@battery_charge := LEAST(@battery_charge + GREATEST(SolarElectricityGeneration - ElectricityUsage, 0), 12.5), 12.5) AS BatteryChargeLevel
    FROM 
        solarelectricity,
        (SELECT @battery_charge := 0) AS init
    ORDER BY 
        DateHourStart
    ) AS subquery;

#Calculate Potential Savings
SELECT 
    DateHourStart,
    ElectricityBought * 0.17 AS CostWithoutBattery,
    ElectricityBoughtWithBattery * 0.17 AS CostWithBattery,
    (ElectricityBought - ElectricityBoughtWithBattery) * 0.17 AS Savings
FROM 
    (
    SELECT 
        *,
        GREATEST(ElectricityBought - BatteryChargeLevel, 0) AS ElectricityBoughtWithBattery
    FROM 
        (
        SELECT 
            *,
            GREATEST(ElectricityUsage - SolarElectricityGeneration, 0) AS ElectricityBought,
            LEAST(@battery_charge := LEAST(@battery_charge + GREATEST(SolarElectricityGeneration - ElectricityUsage, 0), 12.5), 12.5) AS BatteryChargeLevel
        FROM 
            solarelectricity,
            (SELECT @battery_charge := 0) AS init
        ORDER BY 
            DateHourStart
        ) AS subquery
    ) AS final_query;

#Aggregate and Visualize Data on a Monthly Basis
SELECT 
    DATE_FORMAT(DateHourStart, '%Y-%m') AS Month,
    SUM(SolarElectricityGeneration) AS TotalSolarGeneration,
    SUM(ElectricityUsage) AS TotalElectricityUsage,
    SUM(ElectricityBought) AS TotalElectricityBoughtWithoutBattery,
    SUM(ElectricityBoughtWithBattery) AS TotalElectricityBoughtWithBattery
FROM 
    (
    SELECT 
        *,
        GREATEST(ElectricityBought - BatteryChargeLevel, 0) AS ElectricityBoughtWithBattery
    FROM 
        (
        SELECT 
            *,
            GREATEST(ElectricityUsage - SolarElectricityGeneration, 0) AS ElectricityBought,
            LEAST(@battery_charge := LEAST(@battery_charge + GREATEST(SolarElectricityGeneration - ElectricityUsage, 0), 12.5), 12.5) AS BatteryChargeLevel
        FROM 
            solarelectricity,
            (SELECT @battery_charge := 0) AS init
        ORDER BY 
            DateHourStart
        ) AS subquery
    ) AS final_query
GROUP BY 
    Month;
    
