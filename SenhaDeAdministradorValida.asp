<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
UsuarioID=ref("U")
Senha=ref("S")
LicencaID = replace(session("Banco"),"clinic","")

set SenhaValidaSQL = dbc.execute("SELECT id FROM cliniccentral.licencasusuarios WHERE LicencaID='"&LicencaID&"' AND Senha='"&Senha&"' AND id="&UsuarioID)

if not SenhaValidaSQL.eof then
    response.write(1)
else
    response.write(0)
end if
%>