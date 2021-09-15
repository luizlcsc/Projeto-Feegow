<!--#include file="connect.asp"-->
<%
DataDe = req("DataDe")
DataAte = req("DataAte")

if DataDe="" then
	DataDe = date()
end if
if DataAte="" then
	DataAte = date()
end if
%>
<h4>Relatório de Segregação da Receita por Tipo de Serviços Prestados</h4>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rSegReceita">
    <div class="clearfix form-actions">
    	<div class="row">
			<%=quickField("datepicker", "DataDe", "Nota Fiscal Emitida Entre", 3, DataDe, "", "", "")%>
            <%=quickField("datepicker", "DataAte", "&nbsp;", 3, DataAte, "", "", "")%>
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