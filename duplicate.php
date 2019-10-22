<?php
$fileName = $_GET['file'];
$ext = pathinfo($fileName, PATHINFO_EXTENSION);
$newFileName = md5(uniqid(time())).".".$ext;

$ds = DIRECTORY_SEPARATOR;  //1
$storeFolder = 'uploads';   //2
$targetPath = dirname( __FILE__ ) . $ds. $storeFolder . $ds;  //4
$file = $targetPath. $fileName;  //5
$newFile = $targetPath.$newFileName;
copy($file, $newFile);
header("location:dropzoneDB.asp?file=".$fileName."&newFile=".$newFileName."&Duplicate=true");
?>