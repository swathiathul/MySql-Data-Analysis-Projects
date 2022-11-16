USE case1;
SELECT * FROM `gas station fills`;
SELECT * FROM `vehicles`;

/*To find duplicates in tables*/

SELECT `Fill ID`,
COUNT(*) AS COUNT
FROM `gas station fills`
GROUP BY `Fill ID`
HAVING COUNT(*) = 1;

SELECT `Vehicle ID`,
COUNT(*) AS COUNT
FROM `vehicles`
GROUP BY `Vehicle ID`
HAVING COUNT(*) = 1;

/*'NOT NULL' constraint has to be applied to any column defined as key*/

ALTER TABLE `gas station fills`
MODIFY `Fill ID` NVARCHAR(50) NOT NULL;

ALTER TABLE `vehicles`
MODIFY `Vehicle ID` NVARCHAR(50) NOT NULL;

ALTER TABLE `gas station fills`
MODIFY `vehicle ID` NVARCHAR(50) NOT NULL;

/*Define the primary and foreign keys*/

ALTER TABLE `gas station fills`
ADD PRIMARY KEY (`Fill ID`);

ALTER TABLE `vehicles`
ADD PRIMARY KEY (`Vehicle ID`);

ALTER TABLE `gas station fills`
ADD FOREIGN KEY (`Vehicle ID`)
REFERENCES VEHICLES (`Vehicle ID`);

/*Join the two tables together by using the foreign key ‘Vehicle I*/

CREATE TEMPORARY TABLE Gas_station
 SELECT G.`Fill ID`,G.`Vehicle ID`as `vehicleID`,
        G.`Fuel Type`,G.`Cost of Fill (£)`,
        G.`Customer Membership`,
        V.`vehicle ID`as `vehicle_id`,V.`Vehicle Name`,V.`Vehicle Type`
       ,V.`Vehicle Cost (£)`
FROM `gas station fills`AS G
LEFT JOIN `vehicles` AS V
ON G.`vehicle ID`= V.`vehicle ID`;

SELECT * FROM Gas_station;

/*The gas fill transactions for the cost and count of the transactions reported based on the different vehicles*/

SELECT `vehicle_id`,`Vehicle Name`
,SUM( CAST(`Cost of Fill (£)` AS unsigned) ) AS Total_Cost
,COUNT(*) AS Total_Count
FROM Gas_station
GROUP BY `vehicle_id`,`Vehicle Name`
ORDER BY SUM( CAST(`Cost of Fill (£)` AS unsigned) ) DESC;

/*The transactions for the gas fills have been split out between customers who have a membership and customers that do not*/

SELECT `Customer Membership`,
COUNT(*) AS membership_count
FROM  Gas_station
GROUP BY `Customer Membership`;

/* The type of fuel and the gas fill transactions associated to it*/

SELECT `Fuel Type`,
COUNT(*) AS Fill_count,
SUM( CAST(`Cost of Fill (£)` AS UNSIGNED) ) AS Total_Fill_Cost,
AVG( CAST(`Cost of Fill (£)` AS UNSIGNED) ) AS Average_Fill_Cost
FROM Gas_station
GROUP BY `Fuel Type`;

/*The ratio between the cost of the vehicles and the total amount for the fill transactions for that vehicle type*/

WITH Vehicle_and_Fill_Ratio
AS
(SELECT `vehicle_id`,`Vehicle Name`,`Vehicle Type`
,SUM( CAST(`Vehicle Cost (£)` AS UNSIGNED) ) AS Total_Cost_of_Vehicle
,SUM( CAST(`Cost of Fill (£)` AS UNSIGNED) ) AS Total_Cost_of_Fill
FROM Gas_station
GROUP BY `vehicle_id`,`Vehicle Name`,`Vehicle Type`)
SELECT`vehicle_id`,`Vehicle Name`,`Vehicle Type`,Total_Cost_of_Vehicle,Total_Cost_of_Fill,
Total_Cost_of_Vehicle/Total_Cost_of_Fill AS Fill_Ratio
FROM Vehicle_and_Fill_Ratio
order by `vehicle_id` ASC;



