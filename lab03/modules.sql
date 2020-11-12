-- Скалярная функция возвращают одно значение типа данных, заданного в предложении RETURNS. 

-- The following statement creates a function that counts the drivers 
-- whose nationality corresponds to nat:
CREATE OR REPLACE FUNCTION get_nationality_count(nat VARCHAR)
    RETURNS INT
    LANGUAGE plpgsql
AS
$$
DECLARE
   nat_count INTEGER;
BEGIN
   SELECT COUNT(*) 
   INTO nat_count
   FROM driver
   WHERE driver.nationality = nat;
   
   RETURN nat_count;
END;
$$;



-- Подставляемая табличная функция возвращает заранее непредопределённую таблицу.

-- The following statement creates a function that returns 
-- specified number of referred table's rows:
CREATE OR REPLACE FUNCTION get_content_of(_type anyelement, amount INTEGER)
    RETURNS SETOF anyelement
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY 
        EXECUTE format('
            SELECT *
            FROM %s
            LIMIT $1',
        pg_typeof(_type))
        USING amount;
END;
$$;



-- Многооператорная табличная функция - функция, состоящая из нескольких инструкций.

-- The following statement creates a function that returns 
-- a table which consists of driver id, age difference between
-- driver's age and average drivers age, max and min years of 
-- birthdays:
CREATE OR REPLACE FUNCTION get_driver_age() 
	RETURNS TABLE (driver_id INTEGER, age_diff INTEGER, age_min INTEGER, age_max INTEGER)
	LANGUAGE plpgsql
AS 
$$
DECLARE
   age_avg INTEGER;
   age_min INTEGER;
   age_max INTEGER;
BEGIN 
    SELECT AVG(DATE_PART('year', driver.dob)::INTEGER)
    INTO age_avg
    FROM driver; 

    SELECT MIN(DATE_PART('year', driver.dob)::INTEGER)
    INTO age_min
    FROM driver;

    SELECT MAX(DATE_PART('year', driver.dob)::INTEGER)
    INTO age_max
    FROM driver; 

    RETURN query 
		SELECT driver.driver_id, DATE_PART('year', driver.dob)::INTEGER - age_avg AS age_diff, age_min, age_max
		FROM driver;
END;
$$;



-- Рекурсивная функция или функция с рекурсивным ОТВ 

-- The following statement creates a function that returns 
-- a table which consists of overtaken driver id that was 
-- overtook by driver with specified id, specified driver id, 
-- circuit id and circuit turn number: 
CREATE OR REPLACE FUNCTION get_overtakings(od_id INTEGER) 
    RETURNS TABLE (overtaken_driver_id INTEGER, 
                   overtook_driver_id INTEGER, 
                   circuit_id INTEGER, 
                   circuit_turn_number INTEGER)
    LANGUAGE plpgsql
AS
$$
BEGIN 
    RETURN query 
        WITH RECURSIVE RecursiveOvertaking (overtaken_driver_id, 
                                            overtook_driver_id, 
                                            circuit_id, 
                                            circuit_turn_numebr)
        AS
        (
            SELECT ot.overtaken_driver_id, ot.overtook_driver_id, ot.circuit_id, ot.circuit_turn_numebr
            FROM overtaking ot
            WHERE ot.overtook_driver_id = od_id
            UNION ALL
            SELECT ot.overtaken_driver_id, ot.overtook_driver_id, ot.circuit_id, ot.circuit_turn_numebr
            FROM overtaking ot
            JOIN RecursiveOvertaking rec ON ot.overtook_driver_id = rec.overtaken_driver_id
        )
        SELECT ro.overtaken_driver_id::INTEGER, 
               ro.overtook_driver_id::INTEGER, 
               ro.circuit_id::INTEGER, 
               ro.circuit_turn_numebr::INTEGER
        FROM RecursiveOvertaking ro;
END;
$$;



-- Хранимая процедура без параметров или с параметрами

-- The following statement creates a stored procedure 
-- that deletes drivers with surname mathes sn: 
CREATE OR REPLACE PROCEDURE delete_driver_by_sn(sn VARCHAR)  
    LANGUAGE plpgsql
AS 
$$
BEGIN 
    DELETE FROM driver d 
    WHERE d.surname = sn;
END;
$$;
-- CALL delete_driver_by_sn('Russian');



-- Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ

-- The following statement creates a stored procedure 
-- that creates a table which consists of overtaken driver id that was 
-- overtook by driver with specified id, specified driver id, 
-- circuit id and circuit turn number: 
CREATE OR REPLACE PROCEDURE get_overtakings_proc(od_id INTEGER)  
    LANGUAGE plpgsql
