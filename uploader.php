<?php
ini_set("display_errors", "1");
error_reporting(E_ALL);

$nomeArquivo = date('ymdhisu', time('hisu')) . rand(5);
$nomeArquivo = md5($nomeArquivo).".jpg";
var_dump($data);
$data  = $_POST['photo-data'];
$data = base64_decode(preg_replace('#^data:image/\w+;base64,#i', '', $data));

$l = $_GET['L'];

if(is_numeric($l)) {
    $path = "E:\\uploads\\" . $l . "\\Perfil\\";

//    cria o folder caso nao  exista
    if(!file_exists($path)){
        if(!file_exists("E:\\uploads\\" . $l)){
            mkdir("E:\\uploads\\" . $l);
        }
        mkdir($path);
    }

    file_put_contents($path . $nomeArquivo, $data);
    header("location:FotoUploadSave.asp?Action=InsertCamera&P=" . $_GET['P'] . "&I=" . $_GET['I'] . "&Col=" . $_GET['Col'] . "&FileName=" . $nomeArquivo);

}