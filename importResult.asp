<!--#include file="connect.asp"-->
<%
I = req("I")
Sta = req("Sta")
db.execute("update cliniccentral.bancosconferir set concluido="& Sta &", sysUser="& session("User") &", DtAut=now() where id="& I)

set vcaPendImp = db.execute("select id from cliniccentral.bancosconferir where isnull(concluido) and LicencaID="& replace(session("Banco"), "clinic", ""))
if vcaPendImp.eof then
	session("pendImport")=""
	%>
	$("#pendImp").remove();
	<%
end if
%>
$("#pendImp<%= I %>").remove();

