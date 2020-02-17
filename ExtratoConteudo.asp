 <!--#include file="connect.asp"-->
<%
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
<div class="row">
  <div class="col-md-12">
	<table class="table table-striped table-bordered table-hover table-condensed">
	<thead>
		<tr class="success">
        	<th></th>
			<th>Data</th>
			<th>Conta</th>
			<th>Descri&ccedil;&atilde;o</th>
            <th nowrap>Lançado por</th>
            <th class="td-detalhada">Plano de Contas</th>
            <th class="td-detalhada">NF</th>
            <th class="td-detalhada">Recibo</th>
            <th class="td-detalhada">Cheque</th>
            <th class="td-detalhada">Obs.</th>
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
		sqlAcc = " AND ((m.AccountAssociationIDCredit="&AccountAssociationID&" and m.AccountIDCredit="&AccountID&") or (m.AccountAssociationIDDebit="&AccountAssociationID&" and m.AccountIDDebit="&AccountID&")) "
	else
		sqlAcc = " AND m.`Date`>="&mydatenull(session("DateFrom"))&" AND m.`Date`<="&mydatenull(session("DateTo"))&" AND m.`Type` IN('Pay') "
	end if
	if ref("LancadoPor")<>"" then
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
        sqlGM = "select m.*, lu.Nome FROM sys_financialmovement m LEFT JOIN cliniccentral.licencasusuarios lu on lu.id=m.sysUser where ((m.AccountAssociationIDCredit=7 and m.AccountIDCredit="&CaixaID&") or (m.AccountAssociationIDDebit=7 and m.AccountIDDebit="&CaixaID&") or m.CaixaID="& CaixaID &") and m.Type<>'Bill' order by m.Date, m.id"
    else
        sqlGM = "select m.*, lu.Nome from sys_financialMovement m LEFT JOIN cliniccentral.licencasusuarios lu on lu.id=m.sysUser where 1=1 "& sqlAcc & sqlLancadoPor & sqlUnidades & sqlCD & sqlFormas &" order by m.Date, m.id"
    end if
    set getMovement = db.execute( sqlGM )

	while not getMovement.eof
		Value = getMovement("Value")
		AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
		AccountIDCredit = getMovement("AccountIDCredit")
		AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
		AccountIDDebit = getMovement("AccountIDDebit")
		PaymentMethodID = getMovement("PaymentMethodID")
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
		accountReverse = left(accountReverse, 25)

		if getMovement("Date")<=session("DateTo") then
			SaldoAnteriorFim = Balance
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
        if ref("Tipo")<>"" then
            if ref("Tipo")<>CD then
                Omite = "S"
            else
                Omite = ""
            end if
        end if
		'-
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

			linhas = linhas+1

			'---> mostrar primeira linha de saldo
			if ExibiuPrimeiraLinha="N" and ScreenType="Statement" then
				%>
				<tr>
                	<th class="saldo-anterior-td" colspan="6">SALDO ANTERIOR</th>

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
			%>
			<tr>
				<td width="1%"><label><input id="checkbox1" class="ace ace-checkbox-2 bootbox-confirm" type="checkbox" value="<%=getMovement("id")%>" name="InstallmentsToPay" onclick="checkToPay()"><span class="lbl"> </span></label></td>
				<td width="8%" class="text-right"><%= getMovement("Date") %></td>
				<td><code><%= getMovement("id") %></code> <%=iconMethod(getMovement("PaymentMethodID"), CD)%>&nbsp;<%= accountReverse %></td>
				<td><%= linkBill %>
						<%=Descricao%>
						<%if len(getMovement("Name"))>0 and Descricao<>"" then%> - <%end if%><%=DescPagto%>
					<%= endlinkBill %><br /><%=getMovement("Obs")%>
                    </td>
                <td><%=getMovement("Nome")%></td>

                <td class="td-detalhada"><%=PlanoDeContas%></td>
                <td class="td-detalhada"><%=NFe%></td>
                <td class="td-detalhada"><%=Recibo%></td>
                <td class="td-detalhada"><%=Cheque%></td>
                <td class="td-detalhada"><%=Obs%></td>

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
				<td nowrap="nowrap">
					<div class="action-buttons">
						<%= linkBill %>
                        <%
						if linkBill<>"" then
							%>
							<i class="fa fa-edit green bigger-130"></i>
                            <%
						end if
						%>
						<%= endlinkBill %>

						<%
						if linkBill="" then
						%>
						<a style="float: right;" href="javascript:modalPaymentAttachments('<%=getMovement("id")%>');" title="Anexar um arquivo"> <i class="fa fa-paperclip bigger-140 white"></i></a>
						<%
						end if
						%>
						<a href="javascript:modalPaymentDetails('<%=getMovement("id")%>')">
							<i class="fa fa-search-plus bigger-130"></i>
						</a>
                        <%
						if (aut("|movementX") or (not isnull(getMovement("CaixaID")) and aut("|caixasusuX|"))) and (getMovement("Type")="Pay" or getMovement("Type")="Fee" or getMovement("Type")="Transfer" or getMovement("Type")="CCCred" or getMovement("Type")="CCDeb") then
						%>
						<a class="red" onclick="xMov(<%=getMovement("id") %>);" role="button" href="#">
							<i class="fa fa-trash bigger-130"></i>
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

<script type="text/javascript">

    <%
    if ref("DetalharRecebimentos")="S" then
    %>
    if(!menuEscondido){
        var menuEscondido = true;
        $("#toggle_sidemenu_l").click();
    }
    $(".saldo-anterior-td").attr("colspan", 11)

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


<!--#include file="jQueryFunctions.asp"-->
</script>