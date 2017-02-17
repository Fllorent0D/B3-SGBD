/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package creaprog;

import Exceptions.FileInputNotExistsException;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import org.apache.commons.cli.*;
import org.joda.time.format.DateTimeFormat;
import org.w3c.dom.*;
import org.xml.sax.SAXException;

/**
 *
 * @author florentcardoen
 */
public class CreaProg {
    private File input;
    private File output;
    private boolean hasHeader;
    private String regex = "(?<=;|^)([^;]*)(?=;|$)";
    private String separator = ";";
    private CSVParser parser;
    private ArrayList<Programmation> prog;
    private Document doc;
    
    public CreaProg(String input, String output, String log, String verbose, boolean header) throws FileInputNotExistsException
    {  
        LogManager.setVerbose(Integer.parseInt(verbose));        
        if(!log.isEmpty())
            LogManager.setFile(log);
        
        setInput(input);
        setOutput(output);
        setHeader(header);
        
        LogManager.log("Instanciation du parser", 3);
        parser = new CSVParser(getInput(), regex, hasHeader);

    }
    
    public void setHeader(boolean header){
        this.hasHeader= header;
        LogManager.log("Document contenant un header : " + header, 2);

    }

    public void setOutput(String o)
    {
        if(o.isEmpty())
        {
            o = Paths.get(input.getAbsolutePath()).getParent().toString() + 
                System.getProperty("file.separator") + 
                input.getName().toString().substring(0, input.getName().toString().indexOf('.')+1) + "xml";
        }
        output = new File(o);
        LogManager.log("Fichier sortie utilisé : " + output.getAbsolutePath(), 2);

    }
    public void setInput(String i) throws FileInputNotExistsException
    {
        if(i.isEmpty())
            throw new FileInputNotExistsException("Le ficher en entrée n'est pas spécifié");
        
        input = new File(i);
        
        if(!input.exists())
            throw new FileInputNotExistsException("Le fichier donné en entrée n'existe pas.");
        
        Pattern p = Pattern.compile("^prog_\\d{4}_\\d{2}_\\d{2}_\\d+.csv$");
        Matcher m = p.matcher(input.getName());
        if(!m.matches())
            throw new FileInputNotExistsException("Le fichier donné n'a pas un nom correct.");
        LogManager.log("Fichier entrée utilisé : " + input.getAbsolutePath(), 2);

    }
    public File getInput() {
        return input;
    }
    private void createXML() {
        prog = parser.parse();
        
        if(!prog.isEmpty()){
            createDocument();

            if(validateDom())
                writeFile();
        }
        else
            LogManager.log("Aucun film n'a été parsé", -1);
        
        
        LogManager.closeLog();
    }
    
    
    private void createDocument()
    {
        try {
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            
            // root elements
            doc = docBuilder.newDocument();
            Element rootElement = doc.createElement("programmation");
            doc.appendChild(rootElement);
            
            for(Programmation pr : prog){
                Element proj = doc.createElement("demande");

                //Element id = doc.createElement("idDemande");
                proj.setAttribute("idDemande", pr.getId());
                
                Element debut = doc.createElement("debut");
                debut.appendChild(doc.createTextNode(pr.getDebut().toString(DateTimeFormat.forPattern("yyyy-MM-dd"))));
                
                Element fin = doc.createElement("fin");
                fin.appendChild(doc.createTextNode(pr.getFin().toString(DateTimeFormat.forPattern("yyyy-MM-dd"))));
                
                Element film = doc.createElement("idMovie"); 
                film.appendChild(doc.createTextNode(pr.getFilm().toString()));
                
                Element copie = doc.createElement("numCopy");
                copie.appendChild(doc.createTextNode(pr.getCopie().toString()));
                
                Element salle = doc.createElement("salle");
                salle.appendChild(doc.createTextNode(pr.getSalle().toString()));
                
                Element heure = doc.createElement("heure");
                heure.appendChild(doc.createTextNode(pr.getHeure().toString(DateTimeFormat.forPattern("kk:mm:ss"))));
                
                //proj.appendChild(id);
                proj.appendChild(film);
                proj.appendChild(copie);
                proj.appendChild(debut);
                proj.appendChild(fin);
                proj.appendChild(salle);
                proj.appendChild(heure);
                rootElement.appendChild(proj);
            }
            LogManager.log("Document généré en mémoire", 1);
        } catch (ParserConfigurationException ex) {
            LogManager.log("Impossible de créer un document en mémoire.", -1);
            LogManager.log(ex.getMessage(), 3);
        } 
    }
    private boolean validateDom() {
        try {
            SchemaFactory factory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
            File xsd = new File("programmation.xsd");
            if(!xsd.exists())
            {
                LogManager.log("Fichier XSD introuvable",-1);
                System.exit(0);
            }
            LogManager.log("XSD utilisé : " + xsd.getAbsolutePath(), 2);
            Source schemaFile = new StreamSource(xsd);
            Schema schema = factory.newSchema(schemaFile);
            
            Validator validator = schema.newValidator();
            
                    
            validator.validate(new DOMSource(doc));
            LogManager.log("Document mémoire validé avec le XSD", 1);

            return true;
        } catch (SAXException | IOException ex) {
            LogManager.log("Impossible de valider le document généré." + ex.getLocalizedMessage(), -1);
            LogManager.log(ex.getMessage(), 3);

            return false;
        }
    }

