-- 1. Определяемую пользователем скалярную функцию CLR,
CREATE OR REPLACE FUNCTION get_surname_by_id(id INTEGER) 
    RETURNS TEXT
    LANGUAGE plpython3u
AS
$$
    surname = plpy.execute(f"\
        SELECT d.surname\n\
        FROM driver d\n\
        WHERE d.driver_id = '{id}'\n\
        LIMIT 1;"
    )
    
    return surname[0]["surname"]
$$;
-- SELECT get_surname_by_id(395);


-- 2. Пользовательская агрегатная функция CLR
CREATE OR REPLACE FUNCTION _agg_oldest(current DATE, new DATE) 
    RETURNS DATE
    LANGUAGE plpython3u
AS
$$
    import datetime as dt

    current_oldest = dt.datetime(int(current.split('-')[0]), int(current.split('-')[1]), int(current.split('-')[2]))
    try:
        challenger = dt.datetime(int(new.split('-')[0]), int(new.split('-')[1]), int(new.split('-')[2]))
    except:
        challenger = dt.datetime.today()

    maxi = current
    if (current_oldest - challenger).days > 0:
        maxi = new
    return maxi
$$;

CREATE OR REPLACE AGGREGATE max_age(DATE) (
    sfunc = _agg_oldest,
    stype = DATE,
    initcond = '5999-12-31'
);

-- SELECT max_age(dob)
-- FROM driver;


-- 3. Определяемая пользователем табличная функция CLR
CREATE OR REPLACE FUNCTION get_driver_by_nat_count() 
    RETURNS TABLE(
        nationality TEXT,
        cnt INT
    )
    LANGUAGE plpython3u
AS
$$
    result_table = []
    unique_nats = plpy.execute("\
        SELECT DISTINCT nationality\n\
        FROM driver;"
    )
    
    for nationality in unique_nats:
        if nationality["nationality"] != '-':
            result_table.append(
                {
                    "nationality": nationality["nationality"],
                    "cnt": plpy.execute(f"\
                        SELECT COUNT(driver_id)\n\
                        FROM driver\n\
                        WHERE nationality = '{nationality['nationality']}';"
                    )[0]["count"]
                }
            )
    return result_table
$$;

-- SELECT *
-- FROM get_driver_by_nat_count()
-- ORDER BY cnt DESC;


-- 4. Хранимая процедура CLR
CREATE OR REPLACE PROCEDURE id_by_surname(surname VARCHAR)
    LANGUAGE plpython3u
AS
$$
    import requests
    import datetime as dt

    id = plpy.execute(f"\
        SELECT driver_id\n\
        FROM driver\n\
        WHERE surname = '{surname['surname']}';"
        )[0]["count"]

    if id == none:
        plpy.notice(
            f"There is no driver with '{surname}' surname."
        )
    else:
        plpy.notice(
            f"There is '{id}' driver for driver with '{surname}' surname."
        )
$$;


-- CALL id_by_surname('Hamilton');   
-- CALL id_by_surname('Sarkisov');   


-- 5. Триггер CLR
CREATE OR REPLACE FUNCTION al_admin_insert() 
    RETURNS TRIGGER
    LANGUAGE plpython3u
AS
$$
    surname_new = plpy.execute(f"\
        SELECT NEW.surname\n\
        FROM NEW\n\
        WHERE NEW.driver_id = MAX(NEW.driver_id)
        )[0]["count"]"
    
    cnt = plpy.execute(f"\
        SELECT COUNT(driver_id)\n\
        FROM driver\n\
            WHERE surname = '{surname_new}';"
        )[0]["count"]

    if cnt != 0:
        return 
    else:
        return "SKIP"
$$;

-- CREATE TRIGGER is_driver_unique
--     BEFORE INSERT
--     ON driver
-- FOR EACH STATEMENT
-- EXECUTE PROCEDURE is_driver_unique_proc();


-- 6. Определяемый пользователем тип данных CLR
CREATE TYPE driver_t AS (
    driver_id INT,
    surname VARCHAR, 
    dob DATE
);

CREATE OR REPLACE FUNCTION get_ap_capacity(driver_id INT, surname VARCHAR) 
    RETURNS driver_t
    LANGUAGE plpython3u
AS
$$
    dob = plpy.execute(f"\
        SELECT d.dob\n\
        FROM driver d\n\
        WHERE d.surname = '{surname}' AND\n\
            d.driver_id = '{driver_id}';"
    )[0]["dob"]
    return (driver_id, surname, dob)
$$;