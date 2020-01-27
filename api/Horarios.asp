<!--#include file="../Classes/Connection.asp"-->
<!--#include file="../Classes/JSON.asp"-->
<!--#include file="../functionOcupacao.asp"-->
<%

license_id = Request.QueryString("license")
data_fim = Request.QueryString("data_fim")
data_inicio = Request.QueryString("data_inicio")
unidades = Request.QueryString("unidades")
especialidades = Request.QueryString("especialidades")
profissionais = Request.QueryString("profissionais")


get_payload = Request.QueryString("get_payload")

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

    call ocupacao(data_inicio, data_fim, especialidades, "", profissionais, "", unidades)

    if get_payload="true" then
        set HorariosSQL = dbclient.execute("SELECT * FROM agenda_horarios WHERE sysUser=0")

        response.write(recordToJSON(HorariosSQL))
        response.end
    end if
end if
%>