AS 
$$
BEGIN 
    CREATE TABLE IF NOT EXISTS overtaken_buffer(
        overtaken_driver_id INTEGER, 
        overtook_driver_id INTEGER, 
        circuit_id INTEGER, 
        circuit_turn_numebr INTEGER
    );
    WITH RECURSIVE RecursiveOvertaking(overtaken_driver_id, 
                                       overtook_driver_id, 
                                       circuit_id, 
                                       circuit_turn_numebr)
        AS
        (
            SELECT ot.overtaken_driver_id, ot.overtook_driver_id, ot.circuit_id, ot.circuit_turn_numebr
            FROM overtaking ot
            WHERE ot.overtook_driver_id = od_id
            UNION ALL
            SELECT ot.overtaken_driver_id, ot.overtook_driver_id, ot.circuit_id, ot.circuit_turn_numebr
            FROM overtaking ot
            JOIN RecursiveOvertaking rec ON ot.overtook_driver_id = rec.overtaken_driver_id
        )
    INSERT INTO overtaken_buffer
    SELECT * FROM RecursiveOvertaking;
END;
$$;
-- CALL get_overtakings_proc(3);



-- Хранимая процедура с курсором; курсоры являются расширением результирующих наборов

-- The following statement creates a stored procedure 
-- that creates a table which consists of driver id and 
-- surname of first five drivers from driver table:
CREATE OR REPLACE PROCEDURE curs_driver()  
    LANGUAGE plpgsql
AS 
$$
DECLARE 
    curs CURSOR FOR SELECT driver_id, surname FROM driver;
    d_id INTEGER;
    sn VARCHAR;
BEGIN 
    CREATE TABLE IF NOT EXISTS driver_buffer(
        driver_id INTEGER, 
        surname VARCHAR
    );
    OPEN curs;
    FOR counter IN 1..5 LOOP
        FETCH curs INTO d_id, sn;
        INSERT INTO driver_buffer
        VALUES (d_id, sn);
    END LOOP;
END;
$$;



-- Хранимая процедура доступа к методанным 

-- The following statement creates a stored procedure 
-- that creates a table which consists of matadata 
-- about all functions and procedures store in database:
CREATE OR REPLACE PROCEDURE get_udf()
    LANGUAGE plpgsql
AS
$$
BEGIN
    CREATE TABLE IF NOT EXISTS udf_list(
        schm VARCHAR,
        nm VARCHAR,
        lang VARCHAR,
        args VARCHAR,
        return_type VARCHAR
    );

    DELETE FROM udf_list;

    INSERT INTO udf_list
        SELECT  ns.nspname "schema",
                p.proname "name",
                lg.lanname lang,
                pg_get_function_arguments(p.oid) as args,
                t.typname as return_type
        FROM pg_proc p
            LEFT JOIN pg_namespace ns on p.pronamespace = ns.oid
            LEFT JOIN pg_language lg on p.prolang = lg.oid
            LEFT JOIN pg_type t on t.oid = p.prorettype 
        WHERE ns.nspname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY "schema", "name";
END;
$$;



-- Триггер AFTER; Триггер DML — это действие, которое выполняется 
-- при наступлении события языка DML на сервере базы данных. 
-- К событиям DML относятся инструкции UPDATE, INSERT и DELETE, 
-- выполняемые в таблице или представлении.

-- The following statement creates a trigger that
-- saves surname changes from table driver to 
-- table driver_audits:
CREATE TABLE driver_audits (
   driver_id INTEGER,
   surname_old VARCHAR,
   surname_new VARCHAR,
   changed_on TIMESTAMP(6) NOT NULL
);

CREATE OR REPLACE FUNCTION log_surname_changes()
    RETURNS TRIGGER 
    LANGUAGE PLPGSQL
AS
$$
BEGIN
	IF NEW.surname <> OLD.surname THEN
		INSERT INTO driver_audits(driver_id, surname_old, surname_new, changed_on)
		VALUES(OLD.driver_id, OLD.surname, NEW.surname, now());
	END IF;
	RETURN NEW;
END;
$$;

CREATEd TRIGGER surname_changes
    AFTER UPDATE
    ON driver
    FOR EACH ROW
    EXECUTE PROCEDURE log_surname_changes();

UPDATE driver
SET surname = 'Bartley'
WHERE surname = 'Hartley';



-- Триггер INSTEAD OF. 

-- The following statement creates a trigger that
-- saves surname changes from table driver to 
-- table driver_audits:
CREATE TABLE driver_audits (
   driver_id INTEGER,
   surname_old VARCHAR,
   surname_new VARCHAR,
   changed_on TIMESTAMP(6) NOT NULL
);

CREATE OR REPLACE FUNCTION log_surname_insert()
    RETURNS TRIGGER 
    LANGUAGE PLPGSQL
