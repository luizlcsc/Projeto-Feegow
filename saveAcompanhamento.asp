<!--#include file="connect.asp"-->
<%
id = ref("id")
Acompanhamento = ref("Acompanhamento")
ProximoContato = mydatenull(ref("ProximoContato"))

db_execute("update cliniccentral.licencas set Acompanhamento='"&Acompanhamento&"', ProximoContato="&ProximoContato&" where id="&id)
%>