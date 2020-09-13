# psql -U postgres -h 127.0.0.1 -d formula_1 -f create_table_driver.sql

import csv
from random import randrange

def normalize_row(row):
    row[1] = row[1].replace('�', '')

    if (row[2] == ''):
        row[2] = randrange(0, 99, 1)

    if (row[3] == ''):
        row[3] = row[1][:3].upper()

    row[4] = row[4].replace('�', '')
    row[4] = row[4].replace('_', ' ')
    row[4] = row[4].capitalize()

    row[5] = row[5].replace('�', '')
    row[5] = row[5].replace('_', ' ')
    row[5] = row[5].capitalize()

    row[6] = row[6].replace('/', '-')
    row[6] = row[6].split(sep='-', maxsplit = 2)
    if (row[6][0] == ''):
        row[6][0] = randrange(0, 30, 1)
    row[6][0] = str(row[6][0])
    if (row[6][1] == ''):
        row[6][1] = randrange(0, 12, 1)
    row[6][1] = str(row[6][1])
    if (row[6][2] == ''):
        row[6][2] = randrange(1950, 2000, 1)
    row[6][2] = str(row[6][2])
    row[6] = row[6][2] + "-" + row[6][1] + '-' + row[6][0]

    row[7] = row[7].replace('�', '')
    row[7] = row[7].replace('_', ' ')
    row[7] = row[7].capitalize()

with open('formula_1_dataset/drivers.csv', 'r') as f, open('drivers_norm.csv', 'w') as wf:
    reader = csv.reader(f)
    writer = csv.writer(wf)
    #next(reader) 
    len = 0

    for row in reader:
        row = row[0:-1]
        if (len == 0):
            writer.writerow(row) 
        else:
            normalize_row(row)
            writer.writerow(row) 

        len += 1

print('Number of rows in table -', len)
