/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package creaprog;

import Exceptions.InvalidFieldException;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.*;
import org.w3c.dom.Document;


/**
 *
 * @author florentcardoen
 */
public class CSVParser {
    private File input;
    private String regex;
    private boolean skipFirstLine = false;

    
    public CSVParser(File input,String regex, boolean sfl)
    {
        this.input = input;
        this.regex = regex; 
        this.skipFirstLine = sfl;
    }
    public ArrayList<Programmation> parse(){
        
        BufferedReader br = null;
        String line = "";
        Integer nLine = 1;
        LogManager.log("Debut parsing", 1);
        ArrayList<Programmation> programmes = new ArrayList<>();
        ArrayList<String> split ;
        Integer nbrError = 0; 
        try {
            br = new BufferedReader(new FileReader(input));
            
            if(skipFirstLine){
                br.readLine(); 
                nLine++;
            }
            
            Pattern p = Pattern.compile(regex);

            while ((line = br.readLine()) != null) {
                split = new ArrayList<>();
                Matcher m = p.matcher(line.trim());
                LogManager.log("\nLigne lue : "+ line, 3);

                Programmation pr;
                    
                    
                while (m.find()) {
                    if (!m.group().isEmpty()) {
                        LogManager.log("Champs "+ (split.size()+1) +" : " + m.group(), 3);
                        split.add(m.group());              
                    }
                }
                
                if(split.size() != 6)
                {
                    LogManager.log("Ligne " + nLine + " : Le nombre paramètre n'est pas reconnus", -1);
                    nbrError++;

                    //System.exit(0);
                }
                else
                {
                   try {
                    
                    pr = new Programmation(split.get(0), split.get(1), split.get(2), split.get(3), split.get(4), split.get(5));
                    programmes.add(pr);
                    LogManager.log("\tProgrammation : " +pr.toString(), 2);
                        
                    } catch (InvalidFieldException ex) {
                        LogManager.log("Ligne " + nLine + " : " + ex.getMessage(), -1);
                        nbrError++;
                        //System.exit(0);

                    }   
                }

                nLine++;
            }
            if(nbrError == 0)
                LogManager.log("Parsing terminé sans erreur", 1);
            else
                LogManager.log("Parsing terminé avec des erreurs. ("+nbrError+" document"+((nbrError > 1)? "s":"")+" ignoré"+((nbrError > 1)? "s":"")+")", 1);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (br != null) {
                try {
                    br.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        
        return programmes;
    }
    
}
