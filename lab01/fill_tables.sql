COPY driver FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab01/normalized_data/drivers_norm.csv' DELIMITER ',' CSV HEADER;

COPY circuit FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab01/normalized_data/circuits_norm.csv' DELIMITER ',' CSV HEADER;

COPY race FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab01/normalized_data/races_norm.csv' DELIMITER ',' CSV HEADER;

COPY pit_stop FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab01/normalized_data/pit_stops_norm.csv' DELIMITER ',' CSV HEADER;

COPY lap_time FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab01/normalized_data/lap_time_norm.csv' DELIMITER ',' CSV HEADER;

COPY constructor FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab01/normalized_data/constructors_norm.csv' DELIMITER ',' CSV HEADER;

COPY status FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab01/normalized_data/status_norm.csv' DELIMITER ',' CSV HEADER;

COPY result FROM '/Users/temasarkisov/OwnProjects/BMSTU/BMSTU-Data-Bases/lab01/normalized_data/result_norm.csv' DELIMITER ',' CSV HEADER;
