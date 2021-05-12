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
set reqConvenioID  = request.form("ConvenioID")
set reqPlanoID     = request.form("PlanoID")

countConvenios = reqConvenioID.Count
countRegras    = reqRegra.Count

if ProtocoloID = "" or countRegras <> reqId.Count or countRegras <> reqCampo.Count or countRegras <> reqOperador.Count _
    or countRegras <> reqFormID.Count or countRegras <> reqFormCampoID.Count or countRegras <> reqValor.Count _
    or countConvenios <> reqPlanoID.Count then

    response.write("Parametros invalidos")
    response.status = 400
    response.end

end if

user = session("User")

' exclui as regras de convenio do protocolo antes de inserir as novas regras
sqlExclui = "DELETE FROM protocolos_convenios WHERE ProtocoloID = '" & ProtocoloID & "'"
db.execute(sqlExclui)

for idx = 1 to countConvenios
    convenioId = reqConvenioID(idx)
    planoId    = reqPlanoID(idx)

    if planoId = "" then
        planoId = "NULL"
    end if

    'insere a regra do convenio
    sqlInsert = "INSERT INTO protocolos_convenios (ProtocoloID, ConvenioID, PlanoID) " &_
                "VALUES ('" & ProtocoloID & "', '" & convenioId & "', " & planoId & ")"
    db.execute(sqlInsert)
next

' exclui as regras do protocolo antes de inserir as novas regras
sqlExclui = "DELETE FROM protocolos_regras WHERE ProtocoloID = '" & ProtocoloID & "'"
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
