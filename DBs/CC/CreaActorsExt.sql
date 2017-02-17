create table actors_ext (
  id integer,
  name varchar2(100),
  birthday date,
  place varchar2(300),  
  deathday date,
  poster_path varchar2(100),
  bio varchar2(4000)
)
organization external (
  type oracle_loader
  default directory MYDIR
  access parameters (
    records delimited by "\n"
    characterset "AL32UTF8"
    string sizes are in characters
    fields terminated by X"E28199"
    missing field values are null
    (
      id unsigned integer external,
      name char(100),
      birthday char(10) date_format date mask "yyyy-mm-dd",
      place char(300),  
      deathday char(10) date_format date mask "yyyy-mm-dd",
      poster_path char(100),
      bio char(4000)
    )
  )
  location('people.txt')
)
reject limit unlimited
;