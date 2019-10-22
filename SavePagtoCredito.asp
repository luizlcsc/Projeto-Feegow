<!--#include file="connect.asp"-->
<%
T = req("T")
DataPagto = date()
ValorPagto = ref("valCredito")

splMov = split(ref("Credito"), "_")


LastMovementID = splMov(0)


splItens = split(ref("ItemPagarID"), ", ")
for i=0 to ubound(splItens)
    ItemID = splItens(i)
    Valor = ref("Descontar_"&ItemID)
    if Valor<>"" and isnumeric(Valor) then
        Valor = ccur(Valor)
        if Valor>0 then
            db_execute("insert into itensdescontados (ItemID, PagamentoID, Valor) values ("&ItemID&", "&LastMovementID&", "&treatvalzero(Valor)&")")
        end if
    end if
next

set invs = db.execute("select sum(valor) PagoInvoice, ii.InvoiceID from itensdescontados id left join itensinvoice ii on ii.id=id.ItemID where id.PagamentoID="&LastMovementID&" group by invoiceid")
while not invs.eof
    PagoInvoice = invs("PagoInvoice")
    if not isnull(invs("InvoiceID")) then
        set movs = db.execute("select id, ifnull(ValorPago,0) ValorPago, `Value` from sys_financialmovement where Type='Bill' AND InvoiceID="&invs("InvoiceID"))
        while not movs.eof
            if instr(ref("Parcela"), "|"&movs("id")&"|") then
                ValorMov = movs("Value")
                ValorPago = movs("ValorPago")
                ValorPendente = ValorMov-ValorPago
                if PagoInvoice>=ValorPendente then
                    ValorPagoMov = ValorPendente
                else
                    ValorPagoMov = PagoInvoice
                end if
                db_execute("insert into sys_financialdiscountpayments (InstallmentID, MovementID, DiscountedValue) values ("&movs("id")&", "&LastMovementID&", "&treatvalzero(ValorPagoMov)&")")
                db_execute("update sys_financialmovement set ValorPago="&treatvalzero( ValorPago+ValorPagoMov )&" where id="&movs("id"))
                PagoInvoice = PagoInvoice - ValorPagoMov
            end if
        movs.movenext
        wend
        movs.close
        set movs=nothing
    end if
invs.movenext
wend
invs.close
set invs = nothing
%>
if( $.isNumeric($("#PacienteID").val()) )
{
    ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
}else{
    $('.parcela').prop('checked', false); $('#pagar').fadeOut();
    geraParcelas('N');
}
