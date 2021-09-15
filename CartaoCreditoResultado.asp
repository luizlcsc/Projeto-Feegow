<!--#include file="connect.asp"-->
<!--#include file="sqls/sqlUtils.asp"-->

        <%
		if ref("De")<>"" and ref("Ate")<>""  then
		%>
		<div class="row">
			<div class="col-md-12" style="overflow-y: auto;">
				<table class="table table-striped table-bordered table-condensed">
					<thead>
						<tr class="success">
                            <th width="1%"><input type="checkbox" class="chk" onclick="$('.chk').prop( 'checked', $(this).prop('checked') )" /></th>
							<th nowrap>Pagador</th>
							<th nowrap>Transação</th>
							<th nowrap>Autorização</th>
							<th nowrap align="center" width="10%">Data compra</th>
							<th>Recibo</th>
                            <th>NF</th>
							<th nowrap width="8%">Parcela</th>
							<th nowrap>Bandeira</th>
							<th nowrap width="10%">Valor compra</th>
							<th nowrap width="10%">Taxa %</th>
							<th nowrap width="10%">Valor créd.</th>
							<th nowrap width="200">Data créd.</th>
							<th nowrap width="1%">Status</th>
						</tr>
					</thead>
					<tbody>
					<%
					if ref("Baixados")="S" then
						sqlBaixados = " AND p.InvoiceReceiptID<>0 "
						sqlData = " AND movinstal.Date>="&mydatenull(ref("De"))&" AND movinstal.Date<="&mydatenull(ref("Ate"))
					end if

					if ref("Pendentes")="S" then
						sqlBaixados = " AND p.InvoiceReceiptID=0 "
						sqlData = " AND p.DateToReceive>="&mydatenull(ref("De"))&" AND p.DateToReceive<="&mydatenull(ref("Ate"))
					end if

					if ref("Baixados")="S" and ref("Pendentes")="S" then
						sqlBaixados = ""
						sqlData = " AND IF(InvoiceReceiptID<>0, movinstal.Date>="&mydatenull(ref("De"))&" AND movinstal.Date<="&mydatenull(ref("Ate"))&" AND InvoiceReceiptID<>0, p.DateToReceive>="&mydatenull(ref("De"))&" AND p.DateToReceive<="&mydatenull(ref("Ate"))&" AND InvoiceReceiptID=0) "
					end if

					if ref("dataBusca") = "Date" then
						sqlData = " AND m.Date>="&mydatenull(ref("De"))&" AND m.Date<="&mydatenull(ref("Ate"))
					end if

					ValorFinalTaxado = 0
					ValorLiquidoFinal=0

					sqlConta = ""
					sqlTransacao = ""
					sqlAutorizacao = ""

					if ref("Autorizacao") <> ""  then
                        sqlAutorizacao = " and t.AuthorizationNumber like '"&ref("Autorizacao")&"' "
                    end if

                    if ref("Transacao") <> ""  then
                        sqlTransacao = " and t.TransactionNumber like '"&ref("Transacao")&"' "
                    end if

					if ref("Conta") <> ""  then
                        contas = replace(ref("Conta"), "|", "")
						sqlConta = " and m.AccountIDDebit IN ("&contas&") "
					end if
															
					queryBlock = " ,coalesce((select acrescimoPercentual "&_
										   	  " from sys_financial_current_accounts_percentual "&_
											 " where sys_financialCurrentAccountId = m.AccountIDDebit "&_
											  "  and minimo <= (select count(id) "&_
												                " from sys_financialcreditcardreceiptinstallments "&_
												               " where TransactionID = p.TransactionID) "&_
											   " and maximo >= (select count(id) "&_
											                    " from sys_financialcreditcardreceiptinstallments "&_
											                   " where TransactionID = p.TransactionID) "&_
											                     " and (sys_financial_current_accounts_percentual.bandeira = bc.id or sys_financial_current_accounts_percentual.bandeira is null) "&_
											                " order by acrescimoPercentual desc "&_
											                   " limit 1), coalesce((select PercentageDeducted from sys_financialCurrentAccounts where id = m.AccountIDDebit), p.Fee)) AS taxa_atualmente "


					queryBlockBandeira = "coalesce((select cliniccentral.bandeiras_cartao.Bandeira "&_
												  	 " from sys_financial_current_accounts_percentual "&_
													 " join cliniccentral.bandeiras_cartao on cliniccentral.bandeiras_cartao.id = sys_financial_current_accounts_percentual.bandeira "&_
													" where sys_financialCurrentAccountId = m.AccountIDDebit "&_
													  " and minimo <= (select count(id) "&_
															    	   " from sys_financialcreditcardreceiptinstallments "&_
																      " where TransactionID = p.TransactionID) "&_
													  " and maximo >= (select count(id) "&_
																       " from sys_financialcreditcardreceiptinstallments "&_
																	  " where TransactionID = p.TransactionID) order by acrescimoPercentual desc limit 1), bc.Bandeira) AS Bandeira "														

					Limite = 250
					sqlLimit = "LIMIT "&Limite&""

					PaginaAtual = ccur(ref("PaginaAtual"))
					if PaginaAtual>1 then
						sqlLimit = "LIMIT "&((PaginaAtual-1)*Limite)&","&Limite
					end if

                    sql = "select * from (select pac.NomePaciente,reci.UnidadeID, pac.id Prontuario, p.id,p.Value,p.TransactionID,p.DateToReceive,p.InvoiceReceiptID,p.Fee,p.DHUp, m.Date, m.Value Total, t.TransactionNumber, bc.Bandeira , t.AuthorizationNumber, m.AccountAssociationIDCredit, m.AccountIDCredit, m.AccountAssociationIDDebit, m.AccountIDDebit, reci.NumeroSequencial, IFNULL(nfe.numeronfse, fi.nroNFE) NumeroNFe, IF(reci.UnidadeID = 0, (SELECT Sigla from empresa where id=1), (SELECT Sigla from sys_financialcompanyunits where id = reci.UnidadeID)) SiglaUnidade, "&_
                          					"  Parcela, "&_
                          					" Parcelas NumeroParcelas "&queryBlock&" from sys_financialcreditcardreceiptinstallments p  "&_
                          					"INNER JOIN sys_financialcreditcardtransaction t on t.id=p.TransactionID  "&_
                          					"INNER JOIN sys_financialmovement m on m.id=t.MovementID "&_
                          					"INNER JOIN pacientes pac on pac.id=m.AccountIDCredit "&_
                                              "LEFT JOIN sys_financialdiscountpayments dispay on dispay.MovementID=t.MovementID "&_
                          					"LEFT JOIN sys_financialmovement movrec on movrec.id=dispay.InstallmentID "&_
                          					"LEFT JOIN sys_financialmovement movinstal on movinstal.id=p.InvoiceReceiptID "&_
                          					"LEFT JOIN recibos reci ON reci.InvoiceID=movrec.InvoiceID AND reci.sysActive=1 "&_
                                              "LEFT JOIN nfe_notasemitidas nfe ON nfe.InvoiceID=movrec.InvoiceID AND nfe.situacao=1 "&_
                                              "LEFT JOIN sys_financialinvoices fi ON fi.id=movrec.InvoiceID "&_
                          					"LEFT JOIN cliniccentral.bandeiras_cartao bc on bc.id=t.BandeiraCartaoID "&_
                          					"WHERE m.AccountAssociationIDDebit=1 " & sqlConta & sqlAutorizacao & sqlTransacao & sqlData & sqlBaixados & " AND coalesce(NULLIF('"&ref("Bandeira")&"','') like CONCAT('%|',Bandeira,'|%'),true) GROUP BY p.id order by DateToReceive, m.Date, NomePaciente"&_
											")t "&sqlLimit

					sqlQtd = "SELECT COUNT(p.id) qtd "&_
							"	FROM sys_financialcreditcardreceiptinstallments p "&_
							"	INNER JOIN sys_financialcreditcardtransaction t ON t.id=p.TransactionID "&_
							"	INNER JOIN sys_financialmovement m ON m.id=t.MovementID "&_
