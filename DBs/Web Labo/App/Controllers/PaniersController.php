<?php
/**
 * Created by PhpStorm.
 * User: florentcardoen
 * Date: 12/12/2016
 * Time: 16:14
 */

namespace App\Controllers;


use App\Helpers\PanierSession;
use Core\Lib\Debug;
use App\Helpers\OConnect;

class PaniersController extends AppController
{
    /* Le panier est gardé dans $_SESSION */
    public $hasModel = false;
    private $panier;
    public function __construct($Request, $name)
    {
        parent::__construct($Request, $name);
        $this->panier = new PanierSession();
    }

    public function index()
    {
        $d["panier"] = $this->panier->getPanier();
        $d["debug"] = $this->panier;
        $this->set($d);

    }
    public function add()
    {
        if(!$this->Request->isPost)
            $this->redirect("panier/index");

        $this->panier->addToPanier($this->Request->data);

        $this->redirect("paniers/index");
    }
    public function reset()
    {
        $this->panier->resetPanier();

        $this->redirect("paniers/index");

    }
    public function remove($identifier, $quantite = 0)
    {
        if(!$this->Request->isPost)
            $this->redirect("paniers/index");

        $this->panier->removeFromPanier($this->Request->data->seance, $quantite);
        $this->redirect("paniers/index");
    }
    public function validate()
    {
        $d["document"] = $this->panier->validatePanier();


        $ora = new OConnect("CC", "10.59.14.83", "1521", "orcl");
        $conn = $ora->getConnection();

        $stid = oci_parse($conn, 'begin :r := recherche_place_package.commandeplace(:doc); end;');

        $response = oci_new_descriptor($conn, OCI_D_LOB);
        $document = oci_new_descriptor($conn, OCI_D_LOB);
        oci_bind_by_name($stid, ':doc', $document, -1, OCI_B_CLOB);
        $xml = simplexml_load_string($this->panier->validatePanier2());
        $document->writeTemporary($xml->asXML());

        oci_bind_by_name($stid, ":r", $response, -1, OCI_B_CLOB);
        oci_execute($stid);
        oci_free_statement($stid);
        oci_close($conn);

        $d["response"] = new \SimpleXMLElement($response->load());
        $d["isvalid"] = true;
        /*
         *
         * 0 valide
         * 1 erreur de projection
         * 2 plus du tout
         * 3 nombre [available] seulement disponible
         *
         */



        $this->set($d);



    }


}