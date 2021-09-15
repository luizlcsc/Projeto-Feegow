<!--#include file="connect.asp"-->
<%
Conta = req("ContaID")
SpltConta = split(Conta, "_")

AssContaID=SpltConta(0)
ContaID=SpltConta(1)



'------> pegando os creditos
if 1=1 then
sqlMovCred = "select m.*, (select sum(DiscountedValue) from sys_financialdiscountpayments where MovementID=m.id) as soma from sys_financialmovement m where ((m.AccountAssociationIDCredit="&AssContaID&" and m.AccountIDCredit="&ContaID&") or (m.AccountAssociationIDDebit="&AssContaID&" and m.AccountIDDebit="&ContaID&")) and m.Type in('Pay', 'Transfer') and m.CD != 'T' "
'response.Write( sqlMovCred )
set mov = db.execute(sqlMovCred)

		if not mov.eof then
            while not mov.eof
                valor = mov("Value")
                soma = mov("soma")

                if isnull(soma) then soma=0 end if

                valor = round(valor,2)
                soma = round(soma,2)

                if valor>soma then
                    if headCredito = "" then
                    %>
                    <form id="frmCredito" action="" method="post">
                    <div class="modal-body">
                        <div class="widget-box">
                            <div class="widget-header widget-hea1der-small header-color-green">
                                <h6>CRÉDITOS DISPONÍVEIS</h6>


                            </div>

                            <div class="widget-body">
                                <div class="widget-main padding-4">
                                    <div class="slim-scroll" data-height="125">
                                        <div class="content" id="Credits">
                                        <table class="table table-striped table-hover table-bordered">
                                        <thead>
                                            <tr>
                                                <th width="1%"></th>
                                                <th>Data</th>
                                                <th>Tipo</th>
                                                <th>Valor</th>
                                                <th>Utilizado</th>
                                                <th>Cr&eacute;dito</th>
                                                <th width="1%"></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        <%
                        headCredito = "S"
                    end if
                    credito = valor-soma
                    %>
                                            <tr>
                                                <td><label><input type="radio" class="ace credito" id="Credito" name="Credito" value="<%=mov("id")&"_"&formatnumber(credito,2)%>" /><span class="lbl"></span></label></td>
                                                <td class="text-right"><%=mov("Date")%></td>
                                                <td><%=mov("id")%> - <%=mov("Name")%></td>
                                                <td class="text-right"><%=formatnumber(valor,2)%></td>
                                                <td class="text-right"><%=formatnumber(soma,2)%></td>
                                                <td class="text-right"><%=formatnumber(credito,2)%></td>
                                                <td><button type="button" class="btn btn-xs btn-danger" onclick="excluiMov(<%=mov("id")%>);"<% If soma>0 Then %> disabled="disabled"<% End If %>><i class="far fa-remove"></i></button></td>
                                            </tr>
                    <%
                end if
            mov.movenext
            wend
            mov.close
            set mov=nothing
        end if
		if headCredito="S" then
		%>
		                </table>
		                </div>
	                </div>
                    <div id="pagtoCredito" class="alert alert-info mt10">
    	                <%server.Execute("calcCredito.asp")%>
                    </div>
                                </div></div></div></div>
	            </form>
		<%
		end if
end if
%>