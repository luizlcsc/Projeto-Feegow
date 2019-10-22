<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);



    //ibase_connect  Abre uma conexão com um banco de dados InterBase
    //pode ser colocado o IP, ou nome do computador onde esta o banco de dados
     
    $servidor = '127.0.0.1:C:/tarifador/CONTROLLER.FDB';
     
    //conexão com o banco, se der erro mostrara uma mensagem.
    if (!($dbh=ibase_connect($servidor, 'SYSDBA', '')))
            die('Erro ao conectar: ' .  ibase_errmsg());


            /*
$link = ibase_connect("C:/tarifador/CONTROLLER.FDB", "sysdba", "masterkey"); //remote_server_ip:db_file
$res = ibase_query($link, "select * from country");

while ($row = ibase_fetch_row($res)) {
    echo $row[0];
}

ibase_free_result($res);
ibase_close();
*/

?>
