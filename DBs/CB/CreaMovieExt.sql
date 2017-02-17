CREATE TABLE "MOVIES_EXT" 
   (	"ID" NUMBER(*,0), 
	"TITLE" VARCHAR2(2000 BYTE), 
	"ORIGINAL_TITLE" VARCHAR2(2000 BYTE), 
	"RELEASE_DATE" DATE, 
	"STATUS" VARCHAR2(30 BYTE), 
	"VOTE_AVERAGE" NUMBER(3,1), 
	"VOTE_COUNT" NUMBER(*,0), 
	"RUNTIME" NUMBER(*,0), 
	"CERTIFICATION" VARCHAR2(30 BYTE), 
	"POSTER_PATH" VARCHAR2(100 BYTE), 
	"BUDGET" NUMBER(*,0), 
	"TAGLINE" VARCHAR2(2000 BYTE), 
	"GENRES" VARCHAR2(1000 BYTE), 
	"DIRECTORS" VARCHAR2(4000 BYTE), 
	"ACTORS" VARCHAR2(4000 BYTE)
   ) 
   ORGANIZATION EXTERNAL 
    ( TYPE ORACLE_LOADER
      DEFAULT DIRECTORY "MYDIR"
      ACCESS PARAMETERS
      ( records delimited by "\n"
    characterset "AL32UTF8"
    string sizes are in characters
    fields terminated by X"E28199"
    missing field values are null
    (
      id unsigned integer external,
      title char(2000),
      original_title char(2000),
      release_date char(10) date_format date mask "yyyy-mm-dd",
      status char(30),
      vote_average float external,
      vote_count unsigned integer external,
      runtime unsigned integer external,
      certification char(30),
      poster_path char(100),
      budget unsigned integer external,
      tagline char(2000),
      genres char(1000),
      directors char(4000),
      actors char(4000)
    )
      )
      LOCATION
       ( 'movies.txt'
       )
    )
   REJECT LIMIT UNLIMITED ;