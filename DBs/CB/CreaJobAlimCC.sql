BEGIN
	DBMS_SCHEDULER.CREATE_JOB
	(
		JOB_NAME => 'JOB_ALIM_CC',
		JOB_TYPE => 'STORED_PROCEDURE',
		JOB_ACTION => 'ALIMCCPACKAGE.JOB',
		START_DATE => SYSTIMESTAMP,
		REPEAT_INTERVAL => 'FREQ=WEEKLY;BYHOUR=0;BYMINUTE=1;BYSECOND=0',
		ENABLED => TRUE,
		COMMENTS => 'Alimentation hebdomadaire de la BD CC'
	);
END;
/
/*

BEGIN
	DBMS_SCHEDULER.DROP_JOB('JOB_ALIM_CC');
END;

BEGIN
	DBMS_SCHEDULER.CREATE_JOB
	(
		JOB_NAME => 'JOB_ALIM_CC',
		JOB_TYPE => 'STORED_PROCEDURE',
		JOB_ACTION => 'ALIMCCPACKAGE.JOB',
		START_DATE => SYSTIMESTAMP,
		REPEAT_INTERVAL => 'FREQ=MINUTELY;INTERVAL=1',
		ENABLED => TRUE,
		COMMENTS => 'Alimentation hebdomadaire de la BD CC'
	);
END;

*/


