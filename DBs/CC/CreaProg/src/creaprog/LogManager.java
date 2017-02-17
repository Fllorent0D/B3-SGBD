/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package creaprog;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author florentcardoen
 */
        /* LOGS */
        /*
            1. Message sur ce qui démarre
            2. Ligne par ligne
            3. Message technique
        */
public class LogManager {
    private static Integer verboseLevel = 0;
    private static File logFile = null;
    private static Writer out = null;
    private LogManager()
    {
        verboseLevel = 0;
        
    }
    public static void setFile(String l)
    {
        logFile = new File(l);
        try {
            if(!logFile.exists())
                logFile.createNewFile();
            
            out = new BufferedWriter(new FileWriter(logFile, true));
            log("Fichier de log utilisé : "+logFile.getAbsolutePath(), 1);
        } catch (IOException ex) {
            log("Impossible de créer le fichier de log", -1);
            Logger.getLogger(CreaProg.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    public static void setVerbose(Integer level){
        verboseLevel = level;
    }
    public static void closeLog()
    {
        try {
            if(out != null)
                out.close();
            
        } catch (IOException ex) {
            System.err.println("Impossible de fermer le fichier de log");
        }
        
    }
    public static void log(String log, Integer level)
    {
        if(level == -1)
        {
            System.out.println("\u001B[31m"+ log + "\u001B[0m");
        }
        else if(verboseLevel >= level)
        {
            System.out.println(log);
        }
        
        if(out != null)
        {
            try {
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
                LocalDateTime now = LocalDateTime.now();
                
                out.append("["+dtf.format(now)+"]" + log +"\n");
                
            } catch (IOException ex) {
                Logger.getLogger(LogManager.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        
        
        
    }
    
    
    
    
}
