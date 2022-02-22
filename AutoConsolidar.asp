<script src="vendor/jquery/jquery-1.11.1.min.js"></script>
<script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
<script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
<script src="js/components.js"></script>

<!--#include file="connect.asp"-->
<%
response.charset = "utf-8"

set rec = db_execute("select * from reconsolidar ORDER BY id DESC LIMIT 20")

while not rec.eof
    AC = AC & ","& rec("id")
    Tipo = rec("Tipo")
    ItemID = rec("ItemID")
    if Tipo="invoice" then
        set iis = db.execute("select id from itensinvoice where InvoiceID="& treatvalzero(ItemID))
        while not iis.eof
            set rr = db.execute("select distinct ItemInvoiceID, ItemDescontadoID from rateiorateios rr WHERE rr.ItemInvoiceID="& iis("id") &" and isnull(ItemContaAPagar) and isnull(ItemContaAReceber) and isnull(CreditoID)")
            while not rr.eof
                set vca = db.execute("select ItemInvoiceID, ItemDescontadoID from rateiorateios where ItemInvoiceID="& rr("ItemInvoiceID") &" and ItemDescontadoID="& rr("ItemDescontadoID") &" and ( not isnull(ItemContaAPagar) or not isnull(ItemContaAReceber) or not isnull(CreditoID) )")
                if vca.eof then
                    if False then
                        db_execute("delete r from recibos r  inner join rateiorateios rat on r.RepasseIDS LIKE CONCAT('%|',rat.id,'|%') where ItemInvoiceID="& rr("ItemInvoiceID") &" and ItemDescontadoID="& rr("ItemDescontadoID"))
                        db_execute("delete from recibos WHERE InvoiceID="&ItemID&" AND RepasseIDS=''")
                    end if

                    db_execute("delete from rateiorateios where ItemInvoiceID="& rr("ItemInvoiceID") &" and ItemDescontadoID="& rr("ItemDescontadoID"))
                end if
            rr.movenext
            wend
            rr.close
            set rr = nothing
        iis.movenext
        wend
        iis.close
        set iis = nothing
    end if
rec.movenext
wend
rec.close
set rec = nothing

server.Execute("RepasseCalculoAConferirParticular.asp")


%>

<script type="text/javascript">
$.each($(".checkbox-success"), function() {
    $(this).find("input").prop("checked", true);
});

if( $("input:checked").size()>0 ){
    $.post("RepasseConsolida.asp?AC=<%= 0 & AC %>&InvoiceID=<%=req("I")%>", $("form").serialize(), function(data){
        eval(data);
    });
}else
{
    if($("#invoiceID").val()){
        $.post("RepasseConsolida.asp?AC=<%= 0 & AC %>&A=Recibo&InvoiceID="+$("#invoiceID").val(), $("form").serialize(), function(data){
          eval(data);
        });
    }
    
}

</script>