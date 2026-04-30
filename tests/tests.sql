-- ТЕСТ 1: Проверка триггера
INSERT INTO Reading (sensor_id, value, recorded_at) 
VALUES (1, 95.5, NOW());
SELECT * FROM Alert WHERE description = 'Критический перегрев!';

-- ТЕСТ 2: Проверка функции нагрузки
SELECT full_name, get_engineer_load(engineer_id) FROM Engineer;

-- ТЕСТ 3: Проверка процедуры закрытия
CALL close_all_mechanism_alerts(1);
SELECT count(*) FROM Alert WHERE status != 'Resolved' AND reading_id IN (
    SELECT reading_id FROM Reading r JOIN Sensor s ON r.sensor_id = s.sensor_id WHERE s.mechanism_id = 1
);