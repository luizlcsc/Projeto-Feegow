<?php
$ds = DIRECTORY_SEPARATOR;  //1
ini_set('post_max_size', '25M');
ini_set('upload_max_filesize', '25M');
$storeFolder = 'uploads';   //2
$pasta = $_GET['Pasta'];

if (!empty($_FILES)) {

    $tempFile = $_FILES['file']['tmp_name'];          //3

    $ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
    $fileName = md5(uniqid(time())) . "." . $ext;

    $l = $_GET['L'];

    if (is_numeric($l)) {

        //$targetPath = dirname( __FILE__ ) . $ds. $storeFolder . $ds;  //4
        //$targetPath = "E:\\uploads\\". $l ."\\". $pasta ."\\";
        $targetPath = "E:\\uploads\\" . $l . "\\" . $pasta . "\\";

        //    cria o folder caso nao  exista
        if (!file_exists($targetPath)) {
            if (!file_exists("E:\\uploads\\" . $l)) {
                mkdir("E:\\uploads\\" . $l);
            }
            mkdir($targetPath);
        }

        $targetFile = $targetPath . $fileName;  //5
        // 	echo  $_FILES['file']['name'];
        //move_uploaded_file($tempFile,$targetFile); //6
        if (move_uploaded_file($tempFile, $targetFile)) {

            $fileExists = file_exists($targetFile);
            if (!$fileExists) {
                throw new Exception("Upload não realizado.");
            } else {
                print($targetFile);
                header("location:dropzoneDB.asp?PacienteID=" . @$_GET['PacienteID'] . "&FileName=" . $fileName . "&ExameID=" . @$_GET['ExameID'] . "&MovementID=" . @$_GET['MovementID'] . "&guiaID=" . @$_GET['guiaID'] . "&tipoGuia=" . @$_GET['tipoGuia'] . "&Tipo=" . $_GET['Tipo'] . "&LaudoID=" . $_GET['LaudoID'] . "&OldName=" . $_FILES['file']['name']);
            }
        } else {
            throw new Exception("Upload não realizado.");
        }
    }
}
?>

