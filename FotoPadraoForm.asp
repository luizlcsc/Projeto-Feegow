<!--#include file="connect.asp"--><%
CampoID = req("CampoID")
FileName = req("FileName")

db_execute("update buicamposforms set ValorPadrao='"&FileName&"' where id="&CampoID)
'response.Write(reg(""&Col&""))
%>
$("#divFotoPadrao").html('<img src="uploads/<%=fileName%>" style="max-width:95%; max-height:90%;">');