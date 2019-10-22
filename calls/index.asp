<%
Session.Timeout=600
session.LCID=1046
'ConnString = "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&session("Banco")&";uid=root;pwd=pipoca453;"
ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=calls;uid=root;pwd=pipoca453;"
Set db = Server.CreateObject("ADODB.Connection")
db.Open ConnString

callerID = request.QueryString("callerID")

if callerID<>"" and isnumeric(callerID) then
    callerID = ccur(callerID)
	db.execute("insert into clinic100000.chamadas (RE, Telefone) values (1, '"&callerID&"')")
end if
%>

<script>
    window.close();
</script>