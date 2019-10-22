<!--#include file="connect.asp"-->
<%
'aqui faz o insert
resultado = aaTable(ref("tabela"))
ativo = ""
ativoResult = ""
if ref("tabela")<>3 then
    ativo = ", Ativo"
    ativoResult = ", 'on'"
end if
'response.Write(sql)
sql = "insert into "&resultado(0)&" (sysActive, sysUser, "&resultado(2)&" "&ativo&") values (1, "&session("User")&", '"&ref("typed")&"' "&ativoResult&")"
db_execute(sql)
set getLast = db.execute("select id from "&resultado(0)&" where sysUser="&session("User")&" and sysActive=1 order by id desc")
%>
$("#resultSelect<%=ref("selectID")%>").css("display", "none");
$("#<%=ref("selectID")%>").val("<%=ref("tabela")&"_"&getLast("id")%>");