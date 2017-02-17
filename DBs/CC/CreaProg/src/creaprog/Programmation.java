/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package creaprog;

import Exceptions.InvalidFieldException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.logging.Level;
import java.util.logging.Logger;
import org.joda.time.LocalDate;
import org.joda.time.LocalTime;
import org.joda.time.format.*;
import org.joda.time.*;
import Exceptions.*;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.UUID;
import org.w3c.dom.Element;

/**
 * 
 * @author florentcardoen
 */
public class Programmation {
    private LocalDate debut = null;
    private LocalDate fin = null;
    private Integer film = null;
    private Integer copie = null;
    private Integer salle = null;
    private LocalTime heure = null;
    private String id = null ;
//String film, String copie, String salle, String Heure
    public Programmation(String debut, String fin,String film, String copie, String salle, String heure) throws InvalidFieldException  
    {
        
        setDebut(debut);
        setFin(fin);
        setFilm(film);
        setCopie(copie);
        setSalle(salle);
        setHeure(heure);
        generateId();

    }
    public LocalDate getDebut() {
        return debut;
    }

    public void setDebut(String debut) throws InvalidFieldException {
        try{
            DateTimeFormatter dtf = DateTimeFormat.forPattern("dd/mm/yyyy");
            this.debut = LocalDate.parse(debut, dtf);
        }
        catch(IllegalArgumentException ex)
        {
            throw new InvalidFieldException("La date de début n'est pas valide");
        }
       
    }

    public LocalDate getFin() {
        return fin;
    }

    public String getId() {
        return id;
    }

    public void setFin(String fin) throws InvalidFieldException {
        try{ 
            DateTimeFormatter dtf = DateTimeFormat.forPattern("dd/mm/yyyy");
            this.fin = LocalDate.parse(fin, dtf);
        }
        catch(IllegalArgumentException ex)
        {
            throw new InvalidFieldException("La date de fin n'est pas valide");
        }
        if(debut != null)
        {
            if(debut.compareTo(getFin()) > 0)
            {
                throw new InvalidFieldException("La date de début est après la date de fin");
            }
        }
     
    }

    public Integer getFilm() {
        return film;
    }

    public void setFilm(String film) throws InvalidFieldException {
          try {
            this.film = Integer.valueOf(film);

        } catch (NumberFormatException e) {
            throw new InvalidFieldException("L'identifiant du film n'est pas un nombre");
        }
    }

    public Integer getCopie() {
        return copie;
    }

    public void setCopie(String copie) throws InvalidFieldException {
        try {
            this.copie = Integer.valueOf(copie);

        } catch (NumberFormatException e) {
            throw new InvalidFieldException("Le nombre de copie n'est pas un nombre");
        }

    }

    public Integer getSalle() {
        return salle;
    }

    public void setSalle(String salle) throws InvalidFieldException {
           try {
            this.salle = Integer.valueOf(salle);

        } catch (NumberFormatException e) {
            throw new InvalidFieldException("Le numéro de la salle n'est pas un nombre");
        }
    }

    public LocalTime getHeure() {
        return heure;
    }

    public void setHeure(String heure) throws InvalidFieldException {
        try{
            DateTimeFormatter dtf = DateTimeFormat.forPattern("kk:mm");
            this.heure = LocalTime.parse(heure, dtf);
        }
        catch(IllegalArgumentException ex)
        {
            throw new InvalidFieldException("L'heure indiquée n'est pas valide");
        }
    }
    
    @Override
    public String toString(){
        return "ID : "+ id +" | Début : "+getDebut().toString() + " | Fin : " +getFin().toString() + " | Film : "+getFilm()+ " | Copie : "+getCopie()+ " | Salle : "+getSalle() + " | Heure " + getHeure();
                
    }

    private void generateId() {
        try {
            SecureRandom prng = SecureRandom.getInstance("SHA1PRNG"); //TO DO : static
            id = new Integer(prng.nextInt()).toString();
        } catch (NoSuchAlgorithmException ex) {
            Logger.getLogger(Programmation.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    
}
