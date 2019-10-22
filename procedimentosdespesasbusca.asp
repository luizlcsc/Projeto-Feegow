<!--#include file="connect.asp"-->
<table class="table table-condensed table-hover">
    <thead>
        <tr>
            <th width="10%">Código</th>
            <th width="30%">Item</th>
            <th width="20%">Tabela</th>
            <th width="20%">CD</th>
            <th width="10%">Un. Medida</th>
        </tr>
    </thead>
    <tbody>
        <%
        buscaPT = ref("buscaPT")
        set pt = db.execute("select pt.*, p.NomeProduto, tb.Descricao NomeTabela, tcd.Descricao CD, um.Descricao Medida from tissprodutostabela pt LEFT JOIN produtos p ON p.id=pt.ProdutoID lEFT JOIN tisstabelas tb ON tb.id=pt.TabelaID LEFT JOIN cliniccentral.tisscd tcd ON tcd.id=p.CD LEFT JOIN cliniccentral.tissunidademedida um ON um.id=p.ApresentacaoUnidade WHERE pt.Codigo LIKE '%"& buscaPT &"%' OR p.NomeProduto  LIKE '%"& buscaPT &"%'")
        while not pt.eof
            %>
            <tr style="cursor:pointer" onclick="addPT(<%= pt("id") %>)">
                <td><%= pt("Codigo") %></td>
                <td><%= pt("NomeProduto") %></td>
                <td><%= pt("NomeTabela") %></td>
                <td><%= pt("CD") %></td>
                <td><%= pt("Medida") %></td>
            </tr>
            <%
        pt.movenext
        wend
        pt.close
        set pt=nothing
        %>
    </tbody>
</table>