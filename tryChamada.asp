<!--#include file="connect.asp"--><%

set vca = db.execute("select a.id, p.NomePaciente, l.NomeLocal, a.ProfissionalID, o.Observacoes from agendamentos a LEFT JOIN locais l on l.id=a.LocalID LEFT JOIN pacientes p on p.id=a.PacienteID LEFT JOIN agendaobservacoes o on (o.Data=date(now()) and o.ProfissionalID=a.ProfissionalID) where a.Data=date(now()) and a.StaID=5 and l.UnidadeID="&session("UnidadeID"))
while not vca.eof
    Obs = vca("Observacoes") & chr(10)
    splObs = split(Obs, chr(10))
    %>
    <div class="contNome">
        <div class="nomePac">
            <%=left(vca("NomePaciente"), 21) %><br />
        </div>
        <div><span class="localPac"><%=splObs(0) %></span></div>
    </div>
<%
vca.movenext
wend
vca.close
set vca=nothing
%>