<!--#include file="connect.asp"-->
<%
splConta = split(ref("AccountID"), "_")
AssociacaoID = splConta(0)
ContaID = splConta(1)
InvoiceID = req("I")
FecharAutomatico = ref("FecharAutomatico")
EmitirNotaAntecipada = "'"&ref("EmitirNotaAntecipada")&"'"
DiasAntes = treatvalnull(ref("DiasAntes"))
PaymentMethodID = treatvalnull(ref("PaymentMethodID"))
Licenca = ref("Licenca")
TipoContaFixaID = ref("TipoContaFixaID")
ValorMinimoPorUsuario =  treatvalzero(ref("ValorMinimoPorUsuario"))


if session("Banco")="clinic100003" or session("Banco")="clinic5459" then
    sqlFecharAutomatico = ", FecharAutomatico='"&FecharAutomatico&"'"
end if

    sql = "update invoicesfixas set ValorMinimoPorUsuario=NULLIF("&ValorMinimoPorUsuario&",''), TipoContaFixaID="&TipoContaFixaID&", Licenca=NULLIF('"&Licenca&"',''),EmitirNotaAntecipada="&EmitirNotaAntecipada&",DiasAntes="&DiasAntes&",PaymentMethodID="&PaymentMethodID&", AccountID="&ContaID&sqlFecharAutomatico&", AssociationAccountID="&AssociacaoID&", PrimeiroVencto="&mydatenull(ref("PrimeiroVencto"))&", Value="&treatvalzero(ref("Valor"))&", Description='"&ref("Description")&"', CompanyUnitID="&treatvalzero(ref("CompanyUnitID"))&", Intervalo="&ref("Intervalo")&", TipoIntervalo='"&ref("TipoIntervalo")&"', sysActive=1, RepetirAte="& mydatenull(ref("RepetirAte")) &" where id="&InvoiceID

db_execute( sql )



if erro="" then

	splInv = split(ref("inputs"), ", ")
		
		'itens
		db_execute("delete from itensinvoicefixa where InvoiceID="&InvoiceID)
		
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
                Desconto  = desInv
                Acrescimo = acrInv
				sqlInsert = "insert into itensinvoicefixa ("&camID&" InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, CentroCustoID, ValorUnitario, Desconto, Descricao, Executado, DataExecucao, HoraExecucao, AgendamentoID, sysUser, ProfissionalID, HoraFim, Acrescimo, AtendimentoID, Associacao) values ("&valID&" "&InvoiceID&", '"&Tipo&"', "&quaInv&", "&treatvalzero(ref("CategoriaID"&ii))&", "&treatvalzero(ref("ItemID"&ii))&", "&treatvalzero(ref("CentroCustoID"&ii))&", "&treatvalzero(ref("ValorUnitario"&ii))&", "&treatvalzero(ref("Desconto"&ii))&", '"&ref("Descricao"&ii)&"', '"&ref("Executado"&ii)&"', "&mydatenull(ref("DataExecucao"&ii))&", "&mytime(ref("HoraExecucao"&ii))&", "&treatvalzero(ref("AgendamentoID"&ii))&", "&session("User")&", "&treatvalzero(ProfissionalID)&", "&mytime(ref("HoraFim"&ii))&", "&treatvalzero(ref("Acrescimo"&ii))&", "&treatvalnull(ref("AtendimentoID"&ii))&", "&Associacao&")"
			'response.Write("//"&ii&" - "&sqlInsert)
			db_execute(sqlInsert)
			'->itens do rateio irão aqui-----

			if Row<0 then
				set pult = db.execute("select id from itensinvoicefixa order by id desc limit 1")
				NewItemID = pult("id")
			else
				NewItemID = Row
			end if
            rows = rows & "|" & Row
            ids = ids & "|" & NewItemID

		next
		'<-




    splRows = split(rows, "|")
    splIds = split(ids, "|")



	%>
	new PNotify({
		title: 'Sucesso!',
		text: 'Conta recorrente salva.',
		type: 'success',
        delay: 3000
	});

    <%if session("Banco")="clinic100003" or session("Banco")="clinic5459" then %>
    	fetch(domain+"/billing/receitafixa/processar");
    <% end if %>

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
	new PNotify({
		title: 'ERRO!',
		text: '<%=erro%>',
		type: 'danger',
        delay: 3000
	});
	<%
end if

%>