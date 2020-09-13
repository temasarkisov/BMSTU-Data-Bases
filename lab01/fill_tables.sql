COPY driver FROM '/Users/temasarkisov/MyProjects/BMSTU/norm_data/drivers_norm.csv' DELIMITER ',' CSV HEADER;

COPY circuit FROM '/Users/temasarkisov/MyProjects/BMSTU/norm_data/circuits_norm.csv' DELIMITER ',' CSV HEADER;

COPY race FROM '/Users/temasarkisov/MyProjects/BMSTU/norm_data/races_norm.csv' DELIMITER ',' CSV HEADER;

COPY pit_stop FROM '/Users/temasarkisov/MyProjects/BMSTU/norm_data/pit_stops_norm.csv' DELIMITER ',' CSV HEADER;

COPY lap_time FROM '/Users/temasarkisov/MyProjects/BMSTU/norm_data/lap_time_norm.csv' DELIMITER ',' CSV HEADER;

COPY constructor FROM '/Users/temasarkisov/MyProjects/BMSTU/norm_data/constructors_norm.csv' DELIMITER ',' CSV HEADER;

COPY status FROM '/Users/temasarkisov/MyProjects/BMSTU/norm_data/status_norm.csv' DELIMITER ',' CSV HEADER;

COPY result FROM '/Users/temasarkisov/MyProjects/BMSTU/norm_data/result_norm.csv' DELIMITER ',' CSV HEADER;
