DECLARE
ids ALIMCBPACKAGE.MoviesIdsTable;
BEGIN
  /* Auncun id correct */
  --ids := ALIMCBPACKAGE.MoviesIdsTable(1, 4);

  /* id = 3 existe mais pas les autres => warning dans les logs et l'import pour le 3*/
  --ids := ALIMCBPACKAGE.MoviesIdsTable(1, 3, 4);

  /* liste ids vide */
  --ids := ALIMCBPACKAGE.MoviesIdsTable();

  /*  liste correct */
  ids := ALIMCBPACKAGE.MoviesIdsTable(20, 21, 22, 23, 24, 25);
  

  ALIMCBPACKAGE.ALIMCB(ids);

  /* Erreurs de paramètres */
  --ALIMCBPACKAGE.ALIMCB(0);
  --ALIMCBPACKAGE.ALIMCB(-1);


  /* Correct */
  ALIMCBPACKAGE.ALIMCB(10);



EXCEPTION 
	WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;