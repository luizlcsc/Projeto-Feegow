<?php

header('Content-Type: application/xml; charset=ISO-8859-1');

session_start();
if($_SESSION['banco']==''){
	echo "Criando sessão...<br /><br />";
	$_SESSION['banco']=$_GET['B'];
}
echo "<banco>". $_SESSION['banco'] ."</banco>";
?>