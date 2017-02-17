drop table movie_director cascade constraint;
drop table movie_genre cascade constraint;
drop table movie_actor cascade constraint;
drop table artist cascade constraint;
drop table genre cascade constraint;
drop table poster cascade constraint;
drop table movie cascade constraint;
drop table certification cascade constraint;
drop table status cascade constraint;
drop table movie_copies cascade constraint;

DROP SEQUENCE sequence_certification;
DROP SEQUENCE sequence_status;

create table certification (
    id          number(5, 0),
    name        varchar2(9 CHAR),
    description varchar2(4000 CHAR),
    constraint cert$pk primary key (id),
    constraint cert$name$nn check (name is not null),
    constraint cert$name$un unique (name)
);


create table status (
    id          number(5, 0),
    name        varchar2(15 CHAR),
    description varchar2(4000 CHAR),
    constraint status$pk primary key (id),
    constraint status$name$nn check (name is not null),
    constraint status$name$un unique (name)
);

create table movie (
    id            number(6, 0),
    title         varchar2(113 CHAR),
    original_title varchar2(114 CHAR),
    release_date  date,
    status        number(5, 0),
    vote_average  number(2, 1),
    vote_count    number(4, 0),
    certification number(5, 0),
    runtime       number(4, 0),
    budget        number(9, 0),
    tagline       varchar2(867 CHAR),
    constraint movie$pk primary key (id),
    constraint movie$title$nn check (title is not null),
    constraint movie$votes$check check ((vote_count = 0 AND vote_average = 0) OR (vote_count > 0 AND (vote_average >= 0 OR vote_average <= 10))),
    constraint movie$budget$check check (budget > 0 OR budget IS NULL),
    constraint movie$runtime$check check (runtime > 0 OR runtime IS NULL),
    constraint movie$fk$status foreign key (status) references status(id),
    constraint movie$fk$certification foreign key (certification) references certification(id)
);
create table movie_copies
(
    movie   	number(6, 0),
    num_copy 	number(5, 0),
    constraint movie_copies$pk primary key (movie, num_copy),
    constraint movie_copies$fk$movie foreign key (movie) references movie(id)
);

create table artist (
    id   number(7, 0),
    name varchar2(40 CHAR),
    constraint artist$pk primary key (id),
    constraint artist$name$nn check (name is not null)
);


create table genre (
    id   number(5, 0),
    name varchar2(16 CHAR),
    constraint genre$pk primary key (id),
    constraint genre$name$nn check (name is not null),
    constraint genre$name$un unique (name)
);

create table poster(
    movie number(6, 0),
    poster blob,
    constraint poster$pk primary key (movie),
    constraint poster$fk$movie foreign key (movie) references movie(id)
);



create table movie_director (
    movie    number(6, 0),
    director number(7, 0),
    constraint m_d$pk primary key (movie, director),
    constraint m_d$fk$movie foreign key (movie) references movie(id),
    constraint m_d$fk$director foreign key (director) references artist(id)
);

create table movie_genre (
    genre number(5, 0),
    movie number(6, 0),
    constraint m_g$pk primary key (genre, movie),
    constraint m_g$fk$genre foreign key (genre) references genre(id),
    constraint m_g$fk$movie foreign key (movie) references movie(id)
);

create table movie_actor (
    movie  number(6, 0),
    actor number(7, 0),
    role varchar2(114 CHAR),
    constraint m_a$pk primary key (movie, actor),
    constraint m_a$fk$movie foreign key (movie) references movie(id),
    constraint m_a$fk$actor foreign key (actor) references artist(id)
);

/* AutoIncrement certification */ 
CREATE SEQUENCE sequence_certification INCREMENT BY 1 MAXVALUE 99999 NOCYCLE;

CREATE OR REPLACE TRIGGER certificationID
  BEFORE INSERT ON certification
  FOR EACH ROW
DECLARE
BEGIN
  IF(:new.id IS NULL)
  THEN
    :new.id := sequence_certification.nextval;
  END IF;
END;
/

/* AI status */
CREATE SEQUENCE sequence_status INCREMENT BY 1 MAXVALUE 99999 NOCYCLE;

CREATE OR REPLACE TRIGGER statusID
  BEFORE INSERT ON status
  FOR EACH ROW
DECLARE
BEGIN
  IF(:new.id IS NULL)
  THEN
    :new.id := sequence_status.nextval;
  END IF;
END;
/

commit;

CREATE DATABASE LINK CC_LINK CONNECT TO CC IDENTIFIED BY CC USING 'CC';

