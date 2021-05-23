<!--#include file="connect.asp"-->

<%

ConvenioID = req("ConvenioID")
QueryConvenio = "select NaoPermitirGuiaDeConsulta from convenios where id= "&ConvenioID
Consulta = db.execute(QueryConvenio)

Response.write(Consulta("NaoPermitirGuiaDeConsulta"))

%>