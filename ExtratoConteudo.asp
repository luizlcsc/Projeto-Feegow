 <!--#include file="connect.asp"-->
<!--#include file="Classes/AccountBalance.asp"-->
<%
Response.Buffer

c=0
Total=0

DeleteMovementID = ref("DeleteMovementID")
if DeleteMovementID<>"" and isnumeric(DeleteMovementID) then
	set getDeleted = db.execute("select * from sys_financialMovement where id="&DeleteMovementID)
	if not getDeleted.EOF then
		'verificar se há outros movimentos com a mesma invoiceID, se nao houver, apagar a Invoice tb, se houver, update a invoice com valor - o valor deste movimento
		set searchOtherInvoiceMovements = db.execute("select * from sys_financialMovement where InvoiceID like '"&getDeleted("InvoiceID")&"' and id<>"&getDeleted("id"))
		if searchOtherInvoiceMovements.EOF then
			db_execute("delete from sys_financialInvoices where id = '"&getDeleted("InvoiceID")&"'")
			if not isnull(getDeleted("InvoiceID")) then
				set itensadeletar = db.execute("select * from itensinvoice where InvoiceID="&getDeleted("InvoiceID"))
				while not itensadeletar.eof
					db_execute("delete from rateiorateios where ItemInvoiceID="&itensadeletar("id"))
					db_execute("update rateiorateios set ItemContaAPagar=NULL where ItemContaAPagar="&itensadeletar("id"))
				itensadeletar.movenext
				wend
				itensadeletar.close
				set itensadeletar=nothing
				db_execute("delete from itensinvoice where InvoiceID='"&getDeleted("InvoiceID")&"'")
			end if
		else
			set getThisInvoice = db.execute("select * from sys_financialInvoices where id = '"&getDeleted("InvoiceID")&"'")
			db_execute("update sys_financialInvoices set value='"&treatval( ccur(getThisInvoice("Value"))-ccur(getDeleted("Value")) )&"' where id = '"&getDeleted("InvoiceID")&"'")
		end if
		'apagar os discounts de movementid e installmentid
		set movimentosAfetados = db.execute("select InstallmentID, MovementID from sys_financialDiscountPayments where InstallmentID="&DeleteMovementID&" or MovementID="&DeleteMovementID)
		while not movimentosAfetados.eof
			strAfetados = strAfetados&movimentosAfetados("InstallmentID")&";"&movimentosAfetados("MovementID")&";"
		movimentosAfetados.movenext
		wend
		movimentosAfetados.close
		set movimentosAfetados=nothing
		db_execute("delete from sys_financialDiscountPayments where InstallmentID="&DeleteMovementID&" or MovementID="&DeleteMovementID)
		'apagar o movimento
		db_execute("delete from sys_financialMovement where id="&DeleteMovementID)

		splAfetados = split(strAfetados, ";")
		for af=0 to ubound(splAfetados)
			if splAfetados(af)<>"" then
				call getValorPago(splAfetados(af), NULL)
			end if
		next
	end if
end if

ScreenType="Statement"


if ref("DateFrom")<>"" then
	session("DateFrom") = cdate( ref("DateFrom") )
end if
if ref("DateTo")<>"" then
	session("DateTo") = cdate( ref("DateTo") )
end if

if session("DateFrom")="" then
	session("DateFrom") = cdate("01/"&month(date())&"/"&year(date()))
	session("DateTo") = dateadd("m", 1,"01/"&month(date())&"/"&year(date()))
end if

DetalharRecebimento = False

if ref("DetalharRecebimentos")="S" then
    DetalharRecebimento=True
end if
%>
<br>
    <div style="display: flex; justify-content: flex-end; margin-right: 20px;">
        <label class="mr10" style="display: flex; justify-content: center; align-items: flex-end;"> Recebimento
            <input class="ml5" type="checkbox" name="recebimento" id="recebimento" value="D" onclick='filterPayment("D")' checked>
        </label>
        <label class="mr10" style="display: flex; justify-content: center; align-items: flex-end;"> Pagamento
            <input class="ml5" type="checkbox" name="pagamento" id="pagamento" onclick='filterPayment("C")' checked>
        </label>
    </div>
