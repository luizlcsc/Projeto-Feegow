<!--#include file="connect.asp"-->
<style type="text/css">
    body {
        font-size:11px;
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
<h4>Produtividade de Agendamentos - Sintético</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
    <input type="hidden" name="R" value="ProdutividadeSintetico">
    <div class="clearfix form-actions">
        <div class="row">
            <%=quickfield("datepicker", "De", "De", 2, De, "", "", "")%>
            <%=quickfield("datepicker", "Ate", "At&eacute;", 2, A, "", "", "")%>
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

    

    db_execute("delete from cliniccentral.temp_prodagenda where sysUser="& session("User"))
    db_execute("insert into cliniccentral.temp_prodagenda (sysUser, UserID, StaID, Data, ProfissionalID, ARX) select '"& session("User") &"', Usuario, lm.Sta, lm.DataHora, lm.ProfissionalID, lm.ARX from logsmarcacoes lm WHERE date(DataHora) BETWEEN "& mydatenull(req("De")) &" AND "& mydatenull(req("Ate")) &" ")
    %>
    <table width="100%" class="table table-condensed table-striped table-hover table-bordered">
        <thead>
            <tr class="success">
                <th >DATA</th>
                <th >USUÁRIO</th>
                <%
                set stas = db.execute("select distinct tp.StaID, s.StaConsulta from cliniccentral.temp_prodagenda tp LEFT JOIN StaConsulta s ON s.id=tp.StaID where NOT ISNULL(s.StaConsulta) AND tp.sysUser="& session("User"))
                while not stas.eof
                    strSta = strSta & "|"& stas("StaID")
                    %>
                    <th ><%= replace(replace(ucase(stas("StaConsulta")), "MARCADO - ", ""), " PELO PACIENTE", "") %></th>
                    <%
                stas.movenext
                wend
                stas.close
                set stas = nothing
                %>
                <th >EXCLUÍDO</th>
                <th >TOTAL DE AÇÕES</th>
            </tr>
        </thead>
        <tbody>
        <%
        set dist = db.execute("select distinct date(tp.Data) Data, lu.Nome, tp.UserID from cliniccentral.temp_prodagenda tp LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=tp.UserID where tp.sysUser="& session("User") &" order by date(tp.Data), lu.Nome")
        while not dist.eof
            acoesDiaUsu = 0
        %>
        <tr>
            <td><%= (dist("Data")) %></td>
            <td><%=dist("Nome")%></td>
            <%
            splSta = split(strSta, "|")
            for i=1 to uBound(splSta)
                set conta = db.execute("select count(id) acoes from cliniccentral.temp_prodagenda where sysUser="& session("User") &" and date(Data)="& mydatenull(dist("Data")) &" and UserID="& dist("UserID") &" and StaID="& splSta(i))
                acoesDiaUsu = acoesDiaUsu + ccur(conta("acoes"))
                %>
                <td class="text-right"><%= conta("acoes") %></td>
                <%
            next

            set contax = db.execute("select count(id) acoes from cliniccentral.temp_prodagenda where sysUser="& session("User") &" and date(Data)="& mydatenull(dist("Data")) &" and UserID="& dist("UserID") &" and ARX='X'")
            acoesDiaUsu = acoesDiaUsu + ccur(conta("acoes"))
            %>
            <td class="text-right"><%= contax("acoes") %></td>
            <td class="text-right"><%= acoesDiaUsu %></td>
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
