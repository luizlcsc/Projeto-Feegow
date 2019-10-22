<!--#include file="connect.asp"-->
<%
ConsultaID = req("ConsultaID")
PacienteID = req("PacienteID")
ProfissionalID = req("ProfissionalID")
ProcedimentoID = req("ProcedimentoID")
Convenios = "Todos"
%>
<!--#include file="agendamentoProcedimentos.asp"-->