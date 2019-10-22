<!--#include file="connect.asp"-->
<!DOCTYPE html>
<html lang="en">
	<head>
      <title>Agenda</title>
	  <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/theme.css">

      <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
      <script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
      <script src="vendor/plugins/select2/select2.min.js"></script> 
      <script src="vendor/plugins/select2/select2.full.min.js"></script> 
    </head>
    <body>
    <h4 class="text-center" id="NomeProfissional"></h4>
    <div id="GradeAgendaPrint"></div>
	<script>
	$("#NomeProfissional").html( window.parent.$("#ProfissionalID option:selected").html() );
	$("#GradeAgendaPrint").html( window.parent.$("#GradeAgenda").html() );
	
	$(document).ready(function(e) {
        print();
    });
	</script>
	</body>
</html>