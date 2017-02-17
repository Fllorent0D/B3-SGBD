--HEAD
create or replace PACKAGE AJOUT_PROG_PACKAGE AS 

  /* Information lié au cinéma */
  closing_time TIMESTAMP := TO_TIMESTAMP('23:00:00', 'HH24:MI:SS');
  opening_time TIMESTAMP := TO_TIMESTAMP('10:00:00', 'HH24:MI:SS');

  /* Variables internes */
  feedback XMLTYPE;

  /* Procédure et fonctions*/
  PROCEDURE AJOUT_ALL_PROG (path IN VARCHAR2);
  PROCEDURE AJOUT_PROG (filename IN VARCHAR2);
  PROCEDURE AJOUT_ERROR(idDemande IN VARCHAR2, message IN VARCHAR2);
  PROCEDURE GET_PROG_FILES(p_directory IN VARCHAR2); 
  FUNCTION VERIF_DISPONIBILITY(p_idMovie IN VARCHAR2, p_copy IN VARCHAR2, p_salle IN VARCHAR2, p_debut IN VARCHAR2, p_fin IN VARCHAR2, p_heure IN VARCHAR2, runtime IN VARCHAR2) RETURN BOOLEAN;
  PROCEDURE JOB_AJOUT_ALL_PROG;
  
END AJOUT_PROG_PACKAGE;
/

--BODY
create or replace PACKAGE BODY AJOUT_PROG_PACKAGE AS

PROCEDURE AJOUT_ALL_PROG (path IN VARCHAR2) AS
  TYPE prog_files_type IS TABLE OF PROG_FILES%ROWTYPE;
  prog_files_list prog_files_type;
  path_null_exp EXCEPTION;
  cpt INTEGER;
BEGIN
  IF(path IS NULL) THEN
    RAISE path_null_exp;
  END IF;

  GET_PROG_FILES(path); --Utilisation d'une table à cause du code Java
  
  SELECT COUNT(*) INTO cpt FROM PROG_FILES;
  
  DBMS_OUTPUT.PUT_LINE('NOMBRE DE FICHIERS: ' || CAST(cpt AS VARCHAR));
  
  SELECT * BULK COLLECT INTO prog_files_list FROM PROG_FILES;
  
  IF prog_files_list IS NOT NULL THEN
    FOR i IN prog_files_list.FIRST .. prog_files_list.LAST
    LOOP
      AJOUT_PROG(prog_files_list(i).FILENAME);
    END LOOP; 
  END IF;
  
  COMMIT;
  
EXCEPTION
  WHEN path_null_exp THEN RAISE_APPLICATION_ERROR('-20001', 'Veuillez indiquer le chemin du folder en paramètre');
  WHEN OTHERS THEN RAISE; ROLLBACK;
END AJOUT_ALL_PROG;

PROCEDURE AJOUT_PROG (filename IN VARCHAR2) AS
  TYPE demandes_type IS TABLE OF XMLTYPE INDEX BY BINARY_INTEGER;
  demandes demandes_type;
  count_rows NUMBER;

  filename_feedback VARCHAR2(255);
  file utl_file.file_type;

  idDemande VARCHAR2(255);
  idMovie VARCHAR2(255);
  numCopy VARCHAR2(255);
  debut VARCHAR2(255);
  fin VARCHAR2(255);
  salle VARCHAR(255);
  heure VARCHAR2(255);
  runtime VARCHAR(255);

  count_day INTEGER;
  temp_varchar VARCHAR2(255);
  idSeance VARCHAR2(255);
  filename_null_exp EXCEPTION;
  valid BOOLEAN := TRUE;
  projection XMLTYPE;
  seance XMLTYPE;
  time_compute TIMESTAMP;
  interval_compute INTERVAL day to second;
  date_compute DATE;
  date_compute_2 DATE;
  movie_valid BOOLEAN;
  date_valid BOOLEAN;
  can_check_disponibility BOOLEAN;
