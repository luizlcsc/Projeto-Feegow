$("#calls").html("");
<%
ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=192.168.193.43;Database=calls;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set dbCall = Server.CreateObject("ADODB.Connection")
dbCall.Open ConnString

set calls = dbCall.execute("select * from calls where Atendido=0 and now()<DATE_ADD(Hora,INTERVAL 2 MINUTE)")
if not calls.eof then
	%>
	$("#calls").css("display", "block");
	$("#calls").css("padding", "15px");
	$("#calls").css("z-index", "1000000");
    $("#calls").html("<h4 class='blue'>NOVA CHAMADA</h4>");
	<%
else
	%>
	$("#calls").css("display", "none");
	<%
end if
while not calls.eof
	%>$("#calls").html( $("#calls").html() + "<div>Novo Paciente - <%=calls("Numero")%> - <button type='button' class='btn btn-sm btn-success'><i class='far fa-phone-square'></i> Atender</button></div><br>");<%
calls.movenext
wend
calls.close
set calls=nothing
%>