<!--#include file="connect.asp"-->
<!--#include file="Classes/ExecuteAllServers.asp"-->
<%
call ExecuteAllServers("update cliniccentral.licencasusuarios SET AlterarSenhaAoLogin = 1 WHERE id = "&req("id"))
%>