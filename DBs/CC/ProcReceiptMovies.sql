create or replace PROCEDURE RECEIPT_MOVIES AS 
  movie_xml XMLTYPE;
  count_movies_inserted INTEGER;
  count_copies_inserted INTEGER;
BEGIN

  COMMIT;

  /* Début de la transaction */
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
  
  /* Ajout des films et copies dans CC */
  INSERT INTO MOVIES SELECT * FROM COM_MOVIES@CB_LINK
    WHERE EXTRACTVALUE(movie, 'movie/id') NOT IN (SELECT EXTRACTVALUE(OBJECT_VALUE, 'movie/id') FROM MOVIES);
    
  count_movies_inserted := SQL%ROWCOUNT;
    
  INSERT INTO COPIES SELECT * FROM COM_COPIES@CB_LINK;
  
  count_copies_inserted := SQL%ROWCOUNT;
  
  /* Suppression des films et copies dans les tables de communications*/
  DELETE FROM COM_MOVIES@CB_LINK;
  DELETE FROM COM_COPIES@CB_LINK;
  
  /* Fin de la transaction */
  COMMIT;
  
  LOG_INFO('[RECEIPT_MOVIES] Nombre de films recus: ' || count_movies_inserted, 'Procedure', 'Info');
  LOG_INFO('[RECEIPT_MOVIES] Nombre de copies recues: ' || count_copies_inserted, 'Procedure', 'Info');
  
EXCEPTION
  WHEN OTHERS THEN LOG_INFO('[RECEIPT_MOVIES] ' || SQLERRM, 'Procedure', 'Error'); ROLLBACK;
END RECEIPT_MOVIES;
/