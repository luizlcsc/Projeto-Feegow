<!--#include file="connect.asp"-->
<h3>Serviços por Execução</h3>

<form method="get" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rPorExecucao">
    <div class="row">
        <%= quickfield("datepicker", "De", "De", 2, date()-30, "", "", "") %>
        <%= quickfield("datepicker", "Ate", "Até", 2, date(), "", "", "") %>
        <div class="col-md-3">
            <%= selectInsertCA("Executado por", "ExecutadoPor", "", "5, 2, 4, 6, 8", "", " required ", "") %>
        </div>
        <div class="col-md-2">
            <button class="btn btn-block btn-primary mt25">Gerar</button>
        </div>
    </div>
</form>
    <script type="text/javascript">
        <!--#include file="JQueryFunctions.asp"-->
    </script>
