<!--#include file="SendToEndPoint.asp"-->
<!--#include file="toDictionary.asp"-->
<!--#include file="Environment.asp"-->
<%
Function eventEmitter(tipo,sql)
    if isBetaUser() then
        call eventEmitterID(tipo, sql, "")
    end if
end function
Function eventEmitterID(tipo,sql, lastID)
    set payload = toDictionary(sql)
    EVENT_HOST			   = getEnv("FC_EMMITER_ENDPOINT","http://localhost:3000/")
    payload.Add "UnidadeID" , session("unidadeID")
    payload.Add "NomeClinica" , session("NomeEmpresa")
    payload.Add "SysUser" , session("User")
    if lastID&"" <> "" then
        payload.Add "id" , lastID
    end if
    Dim content
    Set content=Server.CreateObject("Scripting.Dictionary")
    content.add "eventID",tipo
    content.add "licenseID",licenseID

    transformado = transformJson(content,payload)
    call SendAsync(EVENT_HOST&"event", transformado, "POST", getEnv("FC_EMMITER_AUTH_TOKEN", ""))
end function
function transformJson(externo,interno)
    str1 = fieldToJSON(externo)
        str1 = str1&",""payload"""&":"& fieldToJSON(interno)
        str1 = str1&"}"
    str2 = str1&"}"
    transformJson = str2
end function
function fieldToJSON(reg)
    str = "{"
            for each x in reg.keys
                i = i+1
                str = str&""""&trim(x)&""":"""&trim(reg.Item(x))&""""
                IF i < reg.Count THEN
                    str = str&","
                END IF
            next
    fieldToJSON = str
end function
%>