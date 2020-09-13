CREATE TABLE Race(
    race_id INTEGER,
    round INTEGER, 
    circuit_id INTEGER,
    name VARCHAR,
    date DATE,
    time TIME,

    PRIMARY KEY (race_id),
    FOREIGN KEY (circuit_id) REFERENCES circuit (circuit_id)
    );