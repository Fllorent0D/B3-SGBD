<?php
/**
 * Created by PhpStorm.
 * User: florentcardoen
 * Date: 04/12/2016
 * Time: 14:11
 */

namespace App\Helpers;


class OConnect
{
    private $schema;
    private $host;
    private $port;
    private $serviceName ;
    private $connection;

    function __construct($schema, $host, $port, $service)
    {
        $this->schema = $schema;
        $this->port= $port;
        $this->serviceName = $service;
        $this->host = $host;

        $this->connectDB();
    }
    function __destruct()
    {
        \oci_close($this->getConnection());
    }

    private function connectDB()
    {
        @$this->connection = \oci_connect($this->schema, $this->schema, $this->host.':'.$this->port.'/'.$this->serviceName);
        if (!$this->connection) {
            $e = \oci_error();
            throw new \Exception(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
        }
    }

    public function callFunction($funcName, array $args = null, $isClob = false)
    {

        $query = "begin :r := RECHERCHE_PLACE_PACKAGE.". $funcName ."(";
        if(count($args))
        {
            $argsQuery = array();
            foreach ($args as $arg)
            {
                $param = ":p".count($argsQuery);
                $query .= $param.", ";
                $argsQuery[$param] = $arg;
            }
            $query = rtrim($query, ", ");
        }
        $query .= "); end;";

        $stid = oci_parse($this->getConnection(), $query);
        if($isClob)
        {
            $myLOB = oci_new_descriptor($this->connection, OCI_D_LOB);
            oci_bind_by_name($stid, ":r", $myLOB, -1, OCI_B_CLOB);
        }
        else
        {
            oci_bind_by_name($stid, ":r", $result, 40000);
        }

        if(count($args))
        {
            foreach ($argsQuery as $param => $value)
            {
                //var_dump($param);
                oci_bind_by_name($stid, $param, $value); //bug avec plusieurs param
            }
        }

        oci_execute($stid, OCI_DEFAULT);

        if($isClob)
            $result = $myLOB->load();

        return $result;
    }
    public function callProcedure()
    {

    }
    public function getConnection()
    {
        return $this->connection;
    }
    public function executeQuery($string)
    {
        $stid = oci_parse($this->getConnection(), $string);
        oci_execute($stid);
        oci_fetch_all($stid, $res);
        return $res;
    }
    private function generateRandomString($length = 10) {
        return substr(str_shuffle(str_repeat($x='abcdefghijklmnopqrstuvwxyz', ceil($length/strlen($x)) )),1,$length);
    }
}