<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/Environment.asp"-->
<%
Versao = req("Versao")

set VersaoSQL = dbc.execute("SELECT Versao FROM cliniccentral.Versoes WHERE Versao='"&Versao&"'")

if not VersaoSQL.eof then
    dbc.execute("UPDATE licencas SET PastaAplicacao='"&VersaoSQL("Versao")&"' WHERE id="&LicenseID)
    session("PastaAplicacaoRedirect") = VersaoSQL("Versao")

    if getEnv("FC_APP_ENV","local")="production" then
        response.Redirect("./"&VersaoSQL("Versao")&"/?P=Home&Pers=1")
    else
        response.Redirect("./?P=Home&Pers=1")
    end if
end if

%>