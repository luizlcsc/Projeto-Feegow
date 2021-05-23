<?php
	$extensao = substr($_REQUEST['url'], -4);
    $image_data = file_get_contents($_REQUEST['url']);
	$fileName = pathinfo($_REQUEST['url']);
    $data = $_REQUEST['data'];
	$licenseId = str_replace("clinic", "", $_GET['B']);


	if (preg_match('/^data:image\/(\w+);base64,/', $data, $type)) {
        $data = substr($data, strpos($data, ',') + 1);
        $type = strtolower($type[1]); // jpg, png, gif
    
        if (!in_array($type, [ 'jpg', 'jpeg', 'gif', 'png','bmp' ])) {
            throw new \Exception('invalid image type');
        }
    
        $data = base64_decode($data);

        if ($data === false) {
            throw new \Exception('base64_decode failed');
        }
        
        $image_data = $data;
        $extensao = '.'.$type;
        $fileName = uniqid().$extensao;

    } else {
        throw new \Exception('did not match data URI with image data');
	}
	
    print(json_encode([
		"novo"=> "ok",
        "ext"=>$extensao,
        "url" => $fileName
    ]));
    
	if($extensao==".png" || $extensao==".jpg" || $extensao==".bmp" || $extensao==".gif" || $extensao=="jpeg"){
		file_put_contents("E:\\uploads\\{$licenseId}\\Imagens\\".$fileName, $image_data);

		$db = mysqli_connect($_GET['IP'], getenv("FC_MYSQL_USER"), getenv("FC_MYSQL_PASSWORD"), $_GET['B']);
		$sql = "insert into arquivos (NomeArquivo, Tipo, PacienteID) values ('".$fileName."', 'I', ".$_GET['PacienteID'].")";
		$consulta = mysqli_query($db, $sql);
		mysqli_close($db);
	}
//echo substr($_REQUEST['url'], -4);
//header("location:dropzoneDB.asp?FileName=".$fileName[basename]."&Tipo=I&PacienteID=".$_GET['PacienteID']);
?>