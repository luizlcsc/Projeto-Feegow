<!--#include file="connect.asp"-->
<%
PacienteID = ref("PacienteID")
StaID = ref("Sta")

if instr(PacienteID, "3_") then
    db_execute("update pacientes set sysActive="&StaID&" where id="&replace(PacienteID, "3_", ""))
    db_execute("insert into pacientesstalog (PacienteID, sysUser, StaID) values ("&replace(PacienteID, "3_", "")&", "&session("User")&", "&StaID&")")
end if
%>