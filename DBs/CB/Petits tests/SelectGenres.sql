with split(genre, stpos, endpos) as 
(
  Select genres, 1 stpos, regexp_instr(genres, '‖') endpos from movies_ext
  union all
  select genre, endpos + 1, regexp_instr(genre, '‖', endpos+1)
  from split
  where endpos > 0
)
select distinct
	cast(substr(genresub, 1, regexp_instr(genresub, '„') -1) as number) id,
	substr(genresub, regexp_instr(genresub, '„')+1) 
	from(
		select substr(genre, stpos, (coalesce(nullif(endpos,0), length(genre)+1))-stpos) genresub
		from split where genre is not null
	)
	order by id 