<!--#include file="connect.asp"-->
<%
table = request.QueryString("R")
itens = split(request.Form(), "&")
Ordem = 0
for i=0 to ubound(itens)
	Ordem = Ordem+1
	spl2 = split(itens(i), "=")
	Item = replace(replace(spl2(0), "list[", ""), "]", "")
	Category = spl2(1)
	if Category="null" then
		Category = 0
	end if
	up = "update "&table&" set Category="&Category&", Ordem="&Ordem&" where id="&Item
'	response.Write(up)
	db_execute(up)
	'response.Write("Item: "&Item&" Categoria: "&Category&" |"
next
%>
