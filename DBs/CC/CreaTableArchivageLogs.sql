CREATE TABLE archivage_logs
(
  id integer PRIMARY KEY,
  date_execution DATE
);

CREATE SEQUENCE sequence_archivage_logs  INCREMENT BY 1 MAXVALUE 99999 CYCLE;

CREATE OR REPLACE TRIGGER archivage_logs_id
  BEFORE INSERT ON archivage_logs
  FOR EACH ROW
DECLARE
BEGIN
  IF(:new.id IS NULL)
  THEN
    :new.id := sequence_archivage_logs.nextval;
  END IF;
END;
/