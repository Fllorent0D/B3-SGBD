<?php
namespace App\Controllers;
use App\Helpers\OClient;
use App\Helpers\OConnect;
use App\Helpers\Seance;
use Core\Lib\Debug;

class RecherchesController extends AppController
{
    public $hasModel = false;
    public function index()
    {
        $ora = new OClient();
        try{
            $d["films"] = $ora->getHoraire();
        }
        catch (\Exception $ex)
        {
            $this->Session->setFlash("Une erreur est arrivée avec la base de données.");
            $this->redirect("/");
        }
        $this->set($d);
    }
    public function recherche()
    {

        $ora = new OClient();
        $d["actors"] = $ora->getActors();
        $d["genres"] = $ora->getGenres();
        //Debug::debug($d);
        $this->set($d);

    }

    public function film($id = null)
    {
        if(is_null($id))
            $this->redirect(["recherche", "index"]);

        try{
            $ora = new OClient();
            $d["infos"] = $ora->getFilmInfo($id);
            $seances = $ora->getFilmSchedule($id);
        }
        catch (\Exception $ex)
        {
            $this->Session->setFlash("Une erreur est survenue. Merci re réessayer plus tard");
            $this->redirect("recherches/index");
        }

        $d["select_options"] = $d["schedule"] = array();

        foreach ($seances as $seance)
        {
            $s = new Seance($seance);
            $d["select_options"][$s->getIdentifier()] = $s->__toString();

            if(!isset($d["schedule"][$s->getDate()]))
                $d["schedule"][$s->getDate()] = array();

            array_push($d["schedule"][$s->getDate()], $s);
        }

        $this->set($d);

    }

}