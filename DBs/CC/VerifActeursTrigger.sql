create or replace TRIGGER VERIFACTEURTRIGGER 
BEFORE INSERT ON MOVIES 
FOR EACH ROW
DECLARE
  v_count number(10) := 1;

  l_http_request    UTL_HTTP.req;
  l_http_response   UTL_HTTP.resp;

  l_response_text   VARCHAR2(32767);
  content           VARCHAR2(32767);
  
  actorFetchedBPE   actors_ext%rowtype; 

  methode           VARCHAR2(5);
  status            VARCHAR2(20);
  
  url_api           varchar2(50) := 'http://bp.dev/api/verifacteur/';
 
  E_APIERROR        EXCEPTION;
  idacteurs number(38);
  curActeurs xmltype;
BEGIN
  
  
  
  WHILE :new.object_value.EXISTSNODE('/movie/actors/actor[' || v_count || ']') = 1 LOOP
    --photo/naissance/mort/lieu || titre(title), annee(release_date), role(character), id

    curActeurs := :new.object_value.extract('/movie/actors/actor[' || v_count || ']');
    BEGIN
      idacteurs := curActeurs.extract('/actor/id/text()').getnumberval();
      log_info(idacteurs, 'ver', 'debug');

      select *
      into actorFetchedBPE
      from actors_ext
      where id = idacteurs;
      
      
      
      
      
      
      content := '{"actor":{"_id":'||actorFetchedBPE.id||
                    ',"name":"'||actorFetchedBPE.name||'"';
                    
      if(actorFetchedBPE.birthday IS NOT NULL) THEN
        content := content ||',"birthday":"'||to_char(actorFetchedBPE.birthday, 'YYYY-MM-DD')||'"';
      END IF;
      if(actorFetchedBPE.place IS NOT NULL) THEN
        content := content ||',"place_of_birth":"'||actorFetchedBPE.place||'"';
      END IF;
      if(actorFetchedBPE.deathday IS NOT NULL) THEN
        content := content ||',"deathday":"'||to_char(actorFetchedBPE.deathday, 'YYYY-MM-DD')||'"';
      END IF;
      if(actorFetchedBPE.poster_path IS NOT NULL) THEN
        content := content ||',"profile_path":"'||actorFetchedBPE.poster_path||'"';
      END IF;

      content := content || '},"film":{"id":'|| :new.object_value.extract('/movie/id/text()').getStringVal() ||
        ', "title":"'|| :new.object_value.extract('/movie/title/text()').getStringVal() ||'"'; 
        
      if :new.object_value.extract('/movie/release_date/text()').getStringVal() IS NOT NULL then
        content := content || ',"release_date":"'|| :new.object_value.extract('/movie/release_date/text()').getStringVal() ||'"';
      end if;
      if curActeurs.extract('/actor/role/text()').getStringVal() IS NOT NULL THEN
        content := content || ',"character":"'|| curActeurs.extract('/actor/role/text()').getStringVal() || '"';
      END IF;
        
      content := content || '}}';
      LOG_INFO(content, 'VerifActeurTrigger', 'Debug');              
      methode := 'POST';
      l_http_request := utl_http.begin_request(url_api, methode,' HTTP/1.1');
      utl_http.set_header(l_http_request, 'content-type', 'application/json'); 
      utl_http.set_header(l_http_request, 'Content-Length', length(content));
      utl_http.write_text(l_http_request, content);
      l_http_response:= utl_http.get_response(l_http_request);
      UTL_HTTP.read_text(l_http_response, l_response_text);
      UTL_HTTP.end_response(l_http_response);
      
      select sta
      into status
      from json_table(l_response_Text, '$' COLUMNS (sta path '$.status'));
      
      IF status <> 'success' THEN 
        RAISE E_APIERROR;
      END IF;

    EXCEPTION
    WHEN UTL_HTTP.end_of_body 
      THEN UTL_HTTP.end_response(l_http_response);  
    WHEN NO_DATA_FOUND 
      THEN 
      LOG_INFO('L''acteur n''existe pas dans la table externe Actors_Ext', 'VERIFACTEURS', 'ERROR');
      --RAISE_APPLICATION_ERROR(-20100, 'L''acteur n''existe pas dans BPE... Ce qui pose problème pour la fin :/');
    WHEN E_APIERROR THEN
      SELECT mess into content from json_table(l_response_Text, '$' COLUMNS (mess path '$.message'));
      LOG_INFO('Une erreur est survenue lors de la mise à jour de la Mongo sur le serveur HTTP. '|| content, 'VERIFACTEURS', 'ERROR');
      --RAISE_APPLICATION_ERROR(-20101, 'Une erreur est survenue lors de la mise à jour de la Mongo sur le serveur HTTP. '|| content);
    END;
    v_count := v_count + 1;  

  END LOOP;
EXCEPTION
  WHEN OTHERS THEN 
      LOG_INFO('Erreur non traitée : '|| SQLERRM || dbms_utility.format_error_backtrace, 'VERIFACTEURS', 'INFO');
      --RAISE;
END;
/