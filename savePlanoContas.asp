<!--#include file="connect.asp"-->
<!--#include file="planoLog.asp"-->
<%
response.Charset="utf-8"
table = request.QueryString("R")
itens = split(request.Form(), "&")
Ordem = 0


'POG para inserir o registro da categoria mãe caso não exista
set rsExists = db.execute("SELECT id FROM " & table & " WHERE id=0")
if rsExists.eof then
	if table = "sys_financialincometype" then
		catName = "RECEITAS"
	else
		catName = "DESPESAS"
	end if
	db.execute("INSERT INTO " & table & " (id, Name, sysActive) VALUES (-1, '" & catName & "', -1)")
	db.execute("UPDATE " & table & " SET id = 0 WHERE id = -1")
end if


for i=0 to ubound(itens)-1
	Ordem = Ordem+1
	spl2 = split(itens(i), ",")

	Id           = ""
	sqlUpdateSet = "Ordem=" & Ordem

	for v=0 to ubound(spl2)
		spl3 = split(spl2(v),":")

		campo = replace(spl3(0), "[", "")
		valor = replace(spl3(1), "]", "")

		if campo = "id" then
			Id = valor
		elseif campo = "Name" or campo = "Category" or campo = "Ordem" or campo = "Posicao" then

			if sqlUpdateSet <> "" then
				sqlUpdateSet = sqlUpdateSet & ", "
			end if
			sqlUpdateSet = sqlUpdateSet & campo & " = '" & valor & "'"
		end if
	next

	if sqlUpdateSet <> "" and Id <> "" then
		up = "update "&table&" SET " & sqlUpdateSet & " where id="&Id
		db.execute(up)
	end if


next
call makePrecoLogAllTable(table)

%>