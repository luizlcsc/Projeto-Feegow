<!--#include file="connect.asp"-->
<%
I = req("I")
db.execute("update buiforms set Prior="& treatvalzero(ref("Prior")) &" where id="& I)
%>