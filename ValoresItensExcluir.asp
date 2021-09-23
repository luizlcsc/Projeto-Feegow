<!--#include file="connect.asp"-->
<%
if ref("pt")<>"" then
    Exc = split(ref("pt"), ", ")
    for i=0 to ubound(Exc)
        db_execute("delete from tissprodutostabela where id IN('"& Exc(i) &"')")
        db_execute("delete from tissprodutosvalores where ProdutoTabelaID IN ("& Exc(i) &")")
    next
    %>
    location.reload();
    <%
end if

if req("PV")<>"" then
    'excluindo valoreplanos
    db_execute("delete from tissprodutosvalores where id="& req("PV"))
    %>
    $("#qfpv<%= req("PV")%>").css("display", "none");
    <%
end if

if req("PT")<>"" then
    db_execute("insert into tissprodutosvalores (ConvenioID, ProdutoTabelaID) values ("& req("C") &", '"& req("PT") &"')")
    set pv = db.execute("select pv.id, c.NomeConvenio, pv.Valor from tissprodutosvalores pv LEFT JOIN convenios c ON c.id=pv.ConvenioID where pv.ConvenioID="& req("C") &" order by pv.id desc limit 1")
    btnx = " <button type='button' class='btn btn-xs btn-danger' onclick='xpv("& pv("id") &")'><i class='far fa-remove'></i></button>"
    call quickfield("currency", "pv"&pv("id"), pv("NomeConvenio") & btnx, 12, fn(pv("Valor")), "", "", "")
    %>
<script >
$(".input-mask-brl").maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true});
</script>
    <%
end if
%>