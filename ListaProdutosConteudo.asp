<!--#include file="connect.asp"-->



<div class="row">
    <div class="col-md-12">
        <table id="datatableProdutos" class="table table-striped table-bordered table-hover">
            <thead>
                <tr class="primary">
                    <th>Produto</th>
                    <th>Código</th>
                    <th>Categoria</th>
                    <th>Fabricante</th>
                    <th>Localização</th>
                    <th>Validade</th>
                    <th width="1%" class="hidden-print"></th>
                </tr>
            </thead>
            <%
            
            sqlAbaixo = ""
            Ordem = ref("Ordem")
            sqlOrdem = " pro.NomeProduto "
            if Ordem = "Validade" then
                sqlOrdem = " estpos.Validade "
            end if

            if ref("ProdutoID")<>0 then
                sqlProd = " AND pro.id="& ref("ProdutoID") &" "
            end if
            if ref("Codigo")<>"" then
                sqlCod = " AND pro.Codigo Like '%"& ref("Codigo") &"%' "
            end if
            if ref("CodigoIndividual")<>"" then
                sqlCodInd = " AND estpos.CBID Like '%"& ref("CodigoIndividual") &"%' "
            end if
            if ref("CategoriaID")<>0 then
                sqlCat = " AND pro.CategoriaID="& ref("CategoriaID") &" "
            end if
            if ref("FabricanteID")<>0 then
                sqlFab = " AND pro.FabricanteID="& ref("FabricanteID") &" "
            end if
            if ref("LocalizacaoID")<>0 then
                sqlLoc = " AND pro.LocalizacaoID="& ref("LocalizacaoID") &" "
            end if
            if ref("Ate")<>"" then
                ValidoAte = ref("Ate")
                sqlVal = " AND (estpos.Validade<= "& mydatenull(ValidoAte) &") AND estpos.Quantidade<>0 "
            end if
            sqlCampoValDe = " AND (Validade>= "& mydatenull(date()) &") AND Quantidade<>0 "
            if ref("De")<>"" then
                ValidoDe = ref("De")
                sqlValDe = " AND (estpos.Validade>= "& mydatenull(ValidoDe) &") AND estpos.Quantidade<>0 "
                sqlCampoValDe = " AND (Validade>= "& mydatenull(ValidoDe) &") AND Quantidade<>0 "
            end if

            if ref("AbaixoMinimo")="S" then
                sqlAbaixo = " AND (if(EstoqueMinimoTipo='U',((select sum(ep.Quantidade) from estoqueposicao ep where ep.ProdutoID = pro.id and ep.TipoUnidade='U' group by ep.ProdutoID)+ "&_
                            " (select sum(ep.Quantidade*pro.ApresentacaoQuantidade) from estoqueposicao ep where ep.ProdutoID = pro.id and ep.TipoUnidade='C' group by ep.ProdutoID)<EstoqueMinimo), "&_
                            " (select sum(ep.Quantidade) from estoqueposicao ep where ep.ProdutoID = pro.id and ep.TipoUnidade='C' group by ep.ProdutoID)<EstoqueMinimo) )"
            elseif ref("AbaixoMinimo")="N" then 
                sqlAbaixo = " AND ( (posicaoConjunto>=EstoqueMinimo) OR ( (posicaoUnidade+(posicaoConjunto*ApresentacaoQuantidade))>EstoqueMinimo) )"
            end if
'(select Validade from estoqueposicao where ProdutoID=pro.id AND Validade<now() ORDER BY Validade DESC LIMIT 1) Vencido, (select Validade from estoqueposicao where ProdutoID=pro.id "&sqlCampoValDe &" ORDER BY Validade LIMIT 1)

            set prod = db.execute("SELECT pro.*, estpos.id PosicaoID, procat.NomeCategoria, profab.NomeFabricante, estpos.Validade , proloc.NomeLocalizacao FROM produtos pro "&_
            "LEFT JOIN produtoscategorias procat ON procat.id=pro.CategoriaID "&_
            "LEFT JOIN produtosfabricantes profab ON profab.id=pro.FabricanteID "&_
            "LEFT JOIN produtoslocalizacoes proloc ON proloc.id=pro.LocalizacaoID "&_
            "LEFT JOIN estoqueposicao estpos ON estpos.ProdutoID=pro.id "&_
            "WHERE pro.sysActive=1 "& sqlProd & sqlCod & sqlCodInd & sqlCat & sqlFab & sqlLoc & sqlValDe & sqlVal & sqlAbaixo &" GROUP BY pro.id ORDER BY "&sqlOrdem)
            while not prod.EOF
                if prod("Validade")=<dateAdd("d", 10, date()) then
                    Validade = prod("Validade")
                    addClass = "label label-warning"
                    if prod("Validade")=<date() then
                        addClass = "label label-danger"
                    end if
                end if
                if prod("Validade")&""="" then
                    Validade = prod("Vencido")
                    addClass = "label label-danger"
                end if

            %>

                <tbody>
                <tr>
                    <td><%=prod("NomeProduto")%></td>
                    <td><%=prod("Codigo")%></td>
                    <td><%=prod("NomeCategoria")%></td>
                    <td><%=prod("NomeFabricante")%></td>
                    <td><%=prod("NomeLocalizacao")%></td>
                    <td><span class="<%=addClass%>"><%=Validade%></span></td>
                    <td class="hidden-print"><a class="btn btn-xs btn-success" target="_blank" href="./?P=Produtos&Pers=1&I=<%=prod("id")%>"><i class="fa fa-edit"></i></a></td>
                </tr>
                </tbody>
            <%
            prod.movenext
            wend
            prod.close
            set prod = nothing
            %>

        </table>
    </div>
</div>

