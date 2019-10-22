<html>
 
<head>   
 
<!-- 1 -->
<link href="assets/css/dropzone.css" type="text/css" rel="stylesheet" />
 
<!-- 2 -->
<script src="assets/js/dropzone.js"></script>
 
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"><style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
}
.dropzone{
	min-height:120px;
	padding:0;
}
-->
</style></head>
 
<body>
 
<!-- 3 -->
<form action="upload.php?PacienteID=<?php echo @$_GET['PacienteID'];?>&L=<?php echo @$_GET['L'];?>&Pasta=<?php echo @$_GET['Pasta'];?>&Tipo=<?php echo @$_GET['Tipo'];?>&MovementID=<?php echo @$_GET['MovementID'];?>&ExameID=<?php echo @$_GET['ExameID'];?>&guiaID=<?php echo @$_GET['guiaID'];?>&tipoGuia=<?php echo @$_GET['tipoGuia'];?>&LaudoID=<?php echo @$_GET['LaudoID'];?>" class="dropzone"></form>
   
</body>
 
</html>
