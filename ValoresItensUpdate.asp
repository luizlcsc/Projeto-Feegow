<!--#include file="connect.asp"-->
<%
if req("Inserir")="Inserir" then
    db_execute("insert into tissprodutostabela (Codigo, sysUser, sysActive) values ('', "& session("User") &", 1)")
    %>
    location.reload();
    <%
end if

if ref("E")="E" then
    set pt = db.execute("select pt.*, p.NomeProduto, p.CD, p.ApresentacaoUnidade from tissprodutostabela pt left join produtos p on p.id=pt.ProdutoID where pt.sysActive=1 order by p.NomeProduto")
    while not pt.eof
            db_execute("update tissprodutostabela set ProdutoID="& treatvalzero(ref("ProdutoID"& pt("id"))) &", Codigo='"& ref("Codigo"& pt("id")) &"', TabelaID="& treatvalnull(ref("TabelaID"& pt("id"))) &", Valor="& treatvalzero(ref("Valor"& pt("id"))) &" where id="& pt("id"))
            db_execute("update produtos set CD='"& ref("CD"& pt("id")) &"', ApresentacaoUnidade="& treatvalnull(ref("ApresentacaoUnidade"& pt("id"))) &" where id="& treatvalzero(ref("ProdutoID"& pt("id"))))
            set pv = db.execute("select pv.*, c.NomeConvenio from tissprodutosvalores pv LEFT JOIN convenios c ON c.id=pv.ConvenioID where pv.ProdutoTabelaID="& pt("id") &" order by pv.ProdutoTabelaID, pv.ConvenioID")
            while not pv.eof
                db_execute("update tissprodutosvalores set Valor="& treatvalzero(ref("pv"& pv("id"))) &" where id="& pv("id"))
            pv.movenext
            wend
            pv.close
            set pv=nothing
    pt.movenext
    wend
    pt.close
    set pt=nothing
    %>
    new PNotify({
        type:'success',
        title:'Salvo!',
        text:'Atualizado com sucesso...',
        delay:1000
    });
    <%
end if
%>
