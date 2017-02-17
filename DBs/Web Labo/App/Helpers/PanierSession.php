<?php
/**
 * Created by PhpStorm.
 * User: florentcardoen
 * Date: 12/12/2016
 * Time: 11:09
 */

namespace App\Helpers;


class PanierSession implements IPanier
{
    public function getPanier() : array
    {
        if(!isset($_SESSION["panier"]))
            $_SESSION["panier"] = array();
        return $_SESSION["panier"];
    }

    public function addToPanier($data)
    {
        if(isset($_SESSION["panier"][$data->seance]))
        {
            if($_SESSION["panier"][$data->seance]["quantite"] + $data->quantite <= 0)
                $this->removeFromPanier($data->seance);
            else
                $_SESSION["panier"][$data->seance]["quantite"] = $_SESSION["panier"][$data->seance]["quantite"] + $data->quantite;

        }
        else{
            $_SESSION["panier"][$data->seance]["projection"] = explode("#", $data->seance)[0];
            $_SESSION["panier"][$data->seance]["date"] = explode("#", $data->seance)[1];
            $_SESSION["panier"][$data->seance]["quantite"] = (int)$data->quantite;
            $_SESSION["panier"][$data->seance]["film"] = $data->film;
        }
    }

    public function removeFromPanier($data, $quantite)
    {
        if($quantite != 0)
        {
            $_SESSION["panier"][$data->seance]["quantite"] = $_SESSION["panier"][$data->seance]["quantite"] - $quantite;
            return;
        }


        if(isset($_SESSION["panier"][$data]))
        {
            unset($_SESSION["panier"][$data]);
        }
        else
        {
            throw new \Exception("Vous avez essayé de supprimer une réservation ne se trouvant pas dans votre panier.");
        }
    }

    public function validatePanier()
    {
        $imp = new \DOMImplementation;
        $dtd = $imp->createDocumentType('panier', '-//W3C//DTD XHTML 1.0 Transitional//FR', "http://bp.dev/App/Webroot/dtd/panier.dtd");
        $dom = $imp->createDocument("", "", $dtd);
        $dom->encoding = 'UTF-8';
        $dom->standalone = false;
        $dom->formatOutput = true;
        $root = $dom->createElement('panier');
        $dom->appendChild($root);


        foreach ($_SESSION["panier"] as $ticket)
        {
            $elem = $dom->createElement('place');
            $elem->appendChild(new \DOMElement("projection", $ticket["projection"]));
            $elem->appendChild(new \DOMElement("date", $ticket["date"]));
            $elem->appendChild(new \DOMElement("quantite", $ticket["quantite"]));
            $root->appendChild($elem);
        }

        if ($dom->validate()) {
            echo "Ce document est valide !\n";
        }
        else
        {
            echo "Ce document n'est pas valide! \n";
        }
        return $dom->saveXML();
    }
    public function validatePanier2()
    {
        $dom = new \DOMDocument();
        $root = $dom->createElement('panier');
        $dom->appendChild($root);


        foreach ($_SESSION["panier"] as $ticket)
        {
            $elem = $dom->createElement('place');
            $elem->appendChild(new \DOMElement("projection", $ticket["projection"]));
            $elem->appendChild(new \DOMElement("date", $ticket["date"]));
            $elem->appendChild(new \DOMElement("quantite", $ticket["quantite"]));
            $root->appendChild($elem);
        }

        return $dom->saveXML();
    }
    public function resetPanier()
    {
        unset($_SESSION["panier"]);

    }

}