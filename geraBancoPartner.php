<?php
//error_reporting(E_ERROR | E_WARNING | E_PARSE);




$db = mysql_connect('localhost', getenv("FC_MYSQL_USER"), getenv("FC_MYSQL_PASSWORD"));
mysql_select_db('clinic'.$_GET['BancoID']);



$nome_do_arquivo = "assets/db/modelo.sql"; // Nome do Arquivo a ser usado
$arquivo = Array();
$arquivo = file($nome_do_arquivo);//  Pega Cada Linha e Joga na Matriz $arquivo
$prepara = "";  // Cria a Variavel $prepara
foreach($arquivo as $v) $prepara.=$v;//  executa um loop pegando cada valor da Matriz e concatenando na variavel $prepara
$sql = explode(";",$prepara); //  Divide a variavel em varios pedaços independente de instruçoes SQL'S tiverem no arquivo, separando por ponto e virgula, criando assim a matriz $sql
foreach($sql as $v) mysql_query($v);  // Executa um Loop Retornando cada valor da matriz $sql, q está em $v, ou seja cada valor do $v é uma instrução sql diferente

header('location:generatePartner.asp?Part=2');


?>