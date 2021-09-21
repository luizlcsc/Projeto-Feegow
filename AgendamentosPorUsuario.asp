<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

'on error resume next
if req("De")="" then
	De=dateAdd("d",-7,date())
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
<h4>Agendamentos por usuário</h4>

<form method="get" target="_blank" action="PrintStatement.asp">
    <input type="hidden" name="R" value="rAgendamentosPorUsuario">
    <div class="clearfix form-actions">
        <div class="row">
            <%=quickfield("datepicker", "De", "De", 2, De, "", "", "")%>
            <%=quickfield("datepicker", "Ate", "At&eacute;", 2, A, "", "", "")%>
            <%'=quickField("empresaMulti", "UnidadeID", "Unidade", 4, session("Unidades"), " input-sm", "", "")%>
            <%=quickField("simpleSelect", "AgendadoPor", "Agendado por", 3, "", "select id, Nome from (select '1' AS id, 'AGENDAMENTO ONLINE' as 'Nome' UNION ALL (SELECT lu.id, lu.Nome FROM cliniccentral.licencasusuarios lu LEFT JOIN sys_users su on su.id=lu.id where lu.LicencaID="&replace(session("Banco"), "clinic", "")&" and lu.Nome not like '' and su.Permissoes like '%agendaI%' order by lu.Nome))t", "Nome", " empty")%>
            <%=quickField("empresaMulti", "UnidadeID", "Unidade", 4, session("Unidades"), " input-sm", "", "")%>


            <div class="col-md-1">
                <label>&nbsp;</label><br />
                <button type="submit" class="btn btn-sm btn-primary" name="Gerar" value="Gerar"><i class="far fa-search"></i>Gerar</button>
            </div>
        </div>
        <div class="row">
            <%'= quickfield("multiple", "Procedimentos", "Contador de procedimentos", 3, "", "select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeProcedimento", "NomeProcedimento", "") %>
            <%= quickfield("multiple", "ProcedimentosGrupos", "Contadores por grupos de procedimento", 4, "", "select id, NomeGrupo from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", "") %>
            <%= quickfield("multiple", "ProcedimentosTipos", "Contadores por tipos de procedimento", 4, "", "select id, TipoProcedimento from tiposprocedimentos order by TipoProcedimento", "TipoProcedimento", "") %>
            <div class="row pt30">
                <label class="pr30"><input type="radio" name="Tipo" value="S" checked /> Sintético</label>
                
                <label><input type="radio" name="Tipo" value="A" /> Analítico</label>
            </div>
        </div>
        <br />



    </div>
    <input type="hidden" name="E" value="E" />
</form>
<%
else
%>
<h3>AGENDAMENTOS POR USUÁRIO</h3>
<hr />
<%
end if


if req("E")="E" then
	if req("Profissional")="" then
		sqlProfissional=""
	else
		sqlProfissional=" and id like '"&req("Profissional")&"'"
	end if
	De = req("De")
	Ate = req("Ate")

	sqlData = ""

	if De<>"" then
	    sqlData = sqlData &" AND date(lm.DataHora) >= date("&mydatenull(De)&")"
	end if
	if req("AgendadoPor")<>"" then
	    sqlUsuario = " AND lm.Usuario = "&req("AgendadoPor")
	end if
	if req("UnidadeID")<>"" then
	    Unidades = replace(req("UnidadeID"),"|","")
	end if
	if Ate<>"" then
	    sqlData = sqlData &" AND date(lm.DataHora) <= date("&mydatenull(Ate)&")"
	end if

	if req("AgendadoPor")<>"" then
	    sqlUsuario = " AND lm.Usuario="&req("AgendadoPor")
	end if
	response.Buffer
    TotalGeral=0

    sqlUn = "select id, Nome FROM (SELECT id, NomeFantasia as Nome FROM sys_financialcompanyunits WHERE sysActive=1 UNION ALL SELECT 0 as id, NomeFantasia as Nome FROM empresa WHERE id=1)t WHERE id IN ("&Unidades&")"

    set UnidadesSQL = db.execute(sqlUn)

    while not UnidadesSQL.eof
        Total=0

        if UnidadesSQL("id")="0" then
            sqlSemUnidade = " OR l.UnidadeID IS NULL"
        end if
        sql = "SELECT lm.id,a.PacienteID, count(lm.id)n, lm.DataHora as 'Data', lu.Nome, lm.Usuario FROM logsmarcacoes lm LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=lm.Usuario LEFT JOIN agendamentos a ON a.id = lm.ConsultaID LEFT JOIN locais l ON l.id=a.LocalID WHERE 1=1 "&sqlData&sqlUsuario&" AND lm.ARX='A' AND lm.id = (SELECT lm2.id FROM logsmarcacoes lm2 WHERE lm2.ARX='A' AND lm2.ConsultaID=lm.ConsultaID GROUP BY lm2.ConsultaID LIMIT 1) AND l.UnidadeID="&UnidadesSQL("id")&sqlSemUnidade&" GROUP BY lm.Usuario,date(lm.DataHora) ORDER BY lm.DataHora"
        'response.write(sql)
        set AgendamentosSQL = db.execute(sql)
%>
    <style>
    body{
        margin: 30px!important;
    }
    </style>
    <h2><%=UnidadesSQL("Nome")%></h2>
    <table width="100%" class="table table-condensed table-hover">
        <thead>
            <tr>
                <th width="25"></th>
                <th >DATA</th>
                <th >USUÁRIO</th>
                <th >QUANTIDADE DE AGENDAMENTOS</th>
            </tr>
        </thead>
        <tbody>
        <%
        CorTD = "#fff"
        UltimaData = ""
        while not AgendamentosSQL.eof
            Total = Total + ccur(AgendamentosSQL("n"))
            NomeUsuario = uCase(AgendamentosSQL("Nome"))

            if AgendamentosSQL("Usuario")=1 then
                NomeUsuario = "AGENDAMENTO ONLINE"
            end if

            if mydate(AgendamentosSQL("Data")) <> mydate(UltimaData) then
                if CorTD="#fff" then
                    CorTD="#f9f9f9"
                else
                    CorTD="#fff"
                end if
            end if
            %>
                <tr>
            <td style="background-color: <%=CorTD%>"></td>
            <td style="background-color: <%=CorTD%>"><%=AgendamentosSQL("Data")%></td>
            <td style="background-color: <%=CorTD%>"><%=NomeUsuario%></td>
            <td style="background-color: <%=CorTD%>"><%=AgendamentosSQL("n")%></td>
                </tr>
            <%
            UltimaData = mydate(AgendamentosSQL("Data"))
            TotalGeral = TotalGeral + Total
        AgendamentosSQL.moveNext
        wend
        AgendamentosSQL.close
        set AgendamentosSQL=nothing
    %>

        </tbody>

    </table>
    <h4>Total: <%=Total%></h4>

    <%
    UnidadesSQL.moveNext
    wend
    UnidadesSQL.close
    set UnidadesSQL=nothing

    %>
<%

%>
<br>
<%
end if%><!--#include file="disconnect.asp"-->
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>
