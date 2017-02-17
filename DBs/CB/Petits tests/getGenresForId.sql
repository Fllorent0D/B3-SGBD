-- Can do sth with this later
declare
  type genre_t is record (id integer, name varchar2(100));
  type genres_t is table of genre_t index by binary_integer;
    type strings_t is table of varchar2(32767) index by binary_integer;

   genres_s varchar2(1000);
    genre varchar2(1000);
    -- TYPE vc_arr IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
    res owa_text.vc_arr;
    genres genres_t;
    i integer := 1;
    found boolean;
begin

    select genres into genres_s from movies_ext where id = 541;
    max NUMBER,
    min NUMBER,
    avg NUMBER,
    ecart NUMBER,
    mediane NUMBER,
    totVal NUMBER,
    quantile100 NUMBER,
    quantile10000 NUMBER,
    valNull NUMBER
    loop
        genre := regexp_substr(genres_s, '(.*?)(‖|$)', 1, i, '', 1);
        exit when genre is null;

        found := owa_pattern.match(genre, '^(.*)„(.*)$', res);
        if found then
            genres(i).id := res(1);
            genres(i).name := res(2);
            DBMS_OUTPUT.put_line(genres(i).id || ' ' || genres(i).name);
        end if;

        --TO TEST
        WITH stat(i, max, min, avg, ecart, mediane, totVal, quantile100, quantile10000, valNull) As
        (
        	SELECT * FROM table(objtable)
        	UNION ALL
			SELECT 
				col,
				MAX(col), 
			    MIN(col), 
			    AVG(col), 
			    STDDEV(col), 
			    MEDIAN(col), 
			    COUNT(col), 
			    PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY col), 
			    PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY col), 
			    COUNT(NVL2(col, NULL, 1))
			FROM MOVIES_EXT WHERE;
		)
        SELECT * from stat BULK COLLECT tableau... ;
        --END TEST

        i := i +1;
    end loop;
end;