" "&_
"								LEFT JOIN sys_financialdiscountpayments dispay ON dispay.MovementID=t.MovementID "&_
"								LEFT JOIN sys_financialmovement movrec ON movrec.id=dispay.InstallmentID "&_
"								LEFT JOIN sys_financialmovement movinstal ON movinstal.id=p.InvoiceReceiptID "&_
"								LEFT JOIN cliniccentral.bandeiras_cartao bc ON bc.id=t.BandeiraCartaoID "&_
"WHERE m.AccountAssociationIDDebit=1 " & sqlConta & sqlAutorizacao & sqlTransacao & sqlData & sqlBaixados & " AND coalesce(NULLIF('"&ref("Bandeira")&"','') like CONCAT('%|',Bandeira,'|%'),true) "

					set TotalLinhasSQL = db.execute(sqlQtd)

					TotalLinhas = ccur(TotalLinhasSQL("qtd"))

					TotalPaginas = TotalLinhas / Limite 


					set rec = db.execute(sql) 

					response.Buffer = "true"

					countQtd=0
					parcela = 0
					lastTransactionID = 0

					while not rec.eof
                        response.flush()
						if not isnull(rec("Value")) and not isnull(rec("Total")) and not isnull(rec("NomePaciente")) then
						    Fee = rec("taxa_atualmente")
						    if isnull(Fee) then
						        Fee=0
						    end if

							Taxa = ccur(Fee) / 100
							Taxa = Taxa * rec("Value")
                            ValorCheio = rec("Value")
							ValorCredito = ccur(rec("Value")) - Taxa
							Parcela = rec("Parcela")

							set diasParaCreditosql = db_execute("select DaysForCredit from sys_financialCurrentAccounts where id = "&rec("AccountIDDebit"))
							diasParaCredito = 30
							if not diasParaCreditosql.eof and IsNumeric(diasParaCreditosql("DaysForCredit")&"") then
								diasParaCredito = cint(diasParaCreditosql("DaysForCredit")&"")
							end if

							if lastTransactionID <> rec("TransactionID") then
								lastTransactionID = rec("TransactionID")

							end if 

							Parcelas = rec("NumeroParcelas")
							Bandeira = rec("Bandeira")&""														

							nomeDoPaciente = rec("NomePaciente")
							if rec("AccountAssociationIDCredit") <> 3 then
								nomeDoPaciente = nameInAccount(rec("AccountAssociationIDCredit") & "_" & rec("AccountIDCredit"))
							end if

                            if rec("InvoiceReceiptID")<>0 and not isnull(rec("InvoiceReceiptID")) then
                                set pmov = db_execute("select Value,Date from sys_financialmovement m where id="&rec("InvoiceReceiptID"))
                                if pmov.eof then
                                    classe = "danger"
                                    ValorRecebido = 0
                                    Data = "-"
                                else
                                    classe = "success"
                                    ValorRecebido = pmov("Value")
                                    Data = pmov("Date")
                                end if
                                set pTaxa = db_execute("select value Taxa from sys_financialmovement where MovementAssociatedID="&rec("InvoiceReceiptID")&" LIMIT 1")
                                if pTaxa.eof then
                                    Taxa = 0
                                else
                                    if rec("Value")<>0 then
                                    fator = 100 / rec("Value")
                                    Taxa = fator * pTaxa("Taxa")
                                    else
                                        Taxa = 0
                                    end if
                                end if
                                ValorFinalTaxado = ValorFinalTaxado + (rec("Value") - ValorRecebido)
                                ValorLiquidoFinal = ValorLiquidoFinal + rec("Value")
								
								countQtd = countQtd + 1
                                %>
                                <tr class="<%=classe %>">
                                    <td></td>
                                    <td><a href="./?P=Pacientes&Pers=1&I=<%= rec("Prontuario") %>" target="_blank"><%=Left(nomeDoPaciente,20)%></a>
							        <td nowrap><%=rec("TransactionNumber")%></td>
							        <td nowrap><%=rec("AuthorizationNumber")%></td>
							        <td align="center"><%= rec("Date") %></td>
							        <td><%=rec("SiglaUnidade")&rec("NumeroSequencial")%></td>
                                    <td><%=rec("NumeroNFe")%></td>
							        <td nowrap><%= Parcela %> / <%= Parcelas %></td>
							        <td nowrap><%= Bandeira %></td>
							        <td nowrap align="right">
                                      R$ <%= fn(rec("Total")) %>
                                      <input type="hidden" id="parc<%=rec("id") %>" value="<%=fn(rec("Value")) %>" />
							        </td>
							        <td class="text-right"><%= fn(Taxa)%>%</td>
                                    <td class="text-right"><%=fn(ValorRecebido) %></td>
                                    <td class="text-center"><%=Data %></td>
                                    <td>
                                        <button id="btn<%=rec("id")%>" class="btn btn-sm btn-default btn-block" type="button" onClick="baixa(<%=rec("id")%>, 'C', <%=Parcela%>, <%=Parcelas%>);">Baixado <i class="far fa-trash red"></i></button>
                                    </td>
                                </tr>
                                <%
                            else
                                ValorFinalTaxado = ValorFinalTaxado + (rec("Value") - ValorCredito)
                                ValorLiquidoFinal = ValorLiquidoFinal + ValorCredito

								countQtd = countQtd+1

								'data = rec("DateToReceive")
								dataPagamento = rec("Date")
								dataPagamento = dateadd("d", diasParaCredito*Parcela, dataPagamento)
								data = dataPagamento
								if weekday(data)=7 then
									data = data+2
								elseif weekday(data)=1 then
									data = data+1
								end if

								'if Parcela > 1 then
									'dias = diasParaCredito * Parcela
									'data = dateadd("d",dias,data)
								'end if

    							%>
							    <tr class="lista-tr">
                                   <td>
                                       <input type="checkbox" name="parcCC" value="<%=rec("id") %>" parcela="<%=Parcela%>" parcelas="<%=Parcelas%>" class="chk" />
                                   </td>
							      <td nowrap>
								   
                                      <a href="./?P=Pacientes&Pers=1&I=<%= rec("Prontuario") %>" target="_blank"> <%=Left(nomeDoPaciente,20)%></a>

							      </td>
							      <td nowrap><%=rec("TransactionNumber")%></td>
							      <td nowrap><%=rec("AuthorizationNumber")%></td>
							      <td align="center"><%= rec("Date") %></td>
							      <td><%=rec("SiglaUnidade")&rec("NumeroSequencial")%></td>
                                  <td><%=rec("NumeroNFe")%></td>
							      <td nowrap><%= Parcela %> / <%= Parcelas %></td>
							      <td nowrap><%= Bandeira %></td>
							      <td nowrap align="right">
                                      R$ <%= fn(rec("Total")) %>
                                      <input type="hidden" id="parc<%=rec("id") %>" value="<%=fn(rec("Value")) %>" />
							      </td>
							      <td><%= quickField("text", "Fee"&rec("id"), "", 2, fn(rec("taxa_atualmente")), "input-mask-brl text-right", "", " data-id='"&rec("id")&"' ") %></td>
							      <td>
							  	    <%= quickField("text", "ValorCredito"&rec("id"), "", 2, fn(ValorCredito), "input-mask-brl text-right", "", " data-id='"&rec("id")&"' ") %>
                                    <input type="hidden" id="Taxa<%=rec("id")%>" name="Taxa<%=rec("id")%>" value="<%=Taxa%>">
                                    <input type="hidden" name="ValorCheio<%=rec("id") %>" value="<%=ValorCheio %>" />
                                  </td>
							      <td><%= quickField("datepicker", "DateToReceive"& rec("id"), "", 1, data, "", "", "") %></td>
							      <td>
                              	    <button id="btn<%=rec("id")%>" class="btn btn-xs btn-success" type="button" onClick="baixa(<%=rec("id")%>, 'B', <%=Parcela%>, <%=Parcelas%>);"><i class="far fa-check"></i> Baixar</button>
								    </td>
						      </tr>
						    <%
                            end if
						end if
					rec.movenext
					wend
					rec.close
					set rec=nothing
					%>
                    <tr>
                        <th colspan="7"><%=countQtd%> registro(s)</th>
                        <th colspan="2">Total de taxa: <span style="color: red;">R$<%=fn(ValorFinalTaxado)%></span></th>
                        <% if ref("Pendentes")="S" then %>
                            <th colspan="6">Valor Bruto: <span style="color: green;">R$<%=fn(ValorLiquidoFinal)%></span></th>
                        <% else %>
                            <th colspan="3">Valor Bruto: <span style="color: green;">R$<%=fn(ValorLiquidoFinal)%></span></th>
                            <th colspan="3">Valor Recebido: <span style="color: green;">R$<%=fn(ValorLiquidoFinal-ValorFinalTaxado)%></span></th>
                        <% end if %>
                    </tr>
					</tbody>
				</table>
			</div>
		</div>
		<%
		
		if TotalPaginas>1 then
		%>
		<div class="row text-center">
			<ul class="pagination">
			<%
			PaginaLoop=1
			while PaginaLoop< TotalPaginas + 1

				ativo = ""

				if PaginaAtual&""=PaginaLoop&"" then
					ativo = "active"
				end if
			%>
			<li  class="<%=ativo%>"><a href="javascript:buscaPagina(<%=PaginaLoop%>)"><%=PaginaLoop%></a></li>
			<%
				PaginaLoop=PaginaLoop+1
			wend
			%>
			</ul>
		</div>
		<%
		end if
		%>
		<div id="divCartaoLote">
		    <div class="panel-body"></div>
        </div>
        <%else%>
        <center><em>Busque acima o perfil dos recebimentos que deseja administrar.</em></center>
        <%End if%>
<script type="text/javascript">
    $(".chk").click(function () {

        if ($(".chk:checked").length == 0) {
            $("#divCartaoLote").addClass("hidden");
        } else {
            $("#divCartaoLote").removeClass("hidden");
        }
        $.post("cartaoLote.asp", $("input[name=parcCC], input[name^=ValorCheio]").serialize(), function (data) {
            $("#divCartaoLote .panel-body").html(data);
        });
    });
$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})
    <!--#include file="JQueryFunctions.asp"-->
</script>