<div class="row">
  <div class="col-md-12">
	<table class="table table-striped table-bordered table-hover table-condensed">
	<thead>
		<tr class="success">
        	<th></th>
        	<th>#</th>
			<th>Data</th>
			<th>Conta</th>
			<th>Forma</th>
			<th>Descri&ccedil;&atilde;o</th>
            <th nowrap>Lançado por</th>
            <th class="td-detalhada">Plano de Contas</th>
            <th class="td-detalhada">NF</th>
            <th class="td-detalhada">Recibo</th>
            <th class="td-detalhada">Cheque</th>
            <th class="td-detalhada">Obs.</th>
            <th class="td-detalhada">Transação</th>
			<th>Valor</th>
			<% If ScreenType="Statement" Then %>
                <th>Saldo</th>
                <th>Total</th>
            <% Else %>
                <th>Pago</th>
            <% End If %>
			<th ></th>
		</tr>
	</thead>
    <%
	Balance = 0
    subBalance = 0
	linhas = 0
	ExibiuPrimeiraLinha = "N"
	SaldoAnteriorFim = 0


	if instr(ref("AccountID"), "_") then
		splAccount = split(ref("AccountID"), "_")
		AccountAssociationID = splAccount(0)
		AccountID = splAccount(1)

        DataSaldo = dateadd("d",-1,ref("DateFrom"))
        Balance = accountBalanceData(ref("AccountID"), DataSaldo) * -1

		sqlAcc = " AND ((m.AccountAssociationIDCredit="&AccountAssociationID&" and m.AccountIDCredit="&AccountID&") or (m.AccountAssociationIDDebit="&AccountAssociationID&" and m.AccountIDDebit="&AccountID&")) "
	else
		sqlAcc = "  AND m.`Type` IN('Pay','Tranfer') "
	end if

	sqlAcc = sqlAcc & " AND m.`Date`>="&mydatenull(session("DateFrom"))&" AND m.`Date`<="&mydatenull(session("DateTo"))&" "

	sqlLancadoPor = ""
	if ref("LancadoPor")&""<>"0" and ref("LancadoPor")&""<>"" then
		sqlLancadoPor = " AND m.sysUser="&treatvalzero(ref("LancadoPor"))&" "
	end if
	if ref("Unidades")<>"" then
		sqlUnidades = " AND (m.UnidadeID IN("&replace(ref("Unidades"), "|", "")&") OR isnull(m.UnidadeID))"
	end if
    if ref("Tipo")<>"" then
    '    sqlCD = " AND m.CD='"&ref("Tipo")&"' "
    end if
    if ref("Formas")<>"" then
        sqlFormas = " AND m.PaymentMethodID IN ("& replace(ref("Formas"), "|", "") &")"
    end if



    if req("T")="MeuCaixa" then
        CaixaID = session("CaixaID")

        if instr(ref("AccountID"), "_") then
            splAccount = split(ref("AccountID"), "_")
            AccountAssociationID = splAccount(0)
            CaixaID = splAccount(1)
        end if
        %>
        <input type="hidden" name="MeuCaixa" id="MeuCaixa" value="S" />
        <%

        sqlGM = "select m.*, lu.Nome, fb.BankName, pm.PaymentMethod FROM sys_financialmovement m "&_
        "LEFT JOIN cliniccentral.licencasusuarios lu on lu.id=m.sysUser "&_
        "left join sys_financialcurrentaccounts sf on sf.id = m.AccountIDDebit  "&_
        "left join sys_financialpaymentmethod pm on pm.id = m.PaymentMethodID  "&_
        "left join sys_financialbanks fb on fb.id = sf.Bank   "&_
        "where ((m.AccountAssociationIDCredit=7 and m.AccountIDCredit="&CaixaID&") or (m.AccountAssociationIDDebit=7 and m.AccountIDDebit="&CaixaID&") or m.CaixaID="& CaixaID &") and m.Type<>'Bill' order by m.Date, m.id"
    else
		if ref("AccountID")<>"" and ref("AccountID")<>"0" then
			sqlDataPraFrente = " AND m.`Date`>="& mydatenull(ref("DateFrom")) &" "
		end if
		sqlGM = "select m.*, lu.Nome, fb.BankName, pm.PaymentMethod from sys_financialMovement m  "&_
		"LEFT JOIN cliniccentral.licencasusuarios lu on lu.id=m.sysUser  "&_
		"left join sys_financialcurrentaccounts sf on sf.id = m.AccountIDDebit  "&_
        "left join sys_financialpaymentmethod pm on pm.id = m.PaymentMethodID  "&_
		"left join sys_financialbanks fb on fb.id = sf.Bank where 1=1 "& sqlAcc & sqlLancadoPor & sqlUnidades & sqlCD & sqlFormas & sqlDataPraFrente &" order by m.Date, m.id"
    end if

    set getMovement = db.execute( sqlGM )


	entradasDinheiro = 0 '1
	saidasDinheiro = 0 '1
	entradasCheque = 0 '2
	saidasCheque = 0 '2
	entradasTransferencia = 0 '3
	saidasTransferencia = 0 '3
	entradasBoleto = 0 '4
	saidasBoleto = 0 '4
	entradasCartaoCredito = 0 '8
	saidasCartaoCredito = 0 '8
	entradasCartaoDebito = 0 '9
	saidasCartaoDebito = 0 '9
	EntradasPix = 0 '15
	saidasPix = 0 '15

	while not getMovement.eof
		response.flush()
		Value = getMovement("Value")

        IF isnull(Value) or Value = "" THEN
            Value = 0
        END IF

		AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
		AccountIDCredit = getMovement("AccountIDCredit")
		AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
		AccountIDDebit = getMovement("AccountIDDebit")
		PaymentMethodID = getMovement("PaymentMethodID")

		'tratei as variáveis para não receber valor nulo (André Coutinho)
		if IsNull(AccountAssociationIDCredit) then
			AccountAssociationIDCredit = 0
		end if	

		if IsNull(AccountAssociationID) then
			AccountAssociationID = 0
		end if

		if IsNull(AccountIDCredit) then
			AccountIDCredit = 0
		end if

		if IsNull(AccountID) then
			AccountID = 0
		end if

		Rate = getMovement("Rate")
		Descricao = ""
		SaldoAnterior = Balance
		Paid = ""

		if instr(ref("AccountID"), "_") then
			if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
				CD = "C"
				displayCD = CD
				if AccountAssociationID = "1" then
					displayCD = "D"
				end if
				Balance = Balance+Value
				accountReverse = accountName(AccountAssociationIDDebit, AccountIDDebit)
			else
				CD = "D"
				displayCD = CD
				if AccountAssociationID = "1" then
					displayCD = "C"
				end if
				Balance = Balance-Value
				accountReverse = accountName(AccountAssociationIDCredit, AccountIDCredit)
			end if
		else
			CD = getMovement("CD")
			if CD="C" then
				displayCD = "D"
				Balance = Balance-Value
				accountReverse = accountName(AccountAssociationIDDebit, AccountIDDebit)
			else
				displayCD = "C"
				Balance = Balance+Value
				accountReverse = accountName(AccountAssociationIDCredit, AccountIDCredit)
			end if
		end if

		if ref("Tipo")<>"" then
            if ref("Tipo")<>CD then
                Omite = "S"
            else
                Omite = ""
            end if
        end if

		accountReverse = left(accountReverse, 25)

		if getMovement("Date")<=session("DateTo") then
			SaldoAnteriorFim = Balance
		end if
		totest =  ""
		if getMovement("Obs") <> "" then
			totest = replace(replace(getMovement("Obs"),"{C",""),"}","")&""
		end if

		if getMovement("CD") = "" and totest <> "" then
			Omite = "S"
		end if


		linkBill = ""
		endLinkBill = ""
		if (accountReverse="" and getMovement("Type")="Bill") or (ScreenType<>"" and getMovement("Type")="Bill") then
			'->if paid
				if getMovement("Type")="Bill" then
					if getMovement("CD")="D" then
						linkBill = "<a href=""?P=invoice&T="&getMovement("CD")&"&I="&getMovement("InvoiceID")&"&Pers=1"">"
					else
						linkBill = "<a href=""?P=invoice&T="&getMovement("CD")&"&I="&getMovement("InvoiceID")&"&Pers=1"">"
					end if
					endLinkBill = "</a>"
				else
					linkBill = ""
					endLinkBill = ""
				end if
				if getMovement("CD")="C" then
					accountReverse = linkBill&"<span class=""badge"">Receita</span>"&endLinkBill
				else
					accountReverse = linkBill&"<span class=""badge"">Despesa</span>"&endLinkBill
				end if
				totalPago = getValorPago(getMovement("id"), getMovement("ValorPago"))
