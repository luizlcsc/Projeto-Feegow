<?php
/**
 * Created by PhpStorm.
 * User: Vinicius
 * Date: 25/10/2016
 * Time: 17:02
 */

function connect(){
    $mysqli = new mysqli('localhost',getenv("FC_MYSQL_USER"),getenv("FC_MYSQL_PASSWORD"),"cliniccentral");
    return $mysqli;
}

$agendamento = $_POST['agendamento'];
$msg = $_POST['msg'];
$licenca_id = str_replace("clinic","",$_POST['licenca']);
$celular = "55".str_replace(array("(",")"," ","-"),array("","","",""),$_POST['celular']);

$sql = "INSERT INTO smsfila (LicencaID,DataHora,AgendamentoID,Mensagem,Celular) VALUES (?,NOW(),?,?,?);";
$mysqli = connect();

if($stmt = $mysqli->prepare($sql)){
    $stmt->bind_param("iiss",$licenca_id,$agendamento,$msg,$celular);
    $stmt->execute();
    $stmt->close();
}

$mysqli->close();