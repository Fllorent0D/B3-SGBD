DECLARE
  	requeteBlock varchar2(10000);
  	type cols is table of varchar2(30);
  	testcols cols;
  
	TYPE resultStat IS RECORD
	(
		col  varchar2(50),
		function varchar2(50),
		value varchar2(50)
	);
  
  TYPE resultsStat is table OF resultStat;
  fichierStat  utl_file.file_type;

	resultats resultsStat;
	prev varchar2(50);
  
	timestart NUMBER;
  
	PROCEDURE affiche(tab IN resultsStat) is 
	BEGIN
	FOR indx IN 1 .. tab.COUNT LOOP
  /* Titre */
	 IF coalesce(prev, '-') != tab(indx).col THEN
	      utl_file.put_line(fichierStat, ' ');
	      utl_file.put_line(fichierStat, replace(tab(indx).col, '_', ' '));
	      utl_file.put_line(fichierStat, RPAD('-', 35, '-'));
	 END IF;
	  /* Lignes */
	  utl_file.put_line(fichierStat,
	    LPAD(
      CASE tab(indx).function 
        WHEN 'MIN' THEN 'Minimum'
        WHEN 'MAX' THEN 'Maximum'
        WHEN 'AVG' THEN 'Moyenne'
        WHEN 'STDDEV' THEN 'Ecart-type'
        WHEN 'MEDIAN' THEN 'Médiane'
        WHEN 'COUNT' THEN 'Elements non vide'
        WHEN 'PERC99' THEN '99ème 100-quantile'
        WHEN 'PERC9999' THEN '9999ème 10000-quantile'
        WHEN 'COUNT2' THEn 'Valeurs vides'
        WHEN 'DISTINCT' THEN 'Valeur distinctes'
        ELSE tab(indx).function
      END
      , 23, ' ') || ' : ' ||
	    RPAD(tab(indx).value, 15, ' '));
	  prev := tab(indx).col;
	END LOOP;

	END affiche;
  
  
BEGIN
    fichierStat := utl_file.fopen ('MYDIR', 'Stats.txt', 'W');
    utl_file.put_line (fichierStat, 'Statistiques colonnes');
    utl_file.put_line (fichierStat, RPAD('-', 35, '-'));
    
  	timestart := dbms_utility.get_time();
    
  /* Colonne Simple */ 
SELECT 'SELECT substr(aliases, 1, instr(aliases, ''__'') -1),substr(aliases, instr(aliases, ''__'')+2, length(aliases) - instr(aliases, ''__'')), value from(SELECT ' || 
listagg(
	CASE dt
	WHEN 'VARCHAR2' THEN
		CASE 
			WHEN col = 'CERTIFICATION' OR col = 'STATUS' THEN 'COUNT(DISTINCT '|| col ||') '|| col ||'__distinct,'
		END ||
		'MIN(LENGTH('|| col ||')) '|| col ||'__min,' || 
		'MAX(LENGTH('|| col ||')) '|| col ||'__max,' || 
		'ROUND(AVG(LENGTH('|| col ||')),2) '|| col ||'__avg,' || 
		'ROUND(STDDEV(LENGTH('|| col ||')),2) '|| col ||'__stddev,' ||  
		'ROUND(MEDIAN(LENGTH('|| col ||')),2) '|| col ||'__median,' ||  
		'COUNT(LENGTH('|| col ||')) '|| col ||'__count,' ||  
		'PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH('|| col ||')) '|| col ||'__perc99,' || 
		'PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY LENGTH('|| col ||')) '|| col ||'__perc9999,' || 
		'COUNT(NVL2(LENGTH('|| col ||'), NULL, 1)) '|| col ||'__count2'

	WHEN 'NUMBER' THEN 
		'MIN('|| col ||') '|| col ||'__min,' || 
		'MAX('|| col ||') '|| col ||'__max,' || 
		'ROUND(AVG('|| col ||'), 2) '|| col ||'__avg,' || 
		'ROUND(STDDEV('|| col ||'), 2) '|| col ||'__stddev,' ||  
		'ROUND(MEDIAN('|| col ||'), 2) '|| col ||'__median,' ||  
		'COUNT('|| col ||') '|| col ||'__count,' || 
		'PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY '|| col ||') '|| col ||'__perc99,' || 
		'PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY '|| col ||') '|| col ||'__perc9999,' || 
		'COUNT(NVL2('|| col ||', NULL, 1)) '|| col ||'__count2'
  END, ', ') 
