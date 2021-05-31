<!--#include file="connect.asp"-->
<!--#include file="planoLog.asp"-->
<%
response.Charset="utf-8"
table = req("R")
itens = split(ref(), "&")
Ordem = 0


for i=0 to ubound(itens)-1
	Ordem = Ordem+1
	spl2 = split(itens(i), ";")

	Id = ""
	Name=""
	Categoria = 0
	posicao = ""
	for v=0 to ubound(spl2)
		spl3 = split(spl2(v),":")

		campo = replace(spl3(0), "[", "")
		valor = replace(replace(spl3(1), "]", ""),"'","\'")


		select Case campo
			case "id"
				Id = valor
			case "categoria"
				Categoria = valor
			case "nome"
				Name = valor
            case "posicao"
                posicao = valor
		end select
	next

	up = "update "&table&" SET Name='"&Name&"', Category="&Categoria&", Ordem="&Ordem&", Posicao='"&posicao&"' where id="&Id

	' response.Write(up)
	' response.write("</br>")

	db.execute(up)
	'response.Write("Item: "&Item&" Categoria: "&Category&" |"
next
call makePrecoLogAllTable(table)

%>