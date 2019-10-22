<!--#include file="connect.asp"-->
<%
InvoiceID = req("I")
CD = ref("T")

if left(ref("AccountID"), 2)="3_" then
	splPac = split(ref("AccountID"), "_")
	PacienteID = splPac(1)
end if

set caixa = db.execute("select * from caixa where sysUser="&session("User")&" and isnull(dtFechamento)")
if not caixa.eof then
	CaixaID = caixa("id")
end if

'Verificar se há lancto financeiro em qualquer das parcelas antes de alterar dados da invoice
set inv = db.execute("select * from sys_financialinvoices where id="&InvoiceID)

set pg = db.execute("select m.id from sys_financialmovement m left join sys_financialdiscountpayments d on (d.InstallmentID=m.id or d.MovementID=m.id) where m.InvoiceID="&InvoiceID&" and not isnull(d.InstallmentID) and not isnull(d.MovementID)")
if not pg.eof then
	existePagto = "S"
end if

if existePagto="" then
	splAcc = split(ref("AccountID"), "_")
	splForma = split(ref("FormaID"), "_")

	AssociationAccountID = splAcc(0)
	AccountID = splAcc(1)

	if CD="C" then
		AccountAssociationIDCredit = 0
		AccountIDCredit = 0
		AccountAssociationIDDebit = AssociationAccountID
		AccountIDDebit = AccountID
		reverse = "D"
	else
		AccountAssociationIDCredit = AssociationAccountID
		AccountIDCredit = AccountID
		AccountAssociationIDDebit = 0
		AccountIDDebit = 0
		reverse = "C"
	end if

	'1. Verificar erro de valores digitados errado
	splInv = split(ref("inputs"), ", ")
	totInvo = 0
	for i=0 to ubound(splInv)
		valInv = ref("ValorUnitario"&splInv(i))
		quaInv = ref("Quantidade"&splInv(i))
		desInv = ref("Desconto"&splInv(i))
		acrInv = ref("Acrescimo"&splInv(i))
		if isnumeric(valInv) and valInv<>"" then valInv=ccur(valInv) else valInv=0 end if
		if isnumeric(quaInv) and quaInv<>"" then quaInv=ccur(quaInv) else quaInv=1 end if
		if isnumeric(desInv) and desInv<>"" then desInv=ccur(desInv) else desInv=0 end if
		if isnumeric(acrInv) and acrInv<>"" then acrInv=ccur(acrInv) else acrInv=0 end if
		totInvo = totInvo + (quaInv * (valInv-desInv+acrInv))
	next
	
	splPar = split(ref("ParcelasID"), ", ")
	totParc = 0
	for i=0 to ubound(splPar)
		valPar = ref("Value"&splPar(i))
		if isnumeric(valPar) and valPar<>"" then
			valPar = ccur(valPar)
			totParc = totParc+valPar
		end if
	next
	if totInvo<=(totParc-0.03) or totInvo>=(totParc+0.03) then
		erro = "O valor total n&atilde;o coincide com a soma das parcelas."
	end if
end if


