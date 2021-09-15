<!--#include file="connect.asp"-->
<form method="get" action="./PrintStatement.asp" target="_blank">
	<input type="hidden" name="R" value="rTaxaOcupacao">
    <div class="page-header">
        <h3 class="text-center">
            Taxa de Ocupação de Agendas
        </h3>
    </div>
    <div class="row">
        <%=quickfield("simpleSelect", "Mes", "Mês", 2, month(date()), "select '1' id, 'Janeiro' Mes UNION SELECT '2', 'Fevereiro' UNION SELECT '3', 'Março' UNION SELECT '4', 'Abril' UNION SELECT '5', 'Maio' UNION SELECT '6', 'Junho' UNION SELECT '7', 'Julho' UNION SELECT '8', 'Agosto' UNION SELECT '9', 'Setembro' UNION SELECT '10', 'Outubro' UNION SELECT '11', 'Novembro' UNION SELECT '12', 'Dezembro'", "Mes", " semVazio no-select2 ")%>
        <%=quickfield("simpleSelect", "Ano", "Ano", 2, year(date()), "select '2019' id, '2019' Ano", "Ano", " semVazio no-select2 ")%>

        <%=quickfield("empresaMultiIgnore", "Unidades", "Unidades", 4, session("Unidades"), "", "", "")%>
        <div class="col-md-2">
            <label>&nbsp;</label>
            <br>
            <button class="btn btn-primary btn-block"><i class="far fa-chart"></i> Gerar</button>
        </div>
    </div>
</form>
<script type="text/javascript">
    $("#TipoFC").change(function () {
        if ($(this).val() == "D") {
            $("#qfdem, #qfatem").addClass("hidden");
            $("#qfde, #qfate").removeClass("hidden");
        } else {
            $("#qfde, #qfate").addClass("hidden");
            $("#qfdem, #qfatem").removeClass("hidden");
        }
    });

<!--#include file="jQueryFunctions.asp"-->
</script>
<%'= DeMin &" :: "& DeMax %>