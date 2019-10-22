<!--#include file="connect.asp"-->
<%
ModoImpressao = req("ModoImpressao")
FormID = req("I")

if ModoImpressao&""<>"" then
    db_execute("UPDATE buiforms SET ModoImpressao ='"&ModoImpressao&"' WHERE id="&FormID)
end if
%>

new PNotify({
    title: 'SUCESSO!',
    text: 'Modo de impressão alterado.',
    type: 'success',
    delay: 3000
});