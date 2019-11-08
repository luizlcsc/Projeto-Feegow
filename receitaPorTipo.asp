<!--#include file="connect.asp"-->
<%
DataDe = request.QueryString("DataDe")
DataAte = request.QueryString("DataAte")

if DataDe="" then
	DataDe = date()
end if
if DataAte="" then
	DataAte = date()
end if
%>
<h4>Relatório de Segregação da Receita por Tipo de Serviços Prestados</h4>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rReceitaPorTipo">
    <div class="clearfix form-actions">
    	<div class="row">
			<%=quickField("datepicker", "DataDe", "Nota Fiscal Emitida Entre", 2, DataDe, "", "", "")%>
            <%=quickField("datepicker", "DataAte", "&nbsp;", 2, DataAte, "", "", "")%>
            <%=quickField("text", "NF", "Número da Nota", 2, NF, "", "", " placeholder='Opcional' ")%>
            <%=quickField("empresaMulti", "UnidadeID", "Unidade", 3, session("Unidades"), " input-sm", "", "")%>

            <div class="col-md-2">
                <label>&nbsp;</label><br>
                <button type="submit" class="btn btn-success btn-block"><i class="fa fa-search"></i> Gerar</button>
            </div>
        </div>

    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>