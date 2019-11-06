<!--#include file="connect.asp"-->
<%
set permform = db.execute("select id from omissaocampos")
while not permForm.eof
	db_execute("update omissaocampos set Grupo='"&ref("Grupo"&permform("id"))&"', Omitir='"&ref("Omitir"&permform("id"))&"' where id="&permform("id"))
permform.movenext
wend
permform.close
set permform=nothing
%>
new PNotify({
	type:'success',
	title:'Salvo!',
	text:'Atualizado com sucesso...',
	delay:1000
});