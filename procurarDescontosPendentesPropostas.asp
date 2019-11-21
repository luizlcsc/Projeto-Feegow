<!--#include file="connect.asp"-->

<%

itens = ref("itens")

temDescontosPendentesAprovacao = 0
if itens&"" <> "" then 

    sqlDescontoPendente = "select * from descontos_pendentes where ItensInvoiceID in ("&itens&") AND SysUserAutorizado IS NULL AND DataHoraAutorizado IS NULL "
    set rsDescontoPendente = db.execute(sqlDescontoPendente)
    if not rsDescontoPendente.eof then 
        temDescontosPendentesAprovacao = 1
    end if
end if

if temDescontosPendentesAprovacao > 0 then 
%>
    <div class='alert alert-warning'>
        Existem descontos pendentes de aprovação <%=temDescontosPendentesAprovacao%>
    </div>
<% end if %>
