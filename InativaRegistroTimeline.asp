<!--#include file="connect.asp"-->
<%
PacienteID = ref("PacienteID")
RecursoID = ref("RecursoID")
Recurso = ref("Recurso")
Motivo = ref("Motivo")
Valor = ref("Valor")
Tabela = ""

if Recurso="L" or Recurso="AE" then
    Tabela = "buiformspreenchidos"
elseif Recurso="Prescricao" then
    Tabela = "pacientesprescricoes"
elseif Recurso="Atestado" then
    Tabela = "pacientesatestados"
elseif Recurso="Pedido" then
    Tabela = "pacientespedidos"
elseif Recurso="Diagnostico" then
    Tabela = "pacientesdiagnosticos"
elseif Recurso="Alergia" then
    Tabela = "pacientesalergias"
end if

sql = "INSERT INTO log_inativa_prontuario_clinico  (Valor,Recurso,RecursoID,PacienteID,Motivo,sysUser) VALUES ("&Valor&",'"&Recurso&"',"&RecursoID&","&PacienteID&",'"&Motivo&"',"&session("User")&")"
'response.write(sql)
db.execute("UPDATE "&Tabela&" SET sysActive="&Valor&" WHERE id="&RecursoID)
db.execute(sql)

%>
reloadTimeline();