from peewee import *
import json
from playhouse.postgres_ext import *

conn = PostgresqlDatabase('formula_1', user='postgres', password='qwerty',
                           host='localhost')
cursor = conn.cursor()

class BaseModel(Model):
    class Meta:
        database = conn
    
class Driver(BaseModel):
    driver_id = AutoField(column_name='driver_id', primary_key=True)
    driver_ref = TextField(column_name='driver_ref')
    driver_number = IntegerField(column_name='driver_number')
    code = TextField(column_name='code')
    forename = TextField(column_name='forename')
    surname = TextField(column_name='surname')
    dob = DateField(column_name='dob')
    nationality = TextField(column_name='nationality') 

    class Meta:
        table_name = 'driver'

class Result(BaseModel):
    result_id = AutoField(column_name='result_id', primary_key=True)
    driver_id = IntegerField(column_name='driver_id')
    number = IntegerField(column_name='number')
    grid = IntegerField(column_name='grid')
    position = IntegerField(column_name='position')
    position_text = TextField(column_name='position_text')
    position_order = IntegerField(column_name='position_order')
    points = IntegerField(column_name='points')
    laps = IntegerField(column_name='laps') 
    milliseconds = IntegerField(column_name='milliseconds')
    fastest_lap = IntegerField(column_name='fastest_lap')
    rank = IntegerField(column_name='rank')
    fastest_lap_speed = IntegerField(column_name='fastest_lap_speed')

    class Meta:
        table_name = 'result'

class DriverPassport(Model):
    passport_number = IntegerField(column_name='passport_number')
    name = JSONField(column_name='name')

    class Meta:
        table_name = 'driver_passport'



# 1.1.  SELECT + WHERE
def SelectWhere():
    query = (Driver.select()
                   .where(Driver.driver_id >= 200)
                   .where(Driver.driver_id <= 205))
    return query 

# 1.2 SELECT + ORDER BY
def SelectOrderBy():
    query = (Driver.select(Driver.driver_id, Driver.forename, Driver.surname)
                   .order_by(Driver.surname).limit(5))
    return query 

# 1.3 SELECT + HAVING
def SelectHaving():
    query = (Driver.select(Driver.surname, Driver.nationality)
                   .having(Driver.nationality == 'French')
                   .group_by(Driver.driver_id).limit(5))
    return query

# 1.4 SELECT + GROP BY (with out HAVING)
def SelectGroupByWithOutHaving():
    query = (Driver.select(Driver.driver_id, Driver.surname, Result.milliseconds)        
                   .join(Result, on=(Driver.driver_id == Result.driver_id))
                   .where(Result.position == 1)
                   .group_by(Driver.driver_id, Driver.surname, Result.milliseconds))
    return query

# 1.5 SELECT + FROM
def SelectFrom():
    query = (Driver.select(Driver.driver_id, Driver.forename, Driver.surname)        
                   .limit(10)) 
    return query

# 2.1 Reading from JSON document.
def JSONReadingQuery():
    query = (DriverPassport.select(DriverPassport.name)) 
    print(query)
    return query

# 3.1 Single table query request.
def SingleTableQuery():
    query = (Driver.select(Driver.surname, Driver.nationality)
                   .having(Driver.nationality == 'French')
                   .group_by(Driver.driver_id).limit(5))
    return query

# 3.2 Multi table query request.
def MultiTableQuery():
    query = (Result.select(Result.driver_id, Driver.forename, Driver.surname, fn.AVG(Result.milliseconds))
                   .join(Driver, on=(Result.driver_id == Driver.driver_id))
                   .where(Result.milliseconds.is_null(False))
                   .group_by(Result.driver_id, Driver.forename, Driver.surname)
                   .limit(5))
    return query

# 3.3.1 Insert data query to db.
def InsertDataQuery():
    query = (Driver.insert(driver_id=844, 
                           driver_ref='sarkisov', 
                           driver_number=4,
                           code='SAR',
                           forename='Artem',
                           surname='Sarkisov',
                           dob='2000-06-12',
                           nationality='Russian')).execute()

# 3.3.2 Delete data query from db.
def DeleteDataQuery():
    query = (Driver.delete()
                   .where(Driver.surname == 'Sarkisov')).execute()

# 3.3.3 Update data query in db.
def UpdateDataQuery():
    query = (Driver.update(code='SRK')
                   .where(Driver.surname == 'Sarkisov')).execute()

# 3.4 Call stored procedure.
def CallStoredProcedure(cursor):
    cursor.callproc('get_driver_age')

def ApplyQuery(queryFunc):
    driver_selected = queryFunc().dicts().execute()
    for driver in driver_selected:
        print(driver)


ApplyQuery(JSONReadingQuery)
#InsertDataQuery()
#UpdateDataQuery()
#DeleteDataQuery()
#CallStoredProcedure(cursor)

cursor.close()
conn.close()