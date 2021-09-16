<%
function formulaRepasse(ValorBruto, ValorRepasse, TipoValorRepasse)
	if TipoValorRepasse="P" then
		formulaRepasse = ValorRepasse * (0.01*ValorBruto)
	else
		formulaRepasse = ValorRepasse
	end if
end function
function valorFinalRepasse(TotalServico, ValorRepasse, TipoValorRepasse, SobreRepasse, PartConv, idItem)
	if SobreRepasse=0 then
		valorFinalRepasse = formulaRepasse(TotalServico, ValorRepasse, TipoValorRepasse)
	else
		if PartConv="Part" then
			sqlItem = "ItemInvoiceID"
		elseif PartConv="Conv" then
			sqlItem = "ItemGuiaID"
		end if
		set rateiosrepasse = db.execute("select * from rateiorateios where "&sqlItem&"="&idItem&" order by Sobre")
		totalTotal = 0
		totalSubtotal1 = 0
		totalSubtotal2 = 0
		totalSubtotal3 = 0
		while not rateiosrepasse.eof
			if rateiosrepasse("FM")="F" then
				Quant = 1
			else
				Quant = rateiosrepasse("Quantidade")
			end if
			if rateiosrepasse("Sobre")=0 then
				totalTotal = totalTotal + formulaRepasse(TotalServico, rateiosrepasse("Valor"), rateiosrepasse("TipoValor"))
			elseif rateiosrepasse("Sobre")=1 then
				totalSubtotal1 = totalSubtotal1 + formulaRepasse( TotalServico -totalTotal, rateiosrepasse("Valor"), rateiosrepasse("TipoValor"))
			elseif rateiosrepasse("Sobre")=2 then
				totalSubtotal2 = totalSubtotal2 + formulaRepasse( TotalServico -totalTotal-totalSubtotal1, rateiosrepasse("Valor"), rateiosrepasse("TipoValor"))
			elseif rateiosrepasse("Sobre")=3 then
				totalSubtotal3 = totalSubtotal3 + formulaRepasse(TotalServico -totalTotal-totalSubtotal1-totalSubtotal2, rateiosrepasse("Valor"), rateiosrepasse("TipoValor"))
			end if
			if SobreRepasse=1 then
				valorFinalRepasse = formulaRepasse( TotalServico -totalTotal, ValorRepasse*Quant, TipoValorRepasse)
			elseif SobreRepasse=2 then
				valorFinalRepasse = formulaRepasse( TotalServico -totalTotal-totalSubtotal1, ValorRepasse*Quant, TipoValorRepasse)
			elseif SobreRepasse=3 then
				valorFinalRepasse = formulaRepasse( TotalServico -totalTotal-totalSubtotal1-totalSubtotal2, ValorRepasse*Quant, TipoValorRepasse)
			end if
		rateiosrepasse.movenext
		wend
		rateiosrepasse.close
		set rateiosrepasse=nothing
	end if
end function

Total = 0
n = 0
if ContaCredito<>"" then
	if FormaID="" or FormaID="0" then 'forma nao selecionada (="") ou particular (="0")
		sqlReps = "select rr.*, ii.*, rr.id as idrateio, p.NomeProcedimento, i.* from rateiorateios as rr left join itensinvoice as ii on rr.ItemInvoiceID=ii.id left join procedimentos as p on p.id=ii.ItemID left join sys_financialinvoices as i on ii.InvoiceID=i.id where not isnull(ii.id) and ContaCredito='"&ContaCredito&"' and DataExecucao>="&mydatenull(De)&" and DataExecucao<="&mydatenull(Ate)&" and i.sysActive=1 order by DataExecucao"
	end if
	if FormaID<>"0" then'pode ser vazio (todos) ou id de algum convenio
        if FormaID<>"" then
            wrConv = " and g.ConvenioID="&FormaID&" "
        end if
		sqlRepsConv = "select rr.*, ig.*, rr.id as idrateio, p.NomeProcedimento, g.* from rateiorateios as rr left join tissprocedimentossadt as ig on rr.ItemGuiaID=ig.id left join procedimentos as p on ig.ProcedimentoID=p.id left join tissguiasadt as g on ig.GuiaID=g.id where not isnull(ig.id) and ContaCredito='"&ContaCredito&"' and ig.Data>="&mydatenull(De)&" and ig.Data<="&mydatenull(Ate)&" "& wrConv &" order by ig.Data"
	end if
