<!--#include file="connect.asp"-->
<%
ParcelaTransacaoID = ref("I")
Acao = ref("A")
DateToReceive = ref("DateToReceive")
Fee = ref("Fee")
if Acao="B" then
    ValorParcela = ccur(ref("ValorParcela"))
    ValorCredito = ccur(ref("ValorCredito"))
    Taxa = ccur( ValorParcela-ValorCredito )
end if
Parcela = ref("Par")
Parcelas = ref("Pars")

if Acao="B" then
	'Dá baixa no recebimento da parcela

	sql = "select cc.Empresa UnidadeID, Transacao.TransactionNumber, mov.AccountIDDebit, cc.CreditAccount,cc.CategoriadTaxaID from sys_financialcreditcardreceiptinstallments rectoParcela LEFT JOIN sys_financialcreditcardtransaction Transacao on Transacao.id=rectoParcela.TransactionID LEFT JOIN sys_financialmovement mov on mov.id=Transacao.MovementID LEFT JOIN sys_financialcurrentaccounts cc on cc.id=mov.AccountIDDebit where rectoParcela.id="&ParcelaTransacaoID
	set rectoParcela = db.execute(sql)
	if not rectoParcela.EOF then
		Nome = "Transação "&left(rectoParcela("TransactionNumber")&" ", 30)&" - "&Parcela&"/"&Parcelas
		NomeFee = "Desc. trans. "&rectoParcela("TransactionNumber")&" - "&Parcela&"/"&Parcelas
		AccountIDCredit = rectoParcela("AccountIDDebit")
		UnidadeID = rectoParcela("UnidadeID")
		AccountIDDebit = rectoParcela("CreditAccount")
		CategoriadTaxaID = rectoParcela("CategoriadTaxaID")
		if AccountIDDebit=0 or isnull(AccountIDDebit) then
			Erro = "Não há uma conta corrente definida para recebimentos deste cartão de crédito. Vá até o cadastro de cartões de crédito e defina uma conta corrente para poder dar baixa nos pagamentos."
		end if
	else
		Erro = "Não foi possível dar baixa neste pagamento. Verifique suas configurações."
	end if

	if Erro="" then
		sqlInsert = "insert into sys_financialmovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Currency, Rate, sysUser, UnidadeID) values ('"&Nome&"', 1, "&AccountIDCredit&", 1, "&AccountIDDebit&", 3, "&treatvalzero(ValorCredito)&", "&mydatenull(DateToReceive)&", 'C', 'CCCred', 'BRL', 1, "&session("User")&", "&treatvalnull(UnidadeID)&")"

		db_execute(sqlInsert)
		set pult = db.execute("select id from sys_financialmovement where sysUser="&session("User")&" order by id desc LIMIT 1")
		db_execute("update sys_financialcreditcardreceiptinstallments set Fee='"&replace(replace(Fee,".",""),",",".")&"',InvoiceReceiptID="&pult("id")&" where id="&ParcelaTransacaoID)
		'fazer insert da taxa e vinculala pra depois apagala
		if Taxa>0 then
			sqlInsertFee = "insert into sys_financialmovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Currency, Rate, MovementAssociatedID, sysUser, CategoryID) values ('"&left(NomeFee, 49)&"', 1, "&AccountIDCredit&", 0, 0, 3, "&treatvalzero(Taxa)&", "&mydatenull(DateToReceive)&", 'C', 'CCFee', 'BRL', 1, "&pult("id")&", "&session("User")&",NULLIF('"&CategoriadTaxaID&"',''))"
			db.execute(sqlInsertFee)
		end if
		
		%>
	//	$("#btn<%=ParcelaTransacaoID%>").replaceWith('<button id="btn<%=ParcelaTransacaoID%>" class="btn btn-sm btn-white" type="button" onClick="baixa(<%=ParcelaTransacaoID%>, \'C\', <%=Parcela%>, <%=Parcelas%>);">Baixado <i class="fa fa-trash red"></i></button>');

        $("#btn<%=ParcelaTransacaoID%>").prop("disabled", true);
        $("#btn<%=ParcelaTransacaoID%>").html("Baixando...");
        $("#btnBuscar").click();
		<%
	else
		%>
        new PNotify({
            title: 'Falha!',
            text: '<%=Erro%>',
            type: 'danger',
            delay:5000
        });

		<%
	end if
end if

if Acao="C" then
	set rectoParcela = db.execute("select rectoParcela.*, mov.* from sys_financialcreditcardreceiptinstallments rectoParcela LEFT JOIN sys_financialmovement mov on mov.id=rectoParcela.InvoiceReceiptID where rectoParcela.id="&ParcelaTransacaoID)
	if not rectoParcela.eof then
		'1. apaga o movimento associado e apaga o movimento principal
		db_execute("delete from sys_financialmovement where id="&rectoParcela("InvoiceReceiptID")&" or MovementAssociatedID="&rectoParcela("InvoiceReceiptID"))

		'2. torna 0 a parcela do credito
		db_execute("update sys_financialcreditcardreceiptinstallments set Fee=0,InvoiceReceiptID=0 where id="&ParcelaTransacaoID)
		%>
	//	$("#btn<%=ParcelaTransacaoID%>").replaceWith('<button id="btn<%=ParcelaTransacaoID%>" class="btn btn-sm btn-success" type="button" onClick="baixa(<%=ParcelaTransacaoID%>, \'B\', <%=Parcela%>, <%=Parcelas%>);"><i class="fa fa-check"></i> Baixar</button>');
        $("#btn<%=ParcelaTransacaoID%>").prop("disabled", true);
        $("#btn<%=ParcelaTransacaoID%>").html("Cancelando...");
        $("#btnBuscar").click();
		<%
	end if
end if
%>