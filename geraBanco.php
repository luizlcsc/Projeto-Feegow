<?php
//error_reporting(E_ERROR | E_WARNING | E_PARSE);




$db = mysqli_connect('localhost', 'root', 'pipoca453', 'clinic'.$_GET['BancoID']);



$nome_do_arquivo = "assets/db/modelo.sql"; // Nome do Arquivo a ser usado
$arquivo = Array();
$arquivo = file($nome_do_arquivo);//  Pega Cada Linha e Joga na Matriz $arquivo
$prepara = "";  // Cria a Variavel $prepara
foreach($arquivo as $v) $prepara.=$v;//  executa um loop pegando cada valor da Matriz e concatenando na variavel $prepara
$sql = explode(";",$prepara); //  Divide a variavel em varios pedaços independente de instruçoes SQL'S tiverem no arquivo, separando por ponto e virgula, criando assim a matriz $sql
foreach($sql as $v) mysqli_query($db, $v);  // Executa um Loop Retornando cada valor da matriz $sql, q está em $v, ou seja cada valor do $v é uma instrução sql diferente

header('location:generateTrialX.asp?Part=2');


?>