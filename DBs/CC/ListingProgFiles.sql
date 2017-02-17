/* Création de la table contenant la liste des fichiers*/

CREATE GLOBAL TEMPORARY TABLE PROG_FILES
( 
  FILENAME VARCHAR2(255),
  DIR VARCHAR2(255)
)
ON COMMIT DELETE ROWS;

/* Ajout du code JAVA qui ajoute les fichiers dans une table en fonction du dossier et d'une regex */ 
 
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED PROG_UTILS AS
import java.io.File;
import java.sql.SQLException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ProgUtils {
    
    public static void listFromDirectory(String directory) throws SQLException
    {
        File path = new File(directory);
        String[] list = path.list();
        String element;

        #sql{COMMIT};

        for(int i = 0; i < list.length; i++)
        {
            element = list[i];
            
            Pattern r = Pattern.compile("^prog_\\d{4}_\\d{2}_\\d{2}_\\d+.xml$");
            
            Matcher m = r.matcher(element);
            
            if(m.find()) {
                #sql {
                  INSERT INTO PROG_FILES (FILENAME)
                  VALUES (:element) 
                };
            } 
        }
    }
}
/
/* Création de la procédure pour récuperer les fichiers */
 
CREATE OR REPLACE PROCEDURE GET_PROG_FILES(p_directory IN VARCHAR2) AS
   LANGUAGE JAVA NAME 'ProgUtils.listFromDirectory( java.lang.String )';
   
/