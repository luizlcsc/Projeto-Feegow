<?php
$target_dir = "E:\\uploads\\". $_GET['L'] ."\\Perfil\\";


//    cria o folder caso nao  exista
if(!file_exists($target_dir)){
    if(!file_exists("E:\\uploads\\" . $_GET['L'])){
        mkdir("E:\\uploads\\" . $_GET['L']);
    }
    mkdir($target_dir);
}

$fileName = md5("_" . $_GET['I'] . "_" . uniqid(time())) . ".jpg";
$target_file = $target_dir . $fileName;
$uploadOk = 1;
$imageFileType = pathinfo($target_file, PATHINFO_EXTENSION);
// Check if image file is a actual image or fake image
if (isset($_POST["submit"])) {
    $check = getimagesize($_FILES["fileToUpload"]["tmp_name"]);
    if ($check !== false) {
        echo "File is an image - " . $check["mime"] . ".";
        $uploadOk = 1;
    } else {
        echo "File is not an image.";
        $uploadOk = 0;
    }
}
// Check if file already exists
if (file_exists($target_file)) {
    echo "Sorry, file already exists.";
    $uploadOk = 0;
}
// Check file size
if ($_FILES["fileToUpload"]["size"] > 500000) {
    echo "Sorry, your file is too large.";
    $uploadOk = 0;
}
// Allow certain file formats
if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
    && $imageFileType != "gif"
) {
    echo "Sorry, only JPG, JPEG, PNG & GIF files are allowed.";
    $uploadOk = 0;
}
// Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
    echo "Sorry, your file was not uploaded.";
// if everything is ok, try to upload file
} else {
    if (move_uploaded_file($_FILES["Foto"]["tmp_name"], $target_file)) {
        echo "The file " . $target_file . " has been uploaded.";
    } else {
        echo "Sorry, there was an error uploading your file.";
    }
}

header("location:FotoUploadSave.asp?P=" . $_GET['P'] . "&I=" . $_GET['I'] . "&Col=" . $_GET['Col'] . "&Action=Insert&FileName=" . $fileName);

?> 