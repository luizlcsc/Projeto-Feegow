<!--#include file="connect.asp"-->
<%
CampoID = req("CampoID")
FormID = req("FormID")
Acao = req("Acao")'0=remove, 1=add

if FormID="0" then
	'Significa que esta é uma nova linha do modelo
	if Acao = "1" then
		db_execute("insert into buitabelasmodelos (CampoID) values ("&CampoID&")")
	elseif Acao="0" then
		db_execute("delete from buitabelasmodelos where id="&CampoID)
	end if
	%>
    refLay();
    <%
else
	'É uma nova linha do form preenchido
end if
%>