''

				if getMovement("Value")>totalPago then
					Paid = ""
				else
					if getMovement("Type")="Bill" then
						Paid = "<img src=""assets/img/checked.png"" width=""18"" height=""18"">"
					else
						Paid = ""
					end if
				end if
				if ref("Pagto")="Q" and Paid="" then
					Omite = "S"
				elseif ref("Pagto")="N" and Paid<>"" then
					Omite = "S"
				else
					Omite = ""
				end if
''
			'<-if paid
		end if

		cType = getMovement("Type")

		if (screenType="Statement" or CD=ref("AccountID")) and getMovement("Date")>=session("DateFrom") and getMovement("Date")<=session("DateTo") then
			if not isnull(getMovement("InvoiceID")) then
				cItens = 0
				Descricao = ""

				set itens = db.execute("select * from itensinvoice where InvoiceID="&getMovement("InvoiceID"))
				while not itens.eof
					if itens("Tipo")="S" then
						set proc = db.execute("select id, NomeProcedimento from procedimentos where id="&itens("ItemID"))
						if not proc.eof then
							Descricao = Descricao & ", " & left(proc("NomeProcedimento"), 23)
						end if
			        elseif itens("Tipo")="M" then
				        set proc = db.execute("select id, NomeProduto from produtos where id="&itens("ItemID"))
				        if not proc.eof then
					        Descricao = Descricao & ", " & left(proc("NomeProduto"), 23)
				        end if
					elseif itens("Tipo")="O" then
						Descricao = Descricao & ", " & left(itens("Descricao"), 23)
					end if
					if itens("Quantidade")>1 then
						Descricao = Descricao &" ("&itens("Quantidade")&")"
					end if
					cItens = cItens+1
				itens.movenext
				wend
				itens.close
				set itens=nothing
		'		if cItens>1 then
		'			Descricao = cItens&" itens"
		'		end if
				if len(Descricao)>1 then
					Descricao = right(Descricao, len(Descricao)-2)
				end if
			end if

            Obs=""
            NFe=""
            Cheque=""
            PlanoDeContas=""
            Recibo=""
            DataCompensacao=""

            if DetalharRecebimento then
                InvID = getMovement("InvoiceID")

                if isnull(InvID) then
                    set MovPayInvoiceSQL = db.execute("SELECT mov.InvoiceID FROM sys_financialmovement mov INNER JOIN sys_financialdiscountpayments disc On disc.InstallmentID=mov.id WHERE disc.MovementID="&getMovement("id"))
                    if not MovPayInvoiceSQL.eof then
                        InvID=MovPayInvoiceSQL("InvoiceID")
                    end if
                end if

                if getMovement("PaymentMethodID")=2 then
                    if getMovement("CD")="C" then
                        TabelaCheque = "sys_financialissuedchecks"
                    elseif getMovement("CD")="D" then
                        TabelaCheque = "sys_financialreceivedchecks"
                    end if

					if tabelaCheque <> "" then
						set ChequeSQL = db.execute("SELECT CheckNumber FROM "&tabelaCheque&" where MovementID="&getMovement("id"))

						if not ChequeSQL.eof then
							Cheque=ChequeSQL("CheckNumber")
						end if
					end if
                end if

                if not isnull(InvID) then
                    set InvoiceSQL = db.execute("select i.Description, IFNULL((SELECT numeronfse FROM nfe_notasemitidas where InvoiceID=i.id AND situacao=1 order by id desc limit 1), i.nroNFe)NF from sys_financialinvoices i where i.id="&InvID)

                    if not InvoiceSQL.eof then
                        Obs=InvoiceSQL("Description")
                        NFe=InvoiceSQL("NF")
                        'Cheque=""
                        PlanoDeContas=""
                        DataCompensacao=""
                    end if

                    set ReciboSQL = db.execute("SELECT NumeroSequencial FROM recibos WHERE InvoiceID="&InvID)
                    if not ReciboSQL.eof then
                        Recibo = ReciboSQL("NumeroSequencial")
                    end if

                    if getMovement("CD")="C" then
                        TabelaCategoria = "sys_financialexpensetype"
                    elseif getMovement("CD")="D" then
                        TabelaCategoria = "sys_financialincometype"
                    end if

                    set PlanoContasSQL = db.execute("SELECT concat(IFNULL(IFNULL(pg.NomeGrupo, cat.Name),''))Categorias FROM itensinvoice ii  LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN procedimentosgrupos pg ON pg.id=proc.GrupoID  LEFT JOIN "&TabelaCategoria&" cat ON cat.id=ii.CategoriaID WHERE ii.InvoiceID="&InvID)
                    if not PlanoContasSQL.eof then
                        PlanoDeContas = PlanoContasSQL("Categorias")
                    end if
                end if

            end if

            TransactionNumber=""
            if DetalharRecebimento then
                set TransactionSQL = db.execute("SELECT TransactionNumber,Parcelas FROM sys_financialcreditcardtransaction WHERE MovementID="&treatvalzero(getMovement("id")))
                if not TransactionSQL.eof then
                    TransactionNumber=TransactionSQL("TransactionNumber")
                end if
            end if

			linhas = linhas+1

			'---> mostrar primeira linha de saldo
			if ExibiuPrimeiraLinha="N" and ScreenType="Statement" then
				%>
				<tr>
                	<th class="saldo-anterior-td" colspan="8">SALDO ANTERIOR</th>

					<% 
					If (AccountAssociationID=1 or AccountAssociationID=7) and ScreenType="Statement" Then 
						varSaldoAnterior= formatnumber(SaldoAnterior*(-1),2) 
					Else 
						varSaldoAnterior= formatnumber(SaldoAnterior,2) 
					End If 
					%>
                    <th class="text-right column-number" data-value="<%=varSaldoAnterior%>" data-formated-value="<%=varSaldoAnterior%>" > <%=varSaldoAnterior%></th>
                    <th class="text-right">0,00</th>
                    <td></td>
                </tr>
				<%
				ExibiuPrimeiraLinha = "S"
			end if
			'<--- mostrar primeira linha de saldo
			if Omite="" then
				c=c+1
				Total = Total+getMovement("Value")

				if getMovement("Type")="Pay" and getMovement("CD")="D" then
					DescPagto = "Recebimento"
				else
					DescPagto = left(getMovement("Name"),30)
				end if
                '> subBalance
		        if instr(ref("AccountID"), "_") then
			        if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
				        CD = "C"
				        displayCD = CD
				        if AccountAssociationID = "1" then
					        displayCD = "D"
				        end if
				        subBalance = subBalance+Value
				        accountReverse = accountName(AccountAssociationIDDebit, AccountIDDebit)
			        else
				        CD = "D"
				        displayCD = CD
				        if AccountAssociationID = "1" then
					        displayCD = "C"
				        end if
				        subBalance = subBalance-Value
				        accountReverse = accountName(AccountAssociationIDCredit, AccountIDCredit)
			        end if
		        else
			        CD = getMovement("CD")
			        if CD="C" then
				        displayCD = "D"
				        subBalance = subBalance-Value
				        accountReverse = accountName(AccountAssociationIDDebit, AccountIDDebit)
			        else
				        displayCD = "C"
				        subBalance = subBalance+Value
				        accountReverse = accountName(AccountAssociationIDCredit, AccountIDCredit)
			        end if
		        end if
                '<subBalance
                if getMovement("Type")="Transfer" and instr(DescPagto, "repasse invertido") then
                    DescPagto = "<a href='javascript:eri("& getMovement("id") &")'>"& DescPagto &"</a>"
                end if

				if getMovement("CD") = "D" then
					tipoMov = "D"
				else
					tipoMov = "C"
				end if

					controle = displayCD
				if req("T") = "MeuCaixa" then
					if displayCD = "C" then
						controle = "D"
					elseif displayCD = "D" then
						controle ="C"
					end if
				end if

				Select Case PaymentMethodID
				case 1
					if controle="C" then
						entradasDinheiro = entradasDinheiro+Value
					else
						saidasDinheiro = saidasDinheiro+Value
					end if
				case 2
					if controle="C" then
						entradasCheque = entradasCheque+Value
					else
						saidasCheque = saidasCheque+Value
					end if
				case 3,7,5,6
					if controle="C" then
						entradasTransferencia = entradasTransferencia+Value
					else
						saidasTransferencia = saidasTransferencia+Value
					end if
				case 4
					if controle="C" then
						entradasBoleto = entradasBoleto+Value
					else
						saidasBoleto = saidasBoleto+Value
					end if
				case 8 ,10
					if controle="C" then
						entradasCartaoCredito = entradasCartaoCredito +Value
					else
						saidasCartaoCredito = saidasCartaoCredito +Value
					end if
				case 9
					if controle="C" then
						entradasCartaoDebito = entradasCartaoDebito +Value
					else
						saidasCartaoDebito = saidasCartaoDebito +Value
					end if
				case 15
					if controle="C" then
						entradasPix = entradasPix +Value
					else
						saidasPix = saidasPix +Value
					end if
				End Select
				controle = ""
			%>
			<tr data-tipo="<%=tipoMov%>">
				<td width="1%"><label><input id="checkbox1" class="ace ace-checkbox-2 bootbox-confirm" type="checkbox" value="<%=getMovement("id")%>" name="InstallmentsToPay" onclick="checkToPay()"><span class="lbl"> </span></label></td>
				<td width="2%" class="text-right"><code><%= getMovement("id") %></code></td>
				<td width="8%" class="text-right"><%= getMovement("Date") %></td>
				<%
					origem = getMovement("BankName")&""
				%>
				<td><%= accountReverse %></td>
                <td width="6%" ><%=iconMethod(getMovement("PaymentMethodID"),getMovement("PaymentMethod"), CD, origem)%></td>
				<td><%= linkBill %>
						<%=Descricao%>
						<%if len(getMovement("Name"))>0 and Descricao<>"" then%> - <%end if%><%=DescPagto%>
					<%= endlinkBill %><br /><%=getMovement("Obs")%>
                    </td>
                <td><small><%=getMovement("Nome")%></small></td>

                <td class="td-detalhada"><%=PlanoDeContas%></td>
                <td class="td-detalhada"><%=NFe%></td>
                <td class="td-detalhada"><%=Recibo%></td>
                <td class="td-detalhada"><%=Cheque%></td>
                <td class="td-detalhada"><%=Obs%></td>
                <td class="td-detalhada"><%=TransactionNumber%></td>

				<td class="text-right column-number" data-value="<%= formatnumber(Value,2) %>" data-formated-value="<%= formatnumber(Value,2) %>&nbsp;<%=displayCD%>" > <%= Paid %>&nbsp;<%= formatnumber(Value,2) %>&nbsp;<%=displayCD%></td>
				<%
				If ScreenType="Statement" Then
					
					If (AccountAssociationID=1 or AccountAssociationID=7) and Balance<>0 Then
						varSaldo= formatnumber(Balance*(-1),2)
						Else
						varSaldo= formatnumber(Balance,2)
						End If
					%>
					
                    <td class="text-right column-number" data-value="<%=varSaldo%>" data-formated-value="<%=varSaldo%>" > <%=varSaldo%> </td>
                    
					<% If (AccountAssociationID=1 or AccountAssociationID=7) and subBalance<>0 Then 
						varTotal = formatnumber(subBalance*(-1),2) 
					Else 
						varTotal = formatnumber(subBalance,2) 
					End If 
					%>
					<td class="text-right column-number" data-value="<%=varTotal%>" data-formated-value="<%=varTotal%>" > <%=varTotal%></td>
                <%
				Else
				%>
                    <td class="text-right column-number" data-value="<%= formatnumber(Value,2) %>" data-formated-value="<%= formatnumber(Value,2) %>"><%= formatnumber(totalPago,2) %></td>
                <%
				End If %>
				<td width="4%">
					<div class="action-buttons">
						<%= linkBill %>
                        <%
						if linkBill<>"" then
							%>
							<i class="far fa-edit green bigger-130"></i>
                            <%
						end if
						%>
						<%= endlinkBill %>

						<%
						if linkBill="" then
						%>
						<a style="float: right;" href="javascript:modalPaymentAttachments('<%=getMovement("id")%>');" title="Anexar um arquivo"> <i class="far fa-paperclip bigger-140 white"></i></a>
						<%
						end if
						%>
						<a href="javascript:modalPaymentDetails('<%=getMovement("id")%>')">
							<i class="far fa-search-plus bigger-130"></i>
						</a>
                        <%
						if (aut("|movementX") or (not isnull(getMovement("CaixaID")) and aut("|caixasusuX|"))) and (getMovement("Type")="Pay" or getMovement("Type")="Fee" or getMovement("Type")="Transfer" or getMovement("Type")="CCCred" or getMovement("Type")="CCDeb") then
						%>
						<a class="red" onclick="xMov(<%=getMovement("id") %>, 'extrato');" role="button" href="#">
							<i class="far fa-trash bigger-130"></i>
						</a>
                        <%
						end if
						%>
					</div>
				</td>
			</tr>
			<%
			end if
		end if
	getMovement.movenext
	Omite=""
	wend
	getMovement.close
	set getMovement = nothing

			'---> mostrar primeira linha de saldo
			if ExibiuPrimeiraLinha="N" and ScreenType="Statement" then

				%>
				<tr>
                	<th colspan="6">SALDO ANTERIOR</th>
                	<th class="td-detalhada"></th>
                    <th class="td-detalhada"></th>
                    <th class="td-detalhada"></th>
                    <th class="td-detalhada"></th>
                    <th class="td-detalhada"></th>
                    <th class="text-right"><%= formatnumber(SaldoAnteriorFim,2) %></th>
                    <th class="text-right">0,00</th>
                    <th></th>
                </tr>
				<%
				ExibiuPrimeiraLinha = "S"
			end if
			'<--- mostrar primeira linha de saldo
			if ScreenType<>"Statement" then
				%>
                <tfoot>
				<tr>
                	<th colspan="4"><%=c%> registros</th>
                    <th class="text-right"><%=formatnumber(Total, 2)%></th>
                </tr>
                </tfoot>
				<%
			end if
	%>
	</table>
