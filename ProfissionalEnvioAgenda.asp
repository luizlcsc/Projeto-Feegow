<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
ProfissionalID=req("ProfissionalID")
LicencaID=replace(session("Banco"),"clinic","")

set EnviosSQL = dbc.execute("SELECT * FROM cliniccentral.envio_agenda_profissional WHERE LicencaID="&LicencaID&" AND ProfissionalID="&ProfissionalID&" ORDER BY DataHora DESC limit 100")


if not EnviosSQL.eof then
%>
<table class="table table-bordered table-striped">
    <thead>
        <tr>
            <th>Data e hora</th>
            <th>Status</th>
            <th>Número de agendamentos</th>
            <th>E-mail</th>
        </tr>
    </thead>
    <tbody>
    <%
    while not EnviosSQL.eof

        if EnviosSQL("Enviado") and EnviosSQL("NumeroAgendamentos")>0 and EnviosSQL("StatusEnvio")&""="202"  then
            strStatus="Enviado"
            classeStatus="success"
        elseif EnviosSQL("Enviado") and EnviosSQL("NumeroAgendamentos")>0 and EnviosSQL("StatusEnvio")&""<>"202" then
            strStatus="Erro no envio"
            classeStatus="danger"
        else
            strStatus="Não enviado"
            classeStatus="warning"
        end if
    %>
        <tr>
            <td><%=EnviosSQL("DataHora")%></td>
            <td><span class="label label-<%=classeStatus%>"><%=strStatus%></span></td>
            <td><%=EnviosSQL("NumeroAgendamentos")%></td>
            <td><%=EnviosSQL("Email")%></td>
        </tr>
    <%
    EnviosSQL.movenext
    wend
    EnviosSQL.close
    set EnviosSQL=nothing
    %>
    </tbody>
</table>
<%
else
%>
Nenhum registro encontrado.
<%
end if
%>