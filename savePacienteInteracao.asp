<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")

if ref("col")="Interesses" then
    val = "'"& ref("valor[]") &"'"
else
    val = treatvalzero(ref("valor"))
end if

db_execute("update pacientes set "&ref("col")&"="&val&" where id="&PacienteID)
%>