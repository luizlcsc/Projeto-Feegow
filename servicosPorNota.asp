<!--#include file="connect.asp"-->
<h4>Serviços por Nota</h4>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rServicosPorNota">
    <div class="clearfix form-actions">
    	<div class="row">
            <%=quickField("text", "NF", "Número da Nota", 3, NF, "", "", " required ")%>
            <div class="col-md-2">
                <label>&nbsp;</label><br>
                <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i> Gerar</button>
            </div>
        </div>

    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>