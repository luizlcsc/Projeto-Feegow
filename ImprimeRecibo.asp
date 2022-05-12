<!--#include file="connect.asp"-->
<%
ReciboID = req("I")

set ReciboSQL=db.execute("SELECT * FROM recibos WHERE id="&ReciboID)

if not ReciboSQL.eof then
    'db.execute("UPDATE recibos SET Texto = '"&Recibo&"', ImpressoEm = now() WHERE id="&reciboID)
    db.execute("UPDATE recibos SET ImpressoEm = now() WHERE id="&reciboID)
    response.write(unscapeOutput(ReciboSQL("Texto")))
end if
%>
<script type="text/javascript">
    print();
</script>