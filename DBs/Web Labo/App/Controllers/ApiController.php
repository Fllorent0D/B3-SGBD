<?php

namespace App\Controllers;
use App\Helpers\OClient;
use App\Helpers\OConnect;

class ApiController extends AppController
{
    /*  API PRIVATE METHODS */
    public $hasModel = false;
    private $status = "success";
    private $data = null;
    public function beforeRender()
    {
        header('Content-Type: application/json');
        $this->needRender = false;

        if($this->status == "error"){
            $key = "message";
            //http_response_code(400);
        }
        else
            $key = "data";
        $response = ["status" => $this->status, $key => $this->data];

        echo json_encode($response);
        die;
    }
    private function setData($data)
    {
        $this->data = $data;
    }
    private function setStatus($status)
    {
        $this->status = $status;
    }
    /*  END API METHODS */


    public function verifacteur($id = null)
    {
        try {
            if ($this->Request->isPost) {

                $inputParam = file_get_contents("php://input");
                $inputParam = json_decode($inputParam);

                if (is_null($inputParam))
                    throw new \Exception("Les paramètres envoyés sont mauvais.");

                if (!isset($inputParam->actor->_id) OR !is_numeric($inputParam->actor->_id))
                    throw new \Exception("L'id de l'acteur n'est pas spécifié dans les paramètres.");

                $id = intval($inputParam->actor->_id);


                $m = new \MongoDB\Client();
                $collection = $m->selectCollection('people', 'people');

                if(isset($inputParam->actor))
                    $result = $collection->updateOne(["_id" => $id], ['$set' => $inputParam->actor], ["upsert" => true]);

                if(isset($inputParam->film))
                {
                    if(!isset($inputParam->film->id))
                        throw new \Exception("L'id du film n'est pas donné en param");

                    $actor = $collection->findOne(['_id' => intval($id)]);
                    $exist = false;
                    foreach ($actor->credits->cast as $film)
                    {

                        if(isset($film->id) AND $film->id == $inputParam->film->id)
                            $exist = true;
                    }
                    if(!$exist)
                    {
                        $newMovie = array();
                        foreach ($inputParam->film as $key => $val)
                        {
                            $newMovie[$key] = $val;
                        }

                        $collection->updateOne(["_id" => $id], ['$push' => array("credits.cast" => $newMovie)]);
                        //Si il n'existe pas on l'ajoute
                    }
                }
            }
            else if ($_SERVER["REQUEST_METHOD"] === 'GET' && isset($id) && is_numeric($id)) {
                $m = new \MongoDB\Client();
                $collection = $m->selectCollection('people', 'people');
                $actor = $collection->findOne(['_id' => intval($id)]);
                //$actor = $collection->find();
                if (is_null($actor))
                    throw new \Exception("Aucun acteur trouvé dans BP");
                else
                    $this->setData($actor);

            } else {
                throw new \Exception("Requete non implémentée.");
            }
        } catch (\Exception $ex) {

            $this->setStatus("error");
            $this->setData($ex->getMessage());
        }
    }
    public function recherche()
    {
        $data = $this->Request->data;

        if((!$this->Request->isPost) OR (!isset($data->opPer) OR !isset($data->per) OR !isset($data->opPop) OR !isset($data->pop) OR !isset($data->title)))
        {
            $this->setStatus("error");
            $this->setData("Requete n'est pas POST");
        }
        else
        {
            try{
                $ora = new OConnect("CC", "10.59.14.83", "1521", "orcl");
                $conn = $ora->getConnection();

                $stid = oci_parse($conn, 'begin :r := recherche_place_package.recherchefilm(:opPop, :pop, :opPer, :per, :title, :acteurs, :genres); end;');
                $myLOB = oci_new_descriptor($conn, OCI_D_LOB);
                oci_bind_by_name($stid, ":r", $myLOB, -1, OCI_B_CLOB);
                oci_bind_by_name($stid, ":opPop", $data->opPop);
                oci_bind_by_name($stid, ":pop", $data->pop);
                oci_bind_by_name($stid, ":opPer", $data->opPer);
                oci_bind_by_name($stid, ":per", $data->per);
                oci_bind_by_name($stid, ":title", $data->title);
                oci_bind_by_name($stid, ":acteurs", $data->acteurs);
                oci_bind_by_name($stid, ":genres", $data->genres);

                oci_execute($stid);
                $resultats = $myLOB->load();

                oci_free_statement($stid);
                oci_close($conn);
                //var_dump($resultats);
                $xml = new \SimpleXMLElement($resultats);
                $result = array();
                foreach ($xml as $film)
                {
                    $elem["id"] = $film->id->__toString();
                    $elem["titre"] = $film->title->__toString();
                    $elem["popularite"] = $film->popularite->__toString();
                    $elem["perennite"] = $film->perennite->__toString();
                    array_push($result, $elem);
                }
                $this->setData($result);

            }
            catch(\Exception $ex)
            {
                $this->setStatus("error");
                $this->setData($ex->getMessage());
            }

        }

    }
    public function poster($id)
    {
        $ora = new OConnect("CC", "10.59.14.83", "1521", "orcl");
        $conn = $ora->getConnection();

        $stid = oci_parse($conn, 'begin :r := recherche_place_package.getposter(:idMovie); end;');
        $myLOB = oci_new_descriptor($conn, OCI_D_LOB);
        oci_bind_by_name($stid, ":r", $myLOB, -1, OCI_B_BLOB);
        oci_bind_by_name($stid, ":idMovie", $id);
        oci_execute($stid);
        oci_free_statement($stid);
        oci_close($conn);

        if(is_null($myLOB))
        {
            $this->redirect("http://bp.dev/App/Webroot/img/unavailable.jpg", true);
        }
        else
        {
            $resultats = $myLOB->load();
            header("Content-type: image/JPEG");
            print $resultats;
        }

        die;
    }

}