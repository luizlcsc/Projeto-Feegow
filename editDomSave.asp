<!--#include file="connect.asp"-->
<%
DominioID = req("D")

Formas = ref("Formas")


db.execute("update rateiodominios set Procedimentos='"&ref("Procedimentos")&"', Profissionais='"&ref("Profissionais")&"',GruposProfissionais='"&ref("GruposProfissionais")&"', Formas='"&Formas&"', Tabelas='"& ref("Tabelas") &"', Unidades='"& ref("Unidades") &"', Dias='"& ref("Dias") &"', Horas='"& ref("Horas") &"' where id="& DominioID)
%>
location.reload();