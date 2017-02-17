/* HEAD */
create or replace PACKAGE ALIMCCPACKAGE AS 

  PROCEDURE PREPARE_MOVIE_TO_COPY(idMovie IN NUMBER);
  PROCEDURE JOB;
  
END ALIMCCPACKAGE;
/


/* BODY */
create or replace PACKAGE BODY ALIMCCPACKAGE AS
  PROCEDURE PREPARE_MOVIE_TO_COPY(idMovie IN NUMBER)
  AS
    nbrCopyAvailable NUMBER;
    nbrCopyToSend NUMBER;
    movie_xml XMLTYPE;
    copy_xml XMLTYPE;
  
    TYPE copy_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    copies copy_table;
  
    i NUMBER;
    j NUMBER;
    
    ID_MOVIE_NULL_EXCP EXCEPTION;
  BEGIN
  
    IF idMovie IS NULL
      THEN RAISE ID_MOVIE_NULL_EXCP;
    END IF;
  
      /* Nombre de copies disponibles pour le film */
    SELECT COUNT(*) INTO nbrCopyAvailable FROM MOVIE_COPIES WHERE MOVIE = idMovie;
  
    /* Nombre de copies sélectionné selon une distribution uniforme de 0 à N/2 */
    nbrCopyToSend := FLOOR(DBMS_RANDOM.VALUE(0, nbrCopyAvailable/2));
    
    LOG_INFO('[PREPARE_MOVIE_TO_COPY] ID_MOVIE: '|| idMovie ||'; AVAILABLE COPIES: '|| nbrCopyAvailable ||'; COPIES TO SEND: ' || nbrCopyToSend, 'AlimCC', 'Info');

    IF nbrCopyToSend > 0 THEN
  
      /* Création du schéma XML */
      SELECT XMLElement("movie",
        XMLForest(
          ID as "id",
          TITLE as "title",
          ORIGINAL_TITLE as "original_title",
          TO_CHAR(RELEASE_DATE, 'YYYY/MM/DD') AS "release_date", 
          (SELECT XMLForest(id AS "id", name AS "name", description AS "description")
            FROM status
            WHERE id = m.status
          ) AS "status",
          REPLACE(VOTE_AVERAGE,',','.') as "vote_average",
          VOTE_COUNT as "vote_count",     
          (SELECT XMLForest(id AS "id", name AS "name", description AS "description")
            FROM certification
            WHERE id = m.certification
          ) AS "certification",
          (SELECT poster FROM poster where movie = idMovie) AS "poster",
          RUNTIME as "runtime",
          BUDGET as "budget",
          TAGLINE as "tagline"
        ),
        XMLElement("genres", 
          (SELECT XMLAgg(XMLElement("genre", XMLForest(GENRE.ID AS "id", GENRE.NAME AS "name"))) 
            FROM MOVIE
            INNER JOIN MOVIE_GENRE ON MOVIE_GENRE.MOVIE = MOVIE.ID
            INNER JOIN GENRE ON MOVIE_GENRE.GENRE = GENRE.ID
            WHERE MOVIE.ID = idMovie
          )
        ),
        XMLElement("actors",
          (SELECT XMLAgg(XMLElement("actor", XMLForest(ARTIST.ID AS "id", ARTIST.NAME AS "name", MOVIE_ACTOR.ROLE AS "role")))
            FROM MOVIE
            INNER JOIN MOVIE_ACTOR ON MOVIE_ACTOR.MOVIE = MOVIE.ID
            INNER JOIN ARTIST ON MOVIE_ACTOR.ACTOR = ARTIST.ID
            WHERE MOVIE.ID = idMovie
          )
        ),
        XMLElement("directors",
          (SELECT XMLAgg(XMLElement("director", XMLForest(ARTIST.ID AS "id")))
            FROM MOVIE
            INNER JOIN MOVIE_DIRECTOR ON MOVIE_DIRECTOR.MOVIE = MOVIE.ID
            INNER JOIN ARTIST ON MOVIE_DIRECTOR.DIRECTOR = ARTIST.ID
            WHERE MOVIE.ID = idMovie
          )
        )
      ) 
      into movie_xml
      from movie m
      where id = idMovie; 
        
      /* Sélection des copies effectives à envoyer */
      SELECT NUM_COPY BULK COLLECT INTO copies
      FROM MOVIE_COPIES
      WHERE MOVIE = idMovie
      AND ROWNUM <= nbrCopyToSend;
      


      INSERT INTO COM_MOVIES VALUES(movie_xml);
    
      FOR i IN copies.FIRST .. copies.LAST LOOP
   
        SELECT XMLElement("copy",
          XMLForest(
            movie AS "movie",
            num_copy AS "num"
          )
        )
        INTO copy_xml
        FROM MOVIE_COPIES
        WHERE MOVIE = idMovie
        AND NUM_COPY = copies(i);
    
        INSERT INTO COM_COPIES VALUES(copy_xml);
        DELETE FROM MOVIE_COPIES WHERE MOVIE = idMovie AND NUM_COPY = copies(i);
      END LOOP;
      
    END IF;
  
  EXCEPTION
    WHEN ID_MOVIE_NULL_EXCP THEN LOG_INFO('[PREPARE_MOVIE_TO_COPY] Veuillez indiquer un id de film non null', 'AlimCC', 'Error');
    WHEN OTHERS THEN LOG_INFO('[PREPARE_MOVIE_TO_COPY] ' || SQLERRM, 'AlimCC', 'Error');
  END;
  
  PROCEDURE JOB
  AS
    movieRow MOVIE%ROWTYPE;
    i number;
  BEGIN
  
    LOG_INFO('[JOB] Execution du job', 'AlimCC', 'Info');
    
    FOR movieRow IN (SELECT * FROM MOVIE) LOOP
      PREPARE_MOVIE_TO_COPY(movieRow.id);
    END LOOP;
      
    RECEIPT_MOVIES@CC_LINK;
    
    /* Retour copies */
    ARCH_PROG@CC_LINK;
    RETOUR_COPIES@CC_LINK;
    RECEIPTION_RETOUR_COPIES;

    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN LOG_INFO('[JOB] ' || SQLERRM, 'AlimCC', 'Error'); ROLLBACK;
  END;
  

END ALIMCCPACKAGE;
/