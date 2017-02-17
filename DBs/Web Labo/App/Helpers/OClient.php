<?php
/**
 * Created by PhpStorm.
 * User: florentcardoen
 * Date: 05/12/2016
 * Time: 11:03
 */

namespace App\Helpers;


class OClient
{
    private $ora;

    /*  constructors */
    function __construct()
    {
        $a = func_get_args();
        $i = func_num_args();

        if($i != 0 AND $i != 4)
            throw new \Exception("Nombre de paramètres incorrect");

        if (method_exists($this,$f='__construct'.$i)) {
            call_user_func_array(array($this,$f),$a);
        }
    }
    private function __construct0()
    {
        $this->ora = new OConnect("CC", "10.59.14.83", "1521", "orcl");
    }
    private function __construct4($schema, $host, $port, $service)
    {
        $this->ora = new OConnect($schema, $host, $port, $service);
    }
    /* End Constructors */

    function getOra() : OConnect
    {
        return $this->ora;
    }
    private function executeFunction($funcName, array $args = null, $isClob = false)
    {
        return $this->getOra()->callFunction($funcName, $args, $isClob);
    }

    function getFilmSchedule($id = null) : \SimpleXMLElement
    {
        if(is_null($id))
            throw new \Exception("L'id du film ne peut pas être null");

        $response = $this->executeFunction("GETFILMSCHEDULE", [$id], true);
        return (new \SimpleXMLElement($response));

    }
    function getGenres(): \SimpleXMLElement
    {
        $response = $this->executeFunction("GETGENRES", [], true);
        return new \SimpleXMLElement($response);
    }
    function getDirectors(): \SimpleXMLElement
    {
        $response = $this->executeFunction("GETDIRECTORS", [], true);
        return new \SimpleXMLElement($response);
    }
    function getActors() : \SimpleXMLElement
    {
        $response = $this->executeFunction("GETACTORS", [], true);
        return (new \SimpleXMLElement($response));
    }
    function getFilmInfo($id = null) : \SimpleXMLElement
    {
        if(is_null($id))
            throw new \Exception("L'id du film ne peut pas être null");

        $response = $this->executeFunction("getfilminfo", [$id], true);
        return (new \SimpleXMLElement($response));

    }

    function getHoraire() : \SimpleXMLElement
    {
        $response =  $this->executeFunction("gethoraire", [], true);
        return new \SimpleXMLElement($response);
    }

    function rechercherfilm($operateurPop, $popularite, $operateurPer, $perenite)
    {
        $response =  $this->executeFunction("recherchefilm", [$operateurPop, $popularite, $operateurPer, $perenite], true); /* Multi param ne marche pas */
        return new \SimpleXMLElement($response);

    }
    function getPoster($idFilm)
    {
        $response = $this->executeFunction("getposter", [$idFilm], true);
        return $response;
    }

}