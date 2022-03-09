<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
DominioID = req("D")

Formas = ref("Formas")
Protocolos = ref("Protocolos")

sqlUp = "update rateiodominios set Procedimentos='"&ref("Procedimentos")&"', Profissionais='"&ref("Profissionais")&"',GruposProfissionais='"&ref("GruposProfissionais")&"', Formas='"&Formas&"', Tabelas='"& ref("Tabelas") &"', Unidades='"& ref("Unidades") &"', Dias='"& ref("Dias") &"', Horas='"& ref("Horas") &"', Protocolos='"& ref("Protocolos") &"' where id="& DominioID
call gravaLogs(sqlUp, "AUTO", "Domínio de repasse alterado", "")

db.execute(sqlUp)
%>
location.reload();