<link href="css/demo.css" rel="stylesheet" type="text/css" />
<div id="listaEmails">Carregando e-mails...</div>
<script>
$.get("baixaEmails.php", function(data){ $("#listaEmails").html(data) });
</script>