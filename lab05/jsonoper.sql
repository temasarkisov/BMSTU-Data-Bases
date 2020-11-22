-- 1. Extracts data from "driver" table into JSON file "driver.json"
COPY (
	SELECT row_to_json(driver_data) 
    FROM (
        SELECT *
        FROM driver
    ) driver_data 
) TO '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab05/driver.json';


-- 2. Creates table "driver_based_json" based on JSON file "driver.json" data
CREATE OR REPLACE PROCEDURE table_based_on_json()  
    LANGUAGE PLPGSQL
AS 
$$
BEGIN 
    CREATE TABLE IF NOT EXISTS driver_based_json (
        driver_id INTEGER, 
        driver_ref VARCHAR, 
        driver_number INTEGER,
        code VARCHAR(3),
        forename VARCHAR,
        surname VARCHAR,
        dob DATE,
        nationality VARCHAR, 
        PRIMARY KEY (driver_id)
    );

    DELETE FROM driver_based_json;

    CREATE TABLE IF NOT EXISTS driver_json_tmp ( 
        driver_info jsonb 
    );

    DELETE FROM driver_json_tmp;

    COPY driver_json_tmp 
    FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab05/driver.json';

    INSERT INTO driver_based_json(driver_id, driver_ref, driver_number, 
                code, forename, surname, dob, nationality)
        SELECT (driver_info -> 'driver_id')::INTEGER AS driver_id,
            (driver_info ->> 'driver_ref') AS driver_ref,
            (driver_info ->> 'driver_number')::INTEGER AS driver_number,
            (driver_info ->> 'code') AS code,
            (driver_info ->> 'forename') AS forename,
            (driver_info ->> 'surname') AS surname,
            (driver_info ->> 'dob')::DATE AS dob,
            (driver_info ->> 'nationality') AS nationality
        FROM driver_json_tmp;

    DROP TABLE driver_json_tmp;
END;
$$;

CALL table_based_on_json();

--CREATE TYPE driver_info_t 
--AS (driver_id INTEGER, 
--    driver_ref VARCHAR, 
--    driver_number INTEGER,
--    code VARCHAR(3),
--    forename VARCHAR,
--    surname VARCHAR,
--    dob DATE,
--    nationality VARCHAR
--);

--SELECT jsonb_each(driver_info)
--FROM driver_json_tmp;

-- INSERT INTO driver_based_json
--    SELECT jsonb_populate_record(NULL::driver_info_t, driver_info)
--    FROM driver_json_tmp;


-- 3. Creates table "driver_passport" with JSON data inside.
-- Fills the table with plausible data.
CREATE TABLE driver_passport (
    passport_number INT NOT NULL, 
    driver_name JSON NOT NULL
);

INSERT INTO driver_passport 
VALUES (19365687, '{"forename": "Lewis", "surname": "Hamilton"}'),
       (75892093, '{"forename": "Artem", "surname": "Sarkisov"}'),
       (94738401, '{"forename": "Max", "surname": "Verstappen"}');


-- 4.1. Extracts specified JSON snippet from artist.json. 
CREATE OR REPLACE FUNCTION extract_json_snippet()  
    RETURNS TABLE(album JSON, type TEXT)
    LANGUAGE PLPGSQL
AS 
$$
BEGIN 
    CREATE TABLE IF NOT EXISTS artist ( 
        artist_info json 
    );
    DELETE FROM artist;
    COPY artist 
    FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab05/artist.json';

    RETURN query 
        SELECT artist_info #> '{album}' as "album", json_typeof(artist_info #> '{album}') AS "type"
        FROM artist;

    DROP TABLE artist;
END;
$$;

-- 4.2. Extracts exact value from artist.json by specified JSON snippet. 
CREATE OR REPLACE FUNCTION extract_exact_value()  
    RETURNS TABLE(album TEXT, type TEXT)
    LANGUAGE PLPGSQL
AS 
$$
BEGIN 
    CREATE TABLE IF NOT EXISTS artist ( 
        artist_info json 
    );
    DELETE FROM artist;
    COPY artist 
    FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab05/artist.json';

    RETURN query 
        SELECT artist_info->>'name' AS "artist's name", json_typeof(artist_info->'name') AS "type"
        FROM artist;

    DROP TABLE artist;
END;
$$;


-- 4.3
-- Checks by specified path if snippet or value exists. 
CREATE OR REPLACE PROCEDURE is_snippet_exist()  
    LANGUAGE PLPGSQL
AS 
$$
DECLARE 
    object_tmp TEXT;
BEGIN 
    object_tmp = '';
    CREATE TABLE IF NOT EXISTS artist ( 
        artist_info json 
    );
    DELETE FROM artist;
    COPY artist 
    FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab05/artist.json';

    SELECT artist_info #>> '{album}'
    INTO object_tmp
    FROM artist;

    IF object_tmp IS NULL THEN raise notice 'Nothing found:(';
    ELSE raise notice 'Search result: %', object_tmp;
    END IF;

    DROP TABLE artist;
END
$$;



