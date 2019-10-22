<!--#include file="connect.asp"-->
<%
set permform = db.execute("select id from obrigacampos")
while not permForm.eof
	db_execute("update obrigacampos set Grupo='"&ref("Grupo"&permform("id"))&"', Obrigar='"&ref("Obrigar"&permform("id"))&"', Exibir='"&ref("Exibir"&permform("id"))&"' where id="&permform("id"))
permform.movenext
wend
permform.close
set permform=nothing
%>
new PNotify({
    title: 'Sucesso!',
    text: 'Campos obrigatórios salvos!',
    type: 'success',
    delay: 3000
});