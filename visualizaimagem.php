<?php


function strToBin($str, $delimiter = ' '){
    for($i=0; $i<strlen($str); $i++){
        $n_str[] = base_convert(ord($str[$i]), 10, 2);
    }
    return implode($delimiter, $n_str);
}
$user = getenv("FC_MYSQL_USER");
$pass = getenv("FC_MYSQL_PASSWORD");

$db = mysqli_connect('localhost', $user, $pass, 'dermagrupo - renata');
$sql = "select * from pacientes where Paci_ln_Counter=8102";
$consulta = mysqli_query($db, $sql);


$row=mysqli_fetch_row($consulta);
header('Content-type: image/jpeg');
echo strToBin($row[26]);

mysqli_close($db);

?>