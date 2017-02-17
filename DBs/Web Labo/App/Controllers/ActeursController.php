<?php

namespace App\Controllers;

class ActeursController extends AppController
{
    public $hasModel = false;

    public function index()
    {
        if($this->Request->isPost)
        {
            $this->redirect("acteurs/affiche/".$this->Request->data->idacteur);
        }
    }
    public function affiche($id)
    {

        if(isset($id) && is_numeric($id))
        {
            try{
                $m = new \MongoDB\Client();
                $collection = $m->selectCollection('people', 'people');
                $d["people"] = $collection->findOne(['_id' => intval($id)]);
                if(is_null($d["people"])) {
                    $this->Session->setFlash("Aucun acteur avec l'id ". $id ." n'a été trouvé", "danger");
                    $this->redirect("acteurs/index");
                }
                $this->set($d);

            }
            catch(\Exception $ex)
            {
                $this->Session->setFlash("Erreur lors de la requête sur la base de données", "danger");
                $this->redirect("acteurs/index");
            }
        }
        else
        {
            $this->Session->setFlash("L'id est manquant ou non numérique", "danger");
            $this->redirect("acteurs/index");
        }
    }

   

}