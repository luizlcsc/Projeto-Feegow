<!--#include file="connect.asp"-->
<%
set vcaat = db.execute("select a.HoraInicio, a.HoraFim from atendimentosprocedimentos ap LEFT JOIN atendimentos a ON a.id=ap.AtendimentoID WHERE a.PacienteID="&ref("PacienteID")&" AND a.ProfissionalID="&ref("ProfissionalID")&" AND a.Data=DATE(NOW())")
if not vcaat.EOF then
	if not isnull(vcaat("HoraInicio")) then
		%>
		$("#AtendidoDe").val("<%=formatdatetime(vcaat("HoraInicio"), 4)%>");
		<%
	end if
	if not isnull(vcaat("HoraFim")) then
		%>
		$("#AtendidoAs").val("<%=formatdatetime(vcaat("HoraFim"), 4)%>");
		<%
	end if
end if
%>