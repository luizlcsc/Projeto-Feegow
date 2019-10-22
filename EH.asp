<!--#include file="connect.asp"-->
<%
Err.Clear
On Error Resume Next
set p = db.execute("select * from convenios")
response.Write( p("lfe") )

if err.number<>0 then
	response.Write("O erro é="&err.description)
end if
'On Error GoTo 0
%>