<%
if linhas=0 then
	%>
	<div class="col-md-12 text-center">N&atilde;o h&aacute; lan&ccedil;amentos para o per&iacute;odo consultado.</div>
	<%
else
    if c>1 then
        s = "s"
    end if
    %>
    <div class="col-md-12 text-left"><%=c %> registro<%=s %> encontrado<%=s %>.</div>
    <%
end if
%>
  </div>
</div>

<div class='dFlex mt20 '>
	<table class='tableTotal table col-md-6 table-striped table-bordered table-hover table-condensed'>
		<tr class="success">
			<th colspan='3'> Total de Entradas</th>
		</tr>
		<tr>
			<td>Dinheiro <img width="18" src="assets/img/1C.png"> R$ <%=formatnumber(entradasDinheiro,2)%></td>
			<td>Cartão de Débito <img width="18" src="assets/img/9D.png"> R$ <%=formatnumber(entradasCartaoDebito,2)%></td>
			<td>Cartão de Crédito <img width="18" src="assets/img/8D.png"> R$ <%=formatnumber(entradasCartaoCredito,2)%></td>
		</tr>
		<tr>
			<td>Transferência <img width="18" src="assets/img/6C.png"> R$ <%=formatnumber(entradasTransferencia,2)%></td>
			<td>Cheque <img width="18" src="assets/img/2D.png"> R$ <%=formatnumber(entradasCheque,2)%></td>
			<td>Boleto <img width="18" src="assets/img/4D.png"> R$ <%=formatnumber(entradasBoleto,2)%></td>
		</tr>
		<tr>
			<td>Pix <img width="18" src="assets/img/pix.png"> R$ <%=formatnumber(entradasPix,2)%></td>
		</tr>
		<tr>
		<%
			entradas = entradasBoleto + entradasPix + entradasCartaoCredito + entradasCartaoDebito + entradasCheque + entradasDinheiro + entradasDOC + entradasTED + entradasTransferencia
		%>
		<td colspan='3'>Total: R$<%= formatnumber(entradas,2)%></td>
		</tr>

	</table>
	<table class='tableTotal table col-md-6 table-striped table-bordered table-hover table-condensed'>
		<tr class="danger">
			<th colspan='3'> Total de saidas</th>
		</tr>
		<tr>
			<td>Dinheiro <img width="18" src="assets/img/1C.png"> R$ <%=formatnumber(saidasDinheiro,2)%></td>
			<td>Cartão de Débito <img width="18" src="assets/img/9D.png"> R$ <%=formatnumber(saidasCartaoDebito,2)%></td>
			<td>Cartão de Crédito <img width="18" src="assets/img/8D.png"> R$ <%=formatnumber(saidasCartaoCredito,2)%></td>
		</tr>
		<tr>
			<td>Transferência <img width="18" src="assets/img/6D.png"> R$ <%=formatnumber(saidasTransferencia,2)%></td>
			<td>Cheque <img width="18" src="assets/img/2D.png"> R$ <%=formatnumber(saidasCheque,2)%></td>
			<td>Boleto <img width="18" src="assets/img/4D.png"> R$ <%=formatnumber(saidasBoleto,2)%></td>
		</tr>
		<tr>
			<td>Pix <img width="18" src="assets/img/6D.png"> R$ <%=formatnumber(saidasPix,2)%></td>
		</tr>
		<tr>
		<%
			saidas = saidasBoleto + saidasPix + saidasCartaoCredito + saidasCartaoDebito + saidasCheque + saidasDinheiro + saidasDOC + saidasTED + saidasTransferencia
		%>
		<td colspan='3'>Total: R$ <%= formatnumber(saidas,2)%></td>
		</tr>

	</table>
