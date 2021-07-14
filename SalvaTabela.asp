<!--#include file="connect.asp"-->
<%
Texto=ref("Texto")
Texto=replace(replace(replace(replace(replace(replace(Texto,"'","''"),"|!_"," "),"|!1","%"),"|!2","+"),"|!3","&amp;"),"|!4",chr(10))

I=req("I")
db_execute("update buiCamposForms set Texto='"&Texto&"' where id="&I)
response.Write("update buiCamposForms set Texto='"&Texto&"' where id="&I)
%>