create or replace TRIGGER STATUSRELEASEDATE 
BEFORE INSERT OR UPDATE OF RELEASE_DATE,STATUS ON MOVIE 
FOR EACH ROW
WHEN (new.RELEASE_DATE IS NOT NULL AND new.STATUS IS NOT NULL)
DECLARE
currentStatus status.name%type;
yearMovie number(4);
currentYear number(4);
badDate   exception;
BEGIN
    LOG_INFO('[TRIGGER]Test du status et de la date du film '||to_char(:NEW.id) , 'STATUSRELEASEDATE', 'Info');

    SELECT name into currentStatus from status where id = :NEW.STATUS;
    IF currentStatus = 'Released' THEN
      currentYear := extract(YEAR from sysdate);
      yearMovie := extract(YEAR from :NEW.release_date);
      IF yearMovie > currentYear + 5 THEN
        raise badDate;
      END IF;
    END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
  WHEN badDate then 
    LOG_INFO('[TRIGGER]Le statut du film ('||to_char(:NEW.id)||') ne peut pas être ''Released'' lorsque la date est plus loin que '|| to_char(currentYear + 5), 'STATUSRELEASEDATE', 'Error');
    RAISE_APPLICATION_ERROR(-20002, 'Le statut du film ('||to_char(:NEW.id)||') ne peut pas être ''Released'' lorsque la date est plus loin que '|| to_char(currentYear + 5));
END;
/