</div>

<style>
    .dFlex{
        display:flex;
		justify-content: space-between;
    }
	.dFlex div {
    	font-weight: bold;
	}
	.tableTotal{
		width:48%!important;
	}
	.tableTotal th[colspan], .tableTotal td[colspan]{
    	text-align: center;
    	font-weight: bold;
	}
</style>
<script type="text/javascript">

    <%
    if ref("DetalharRecebimentos")="S" then
    %>
    if(!menuEscondido){
        var menuEscondido = true;
        $("#toggle_sidemenu_l").click();
    }
    $(".saldo-anterior-td").attr("colspan", 14)

    <%
    else
    %>
    $(".td-detalhada").css("display", "none")
    <%
    end if
    %>

    function eri(i) {
        $.get("repassesCredito.asp?I=" + i, function (data) {
            $("#modal").html(data);
            $("#modal-table").modal("show");
        });
    }

	function filterPayment(type){
		let atual = $($('tr[data-tipo="'+type+'"]')[0]).css('display')
		// $('tr[data-tipo]').show()
		// console.log(type)

		if( atual == "none"){
			// console.log('mostra')
			$('tr[data-tipo="'+type+'"]').show()
		}else{
			// console.log('some')
			$('tr[data-tipo="'+type+'"]').hide()
		}
	}
<!--#include file="jQueryFunctions.asp"-->
</script>
