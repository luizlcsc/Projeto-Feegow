<!--#include file="connect.asp"-->
<%
deleteID = ref("deleteID")
movementID = ref("movementID")
if deleteID<>"" and isnumeric(deleteID) then
	db_execute("delete from sys_financialDiscountPayments where id="&deleteID)
'	db_execute("delete from itensdescontados where PagamentoID="&movementID)
'	db.execute
	call getValorPago(MovementID, NULL)
	%>
	<script>
		geraParcelas('N');
	</script>
	<%
end if

set getMovement = db.execute("select * from sys_financialMovement where id="&movementID)
if not getMovement.EOF then
	mValue = getMovement("Value")
	mCurrency = getMovement("Currency")
	mName = getMovement("Name")
	CD = getMovement("CD")'getCD(getMovement("AccountAssociationIDCredit")&"_"&getMovement("AccountIDCredit"), getMovement("AccountAssociationIDDebit")&"_"&getMovement("AccountIDDebit"))
	if CD="C" then
		CDInv = "D"
	else
		CDInv = "C"
	end if
	mType = getMovement("Type")
	mDate = getMovement("Date")
	mInvoiceId = getMovement("InvoiceID")
	por = nameInTable(getMovement("sysUser"))
	if not isnull(por) and por<>"" then
		por = " por "&por
	end if
	
	select case CD&mType
		case "CBill"
			Title = "Contas a Receber <small>&raquo; "&mName&"</small>"
			BodyType = "Bill"
		case "DBill"
			Title = "Contas a Pagar <small>&raquo; "&mName&"</small>"
			BodyType = "Bill"
		case "CPay"
			Title = "Pagamento"
			BodyType = "Pay"
		case "DPay"
			Title = "Recebimento"
			BodyType = "Pay"
		case "Transfer"
			Title = mName
			BodyType = "Bill"
	end select

	EhRepasse = Fale

    if isnull(mInvoiceId) then
        set getPaymentDiscounts = db.execute("select InstallmentID from sys_financialdiscountpayments where MovementID="&movementID)
            if not getPaymentDiscounts.EOF then
                set getInstallmentPaid = db.execute("select InvoiceID from sys_financialMovement where id="&getPaymentDiscounts("InstallmentID"))
                if not getInstallmentPaid.EOF then
                    mInvoiceId = getInstallmentPaid("InvoiceID")
                end if
            end if
    end if

	set ItemInvoiceRepasseSQL = db.execute("SELECT rr.id FROM itensinvoice ii INNER JOIN rateiorateios rr ON rr.ItemContaAPagar=ii.id WHERE ii.InvoiceID="&treatvalzero(mInvoiceId))

    AutRepasse= False

	if not ItemInvoiceRepasseSQL.eof then
	    EhRepasse=True

	    if getMovement("CD")="C" and aut("|contaapagarrepasseX|")=1 then
            AutRepasse=True
	    end if
	end if

	%>
	
	<div class="modal-header">
	    <button type="button" onclick="$('.parcela').prop('checked', false); $('#pagar').fadeOut();" class="close" data-dismiss="modal">×</button>
		<h4 class="modal-title"><%= Title %> <%=por%></h4>
        <%
		if not isnull(getMovement("ChequeID")) then
		    if CD="C" then
                set cheque = db.execute("select c.*, lu.Nome NomeUsuario, mov.sysDate, ca.AccountName, b.BankName from sys_financialissuedchecks c "&_
                 " LEFT JOIN sys_financialcurrentaccounts ca ON ca.id=c.AccountID "&_
                 " LEFT JOIN sys_financialbanks b ON b.id=ca.Bank "&_
                 " INNER JOIN sys_financialmovement mov ON mov.id=c.MovementID "&_
                 " LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=mov.sysUser where c.id="&getMovement("ChequeID"))
                if not cheque.eof then
                %>
                <strong>Conta: </strong> <%=cheque("AccountName")%><br>
                <strong>Banco: </strong> <%=cheque("BankName")%><br>
                <strong>Número:</strong> <%=cheque("CheckNumber")%> <br>
                <strong>Data do cheque: </strong><%=cheque("CheckDate")%> <br>
                <strong>Usuário: </strong> <%=cheque("NomeUsuario")%><br>
                <strong>Data do pagamento: </strong><%=cheque("sysDate")%> <br>

                <%
                end if
            else

                set cheque = db.execute("select * from sys_financialreceivedchecks where id="& getMovement("ChequeID"))
                if not cheque.eof then
                    %>
                    <h5>Detalhes do Cheque</h5>
                    <div class="row">
                        <%=quickfield("simpleSelect", "BankID", "Banco", 4, cheque("BankID"), "select id, concat(BankNumber, ' - ', BankName) Banco from sys_financialbanks", "Banco", " disabled ")%>
                        <%=quickfield("text", "Branch", "N&deg; da Agência", 2, cheque("Branch"), "", "", " disabled ")%>
                        <%=quickfield("text", "Account", "N&deg; da Conta", 2, cheque("Account"), "", "", " disabled ")%>
                        <%=quickfield("text", "CheckNumber", "N&deg; do Cheque", 2, cheque("CheckNumber"), "", "", " disabled ")%>
                        <%=quickfield("datepicker", "CheckDate", "Data do Cheque", 2, cheque("CheckDate"), "", "", " disabled ")%>
                    </div>
                    <div class="row">
                        <%=quickfield("text", "Holder", "Emitente", 6, cheque("Holder"), "", "", " disabled ")%>
                        <%=quickfield("text", "Document", "CPF / CNPJ", 3, cheque("Document"), " input-mask-cpf", "", " disabled ")%>
                        <%=quickfield("text", "BorderoID", "N&deg; do Border&ocirc;", 3, cheque("BorderoID"), "", "", " disabled ")%>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <label for="ContaCorrente">Localiza&ccedil;&atilde;o</label><br>
                            <%=simpleSelectCurrentAccounts("ContaCorrente", "1, 7, 2, 4, 5, 6, 3", cheque("AccountAssociationID")&"_"&cheque("AccountID"), " disabled ","")%>
                        </div>
                        <%=quickfield("simpleSelect", "StatusID", "Status", 3, cheque("StatusID"), "select * from cliniccentral.chequestatus", "Descricao", " disabled ")%>
                    </div>
                    <%
                end if
            end if
		end if
		%>
	</div>
	<div class="modal-body">
    <div class="well well-sm">
		<strong><%= mDate %> &raquo; R$&nbsp;<%=formatNumber(mValue,2)%></strong>
        <%
        IF mType="CCCred" THEN
            set DadosCartao = db.execute("SELECT pac.NomePaciente, fcct.TransactionNumber, fcct.AuthorizationNumber, band.Bandeira, reci.NumeroSequencial, mov.Date, IFNULL(nfe.numeronfse, fi.nroNFE) NumeroNFe, IF(reci.UnidadeID = 0, (SELECT Sigla from empresa where id=1), (SELECT Sigla from sys_financialcompanyunits where id = reci.UnidadeID)) SiglaUnidade "&_
                                         "FROM sys_financialcreditcardreceiptinstallments fcci "&_
                                         "INNER JOIN sys_financialcreditcardtransaction fcct ON fcct.id=fcci.TransactionID "&_
                                         "INNER JOIN sys_financialmovement mov ON mov.id=fcct.MovementID "&_
                                         "LEFT JOIN cliniccentral.bandeiras_cartao band ON band.id=fcct.BandeiraCartaoID "&_
                                         "LEFT JOIN pacientes pac ON pac.id=mov.AccountIDCredit AND mov.AccountAssociationIDCredit = 3 "&_
                                         "LEFT JOIN sys_financialdiscountpayments dispay on dispay.MovementID=mov.id "&_
                                         "LEFT JOIN sys_financialmovement movrec on movrec.id=dispay.InstallmentID "&_
                                         "LEFT JOIN recibos reci ON reci.InvoiceID=movrec.InvoiceID AND reci.sysActive=1 "&_
                                         "LEFT JOIN nfe_notasemitidas nfe ON nfe.InvoiceID=movrec.InvoiceID AND nfe.situacao=1 "&_
                                         "LEFT JOIN sys_financialinvoices fi ON fi.id=movrec.InvoiceID "&_
                                         "WHERE fcci.InvoiceReceiptID="&movementID)
            IF NOT DadosCartao.EOF THEN
            %>
            <h5>Dados do cartão</h5>
            <table class="table table-striped table-hover">
                <tr>
                    <th>Conta</th>
                    <th>Autorização</th>
                    <th>Transação</th>
                    <th>Bandeira</th>
                    <th>Pagamento</th>
                    <th>NFe</th>
                    <th>Recibo</th>
                </tr>
                <tr>
                    <td><%=DadosCartao("NomePaciente")%></td>
                    <td><%=DadosCartao("AuthorizationNumber")%></td>
                    <td><%=DadosCartao("TransactionNumber")%></td>
                    <td><%=DadosCartao("Bandeira")%></td>
                    <td><%=DadosCartao("Date")%></td>
                    <td><%=DadosCartao("NumeroNFe")%></td>
                    <td><%=DadosCartao("SiglaUnidade")&DadosCartao("NumeroSequencial")%></td>
                </tr>
            </table>
            <%
            END IF
        END IF
        '(getMovement("CaixaID")=session("CaixaID") and aut("|aberturacaixinhaX|") and getMovement("Type")="Pay") or (aut("|contasareceberX|") and getMovement("CD")="D" and getMovement("Type")="Pay") or (aut("|areceberpacienteX|") and getMovement("CD")="D" and getMovement("AccountAssociationIDCredit")=3 and getMovement("Type")="Pay") or (aut("|contasapagarA|") and getMovement("CD")="C" and getMovement("Type")="Pay") or (aut("|lancamentosX|") and getMovement("Type")="Transfer")

        EhStone = False
         if getMovement("AccountAssociationIDDebit") = 1 then

             set currentAccount = db.execute("select * from sys_financialcurrentaccounts WHERE id ="&getMovement("AccountIDDebit"))
             if not currentAccount.eof then
                 if currentAccount("IntegracaoStone") = "S" then
                    EhStone=True
                end if
            end if
        end if

        desabilitarExclusao = ""
        titleNotaFiscal = ""

        if recursoAdicional(34) = 4 and desabilitarExclusaoPagamento = "" and getConfig("ExecutadosNFse") = 1 then
            set existeNotaEmitida = db.execute("select nfse.id from nfse_emitidas nfse inner join sys_financialmovement mov on nfse.InvoiceID = mov.InvoiceID where mov.id ="&movementID&" and Status = 3")
            if not existeNotaEmitida.eof then
                desabilitarExclusao = " disabled "
                titleNotaFiscal = "Existe nota com status autorizada"
            end if
        end if


        if not EhStone AND getMovement("Type")<>"Bill" AND getMovement("Obs")<>"{C}" and podeExcluir(getMovement("CaixaID"), getMovement("Type"), getMovement("CD"), getMovement("AccountAssociationIDCredit")) or AutRepasse then

            %>
            <span class="d-inline-block pull-right" tabindex="0" data-toggle="tooltip" title="<%=titleNotaFiscal%>">
                <button type="button" class="btn btn-xs btn-danger pull-right <%=desabilitarExclusao%> " onclick="xMov(<%=getMovement("id") %>)"><i class="far fa-ban"></i> Cancelar</button>
            </span>
            <%
        elseif EhStone then

            set microtefLogs = db.execute("SELECT * FROM microtef_logs WHERE InvoiceID ="&treatvalzero(mInvoiceId))
                if microtefLogs.eof then
                %>
                <span class="d-inline-block pull-right" tabindex="0" data-toggle="tooltip" title="<%=titleNotaFiscal%>">
                    <button type="button" class="btn btn-xs btn-danger pull-right <%=desabilitarExclusaoPagamento%>" onclick="xMov(<%=getMovement("id") %>)"><i class="far fa-trash"></i></button>
                </span>
                <%
                else
                %>
                        <span class="pull-right" style="color:red">Para excluir, realize o estorno da transação.</span>
                <%
                end if
        end if
        %>
    </div>
    <%
	if BodyType="Bill" then
		%>
		<h5>Pagamentos Realizados</h5>
	
		<table class="table table-striped table-hover">
		<%
		AlreadyDiscounted = 0
        set getPaymentMovement2 = db.execute("select * from sys_financialDiscountPayments where MovementID="&movementID)
		set getAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&movementID)

		if getAlreadyDiscounted.EOF and getPaymentMovement2.EOF then
			%>
			<tr><td colspan="2"><em>Nenhum pagamento realizado.</em></td></tr>
			<%
		end if
		while not getAlreadyDiscounted.EOF
			set getPaymentMovement = db.execute("select * from sys_financialMovement where id="&getAlreadyDiscounted("MovementID"))
			pDate = ""
			if not getPaymentMovement.EOF then
				pType = getPaymentMovement("Type")
				pPaymentMethod = getPaymentMovement("PaymentMethodID")
				pName = getPaymentMovement("Name")
				pValue = getPaymentMovement("Value")
				pCurrency = getPaymentMovement("Currency")
				pDate = getPaymentMovement("Date")
				ChequeID = getPaymentMovement("ChequeID")
			AlreadyDiscounted = AlreadyDiscounted+getAlreadyDiscounted("DiscountedValue")
			%><tr>
					<td>R$&nbsp;<%=formatnumber(getAlreadyDiscounted("DiscountedValue"),2)%></td>
					<td><%=getAlreadyDiscounted("Date")%></td>
					<td><code> <%=getAlreadyDiscounted("MovementID")%> </code>
					<% 
					select case pType
						case "Bill"
							response.Write("Descontados de "&pName&" ("&pCurrency&"&nbsp;"&formatnumber(pValue,2)&")")
						case "Pay"
							set getPaymentMethod = db.execute("select * from cliniccentral.sys_financialPaymentMethod where id="&pPaymentMethod)
							response.Write("<a href=""javascript:mpd("&getPaymentMovement("id")&");""><i class='far fa-search-plus'></i> </a> De pagamento via ")
							if ChequeID<>"" then
								abreLinkPM = "<a href=""javascript:dadosCheque("&ChequeID&", '"&getPaymentMovement("CD")&"');"">"
								fechaLinkPM = " <i class=""far fa-external-link""></i></a>"
							else
								abreLinkPM = ""
								fechaLinkPM = ""
							end if
                            if not getPaymentMethod.eof then
    							response.Write(abreLinkPM & getPaymentMethod("PaymentMethod") & fechaLinkPM)
    							if getPaymentMovement("CD")="C" then
                                    response.Write(" - "&accountName(getPaymentMovement("AccountAssociationIDCredit"),getPaymentMovement("AccountIDCredit")))
                                else
                                    response.Write(" - "&accountName(getPaymentMovement("AccountAssociationIDDebit"),getPaymentMovement("AccountIDDebit")))
                                end if
                            end if
							response.Write(" (R$&nbsp;"&formatnumber(pValue,2)&" - "&pDate&")")
						case "Transfer"
                            response.Write("<a href=""javascript:mpd("&getPaymentMovement("id")&");""><i class='far fa-search-plus'></i> </a> De pagamento via ")
							response.Write(getPaymentMovement("Name")&" (R$ "&fn(getPaymentMovement("Value"))&"{" & getPaymentMovement("id") & "})")
							response.write("</a>")
					end select
					 %>
					 </td>
					 <%
					 EhStone = False
					 if not isnull(getPaymentMovement("AccountAssociationIDDebit")) then
                         if getPaymentMovement("AccountAssociationIDDebit") = 1 then

                             set currentAccount = db.execute("select * from sys_financialcurrentaccounts WHERE id ="&getPaymentMovement("AccountIDDebit"))
                             if not currentAccount.eof then
                                 if currentAccount("IntegracaoStone") = "S" then
                                    EhStone=True
                                    MovementPaymentID = getPaymentMovement("id")
                                    set microtefLogs = db.execute("select * from microtef_logs WHERE MovementID ="&movementID)
                                    if not microtefLogs.eof then
                                 %>
                                 <td>
                                    <button onclick="tefSegundaVia(<%=microtefLogs("id")%>)" title="Comprovante TEF" class="btn btn-xs btn-success"><i class="far fa-file-text"></i></button>
                                 </td>
                                 <%
                                    end if
                                 end if
                             end if
                         end if
                     end if



                     if getPaymentMovement("CD")="D" then
                         set getRecibo = db.execute("SELECT r.NumeroSequencial, unit.Sigla FROM recibos r LEFT JOIN (SELECT 0 id, Sigla FROM empresa UNION ALL SELECT id, Sigla FROM sys_financialcompanyunits) unit ON unit.id=r.UnidadeID WHERE r.sysActive = 1 AND r.InvoiceId="&mInvoiceId&" ORDER BY r.id DESC LIMIT 1")
                         if not getRecibo.eof then
                         %>
                         <td>
                            Recibo: <%=getRecibo("Sigla")&""%> <%=getRecibo("NumeroSequencial")&""%>
                         </td>
                         <%
                         end if
                     end if
                     %>


                     <td width="1%">
                         <%
