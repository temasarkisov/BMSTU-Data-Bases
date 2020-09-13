import csv
from random import randrange

def normalize_row(row):
    row[1] = row[1].replace('�', '')

    row[2] = row[2].replace('�', '')
    row[2] = row[2].replace('_', ' ')
    row[2] = row[2].capitalize()

    row[3] = row[3].replace('�', '')
    row[3] = row[3].replace('_', ' ')
    row[3] = row[3].capitalize()

    row[4] = row[4].replace('�', '')
    row[4] = row[4].replace('_', ' ')
    row[4] = row[4].capitalize()

    if row[5] == '':
        row[5] = 0
    if row[6] == '':
        row[6] = 0
    if row[7] == '':
        row[7] = 0

with open('formula_1_dataset/circuits.csv', 'r', encoding='ISO-8859-1') as f, open('circuits_norm.csv', 'w') as wf:
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
