<?php
    $data = $_REQUEST['data'];
	$licenseId = str_replace("clinic", "", $_GET['B']);

    if (preg_match('/^data:image\/(\w+);base64,/', $data, $type)) {
        $data = substr($data, strpos($data, ',') + 1);
        $type = strtolower($type[1]); // jpg, png, gif
    
        if (!in_array($type, [ 'jpg', 'jpeg', 'gif', 'png','bmp' ])) {
            throw new \Exception('invalid image type');
        }
    
        $data = base64_decode($data);
        $extensao = '.'.$type;
        $fileName = uniqid().$extensao;

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
        "ext"=>$extensao,
        "url" => $fileName
    ]));

	if($extensao==".png" || $extensao==".jpg" || $extensao==".bmp" || $extensao==".gif" || $extensao=="jpeg"){
		file_put_contents("E:\\uploads\\{$licenseId}\\Imagens\\".$fileName[basename], $image_data);

		$db = mysqli_connect($_GET['IP'], 'root', 'pipoca453', $_GET['B']);
		$sql = "insert into arquivos (NomeArquivo, Tipo, PacienteID) values ('".$fileName[basename]."', 'I', ".$_GET['PacienteID'].")";
		$consulta = mysqli_query($db, $sql);
		mysqli_close($db);
    }
    
?>