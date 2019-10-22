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
<h4>Produ&ccedil;&atilde;o por Grupo - Sintético</h4>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rProducaoPorGrupo">
    <div class="clearfix form-actions">
    	<div class="row">
			<%=quickField("datepicker", "DataDe", "De", 3, DataDe, "", "", "")%>
            <%=quickField("datepicker", "DataAte", "At&eacute;", 3, DataAte, "", "", "")%>
            <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, "|"&session("UnidadeID")&"|", "", "", "")%>
            <div class="col-md-2">
                <label>&nbsp;</label><br>
                <button type="submit" class="btn btn-success btn-block"><i class="fa fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->

    function profs(){
        $.get("rProducaoMedicaProfissionais.asp?DataDe="+$("#DataDe").val()+"&DataAte="+$("#DataAte").val(), function(data){ $("#divProfissionais").html(data) });
    }
    profs();
    $("input[name^=Data]").change(function(){ profs() });

</script>