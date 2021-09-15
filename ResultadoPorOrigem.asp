<!--#include file="connect.asp"-->
<div class="container">
<%
response.Charset="utf-8"
De = req("De")
Ate = req("Ate")

	De = date()
	Ate = date()
	%>
    <h4>Resultado por Origem</h4>
    <form method="get" target="_blank" action="Relatorio.asp">
    <input type="hidden" name="TipoRel" value="rResultadoPorOrigem" />
    <div class="clearfix form-actions">
      <div class="row">
		<%=quickfield("datepicker", "De", "Selecione o per&iacute;odo", 3, De, "", "", " placeholder='De'")%>
        <%=quickfield("datepicker", "Ate", "&nbsp;", 3, Ate, "", "", " placeholder='At&eacute;'")%>
        <%=quickfield("multiple", "Unidades", "Unidades", 4, "", "select * from sys_financialcompanyunits where sysActive", "UnitName", "")%>
        <div class="col-md-2"><label>&nbsp;</label><br>
        <button class="btn btn-sm btn-success"><i class="far fa-list"></i> Gerar</button>
      	</div>
      </div>
    </div>
    </form>
</div>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>