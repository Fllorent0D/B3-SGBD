
--Génère requete de stats pour VARCHAR
SELECT 'SELECT substr(aliases, 1, instr(aliases, ''__'') -1),substr(aliases, instr(aliases, ''__'')+2, length(aliases) - instr(aliases, ''__'')), value from(SELECT ' || 
listagg('MIN(LENGTH('|| col ||')) '|| col ||'__min' || ', '||
'MAX(LENGTH('|| col ||')) '|| col ||'__max' || ', '||
'AVG(LENGTH('|| col ||')) '|| col ||'__avg' || ', '||
'STDDEV(LENGTH('|| col ||')) '|| col ||'__stddev' || ', '|| 
'MEDIAN(LENGTH('|| col ||')) '|| col ||'__median' || ', '|| 
'COUNT(LENGTH('|| col ||')) '|| col ||'__count' || ', '|| 
'PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY LENGTH('|| col ||')) '|| col ||'__perc99' || ', '||
'PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY LENGTH('|| col ||')) '|| col ||'__perc9999' || ', '||
'COUNT(NVL2(LENGTH('|| col ||'), NULL, 1)) '|| col ||'__count2', ', ') WITHIN group (order by col) || 
' FROM movies_ext)' ||
' UNPIVOT (value for aliases in(' || listagg(col || '__min, ' || col || '__max, ' ||col || '__avg, ' ||col || '__stddev, ' ||col || '__median, ' ||col || '__count, ' ||col || '__perc99, ' ||col || '__perc9999, ' ||col || '__count2', ', ') within group(order by col) ||'))'
query
from (select column_name col
      from user_tab_columns
      where table_name = 'MOVIES_EXT' and data_type = 'VARCHAR2' and column_name not in ('ACTORS', 'DIRECTORS', 'GENRES'));
  



--Génère requete de stats pour NUMBER    
SELECT 'SELECT substr(aliases, 1, instr(aliases, ''__'') -1),substr(aliases, instr(aliases, ''__'')+2, length(aliases) - instr(aliases, ''__'')), value from(SELECT ' || 
listagg('MIN('|| col ||') '|| col ||'__min' || ', '||
'MAX('|| col ||') '|| col ||'__max' || ', '||
'AVG('|| col ||') '|| col ||'__avg' || ', '||
'STDDEV('|| col ||') '|| col ||'__stddev' || ', '|| 
'MEDIAN('|| col ||') '|| col ||'__median' || ', '|| 
'COUNT('|| col ||') '|| col ||'__count' || ', '|| 
'PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY '|| col ||') '|| col ||'__perc99' || ', '||
'PERCENTILE_CONT(0.9999) WITHIN GROUP(ORDER BY '|| col ||') '|| col ||'__perc9999' || ', '||
'COUNT(NVL2('|| col ||', NULL, 1)) '|| col ||'__count2', ', ') WITHIN group (order by col) || 
' FROM movies_ext)' ||
' UNPIVOT (value for aliases in(' || listagg(col || '__min, ' || col || '__max, ' ||col || '__avg, ' ||col || '__stddev, ' ||col || '__median, ' ||col || '__count, ' ||col || '__perc99, ' ||col || '__perc9999, ' ||col || '__count2', ', ') within group(order by col) ||'))'
query
from (select column_name col
      from user_tab_columns
      where table_name = 'MOVIES_EXT' and (data_type = 'NUMBER' ) and column_name not in ('ACTORS', 'DIRECTORS', 'GENRES'));
      