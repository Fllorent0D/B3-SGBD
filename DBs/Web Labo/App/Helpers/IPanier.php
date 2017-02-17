<?php
/**
 * Created by PhpStorm.
 * User: florentcardoen
 * Date: 12/12/2016
 * Time: 16:18
 */

namespace App\Helpers;


interface IPanier
{
    public function getPanier() : array;
    public function addToPanier($data);
    public function removeFromPanier($data, $quantite);
    public function validatePanier();
    public function resetPanier();
}