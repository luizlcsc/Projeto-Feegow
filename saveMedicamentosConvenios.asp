<!--#include file="connect.asp"-->
<%
Tipo = req("Tipo")

if Tipo = "P" then
    db.execute("UPDATE medicamentosconvenios SET Planos = '"&ref("Planos")&"' WHERE id="&req("I"))
else
    set getMedicamentosConvenios = db.execute("SELECT * FROM medicamentosconvenios WHERE sysActive=1")
    while not getMedicamentosConvenios.eof
        db.execute("UPDATE medicamentosconvenios SET Convenios = '"&ref("Convenios_"&getMedicamentosConvenios("id"))&"', MedicamentoOriginalID="&treatvalzero(ref("MedicamentoOriginalID_"&getMedicamentosConvenios("id")))&" , MedicamentoSubstitutoID="&treatvalzero(ref("MedicamentoSubstitutoID_"&getMedicamentosConvenios("id")))&", sysActive=1 WHERE id="&getMedicamentosConvenios("id"))
    getMedicamentosConvenios.movenext
    wend
    getMedicamentosConvenios.close
    set getMedicamentosConvenios=nothing
end if
%>

new PNotify({
    title: 'Sucesso!',
    text: 'Salvo',
    type: 'success',
    delay:1000
});