AS
$$
BEGIN
	INSERT INTO driver_audits(driver_id, surname_old, surname_new, changed_on)
	VALUES(NEW.driver_id, null, NEW.surname, now());
	RETURN OLD;
END;
$$;

CREATE TRIGGER surname_insert
    BEFORE INSERT
    ON driver
    FOR EACH ROW
    EXECUTE PROCEDURE log_surname_insert();

INSERT INTO driver (driver_id, driver_ref, driver_number, code, forename, surname, dob, nationality) 
VALUES (844, 'sarkisov', 4, 'SAR', 'Artem', 'Sarkisov', TO_DATE('20000612', 'YYYYMMDD'), 'Russian');





-- Защита:
-- 1. Рекурсивная функция/процедура
-- 2. Написать процедуру, которая удалит все таблицы в оперделенном временном интервале


-- 1.
-- The following statement creates a stored procedure 
-- that creates a table which consists of overtaken driver id that was 
-- overtook by driver with specified id, specified driver id, 
-- circuit id and circuit turn number: 
CREATE OR REPLACE PROCEDURE get_overtakings_proc(od_id INTEGER)  
    LANGUAGE plpgsql
AS 
$$
DECLARE 
    overtaken_driver_id INTEGER; 
    overtook_driver_id INTEGER;
    circuit_id INTEGER;
    circuit_turn_numebr INTEGER;
BEGIN  
    CREATE TABLE IF NOT EXISTS overtaken_buffer(
        overtaken_driver_id INTEGER, 
        overtook_driver_id INTEGER, 
        circuit_id INTEGER, 
        circuit_turn_numebr INTEGER
    );
    SELECT ot.overtaken_driver_id, ot.overtook_driver_id, ot.circuit_id, ot.circuit_turn_numebr 
    INTO overtaken_driver_id, overtook_driver_id, circuit_id, circuit_turn_numebr 
    FROM overtaking ot
    WHERE ot.overtaken_driver_id = od_id;

    IF FOUND THEN 
        INSERT INTO overtaken_buffer
        VALUES (overtaken_driver_id, overtook_driver_id, circuit_id, circuit_turn_numebr);
        CALL get_overtakings_proc(od_id + 1);
    END IF;
END;
$$;
-- CALL get_overtakings_proc(3);



-- 2.
CREATE TABLE update_log(
    table_name text PRIMARY KEY, 
    updated timestamp NOT NULL DEFAULT now());


CREATE FUNCTION stamp_update_log() 
    RETURNS TRIGGER 
    LANGUAGE 'plpgsql' 
AS 
$$
BEGIN
    DELETE 
    FROM update_log 
    WHERE table_name = TG_TABLE_NAME;

    INSERT INTO update_log(table_name) 
    VALUES(TG_TABLE_NAME);
    RETURN NEW;
END
$$;

CREATE TRIGGER sometable_stamp_update_log
    AFTER INSERT OR UPDATE 
    ON driver
    FOR EACH STATEMENT
    EXECUTE PROCEDURE stamp_update_log();


CREATE OR REPLACE PROCEDURE drop_by_interval(edge_date_start_in TEXT, edge_date_end_in TEXT)  
    LANGUAGE plpgsql
AS 
$$
DECLARE 
    tmp_table_name text;
    edge_date_start TIMESTAMP;
    edge_date_end TIMESTAMP;
    tmp_date TIMESTAMP;
    cursor_table_name CURSOR FOR
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = 'public';
BEGIN 
    edge_date_start = TO_TIMESTAMP(edge_date_start_in, 'YYYY-MM-DD HH:MI:SS');
    edge_date_end = TO_TIMESTAMP(edge_date_end_in, 'YYYY-MM-DD HH:MI:SS');
    IF edge_date_start >= edge_date_end THEN 
        RAISE NOTICE 'Incorrect edges!';
        RETURN;
    END IF;

    
    OPEN cursor_table_name;
    LOOP
        FETCH cursor_table_name INTO tmp_table_name;
        EXIT WHEN NOT FOUND;

        SELECT MAX(ul.updated) 
        INTO tmp_date
        FROM update_log ul 
        WHERE ul.table_name = tmp_table_name;

        IF tmp_date > edge_date_start and tmp_date < edge_date_end THEN
            EXECUTE 'DROP TABLE IF EXISTS ' || table_name || ';'; 
            RAISE NOTICE 'Table "%" wasdeleted!', tmp_table_name;
        END IF;
    END LOOP;

    CLOSE cursor_table_name;
END;
$$;


SELECT p.tablename
FROM pg_tables p
WHERE p.schemaname = 'public';

-- edge_date_input = '2017-03-31 9:30:20'


