<!--#include file="connect.asp"-->
<%
'->Removendo plick do nome para previnir erro de sql
nameUser = Replace(nameInTable(session("User")),"'","")


' ######################### BLOQUEIO FINANCEIRO ########################################
UnidadeID =  replace(session("UnidadeID"),"'","")
contabloqueadacred = verificaBloqueioConta(2, 1, treatvalzero(ref("ContaCorrenteID")), UnidadeID,date())
if contabloqueadacred = "1" or contabloqueadadebt = "1" then
    retorno  = 	"new PNotify({ "&_
                "		title: 'Meu Caixa', "&_
                "		text: 'Esta conta está BLOQUEADA e não pode ser alterada!', "&_
                "		type: 'danger' "&_
                "	});" &_
                " $('#modalCaixa').modal('hide');"
    response.write(retorno)
    response.end
end if
' #####################################################################################

if ref("Acao")="Abrir" then
	Descricao = "Caixa de "&nameUser&" em "&date()&" (Aberto)"
	SaldoInicial = ref("SaldoInicial")
	if SaldoInicial="" or not isnumeric(SaldoInicial) then
		SaldoInicial = 0
	else
		SaldoInicial = ccur(SaldoInicial)
	end if
	
	db_execute("insert into caixa (sysUser, dtAbertura, SaldoInicial, ContaCorrenteID, Descricao) values ("&session("User")&", "&mydatetime(now())&", "&treatvalzero(SaldoInicial)&", "&ref("ContaCorrenteID")&", '"&Descricao&"')")

	set plast = db.execute("select id from caixa where sysUser="&session("User")&" and isnull(dtFechamento) order by id desc LIMIT 1")
	session("CaixaID") = plast("id")

	if SaldoInicial>0 then
		db_execute("insert into sys_financialmovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Rate, CaixaID, sysUser, UnidadeID) values ('Saldo para abertura de caixa', 1, "&treatvalzero(ref("ContaCorrenteID"))&", 7, "&plast("id")&", 1, "&treatvalzero(SaldoInicial)&", "&mydatenull(date())&", '', 'Transfer', 1, "&plast("id")&", "&session("User")&", "&session("UnidadeID")&")")
	end if

	%>

	gtag('event', 'caixa_aberto', {
		'event_category': 'caixa',
		'event_label': "Caixinhna > Abrir",
	});


    $("#badge-caixa").html("$");
    new PNotify({
        title: 'Meu Caixa',
        text: 'aberto com sucesso.',
        type: 'success'
    });

    var $mudaLocal = $(".menu-click-meu-perfil-muda-local");

    $.each($mudaLocal, function(){
        $(this).css("opacity", 0.4);

        var ahref = $(this).find("a");
        ahref.attr("onclick", ahref.attr("onclick2"))
        ahref.removeAttr("href")
    });
	<%
end if

if ref("Acao")="Fechar" then
	set caixa = db.execute("select *, date(dtAbertura) Abertura from caixa where id="&ref("idCaixa"))
	SaldoFinalFinal = ref("SaldoFinalFinal")
	Dinheiro = ref("Dinheiro")
	DataFechamento = mydatenull(date())

	if getConfig("NaoPermitirRecebimentoCaixaComDataAnterior") and caixa("Abertura")<>date() then
	    DataFechamento=mydatenull(caixa("Abertura"))
	end if

	if Dinheiro<>"" then
		db_execute("insert into sys_financialmovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Rate, CaixaID, sysUser, UnidadeID) values ('Fechamento Cx - Dinheiro', 7, "&caixa("id")&", 1, "&caixa("ContaCorrenteID")&", 1, "&treatvalzero(Dinheiro)&", "&DataFechamento&", '', 'Transfer', 1, "&caixa("id")&", "&session("User")&", "&session("UnidadeID")&")")
	end if

	'->verifca se existe algum cheque neste caixa, e passa para a tesouraria deste caixa
	set getCheques = db.execute("select * from sys_financialreceivedchecks where AccountAssociationID=7 and AccountID="&caixa("id"))
	while not getCheques.eof
		db_execute("insert into sys_financialmovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Rate, CaixaID, ChequeID, sysUser, UnidadeID) values ('Fechamento Cx - Cheque', 7, "&caixa("id")&", 1, "&caixa("ContaCorrenteID")&", 2, "&treatvalzero(getCheques("Valor"))&", "&mydatenull(getCheques("CheckDate"))&", '', 'Transfer', 1, "&caixa("id")&", "&getCheques("id")&", "&session("User")&", "&session("UnidadeID")&")")
		db_execute("update sys_financialreceivedchecks set AccountAssociationID=1, AccountID="&caixa("ContaCorrenteID")&" where id="&getCheques("id"))
	getCheques.movenext
	wend
	getCheques.close
	set getCheques=nothing
	'<-

	Descricao = "Caixa de "&nameUser&" ("&caixa("dtAbertura")&" a "&now()&")"
	db_execute("update caixa set dtFechamento="&mydatetime(now)&", SaldoFinal="&treatvalzero(SaldoFinalFinal)&", Descricao='"&Descricao&"' where id="&ref("idCaixa"))
	%>

		gtag('event', 'caixa_fechado', {
			'event_category': 'caixa',
			'event_label': "Caixinha > Fechar",
		});


        new PNotify({
            title: 'Meu Caixa',
            text: 'Fechado com sucesso.',
            type: 'success'
        });
    $("#badge-caixa").html("");
    var $mudaLocal = $(".menu-click-meu-perfil-muda-local");

    $.each($mudaLocal, function(){
        $(this).css("opacity", 1);
        var ahref = $(this).find("a");
        ahref.attr("href", ahref.attr("href2"))
        ahref.removeAttr("onclick")
    });
	<%
	session("CaixaID")=""
end if
%>

$("#modalCaixa").modal("hide");