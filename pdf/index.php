<?php 
error_reporting(E_ALL);
ini_set('display_errors', 1);

	include("mpdf60/mpdf.php");

/*	$html = "
	 <fieldset>
	 	<h1>Recibo</h1>
	 	<p class='center sub-titulo'>
	 		Nº <strong>0001</strong> - 
	 		VALOR <strong>R$ 500,00</strong>
	 	</p>
	 	<p>Recebi(emos) de <strong>Carlos Domingues Neto</strong></p>
	 	<p>a quantia de <strong>Quinhentos Reais</strong></p>
	 	<p>Correspondente a <strong>Serviços prestados ..<strong></p>
	 	<p>e para clareza firmo(amos) o presente.</p>
	 	<p class='direita'>São Roque, 25 de Dezembro de 2015</p>
	 	<p>Assinatura ......................................................................................................................................</p>
	 	<p>Nome <strong>João da Silva Nogueira</strong> CPF/CNPJ: <strong>222.222.222-02</strong></p>
	 	<p>Endereço <strong>Rua da Penha, 200 - Jd. Alguma Coisa - São Paulo</strong></p>
	 </fieldset>";*/
	
$getdata = http_build_query(
array(
    'PropostaID' => '158',
    'U' => '111'
 )
);


$opts = array('http' =>
 array(
    'method'  => 'GET',
    'content' => $getdata
)
);

$context  = stream_context_create($opts);











 
	$html = file_get_contents ("http://127.0.0.1/feegowclinic/templateProposta.asp?".$getdata, false, $context);

	$mpdf=new mPDF('utf-8', 'A4-L'); 
	$mpdf->SetDisplayMode('fullpage');
	$css = file_get_contents("css/estilo.css");
	$mpdf->WriteHTML($css,1);
	$mpdf->WriteHTML($html);
//	$mpdf->Output();   //aqui funciona exibindo na tela
    
//    $arquivo = $_GET['Arquivo'];

//    $mpdf->Output( $arquivo .'.pdf','F'); //aqui funciona salvando o arquivo








//testeeeeeeeeeeeeeeeeeeeeee
/*
$content = $mpdf->Output('', 'S');
$content = chunk_split(base64_encode($content));
$mailto = 'maia_silvio@hotmail.com.com';
$from_name = 'Silvio Maia';
$from_mail = 'silvio@feegow.com.br';
$replyto = 'silvio@feegow.com.br';
$uid = md5(uniqid(time()));
$subject = 'Primeira tentativa de envio';
$message = 'Esta é a mensagem.';
$filename = 'proposta.pdf';
$header = "From: ".$from_name." <".$from_mail.">\r\n";
$header .= "Reply-To: ".$replyto."\r\n";
$header .= "MIME-Version: 1.0\r\n";
$header .= "Content-Type: multipart/mixed; boundary=\"".$uid."\"\r\n\r\n";
$header .= "This is a multi-part message in MIME format.\r\n";
$header .= "--".$uid."\r\n";
$header .= "Content-type:text/plain; charset=iso-8859-1\r\n";
$header .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
$header .= $message."\r\n\r\n";
$header .= "--".$uid."\r\n";
$header .= "Content-Type: application/pdf; name=\"".$filename."\"\r\n";
$header .= "Content-Transfer-Encoding: base64\r\n";
$header .= "Content-Disposition: attachment; filename=\"".$filename."\"\r\n\r\n";
$header .= $content."\r\n\r\n";
$header .= "--".$uid."--";
$is_sent = @mail($mailto, $subject, "", $header);
$mpdf->Output();
*/
	exit;