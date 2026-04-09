DROP TABLE IF EXISTS Alert_details CASCADE;
DROP TABLE IF EXISTS Alert CASCADE;
DROP TABLE IF EXISTS Reading CASCADE;
DROP TABLE IF EXISTS Sensor CASCADE;
DROP TABLE IF EXISTS Engineer CASCADE;
DROP TABLE IF EXISTS Mechanism CASCADE;

CREATE TABLE Mechanism (
    mechanism_id SERIAL PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    installation_date DATE NOT NULL,
    location VARCHAR(255) NOT NULL
);

CREATE TABLE Engineer (
    engineer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    specialization VARCHAR(100),
    phone VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Sensor (
    sensor_id SERIAL PRIMARY KEY,
    mechanism_id INT NOT NULL,
    sensor_type VARCHAR(50) NOT NULL,
    serial_number VARCHAR(50) UNIQUE NOT NULL,
    -- Внешний ключ: если механизм удалят, датчики тоже (CASCADE) или запрет удаления
    CONSTRAINT fk_mechanism FOREIGN KEY (mechanism_id) REFERENCES Mechanism(mechanism_id) ON DELETE CASCADE
);

CREATE TABLE Reading (
    reading_id SERIAL PRIMARY KEY,
    sensor_id INT NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sensor FOREIGN KEY (sensor_id) REFERENCES Sensor(sensor_id) ON DELETE CASCADE
);

CREATE TABLE Alert (
    alert_id SERIAL PRIMARY KEY,
    reading_id INT NOT NULL,
    engineer_id INT,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'New',
    severity VARCHAR(20) NOT NULL,
    CONSTRAINT fk_reading FOREIGN KEY (reading_id) REFERENCES Reading(reading_id),
    CONSTRAINT fk_engineer FOREIGN KEY (engineer_id) REFERENCES Engineer(engineer_id),
    -- Ограничение на значения статуса и критичности
    CONSTRAINT check_status CHECK (status IN ('New', 'In Progress', 'Resolved', 'False Alarm')),
    CONSTRAINT check_severity CHECK (severity IN ('Low', 'Medium', 'High', 'Critical'))
);


CREATE TABLE Alert_details (
    alert_sensor_id SERIAL PRIMARY KEY,
    alert_id INT NOT NULL,
    sensor_id INT NOT NULL,
    min_threshold NUMERIC(10, 3) NOT NULL,
    max_threshold NUMERIC(10, 3) NOT NULL,
    CONSTRAINT fk_alert FOREIGN KEY (alert_id) REFERENCES Alert(alert_id) ON DELETE CASCADE,
    CONSTRAINT fk_sensor_detail FOREIGN KEY (sensor_id) REFERENCES Sensor(sensor_id),
    -- Важная бизнес-логика: макс всегда больше мин
    CONSTRAINT check_thresholds CHECK (max_threshold > min_threshold)
);