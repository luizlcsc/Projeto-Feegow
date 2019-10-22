<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
Novas respostas:
<?php
header('Content-Type: text/html; charset=iso-8859-1');
error_reporting(E_ALL);
ini_set("display_errors", "1");

function retira_acentos($texto){
 return strtr($texto, "áàãâéêíóôõúüçÁÀÃÂÉÊÍÓÔÕÚÜÇ", "aaaaeeiooouucAAAAEEIOOOUUC");
}


$xml = file_get_contents("https://webservices.twwwireless.com.br/reluzcap/wsreluzcap.asmx/BuscaSMSMONaoLido?NumUsu=feegow&Senha=fee177");
//$xml = iconv('UTF-8', 'ISO-8859-1//TRANSLIT', $xml);
$DOM = new DOMDocument('1.0', 'iso-8859-1');
$DOM->loadXML($xml);
$Respostas = $DOM->getElementsByTagName('SMSMO');
?>
<ul>
<?php
$dbc = mysqli_connect("localhost", "root", "pipoca453", "cliniccentral") or die("Erro de conexao");
$query = "";

foreach($Respostas as $Resposta) {
	$seunum = utf8_decode($Resposta->getElementsByTagName("seunum")->item(0)->nodeValue);
	$celular = utf8_decode($Resposta->getElementsByTagName("celular")->item(0)->nodeValue);
	$mensagem = utf8_decode($Resposta->getElementsByTagName("mensagem")->item(0)->nodeValue);
	$status = utf8_decode($Resposta->getElementsByTagName("status")->item(0)->nodeValue);
	$datarec = utf8_decode($Resposta->getElementsByTagName("datarec")->item(0)->nodeValue);
	$dataenv = utf8_decode($Resposta->getElementsByTagName("dataenv")->item(0)->nodeValue);
	$datastatus = utf8_decode($Resposta->getElementsByTagName("datastatus")->item(0)->nodeValue);
	$op = utf8_decode($Resposta->getElementsByTagName("op")->item(0)->nodeValue);
	//echo '<li>'.utf8_decode($Resposta->getElementsByTagName("mensagem")->item(0)->nodeValue).' - '.utf8_decode($Resposta->getElementsByTagName("celular")->item(0)->nodeValue).'</li>';
	//echo $mensagem;
	$query = "insert into smsmo (seunum, celular, mensagem, `status`, datarec, dataenv, datastatus, op) values ('".$seunum."', '".$celular."', '".retira_acentos($mensagem)."', '".$status."', '".$datarec."', '".$dataenv."', '".$datastatus."', '".$op."')";
	echo $query;
	mysqli_query($dbc, $query) or die(mysqli_error(mysqli_error($dbc)));
}
if($query!=""){
	header("location:salvaMO.asp");
}
?>
</ul>

</body>
</html>