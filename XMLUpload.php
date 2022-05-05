<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$target_dir = "C:\\inetpub\\wwwroot\\temp\\xml-retorno\\";
$fileName = md5( uniqid(time())) . ".xml";
$target_file = $target_dir . $fileName;
$uploadOk = 1;
$imageFileType = pathinfo($target_file, PATHINFO_EXTENSION);

if (file_exists($target_file)) {
    echo "Sorry, file already exists.";
    $uploadOk = 0;
}
// Check file size
if ($_FILES["arquivo"]["size"] > 1000000) {
    echo "Sorry, your file is too large.";
    $uploadOk = 0;
}
// Allow certain file formats
if ($imageFileType != "xml") {
    echo "XML invalido.";
    $uploadOk = 0;
}
// Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
    echo "Sorry, your file was not uploaded.";
// if everything is ok, try to upload file
} else {
    if (move_uploaded_file($_FILES["arquivo"]["tmp_name"], $target_file)) {
        //echo "The file " . $target_file . " has been uploaded.";
		echo "{status: 'OK'}";
    } else {
        echo "Sorry, there was an error uploading your file.";
    }
}

header("location:XMLUploadSave.asp?FileName=" . $fileName);

?>