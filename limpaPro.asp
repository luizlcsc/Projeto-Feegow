<!--#include file="connect.asp"-->
<%
session.Timeout=100

destino = "1739_novo"
set dis = db.execute("select distinct PacienteID, DataHora from clinic"&destino&"._8 where year(DataHora)='2001'")
while not dis.eof
	set unic = db.execute("select id from clinic"&destino&"._8 where PacienteID="&dis("PacienteID")&" and DataHora="&mydatetime(dis("DataHora"))&" order by tamanho desc limit 1")
	db_execute("update clinic"&destino&"._8 set Fica=1 where id="&unic("id"))
dis.movenext
wend
dis.close
set dis=nothing
%>