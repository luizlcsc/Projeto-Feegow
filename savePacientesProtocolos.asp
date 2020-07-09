<!--#include file="connect.asp"-->
<%
I = req("I")

db.execute("UPDATE pacientesprotocolos SET ProfissionalID='"&ref("ProfissionalID")&"'  WHERE id="&I)
set getMedicamentos = db.execute("SELECT * FROM pacientesprotocolosmedicamentos WHERE PacienteProtocoloID="&I)
while not getMedicamentos.eof
    MedicamentoID = getMedicamentos("id")
    db.execute("UPDATE pacientesprotocolosmedicamentos SET DoseMedicamento="&treatvalzero(ref("DoseMedicamento_"&MedicamentoID))&" , Obs='"&ref("Obs_"&MedicamentoID)&"' WHERE id="&MedicamentoID)
getMedicamentos.movenext
wend
getMedicamentos.close
set getMedicamentos=nothing
%>

new PNotify({
    title: 'Sucesso!',
    text: 'Protocolo Salvo',
    type: 'success',
    delay:1000
});