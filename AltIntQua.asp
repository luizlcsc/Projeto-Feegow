<!--#include file="connect.asp"--><%
'response.Write(request.QueryString())
n=0
strUpDt=""
while n<7
	n=n+1
	if isNumeric(request.QueryString("d"&n)) and not request.QueryString("d"&n)="" and request.QueryString("d"&n)>"0" then
		strUpDt=strUpDt&"d"&n&"='"&request.QueryString("d"&n)&"',"
	else
		resultado="Erro: O tempo de intervalo entre cada agendamento deve ser definido em números válidos. Não são aceitas letras, valores menores que zero e valores vazios. Verifique os valores digitados."
	end if
wend

if strUpDt<>"" and resultado="" then
	strUpDt=left(strUpDt,(len(strUpDt)-1))
	db_execute("update Locais set "&strUpDt&" where id = '"&request.QueryString("Local")&"'")
resultado="Intervalos atualizados com sucesso."
end if
response.Write(resultado)
%>
