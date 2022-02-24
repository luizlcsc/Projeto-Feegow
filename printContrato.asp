<!DOCTYPE html>

<html>
  <head>
    <meta http-equiv="content-type" content="text/html;charset=UTF-8" />


<!--#include file="connect.asp"-->
    <title>&nbsp;</title>
<style type="text/css">
body {
    background-color: #fff;
    color: #333;
    font-family: sans-serif,Arial,Verdana,"Trebuchet MS";
    font-size: 13px;
}
</style>
<style type="text/css" media="print">
.break {
page-break-after: always;
page-break-inside: avoid;
}
</style>
<%
ContratoID = req("I")
set cont = db.execute("select * from contratos where id="&ContratoID)

Contrato = cont("Contrato")&""
Contrato = replace(Contrato&"", "<hr />", "<div class='break'></div>")

if instr(Contrato, "[CodigoBarras.")>0 then
    spl = split(Contrato, "[CodigoBarras.")
    if cont("InvoiceID")>0 then
        NumeroCB = left(spl(1), 6)
    else
        NumeroCB = zeroEsq(cont("InvoiceID")*(-1), 8)
    end if
    Contrato = replace(Contrato, "[CodigoBarras."&NumeroCB&"]", "<iframe frameborder=0 scrolling=no width=200 height=50 src='CodBarras.asp?NumeroCodigo="& NumeroCB &"'></iframe>")
end if

Contrato = unscapeOutput(Contrato)
%>
</head>
<body>
    <%=Contrato %>
</body>
</html>
<script type="text/javascript">
    print();
</script>