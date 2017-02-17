create or replace package AlimCBPackage as  

    /* Longueur des datas */
    TYPE DataLengthRecord IS RECORD (
      ColName     user_tab_columns.COLUMN_NAME%type, 
      ColType     user_tab_columns.DATA_TYPE%type, 
      ColLength    user_tab_columns.DATA_LENGTH%type);
    Type DataLengthTable IS TABLE OF DataLengthRecord INDEX BY BINARY_INTEGER;
    DataLength DataLengthTable;
    
    /* Charger les acteurs/genres/producteurs */
    
    /* */
    TYPE MoviesExtTable is table of movies_ext%rowtype;

    /* Args */
    TYPE MoviesIdsTable is table of movies_ext.id%type;
    MoviesIds MoviesIdsTable;
    /* */
    
 
 
    /* Procedures */
    PROCEDURE SANITIZE_FIELDS(movieextrow IN OUT NOCOPY movies_ext%rowtype);
    PROCEDURE SANITIZE_ACTEURS(actorsrow IN OUT NOCOPY owa_text.vc_arr);
    PROCEDURE SANITIZE_GENRES(genresrow IN OUT NOCOPY owa_text.vc_arr);
    PROCEDURE SANITIZE_PRODUCTEURS(directorsrow IN OUT NOCOPY owa_text.vc_arr);

    PROCEDURE IMPORTCB(Movies IN  MoviesExtTable);

    PROCEDURE ALIMCB(Movies IN MoviesIdsTable);
    PROCEDURE ALIMCB(NombreMovie In Number);
    