WITHIN group (order by col) || 
' FROM movies_ext)' ||
' UNPIVOT (value for aliases in('|| listagg(CASE WHEN col = 'CERTIFICATION' OR col = 'STATUS' THEN col ||'__distinct, 'END || col || '__min, ' || col || '__max, ' ||col || '__avg, ' ||col || '__stddev, ' ||col || '__median, ' ||col || '__count, ' ||col || '__perc99, ' ||col || '__perc9999, ' ||col || '__count2', ', ') within group(order by col) ||'))'
query
into requeteBlock
from (select column_name col, data_type dt
      from user_tab_columns
      where table_name = 'MOVIES_EXT' and (data_type = 'VARCHAR2' OR data_type = 'NUMBER')  
      and column_name not in ('ACTORS', 'DIRECTORS', 'GENRES'));
      
Execute IMMEDIATE requeteBlock BULK COLLECT INTO resultats;
  LOG_info('Fin analyse Varchar/Number', 'AnalyseCB');
affiche(resultats);


/* DATE */
select substr(aliases, 1, instr(aliases, '__') -1),substr(aliases, instr(aliases, '__')+2, length(aliases) - instr(aliases, '__')), value
BULK COLLECT INTO resultats 
from (
  select 
  to_char(MIN(release_date), 'DD/MM/YYYY') releaseDate__min,
  to_char(MAX(release_date), 'DD/MM/YYYY') releaseDate__max,
  to_char(FLOOR(AVG(EXTRACT(month from release_date)))) releaseDate__moyenne_mois,
  to_char(FLOOR(AVG(EXTRACT(year from release_date)))) releaseDate__moyenne_annees,
  to_char(FLOOR(MEDIAN(EXTRACT(month from release_date)))) releaseDate__mediane_mois,
  to_char(FLOOR(MEDIAN(EXTRACT(year from release_date)))) releaseDate__mediane_annees,
  to_char(COUNT(release_date)) releaseDate__count,  
  to_char(COUNT(NVL2(release_date, NULL, 1))) releaseDate__count2
  from movies_ext)
