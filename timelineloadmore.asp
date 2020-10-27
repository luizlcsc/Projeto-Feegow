<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
<%
ProfessionalID = req("ProfissionalID")
Tipo = req("Tipo")
PacienteID = req("PacienteID")
ComEstilo = req("ComEstilo")
loadMore = req("loadMore")
MaximoLimit = 40

%>

<!--#include file="timelineload.asp"-->