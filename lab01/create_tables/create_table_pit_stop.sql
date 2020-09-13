CREATE TABLE Pit_stop(
    race_id INTEGER,
    driver_id INTEGER,
    stop INTEGER,
    lap INTEGER, 
    time TIME,
    milliseconds INTEGER,

    FOREIGN KEY (race_id) REFERENCES race (race_id),
    FOREIGN KEY (driver_id) REFERENCES driver (driver_id)
    );
