-- 3 - ий вариант. Саркисов Артём ИУ7-53Б.

-- 1 - ое задание 
CREATE DATABASE rk2;


CREATE TABLE dish(
    dish_id INT,
    dish_name TEXT,
    descr TEXT,
    rating INT,
    product_id INT,
    menu_id INT,

    PRIMARY KEY (dish_id)
);

ALTER TABLE dish
ADD CONSTRAINT dish_product_fk
FOREIGN KEY (product_id) REFERENCES product (product_id);

ALTER TABLE dish
ADD CONSTRAINT dish_menu_fk
FOREIGN KEY (menu_id) REFERENCES menu (menu_id);    

-- alter table dish drop constraint dish_product_fk;
-- alter table dish drop constraint dish_menu_fk;


CREATE TABLE product(
    product_id INT,
    product_name TEXT,
    man_date DATE,
    shelf_days INT,
    supplier TEXT,
    dish_id INT,

    PRIMARY KEY (product_id)
);

ALTER TABLE product
ADD CONSTRAINT product_dish_fk
FOREIGN KEY (dish_id) REFERENCES dish (dish_id);

-- alter table product drop constraint product_dish_fk;


CREATE TABLE menu(
    menu_id INT,
    eats_time TEXT,
    CHECK (eats_time = 'breakfast' OR eats_time = 'lunch' OR eats_time = 'dinner'),
    descr TEXT,
    dish_id INT,

    PRIMARY KEY (menu_id)
);

ALTER TABLE menu
ADD CONSTRAINT menu_dish_fk
FOREIGN KEY (dish_id) REFERENCES dish (dish_id);

-- alter table menu drop constraint menu_dish_fk;


INSERT INTO dish (dish_id,dish_name,descr,rating,product_id,menu_id)
VALUES 
(1, 'fried fish', 'tasty fried fish', 9, 1, 10),
(2, 'boiled fish', 'tasty boiled fish', 9, 1, 10),
(3, 'fried meat', 'tasty fried meat', 10, 2, 11),
(4, 'boiled meat', 'tasty boiled meat', 10, 2, 11),
(5, 'fried egg', 'tasty fried egg', 7, 3, 12),
(6, 'boiled egg', 'tasty boiled egg', 7, 3, 12),
(7, 'fried tomato', 'tasty fried tomato', 9, 4, 13),
(8, 'boiled tomato', 'tasty boiled tomato', 9, 4, 13),
(9, 'fried potato', 'tasty fried potato', 10, 5, 14),
(10, 'boiled potato', 'tasty fried potato', 10, 5, 14);


INSERT INTO product (product_id,product_name,man_date,shelf_days,supplier,dish_id)
VALUES 
(1, 'fish1', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 1),
(2, 'fish2', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 1),
(3, 'meat1', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 2),
(4, 'meat2', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 2),
(5, 'egg1', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 3),
(6, 'egg2', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 3),
(7, 'tomato1', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 4),
(8, 'tomato2', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 4),
(9, 'potato', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 5),
(10, 'potato', TO_DATE('20000612', 'YYYYMMDD'), 30, 'Petya', 5);


INSERT INTO menu (menu_id,eats_time,descr,dish_id)
VALUES 
(10, 'breakfast', 'very tasty fried fish', 9),
(11, 'breakfast', 'very tasty boiled fish', 9),
(12, 'breakfast', 'very tasty fried meat', 10),
(13, 'dinner', 'very tasty boiled meat', 10),
(14, 'dinner', 'very tasty fried egg', 7),
(15, 'dinner', 'very tasty boiled egg', 7),
(16, 'dinner', 'very tasty fried tomato', 9),
(17, 'lunch', 'very tasty boiled tomato', 9),
(18, 'lunch', 'very tasty fried potato', 10),
(19, 'lunch', 'very tasty fried potato', 10);


-- 2 - ое задание 

-- Инструкция SELECT, использующая предикат сравнения с квантором
-- Инструкция выводит всю информацию о блюдах, рейтинг которых меньше всех рейтингов
-- блюд с id равным 11, то есть с рейтингом меньше максимального рейтинга
-- блюд с id равным 11. 
SELECT *
FROM dish
WHERE rating < ALL (
    SELECT rating 
    FROM dish 
    WHERE menu_id = 11
);

-- Инструкция SELECT, использующая агрегатные функции в выражениях столбцов
-- Инструкция выводит средний рейтинг всех блюд из таблицы dish.
SELECT AVG(rating) AS "Average Rating"
FROM dish;

-- Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
-- Инструкция создаёт временную локальныю таблицу, состоящую из всех 
-- данных о позиции в меню, врменя приема пищи которых равно 'breakfast', 
-- то есть таким образом получаю утреннее меню. 
SELECT menu_id, descr, dish_id
INTO menu_breakfast
FROM menu
WHERE eats_time = 'breakfast'


-- 3 - е задание 
-- Создать хранимая процедура, которая, не уничтожая базу данных, 
-- уничтожает все те таблицы текущей базы данных в схеме 'dbo', 
-- имена которых начинаются с фразы 'TableName'.
CREATE OR REPLACE PROCEDURE drop_by_interval()  
    LANGUAGE plpgsql
AS 
$$
DECLARE 
    tmp_table_name text;
    cursor_table_name CURSOR FOR
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = 'public';
BEGIN  
    OPEN cursor_table_name;
    LOOP
        FETCH cursor_table_name INTO tmp_table_name;
        EXIT WHEN NOT FOUND;

        IF tmp_table_name LIKE 'tablename%' THEN
            EXECUTE 'DROP TABLE IF EXISTS ' || tmp_table_name || ';'; 
            RAISE NOTICE 'Table "%" was deleted!', tmp_table_name;
        END IF;
    END LOOP;

    CLOSE cursor_table_name;
END;
$$;