BEGIN

  /* Vérification du param */
  IF(filename IS NULL)
    THEN RAISE filename_null_exp;
  ELSE
    filename_feedback := CONCAT(SUBSTR(filename, 1, LENGTH(filename) - 4), '_feedback.xml');
    DBMS_OUTPUT.PUT_LINE('Nom du feedback: ' || filename_feedback);
    file := utl_file.fopen('MYDIR', filename_feedback,'w');
    utl_file.fclose(file);
  END IF;

  /* Initialisation du XML feedback */
  feedback := XMLTYPE('<feedback></feedback>');

  /* Récupération des demandes dans le directory */
  WITH demandes_with(value) AS(
    SELECT * FROM xmltable('programmation/demande'
    passing xmltype(BFILENAME('MYDIR', filename), nls_charset_id('AL32UTF8')))
  )
  SELECT * bulk collect into demandes FROM demandes_with;

  /* Loop vérification des demandes */
  FOR cpt IN demandes.FIRST .. demandes.LAST
  LOOP
    movie_valid := TRUE;
    date_valid := TRUE;
    can_check_disponibility := TRUE;
    
    /* idDemande */
    IF(demandes(cpt).EXTRACT('/demande/@idDemande') IS NULL) THEN
      SELECT INSERTCHILDXML(feedback, '/feedback', 'demande', XMLTYPE('<demande><idDemande>-1</idDemande><errors></errors></demande>')) INTO feedback FROM DUAL;
      AJOUT_ERROR('-1', 'Veuillez indiquer l''id de la demande');
      CONTINUE;
    ELSE
      idDemande := demandes(cpt).EXTRACT('/demande/@idDemande').getStringVal();
      SELECT INSERTCHILDXML(feedback, '/feedback', 'demande', XMLTYPE('<demande><idDemande>' || idDemande || '</idDemande><errors></errors></demande>')) INTO feedback FROM DUAL;
    END IF;
    
    /* Vérication de l'exsitence de la projection dans la BD*/
    SELECT COUNT(*) INTO count_rows FROM projections WHERE EXISTSNODE(OBJECT_VALUE, '/projection[idProjection="' || idDemande || '"]') = 1;
    
    IF(count_rows > 0) THEN
      AJOUT_ERROR(idDemande, 'Cette demande a déjà été ajoutée à la BD');
      CONTINUE;
    END IF;

    /* idMovie */
    IF(demandes(cpt).EXTRACT('demande/idMovie/text()') IS NULL) THEN
      AJOUT_ERROR(idDemande, 'Veuillez indiquer l''id du film');
      can_check_disponibility := FALSE;
        movie_valid := FALSE;
    ELSE
      idMovie := demandes(cpt).EXTRACT('demande/idMovie/text()').getStringVal();

      SELECT COUNT(*) INTO count_rows FROM movies WHERE EXISTSNODE(OBJECT_VALUE, '/movie[id="' || idMovie || '"]') = 1;
      
      IF(count_rows = 0) THEN
        AJOUT_ERROR(idDemande, 'Veuillez indiquer l''id d''un film existant');
        can_check_disponibility := FALSE;
        movie_valid := FALSE;
      END IF;
    END IF;

    /* debut */
    IF(demandes(cpt).EXTRACT('demande/debut/text()') IS NULL) THEN
      AJOUT_ERROR(idDemande, 'Veuillez indiquer la date de début');
      valid := FALSE;
    ELSE
      BEGIN
        debut := demandes(cpt).EXTRACT('demande/debut/text()').getStringVal();
        SELECT TO_DATE(debut, 'YYYY-MM-DD') INTO date_compute FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN date_valid := FALSE; can_check_disponibility := FALSE; AJOUT_ERROR(idDemande, 'Veuillez indiquer une date de début valide');
      END;
    END IF;

    /* fin */
    IF(demandes(cpt).EXTRACT('demande/fin/text()') IS NULL) THEN
      AJOUT_ERROR(idDemande, 'Veuillez indiquer la date de fin');
    ELSE
      BEGIN
        fin := demandes(cpt).EXTRACT('demande/fin/text()').getStringVal();
        SELECT TO_DATE(fin, 'YYYY-MM-DD') INTO date_compute FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN date_valid := FALSE; can_check_disponibility := FALSE; AJOUT_ERROR(idDemande, 'Veuillez indiquer une date de fin valide');
      END;
    END IF;

    /* Vérification cohérence date début et fin*/
    /*IF(date_valid = TRUE) THEN
      SELECT TO_DATE(debut, 'YYYY-MM-DD') INTO date_compute FROM DUAL;

      IF(date_compute <= CURRENT_DATE) THEN
        AJOUT_ERROR(idDemande, 'Veuillez indiquer une date postérieure au jour en cours');
      END IF;

      SELECT TO_DATE(fin, 'YYYY-MM-DD') INTO date_compute_2 FROM DUAL;

      IF(date_compute > date_compute_2) THEN
        AJOUT_ERROR(idDemande, 'Veuillez indiquer un interval d''au moins un jour de diffusion');
      END IF;
    END IF;*/

    /* heure */
    IF(demandes(cpt).EXTRACT('demande/debut/text()') IS NULL) THEN
      AJOUT_ERROR(idDemande, 'Veuillez indiquer une heure de diffusion');
    ELSE
      BEGIN
        heure := demandes(cpt).EXTRACT('demande/heure/text()').getStringVal();
        SELECT TO_TIMESTAMP(heure, 'HH24:MI:SS') INTO temp_varchar FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN can_check_disponibility := FALSE; AJOUT_ERROR(idDemande, SQLERRM);
      END;
    END IF;

    /* Vérification plage ouverture */
    IF(movie_valid) THEN
      SELECT NVL(EXTRACT(object_value, '/movie/runtime/text()').getstringval(), '150') INTO runtime
        FROM movies WHERE EXISTSNODE(OBJECT_VALUE, '/movie[id="' || idMovie || '"]') = 1;

      SELECT TO_TIMESTAMP(heure, 'HH24:MI:SS') INTO TIME_COMPUTE FROM DUAl;

      interval_compute := NUMTODSINTERVAL(runtime, 'MINUTE');

      IF((time_compute + interval_compute) > closing_time) THEN
        AJOUT_ERROR(idDemande, 'La diffusion du film dépasse l''heure de fermeture du cinéma');
      END IF;

      IF(time_compute < opening_time) THEN
        AJOUT_ERROR(idDemande, 'La diffusion du film précède l''heure d''ouverture du cinéma');
      END IF;
    END IF;

    /* numCopy */
    IF(movie_valid) THEN
      IF(demandes(cpt).EXTRACT('demande/numCopy/text()') IS NULL) THEN
        AJOUT_ERROR(idDemande, 'Veuillez indiquer le numero de la copie');
      ELSE
        numCopy := demandes(cpt).EXTRACT('demande/numCopy/text()').getStringVal();
  
        SELECT COUNT(*) INTO count_rows FROM copies
          WHERE EXISTSNODE(OBJECT_VALUE, '/copy[num="' || numCopy || '"]') = 1
          AND EXISTSNODE(OBJECT_VALUE, '/copy[movie="' || idMovie || '"]') = 1;
          
          DBMS_OUTPUT.PUT_LINE('Copie trouvee: ' || count_rows);
  
  
        IF(count_rows = 0) THEN
          AJOUT_ERROR(idDemande, 'La copie ' || numCopy || ' du film ' || idMovie || ' n''existe pas');
          can_check_disponibility := FALSE;
        END IF;
      END IF;
    END IF;


    /* salle */
    IF(demandes(cpt).EXTRACT('demande/salle/text()') IS NULL) THEN
      AJOUT_ERROR(idDemande, 'Veuillez indiquer une salle');
    ELSE
      salle := demandes(cpt).EXTRACT('demande/salle/text()').getStringVal();

      select count(*) into count_rows from salles where EXISTSNODE(OBJECT_VALUE, '/salle[numSalle="' || salle || '"]') = 1;

      IF(count_rows = 0) THEN
        can_check_disponibility := FALSE;
        AJOUT_ERROR(idDemande, 'Le numéro de salle ' || salle || ' n''exsite pas');
      END IF;
    END IF;

    /* Vérification disponibilite salle*/
    IF(can_check_disponibility = TRUE) THEN
      valid := VERIF_DISPONIBILITY(NULL, NULL, salle, debut, fin, heure, runtime);

      IF(valid = FALSE) THEN
        AJOUT_ERROR(idDemande, 'La salle est indisponible pour l''heure demandée');
      END IF;
    END IF;
    
    /* Vérification disponibilite copie*/
    IF(can_check_disponibility = TRUE) THEN
      valid := VERIF_DISPONIBILITY(idMovie, numCopy, NULL, debut, fin, heure, runtime);

      IF(valid = FALSE) THEN
        AJOUT_ERROR(idDemande, 'La copie est indisponible pour l''heure demandée');
      END IF;
    END IF;

    /* Vérification si demande possède des erreurs */
    count_rows := feedback.EXISTSNODE('/feedback/demande[idDemande="' || idDemande || '"]/errors/error');

    IF(count_rows > 0) THEN
      valid := FALSE;
      LOG_INFO('[AJOUT_PROG] La demande ' || idDemande || ' a été refusée', 'Procedure', 'Info');
    ELSE
      valid := true;
      LOG_INFO('[AJOUT_PROG] La demande ' || idDemande || ' a été accepté', 'Procedure', 'Info');
    END IF;

    /* Ajout de la demande dans la table projections si elle est valide */
    IF(valid = TRUE) THEN
      SELECT XMLElement("projection",
          XMLForest(
            idDemande AS "idProjection",
            idMovie AS "idMovie",
            salle AS "numSalle",
            numCopy AS "numCopy",
            debut AS "debut",
            fin AS "fin",
            heure AS "heure",
            '0' AS "archivee"
          )
        ) into projection
      FROM DUAL;
      
      INSERT INTO projections VALUES projection;
  
      SELECT (TO_DATE(fin, 'yyyy-MM-dd') - TO_DATE(debut, 'yyyy-MM-dd')) INTO count_day FROM DUAL;
      
      FOR cpt IN 0 .. count_day
      LOOP
        SELECT (TO_DATE(debut, 'yyyy-MM-dd')  + cpt) INTO date_compute FROM DUAL;
      
        /* Ajout des séances */
        SELECT XMLElement("seance",
            XMLForest(
              idDemande AS "idProjection",
              date_compute AS "dateSeance",
              '10' AS "nombreReservations"
            )
          ) INTO seance
        FROM DUAL;
        
        INSERT INTO seances VALUES seance;
        
        COMMIT;
      END LOOP;
    END IF;
  END LOOP;
  
  /* Copie du feedback XML dans un fichier*/
  DBMS_XSLPROCESSOR.CLOB2FILE(feedback.getClobVal(), 'MYDIR', filename_feedback, nls_charset_id('AL32UTF8'));
  
  LOG_INFO('[AJOUT_PROG] Envoie du feedback dans le directory', 'Procedure', 'Info');

