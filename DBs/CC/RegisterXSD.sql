begin
  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://cc/movie.xsd',
    SCHEMADOC => BFILENAME('MYDIR', 'movie.xsd'),
    LOCAL => TRUE, GENTYPES => TRUE, GENTABLES => FALSE,
    CSID => NLS_CHARSET_ID('AL32UTF8')
  );

  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://cc/copy.xsd',
    SCHEMADOC => BFILENAME('MYDIR', 'copy.xsd'),
    LOCAL => TRUE, GENTYPES => TRUE, GENTABLES => FALSE,
    CSID => NLS_CHARSET_ID('AL32UTF8')
  );

  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://cc/programmation.xsd',
    SCHEMADOC => BFILENAME('MYDIR', 'programmation.xsd'),
    LOCAL => TRUE, GENTYPES => TRUE, GENTABLES => FALSE,
    CSID => NLS_CHARSET_ID('AL32UTF8')
  );

  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://cc/projection.xsd',
    SCHEMADOC => BFILENAME('MYDIR', 'projection.xsd'),
    LOCAL => TRUE, GENTYPES => TRUE, GENTABLES => FALSE,
    CSID => NLS_CHARSET_ID('AL32UTF8')
  );

  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://cc/archivage.xsd',
    SCHEMADOC => BFILENAME('MYDIR', 'archivage.xsd'),
    LOCAL => TRUE, GENTYPES => TRUE, GENTABLES => FALSE,
    CSID => NLS_CHARSET_ID('AL32UTF8')
  );

  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://cc/panier.xsd',
    SCHEMADOC => BFILENAME('MYDIR', 'panier.xsd'),
    LOCAL => TRUE, GENTYPES => TRUE, GENTABLES => FALSE,
    CSID => NLS_CHARSET_ID('AL32UTF8')
  );

  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://cc/feedback.xsd',
    SCHEMADOC => BFILENAME('MYDIR', 'feedback.xsd'),
    LOCAL => TRUE, GENTYPES => TRUE, GENTABLES => FALSE,
    CSID => NLS_CHARSET_ID('AL32UTF8')
  );

  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://cc/salle.xsd',
    SCHEMADOC => BFILENAME('MYDIR', 'salle.xsd'),
    LOCAL => TRUE, GENTYPES => TRUE, GENTABLES => FALSE,
    CSID => NLS_CHARSET_ID('AL32UTF8')
  );

  DBMS_XMLSCHEMA.REGISTERSCHEMA(
    SCHEMAURL => 'http://cc/seance.xsd',
    SCHEMADOC => BFILENAME('MYDIR', 'seance.xsd'),
    LOCAL => TRUE, GENTYPES => TRUE, GENTABLES => FALSE,
    CSID => NLS_CHARSET_ID('AL32UTF8')
  );
end;
/
