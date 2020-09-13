import csv
from random import randrange

def normalize_row(row):
    if (row[5] == 'ï¿½'):
        hour = randrange(11, 17, 1)
        hour = str(hour)
        row[5] = hour + ":00:00"

with open('formula_1_dataset/races.csv', 'r', encoding='ISO-8859-1') as rf, open('races_norm.csv', 'w') as wf:
    reader = csv.reader(rf)
    writer = csv.writer(wf)
    #next(reader) 
    len = 0

    for row in reader:
        row = row[0:-1]
        row.pop(1)

        if (len == 0):
            writer.writerow(row) 
        else:
            normalize_row(row)
            writer.writerow(row) 

        len += 1

print('Number of rows in table -', len)
