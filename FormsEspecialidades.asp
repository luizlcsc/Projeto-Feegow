<!--#include file="connect.asp"--><%
set pForm=db.execute("select * from buiForms where id="&request.QueryString("ModeloFormID"))
Especialidades=pForm("Especialidade")&" "
if request.QueryString("Checado")="true" then
	Especialidades=Especialidades&"|"&request.QueryString("EspecialidadeID")&"|"
else
	Especialidades=replace(Especialidades, "|"&request.QueryString("EspecialidadeID")&"|", "")
end if
db_execute("update buiForms set Especialidade='"&Especialidades&"' where id="&request.QueryString("ModeloFormID"))
%>Especialidade alterada com sucesso.