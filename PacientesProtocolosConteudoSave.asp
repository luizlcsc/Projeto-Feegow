<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<!--#include file="geraPacientesProtocolosCiclos.asp"-->
<% 
    response.Charset="utf-8" 

    tipo = ref("tipo")
    dose = ref("dose")
    obs = ref("obs")
    id = ref("id")

    remover = ""
    if tipo = "R" then
    remover = "sysActive=-1,"
    end if

    sql = "UPDATE pacientesprotocolosmedicamentos SET DoseMedicamento="&dose&", "&remover&" Obs='"&obs&"' WHERE id="&id

    db.execute(sql)

    if tipo = "R" then
        call updatePacientesProtocolosCiclosStatus(pacienteProtocoloId, 7, "Remoção de protocolo pelo auditor")
    else
        call updatePacientesProtocolosCiclosStatus(pacienteProtocoloId, 6, "Alteração de protocolo pelo auditor")
    end if

    response.write(true)
%>