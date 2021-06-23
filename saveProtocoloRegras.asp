<!--#include file="connect.asp"-->
<%

ProtocoloID = req("ProtocoloID")

set reqRegra       = request.form("Regra")
set reqId          = request.form("id")
set reqCampo       = request.form("Campo")
set reqOperador    = request.form("Operador")
set reqFormID      = request.form("FormID")
set reqFormCampoID = request.form("FormCampoID")
set reqValor       = request.form("Valor")

countRegras = reqRegra.Count

if ProtocoloID = "" or countRegras <> reqId.Count or countRegras <> reqCampo.Count or countRegras <> reqOperador.Count _
    or countRegras <> reqFormID.Count or countRegras <> reqFormCampoID.Count or countRegras <> reqValor.Count then

    response.write("Parametros invalidos")
    response.status = 400
    response.end

end if

user = session("User")

Convenio = ref("Convenio")&""
Plano    = ref("Plano")&""
if Convenio = "" then
    Convenio = "NULL"
else
    Convenio = "'" & Convenio & "'"
end if
if Plano = "" then
    Plano = "NULL"
else
    Plano = "'" & Plano & "'"
end if
sqlUpdate = "UPDATE protocolos SET ConvenioRegra = " & Convenio & ", ConvenioValor = " & Plano & " " &_
            "WHERE id = '" & ProtocoloID & "'"
db.execute(sqlUpdate)

' exclui as regras do protocolo antes de inserir as novas regras
sqlExclui = "UPDATE protocolos_regras SET sysActive = -1, sysUser = " & user & ", sysDate = NOW() " &_
            "WHERE ProtocoloID = '" & ProtocoloID & "' AND sysActive = 1"
db.execute(sqlExclui)

for idx = 1 to countRegras

    regra       = reqRegra(idx)
    campo       = reqCampo(idx)
    operador    = reqOperador(idx)
    formId      = reqFormID(idx)
    formCampoId = reqFormCampoID(idx)
    valor       = reqValor(idx)

    if formId = "" then
        formID      = "NULL"
        formCampoId = ""
    end if

    if formCampoId = "" then
        formCampoId = "NULL"
    end if


    'insere a regra
    sqlInsert = "INSERT INTO protocolos_regras (ProtocoloID, Regra, Campo, Operador, FormID, FormCampoID, Valor, " &_
                "sysActive, sysUser, sysDate) VALUES ('" & ProtocoloID & "', '" & regra & "', '" & campo & "', '" &_
                operador & "', " & formId & ", " & formCampoId & ", '" & valor & "', 1, " & user & ", NOW())"
    db.execute(sqlInsert)

next

response.write("OK")

%>
