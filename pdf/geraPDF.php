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
	
     $html = "<div style='position: absolute; margin-top: 440px; left: 90px; color: #fff;'>
        <h2>Proposta de Implementação</h2>
        <h1>".strtoupper( $_POST['NomeCliente'] )."</h1>
    </div>
    <img src='http://beta.feegow.com.br/pdf/img/p1.png' width='100%' />
    <pagebreak>
    <div style='position:absolute; margin-top:230px; left:590px; width:460px;'>
    <h3>Fundada em 2008, somos uma empresa de tecnologia que tem como missão desenvolver soluções para clínicas e consultórios médicos  baseando-se na experiência do usuário e os problemas que ele encontra no dia-a-dia.</h3>
            </div>
         <img src='http://beta.feegow.com.br/pdf/img/p2.png' width='100%' />

    <pagebreak> 
    <img src='http://beta.feegow.com.br/pdf/img/p3.png' width='100%' />
    <pagebreak> 
    <img src='http://beta.feegow.com.br/pdf/img/p4.png' width='100%' />
    <pagebreak> 
    <img src='http://beta.feegow.com.br/pdf/img/p5.png' width='100%' />
    <pagebreak> 
    <img src='http://beta.feegow.com.br/pdf/img/p6.png' width='100%' />
    <pagebreak> 
    <div style='top:140px; left:83px; position:absolute; width:500px'>
            <h1>INVESTIMENTO MENSAL</h1>
            ". $_POST['DescItens'] ." 
            <br />
            <h2>Mensalidade total -> ".$_POST['ValTotal'] ."</h2>
            <h2>Taxa de habilitação -> ISENTO</h2>
            <br />
            <h4>
                A mensalidade acima calculada contempla os seguintes serviços/benefícios:
                <ul>
                    <li>Suporte técnico ilimitado via telefone, chat, e-mail, acesso remoto e helpdesk, de segunda a sexta em horário comercial.</li>
                    <li>Treinamento aos funcionários da clínica através dos canais acima mencionados.</li>
                    <li>Infraestrutura de hospedagem do software e seu banco de dados em nuvem, com total infraestrutura e segurança.</li>
                    <li>Espelhamento de dados e backups diários automatizados.</li>
                    <li>Obs.: Proposta tem que ter logo dos aplicativos e ser um resumo de tudo o que o sistema possui, sem esquecer de nenhum detalhe.</li>
                </ul>
            </h4>
        </div>
        <img src='http://beta.feegow.com.br/pdf/img/p7.png' width='100%' />
        <pagebreak> 
        <div style='position:absolute; top:410px; left:90px; color:#fff; width:100%'>
            <table width='950'>
                <tr>
                    <td style='color:#fff'>
                        <h1>". $_POST['NomeProp'] ." - Comercial</h1>
                        <h3>
                            0800-729-6103 // www.feegowclinic.com.br // ". $_POST['EmailProp'] ."
                        </h3>
                            <br />
                        <h4>
                            Validade desta proposta: 15 dias.
                        </h4>
                    </td>
                    <td>
                        <img src='http://beta.feegow.com.br/". $_POST['FotoProp'] ."' height='190' style='object-fit:cover; border-radius:50px'/>
                    </td>
                </tr>
            </table>

        </div>

    <img src='http://beta.feegow.com.br/pdf/img/p8.png' width='100%' />";







 
//	$html = file_get_contents ("http://beta.feegow.com.br/templateProposta.asp?".$getdata, false, $context);

	$mpdf=new mPDF('utf-8', 'A4-L'); 
	$mpdf->SetDisplayMode('fullpage');
//	$css = file_get_contents("css/estilo.css");
    $css = "body {
            font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif;
            font-weight: lighter;
            line-height: 35px;
            }";
	$mpdf->WriteHTML($css,1);
	$mpdf->WriteHTML($html);
//	$mpdf->Output();   //aqui funciona exibindo na tela
    
    $arquivo = $_GET['F'];

    $mpdf->Output( $arquivo .'.pdf','F'); //aqui funciona salvando o arquivo

//Enviando pro arquivo ASP que manda o email
    $postdata = http_build_query(
        array(
            'F' => $_GET['F'],
            'Assunto' => $_POST['Assunto'],
            'EmailProp' => $_POST['EmailProp'],
            'Mensagem' => $_POST['Mensagem'],
            'NomeProp' => $_POST['NomeProp'],
            'Para' => $_POST['Para'],
            'PacienteID' => $_POST['PacienteID'],
            'User' => $_POST['User'],
            'B' => $_POST['B']
        )
    );

    $opts = array('http' =>
        array(
            'method'  => 'POST',
            'header'  => 'Content-type: application/x-www-form-urlencoded',
            'content' => $postdata
        )
    );

    $context  = stream_context_create($opts);

    $result = file_get_contents('http://beta.feegow.com.br/enviaEmailProposta.asp', false, $context);

    echo $result;

  //  $header('Location: ./../enviaEmailProposta.asp?F=');

//<-- Enviando pro arquivo ASP que manda o email
 /*

 require_once "Mail.php";
 
 $from = "Marcio Krizekzzz <nao-responda@feegowclinic.com.br>";
 $to = "Silvio Maia <maia_silvio@hotmail.com>";
 $subject = "Teste de envio usando Pear";
 $body = "Vamos ver se esse pear funciona mesmo.";
 
 $host = "in-v3.mailjet.com";
 $username = "c5859ca10e54a8797e246dc4a60769a5";
 $password = "d04f670ed390e83fe31b620e639e8dd3";
 
 $headers = array ('From' => $from,
   'To' => $to,
   'Subject' => $subject);
 $smtp = Mail::factory('smtp',
   array ('host' => $host,
     'auth' => true,
     'username' => $username,
     'password' => $password));
 
 $mail = $smtp->send($to, $headers, $body);
 
 if (PEAR::isError($mail)) {
   echo("<p>" . $mail->getMessage() . "</p>");
  } else {
   echo("<p>Message successfully sent!</p>");
  }

SMTP = smtp.example.com
smtp_port = 25
username = info@example.com
password = yourmailpassord
sendmail_from = info@example.com


ini_set('SMTP', 'ssl:in-v3.mailjet.com');
ini_set('smtp_server', 'in-v3.mailjet.com');
ini_set('smtp_port', 587);
ini_set('auth_username', 'c5859ca10e54a8797e246dc4a60769a5');
ini_set('auth_password', 'd04f670ed390e83fe31b620e639e8dd3');
ini_set('sendmail_from', 'nao-responda@feegowclinic.com.br');

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
//$mpdf->Output();
*/
	exit;