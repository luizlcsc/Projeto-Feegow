<!--#include file="connect.asp"-->
<%
procedimentoId = ref("ProcedimentoID")
id = ref("ID")
acao = ref("Acao")

if acao = "ADD" then
    db_execute("insert INTO procedimentoslembrete (ProcedimentoID) VALUES ("&procedimentoId&")")
    response.write("Created")
elseif acao = "UPDATE" then
    campo = ref("Campo")
    valor = ref("Valor")
    db_execute("update procedimentoslembrete SET `"&Campo&"` = '"&valor&"' WHERE ProcedimentoID = "&procedimentoId&" AND id ="&id)
    response.write("Updated")
elseif acao = "REMOVE" then
    db_execute("delete FROM procedimentoslembrete WHERE ProcedimentoID = "&procedimentoId&" AND id = "&id)
    response.write("Deleted")
end if

%>