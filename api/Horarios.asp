<!--#include file="../Classes/Connection.asp"-->
<!--#include file="../Classes/JSON.asp"-->
<!--#include file="../functionOcupacao.asp"-->
<%

license_id = Request.QueryString("license")
data_fim = Request.QueryString("data_fim")
data_inicio = Request.QueryString("data_inicio")
unidades = Request.QueryString("unidades")
especialidades = Request.QueryString("especialidades")
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

    call ocupacao(data_inicio, data_fim, especialidades, "", "", "", unidades)

    set HorariosSQL = dbclient.execute("SELECT * FROM rel_ocupacao WHERE sysUser=0")

    dbclient.execute("DELETE FROM agenda_horarios WHERE sysUser=0")
    dbclient.execute("INSERT INTO agenda_horarios (sysUser, Data, Hora, StaID, Situacao, ProfissionalID, EspecialidadeID, LocalID, UnidadeID, BloqueioID, AgendamentoID, TipoGrade, GradeID, Bloqueado, Encaixe, GradeOriginal) "&_
    "  (SELECT sysUser, Data, Hora, StaID, Situacao, ProfissionalID, EspecialidadeID, LocalID, UnidadeID, null, null, TipoGrade, GradeID, Bloqueado, Encaixe, GradeOriginal FROM rel_ocupacao WHERE sysUser=0)")

    if get_payload="true" then
        response.write(recordToJSON(HorariosSQL))
        response.end
    end if
end if
%>