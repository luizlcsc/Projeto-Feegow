<!--#include file="connect.asp"-->
<%
PacienteID=req("PacienteID")
Tipo=req("Tipo")

if Tipo="CPF" then
    CPF=req("CPF")
    db.execute("UPDATE pacientes SET CPF='"&CPF&"' WHERE id="&PacienteID)
end if

if Tipo="EMAIL" then
    Email1 = req("Email1")
    Email2 = req("Email2")
    db.execute("UPDATE pacientes SET Email1='"&Email1&"', Email2='"&Email2&"' WHERE id="&PacienteID)
end if

if Tipo="TEL" then
    Tel1 = req("Tel1")
    Tel2 = req("Tel2")
    Cel1 = req("Cel1")
    Cel2 = req("Cel2")
    db.execute("UPDATE pacientes SET Tel1='"&Tel1&"', Tel2='"&Tel2&"', Cel1='"&Cel1&"', Cel2='"&Cel2&"' WHERE id="&PacienteID)
end if



%>

new PNotify({
    title: 'Dados gravados com sucesso.',
    text: '<%=Tipo%> do paciente alterado.',
    type: 'success',
    delay:1000
});