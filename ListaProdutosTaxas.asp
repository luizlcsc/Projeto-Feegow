<!--#include file="connect.asp"-->

<%
if aut("|produtosX|")=1 and req("Acao")="X" then
    db.execute("UPDATE produtos SET sysActive=-1 WHERE id="&treatvalzero(req("ItemID")))
%>
<script>
new PNotify({
    title: 'Item excluído com sucesso',
    type: 'success',
    delay: 5000
});
</script>
<% end if %>

<script type="text/javascript">
    $(".crumb-active a").html("Taxas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Lista");
    $(".crumb-icon a span").attr("class", "far fa-money");

    <% if aut("|produtosI|")=1 then %>
        $("#rbtns").html('<a id="InserirProduto" class="btn btn-sm btn-success" href="?P=ProdutosTaxas&Pers=1&I=N"><i class="far fa-plus"></i> INSERIR</a>');
    <%end if%>

    function removeItem(ID){
        $.get("ListaProdutosTaxas.asp?ItemID="+ID+"&Acao=X", {}, function (data) {
            new PNotify({
                title: 'Item excluído com sucesso',
                type: 'success',
                delay: 5000
            });
            $("#linha"+ID).remove();
        });
    };
</script>
<form id="frmListaProdutos">
    <div class="panel">
        <div class="panel-body mt20">
            <div class="row">
                <div class="col-md-12">
                    <table id="datatableProdutos" class="table table-striped table-bordered table-hover">
                        <thead>
                            <tr class="primary">
                                <th width="90%">Taxa</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        sqlTipoProduto = "SELECT * FROM produtos WHERE TipoProduto = 5 and sysActive=1"
                        set prod = db.execute(sqlTipoProduto)
                            while not prod.EOF
                        %>
                            <tr id="linha<%=prod("id")%>">
                                <td><a href="./?P=ProdutosTaxas&Pers=1&I=<%=prod("id")%>"><%=prod("NomeProduto")%></a></td>
                                <td class="hidden-print" title="<%=title%>">
                                    <a class="btn btn-xs btn-primary" href="./?P=ProdutosTaxas&Pers=1&I=<%=prod("id")%>"><i class="far fa-edit"></i></a>
                                    <%
                                    if aut("|produtosX|")=1 then
                                    %>
                                    <button class="btn btn-xs btn-danger <%=disabled%>" type="button" onClick="removeItem(<%=prod("id")%>)"><i class="far fa-remove"></i></button>
                                    <%
                                    end if
                                    %>
                                </td>
                            </tr>
                    <%
                        prod.movenext
                        wend
                        prod.close
                    %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</form>