<!--#include file="connect.asp"-->
<%
ProfissionalID = request.QueryString("ProfissionalID")
Data = mydatenull(request.QueryString("Data"))
Observacoes = ref("Observacoes")
if ProfissionalID = "undefined" then
    ProfissionalID = "0"
end if

set vca = db.execute("select * from agendaobservacoes where ProfissionalID="&ProfissionalID&" and Data="&Data)
if vca.eof then
    db_execute("insert into agendaobservacoes (ProfissionalID, Data, Observacoes) values ("&ProfissionalID&", "&Data&", '"&Observacoes&"')")
else
    db_execute("update agendaobservacoes set Observacoes='"&Observacoes&"' where id="&vca("id"))
end if
%>