'                         if not EhStone and (getPaymentMovement("CaixaID")=session("CaixaID") and aut("|aberturacaixinhaX|")) or (aut("|contasareceberX|") and getPaymentMovement("CD")="D") or (aut("|areceberpacienteX|") and getPaymentMovement("CD")="D") or (aut("|contasapagarA|") and getPaymentMovement("CD")="C") or (aut("|lancamentosX|") and getPaymentMovement("Type")="Transfer") then
                            %>
                            ...<button type="button" class="btn btn-xs btn-danger hidden" onclick="modalPaymentDetails(<%=movementID%>, <%=getAlreadyDiscounted("id")%>)"><i class="far fa-trash"></i></button></td>
                            <%
 '                        end if
                         %>
			</tr><%
                end if
		getAlreadyDiscounted.movenext
		wend
		getAlreadyDiscounted.close
		set getAlreadyDiscounted = nothing

		PaymentMovement = 0
		while not getPaymentMovement2.EOF
			PaymentMovement = PaymentMovement+getPaymentMovement2("DiscountedValue")
				%><tr>
						<td>R$&nbsp;<%=formatnumber(getPaymentMovement2("DiscountedValue"),2)%></td>
						<td>
						<% 
						set getThisInstallment = db.execute("select * from sys_financialMovement where id="&getPaymentMovement2("InstallmentID"))
						if not getThisInstallment.EOF then
							%>Descontados de <%=getThisInstallment("Name")%> (<%=getThisInstallment("Currency")&"&nbsp;"&formatnumber(getThisInstallment("Value"),2)%>)<%
						end if
						 %>
						</td>
                        <td>
                            <button class="btn btn-warning btn-xs" onclick="DesvinclarItemCredito('<%=getPaymentMovement2("id")%>', '<%=getPaymentMovement2("MovementID")%>', '<%=getPaymentMovement2("InstallmentID")%>')" type="button" title="Desvincular item"><i class="far fa-unlink"></i></button>
                        </td>
				</tr><%
		getPaymentMovement2.movenext
		wend
		getPaymentMovement2.close
		set getPaymentMovement2 = nothing
	
		'to build the percentual paid... continuation
		discountedTotal = AlreadyDiscounted + PaymentMovement
		totaldiscountedTotal = totaldiscountedTotal + discountedTotal
		totalinstallmentValue = totalinstallmentValue + installmentValue
		%>
		</table>
        
	<%elseif BodyType="Pay" then%>
		<h5>Utilizados para Pagar</h5>
	
		<table class="table table-striped table-hover">
		<%
		set getPaymentDiscounts = db.execute("select * from sys_financialdiscountpayments where MovementID="&movementID)
		while not getPaymentDiscounts.EOF
				set getInstallmentPaid = db.execute("select * from sys_financialMovement where id="&getPaymentDiscounts("InstallmentID"))
				if not getInstallmentPaid.EOF then
                FormaPagamento = ""

                set FormaPagamentoSQL = db.execute("SELECT forma.PaymentMethod, forma.id FROM sys_financialmovement mov LEFT JOIN sys_financialpaymentmethod forma ON forma.id=mov.PaymentMethodID WHERE mov.id="&movementID)
                if not FormaPagamentoSQL.eof then
                    FormaPagamento = FormaPagamentoSQL("PaymentMethod")
                    select case FormaPagamentoSQL("id")
                        case 10,8,9
                            set DadosPagamentoCartaoSQL=db.execute("SELECT cartao.Parcelas,bandeira.Bandeira FROM sys_financialcreditcardtransaction cartao LEFT JOIN cliniccentral.bandeiras_cartao bandeira ON bandeira.id = cartao.BandeiraCartaoID WHERE cartao.MovementID="&movementID)
                            if not DadosPagamentoCartaoSQL.eof then
                                FormaPagamento=FormaPagamento&" ("&DadosPagamentoCartaoSQL("Parcelas")&"x) "&DadosPagamentoCartaoSQL("Bandeira")
                            end if
                    end select

                end if
					%>
					<tr>
						<td>R$ <%=formatnumber(getPaymentDiscounts("DiscountedValue"),2)%> - <%=FormaPagamento%></td>
						<td><%=getInstallmentPaid("Name")%></td>
						<td><%
						if not isnull(getInstallmentPaid("InvoiceID")) then
							set itens = db.execute("select * from itensinvoice WHERE InvoiceID="&getInstallmentPaid("InvoiceID")&"")
							while not itens.eof

								NomeItem = ""
								if itens("Tipo")="S" then
									set proc = db.execute("select NomeProcedimento from procedimentos where id="&itens("ItemID"))
									if not proc.EOF then
										NomeItem = proc("NomeProcedimento")
									end if
								else
									NomeItem = itens("Descricao")
								end if

								%>
								<a class="btn" href="./?P=invoice&T=<%=CDInv%>&I=<%=getInstallmentPaid("InvoiceID")%>&Pers=1"><%=NomeItem%></a>
								<%
							itens.movenext
							wend
							itens.close
							set itens = nothing
						end if
						%></td>
					</tr><%
				end if
		getPaymentDiscounts.movenext
		wend
		getPaymentDiscounts.close
		set getPaymentDiscounts=nothing
		%>
		</table>
        
	<% End If %>
	</div>
	
	<div class="modal-footer no-margin-top">
	</div>
	<%
end if
%>
<%if recursoAdicional(14)=4 then%>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<% end if %>
<script>

<%if session("Banco")="clinic7211" then%>
	const feegowPay = new FeegowPay('zoop', false, 'https://api.feegow.com.br/');
<%else%>
	const cappta = new FeegowCappta();
<%end if%>

function mpd(I){
	$.post('modalPaymentDetails.asp', {movementID:I}, function(data){ $("#pagar").html(data) });
}

function dadosCheque(I, TipoCheque){
	$.post("ChequeRecebido.asp?I="+I+"&TipoCheque="+TipoCheque, '', function(data,status){ $("#pagar").html(data) });
}

function DesvinclarItemCredito(DiscountID, MovementID, InstallmentID) {
    $.post("DesvinculaItemCredito.asp", {DiscountID: DiscountID, MovementID: MovementID, InvoiceID: "<%=mInvoiceID%>", InstallmentID: InstallmentID}, function(data) {
        eval(data);
    })
}

function tefSegundaVia (transactionId) {
	<%if session("Banco")="clinic7211" then%>
		feegowPay.printReceipt(transactionId, "customer");
	<%else%>
		cappta.printReceipt(transactionId, "customer");
	<%end if%>
}
</script>