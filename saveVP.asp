<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
set vp = db.execute("select id from varprecos where id="& req("I"))
while not vp.eof
    id = vp("id")
    ApenasPrimeiroAtendimento = ref("ApenasPrimeiroAtendimento")
    if ApenasPrimeiroAtendimento="" then
        ApenasPrimeiroAtendimento="N"
    end if

    sqlUp = "update varprecos set Procedimentos='"&ref("Procedimentos"&id)&"', Profissionais='"&ref("Profissionais"&id)&"', Especialidades='"&ref("Especialidades"&id)&"', Tabelas='"&ref("Tabelas"&id)&"', Unidades='"&ref("Unidades"&id)&"', Tipo='"&ref("Tipo"&id)&"', Valor="&treatvalzero(ref("Valor"&id))&", TipoValor='"&ref("TipoValor"&id)&"', ApenasPrimeiroAtendimento='"&ApenasPrimeiroAtendimento&"' where id="&id
    call gravaLogs(sqlUp, "AUTO", "", "")
    db_execute(sqlUp)
vp.movenext
wend
vp.close
set vp=nothing
%>
new PNotify({
    type: 'success',
    title: 'Sucesso!',
    text: 'Variações salvas',
    delay: 1000
});
ajxContent('VariacoesPrecosConteudo', '', 1, 'divVarPrecos');
$("#modal-table").modal("hide");