    private void writeFile() { 
        try {
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            //transformer.setOutputProperties(oformat);
            DOMSource source = new DOMSource(getDoc());
            StreamResult result = new StreamResult(getOutput());
            transformer.transform(source, result);
            LogManager.log("Document mémoire transformé en XML", 1);

        } catch (TransformerException ex) {
            LogManager.log("Impossible de tranformer l'arbre créé en mémoire en document XML.", -1);
            LogManager.log(ex.getMessage(), 3);
        }
    }

    public File getOutput() {
        return output;
    }

    public Document getDoc() {
        return doc;
    }
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        Option helpOption = Option.builder("h")
                         .longOpt("help")
                         .required(false)
                         .desc("Afficher ce message")
                         .build();

        Option inputOption = Option.builder("i")
                             .longOpt("input")
                             .hasArg()
                             .required(false)
                             .desc("Chemin relatif du fichier CSV en entrée")
                             .build();

        Option outputOption = Option.builder("o")
                             .longOpt("output")
                             .required(false)
                             .hasArg()
                             .desc("Chemin du fichier XML en sortie")
                             .build();
        Option verboseOption = Option.builder("v")
                             .longOpt("verbose")
                             .required(false)
                             .hasArg()
                             .desc("Niveau de log affiché lors du traitement")
                             .build();
        Option logOption = Option.builder("l")
                            .longOpt("log")
                            .required(false)
                            .hasArg()
                            .desc("Fichier utilisé pour les logs")
                            .build();
        
        Option headerOption = Option.builder("he")
                            .longOpt("header")
                            .required(false)
                            .desc("Spécifier si le fichier contient un header")
                            .build();        
        
        Options options = new Options();
        options.addOption(helpOption);
        options.addOption(inputOption);
        options.addOption(outputOption);
        options.addOption(verboseOption);
        options.addOption(logOption);
        options.addOption(headerOption);

        CommandLineParser parser = new DefaultParser();
        CommandLine cmdLine;
        try {
            cmdLine = parser.parse(options, args);
            if (cmdLine.hasOption("help")) 
            {
                HelpFormatter formatter = new HelpFormatter();
                formatter.printHelp("CreaProg", options);
                System.exit(1);
            }
            
            CreaProg singleton = new CreaProg(cmdLine.getOptionValue('i', ""), cmdLine.getOptionValue('o', ""), cmdLine.getOptionValue('l', ""), cmdLine.getOptionValue('v', "0"), cmdLine.hasOption("he"));
            singleton.createXML();   
        
        } catch (ParseException | FileInputNotExistsException ex) {
            
            LogManager.log("Erreur:" + ex.getMessage() , -1);
            System.exit(0);
        } 

       
    }

    




    
}
