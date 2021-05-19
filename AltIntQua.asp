<!--#include file="connect.asp"--><%
'response.Write(req())
n=0
strUpDt=""
while n<7
	n=n+1
	if isNumeric(req("d"&n)) and not req("d"&n)="" and req("d"&n)>"0" then
		strUpDt=strUpDt&"d"&n&"='"&req("d"&n)&"',"
	else
		resultado="Erro: O tempo de intervalo entre cada agendamento deve ser definido em números válidos. Não são aceitas letras, valores menores que zero e valores vazios. Verifique os valores digitados."
	end if
wend

if strUpDt<>"" and resultado="" then
	strUpDt=left(strUpDt,(len(strUpDt)-1))
	db_execute("update Locais set "&strUpDt&" where id = '"&req("Local")&"'")
resultado="Intervalos atualizados com sucesso."
end if
response.Write(resultado)
%>
