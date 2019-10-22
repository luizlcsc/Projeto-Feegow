<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->

<% 

db.execute("SET SESSION group_concat_max_len = 1000000; ")
set jsonProfissional = db.execute("select id, Bandeira name from cliniccentral.bandeiras_cartao WHERE true;")

Response.ContentType = "application/json"
response.write(recordToJSON(jsonProfissional))
response.end



%>