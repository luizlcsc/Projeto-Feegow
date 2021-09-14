<!--#include file="connect.asp"-->
<%
DominioID = req("I")

set subs = db.execute("select * from rateiodominios where dominioSuperior="&DominioID)
while not subs.eof
	db_execute("delete from rateiodominios where dominioSuperior="&subs("id"))
	db_execute("delete from rateiofuncoes where DominioID="&subs("id"))
subs.movenext
wend
subs.close
set subs=nothing

db_execute("delete from rateiodominios where id="&DominioID)
db_execute("delete from rateiofuncoes where DominioID="&DominioID)
db_execute("delete from rateiodominios where dominioSuperior="&DominioID)
%>