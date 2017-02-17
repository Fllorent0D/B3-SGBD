create or replace PROCEDURE RECEIPTION_RETOUR_COPIES AS 
  count_copies_inserted INTEGER := 0;
  
  TYPE copies_type IS TABLE OF XMLTYPE INDEX BY PLS_INTEGER;
  copies copies_type;
  
  idMovie VARCHAR2(255);
  numCopy VARCHAR2(255);
BEGIN
  SELECT * BULK COLLECT INTO copies FROM com_retour_copies@CC_LINK;
  
  IF(copies IS NOT NULL) THEN
    FOR cpt IN copies.FIRST .. copies.LAST LOOP
      idMovie := copies(cpt).EXTRACT('/copy/movie/text()').getstringval();
      numCopy := copies(cpt).EXTRACT('/copy/num/text()').getstringval();
      
      INSERT INTO movie_copies (movie, num_copy) VALUES(idMovie, numCopy);
      count_copies_inserted := count_copies_inserted + SQL%ROWCOUNT;
    END LOOP;
  END IF;
  
  DELETE FROM com_retour_copies@CC_LINK;
  
  LOG_INFO('[RECEIPTION_RETOUR_COPIES] Nombre de copies recues: ' || count_copies_inserted, 'Procedure', 'Info');
EXCEPTION
  WHEN OTHERS THEN LOG_INFO('[RECEIPTION_RETOUR_COPIES] ' || SQLERRM, 'Procedure', 'Error'); ROLLBACK;
END RECEIPTION_RETOUR_COPIES;
/