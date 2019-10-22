<!--#include file="connect.asp"-->
<%
'aqui faz o insert
if ref("mainFormColumn")<>"" then
	Coluna = ", "&ref("mainFormColumn")
	ValorColuna = ", '"&ref("campoSuperior")&"'"
end if
'response.Write(sql)
set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName like '"&ref("resource")&"'")
if not dadosResource.eof then
	othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
	if not isnull(othersToAddSelectInsert) then
		spl = split(othersToAddSelectInsert, ", ")
		for i=0 to ubound(spl)
			compInsert = compInsert&", "&spl(i)
			valInsert = valInsert&", '"&ref(spl(i))&"'"
		next
	end if
end if
sql = "insert into "&ref("resource")&" (sysActive, sysUser, "&ref("showColumn")&Coluna&compInsert&") values (1, "&session("User")&", '"&ref("typed")&"'"&ValorColuna&valInsert&")"
db_execute(sql)
set getLast = db.execute("select id from "&ref("resource")&" where sysUser="&session("User")&" and sysActive=1 order by id desc")
%>
$("#resultSelect<%=ref("selectID")%>").css("display", "none");
$("#<%=ref("selectID")%>").val("<%=getLast("id")%>");
$("#search<%=ref("selectID")%>").val("<%=ref("typed")%>");