end AlimCBPackage;
/
create or replace PACKAGE BODY ALIMCBPACKAGE AS
  PROCEDURE SANITIZE_FIELDS(movieextrow IN OUT NOCOPY movies_ext%rowtype) AS
    E_NoMovieTable Exception;
  BEGIN
    SELECT CASE WHEN table_name = 'MOVIE' THEN column_name ELSE table_name END, data_type, CASE WHEN data_type = 'VARCHAR2' THEN DATA_LENGTH ELSE DATA_precision END
    BULK COLLECT INTO DataLength
    FROM user_tab_columns
    WHERE 
    ((table_name = 'MOVIE' and column_name NOT IN ('STATUS', 'NBRCOPIE', 'CERTIFICATION'))OR ((table_name IN ('STATUS', 'CERTIFICATION')) and column_name = 'NAME')) 
    and data_type <> 'DATE';
      
    if datalength.count = 0 THEN
      Raise E_NoMovieTable;
    end if;
    
    for i IN 1..DataLength.count LOOP
  
      CASE DataLength(i).ColName
        WHEN 'ID' THEN --n
          IF length(movieextrow.id) > DataLength(i).ColLength then
              LOG_info('[SANITIZE]ID : '||movieextrow.id||'. Col : '|| DataLength(i).ColName || '. Précision attendue : ' || DataLength(i).ColLength || ' | Valeur original : ' || movieextrow.id || ' | Nouvelle valeur : NULL' , 'AlimCB', 'Info');
              movieextrow.id := null;
            END IF;
            
            
        WHEN 'TITLE' THEN 
          IF LENGTH(movieextrow.title) > DataLength(i).ColLength THEN --Check la longueur
              LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : ' || DataLength(i).ColName || '. Longueur de la chaine réduite de ' || LENGTH(movieextrow.title) - DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
              movieextrow.title := SUBSTR(movieextrow.title,0,DataLength(i).ColLength);
          END IF;
          movieextrow.title := regexp_replace(movieextrow.title ,'^\s+|$\s+', '');
          
        WHEN 'ORIGINAL_TITLE' THEN 
          IF LENGTH(movieextrow.original_title) > DataLength(i).ColLength THEN --Check la longueur
              LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : ' || DataLength(i).ColName || '. Longueur de la chaine réduite de ' || LENGTH(movieextrow.original_title) - DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
              movieextrow.original_title := SUBSTR(movieextrow.original_title,0,DataLength(i).ColLength);
          END IF;
          movieextrow.original_title := regexp_replace(movieextrow.original_title ,'^\s+|$\s+', '');
        
        
        WHEN 'STATUS' THEN 
          IF LENGTH(movieextrow.status) > DataLength(i).ColLength THEN --Check la longueur
                LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : ' || DataLength(i).ColName || '. Longueur de la chaine réduite de ' || LENGTH(movieextrow.status) - DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
                movieextrow.status := SUBSTR(movieextrow.status,0,DataLength(i).ColLength);
          END IF;
          
          
        WHEN 'VOTE_AVERAGE' THEN 
            if movieextrow.vote_average < 0 then
              movieextrow.vote_average := 0;
              LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : '|| DataLength(i).ColName || '. Valeur négative reçue. Nouvelle valeur : 0.', 'AlimCB', 'Info');
            ELSIF length(floor(movieextrow.vote_average)) > DataLength(i).ColLength then
              LOG_info('[SANITIZE]ID : '||movieextrow.id||'. Col : '|| DataLength(i).ColName || '. Précision attendue : ' || DataLength(i).ColLength || ' | Valeur original : ' || movieextrow.vote_average || ' | Nouvelle valeur : 0' , 'AlimCB', 'Info');
              movieextrow.vote_average := 0;
              movieextrow.vote_count := 0;
            END IF;
        
        
        WHEN 'VOTE_COUNT' THEN 
            if movieextrow.vote_count < 0 then
              movieextrow.vote_count := 0;
              movieextrow.vote_average := 0;
              LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : '|| DataLength(i).ColName || '. Valeur négative reçue. Nouvelle valeur : 0.', 'AlimCB', 'Info');
            ELSIF length(movieextrow.vote_count) > DataLength(i).ColLength then
              LOG_info('[SANITIZE]ID : '||movieextrow.id||'. Col : '|| DataLength(i).ColName || '. Précision attendue : ' || DataLength(i).ColLength || ' | Valeur original : ' || movieextrow.vote_count || ' | Nouvelle valeur : 0' , 'AlimCB', 'Info');
              movieextrow.vote_count := 0;
              movieextrow.vote_average := 0;

            END IF;
        
        
        
        WHEN 'CERTIFICATION' THEN
          IF LENGTH(movieextrow.certification) > DataLength(i).ColLength THEN --Check la longueur
                LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : ' || DataLength(i).ColName || '. Longueur de la chaine réduite de ' || LENGTH(movieextrow.certification) - DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
                movieextrow.certification := SUBSTR(movieextrow.certification,0,DataLength(i).ColLength);
          END IF;
        
        
        
        WHEN 'RUNTIME' THEN 
          if movieextrow.runtime <= 0 then
            movieextrow.runtime := NULL;
            LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : '|| DataLength(i).ColName || '. Valeur négative ou égale à 0 reçue. Nouvelle valeur : NULL.', 'AlimCB', 'Info');
          ELSIF length(movieextrow.runtime) > DataLength(i).ColLength then
            LOG_info('[SANITIZE]ID : '||movieextrow.id||'. Col : '|| DataLength(i).ColName || '. Précision attendue : ' || DataLength(i).ColLength || '. Valeur original : ' || movieextrow.runtime || '. Nouvelle valeur : NULL' , 'AlimCB', 'Info');
            movieextrow.runtime := null;
          END IF;
        
        
        
        WHEN 'BUDGET' THEN 
          if movieextrow.budget <= 0 then
            movieextrow.budget := NULL;
            LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : '|| DataLength(i).ColName || '. Valeur négative ou égale à 0 reçue. Nouvelle valeur : NULL.', 'AlimCB', 'Info');
          ELSIF length(movieextrow.budget) > DataLength(i).ColLength then
              LOG_info('[SANITIZE]ID : '||movieextrow.id||'. Col : '|| DataLength(i).ColName || '. Précision attendue : ' || DataLength(i).ColLength || '. Valeur original : ' || movieextrow.budget || '. Nouvelle valeur : NULL' , 'AlimCB', 'Info');
              movieextrow.budget := null;
          END IF;
        
        
        
        WHEN 'POSTER_PATH' THEN 
          IF LENGTH(movieextrow.poster_path) > DataLength(i).ColLength THEN --Check la longueur
                movieextrow.poster_path := SUBSTR(movieextrow.poster_path,0,DataLength(i).ColLength);
                LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : ' || DataLength(i).ColName || '. Longueur de la chaine réduite à ' || DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
          END IF;
        
        
        
        WHEN 'TAGLINE' THEN 
          IF LENGTH(movieextrow.tagline) > DataLength(i).ColLength THEN --Check la longueur
                movieextrow.tagline := SUBSTR(movieextrow.tagline,0,DataLength(i).ColLength);
                LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : ' || DataLength(i).ColName || '. Longueur de la chaine réduite à ' || DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
          END IF;
          movieextrow.tagline := regexp_replace(movieextrow.tagline ,'^\s+|$\s+', '');
        
        ELSE 
          LOG_INFO('[SANITIZE]ID : '||movieextrow.id||'. Col : ' || DataLength(i).ColName || '. Colonne existante dans la table movie mais non netoyée' , 'AlimCB', 'Info');
          
      END CASE;
    
    END LOOP; 
    
    
    EXCEPTION
      WHEN E_NoMovieTable THEN 
        RAISE_APPLICATION_ERROR(-20001, 'La table Movie n''existe pas ou n''a aucune colonne');
        LOG_INFO('[SANITIZE]Aucune colonne dans la table Movie' , 'AlimCB', 'Error');

  
  END SANITIZE_FIELDS;
  
