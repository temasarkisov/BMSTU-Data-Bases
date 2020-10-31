--psql -U postgres -h 127.0.0.1 -d formula_1 -f requests.sql

--1 Инструкция SELECT, использующая предикат сравнения.
SELECT DISTINCT D.forename, D.surname, R.grid, R.position_order
FROM result AS R JOIN driver AS D ON R.driver_id = D.driver_id 
WHERE D.forename = 'Lewis' AND D.surname = 'Hamilton' 

--2 Инструкция SELECT, использующая предикат BETWEEN.
SELECT DISTINCT driver_id, code, forename, surname, dob 
FROM driver
WHERE dob BETWEEN '1997-01-01' AND '2000-01-01'

--3 Инструкция SELECT, использующая предикат LIKE.
SELECT DISTINCT forename, surname FROM driver 
WHERE surname LIKE '%ilton'

--4 Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
SELECT RE.race_id, RE.driver_id, D.surname, RE.constructor_id, RE.fastest_lap, RE.fastest_lap_speed
FROM result AS RE JOIN driver AS D ON RE.driver_id = D.driver_id 
WHERE race_id IN (
    SELECT race_id 
    FROM race
    WHERE circuit_id = 1
) AND RE.position = 1 AND RE.fastest_lap_speed IS NOT NULL

--5 Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
SELECT C.circuit_id, C.name 
FROM circuit AS C
WHERE EXISTS (
    SELECT R.time
    FROM race AS R LEFT OUTER JOIN circuit AS C
    ON R.circuit_id = C.circuit_id 
    WHERE R.time IS NOT NULL
)

--6 Инструкция SELECT, использующая предикат сравнения с квантором.
SELECT D.driver_id, D.surname, L.time
FROM driver AS D JOIN lap_time AS L ON D.driver_id = L.driver_id
WHERE L.time < ALL (
    SELECT L.time 
    FROM lap_time AS L
    WHERE L.lap = 1 
) AND L.lap = 2

--7 Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
SELECT AVG(PitStopTime) AS "Average Pit Stop Time", SUM(PitStopTime) / COUNT(driver_id) AS "Average Pit Stop Time"
FROM (
    SELECT driver_id, SUM(milliseconds)/COUNT(driver_id) AS PitStopTime
    FROM pit_stop 
    GROUP BY driver_id
) AS PitStopTimeQ

SELECT DISTINCT D.surname, P.driver_id, SUM(P.milliseconds)/COUNT(P.driver_id) AS PitStopTime
FROM pit_stop AS P JOIN driver AS D ON P.driver_id = D.driver_id
GROUP BY P.driver_id

SELECT race_id, SUM(milliseconds)/COUNT(race_id) AS PitStopTime
FROM pit_stop 
GROUP BY race_id

--8 Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
SELECT race.race_id, race.name, (
    SELECT AVG(result.laps)
    FROM result 
    WHERE race.race_id = result.race_id
    ) AS Avg_Laps_Num, (
    SELECT MIN(result.laps)
    FROM result
    WHERE race.race_id = result.race_id
    ) AS Min_Laps_Num 
FROM race
WHERE race.circuit_id = 1

