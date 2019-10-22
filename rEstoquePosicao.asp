<!--#include file="connect.asp"-->
<h3>Posição de Estoque</h3>

<table class="table table-condensed table-bordered">
    <thead>
        <th>Produto</th>
        <th>Lote</th>
        <th>Validade</th>
        <th>Cód. Individual</th>
        <th>Localização</th>
        <th>Responsável</th>
        <th colspan="2">Quantidade</th>
    </thead>
<%
'set prod = db.execute("select p.id, p.NomeProduto, ep.Lote, ep.Validade,ep.CBID, l.NomeLocalizacao, ep.Responsavel, ep.Quantidade, ep.ValorPosicao, ep.TipoUnidade, u.Descricao Unidade, p.ApresentacaoNome from produtos p LEFT JOIN estoqueposicao ep ON ep.ProdutoID=p.id LEFT JOIN produtoslocalizacoes l ON l.id=ep.LocalizacaoID LEFT JOIN cliniccentral.tissunidademedida u ON u.id=p.ApresentacaoUnidade where (p.PosicaoConjunto>0 or p.PosicaoUnidade>0) and ep.Quantidade>0 and p.sysActive=1 order by p.NomeProduto")
set prod = db.execute("select p.NomeProduto, ep.Lote, ep.Validade, ep.CBID, l.NomeLocalizacao, ep.Responsavel, ep.Quantidade, ep.TipoUnidade, u.Descricao Unidade, p.ApresentacaoNome from estoqueposicao ep LEFT JOIN produtos p ON p.id=ep.ProdutoID LEFT JOIN produtoslocalizacoes l ON l.id=ep.LocalizacaoID LEFT JOIN cliniccentral.tissunidademedida u ON u.id=p.ApresentacaoUnidade WHERE ep.Quantidade>0 AND p.sysActive=1 AND NOT ISNULL(p.NomeProduto) ORDER BY p.NomeProduto")
while not prod.eof
    Responsavel = prod("Responsavel")&""
    TipoUnidade = prod("TipoUnidade")
    if instr(Responsavel, "_") then
        Responsavel = accountName(NULL, Responsavel)
    end if
    if TipoUnidade="C" then
        DescQuan = prod("ApresentacaoNome")
    else
        DescQuan = prod("Unidade")
    end if
    if instr(DescQuan&"", " - ") then
        DescQuan = right(DescQuan, len(DescQuan&"")-6)
    end if
    %>
    <tr>
        <td><%= prod("NomeProduto") %></td>
        <td><%= prod("Lote") %></td>
        <td><%= prod("Validade") %></td>
        <td><%= prod("CBID") %></td>
        <td><%= prod("NomeLocalizacao") %></td>
        <td><%= left(Responsavel, 15) %></td>
        <td class="text-right"><%= fn(prod("Quantidade")) %></td>
        <td><%= DescQuan %></td>
    </tr>
    <%
prod.movenext
wend
prod.close
set prod=nothing
%>
</table>