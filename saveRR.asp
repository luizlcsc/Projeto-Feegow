<!--#include file="connect.asp"-->
<%
splF = split( ref("itensF"), ", " )
for i=0 to ubound(splF)
	splIF = split(splF(i), "_")
	set fun = db.execute("select * from rateiofuncoes where id="&splIF(1))
	if not fun.eof then
		muid = splF(i)
		set vca = db.execute("select * from rateiorateios where ItemInvoiceID="&splIF(0)&" and FuncaoID="&fun("id"))
		if vca.eof then
			db_execute("insert into rateiorateios (ItemInvoiceID, Funcao, TipoValor, Valor, ContaCredito, sysDate, FormaID, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, FuncaoID) values ("&splIF(0)&", '"&rep(fun("Funcao"))&"', '"&fun("TipoValor")&"', "&treatvalzero(fun("Valor"))&", '"&ref("ContaCredito"&muid)&"', "&mydatenull(date())&", 0, '"&fun("Sobre")&"', '"&fun("FM")&"', 0, "&treatvalzero(fun("ValorUnitario"))&", "&treatvalzero(fun("Quantidade"))&", "&splIF(1)&")")
		else
			db_execute("update rateiorateios set ContaCredito='"&ref("ContaCredito"&muid)&"' where id="&vca("id"))
		end if
	end if
next

splM = split( ref("itensM"), ", " )
for i=0 to ubound(splM)
	splIM = split(splM(i), "_")
	set fun = db.execute("select * from rateiofuncoes where id="&splIM(1))
	if not fun.eof then
		muid = splM(i)
		set vca = db.execute("select * from rateiorateios where ItemInvoiceID="&splIM(0)&" and FuncaoID="&fun("id"))
		if vca.eof then
			db_execute("insert into rateiorateios (ItemInvoiceID, Funcao, TipoValor, Valor, ContaCredito, sysDate, FormaID, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, FuncaoID) values ("&splIM(0)&", '"&rep(fun("Funcao"))&"', '"&fun("TipoValor")&"', "&treatvalzero(fun("Valor"))&", '"&ref("ContaCredito"&muid)&"', "&mydatenull(date())&", 0, '"&fun("Sobre")&"', '"&fun("FM")&"', 0, "&treatvalzero(fun("ValorUnitario"))&", "&treatvalzero(ref("Quantidade"&muid))&", "&fun("id")&")")
		else
			db_execute("update rateiorateios set ContaCredito='"&ref("ContaCredito"&muid)&"', Quantidade="&treatvalzero(ref("Quantidade"&muid))&" where id="&vca("id"))
		end if
	end if
next
%>
$("#modal-table").modal("hide");
<!--#include file="disconnect.asp"-->