EXCEPTION
  WHEN filename_null_exp THEN RAISE_APPLICATION_ERROR('-20001', 'Veuillez indiquer le nom du fichier en paramètre'); ROLLBACK;
  WHEN OTHERS THEN RAISE; ROLLBACK; IF utl_file.is_open(file) THEN utl_file.fclose(file); END IF;
END AJOUT_PROG;


PROCEDURE AJOUT_ERROR(idDemande IN VARCHAR2, message IN VARCHAR2) AS
  count_rows NUMBER;
BEGIN

  /* On ajoute l'erreur au feedback XML */
  SELECT INSERTCHILDXML(feedback, 'feedback/demande[idDemande=' || idDemande || ']/errors', 'error', XMLTYPE('<error>' || message || '</error>')) INTO feedback FROM DUAL;

END AJOUT_ERROR;


PROCEDURE GET_PROG_FILES(p_directory IN VARCHAR2) AS
LANGUAGE JAVA NAME 'ProgUtils.listFromDirectory( java.lang.String )';


FUNCTION VERIF_DISPONIBILITY(p_idMovie IN VARCHAR2, p_copy IN VARCHAR2, p_salle IN VARCHAR2, p_debut IN VARCHAR2, p_fin IN VARCHAR2, p_heure IN VARCHAR2, runtime IN VARCHAR2)
RETURN BOOLEAN
AS
  id_movie_current VARCHAR2(255);
  debut_current DATE;
  fin_current DATE;
  heure_debut_current TIMESTAMP;
  heure_fin_current TIMESTAMP;
  runtime_current VARCHAR2(255);

  debut DATE;
  fin DATE;
  heure_debut TIMESTAMP;
  heure_fin TIMESTAMP;

  TYPE projections_type IS TABLE OF XMLTYPE INDEX BY PLS_INTEGER;
  projections projections_type;
  varchar_temp VARCHAR(255);

  interval_compute INTERVAL DAY TO SECOND;

  disponible BOOLEAN := TRUE;
  
  too_few_params_exp EXCEPTION;
