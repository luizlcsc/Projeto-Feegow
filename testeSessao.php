<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

function sessao($Nome){
       
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL,'http://localhost/feegowclinic/valSession.asp?N='.$Nome);
    curl_exec($ch);
    $valor = curl_exec($ch);
    return $valor;
}

var_dump( sessao("Banco"));