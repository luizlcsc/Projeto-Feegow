<!--#include file="connect.asp"-->
<h4>Serviços a Executar</h4>

<form method="get" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rAExecutar">

    <%= quickfield("datepicker", "DataDe", "Data da venda", 2, dateadd("m", -6, date()), "", "", "") %>
    <%= quickfield("datepicker", "DataAte", "Até", 2, date(), "", "", "") %>
    <%= quickfield("empresaMulti", "UnidadeID", "Unidade", 2, session("Unidades"), "", "", "") %>
    <div class="col-md-2">
        <button class="btn btn-primary mt25">Gerar</button>
    </div>
    <script type="text/javascript">
        <!--#include file="JQueryFunctions.asp"-->
    </script>
</form>