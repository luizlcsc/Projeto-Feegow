<!--#include file="connect.asp"-->
<%
'db_execute("insert into pacientesdiagnosticos (PacienteID, CidID, Descricao, sysUser) values ('"&ref("I")&"', '"&ref("DiagnosticoCid10")&"', '"&ref("DiagnosticoObservacoes")&"', '"&session("User")&"')")
db_execute("update pacientesdiagnosticos set Descricao='"&ref("Descricao")&"' where id="&replace(ref("DiagnosticoID"), "memo", ""))
%>