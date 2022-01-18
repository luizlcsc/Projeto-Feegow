<%
if isnull(ValorPago) or ValorPago="" or not isnumeric(ValorPago) then
	ValorPago = 0
end if

if NumeroParcelas="" then
    NumeroParcelas=1
end if

set BoletosDaParcela = db.execute("SELECT  coalesce(sum(boletos_emitidos.DueDate > now() and StatusID = 1),0) as aberto"&_
                                  "       ,coalesce(sum(now() > boletos_emitidos.DueDate and StatusID <> 3),0) as vencido"&_
                                  "       ,coalesce(sum(StatusID  = 3),0) as pago"&_
                                  "       ,COUNT(*) as totalboletos"&_
                                  " FROM sys_financialinvoices"&_
                                  " JOIN boletos_emitidos ON boletos_emitidos.InvoiceID = sys_financialinvoices.id"&_
                                  " WHERE boletos_emitidos.MovementID = "&ParcelaID&";")
%>
<style>
.geraBoleto {
width: 33px;
}
.geraBoleto .badge{
    top: -5px;
    font-size: 10px;
    left: 0px;
    background: #0e90d2;
    color: #ffffff;
}

.pendingTef {
width: 33px;
}
.pendingTef .badge{
    top: -15px;
    font-size: 10px;
    left: -5px;
    background: red;
    color: #ffffff;
}

<%

IF BoletosDaParcela("vencido") > "0" THEN %>
.geraBoleto .badge{
    background: #df5640;
}
<% END IF %>


</style>

<%
if recursoAdicional(14)=4 then
    if ValorPago=0 then
%>
<script>
$(function() {
    function checkForPendingTEF(movementId) {
        console.log("Checando transações TEF pendentes para movementId: " + movementId);
        let logs = localStorage.getItem("cappta-logs");
        if(logs) {
            let logsData = JSON.parse(logs);
            logsData.find(function(e) {
                if(typeof e.reqData !==  "undefined") {
                    if(e.reqData.movementId == movementId) {
                        $(".pendingTef").css("display", "block");
                        openComponentsModal("microtef/sync-payments", {"logData": e}, "Você possui pagamentos pendentes pelo TEF")
                    }
                }
            })
        }
    }checkForPendingTEF(<%=ParcelaID%>);
});
</script>
<%
    end if
end if
%>

<tr class="liPar" data-par="<%=ParcelaID %>">
    <td width="1%" style="display: flex;width:100%;height:50px;padding-bottom: 15px">
        <%
        if CD="C" then
            if recursoAdicional(14)=4 then
        %>
            <div>
                <button style="display: none" type="button" title="Pagamentos pendentes TEF" class="btn btn-warning btn-sm ml5 pendingTef" onclick="checkForPendingTEF(<%=ParcelaID%>)">
                <i class="far fa-refresh"></i>
                <span class="badge badge-danger" style="">1</span>
                </button>
            </div>
        <%
        end if
        if StatusEmissaoBoleto=4 then
            %>
            <div>
                <button type="button" title="Gerar boleto" class="btn btn-primary btn-sm ml5 geraBoleto" onclick="geraBoleto(<%=ParcelaID%>, '<% if session("Banco")="clinic5459" then response.write("legacy") else response.write("default") end if %>')" >
                <i class="far fa-barcode"></i>
                <% IF BoletosDaParcela("totalboletos") THEN %>
                <span class="badge badge-danger" style=""><%=BoletosDaParcela("totalboletos")%></span>
                <% END IF %>
                </button>
            </div>

