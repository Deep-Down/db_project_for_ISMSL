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