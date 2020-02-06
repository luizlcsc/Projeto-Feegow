<!--#include file="connect.asp"-->
<!--#include file="Classes/Connection.asp"-->
<%
A = ref("A")
L = ref("L")
StaID = ref("StaID")
Notas = ref("Notas")

set LicencaSQL = db.execute("SELECT Servidor FROM cliniccentral.licencas WHERE id="&treatvalzero(L))

set dbClient = newConnection("clinic"&L, LicencaSQL("Servidor"))

sql = "update clinic"&L&".agendamentos set StaID="& StaID &", Notas='"& ref("Notas") &"' where id="& A

dbClient.execute( sql )
%>
showMessageDialog("Alterado com sucesso", "success");
$("tr[data-id=<%=A%>]").find(".label-status").find("img").attr("src", "assets/img/<%=StaID%>.png");
$("tr[data-id=<%=A%>]").find(".btn-group").removeClass("open");
