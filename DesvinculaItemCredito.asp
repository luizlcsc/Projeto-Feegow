<!--#include file="connect.asp"-->
<%
DiscountID=ref("DiscountID")
InstallmentID=ref("InstallmentID")
MovementID=ref("MovementID")
InvoiceID=ref("InvoiceID")

if DiscountID&"" <> "" then
    set ValorSQL = db.execute("SELECT DiscountedValue FROM sys_financialdiscountpayments WHERE id="&treatvalzero(DiscountID))

    if not ValorSQL.eof then
        Valor = ValorSQL("DiscountedValue")

        db_execute("UPDATE sys_financialmovement SET ValorPago=IF(ValorPago-"&treatvalzero(Valor)&" < 0 , 0,ValorPago-"&treatvalzero(Valor)&") WHERE id="&InstallmentID)

        db_execute("DELETE FROM sys_financialdiscountpayments WHERE InstallmentID="&treatvalzero(InstallmentID)&" AND MovementID="&treatvalzero(MovementID))
        db_execute("DELETE FROM itensdescontados WHERE PagamentoID="&treatvalzero(MovementID))
        %>
if( $.isNumeric($("#PacienteID").val()) )
{
    ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
}else{
    $('.parcela').prop('checked', false); $('#pagar').fadeOut();
    geraParcelas('N');
}

        <%
    end if
end if

%>