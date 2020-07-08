<!--#include file="connect.asp"-->
<%
set getMedicamentosConvenios = db.execute("SELECT * FROM medicamentosconvenios WHERE sysActive=1")
while not getMedicamentosConvenios.eof
    db.execute("UPDATE medicamentosconvenios SET Convenios = '"&ref("Convenios_"&getMedicamentosConvenios("id"))&"', MedicamentoOriginalID="&treatvalzero(ref("MedicamentoOriginalID_"&getMedicamentosConvenios("id")))&" , MedicamentoSubstitutoID="&treatvalzero(ref("MedicamentoSubstitutoID_"&getMedicamentosConvenios("id")))&", sysActive=1 WHERE id="&getMedicamentosConvenios("id"))
getMedicamentosConvenios.movenext
wend
getMedicamentosConvenios.close
set getMedicamentosConvenios=nothing

%>

new PNotify({
    title: 'Sucesso!',
    text: 'Salvo',
    type: 'success',
    delay:1000
});