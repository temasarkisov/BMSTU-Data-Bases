import psycopg2

def scalarSQLRequest(cursor):
    cursor.execute('SELECT driver_id FROM driver WHERE surname = %(surname)s LIMIT 1', {"surname":"Verstappen"})
    records = cursor.fetchall()
    print('\nID пилота для фамилии Verstappen -', records[0][0])

def multiplesJoinsSQLRequest(cursor):
    cursor.execute('SELECT dr.driver_id, dr.surname, rc.name, rc.date, rs.grid ' +
                   'FROM result AS rs JOIN driver AS dr ON rs.driver_id = dr.driver_id ' +
                   'JOIN race AS rc ON rs.race_id = rc.race_id')
    records = cursor.fetchmany(size=5)
    print('\n')
    for row in records:
        print(row)

def cteSQLRequest(cursor):
    cursor.execute('WITH CTE (driver_id, position) AS ' +
    '( ' +
        'SELECT driver_id, position ' + 
        'FROM result ' +
        'WHERE position IS NOT NULL ' +
        'AND grid = 1' + 
        'GROUP BY driver_id, position ' +
    ') ' +
    'SELECT DISTINCT driver_id, AVG(position) OVER (PARTITION BY driver_id) FROM CTE')
    records = cursor.fetchall()
    print('\n')
    for row in records:
        print(row)
    
def metadataSQLRequest(cursor):
    cursor.execute('SELECT tablename ' +
    'FROM pg_tables ' +
    'WHERE schemaname = %(type)s', {"type":"public"})
    records = cursor.fetchall()
    print('\n')
    print('Список таблиц "public":')
    for row in records:
        print(row[0])

def callSQLScalarFunction(cursor):
    cursor.execute('SELECT * ' +
    'FROM get_nationality_count(%(nationality)s)', {"nationality":"French"})
    records = cursor.fetchall()
    print('\n')
    print('Количество французских пилотов:')
    for row in records:
        print(row[0])

def callSQLTableFunction(cursor):
    cursor.execute('SELECT * ' +
    'FROM get_driver_age()')
    records = cursor.fetchall()
    print('\n')
    print('Информация о возрасте пилота:')
    print('driver_id, age_diff, age_min, age_max')
    for row in records:
        print(row)

def callSQLScalarProcedure(cursor, conn):
    print('Все пилоты с фамилией "Sarkisov" были удалены!')
    cursor.execute('CALL delete_driver_by_sn(%(surname)s)', {"surname":"Sarkisov"})
    conn.commit()

def systemSQLFunction(cursor):
    cursor.execute('SELECT version()')
    record = cursor.fetchall()
    print('Версия PostgreSQL:')
    print(record[0][0])

def createSQLTable(cursor, conn):
    cursor.execute('CREATE TABLE IF NOT EXISTS driver_passport ' +
    '(passport_number INT NOT NULL, name TEXT NOT NULL)')
    conn.commit()

def fillSQLTable(cursor, conn):
    cursor.execute("INSERT INTO driver_passport (passport_number, name) VALUES (%s, %s)",
    ("19385987", "Lewis Hamilton"))
    conn.commit()

def menu(cursor, conn):
    while True:
        print('\n1 - Выполнить скалярный запрос;')
        print('2 - Выполнить запрос с несколькими соединениями (JOIN);')
        print('3 - Выполнить запрос с ОТВ (CTE) и оконными функциями;')
        print('4 - Выполнить запрос к метаданным;')
        print('5 - Вызвать скалярную функцию (написанную в третьей лабораторной работе);')
        print('6 - Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе);')
        print('7 - Вызвать хранимую процедуру (написанную в третьей лабораторной работе);')
        print('8 - Вызвать системную функцию или процедуру;')
        print('9 - Создать таблицу в базе данных, соответствующую тематике БД;')
        print('10 - Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY.')
        print('\n0 - Выход\n')

        operNum = int(input('Введите номер операции: '))
        if operNum == 0:
            return
        elif operNum == 1:
            scalarSQLRequest(cursor)
        elif operNum == 2:
            multiplesJoinsSQLRequest(cursor)
        elif operNum == 3:
            cteSQLRequest(cursor)
        elif operNum == 4:
            metadataSQLRequest(cursor)
        elif operNum == 5:
            callSQLScalarFunction(cursor)
        elif operNum == 6:
            callSQLTableFunction(cursor)
        elif operNum == 7:
            callSQLScalarProcedure(cursor, conn)
        elif operNum == 8:
            systemSQLFunction(cursor)
        elif operNum == 9:
            createSQLTable(cursor, conn)
        elif operNum == 10:
            fillSQLTable(cursor, conn)
        else:
            return
            
conn = psycopg2.connect(dbname='formula_1', user='postgres', 
                        password='qwerty', host='localhost')
cursor = conn.cursor()

menu(cursor, conn)

cursor.close()
conn.close()