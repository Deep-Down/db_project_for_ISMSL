--- индексы для ускорения запросов в ISMSL
CREATE INDEX idx_reading_time ON Reading(recorded_at);
CREATE INDEX idx_alert_severity_status ON Alert(severity, status);
CREATE INDEX idx_sensor_mechanism ON Sensor(mechanism_id);



-- функция: считает количество активных задач у инженера
CREATE OR REPLACE FUNCTION get_engineer_load(eng_id INT) 
RETURNS INT AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM Alert WHERE engineer_id = eng_id AND status != 'Resolved');
END;
$$ LANGUAGE plpgsql;

-- процедура: закрывает все алерты для конкретного механизма 
CREATE OR REPLACE PROCEDURE close_all_mechanism_alerts(mech_id INT)
AS $$
BEGIN
    UPDATE Alert 
    SET status = 'Resolved' 
    WHERE reading_id IN (
        SELECT reading_id FROM Reading r
        JOIN Sensor s ON r.sensor_id = s.sensor_id
        WHERE s.mechanism_id = mech_id
    ) AND status != 'Resolved';
END;
$$ LANGUAGE plpgsql;

-- функция: проверяет специализацию инженера для конкретной задачи
CREATE OR REPLACE FUNCTION check_engineer_specialization(eng_id INT, required_spec TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM Engineer 
        WHERE engineer_id = eng_id AND specialization = required_spec
    );
END;
$$ LANGUAGE plpgsql;



-- триггер: Автоматически создает алерт при превышении порога для температуры
CREATE OR REPLACE FUNCTION check_reading_threshold()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT sensor_type FROM Sensor WHERE sensor_id = NEW.sensor_id) = 'Temperature' AND NEW.value > 85 THEN
        INSERT INTO Alert (reading_id, engineer_id, description, severity, status)
        VALUES (NEW.reading_id, 1, 'Критический перегрев!', 'Critical', 'New');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_insert_reading
AFTER INSERT ON Reading
FOR EACH ROW
EXECUTE FUNCTION check_reading_threshold();

-- таблица для хранения истории
CREATE TABLE IF NOT EXISTS Alert_Status_Log (
    log_id SERIAL PRIMARY KEY,
    alert_id INT,
    old_status TEXT,
    new_status TEXT,
    changed_at TIMESTAMP DEFAULT NOW()
);

-- функция для логирования изменений статуса алерта
CREATE OR REPLACE FUNCTION log_alert_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO Alert_Status_Log (alert_id, old_status, new_status)
        VALUES (OLD.alert_id, OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- триггер для логирования изменений статуса алерта
CREATE TRIGGER trg_alert_status_update
AFTER UPDATE OF status ON Alert
FOR EACH ROW
EXECUTE FUNCTION log_alert_status_change();