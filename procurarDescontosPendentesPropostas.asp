<!--#include file="connect.asp"-->

<%

itens = ref("itens")

descontoRecemAprovado = 0
descontoRecemRejeitado = 0
temDescontosPendentesAprovacao = 0
if itens&"" <> "" then

    sqlDescontoPendente = "select id, DataHoraAutorizado, TIMESTAMPDIFF(MINUTE, DataHoraAutorizado, NOW()) TempoAutorizado, Status from descontos_pendentes where ItensInvoiceID in ("&itens&") "
    set rsDescontoPendente = db.execute(sqlDescontoPendente)
    if not rsDescontoPendente.eof then
        if isnull(rsDescontoPendente("DataHoraAutorizado")) then
            temDescontosPendentesAprovacao = 1
        else

            if not isnull(rsDescontoPendente("TempoAutorizado")) then
                if ccur(rsDescontoPendente("TempoAutorizado")) < 2 then
                    if rsDescontoPendente("Status")&"" = "1" then
                        descontoRecemAprovado=1
                    elseif rsDescontoPendente("Status")&"" = "-1" then
                        descontoRecemRejeitado=1
                    end if
                end if
            end if
        end if
    end if
end if

if temDescontosPendentesAprovacao > 0 then 
%>
    <div class='alert alert-warning'>
        <strong>Atenção!</strong> Existem descontos pendentes de aprovação: <%=temDescontosPendentesAprovacao%>
    </div>
<% end if
if descontoRecemAprovado > 0 then
%>
    <div class='alert alert-success'>
        <strong>Atenção!</strong> Desconto aprovado.
    </div>
<script >
showMessageDialog("Desconto aprovado", "success");
</script>
<% end if

if descontoRecemRejeitado > 0 then
%>
    <div class='alert alert-danger'>
        <strong>Atenção!</strong> Desconto rejeitado.
    </div>
<script >
showMessageDialog("Desconto rejeitado", "danger");
</script>
<% end if %>
<%

if temDescontosPendentesAprovacao =0 or descontoRecemAprovado =1 or descontoRecemRejeitado =1 then
    %>

<script >
try{
    clearInterval(descontoPendenteInterval);
}catch (e) {

}
</script>
    <%
end if
%>