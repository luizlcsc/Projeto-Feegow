<!--#include file="connect.asp"-->
Gerando ligação...
<%
I = req("I")'I eh o T  eh o tipo do contato
if req("Contato")="" or instr(req("Contato"), "_")=0 then
    Contato="NULL"
else
    Contato = "'"&req("Contato")&"'"
end if
db_execute("insert into chamadas (StaID, Contato, sysUserAtend, DataHoraAtend, RE, Telefone) values (1, "&Contato&", "&session("User")&", now(), '"&I&"', '"&req("Numero")&"')")
%>
<script type="text/javascript">
constante();
</script>