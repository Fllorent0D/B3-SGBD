<?php
/**
 * Created by PhpStorm.
 * User: florentcardoen
 * Date: 12/12/2016
 * Time: 11:10
 */

namespace App\Helpers;
use Carbon\Carbon;
use Symfony\Component\Translation\Tests\StringClass;


class Seance
{
    private $idSalle;
    private $idProjection;
    public $date;
    public $capacite;
    public $reservations;

    public function __construct($seance)
    {
        $this->idSalle = $seance->numSalle->__toString();
        $this->idProjection = $seance->idProjection->__toString();
        $this->date = Carbon::parse($seance->date)->setTimeFromTimeString(Carbon::parse($seance->heure)->toTimeString());
        $this->capacite = $seance->capacite->__toString();
        $this->reservations = $seance->reservations->__toString();
    }

    public function getIdentifier() : String
    {
        return $this->idProjection . "#" . $this->date->format("Y-m-d");
    }

    public function __toString() : String
    {
        return $this->date->format("\\L\\e d F \\à G:m ") . " salle n°".$this->idSalle;
    }

    public function getDate() : String{
        return $this->date->format("Y-m-d");
    }
    public function placeRestantes()
    {
        return (isset($this->reservations) and isset($this->capacite))? $this->capacite - $this->reservations : $this->capacite;
    }

}