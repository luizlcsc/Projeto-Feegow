<!--#include file="connect.asp"-->
<%


set g = db.execute("select count(id) Qtd, sum(ValorPago) Total ,ConvenioID from tiss"&req("T")&" where id in("&ref("guia")&")")
Qtd = ccur(g("Qtd"))
if Qtd>1 then
    s = "s"
end if


if not g.eof then
    set ContasSQL = db.execute("SELECT conta.id, itensinvoice.Descricao "&_
                               " FROM sys_financialinvoices conta "&_
                               " LEFT JOIN itensinvoice ON itensinvoice.InvoiceID = conta.id "&_
                               " WHERE conta.AccountID="&g("ConvenioID")&" AND conta.AssociationAccountID=6 AND conta.CD='C' AND itensinvoice.Tipo='O' AND itensinvoice.Descricao LIKE 'lote%' AND conta.sysDate > DATE_SUB(CURDATE(), INTERVAL 30 DAY)")
end if
if g("Total") > 0 then
%>
<div class="btn-group">
    <button onclick="geraInvoice('<%=req("T")%>', '<%=fn(g("Total"))%>',false)" class="btn btn-sm btn-system"><%=Qtd%> guia<%=s%> <i class="fa fa-chevron-circle-right"></i> R$ <%=fn(g("Total"))%> - Lançar no Contas a Receber</button>
    <%
    if not ContasSQL.eof then
    %>

    <button type="button" class="btn btn-system btn-sm dropdown-toggle" data-toggle="dropdown">
        <span class="caret"></span>
    </button>
    <ul class="dropdown-menu" role="menu">

    <%
        while not ContasSQL.eof
    %>
            <li><a href="#" onclick="javascript:geraInvoice('<%=req("T")%>', '<%=fn(g("Total"))%>', '<%=ContasSQL("id")%>')"><i class="fa fa-plus"></i> Adicionar a conta: <%=ContasSQL("Descricao")%></a></li>
    <%
        ContasSQL.movenext
        wend
        ContasSQL.close
        set ContasSQL=nothing
    %>
    </ul>
    <%
    end if
    %>
</div>
<%
end if
%>