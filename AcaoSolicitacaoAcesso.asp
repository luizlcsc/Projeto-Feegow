<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
Acao = ref("Acao")
SolicitacaoID = ref("SolicitacaoID")

if Acao="CONFIRMAR" then
    Status = "APROVADO"
end if
if Acao="RECUSAR" then
    Status = "RECUSADO"
end if

dbc.execute("UPDATE cliniccentral.admin_senhas_master SET DataHoraAprovacao=NOW(),UsuarioAprovacaoID="&session("User")&",Status='"&Status&"' "&_
"WHERE id="&SolicitacaoID&" AND LicencaID="&LicenseId&" AND Status='PENDENTE' AND DATE(dataHora)=CURDATE()")
%>