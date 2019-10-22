<?php
	$extensao = substr($_REQUEST['url'], -4);
    $image_data = file_get_contents($_REQUEST['url']);
	$fileName = pathinfo($_REQUEST['url']);
	$licenseId = str_replace("clinic", "", $_GET['B']);

    print(json_encode([
        "ext"=>$extensao,
        "url" => $fileName
    ]));
    
	if($extensao==".png" || $extensao==".jpg" || $extensao==".bmp" || $extensao==".gif" || $extensao=="jpeg"){
		//    $image_data = file_get_contents("http://featherfiles.aviary.com/2014-09-03/1b534c0e712db524/a4935a0d4dc548a58313217577f316c0.jpg");
		file_put_contents("E:\\uploads\\{$licenseId}\\Imagens\\".$fileName[basename], $image_data);
//		file_put_contents("E:\\uploads", $image_data);

		$db = mysqli_connect($_GET['IP'], 'root', 'pipoca453', $_GET['B']);
		$sql = "insert into arquivos (NomeArquivo, Tipo, PacienteID) values ('".$fileName[basename]."', 'I', ".$_GET['PacienteID'].")";
		$consulta = mysqli_query($db, $sql);
		mysqli_close($db);
	}
//echo substr($_REQUEST['url'], -4);
//header("location:dropzoneDB.asp?FileName=".$fileName[basename]."&Tipo=I&PacienteID=".$_GET['PacienteID']);
?>