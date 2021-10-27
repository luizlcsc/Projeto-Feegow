<!--#include file="connect.asp"-->
<table class="table table-striped table-bordered table-hover table-condensed">
    <thead>
        <th width="1%">#</th>
        <th width="20%">Código Individual</th>
    </thead>
    <tbody>
    <%
    ProdutoID = req("ProdutoID")
    set ultCod = db.execute("select CAST(CBID AS UNSIGNED) CBID from ( select CBID FROM estoqueposicao "&_
        "where CBID REGEXP ('^[0-9]') and ProdutoID="&ProdutoID&" order by id desc limit 10) t "&_
        "order by CAST(CBID AS UNSIGNED) desc LIMIT 1")

    if not ultCod.eof then
        UltimoCodigo = ultCod("CBID")
    end if


    if UltimoCodigo="" then
        UltimoCodigo = ProdutoID & "000000"
        UltimoCodigo = left(UltimoCodigo, 7)
    end if

    q = ccur(req("q"))
    c = 0
    Codigo = ccur(UltimoCodigo)
    while c<q
        c = c+1
        Codigo = Codigo + 1
        %>
        <tr>
            <td><%=c %></td>
            <%if aut("AlterarCodigoIndividual")=1 then%>
            <td><input class="form-control estind" name="CBIDs" type="text" value="<%=Codigo %>" /></td>
            <%else%>
            <td><input class="hidden" name="CBIDs" value="<%=Codigo %>" /><%=Codigo %></td>
            <%end if%>
        </tr>
        <%
    wend
    %>
    </tbody>
</table>