<script >
function geraBoleto(ParcelaID, type = 'default') {
    var Vecto = $("#Date" + ParcelaID).val();

    openComponentsModal("emissaoboleto/invoice/movement", {"billId": ParcelaID, 'billMode': type, 'expiresAt': Vecto, 'invoiceId': '<%=req("I")%>'}, "Gerenciar boletos", true, false);
}
</script>
            <%
        end if

        if 1=1 and session("Banco")="clinic5459" and (formatnumber(ParcelaValor,2)>formatnumber( ValorPago ,2) or ParcelaValor=0) then
            set ItemInvoiceMensalidadeSQL = db.execute("SELECT id FROM itensinvoice WHERE CategoriaID IN "&_
            "(101, 220, 221, 222, 223, 224, 225) "&_
            " AND InvoiceID="&req("I")&" LIMIT 1")
            SistemaNovo = 0
            if not ItemInvoiceMensalidadeSQL.eof then
                SistemaNovo =1
            end if

            if SistemaNovo=1 then
            %>
            <a href="#" title="Atualizar fatura" class="btn btn-default btn-sm " onClick="geraDetalhamento(<%=ParcelaID%>)"><i class="far fa-calculator"></i></a>
            <%
            end if
            if SistemaNovo=1 then
            %>
            <a href="#" title="Enviar fatura via e-mail" class="btn btn-system btn-sm ml5" onClick="if(confirm('Deseja enviar a fatura?'))EnviaEmailFatura(<%=ParcelaID%>)" target="_blank"><i class="far fa-envelope"></i></a>
            <%
            EnvioEmail = ""
            set EnvioEmailSQL = db.execute("SELECT DataHora, ValorBoleto, VenctoBoleto, Para FROM faturasemails WHERE ReceitaID="&req("I"))
            if not EnvioEmailSQL.eof then
                while not EnvioEmailSQL.eof
                    EnvioEmail = EnvioEmail&"<span data-toggle='tooltip' title='Vencimento: "&EnvioEmailSQL("VenctoBoleto")&"<br> Valor: R$ "&fn(EnvioEmailSQL("ValorBoleto"))&" <br> Para: "&EnvioEmailSQL("Para")&"' class='label label-primary m5'> "&EnvioEmailSQL("DataHora")&" </span>"
                EnvioEmailSQL.movenext
                wend
                EnvioEmailSQL.close
                set EnvioEmailSQL = nothing
                %>
                <div style="font-size: 11px;"><%=EnvioEmail%></div>
                <%
            end if
            end if
            %>
            <script >
                function geraDetalhamento(ParcelaID) {
                    var Vecto = $("#Date<%=ParcelaID %>").val();

                    window.open("../feegow_components/api/FechaFatura?Fecha=S&Detalhamento=1&MovementID=<%=ParcelaID%>&Vencimento="+Vecto+"&ReceitaID=<%=req("I")%>&redirectTo=<%=req("Div")%>");
                }

                function EnviaEmailFatura(ParcelaID) {
                    var Vecto = $("#Date<%=ParcelaID %>").val();

                    window.open("../feegow_components/api/FechaFatura?Email=S&MovementID=<%=ParcelaID%>&Vencimento="+Vecto+"&ReceitaID=<%=req("I")%>&redirectTo=<%=req("Div")%>");
                }
            </script>
            <%
        elseif cint(NumeroParcelas) > 1 and StatusEmissaoBoleto<>4 then
        %>
        <button type="button" id="propParc<%=ParcelaID %>" onclick="propParc(<%=ParcelaID%>)" class="btn btn-xs btn-warning hidden"><i class="far fa-chevron-down"></i></button>
        <%end if %>
        <%
        end if
        %>
    </td>
    <% 
        sqlDataPrev = "SELECT tl.dataprevisao FROM itensinvoice ii " &_
                      "INNER JOIN tissguiasinvoice tgi ON tgi.ItemInvoiceID = ii.id " &_
                      "INNER JOIN tissguiasadt tgs ON tgs.id = tgi.GuiaID " &_
                      "INNER JOIN tisslotes tl ON tl.id = tgs.LoteID " &_
                      "WHERE ii.InvoiceID = '" & req("I") & "' LIMIT 1 "
        set rsDataPrev = db.execute(sqlDataPrev)

        if rsDataPrev.eof then
            dataprev = ParcelaData
        else
            dataprev = rsDataPrev("dataprevisao")
        end if
        %>
    <td><%=quickField("datepicker", "Date"&ParcelaID, "", 3, dataprev, " text-right disable", "", " required"&primParc)%></td>
    <td><%=quickField("text", "Name"&ParcelaID, "", 3, Name, " text-right disable ", "", "  placeholder='Opcional'  "&primParc)%></td>
    <td><%=quickField("currency", "Value"&ParcelaID, "", 3, formatnumber(ParcelaValor,2), " text-right disable", "", " required")%></td>
    <td class="text-right">R$ <%=formatnumber( ValorPago ,2)%></td>
    <td>
        
            	<input type="hidden" name="ParcelasID" id="ParcelasID" value="<%=ParcelaID%>">

        <%
        %>
        <%=btnParcela(ParcelaID, ValorPago, ParcelaValor, "", CD, parcelaCaixaID)%>




    <a class="btn btn-xs btn-info hidden" href="#modal-table" role="button" data-toggle="modal" onclick="modalPaymentDetails('<%=ParcelaID%>');"><i class="far fa-search-plus"></i></a>
    <td class="hidden"><button type="button" class="btn btn-xs btn-danger" onClick="parcelas('<%=ParcelaID%>', 'X', '<%=ParcelaID%>')"><i class="far fa-remove"></i></button></td>
</tr>
