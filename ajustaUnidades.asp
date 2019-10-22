<!--#include file="connect.asp"-->
<%
De = cdate(req("De"))

response.write("<h1 class='text-center'>"& De &"</h1>")

Ate = date()

ProfissionaisExcecao = ""
sqlGrade = "SELECT t.*, prof.NomeProfissional, l.UnidadeID FROM ("&_
    " select 'Excecao' TipoGrade, ProfissionalID, LocalID from assperiodolocalxprofissional where "& mydatenull(De) &" between DataDe and DataA "&_
    " UNION ALL "&_
    " select 'Fixa', ProfissionalID, LocalID from assfixalocalxprofissional where DiaSemana="& weekday(De) &" "&_
    ") t left join profissionais prof ON prof.id=t.ProfissionalID LEFT JOIN locais l ON l.id=t.LocalID WHERE NOT ISNULL(prof.id) AND NOT ISNULL(l.UnidadeID) "&_
    " GROUP BY ProfissionalID ORDER BY TipoGrade, NomeProfissional"

set prof = db.execute( sqlGrade )
while not prof.eof
        %>
        <h2><%= prof("TipoGrade") &" - "& prof("NomeProfissional") &" - Unidade: "& prof("UnidadeID") %></h2>
        <%
        UnidadeID = prof("UnidadeID")
        ProfissionalID = prof("ProfissionalID")
        db_execute("update atendimentos set UnidadeID="& UnidadeID &" where ProfissionalID="& ProfissionalID &" and Data="& mydatenull(De) &"")
        db_execute("update sys_financialinvoices i left join itensinvoice ii on ii.InvoiceID=i.id SET i.CompanyUnitID="& UnidadeID &" where ii.Associacao=5 AND ii.ProfissionalID="& ProfissionalID &" AND ii.DataExecucao="& mydatenull(De))
        db_execute("update tissguiaconsulta set UnidadeID="& UnidadeID &" where ProfissionalID="& ProfissionalID &" and DataAtendimento="& mydatenull(De))
        db_execute("update tissguiasadt gs left join tissprocedimentossadt gps ON gps.GuiaID=gs.id SET gs.UnidadeID="& UnidadeID &" WHERE gps.Data="& mydatenull(De) &" AND gps.ProfissionalID="& ProfissionalID &" AND gps.Associacao=5")
prof.movenext
wend
prof.close
set prof = nothing
%>