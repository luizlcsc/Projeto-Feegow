<!--#include file="connect.asp"--><%
set pForm=db.execute("select * from buiForms where id="&req("ModeloFormID"))
Especialidades=pForm("Especialidade")&" "
if req("Checado")="true" then
	Especialidades=Especialidades&"|"&req("EspecialidadeID")&"|"
else
	Especialidades=replace(Especialidades, "|"&req("EspecialidadeID")&"|", "")
end if
db_execute("update buiForms set Especialidade='"&Especialidades&"' where id="&req("ModeloFormID"))
%>Especialidade alterada com sucesso.