UNPIVOT (value for aliases in (releaseDate__min, releaseDate__max, releaseDate__moyenne_annees, releaseDate__moyenne_mois,releaseDate__mediane_annees,releaseDate__mediane_mois, releaseDate__count, releaseDate__count2));

  affiche(resultats);
  /* Colonne double - genres / réalisateurs*/
  	testcols := cols('genres', 'directors');
	FOR indx IN 1 .. testcols.count LOOP
		requeteBlock := '
		SELECT substr(aliases, 1, instr(aliases, ''__'') -1),
		substr(aliases, instr(aliases, ''__'')+2, length(aliases) - instr(aliases, ''__'')), 
		value
	    FROM
	    (
	      SELECT 
	      MIN(id) id_'|| testcols(indx) ||'__min,
          MAX(id) id_'|| testcols(indx) ||'__max,
          ROUND(AVG(id),2) id_'|| testcols(indx) ||'__avg, 
          ROUND(STDDEV(id),2) id_'|| testcols(indx) ||'__stddev,  
          ROUND(MEDIAN(id),2) id_'|| testcols(indx) ||'__median,  
          COUNT(id) id_'|| testcols(indx) ||'__count,  
          PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY id) id_'|| testcols(indx) ||'__perc99,
          PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY id) id_'|| testcols(indx) ||'__perc9999, 
          COUNT(NVL2(id, NULL, 1)) id_'|| testcols(indx) ||'__count2,
          min(LENGTH(genre)) '|| testcols(indx) ||'__min, 
          max(LENGTH(genre)) '|| testcols(indx) ||'__max, 
          ROUND(avg(LENGTH(genre)),2) '|| testcols(indx) ||'__avg, 
          ROUND(stddev(LENGTH(genre)),2) '|| testcols(indx) ||'__stddev, 
          ROUND(median(LENGTH(genre)),2) '|| testcols(indx) ||'__median, 
          count(LENGTH(genre)) '|| testcols(indx) ||'__count, 
          PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(genre)) '|| testcols(indx) ||'__perc99, 
          PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY LENGTH(genre)) '|| testcols(indx) ||'__perc9999, 
          COUNT(NVL2(LENGTH(genre), NULL, 1)) '|| testcols(indx) ||'__count2
          FROM (
            with split(champs, debut, fin) as 
            (
              Select '|| testcols(indx) ||', 1 debut, regexp_instr('|| testcols(indx) ||',''‖'') fin from movies_ext
              union all
              select champs, fin + 1, regexp_instr(champs, ''‖'', fin+1)
              from split
              where fin <> 0
            )
  	        select distinct
              cast(substr(tuple, 1, regexp_instr(tuple, ''„'') -1) as number) id,
              substr(tuple, regexp_instr(tuple, ''„'')+1) as genre
              from(
                select substr(champs, debut, (coalesce(nullif(fin,0), length(champs)+1))-debut) tuple
                from split where champs is not null)
              )
		)
		UNPIVOT(value for aliases IN('|| testcols(indx) ||'__min, '|| testcols(indx) ||'__max, '|| testcols(indx) ||'__avg, '|| testcols(indx) ||'__stddev, '|| testcols(indx) ||'__median, '|| testcols(indx) ||'__count, '|| testcols(indx) ||'__perc99, '|| testcols(indx) ||'__perc9999, '|| testcols(indx) ||'__count2, '|| 'id_'||testcols(indx) ||'__min, '|| 'id_'||testcols(indx) ||'__max, '|| 'id_'||testcols(indx) ||'__avg, '|| 'id_'||testcols(indx) ||'__stddev, '|| 'id_'||testcols(indx) ||'__median, '|| 'id_'||testcols(indx) ||'__count, '|| 'id_'||testcols(indx) ||'__perc99, '|| 'id_'||testcols(indx) ||'__perc9999, '|| 'id_'||testcols(indx) ||'__count2))';
	    --DBMS_OUTPUT.put_line(requeteBlock);
	    EXECUTE IMMEDIATE requeteBlock BULK COLLECT INTO resultats;
	    affiche(resultats);
	END LOOP;


	/* Acteurs */
	SELECT substr(aliases, 1, instr(aliases, '__') -1) col,
        substr(aliases, instr(aliases, '__')+2, length(aliases) - instr(aliases, '__')) function,
        value
        BULK COLLECT INTO resultats
	from
	(select 
	  MIN(LENGTH(actors)) actors__min,
	  MAX(LENGTH(actors)) actors__max,
	  ROUND(AVG(LENGTH(actors)),2) actors__avg, 
	  ROUND(STDDEV(LENGTH(actors)),2) actors__stddev,
	  ROUND(MEDIAN(LENGTH(actors)),2) actors__median,
	  COUNT(LENGTH(actors)) actors__count,  
	  PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(actors)) actors__perc99,
	  PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY LENGTH(actors)) actors__perc9999, 
	  COUNT(NVL2(LENGTH(roles), NULL, 1)) actors__count2,
	  MIN(LENGTH(roles)) roles__min,
	  MAX(LENGTH(roles)) roles__max,
	  ROUND(AVG(LENGTH(roles)),2) roles__avg, 
	  ROUND(STDDEV(LENGTH(roles)),2) roles__stddev,  
	  ROUND(MEDIAN(LENGTH(roles)),2) roles__median,  
	  COUNT(LENGTH(roles)) roles__count,  
	  PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH(roles)) roles__perc99,
	  PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY LENGTH(roles)) roles__perc9999, 
	  COUNT(NVL2(LENGTH(roles), NULL, 1)) roles__count2,
	  MIN(id) id_actors__min,
	  MAX(id) id_actors__max,
	  ROUND(AVG(id),2) id_actors__avg, 
	  ROUND(STDDEV(id),2) id_actors__stddev,  
	  ROUND(MEDIAN(id),2) id_actors__median,  
	  COUNT(id) id_actors__count,  
	  PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY id) id_actors__perc99,
	  PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY id) id_actors__perc9999, 
	  COUNT(NVL2(id, NULL, 1)) id_actors__count2
	  from
	  (
	    with split(champs, debut, fin) as 
	    (
	      Select actors, 1 debut, regexp_instr(actors, '‖') fin from movies_ext
	      union all
	      select champs, fin + 1, regexp_instr(champs, '‖', fin+1)
	      from split
	      where fin <> 0
	    )
	    select distinct
	      cast(substr(tuple, 1, instr(tuple, '„') -1) as number) id,
	      substr(tuple, instr(tuple, '„')+1, instr(tuple, '„', 1, 2) - instr(tuple, '„', 1, 1) - 1) actors, 
	      substr(tuple, instr(tuple, '„', 1, 2)+1) roles
	      from(
	        select substr(champs, debut, (coalesce(nullif(fin,0), length(champs)+1))-debut) tuple
	        from split where champs is not null
	    )
	  )
	)
	UNPIVOT (value for aliases IN (actors__min, actors__max, actors__avg,actors__stddev,actors__median,actors__count,actors__perc99,actors__perc9999,actors__count2,roles__min,roles__max,roles__avg,roles__stddev,roles__median,roles__count,roles__perc99,roles__perc9999,roles__count2,id_actors__min,id_actors__max,id_actors__avg, id_actors__stddev,id_actors__median,id_actors__count,id_actors__perc99,id_actors__perc9999,id_actors__count2));
	  
	affiche(resultats);
	
	dbms_output.put_line('Temps : ' || to_char(((dbms_utility.get_time() - timestart)/100)));
  utl_file.fclose (fichierStat);
  EXCEPTION
  WHEN OTHERS THEN
     IF utl_file.is_open(fichierStat) THEN
        utl_file.fclose (fichierStat);
     END IF;
    LOG_info(SQLERRM, 'AnalyseCB');
    RAISE;

END;