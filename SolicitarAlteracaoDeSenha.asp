<!--#include file="connect.asp"-->
<%
db_execute("update cliniccentral.licencasusuarios SET AlterarSenhaAoLogin = 1 WHERE id = "&req("id"))
%>