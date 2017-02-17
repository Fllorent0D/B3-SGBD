/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package creaprog;

import java.io.File;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author bastin
 */
public class toremove {
    
    public static void getList(String directory) throws SQLException
    {
        File path = new File( directory );
        String[] list = path.list();
        String element;

        for(int i = 0; i < list.length; i++)
        {
            element = list[i];
            
            Pattern r = Pattern.compile("(^prog)(.*)(.csv)");
            
            Matcher m = r.matcher(element);
            
            if(m.find()) {
                System.out.println(element);
            } 
        }
    }
    
    public static void main(String[] args) {
        try {
            getList("C:\\Users\\bastin\\Dropbox\\SGBD\\CC\\CreaProg");
        } catch (SQLException ex) {
            Logger.getLogger(toremove.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
