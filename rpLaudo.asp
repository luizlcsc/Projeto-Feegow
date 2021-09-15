<!--#include file="connect.asp"-->
<%
De = 01&"/"&month(date())&"/"&year(date())
Ate = dateadd("m", 1, De)
Ate = dateadd("d", -1, Ate)
%>
<form method="get" action="./Relatorio.asp" target="_blank">
	<input type="hidden" name="TipoRel" value="LaudoSintetico">
    <div class="page-header">
        <h3 class="text-center">
            Laudos - Sintético
        </h3>
    </div>
    <div class="row">
        <%=quickfield("datepicker", "De", "De", 3, De, "", "", "")%>
        <%=quickfield("datepicker", "Ate", "Até", 3, Ate, "", "", "")%>
        <%=quickfield("select", "ProfissionalID", "Profissional", 4, ProfissionalID, "select id, NomeProfissional from profissionais where sysActive=1 AND Ativo='on' order by NomeProfissional", "NomeProfissional", " empty")%>
        <div class="col-md-2">
            <label>&nbsp;</label>
            <br>
            <button class="btn btn-sm btn-primary btn-block"><i class="far fa-chart"></i> Gerar</button>
        </div>
    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>