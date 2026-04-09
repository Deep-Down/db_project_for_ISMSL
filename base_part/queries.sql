-- Список механизмов и типов датчиков, установленных на них
SELECT m.model, m.location, s.sensor_type 
FROM Mechanism m 
JOIN Sensor s ON m.mechanism_id = s.mechanism_id;

-- Последние 5 показаний температуры
SELECT r.value, r.recorded_at 
FROM Reading r 
JOIN Sensor s ON r.sensor_id = s.sensor_id 
WHERE s.sensor_type = 'Temperature' 
ORDER BY r.recorded_at DESC LIMIT 5;

-- Количество алертов для каждого инженера
SELECT e.full_name, COUNT(a.alert_id) as total_alerts 
FROM Engineer e 
LEFT JOIN Alert a ON e.engineer_id = a.engineer_id 
GROUP BY e.full_name;

-- Механизмы с критическим уровнем вибрации
SELECT DISTINCT m.model, a.description 
FROM Mechanism m 
JOIN Sensor s ON m.mechanism_id = s.mechanism_id 
JOIN Reading r ON s.sensor_id = r.sensor_id 
JOIN Alert a ON r.reading_id = a.reading_id 
WHERE a.severity = 'Critical' AND s.sensor_type = 'Vibration';

-- Среднее значение шума по локациям
SELECT m.location, AVG(r.value) as avg_noise 
FROM Mechanism m 
JOIN Sensor s ON m.mechanism_id = s.sensor_id 
JOIN Reading r ON s.sensor_id = r.sensor_id 
WHERE s.sensor_type = 'Noise' 
GROUP BY m.location;

-- Поиск датчиков, которые ни разу не срабатывали
SELECT serial_number FROM Sensor 
WHERE sensor_id NOT IN (SELECT DISTINCT sensor_id FROM Reading);

-- Алерты, которые до сих пор в статусе "New"
SELECT description, severity FROM Alert WHERE status = 'New';

-- Максимальные пороги вхождения для каждого типа датчика в алертах
SELECT s.sensor_type, MAX(ad.max_threshold) 
FROM Alert_details ad 
JOIN Sensor s ON ad.sensor_id = s.sensor_id 
GROUP BY s.sensor_type;

-- Инженеры, которые имеют нерешенные задачи
SELECT DISTINCT e.full_name 
FROM Engineer e 
JOIN Alert a ON e.engineer_id = a.engineer_id 
WHERE e.specialization = 'Механик' AND a.status != 'Resolved';

-- Показания, превысившие среднее значение по всем датчикам
SELECT reading_id, value FROM Reading 
WHERE value > (SELECT AVG(value) FROM Reading);