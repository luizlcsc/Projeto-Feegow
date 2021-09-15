<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<%
if ref("Fatura")<>"" or req("Fatura")<>"" then

    Fatura=ref("Fatura")
    if Fatura="" then
        Fatura = req("Fatura")
    end if
    'aqui lista os itens caso seja a fatura do cartao
    set ItemInvoiceSQL = db.execute("SELECT id FROM itensinvoice WHERE InvoiceID="&Fatura&" LIMIT 1")
    if not ItemInvoiceSQL.eof then
        ItemInvoiceID = ItemInvoiceSQL("id")
    end if
    set ItensFaturaCartaoSQL = db.execute("SELECT fcpi.* FROM sys_financialcreditcardpaymentinstallments fcpi WHERE ItemInvoiceID="&treatvalzero(ItemInvoiceID))
    if not ItensFaturaCartaoSQL.eof then
        %>
        <table class="table table-striped">
        <thead>
            <tr class="success">
                <th>Data</th>
                <th><small>Conta</small></th>
                <th><small>Descrição</small></th>
                <th><small>Parcela</small></th>
                <th><small>Valor</small></th>
                <th style="display:none">Alterar Fatura</th>
            </tr>
        </thead>
        <%
        ValorTotal = 0
        while not ItensFaturaCartaoSQL.eof
            set NumeroParcelasSQL = db.execute("SELECT count(id) NumeroParcelas FROM sys_financialcreditcardpaymentinstallments WHERE TransactionID = "&ItensFaturaCartaoSQL("TransactionID"))
            NumeroParcelas = NumeroParcelasSQL("NumeroParcelas")
            set MovementSQL = db.execute("SELECT fdp.InstallmentID FROM sys_financialcreditcardpaymentinstallments fcpi  LEFT JOIN sys_financialcreditcardtransaction fct ON fct.id = fcpi.TransactionID LEFT JOIN sys_financialmovement fm ON fm.id = fct.MovementID LEFT JOIN sys_financialdiscountpayments fdp ON fdp.MovementID = fm.id WHERE fcpi.id = "&ItensFaturaCartaoSQL("id"))

            if not MovementSQL.eof then
                InstallmentID = MovementSQL("InstallmentID")
                if not isnull(InstallmentID) then
                    set InvoiceSQL = db.execute("SELECT fi.AssociationAccountID, fi.AccountID, GROUP_CONCAT( CASE ii.Tipo WHEN 'O' THEN ii.Descricao WHEN 'M' THEN p.NomeProduto END) Descricoes, fm.InvoiceID FROM sys_financialmovement fm LEFT JOIN itensinvoice ii ON ii.InvoiceID = fm.InvoiceID LEFT JOIN produtos p ON p.id = ii.ItemID LEFT JOIN sys_financialinvoices fi ON fi.id = ii.InvoiceID WHERE fm.id="&InstallmentID)

                    if not InvoiceSQL.eof then
                        InvoiceID = InvoiceSQL("InvoiceID")

                        if not isnull(InvoiceID) then
                            ContaItem = accountName(InvoiceSQL("AssociationAccountID"), InvoiceSQL("AccountID"))
                            Descricao = InvoiceSQL("Descricoes")
                        else
                            ContaItem = ""
                            Descricao = ""
                        end if
                    end if
                end if

                %>
                <tr>
                    <td><%=ItensFaturaCartaoSQL("DateToPay")%></td>
                    <td><%=ContaItem%></td>
                    <td><a href="?P=invoice&I=<%=InvoiceID%>&A=&Pers=1&T=D" target="_blank"><%=Descricao%></a></td>
                    <td><%=ItensFaturaCartaoSQL("Parcela")%>/<%=NumeroParcelas%></td>
                    <td>R$ <%=fn(ItensFaturaCartaoSQL("Value"))%></td>
                    <td style="display:none"><button type="button" onclick="AlteraFatura('<%=InvoiceID%>')" title="Alterar fatura desta conta" class="btn-default btn btn-xs"><i class="far fa-arrow-circle-o-right"></i></button></td>
                </tr>
                <%
                ValorTotal = ValorTotal + ItensFaturaCartaoSQL("Value")
            end if
        ItensFaturaCartaoSQL.movenext
        wend
        ItensFaturaCartaoSQL.close
        set ItensFaturaCartaoSQL=nothing
        %>
        <thead>
            <tr class="dark">
                <th></th>
                <th></th>
                <th></th>
                <th></th>
                <th><small>R$ <%=fn(ValorTotal)%></small></th>
                <th style="display:none"></th>
            </tr>
        </thead>
    </table>
    <script >
    setTimeout(function() {
        var $linhaFatura = $("#invoiceItens").find("[id^='row']").eq("0");
        $linhaFatura.find("input").attr("readonly",true);
        $linhaFatura.find("[name^='Desconto'], [name^='Acrescimo']").attr("readonly",false);

        $linhaFatura.find(".btn-danger, .btn-alert").attr("disabled",true);
    }, 250);

    function AlteraFatura(FaturaAtual) {
        $.get("AlteraFaturaConta.asp", {FaturaAtual: FaturaAtual}, function(data) {
            $("#modal-table").modal("show");
            $("#modal").html(data);
        });
    }
    </script>
        <%
    end if

%>
<%else%>
<center><em>Busque acima o perfil da fatura do cartão.</em></center>
<%End if%>