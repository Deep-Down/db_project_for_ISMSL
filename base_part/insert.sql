-- Путь к папке должен быть абсолютным!
COPY Mechanism FROM '/home/sierra/Документы/codespace/db_project/db_project_for_ISMSL/data/Mechanism.csv' DELIMITER ',' CSV HEADER;
COPY Engineer FROM '/home/sierra/Документы/codespace/db_project/db_project_for_ISMSL/data/Engineer.csv' DELIMITER ',' CSV HEADER;
COPY Sensor FROM '/home/sierra/Документы/codespace/db_project/db_project_for_ISMSL/data/Sensor.csv' DELIMITER ',' CSV HEADER;
COPY Reading FROM '/home/sierra/Документы/codespace/db_project/db_project_for_ISMSL/data/Reading.csv' DELIMITER ',' CSV HEADER;
COPY Alert FROM '/home/sierra/Документы/codespace/db_project/db_project_for_ISMSL/data/Alert.csv' DELIMITER ',' CSV HEADER;
COPY Alert_details FROM '/home/sierra/Документы/codespace/db_project/db_project_for_ISMSL/data/Alert_details.csv' DELIMITER ',' CSV HEADER;
db_project/db_project_for_ISMSL/data