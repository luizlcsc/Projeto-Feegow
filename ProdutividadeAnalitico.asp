<!--#include file="connect.asp"-->
<style type="text/css">
    body {
        font-size:10px;
    }
</style>
<%
response.Charset="utf-8"

'on error resume next
if req("De")="" then
	De=dateAdd("m",-1,date())
else
	De=req("De")
end if

if req("Ate")="" then
	A=date()
else
	A=req("Ate")
end if

valorTotal=0
%>
<%
if req("De")="" then
%>
<h4>Produtividade de Agendamentos - Analítico</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
    <input type="hidden" name="R" value="ProdutividadeAnalitico">
    <div class="clearfix form-actions">
        <div class="row">
            <%=quickfield("datepicker", "De", "De", 2, De, "", "", "")%>
            <%=quickfield("datepicker", "Ate", "At&eacute;", 2, A, "", "", "")%>
            <%=quickfield("multiple", "StaID", "Status", 2, A, "select id, StaConsulta from staconsulta", "StaConsulta", "")%>
            <%=quickField("empresaMulti", "UnidadeID", "Unidade", 4, session("Unidades"), " input-sm", "", "")%>
            <div class="col-md-1">
                <label>&nbsp;</label><br />
                <button type="submit" class="btn btn-sm btn-primary" name="Gerar" value="Gerar"><i class="far fa-search"></i>Gerar</button>
            </div>
        </div>
        <br />

    </div>
    <input type="hidden" name="E" value="E" />
</form>
<%
else
%>
<h3>DURAÇÃO DO ATENDIMENTO</h3>
<hr />
<%
end if


if req("E")="E" then

    if req("StaID")<>"" then
        sqlStaID = " AND lm.Sta IN ("& replace(req("StaID"), "|", "") &") "
    end if
    

    db_execute("delete from cliniccentral.temp_prodagenda where sysUser="& session("User"))
    db_execute("insert into cliniccentral.temp_prodagenda (sysUser, UserID, StaID, Data, DataAg, HoraAg, ProcedimentoID, ProfissionalID, ARX) select '"& session("User") &"', Usuario, lm.Sta, lm.DataHora, lm.Data, lm.Hora, lm.ProcedimentoID, lm.ProfissionalID, lm.ARX from logsmarcacoes lm WHERE date(DataHora) BETWEEN "& mydatenull(req("De")) &" AND "& mydatenull(req("Ate")) & sqlStaID &" ")
    %>
    <table width="100%" class="table table-condensed table-striped table-hover table-bordered">
        <thead>
            <tr class="info">
                <th >USUÁRIO</th>
                <th>DT AÇÃO</th>
                <th>HR AÇÃO</th>
                <th>DT AGENDA</th>
                <th>HR AGENDA</th>
                <th>AÇÃO EFETUADA</th>
                <th>SERVIÇO</th>
                <th>PROFISSIONAL</th>
            </tr>
        </thead>
        <tbody>
        <%
        set dist = db.execute("select tp.*, lu.Nome, s.StaConsulta, proc.NomeProcedimento, prof.NomeProfissional from cliniccentral.temp_prodagenda tp LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=tp.UserID LEFT JOIN StaConsulta s ON s.id=tp.StaID LEFT JOIN procedimentos proc ON proc.id=tp.ProcedimentoID LEFT JOIN profissionais prof ON prof.id=tp.ProfissionalID where tp.sysUser="& session("User") &" order by tp.Data")
        while not dist.eof
            if dist("ARX")="X" then
                Acao = "Exclusão"
            else
                Acao = dist("StaConsulta")
            end if
            %>
            <tr>
                <td><%= left(dist("Nome")&"", 18)%></td>
                <td><%= formatdatetime(dist("Data"), 2) %></td>
                <td><%= ft(dist("Data")) %></td>
                <td><%= dist("DataAg") %></td>
                <td><%= ft(dist("HoraAg")) %></td>
                <td><%= Acao %></td>
                <td><%= left(dist("NomeProcedimento")&"", 18) %></td>
                <td><%= left(dist("NomeProfissional")&"", 18) %></td>
            </tr>
            <%
        dist.movenext
        wend
        dist.close
        set dist = nothing
        %>
        </tbody>
        <tfoot>

        </tfoot>
    </table>
    <%
end if%><!--#include file="disconnect.asp"-->
<script type="text/javascript">
<!--#include file="jQueryFunctions.asp"-->
</script>
