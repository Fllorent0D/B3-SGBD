create or replace PACKAGE RECHERCHE_PLACE_PACKAGE AS 
  
  FUNCTION GETHORAIRE RETURN clob;
  FUNCTION GETFILMINFO(idMovie Number) return clob;
  FUNCTION GETFILMSCHEDULE(idMovie Number) return clob;
  FUNCTION GETACTORS RETURN clob;
  FUNCTION GETDIRECTORS RETURN clob;
  FUNCTION GETGENRES RETURN clob;
  FUNCTION GETPOSTER(idMovie Number) RETURN blob;
  FUNCTION RECHERCHEFILM(opPop IN CHAR, popularite IN number, opPer IN CHAR, perennite IN number, titre IN VARCHAR2 default '', acteursliste IN VARCHAR2 default '', genresliste in varchar2 default '') RETURN clob;
  FUNCTION COMMANDEPLACE(docxml clob) RETURN CLOB;
  
END RECHERCHE_PLACE_PACKAGE;
/

--
create or replace PACKAGE BODY RECHERCHE_PLACE_PACKAGE AS
  
 
  FUNCTION GETHORAIRE RETURN clob AS
    TYPE tabNumber IS TABLE OF number INDEX BY BINARY_INTEGER;
    tabId tabNumber;
    response xmltype;
  BEGIN
    SELECT 
      XMLELEMENT("films",
                 XMLAGG(
                    XMLElement( "film", 
                                XMLForest(idMovP  AS "id", 
                                          title AS "title" 
            ))))
      INTO response
      FROM (
        SELECT DISTINCT extractvalue(object_value, 'projection/idMovie') idMovP
        FROM projections
        WHERE   (extractvalue(object_value, 'projection/debut')) < sysdate 
        and (extractvalue(object_value, 'projection/fin')) > sysdate) ta
      LEFT JOIN
        (SELECT extractvalue(object_value, 'movie/id') idMovM, extractvalue(object_value, 'movie/title') title
         FROM MOVIES) tb
         ON ta.idMovP = tb.idMovM;
 
    RETURN response.getStringVal();
  END GETHORAIRE;

  FUNCTION GETFILMINFO(idMovie Number) RETURN clob AS
    movie xmltype;
    resultat varchar2(4000);
  
  BEGIN
    BEGIN 
      SELECT extract(object_value, '/movie/*[not(self::poster)]') into movie from movies where extractvalue(object_value, '/movie/id') = idMovie;
      return '<movie>'||movie.getStringVal()||'</movie>';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        resultat := '<error>Le film ne se trouve pas dans la base de données</error>';
      when others then
        --raise;
        resultat := '<error>'|| SQLERRM || '</error>';
    END;
    
    return resultat;
  END GETFILMINFO;
  FUNCTION GETFILMSCHEDULE(idMovie Number) return clob AS
    response xmltype;
    resultat varchar2(100);
  BEGIN
    BEGIN 
      SELECT 
      XMLELEMENT("seances", 
        XMLAGG(
          XMLElement("seance", 
                    XMLForest(extractvalue(pr.object_value, '/projection/numSalle/text()') AS "numSalle", 
                              extractvalue(sa.object_value, '/salle/capacity/text()')  AS "capacite",
                              extractvalue(pr.object_value, '/projection/idProjection/text()') as "idProjection",
                              extractvalue(se.object_value, '/seance/nombreReservations/text()') AS "reservations",
                              extractvalue(se.object_value, '/seance/dateSeance/text()') AS "date",
                              extractvalue(pr.object_value, '/projection/heure/text()')  AS "heure"
                              
                              )
                    )
              )
      ) result
      into response
      FROM projections pr
      inner join seances se
      on extractvalue(pr.object_value, '/projection/idProjection') = extractvalue(se.object_value, '/seance/idProjection')
      inner join salles sa
      on extractvalue(sa.object_value, '/salle/numSalle') = extractvalue(pr.object_value, '/projection/numSalle')
      where extractvalue(pr.object_value, '/projection/debut') < sysdate 
      and extractvalue(pr.object_value, '/projection/idMovie') = idMovie
      and extractvalue(se.object_value, '/seance/dateSeance') >= sysdate
      order by extractvalue(se.object_value, '/seance/dateSeance/text()') ASC;
    
    return response.getStringVal();
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        resultat := '<error>Le film ne se trouve pas dans la base de données</error>';
      when others then
        --raise;
        resultat := '<error>'|| SQLERRM || '</error>';
    END;
    return resultat;
  END GETFILMSCHEDULE;

  FUNCTION GETACTORS RETURN clob AS
  resultat xmltype;
  
  BEGIN
    SELECT XMLELEMENT("actors", XMLAGG(XMLELEMENT("actor", XMLFOREST("id" AS "id", "name" AS "name")))) AS actors
    INTO resultat
    FROM (
      SELECT DISTINCT actors."id", actors."name" 
      FROM movies, XMLTABLE('/movie/actors/actor' PASSING movies.OBJECT_VALUE COLUMNS "id" VARCHAR2(255) PATH 'id', "name" VARCHAR2(255) PATH 'name') actors
      order by actors."name"
    );
    RETURN resultat.getClobVal();
  END GETACTORS;

  FUNCTION GETDIRECTORS RETURN clob AS
  resultat xmltype;
  
  BEGIN
    SELECT XMLELEMENT("directors", XMLAGG(XMLELEMENT("director", XMLFOREST("id" AS "id")))) AS directors
    into resultat
    FROM (
      SELECT DISTINCT directors."id"
      FROM movies, XMLTABLE('/movie/directors/director' PASSING movies.OBJECT_VALUE COLUMNS "id" VARCHAR2(255) PATH 'id') directors
    );
    
    RETURN resultat.getClobVal();
  END GETDIRECTORS;

  FUNCTION GETGENRES RETURN clob AS
  resultat xmltype;
  BEGIN
    SELECT XMLELEMENT("genres", XMLAGG(XMLELEMENT("genre", XMLFOREST("id" AS "id", "name" AS "name")))) AS genres
    INTO resultat
    FROM (
      SELECT DISTINCT genres."id", genres."name" 
      FROM movies, XMLTABLE('/movie/genres/genre' PASSING movies.OBJECT_VALUE COLUMNS "id" VARCHAR2(255) PATH 'id', "name" VARCHAR2(255) PATH 'name') genres
      order by genres."name"
    );
    RETURN resultat.getClobVal();
  END GETGENRES;

  FUNCTION RECHERCHEFILM(opPop IN CHAR, popularite IN number, opPer IN CHAR, perennite IN number, titre IN VARCHAR2 default '', acteursliste IN VARCHAR2 default '', genresliste in varchar2 default '') RETURN clob AS
  resultat xmltype;
  aliste varchar2(4000);
  gliste varchar2(4000);
  BEGIN
    
    aliste := '/movie/actors/*[contains('''||replace(acteursliste, '#', ' ')||''', id)]';
    gliste := '/movie/genres/*[contains('''||replace(genresliste, '#', ' ')||''', id)]';
  
    SELECT 
    XMLELEMENT("movies", 
      XMLAGG(XMLELEMENT("movie", 
        XMLFOREST(
          id AS "id", 
          title AS "title",
          perennite AS "perennite",
          popularite AS "popularite")          
        )
      )
    ) AS resultat 
    INTO resultat
    FROM(
      SELECT DISTINCT extractvalue(mo.object_value, '/movie/id') id, extractvalue(mo.object_value, '/movie/title') title, extractvalue(ar.object_value, '/archivage/perennite') perennite, extractvalue(ar.object_value, '/archivage/placesVendues/text()') popularite
      FROM MOVIES MO
      INNER JOIN ARCHIVAGES AR 
      ON extractvalue(mo.object_value, '/movie/id') = extractvalue(ar.object_value, '/archivage/idMovie')
      left JOIN projections pr 
      ON extractvalue(pr.object_value, '/projection/idMovie') = extractvalue(mo.object_value, '/movie/id')
      WHERE 
        (((CASE 
          WHEN opPer LIKE '>' AND CAST(extractvalue(ar.object_value, '/archivage/perennite') AS INT) > perennite THEN 1
          WHEN opPer LIKE '<' AND CAST(extractvalue(ar.object_value, '/archivage/perennite') AS INT) < perennite THEN 1
          WHEN opPer LIKE '=' AND CAST(extractvalue(ar.object_value, '/archivage/perennite') AS INT) = perennite THEN 1
          WHEN opPer LIKE 'N' THEN 1
          ELSE 0 
        END) = 1
      AND 
        (CASE 
          WHEN opPop LIKE '>' AND (CAST(extractvalue(ar.object_value, '/archivage/placesVendues/text()') AS INT)) > popularite THEN 1
          WHEN opPop LIKE '<' AND (CAST(extractvalue(ar.object_value, '/archivage/placesVendues/text()') AS INT)) < popularite THEN 1
          WHEN opPop LIKE '=' AND (CAST(extractvalue(ar.object_value, '/archivage/placesVendues/text()') AS INT)) = popularite THEN 1
          WHEN opPop LIKE 'N' THEN 1 
          ELSE 0
        END) = 1
     AND
      (CASE WHEN titre = '' THEN 1
       WHEN REGEXP_LIKE (extractvalue(mo.object_value, '/movie/title/text()'), '^(.*?('|| titre ||')[^$]*)$', 'i') THEN 1
       ELSE 0 
      END) = 1
     AND
      (CASE WHEN acteursliste is null THEN 1
       WHEN EXISTSNODE(mo.object_value, aliste) = 1 THEN 1
       ELSE 0 
      END) = 1
     AND
      (CASE WHEN genresliste is null THEN 1
       WHEN EXISTSNODE(mo.object_value, gliste) = 1 THEN 1
       ELSE 0 
      END) = 1)
     OR
      (genresliste is null  
       and acteursliste is null 
       and titre is null 
       and opPop = 'N' 
       and opPer = 'N' 
       and EXISTS(select * from seances se where to_char(extractvalue(se.object_value, '/seance/dateSeance/text()'), 'YYYY-MM-DD') = to_char(sysdate, 'YYYY-MM-DD'))
       )
     )
     and (
        extractvalue(pr.object_value, '/projection/debut') < sysdate and 
        extractvalue(pr.object_value, '/projection/fin') > sysdate
     )
     order by popularite desc, perennite desc, title asc
    );
      
    RETURN resultat.getClobVal();
  END RECHERCHEFILM;

  FUNCTION GETPOSTER(idMovie Number) RETURN blob AS
  poster blob;
  BEGIN
    select extractvalue(object_value, '/movie/poster/text()')
    into poster
    from movies
    where extractvalue(object_value, '/movie/id/text()') = idMovie;
    
    RETURN poster;
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20010, 'Aucun poster trouvé');
  END GETPOSTER;

  FUNCTION COMMANDEPLACE(docxml clob) RETURN CLOB AS
  panier xmltype;
  place xmltype;
  seance xmltype;
  message varchar2(4000);
  E_NO_MORE EXCEPTION;
  E_NOT_ENOUGH EXCEPTION;
  isvalid number(10) := 1;
  response xmltype := xmltype('<commande></commande>');
  v_count number(10) := 1;
  placedispo number(10);
  code number(2);
  BEGIN
    panier := XMLTYPE(docxml);
    LOG_INFO(panier.getStringVal(), 'api', 'debug');
    --SELECT INSERTCHILDXML(feedback, 'feedback/demande[idDemande=' || idDemande || ']/errors', 'error', XMLTYPE('<error>' || message || '</error>')) INTO feedback FROM DUAL;
    WHILE panier.EXISTSNODE('/panier/place[' || v_count || ']') = 1 LOOP
      place := panier.extract('/panier/place[' || v_count || ']');
      --LOG_INFO(place.getstringval(), 'api', 'debug');
      --LOG_INFO(place.extract('/place/projection/text()').getstringval(), 'api', 'debug');
      BEGIN 
      
        SELECT *
        into seance
        from seances
        where extractvalue(object_value, '/seance/idProjection/text()') = place.extract('/place/projection/text()').getStringVal()
        and to_char(extractvalue(object_value, '/seance/dateSeance/text()'), 'yyyy-mm-dd') = place.extract('/place/date/text()').getStringVal();
        
        
        SELECT (extractvalue(sa.object_value, '/salle/capacity/text()') - extractvalue(se.object_value, '/seance/nombreReservations/text()'))  
        into placedispo
        FROM projections pr
        inner join seances se
        on extractvalue(pr.object_value, '/projection/idProjection/text()') = extractvalue(se.object_value, '/seance/idProjection/text()')
        inner join salles sa 
        on extractvalue(sa.object_value, '/salle/numSalle/text()') = extractvalue(pr.object_value,'/projection/numSalle/text()')
        where extractvalue(se.object_value, '/seance/idProjection/text()') = place.extract('/place/projection/text()').getStringVal()
        and to_char(extractvalue(se.object_value, '/seance/dateSeance/text()'), 'yyyy-mm-dd') = place.extract('/place/date/text()').getStringVal();
        
        if placedispo = 0 THEN
          raise e_no_more;
        end if;
        LOG_INFO(placedispo, '', '');
        if placedispo >= place.extract('/place/quantite/text()').getnumberval() then
          UPDATE seances SET object_value =
           UPDATEXML(object_value, '/seance/nombreReservations/text()', extractvalue(object_value, '/seance/nombreReservations/text()') + place.extract('/place/quantite/text()').getnumberval())
           where extractvalue(object_value, '/seance/idProjection/text()') = place.extract('/place/projection/text()').getStringVal()
           and to_char(extractvalue(object_value, '/seance/dateSeance/text()'), 'yyyy-mm-dd') = place.extract('/place/date/text()').getStringVal();
           message := '<message>La place peut être commandée</message>';
        else 
          raise E_NOT_ENOUGH;
        end if;
        
        code := 0;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          isvalid := 0;
          code :=1;
          message := '<message>La séance demandé n''existe pas. Veuillez recommencer votre panier.</message>';
        WHEN E_NO_MORE THEN
          isvalid := 0;
          code := 2;
          message := '<message>Il n''y a plus de places disponible.</message>';
        WHEN E_NOT_ENOUGH THEN
          isvalid := 0;
          code := 3;
          message := '<message available="'||placedispo||'">Il n''y a plus assez de places disponible. Il en reste '||placedispo ||'</message>';
        
      END;
      
      SELECT INSERTCHILDXML(response, '/commande', 'place', XMLTYPE('<place code="'||code||'" projection="'|| place.extract('/place/projection/text()').getStringVal() ||'" date="'|| place.extract('/place/date/text()').getStringVal() ||'">'|| message ||'</place>')) INTO response FROM DUAL;
      v_count := v_count + 1;

    END LOOP;
    
    if isvalid = 1 then
      commit;
    else
      rollback;
    end if;
    
    RETURN response.getClobVal();
  END COMMANDEPLACE;

END RECHERCHE_PLACE_PACKAGE;
/