elseif ItemContaAPagar<>"" then
	sqlReps = "select rr.*, ii.*, rr.id as idrateio, p.NomeProcedimento, i.* from rateiorateios as rr left join itensinvoice as ii on rr.ItemInvoiceID=ii.id left join procedimentos as p on p.id=ii.ItemID left join sys_financialinvoices as i on ii.InvoiceID=i.id where rr.ItemContaAPagar="&ItemContaAPagar&" order by DataExecucao"
end if
%>
<form method="post" id="frmRepasses" name="frmRepasses">
    <div class="panel">
        <div class="panel-body">
            <table class="table table-striped table-bordered table-condensed">
            <tr class="info">
	            <th width="1%"></th>
	            <th><%if ContaCredito<>"" then%><label><input type="checkbox" class="ace" id="marcar" /><span class="lbl"></span></label><%end if%></th>
	            <th>Data Exec.</th>
                <th>Descri&ccedil;&atilde;o</th>
                <th>Pagador</th>
                <th>Fun&ccedil;&atilde;o</th>
                <th nowrap="nowrap">Forma Rec.</th>
                <th nowrap="nowrap">Valor Serv.</th>
                <th nowrap="nowrap">Repasse</th>
                <th nowrap="nowrap" width="100">Total</th>
                <th></th>
            </tr>
            <%
            if sqlReps<>"" then
	            set reps = db.execute(sqlReps)
	            while not reps.eof
		            n = n+1
		            if reps("TipoValor")="V" then
			            Percen = ""
			            Cifrao = "R$ "
			            Subtotal = reps("Valor")
		            else
			            Percen = "%"
			            Cifrao = ""
			            if reps("FM")="F" then
				            Quantidade = 1
			            else
				            Quantidade = reps("Quantidade")
			            end if
			            Subtotal = reps("Quantidade") * (reps("ValorUnitario")-reps("Desconto")+reps("Acrescimo"))
			            Subtotal = valorFinalRepasse(Subtotal, reps("Valor"), reps("TipoValor"), reps("Sobre"), "Part", reps("ItemInvoiceID"))
		            end if
		            Total = Total+Subtotal
		            if not isnull(reps("AccountID")) then
			            Pagador = nameInAccount(reps("AssociationAccountID")&"_"&reps("AccountID"))
		            else
			            Pagador = ""
		            end if
		            if reps("FormaID")=0 or isnull(reps("FormaID")) then
			            Forma = "Particular"
		            else
			            set pforma = db.execute("select NomeConvenio from convenios where id="&reps("FormaID"))
			            if not pforma.eof then
				            Forma = pforma("NomeConvenio")
			            else
				            Forma = "Particular"
			            end if
		            end if

                    valItem = reps("Quantidade") * (reps("ValorUnitario")-reps("Desconto")+reps("Acrescimo"))
                    valorPago = -777

                    if Forma="Particular" then
