<!--#include file="../Classes/Connection.asp"-->
<!--#include file="../Classes/JSON.asp"-->
<!--#include file="../functionOcupacao.asp"-->
<%

license_id = req("license")
data_fim = req("data_fim")
data_inicio = req("data_inicio")
unidades = req("unidades")
especialidades = req("especialidades")
profissionais1 = req("profissionais")
convenioId = req("convenioId")
procedimentoId = req("procedimentos")
sysUser = req("sysUser")&""
resetMode="always"

if  req("resetMode")&"" <> "" then
    resetMode = req("resetMode")&""
end if 


if sysUser = "" then
    sysUser= 0
end if 


get_payload = req("get_payload")

Response.ContentType = "application/json"

set db = newConnection("","")

set LicenseSQL = db.execute("SELECT Servidor FROM cliniccentral.licencas WHERE id="&license_id)

if not LicenseSQL.eof then
    Servidor = LicenseSQL("Servidor")

    set dbclient = newConnection("clinic"&license_id, Servidor)

    session("Servidor")=Servidor
    session("Banco")="clinic"&license_id
    %>
<!--#include file="../connect.asp"-->
    <%
    call ocupacao(data_inicio, data_fim, especialidades, procedimentoId, profissionais1, convenioId, unidades, sysUser, resetMode, False)

    if get_payload="true" then
        set HorariosSQL = dbclient.execute("SELECT * FROM agenda_horarios WHERE sysUser=0 ORDER BY Data, ProfissionalID, Hora")

        response.write(recordToJSON(HorariosSQL))
        response.end
    end if
end if
%>