PROCEDURE SANITIZE_ACTEURS(actorsrow IN OUT NOCOPY owa_text.vc_arr) AS
  BEGIN
     --Récupère les tailles des cols
     SELECT column_name,
            data_type, 
            CASE WHEN data_type = 'VARCHAR2' 
              THEN DATA_LENGTH 
              ELSE DATA_precision 
            END
     BULK COLLECT INTO DataLength
     FROM user_tab_columns
     WHERE (table_name = 'ARTIST') OR 
           (table_name = 'MOVIE_ACTOR' AND column_name='ROLE');
    
     for i IN 1..DataLength.count LOOP
       CASE DataLength(i).ColName
          WHEN 'ID' THEN --n
            IF length(actorsrow(1)) > DataLength(i).ColLength then
                LOG_info('[SANITIZE]ID ACTEUR : '||actorsrow(1)||' | Col : '|| DataLength(i).ColName || '| Précision attendue : ' || DataLength(i).ColLength || ' | Valeur original : ' || actorsrow(1) || ' | Nouvelle valeur : NULL' , 'AlimCB', 'Info');
                actorsrow(1) := null;
              END IF;
              
          WHEN 'NAME' THEN 
            IF LENGTH(actorsrow(2)) > DataLength(i).ColLength THEN --Check la longueur
                LOG_INFO('[SANITIZE]ID ACTEUR : '||actorsrow(1)||' | Col : ' || DataLength(i).ColName || ' | Longueur de la chaine réduite de ' || LENGTH(actorsrow(2)) - DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
                actorsrow(2) := SUBSTR(actorsrow(2),0,DataLength(i).ColLength);
            END IF;
            actorsrow(2) := regexp_replace(actorsrow(2) ,'^\s+|$\s+', '');

          WHEN 'ROLE' THEN 
            IF LENGTH(actorsrow(3)) > DataLength(i).ColLength THEN --Check la longueur
                LOG_INFO('[SANITIZE]ID ACTEUR : '||actorsrow(1)||' | Col : ' || DataLength(i).ColName || ' | Longueur de la chaine réduite de ' || LENGTH(actorsrow(3)) - DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
                actorsrow(3) := SUBSTR(actorsrow(3),0,DataLength(i).ColLength);
            END IF;
            actorsrow(3):= regexp_replace(actorsrow(3) ,'^\s+|$\s+', '');

        END CASE;
      end loop;
  END SANITIZE_ACTEURS;

  PROCEDURE SANITIZE_GENRES(genresrow IN OUT NOCOPY owa_text.vc_arr) AS
  BEGIN
     --Récupère les tailles des cols
     SELECT column_name,
            data_type, 
            CASE WHEN data_type = 'VARCHAR2' 
              THEN DATA_LENGTH 
              ELSE Data_Precision 
            END
     BULK COLLECT INTO DataLength
     FROM   user_tab_columns
     WHERE  table_name = 'GENRE';
      
     for i IN 1..DataLength.count LOOP
       CASE DataLength(i).ColName
          WHEN 'ID' THEN --n
            IF length(genresrow(1)) > DataLength(i).ColLength then
                LOG_info('[SANITIZE]ID GENRE : '||genresrow(1)||' | Col : '|| DataLength(i).ColName || '| Précision attendue : ' || DataLength(i).ColLength || ' | Valeur original : ' || genresrow(1) || ' | Nouvelle valeur : NULL' , 'AlimCB', 'Info');
                genresrow(1) := null;
              END IF;
              
          WHEN 'NAME' THEN 
            IF LENGTH(genresrow(2)) > DataLength(i).ColLength THEN --Check la longueur
                LOG_INFO('[SANITIZE]ID GENRE : '||genresrow(1)||' | Col : ' || DataLength(i).ColName || ' | Longueur de la chaine réduite de ' || LENGTH(genresrow(2)) - DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
                genresrow(2) := SUBSTR(genresrow(2),0,DataLength(i).ColLength);
            END IF;
            genresrow(2) := regexp_replace(genresrow(2) ,'^\s+|$\s+', '');

        
        END CASE;
      end loop;
  END SANITIZE_GENRES;

  PROCEDURE SANITIZE_PRODUCTEURS(directorsrow IN OUT NOCOPY owa_text.vc_arr) AS
  BEGIN
     --Récupère les tailles des cols
     SELECT column_name,
            data_type, 
            CASE WHEN data_type = 'VARCHAR2' THEN DATA_LENGTH ELSE Data_Precision END
     BULK COLLECT INTO DataLength
     FROM   user_tab_columns
     WHERE  table_name = 'ARTIST';
     
      for i IN 1..DataLength.count LOOP
       CASE DataLength(i).ColName
          WHEN 'ID' THEN --n
            IF length(directorsrow(1)) > DataLength(i).ColLength then
                LOG_info('[SANITIZE]ID Artist : '||directorsrow(1)||' | Col : '|| DataLength(i).ColName || '| Précision attendue : ' || DataLength(i).ColLength || ' | Valeur original : ' || directorsrow(1) || ' | Nouvelle valeur : NULL' , 'AlimCB', 'Info');
                directorsrow(1) := null;
              END IF;
              
          WHEN 'NAME' THEN 
            IF LENGTH(directorsrow(2)) > DataLength(i).ColLength THEN --Check la longueur
                LOG_INFO('[SANITIZE]ID Artist : '||directorsrow(1)||' | Col : ' || DataLength(i).ColName || ' | Longueur de la chaine réduite de ' || LENGTH(directorsrow(2)) - DataLength(i).ColLength || ' caractères.' , 'AlimCB', 'Info');
                directorsrow(2) := SUBSTR(directorsrow(2),0,DataLength(i).ColLength);
            END IF;
            directorsrow(2) := regexp_replace(directorsrow(2) ,'^\s+|$\s+', '');
        
        END CASE;
      end loop;
     
  END SANITIZE_PRODUCTEURS;  
  
  
  PROCEDURE IMPORTCB(Movies IN  MoviesExtTable) AS
  currentRow movies_ext%rowtype;
  newMovieRow movie%rowtype;
  alreadySavedRow movie%rowtype;
  Genres ANALYSECIPACKAGE.GenresTable;
  acteurs ANALYSECIPACKAGE.acteurstable;
  producteurs ANALYSECIPACKAGE.producteurstable;
  certificat certification%rowtype;
  statusRow status%rowtype;
  
  moviegenreRow movie_genre%rowtype;
  movieactorrow movie_actor%rowtype;
  moviedirector movie_director%rowtype;
  alreadySave boolean := false;
  E_Verrou Exception;
  PRAGMA EXCEPTION_INIT(E_Verrou, -00054);
  try number;
  nbrcopie number;
  BEGIN
   
  
  
   for j in 1 .. Movies.count loop
    BEGIN
      currentRow := movies(j);
      LOG_INFO('[IMPORT]Début du traitement du film '||currentRow.id, 'AlimCB', 'Info');

      SANITIZE_FIELDS(currentRow);
      
      
      newMovieRow.id := currentRow.id;
      newMovieRow.title := currentRow.title;
      newMovieRow.original_title := currentRow.original_title;
      newMovieRow.release_date := currentRow.release_date;
      newMovieRow.vote_average := currentRow.vote_average;
      newMovieRow.vote_count := currentRow.vote_count;
      newMovieRow.runtime := currentRow.runtime;
      newMovieRow.budget := currentRow.budget;
      --newMovieRow.poster_path := currentRow.poster_path;
      newMovieRow.tagline := currentRow.tagline;
      nbrcopie := FLOOR(dbms_random.normal * 2 + 5);
      
      try := 1;
      WHILE try <= 3
      LOOP
        BEGIN
          SELECT * 
          INTO alreadySavedRow
          FROM movie
          WHERE id = newMovieRow.id
          FOR UPDATE NOWAIT;
          try := 4;
          
        EXCEPTION
          WHEN E_Verrou THEN
            IF try = 3 THEN
              RAISE E_Verrou;
            ELSE
              LOG_INFO('[IMPORT]Verrou actif (essai n°' || try ||')', 'AlimCB', 'Info');
              try := try + 1;
              dbms_lock.sleep(1); /* Attente 1 seconde. */
            END IF;
          WHEN NO_DATA_FOUND THEN 
            try := 5;
        END;
      END LOOP;
      --Si try vaut 4 quand il sort => On a un verrou sur le tuple et on fait vite un update
      --Si on a 5 => No data found
      

      IF try = 5 THEN
        --On génère les derniers champs manquants avant d'insérer dans MOVIE
        /* Certifications */
        IF currentRow.certification is not null then
          BEGIN 
            Select * into certificat from certification where name = currentRow.certification;
  
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
              INSERT INTO certification(name) values(currentRow.certification) returning id, name, description into certificat;
            WHEN OTHERS THEN RAISE;
          END;
          
          newmovierow.certification := certificat.id;
          
        END IF;
        /* Fin certification */
        
        
        /* Status */
        IF currentRow.status is not null then
          BEGIN 
            Select * into statusRow from status where name = currentRow.status;
  
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
              INSERT INTO status(name) values(currentRow.status) returning id, name, description into statusRow;
            WHEN OTHERS THEN RAISE;
          END;
          
          newmovierow.status := statusRow.id;
          
        END IF;
        /* Fin status */
        
        --On insére dans movie
        insert into movie values newMovieRow; 
          
        IF currentRow.genres IS NOT NULL THEN
          Genres := ANALYSECIPACKAGE.getgenres(currentRow.genres);
          for i in 1 .. genres.count loop
            dbms_output.put_line(genres(i).id ||' '|| genres(i).name);
            
            BEGIN
              insert into genre values genres(i);
              LOG_INFO('[IMPORT]Le genre '''|| genres(i).name ||''' a été inséré dans la table genre', 'AlimCB', 'Info');
    
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN 
                LOG_INFO('[IMPORT]Le genre '''|| genres(i).name ||''' existe déjà dans la table genre', 'AlimCB', 'Info');
                null;
              WHEN OTHERS THEN RAISE;
            END;
          
          moviegenrerow.movie := newmovierow.id;
          moviegenrerow.genre := genres(i).id;
            
          insert into movie_genre values moviegenreRow;
          end loop;
        ELSE
          LOG_INFO('[IMPORT]ID : '||newmovierow.id||'. Aucun genre trouvé ', 'AlimCB', 'Warning');
        END IF;
        /* Fin genres */ 
        
        /* Acteurs */
        --dbms_output.put_line('ACTEURS : ');
        --dbms_output.put_line('----------');
        IF currentRow.actors IS NOT NULL THEN
          acteurs := ANALYSECIPACKAGE.getacteurs(currentRow.actors);
          for i in 1 .. acteurs.count loop
            dbms_output.put_line(acteurs(i).id ||' '|| acteurs(i).name||' '|| acteurs(i).role);
            
            BEGIN
              insert into artist values (acteurs(i).id, acteurs(i).name);
              LOG_INFO('[IMPORT]L''artiste '''|| acteurs(i).name ||''' a été inséré dans la table artist', 'AlimCB', 'Info');
    
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN 
                LOG_INFO('[IMPORT]L''artiste '''|| acteurs(i).name ||''' existe déjà dans la table artist', 'AlimCB', 'Info');
                null;
              WHEN OTHERS THEN RAISE;
            END;
          
            movieactorrow.movie := newmovierow.id;
            movieactorrow.actor := acteurs(i).id;
            movieactorrow.role := acteurs(i).role;
            BEGIN   
              insert into movie_actor values movieactorrow; --BUG : fixed certains acteurs on deux roles
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN 
                LOG_INFO('[IMPORT]ID : '||newmovierow.id||'. L''artiste '''|| acteurs(i).name ||''' a déjà joué dans le film avec un autre role. Ce rôle est donc ignoré.', 'AlimCB', 'Error');
              
            END;
          end loop;
        ELSE
          LOG_INFO('[IMPORT]ID : '||newmovierow.id||'. Aucun acteur trouvé ', 'AlimCB', 'Warning');
        END IF;
        /* FIN ACTEUR */ 
        
        /* Director */
        --dbms_output.put_line('DIRECTORS : ');
        --dbms_output.put_line('----------');      
         IF currentRow.directors IS NOT NULL THEN
          producteurs := ANALYSECIPACKAGE.getproducteurs(currentRow.directors);
          for i in 1 .. producteurs.count loop
            dbms_output.put_line(producteurs(i).id ||' '|| producteurs(i).name);
            
            BEGIN
              insert into artist values producteurs(i);
              LOG_INFO('[IMPORT]L''artiste '''|| producteurs(i).name ||''' a été inséré dans la table artist', 'AlimCB', 'Info');
    
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN 
                LOG_INFO('[IMPORT]L''artiste '''|| producteurs(i).name ||''' existe déjà dans la table artist', 'AlimCB', 'Info');
                null;
              WHEN OTHERS THEN RAISE;
            END;
          
            moviedirector.movie := newmovierow.id;
            moviedirector.director := producteurs(i).id;
  
              
            insert into movie_director values moviedirector;
          end loop;
        ELSE
          LOG_INFO('[IMPORT]ID : '||newmovierow.id||'. Aucun producteur trouvé ', 'AlimCB', 'Warning');
        END IF;
        /* FIN DIRECTOR */
  
        IF LENGTH(currentRow.poster_path) > 0 THEN 
          
          BEGIN
            insert into poster(movie, poster) values(newmovierow.id, httpuritype('http://image.tmdb.org/t/p/w185'||currentRow.poster_path).getblob());
            LOG_INFO('[IMPORT]ID : '||newmovierow.id||'. Poster téléchargé', 'AlimCB', 'Info');
            
          EXCEPTION
            WHEN OTHERS THEN
          LOG_INFO('[IMPORT]ID : '||newmovierow.id||'. Erreur poster : '|| SQLERRM, 'AlimCB', 'Error');
          END;
          
        ELSE
          LOG_INFO('[IMPORT]ID : '||newmovierow.id||'. Pas de poster détecté', 'AlimCB', 'Info');        
        END IF;
  
  
        /* Nbr copies */ 
        FOR i IN 1 .. nbrcopie + 1 LOOP
          INSERT INTO movie_copies values (newMovieRow.id, i);
        END LOOP;
  
      END IF;      
      
      commit;
      
      ALIMCCPACKAGE.PREPARE_MOVIE_TO_COPY(newMovieRow.id);

    EXCEPTION
      WHEN OTHERS THEN 
        LOG_INFO('[IMPORT]ID : '|| currentRow.id || '. Import du film annulé (rollback). Erreur : '|| SQLERRM||'.', 'AlimCB', 'Error');
        rollback;
    END;
  
    LOG_INFO('[IMPORT]Fin du traitement du film '||currentRow.id, 'AlimCB', 'Info');

   end loop;

   RECEIPT_MOVIES@CC_LINK;
    
  END IMPORTCB;
  
  
  
  
  
  PROCEDURE ALIMCB(Movies IN MoviesIdsTable) AS --table de ids
  E_NoIds Exception;
  FetchedMovies MoviesExtTable;
  BEGIN
    if Movies.count = 0 THEN Raise E_NoIds; END IF;
    
    select * 
    bulk collect into FetchedMovies 
    from movies_ext 
    where id IN (select * from table(Movies));
  
    --Check si tous les elems sont la 
    
    IMPORTCB(FetchedMovies);
    
  EXCEPTION
    WHEN E_NoIds THEN
      LOG_INFO('[ALIMCB]Le tableau d''id donnée en paramètre est vide', 'ALIMCB', 'Error');
      RAISE_APPLICATION_ERROR(-20002, 'Le tableau d''id donnée en paramètre est vide');
  END ALIMCB;

  PROCEDURE ALIMCB(NombreMovie In Number) AS --aller chercher les tuples aléatoirement
  E_WrongParam Exception;
  FetchedMovies MoviesExtTable;
  BEGIN
    if NombreMovie <= 0 OR NombreMovie = null THEN Raise E_WrongParam; END IF;
    
    select * 
    bulk collect into FetchedMovies 
    from movies_ext 
    ORDER BY dbms_random.value
    FETCH FIRST NombreMovie ROWS ONLY;

    IMPORTCB(FetchedMovies);
    
  EXCEPTION
    WHEN E_WrongParam THEN
      LOG_INFO('[IMPORT]Le param n donné est négatif ou égale à 0', 'ALIMCB', 'Error');
      RAISE_APPLICATION_ERROR(-20002, 'Le param n donné est négatif ou égale à 0');
  END ALIMCB;
  
END ALIMCBPACKAGE;
/