--9 Инструкция SELECT, использующая простое выражение CASE.
SELECT race.race_id, race.name, 
CASE race.date
    WHEN CURRENT_DATE THEN 'This Year'
    WHEN CURRENT_DATE - 1 THEN 'Last year'
    ELSE 'Many years ago' --CAST ((DATE_PART('year', race.date) - DATE_PART('year', CURRENT_DATE)) AS varchar(10) + ' years ago'
    END AS "When"
FROM race

--10 Инструкция SELECT, использующая поисковое выражение CASE.
SELECT driver_id, forename, surname,
CASE
    WHEN dob > '2000-01-01' THEN '< 20'
    WHEN dob > '1990-01-01' THEN '< 30' 
    WHEN dob > '1980-01-01' THEN '< 40'
    WHEN dob > '1970-01-01' THEN '< 50' 
    ELSE '> 50'
    END AS Age 
FROM driver

--11 Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
SELECT result.driver_id, driver.forename, driver.surname, AVG(result.milliseconds) AS avg_time
INTO average_time
FROM result JOIN driver ON result.driver_id = driver.driver_id
WHERE result.milliseconds IS NOT NULL
GROUP BY result.driver_id, driver.forename, driver.surname

--12 Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.
SELECT result.result_id AS "ResultIdMax", TS.timeSum as MaxPitStopTime
FROM result JOIN (
    SELECT pit_stop.race_id, SUM(pit_stop.milliseconds) AS timeSum 
    FROM pit_stop
    GROUP BY pit_stop.race_id
    ORDER BY timeSum DESC
    LIMIT 1
    ) AS TS ON result.race_id = TS.race_id
UNION
SELECT result.result_id AS "ResultIdAve", TA.timeAve as AvePitStopTime 
FROM result JOIN (
    SELECT pit_stop.race_id, SUM(pit_stop.milliseconds) / COUNT(pit_stop.race_id) AS timeAve
    FROM pit_stop
    GROUP BY pit_stop.race_id
    ORDER BY timeAve DESC
    LIMIT 1
    ) AS TA ON result.race_id = TA.race_id

--13 Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
SELECT driver.surname as "Min Time"
FROM driver
WHERE driver.driver_id = (
    SELECT lap_time.driver_id
    FROM lap_time
    GROUP BY driver_id 
    HAVING SUM(lap_time.time) = (
        SELECT MIN(SumTime) 
        FROM (
            SELECT SUM(lap_time.time) AS SumTime
            FROM lap_time
            GROUP BY driver_ID
        ) AS DriverTime
    )
)
UNION
SELECT driver.surname as "Min Avg Time"
FROM driver
WHERE driver.driver_id = (
    SELECT lap_time.driver_id
    FROM lap_time
    GROUP BY driver_id 
    HAVING SUM(lap_time.time)/COUNT(driver_id) = (
        SELECT MIN(AvgTime) 
        FROM (
            SELECT SUM(lap_time.time)/COUNT(driver_id) AS AvgTime
            FROM lap_time
            GROUP BY driver_ID
        ) AS DriverTime
    )
)

--14 Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
SELECT D.driver_id, D.surname, R.milliseconds AS "Time", AVG(R.milliseconds) AS "Average Time", MIN(R.milliseconds) AS "Min Time"
FROM driver AS D LEFT OUTER JOIN result AS R ON D.driver_id = R.driver_id
WHERE R.position = 1
GROUP BY D.driver_id, D.surname, R.milliseconds

--15 Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
SELECT result.race_id, race.name, AVG(result.fastest_lap_speed) AS "Average Fastest Lap Speed"
FROM result JOIN race ON result.race_id = race.race_id
GROUP BY result.race_id, race.name
HAVING AVG(result.fastest_lap_speed) > (
    SELECT AVG(result.fastest_lap_speed) 
    FROM result
)

--16 Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
INSERT INTO driver (driver_id, driver_ref, driver_number, code, forename, surname, dob, nationality) 
VALUES (844, 'sarkisov', 4, 'SAR', 'Artem', 'Sarkisov', TO_DATE('20000612', 'YYYYMMDD'), 'Russian')

--17 Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
INSERT INTO race (circuit_id, race_id, round, name, date, time) 
SELECT (        
    SELECT MAX(circuit_id) 
    FROM circuit
    WHERE country = 'France'
), 1010, 1, 'France Inserted Grand Prix', TO_DATE('20000612', 'YYYYMMDD'), TO_TIMESTAMP('06:00:00', 'HH:MI:SS')

--18 Простая инструкция UPDATE.
UPDATE driver
SET nationality = 'Israelis' 
WHERE surname = 'Sarkisov'

--19 Инструкция UPDATE со скалярным подзапросом в предложении SET.
UPDATE driver 
SET dob = (
    SELECT MAX(dob) 
    FROM driver
    WHERE nationality = 'German'
)
WHERE surname = 'Sarkisov'

--20 Простая инструкция DELETE.
DELETE FROM result
WHERE driver_id IS NULL

--21 Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
DELETE FROM driver 
WHERE driver_id IN
(
    SELECT driver.driver_id
    FROM driver LEFT OUTER JOIN result ON driver.driver_id = result.driver_id
    WHERE result.status_id IS NULL
)

--22 Инструкция SELECT, использующая простое обобщенное табличное выражение
WITH CTE (driver_id, fastest_lap) AS
(
    SELECT driver_id, fastest_lap AS RaceTime
    FROM result
    WHERE fastest_lap IS NOT NULL 
    GROUP BY driver_id, fastest_lap
)
SELECT AVG(fastest_lap) AS "Average Race Time" 
FROM CTE

--23 Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
-- Every driver which was overtaken by driver with id equals 3
CREATE TABLE overtaking (
    overtaken_driver_id smallint NOT NULL,
    overtook_driver_id smallint NOT NULL,
    circuit_id smallint NOT NULL,
    circuit_turn_numebr smallint NOT NULL,

    FOREIGN KEY (overtaken_driver_id) REFERENCES driver (driver_id),
    FOREIGN KEY (overtook_driver_id) REFERENCES driver (driver_id),
    FOREIGN KEY (circuit_id) REFERENCES circuit (circuit_id)
);

INSERT INTO overtaking (overtaken_driver_id, overtook_driver_id, circuit_id, circuit_turn_numebr) 
VALUES (1, 2, 3, 4),
(2, 1, 5, 12), 
(3, 1, 1, 7),
(4, 3, 9, 1),
(5, 3, 3, 7),
(6, 3, 11, 5),
(7, 3, 9, 5),
(8, 3, 2, 9),
(9, 2, 4, 11),
(10, 2, 2, 5),
(11, 2, 3, 13),
(12, 2, 12, 9)

WITH RECURSIVE RecursiveOvertaking (overtaken_driver_id, overtook_driver_id, circuit_id, circuit_turn_numebr)
AS
(
    -- Определение закрепленного элемента
    SELECT overtaken_driver_id, overtook_driver_id, circuit_id, circuit_turn_numebr
    FROM overtaking ot
    WHERE ot.overtook_driver_id = 3
    UNION ALL
    
    SELECT ot.overtaken_driver_id, ot.overtook_driver_id, ot.circuit_id, ot.circuit_turn_numebr
    FROM overtaking ot
    JOIN RecursiveOvertaking rec ON ot.overtook_driver_id = rec.overtaken_driver_id
)
SELECT overtaken_driver_id, overtook_driver_id, circuit_id, circuit_turn_numebr
FROM RecursiveOvertaking

--24 Оконные функции. Использование конструкций MIN/MAX/AVG OVER().
SELECT DISTINCT PS.driver_id, D.surname, PS.race_id,
AVG(PS.lap) OVER(PARTITION BY PS.driver_id, PS.race_id) AS AvgLap,
MIN(PS.lap) OVER(PARTITION BY PS.driver_id, PS.race_id) AS MinLap,
MAX(PS.lap) OVER(PARTITION BY PS.driver_id, PS.race_id) AS MaxLap,
AVG(PS.milliseconds) OVER(PARTITION BY PS.driver_id, PS.race_id) AS AvgTime,
MIN(PS.milliseconds) OVER(PARTITION BY PS.driver_id, PS.race_id) AS MinTime,
MAX(PS.milliseconds) OVER(PARTITION BY PS.driver_id, PS.race_id) AS MaxTime
FROM pit_stop AS PS LEFT OUTER JOIN driver AS D ON PS.driver_id = D.driver_id

--25 Оконные фнкции для устранения дублей.
DELETE FROM duplicate_driver 
WHERE driver_id IN
(
    SELECT driver_id
    FROM (
        SELECT driver_id, ROW_NUMBER() OVER(PARTITION BY driver_id) n
        FROM duplicate_driver
    ) AS VV WHERE n > 1
)