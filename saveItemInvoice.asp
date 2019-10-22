<!--#include file="connect.asp"-->
<%
TipoItem = request.QueryString("TipoItem")
TipoAcao = request.QueryString("TipoAcao")
InvoiceID = request.QueryString("InvoiceID")
ItemInvoiceID = ccur(request.QueryString("I"))
str = ref("str")

if TipoItem = "S" then

	if ItemInvoiceID<>0 then
		set pSobra = db.execute("select id from itensinvoice where ItemID=(select ItemID from itensinvoice where id="&ItemInvoiceID&") and InvoiceID="&InvoiceID)
		while not pSobra.eof
			Sobra = Sobra&"|"&pSobra("id")&"|"
		pSobra.movenext
		wend
		pSobra.close
		set pSobra=nothing
		%>//alert('<%=ItemInvoiceID%>');<%
	end if
	spl = split(str, "|")
	for i=0 to ubound(spl)
		if spl(i)<>"" and isnumeric(spl(i)) then
			n = ccur(spl(i))
			Tipo = "S"
			CategoriaID = 0
			ItemID = ref("ProcedimentoID")
			if n<0 then
				db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Executado, DataExecucao, HoraExecucao, HoraFim, ProfissionalID, sysUser) values ('"&InvoiceID&"', '"&Tipo&"', 1, '"&CategoriaID&"', '"&ItemID&"', "&treatValZero(ref("ValorUnitario"&n))&", "&treatValZero(ref("Desconto"&n))&", '"&ref("Executado"&n)&"', "&myDateNULL(ref("DataExecucao"&n))&", "&myTime(ref("HoraExecucao"&n))&", "&myTime(ref("HoraFim"&n))&", "&ref("ProfissionalID"&n)&", '"&session("User")&"')")
				set pult = db.execute("select id from itensinvoice order by id desc limit 1")
				EsteItem = pult("id")
			else
				EsteItem = n
				db_execute("update itensinvoice set Executado='"&ref("Executado"&n)&"', DataExecucao="&mydateNULL(ref("DataExecucao"&n))&", HoraExecucao="&myTime(ref("HoraExecucao"&n))&", HoraFim="&myTime(ref("HoraFim"&n))&", ProfissionalID="&ref("ProfissionalID"&n)&", ValorUnitario="&treatValZero(ref("ValorUnitario"&n))&", Desconto="&treatValZero(ref("Desconto"&n))&" where id="&n)
			end if
			sobra = replace(sobra, "|"&n&"|", "")

			'inicio da gravacao dos repasses
			SobraRep = ""
			splRep = split(ref("strRep"&n), "|")
			set pSobraRep = db.execute("select id from rateiorateios where ItemInvoiceID="&EsteItem)
			while not pSobraRep.eof
				SobraRep = SobraRep&"|"&pSobraRep("id")&"|"
			pSobraRep.movenext
			wend
			pSobraRep.close
			set pSobraRep=nothing

			if ref("ProfissionalID"&n)<>0 then
				for g=0 to ubound(splRep)
					if splRep(g)<>"" and isnumeric(splRep(g)) then
						nRep = ccur(splRep(g))
						if nRep<0 then
						'	response.Write("insert into rateiorateios (ItemInvoiceID, Funcao, TipoValor, Sobre, Valor, ContaCredito, sysDate, FM, ProdutoID, ValorUnitario, Quantidade) values ("&EsteItem&", '"&ref("Funcao"&n&"-"&nRep)&"', '"&ref("TipoValor"&n&"-"&nRep)&"', '"&ref("Sobre"&n&"-"&nRep)&"', "&treatvalzero(ref("Valor"&n&"-"&nRep))&", '"&ref("ContaCredito"&n&"-"&nRep)&"', '"&mydate(date())&"', '"&ref("FM"&n&"-"&nRep)&"', "&treatvalzero(ref("ProdutoID"&n&"-"&nRep))&", "&treatvalzero(ref("ValorUnitario"&n&"-"&nRep))&"', "&treatvalzero(ref("Quantidade"&n&"-"&nRep))&")")
							db_execute("insert into rateiorateios (ItemInvoiceID, Funcao, TipoValor, Sobre, Valor, ContaCredito, sysDate, FM, ProdutoID, ValorUnitario, Quantidade) values ("&EsteItem&", '"&ref("Funcao"&n&"-"&nRep)&"', '"&ref("TipoValor"&n&"-"&nRep)&"', '"&ref("Sobre"&n&"-"&nRep)&"', "&treatvalzero(ref("Valor"&n&"-"&nRep))&", '"&ref("ContaCredito"&n&"-"&nRep)&"', '"&mydate(date())&"', '"&ref("FM"&n&"-"&nRep)&"', "&treatvalzero(ref("ProdutoID"&n&"-"&nRep))&", "&treatvalzero(ref("ValorUnitario"&n&"-"&nRep))&", "&treatvalzero(ref("Quantidade"&n&"-"&nRep))&")")
						else
							db_execute("update rateiorateios set Funcao='"&ref("Funcao"&n&"-"&nRep)&"', TipoValor='"&ref("TipoValor"&n&"-"&nRep)&"', Sobre='"&ref("Sobre"&n&"-"&nRep)&"', Valor="&treatvalzero(ref("Valor"&n&"-"&nRep))&", ContaCredito='"&ref("ContaCredito"&n&"-"&nRep)&"', sysDate='"&mydate(date())&"', ProdutoID="&treatvalzero(ref("ProdutoID"&n&"-"&nRep))&", ValorUnitario="&treatvalzero(ref("ValorUnitario"&n&"-"&nRep))&", Quantidade="&treatvalzero(ref("Quantidade"&n&"-"&nRep))&" where id="&nRep)
						end if
						sobraRep = replace(sobraRep, "|"&nRep&"|", "")
					end if
				next
			end if

			splSobraRep = split(sobraRep, "|")
			for h=0 to ubound(splSobraRep)
				if splSobraRep(h)<>"" and isnumeric(splSobraRep(h)) then
					db_execute("delete from rateiorateios where id="&splSobraRep(h))
				end if
			next
			'fim da gravacao dos repasses

		end if
	next
	splSobra = split(sobra, "|")
	for j=0 to ubound(splSobra)
		if splSobra(j)<>"" and isnumeric(splSobra(j)) then
			db_execute("delete from itensinvoice where id="&splSobra(j))
		end if
	next

elseif TipoItem = "O" then
	Tipo = "O"
	Quantidade = ccur(ref("Quantidade"))
	CategoriaID = ref("CategoriaID")
	Descricao = ref("Descricao")
	ItemID = 0
	ValorUnitario = ref("Valor")
	Desconto = ref("Desconto")
	if ItemInvoiceID=0 then
		db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, Descricao, CategoriaID, ItemID, ValorUnitario, Desconto, sysUser) values ('"&InvoiceID&"', '"&Tipo&"', "&Quantidade&", '"&Descricao&"', "&treatvalZero(CategoriaID)&", '"&ItemID&"', "&treatValZero(ValorUnitario)&", "&treatValZero(Desconto)&", '"&session("User")&"')")
	else
		db_execute("update itensinvoice set Quantidade='"&Quantidade&"', Descricao='"&Descricao&"', CategoriaID="&treatvalZero(CategoriaID)&", ValorUnitario="&treatValZero(ValorUnitario)&", Desconto="&treatValZero(Desconto)&" where id="&ItemInvoiceID)
	end if
end if
%>
//alert('<%=request.Form()%>');
atualizaItens();
$("#modal-table").modal("hide");