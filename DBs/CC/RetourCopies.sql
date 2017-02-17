create or replace PROCEDURE RETOUR_COPIES AS 
  TYPE projections_type IS TABLE OF XMLType INDEX BY BINARY_INTEGER;
  projections projections_type;
  
  idMovie VARCHAR2(255);
  numCopy VARCHAR2(255);
  fin VARCHAR2(255);
  dateCompute NUMBER;
  integerCompute NUMBER;
  
  copy XMLTYPE;
BEGIN
  /* Sélectionnez les copies à retourner */
  SELECT * BULK COLLECT INTO projections
  FROM projections 
  WHERE FLOOR((CURRENT_DATE - TO_DATE(EXTRACTVALUE(OBJECT_VALUE, '/projection/fin'), 'yyyy-MM-dd'))) > 0;

  IF(projections IS NOT NULL) THEN
    FOR cpt IN projections.FIRST .. projections.LAST LOOP
      idMovie := projections(cpt).EXTRACT('/projection/idMovie/text()').getstringval();
      numCopy := projections(cpt).EXTRACT('/projection/numCopy/text()').getstringval();
 
      SELECT COUNT(*) INTO integerCompute
      FROM com_retour_copies
      WHERE EXISTSNODE(OBJECT_VALUE, 'copy[movie="' || idMovie || '"]') = 1
      AND EXISTSNODE(OBJECT_VALUE, 'copy[num="' || numCopy || '"]') = 1;
  
      IF(integerCompute > 0) THEN
        CONTINUE;
      END IF;
  
      SELECT * INTO copy
      FROM copies
      WHERE EXISTSNODE(OBJECT_VALUE, 'copy[movie="' || idMovie || '"]') = 1
      AND EXISTSNODE(OBJECT_VALUE, 'copy[num="' || numCopy || '"]') = 1;
      
      INSERT INTO com_retour_copies VALUES copy;
      
      DELETE FROM projections 
      WHERE EXISTSNODE(OBJECT_VALUE, 'projection[idMovie="' || idMovie || '"]') = 1
      AND EXISTSNODE(OBJECT_VALUE, 'projection[numCopy="' || numCopy || '"]') = 1;
      
      DELETE FROM copies 
      WHERE EXISTSNODE(OBJECT_VALUE, 'copy[movie="' || idMovie || '"]') = 1
      AND EXISTSNODE(OBJECT_VALUE, 'copy[num="' || numCopy || '"]') = 1;
      
    END LOOP;
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN RAISE;
END RETOUR_COPIES;

/
