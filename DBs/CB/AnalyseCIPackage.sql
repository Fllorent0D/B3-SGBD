/* SPECS */
create or replace PACKAGE ANALYSECIPACKAGE AS 
  
  TYPE ActeursRecord is RECORD(
    id artist.id%type,
    name artist.name%type,
    role movie_actor.role%type
  );
  TYPE ActeursTable is table of acteursRecord;
  TYPE ProducteursTable is table of artist%rowtype;
  TYPE GenresTable is table of genre%rowtype;
  
  
  
  FUNCTION GETGENRES(text movies_ext.genres%type) RETURN GenresTable;
  FUNCTION GETACTEURS(text movies_ext.actors%type) RETURN acteurstable;
  FUNCTION GETPRODUCTEURS(text movies_ext.directors%type) RETURN ProducteursTable;
  
  
END ANALYSECIPACKAGE;
/

/* BODY */
create or replace PACKAGE BODY ANALYSECIPACKAGE AS

  FUNCTION GETGENRES(text movies_ext.genres%type) RETURN GenresTable AS
    genre varchar2(1000);
    res owa_text.vc_arr;
    genres GenresTable := GenresTable();
    i integer := 1;
    found boolean;
    --TO DO gérer la taille des champs
  BEGIN
    loop
        genre := regexp_substr(text, '(.*?)(‖|$)', 1, i, '', 1);
        exit when genre is null;

        found := owa_pattern.match(genre, '^(.*)„(.*)$', res);
        if found then
            genres.extend;
            genres(i).id := res(1);
            genres(i).name := res(2);
        end if;

        i := i +1;
    end loop;
   
    RETURN GENRES;
  END GETGENRES;

  FUNCTION GETACTEURS(text movies_ext.actors%type) RETURN acteurstable AS
    acteur varchar2(1000);
    res owa_text.vc_arr;
    acteurs ActeursTable := ActeursTable();
    i integer := 1;
    found boolean;
    --TO DO gérer la taille des champs
  BEGIN
    loop
        acteur := regexp_substr(text, '(.*?)(‖|$)', 1, i, '', 1);
        exit when acteur is null;

        found := owa_pattern.match(acteur, '^(.*)„(.*)„(.*)$', res);
        if found then
            acteurs.extend;
            acteurs(i).id := res(1);
            acteurs(i).name := res(2);
            acteurs(i).role := res(3);
        end if;

        i := i +1;
    end loop;
    RETURN acteurs;
  END GETACTEURS;

  FUNCTION GETPRODUCTEURS(text movies_ext.directors%type) RETURN ProducteursTable AS
    prod varchar2(1000);
    res owa_text.vc_arr;
    producteurs producteursTable := producteursTable();
    i integer := 1;
    found boolean;
    --TO DO gérer la taille des champs
  BEGIN
    loop
        prod := regexp_substr(text, '(.*?)(‖|$)', 1, i, '', 1);
        exit when prod is null;

        found := owa_pattern.match(prod, '^(.*)„(.*)$', res);
        if found then
            producteurs.extend;
            producteurs(i).id := res(1);
            producteurs(i).name := res(2);
        end if;

        i := i +1;
    end loop;
   
    RETURN producteurs;
  END GETPRODUCTEURS;

END ANALYSECIPACKAGE;
/