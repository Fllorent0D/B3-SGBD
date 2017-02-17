drop sequence sequence_log;
drop table Logs;

CREATE TABLE Logs
(
	ID 				NUMBER(5, 0) CONSTRAINT LOGS$PK PRIMARY KEY,
	logtime		    TIMESTAMP,
	description		VARCHAR2(4000), 
    script        	VARCHAR2(1000),
    levelLog	    VARCHAR2(100)
);

CREATE OR REPLACE PROCEDURE Log_info(descrip IN logs.description%TYPE, script IN logs.script%type, lev IN logs.levellog%type)
AS
	PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

	INSERT INTO Logs (logtime, description, script, levelLog) VALUES (CURRENT_TIMESTAMP, descrip, script, lev);

	COMMIT;

EXCEPTION
	WHEN DUP_VAL_ON_INDEX 
    THEN 
      RAISE_APPLICATION_ERROR (-20001, 'Erreur lors de l''écriture dans les logs'); 
      ROLLBACK;
	WHEN OTHERS 
    THEN 
      ROLLBACK; 
      RAISE;
	
END;
/

CREATE SEQUENCE sequence_log INCREMENT BY 1 MAXVALUE 99999 CYCLE;


CREATE OR REPLACE TRIGGER logID
BEFORE INSERT ON Logs
FOR EACH ROW
BEGIN
	SELECT sequence_log.NEXTVAL INTO :NEW.ID FROM dual;
END;
/

COMMIT;
COMMIT;