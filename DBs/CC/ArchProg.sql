create or replace PROCEDURE ARCH_PROG(dateTest DATE := NULL) AS 
  TYPE varchar2_collection_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  TYPE xmltype_collection_type IS TABLE OF XMLTYPE INDEX BY BINARY_INTEGER;
  
  idMovies varchar2_collection_type;
  projections xmltype_collection_type;
  
  archivage XMLTYPE;
  
  placesVendues INTEGER;
  perennite INTEGER;
  nbrCopies INTEGER;
  
  isNew BOOLEAN;
  integerCompute INTEGER;
  debut VARCHAR2(255);
  
  archiveDate DATE; -- Garder la possibilité d'effectuer des tests
BEGIN

  LOG_INFO('[JOB] Exécution de l''archivage des projections', 'ARCH_PROG', 'message');

  IF(dateTest IS NOT NULL) THEN
    archiveDate := dateTest;
  ELSE
    archiveDate := CURRENT_DATE;
  END IF;
  
  archiveDate := archiveDate - 1;

  SELECT COUNT(*) INTO integerCompute FROM archivage_logs WHERE TO_DATE(date_execution, 'dd/MM/yy') = TO_DATE(archiveDate, 'dd/MM/yy');
  
  IF(integerCompute > 0) THEN
    RETURN;
  END IF;
  
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(archiveDate, 'dd/MM/yyyy'));

  /* Récupération des films en cours de projection pour la journée courante */
  SELECT DISTINCT EXTRACTVALUE(OBJECT_VALUE, 'projection/idMovie/text()') BULK COLLECT INTO idMovies  
  FROM projections
  WHERE TO_CHAR(archiveDate, 'dd/MM/yyyy') >= EXTRACTVALUE(OBJECT_VALUE, 'projection/debut/text()') AND TO_CHAR(archiveDate, 'dd/MM/yyyy') <= EXTRACTVALUE(OBJECT_VALUE, 'projection/fin/text()');

  DBMS_OUTPUT.PUT_LINE(idMovies.COUNT());

  /* Boucle sur les films pour effectuer leur archivage */
  IF(idMovies.COUNT() > 0) THEN
    FOR cpt IN idMovies.FIRST .. idMovies.LAST LOOP
    
      LOG_INFO('[JOB] Analyse des projections du film: ' || idMovies(cpt) || '...', 'ARCH_PROG', 'message');

      BEGIN
        SELECT * INTO archivage FROM archivages
        WHERE EXISTSNODE(OBJECT_VALUE, 'archivage[idMovie="' || idMovies(cpt) || '"]') = 1;

        isNew := FALSE;
        placesVendues := archivage.EXTRACT('archivage/placesVendues/text()').getstringval();
        perennite := archivage.EXTRACT('archivage/perennite/text()').getstringval();
        nbrCopies := archivage.EXTRACT('archivage/nbrCopies/text()').getstringval();
      EXCEPTION
        WHEN NO_DATA_FOUND THEN placesVendues := 0; perennite := 0; nbrCopies := 0; isNew := TRUE;
        WHEN OTHERS THEN RAISE;
      END;
      
      SELECT * BULK COLLECT INTO projections 
      FROM projections 
      WHERE EXISTSNODE(OBJECT_VALUE, 'projection[idMovie="' || idMovies(cpt) || '"]') = 1;
      
      /* Mise à jour de la pérénnité */
      perennite := perennite + 1;
      
      /* Mise à jour des places vendues */
      FOR cpt2 IN projections.FIRST .. projections.LAST LOOP
        SELECT SUM(EXTRACTVALUE(OBJECT_VALUE, 'seance/nombreReservations')) INTO integerCompute 
        FROM seances
        WHERE EXISTSNODE(OBJECT_VALUE, 'seance[idProjection="' || projections(cpt2).EXTRACT('projection/idProjection/text()').getstringval() || '"]') = 1
        AND EXISTSNODE(OBJECT_VALUE, 'seance[dateSeance="' || TO_CHAR(archiveDate, 'yyyy-MM-dd') || '"]') = 1;
   
        IF(integerCompute IS NOT NULL) THEN
          placesVendues := placesVendues + integerCompute;
        END IF;
      END LOOP;
      
      /* Mise à jour du nombre de copies utilisées */
      FOR cpt2 IN projections.FIRST .. projections.LAST LOOP
        debut := projections(cpt2).EXTRACT('/projection/debut/text()').getstringval();
        SELECT FLOOR(archiveDate - TO_DATE(debut, 'yyyy-MM-dd')) INTO integerCompute FROM DUAL;
              
        IF(integerCompute = 0) THEN
          nbrCopies := nbrCopies + 1;
        END IF;
      END LOOP;
      
      /* Génération du document XML d'archivage */
      SELECT XMLElement("archivage",
          XMLForest(
            idMovies(cpt) AS "idMovie",
            perennite AS "perennite",
            placesVendues AS "placesVendues",
            nbrCopies AS "nbrCopies"
          )
        ) INTO archivage
      FROM DUAL;
    
      /* Sauvegarde de l'archivage */
      IF isNew THEN
        INSERT INTO archivages VALUES archivage;
      ELSE
        UPDATE archivages SET object_value = archivage WHERE EXISTSNODE(OBJECT_VALUE, 'archivage[idMovie="' || idMovies(cpt) || '"]') = 1;
      END IF;
    
    END LOOP;
    
    INSERT INTO archivage_logs (date_execution) VALUES(archiveDate);
    
    COMMIT;
    
    LOG_INFO('[JOB] Enregistrement des archives', 'ARCH_PROG', 'message');
    
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN LOG_INFO('[JOB] ' || SQLERRM, 'ARCH_PROG', 'Error'); ROLLBACK;
END ARCH_PROG;
/