'                        set valPago = db.execute("select ifnull(sum(Valor), 0) Pago from itensdescontados where ItemID="& reps("ItemInvoiceID"))
'                        valorPago = ccur(valPago("Pago"))
                        valorPago = 0
                        descrPagtos = ""
                        set valPago = db.execute("select idesc.Valor Pago, m.id, m.PaymentMethodID from itensdescontados idesc LEFT JOIN sys_financialmovement m on m.id=idesc.PagamentoID where idesc.ItemID="& reps("ItemInvoiceID"))
                        while not valPago.eof
                            valorPago = valorPago + valPago("Pago")
                            if valPago("PaymentMethodID")=2 or valPago("PaymentMethodID")=8 or valPago("PaymentMethodID")=9 then
                                if valPago("PaymentMethodID")=2 then
                                    titulo = "Individualizar cheque"
                                else
                                    set parcs = db.execute("select * from sys_financialcreditcardtransaction where MovementID="& valPago("id"))
                                    titulo = "Individualizar parcelas ("& parcs("Parcelas") &")"
                                end if
                                descrPagtos = descrPagtos & "<button type='button' title='"&titulo&"' class='btn btn-xs' onclick='alert(""database error"")'><i class='far fa-chain-broken'></i></button>"
                            end if
                        valPago.movenext
                        wend
                        valPago.close
                        set valPago = nothing
                        classPago = corPago("classe", valItem, valorPago)
                    end if
		            %>
		            <tr>
        	            <td nowrap>
                            <a title="Valor recebido: R$ <%= fn(valorPago) %>" href="./?P=invoice&I=<%=reps("InvoiceID") %>&Pers=1&T=C" target="_blank" class="btn btn-xs btn-<%=classPago %>">
                                <i class="far fa-money"></i>
                            </a>
                            <%=descrPagtos %>
        	            </td>
        	            <td>
                        <%if reps("ItemContaAPagar")=0 or isnull(reps("ItemContaAPagar")) then%>
	                        <label><input type="checkbox" class="ace repasse" id="<%=reps("idrateio")%>" name="Repasses" value="<%=reps("idrateio")&"|"&Subtotal%>" /><span class="lbl"></span></label>
                        <%end if%>
                        </td>
        	            <td><%=reps("DataExecucao")%></td>
        	            <td><%=reps("NomeProcedimento")%></td>
        	            <td><%=Pagador%></td>
        	            <td><%=reps("Funcao")%></td>
        	            <td><%=Forma%></td>
                        <td class="text-right" nowrap="nowrap">R$ <%=fn( valItem )%></td>
        	            <td class="text-right" nowrap="nowrap"><%= Cifrao %><%=formatnumber(reps("Valor"),2)%><%=Percen%></td>
                        <td class="text-right" nowrap="nowrap"><input class="form-control text-right" type="text" value="<%=formatnumber(Subtotal,2)%>" /></td>
                        <td>
                        <%if reps("ItemContaAPagar")=0 or isnull(reps("ItemContaAPagar")) then%>
	                        <button type="button" class="btn btn-xs btn-danger" onClick="x(<%=reps("idrateio")%>);"><i class="far fa-remove"></i></button>
                        <%end if%>
                        </td>
                    </tr>
		            <%
	            reps.movenext
	            wend
	            reps.close
	            set reps=nothing
            end if
            if sqlRepsConv<>"" then
            '	response.Write(sqlRepsConv)
	            set repsConv = db.execute(sqlRepsConv)
	            while not repsConv.eof
		            Subtotal = valorFinalRepasse(repsConv("ValorTotal"), repsConv("Valor"), repsConv("TipoValor"), repsConv("Sobre"), "Conv", repsConv("ItemGuiaID"))
		            total = total+Subtotal
		            n = n+1
		            set conv = db.execute("select NomeConvenio from convenios where id = '"&repsConv("ConvenioID")&"'")
		            if not conv.eof then
			            Forma = conv("NomeConvenio")
		            end if
		            NomePaciente = ""
		            if not isnull(repsConv("PacienteID")) then
			            set pac = db.execute("select NomePaciente from pacientes where id="&repsConv("PacienteID"))
			            if not pac.eof then
				            NomePaciente = pac("NomePaciente")
			            end if
		            end if
		            %>
		            <tr>
        	            <td><a href="./?P=tissguiasadt&Pers=1&I=<%=repsConv("GuiaID") %>" class="btn btn-xs btn-default" target="_blank"><i class="far fa-credit-card"></i></a></td>
        	            <td>
                        <%if repsConv("ItemContaAPagar")=0 or isnull(repsConv("ItemContaAPagar")) then%>
	                        <label><input type="checkbox" class="ace repasse" id="<%=repsConv("idrateio")%>" name="Repasses" value="<%=repsConv("idrateio")&"|"&Subtotal%>" /><span class="lbl"></span></label>
                        <%end if%>
                        </td>
        	            <td><%=repsConv("Data")%></td>
        	            <td><%=repsConv("NomeProcedimento")%></td>
        	            <td><%=NomePaciente%></td>
        	            <td><%=repsConv("Funcao")%></td>
        	            <td><%=Forma%></td>
                        <td class="text-right" nowrap="nowrap">R$ <%=fn(repsConv("ValorUnitario"))%></td>
        	            <td class="text-right" nowrap="nowrap"><%= Cifrao %><%=formatnumber(repsConv("Valor"),2)%><%=Percen%></td>
                        <td class="text-right" nowrap="nowrap">R$ <%=formatnumber(Subtotal,2)%></td>
                        <td>
                        <%if repsConv("ItemContaAPagar")=0 or isnull(repsConv("ItemContaAPagar")) then%>
	                        <button type="button" class="btn btn-xs btn-danger" onClick="x(<%=repsConv("idrateio")%>);"><i class="far fa-remove"></i></button>
                        <%end if%>
                        </td>
                    </tr>
		            <%
	            repsConv.movenext
	            wend
	            repsConv.close
	            set repsConv = nothing
            end if
            %>
            <tr>
	            <td colspan="9"><%=n%> repasses encontrados.</td>
                <td nowrap class="text-right">R$ <%=formatnumber(total,2)%></td>
            </tr>
            </table>
            <%
            if session("Admin")=1 then
            %>
            <div class="row">
	            <div class="col-md-12 text-right">
    	            <a href="./?P=RegerarRepasses&Pers=1"><em>Regerar repasses</em></a>
                </div>
            </div>
            <%
            end if
            %>
        </div>
    </div>
</form>
