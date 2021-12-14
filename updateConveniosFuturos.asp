<!--#include file="connect.asp"-->

<div id="updateConvenio"></div>
<%
pacienteID = ref("PacienteID") 
convenioID = ref("convenioID") 
agendamentoID = ref("agendamentoID") 

updateConveniosFuturosSQL = "UPDATE agendamentos a SET a.ValorPlano = "&convenioID&", a.rdValorPlano = 'P' WHERE DATE(a.`Data`) >= CURDATE() AND a.PacienteID="&pacienteID&" AND a.id IN("&agendamentoID&") ORDER BY a.Data ASC, a.Hora ASC"

pagamentoEmDinheiroSQL = "UPDATE agendamentos a SET a.ValorPlano = 0, a.rdValorPlano = 'V' WHERE DATE(a.`Data`) >= CURDATE() AND a.PacienteID="&pacienteID&" AND a.id IN("&agendamentoID&") ORDER BY a.Data ASC, a.Hora ASC"

if convenioID&"" <> "" then 
    set updateConveniosFuturos = db.execute(updateConveniosFuturosSQL)
else
    set updateConveniosFuturos = db.execute(pagamentoEmDinheiroSQL)
end if

updateConveniosFuturos.close
set updateConveniosFuturos = nothing

%>