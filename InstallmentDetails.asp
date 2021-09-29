<%
discountedTotal = 0
%>
<tr>
	<td nowrap="nowrap">
    	<span class="tooltip-warning" data-rel="tooltip" data-placement="left" title="Marque aqui para pagar">
            <span class="smaller" id="<%="smaller"&simpleCountInstallments%>">...
            </span>
        </span>
    </td>
    <td class="text-right"><%if Installments=1 then%>&Uacute;nica<%else%><%=simpleCountInstallments%><%end if%></td>
    <td>
        <div class="input-group">
            <input class="form-control date-picker<%
            if cInstallments=1 and sysActive=0 then%> firstDueDate<%end if
            %>" type="text" data-date-format="dd/mm/yyyy" placeholder="" name="DueDateInstallment<%=cInstallments%>" id="DueDateInstallment<%=cInstallments%>" value="<%=DueDate%>">
            <span class="input-group-addon"><i class="far fa-calendar bigger-110"></i></span>
        </div>
    </td>
    <td>
        <div class="input-group">
            <span class="input-group-addon"><i class="far fa-money bigger-110"></i></span>
            <input class="form-control input-mask-brl InstallmentValues" placeholder="" type="text" value="<%=formatNumber(installmentValue,2)%>" name="ValueInstallment<%=cInstallments%>" id="ValueInstallment<%=cInstallments%>" style="text-align:right" />
        </div>
    </td>
    <td class="text-right">
					<%
					if sysActive=1 then
						AlreadyDiscounted = 0
						set getAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&cInstallments)
						while not getAlreadyDiscounted.EOF
							AlreadyDiscounted = AlreadyDiscounted+getAlreadyDiscounted("DiscountedValue")
						getAlreadyDiscounted.movenext
						wend
						getAlreadyDiscounted.close
						set getAlreadyDiscounted = nothing
		
						PaymentMovement = 0
						set getPaymentMovement = db.execute("select * from sys_financialDiscountPayments where MovementID="&cInstallments)
						while not getPaymentMovement.EOF
							PaymentMovement = PaymentMovement+getPaymentMovement("DiscountedValue")
						getPaymentMovement.movenext
						wend
						getPaymentMovement.close
						set getPaymentMovement = nothing
						
						'to build the percentual paid... continuation
						discountedTotal = AlreadyDiscounted + PaymentMovement
						totaldiscountedTotal = totaldiscountedTotal + discountedTotal
						totalinstallmentValue = totalinstallmentValue + installmentValue
					end if
					%>
            <%
			innerSmaller = "<label>"
			
			messagePartialPayment = ""
			If discountedTotal<installmentValue or sysActive=0 Then
				difference = installmentValue - discountedTotal
				
                innerSmaller = innerSmaller & "<input class=""ace ace-checkbox-2 bootbox-confirm"" type=""checkbox"" id=""checkbox"&simpleCountInstallments&""" onClick="""
				if sysActive=0 then
					stripePaymentStatus = "<span class=""label arrowed"">Em dia</span>"
					innerSmaller = innerSmaller & "fTriedCheckbox(this.id);"
				else
					if discountedTotal=0 then
						if date()>DueDate then
							stripePaymentStatus = "<span class=""label label-danger arrowed-in"">Vencida</span>"
						else
							stripePaymentStatus = "<span class=""label arrowed"">Em dia</span>"
						end if
					else
						stripePaymentStatus = "<span class=""label label-warning arrowed""> Falta</span>"
						messagePartialPayment = "<br /><span class=""label label-primary arrowed-right"">"&formatNumber(installmentValue,2)&"</span>"&_
						"<span class=""label label-success arrowed-in arrowed-right""> - "&formatNumber(discountedTotal,2)&"</span>"&_
						"<span class=""label label-danger arrowed-in""> = "&formatNumber(difference,2)&"</span>"&_
						"<input type=""hidden"" value="""&formatNumber(difference,2)&""" name=""difference"&cInstallments&""" id=""difference"&cInstallments&""" />"
					end if
					innerSmaller = innerSmaller & "checkToPay()"
				End If 
				innerSmaller = innerSmaller & """ name=""InstallmentsToPay"" value="""&cInstallments&""">"
			Else
				stripePaymentStatus = "<span class=""label label-success arrowed-in"">Quitada</span>"
				innerSmaller = innerSmaller & "<i class=""green ace icon-thumbs-up bigger-110""></i>"
			End If
            innerSmaller = innerSmaller & "	<span class=""lbl""> </span>"
			innerSmaller = innerSmaller & "</label>"
			
			innerSmaller = innerSmaller & stripePaymentStatus
			%>
			<%'=messagePartialPayment%>
            <%=formatnumber(discountedTotal,2)%>
	</td>
    <td class="text-right"><%=formatnumber(difference,2)%></td>
    <td>
    <% If sysActive=1 Then %>
    <a href="#modal-table" class="btn btn-xs btn-info" data-toggle="modal" onclick="modalPaymentDetails(<%= cInstallments %>);"><i class="far fa-zoom-in"></i></a>
	<% End If %>
    </td>
</tr>
        
<script language="javascript">
document.getElementById('<%="smaller"&simpleCountInstallments%>').innerHTML = '<%=innerSmaller %>';
</script>