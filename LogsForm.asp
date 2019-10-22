<!--#include file="connect.asp"-->
<%
set logs = db.execute("select * from cliniccentral.formslog where UserID="& session("User") &" and LicencaID="& replace(session("Banco"), "clinic", "") &" and m="&req("m")&" and p="& req("p") &" order by id desc")
while not logs.eof
    %>
    <h2><%=logs("DataHora") %></h2>
    <div>
        <%=logs("txt") %>
    </div>
    <%
logs.movenext
wend
logs.close
set logs=nothing
%>