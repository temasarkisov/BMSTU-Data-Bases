CREATE TABLE Lap_time(
    race_id INTEGER,
    driver_id INTEGER,
    lap INTEGER,
    position INTEGER, 
    time TIME,

    FOREIGN KEY (race_id) REFERENCES race (race_id),
    FOREIGN KEY (driver_id) REFERENCES driver (driver_id)
    );
