CREATE TABLE Result(
    result_id INTEGER,
    race_id INTEGER,
    driver_id INTEGER,
    constructor_id INTEGER,
    number INTEGER, 
    grid INTEGER, 
    position INTEGER,
    position_text VARCHAR,
    position_order INTEGER,
    points NUMERIC,
    laps INTEGER, 
    milliseconds INTEGER,
    fastest_lap INTEGER,
    rank INTEGER,
    fastest_lap_speed NUMERIC,
    status_id INTEGER,

    PRIMARY KEY (result_id),
    FOREIGN KEY (race_id) REFERENCES race (race_id),
    FOREIGN KEY (driver_id) REFERENCES driver (driver_id),
    FOREIGN KEY (constructor_id) REFERENCES constructor (constructor_id),
    FOREIGN KEY (status_id) REFERENCES status (status_id)
    );