BEGIN

  debut := TO_DATE(p_debut, 'YYYY-MM-DD');
  fin := TO_DATE(p_fin, 'YYYY-MM-DD');
  heure_debut := TO_TIMESTAMP(p_heure, 'HH24:MI:SS');

  interval_compute := NUMTODSINTERVAL(runtime, 'MINUTE');

  heure_fin := heure_debut + interval_compute;

  /* Récupération des projections existante */
  IF(p_salle IS NULL) THEN
    IF(p_copy IS NULL OR p_idMovie IS NULL) THEN
      RAISE too_few_params_exp;
    ELSE
      SELECT * BULK COLLECT INTO projections FROM projections
        WHERE EXISTSNODE(OBJECT_VALUE, '/projection[idMovie="' || p_idMovie || '"]') = 1 AND EXISTSNODE(OBJECT_VALUE, '/projection[numCopy="' || p_copy || '"]') = 1;
    END IF;
  ELSE
    SELECT * BULK COLLECT INTO projections FROM projections
      WHERE EXISTSNODE(OBJECT_VALUE, '/projection[numSalle="' || p_salle || '"]') = 1;
  END IF;
  
  IF(projections.COUNT > 0) THEN

    FOR cpt IN projections.FIRST .. projections.LAST
    LOOP
      /* Récuperation des champs de la projection en DB */
      debut_current := TO_DATE(projections(cpt).EXTRACT('/projection/debut/text()').getstringval(), 'YYYY-MM-DD');
      fin_current := TO_DATE(projections(cpt).EXTRACT('/projection/fin/text()').getstringval(), 'YYYY-MM-DD');
      heure_debut_current := TO_TIMESTAMP(projections(cpt).EXTRACT('/projection/heure/text()').getstringval(), 'HH24:MI:SS.FF');
      id_movie_current := projections(cpt).EXTRACT('/projection/idMovie/text()').getstringval();
      varchar_temp := projections(cpt).EXTRACT('/projection/heure/text()').getstringval();

      /* Calcul de l'heure de fin */
      SELECT NVL(EXTRACT(object_value, '/movie/runtime/text()').getstringval(), '150') INTO runtime_current
        FROM movies WHERE EXISTSNODE(OBJECT_VALUE, '/movie[id="' || id_movie_current || '"]') = 1;

      interval_compute := NUMTODSINTERVAL(runtime_current, 'MINUTE');
      heure_fin_current := heure_debut_current + interval_compute;

      /* Vérification que la salle soit libre à l'horaire prévu de la projection */
      IF((debut >= debut_current AND debut <= fin_current) OR (fin >= debut_current AND fin <= fin_current)) THEN
        IF((heure_debut >= heure_debut_current AND heure_debut <= heure_fin_current) OR (heure_fin >= heure_debut_current AND heure_fin <= heure_fin_current)) THEN
          disponible := FALSE; EXIT;
        END IF;
      END IF;
      
    END LOOP;
  END IF;

  RETURN disponible;
EXCEPTION
  WHEN too_few_params_exp THEN RAISE_APPLICATION_ERROR('-20001', 'Veuillez indiquer une salle ou une copie');
  WHEN OTHERS THEN RAISE;
END VERIF_DISPONIBILITY;


PROCEDURE JOB_AJOUT_ALL_PROG AS
BEGIN
  LOG_INFO('[JOB] Execution du job', 'AJOUT_PROG_PACKAGE', 'Info');
  AJOUT_PROG_PACKAGE.AJOUT_ALL_PROG('/home/oracle/sgbd');
EXCEPTION
  WHEN OTHERS THEN LOG_INFO('[JOB] ' || SQLERRM, 'AJOUT_PROG_PACKAGE', 'Error'); ROLLBACK;
END JOB_AJOUT_ALL_PROG;

END AJOUT_PROG_PACKAGE;
/