if erro="" then

	'rateios
	db_execute("delete rr from rateiorateios rr left join itensinvoice ii on rr.ItemInvoiceID=ii.id where ii.InvoiceID="&InvoiceID&" and (isnull(rr.ItemContaAPagar) OR rr.ItemContaAPagar=0)")
	splInv = split(ref("inputs"), ", ")
		
	if existePagto="" then
		'itens
		db_execute("delete from itensinvoice where InvoiceID="&InvoiceID)
		
		'-> roda de novo o processo de cima
		totInvo = 0
		
		
		for i=0 to ubound(splInv)
			ii = splInv(i)
			Row = ccur(ii)
			valInv = ref("ValorUnitario"&splInv(i))
			quaInv = ref("Quantidade"&splInv(i))
			desInv = ref("Desconto"&splInv(i))
			acrInv = ref("Acrescimo"&splInv(i))
			if isnumeric(valInv) and valInv<>"" then valInv=ccur(valInv) else valInv=0 end if
			if isnumeric(quaInv) and quaInv<>"" then quaInv=ccur(quaInv) else quaInv=1 end if
			if isnumeric(desInv) and desInv<>"" then desInv=ccur(desInv) else desInv=0 end if
			if isnumeric(acrInv) and acrInv<>"" then acrInv=ccur(acrInv) else acrInv=0 end if
			if Row>0 then
				camID = "id,"
				valID = ii&","
			else
				camID = ""
				valID = ""
			end if
			if ref("ItemID"&ii)<>"" then Tipo="S" else Tipo="O" end if
				if instr(ref("ProfissionalID"&ii), "_")>0 then
					splAssoc = split(ref("ProfissionalID"&ii), "_")
					Associacao = splAssoc(0)
					ProfissionalID = splAssoc(1)
				else
					Associacao = 0
					ProfissionalID = 0
				end if
			
				sqlInsert = "insert into itensinvoice ("&camID&" InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, Executado, DataExecucao, HoraExecucao, AgendamentoID, sysUser, ProfissionalID, HoraFim, Acrescimo, AtendimentoID, Associacao) values ("&valID&" "&InvoiceID&", '"&Tipo&"', "&quaInv&", "&treatvalzero(ref("CategoriaID"&ii))&", "&treatvalzero(ref("ItemID"&ii))&", "&treatvalzero(ref("ValorUnitario"&ii))&", "&treatvalzero(ref("Desconto"&ii))&", '"&ref("Descricao"&ii)&"', '"&ref("Executado"&ii)&"', "&mydatenull(ref("DataExecucao"&ii))&", "&mytime(ref("HoraExecucao"&ii))&", "&treatvalzero(ref("AgendamentoID"&ii))&", "&session("User")&", "&treatvalzero(ProfissionalID)&", "&mytime(ref("HoraFim"&ii))&", "&treatvalzero(ref("Acrescimo"&ii))&", "&treatvalnull(ref("AtendimentoID"&ii))&", "&Associacao&")"
			'response.Write("//"&ii&" - "&sqlInsert)
			db_execute(sqlInsert)
			'->itens do rateio irão aqui-----

			if Row<0 then
				set pult = db.execute("select id from itensinvoice order by id desc limit 1")
				NewItemID = pult("id")
			else
				NewItemID = Row
			end if
            rows = rows & "|" & Row
            ids = ids & "|" & NewItemID

		next
		'<-



		
		'parcelas
		'-> --------------------------------------------------------------------------
		db_execute("delete from sys_financialmovement where InvoiceID="&InvoiceID)
		splPar = split(ref("ParcelasID"), ", ")
		totParc = 0
		c=0
		for i=0 to ubound(splPar)
			valPar = ref("Value"&splPar(i))
			ii = splPar(i)
			if isnumeric(valPar) and valPar<>"" then
				c=c+1
				valPar = ccur(valPar)
				totParc = totParc+valPar
				if ccur(ii)>0 then
					camID = "id,"
					valID = ii&","
				else
					camID = ""
					valID = ""
				end if
				sqlFM = "insert into sys_financialmovement ("&camID&" AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, CaixaID, UnidadeID) values ("&valID&"  "&AccountAssociationIDCredit&", "&AccountIDCredit&", "&AccountAssociationIDDebit&", "&AccountIDDebit&", "&treatvalzero(ref("Value"&ii))&", "&mydatenull(ref("Date"&ii))&", '"&inv("CD")&"', 'Bill', 'BRL', "&treatvalnull(ii)&", "&InvoiceID&", "&c&", "&session("User")&", "&treatvalnull(CaixaID)&", "&treatvalzero(ref("CompanyUnitID"))&")"
				'response.Write("//|||||||||||||||||||||| sqlFM: "&sqlFM)
				db_execute(sqlFM)
			end if
		next

        if ref("sysActive")="0" then
            sqlCaixaID = ",CaixaID="&treatvalnull(session("CaixaID"))
        end if
		db_execute("update sys_financialinvoices set AccountID="&AccountID&", AssociationAccountID="&AssociationAccountID&", Value="&treatvalzero(ref("Valor"))&", Tax=1, Currency='BRL', Recurrence="&treatvalnull(ref("Recurrence"))&", RecurrenceType='"&ref("RecurrenceType")&"', FormaID="&splForma(0)&", ContaRectoID="&splForma(1)&", sysActive=1 "& sqlCaixaID &" , sysUser="&session("User")& gravaData &" where id="&InvoiceID)

	else
		'ou seja, se já existem pagamentos, ele apenas atualiza os dados de execução dos itens desta invoice
		'-> roda de novo o processo de cima
		for i=0 to ubound(splInv)
			ii = splInv(i)
			Row = ccur(ii)
			if Row>0 then
				camID = "id"
				valID = ii
			else
				camID = ""
				valID = ""
			end if
			if instr(ref("ProfissionalID"&ii), "_")>0 then
				splAssoc = split(ref("ProfissionalID"&ii), "_")
				Associacao = splAssoc(0)
				ProfissionalID = splAssoc(1)
			else
				Associacao = 0
				ProfissionalID = 0
			end if

			'pega atendimento baseado na data e na hora
			AtendimentoID = 0'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			sqlUpdate = "update itensinvoice set Executado='"&ref("Executado"&ii)&"', DataExecucao="&mydatenull(ref("DataExecucao"&ii))&", HoraExecucao="&mytime(ref("HoraExecucao"&ii))&", AgendamentoID="&treatvalzero(ref("AgendamentoID"&ii))&", CategoriaID="&treatvalzero(ref("CategoriaID"&ii))&", ProfissionalID="&treatvalzero(ProfissionalID)&", HoraFim="&mytime(ref("HoraFim"&ii))&", AtendimentoID="&AtendimentoID&", Associacao="&treatvalzero(Associacao)&", Descricao='"&ref("Descricao"&ii)&"' WHERE id="&valID
			'response.Write("|"&sqlUpdate&"|")
			db_execute(sqlUpdate)
			'->itens do rateio irão aqui-----
'			if Row<0 then
'				set pult = db.execute("select id from itensinvoice order by id desc limit 1")
'				NewItemID = pult("id")
'			else
				NewItemID = Row
'			end if
            rows = rows & "|" & Row
            ids = ids & "|" & NewItemID

		next
		'<-
	
	end if

	db_execute("update sys_financialinvoices set Description='"&ref("Description")&"', CompanyUnitID="&treatvalzero(ref("CompanyUnitID"))&", sysDate="&mydatenull(ref("sysDate"))&" where id="&InvoiceID)





    splRows = split(rows, "|")
    splIds = split(ids, "|")

    for r=1 to ubound(splIds)
        LinhaID = splRows(r)
        ItemID = splIds(r)
        call salvaRepasse(LinhaID, ItemID)
    next


	%>
	$.gritter.add({
		title: '<i class="fa fa-save"></i> Salvo com sucesso!',
		text: '',
		class_name: 'gritter-success gritter-light'
	});
	geraParcelas('N');
	$("#sysActive").val("1");

    if( $.isNumeric($("#PacienteID").val()) && $("#PendPagar").val()=="" )
    {
        ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
    }

    itens('<%=CD%>', '', '');
	<%
else
	%>
	$.gritter.add({
		title: '<i class="fa fa-error"></i> ERRO AO TENTAR SALVAR!',
		text: '<%=erro%>',
		class_name: 'gritter-error'
	});
	<%
end if
%>

<!--#include file="disconnect.asp"-->