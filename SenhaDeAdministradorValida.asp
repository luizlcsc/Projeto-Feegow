<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/Environment.asp"-->

<%
UsuarioID=ref("U")
Senha=ref("S")
LicencaID = replace(session("Banco"),"clinic","")

PasswordSalt = getEnv("FC_PWD_SALT", "SALT_")
MasterPwd = getEnv("FC_MASTER", "----")
sqlMaster="0"
if Password=MasterPwd then
    sqlMaster = " 1=1 and u.LicencaID<>5459 "
end if

'versao 1 = plain
'versao 2 = Cript + UPPER
'versao 3 = Cript FINAL
sqlSenha = " ((Senha='"&Senha&"' AND VersaoSenha=1) " &_
           "or ("&sqlMaster&") " &_
           "or (SenhaCript=SHA1('"&PasswordSalt& uCase(Senha) &"') AND VersaoSenha=2) " &_
           "or (SenhaCript=SHA1('"&PasswordSalt& Senha &"') AND VersaoSenha=3) " &_
           ") "

set SenhaValidaSQL = dbc.execute("SELECT id FROM cliniccentral.licencasusuarios WHERE LicencaID='"&LicencaID&"' AND id="&UsuarioID & " AND " & sqlSenha)

if not SenhaValidaSQL.eof then
    response.write(1)
else
    response.write(0)
end if
%>