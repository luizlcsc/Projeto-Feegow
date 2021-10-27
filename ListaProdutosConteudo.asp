<!--#include file="connect.asp"-->
<% TipoProduto = ref("TipoProduto")%>

<% if TipoProduto = "5, 5" then %>
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
                    <tr>
                        <td><a href="./?P=Produtos&Pers=1&I=<%=prod("id")%>"><%=prod("NomeProduto")%></a></td>
                        <td class="hidden-print" title="<%=title%>">
                            <a class="btn btn-xs btn-primary" href="./?P=Produtos&Pers=1&I=<%=prod("id")%>"><i class="far fa-edit"></i></a>
                            <%
                            if aut("|produtosX|")=1 then
                            %>
                            <button class="btn btn-xs btn-danger <%=disabled%>" onClick="removeItem(<%=prod("id")%>)"><i class="far fa-remove"></i></button>
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
<% else %>
<div class="row">
    <div class="col-md-12">
        <span>Legenda: </span>
        <span class="label label-danger">Fora da validade</span>
        <span class="label label-warning">Proximo do vencimento</span>
        <span class="label label-info">Dentro do prazo</span>
    </div>
</div>
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
                    <th width="1%" class="hidden-print"></th>
                </tr>
            </thead>
            <%
            
            sqlAbaixo = ""
            Ordem = ref("Ordem")
            sqlOrdem = " NomeProduto "
            if Ordem = "Validade" then
                sqlOrdem = " Validade "
            end if

            if ref("ProdutoID")<>0 then
                sqlProd = " AND pro.id="& ref("ProdutoID") &" "
            end if
            if ref("TipoProduto")&""<>"" and ref("TipoProduto")<>"1" then
                TipoProdutoRef = split(ref("TipoProduto")&"", ", ")
                sqlTipoProduto = " AND pro.TipoProduto="& TipoProdutoRef(0)
            end if
            if ref("Codigo")<>"" then
                sqlCod = " AND pro.Codigo Like '%"& ref("Codigo") &"%' "
            end if
            if ref("PrincipioAtivo")<>"" and ref("TipoProduto")="4" then
                sqlPrincipioAtivo = " AND pro.PrincipioAtivo="& ref("PrincipioAtivo") &" "
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
                sqlVal = " AND (estpos.Validade<= "& mydatenull(ValidoAte) &") AND estpos.Quantidade>0 "
            end if
            sqlCampoValDe = " AND (Validade>= "& mydatenull(date()) &") AND Quantidade>0 "
            if ref("De")<>"" then
                ValidoDe = ref("De")
                sqlValDe = " AND (estpos.Validade>= "& mydatenull(ValidoDe) &") AND estpos.Quantidade>0 "
                sqlCampoValDe = " AND (Validade>= "& mydatenull(ValidoDe) &") AND Quantidade>0 "
            end if

            if ref("praVencer") <>"" then
                sqlsomentePraVencer = " AND Validade IS NOT NULL AND quantidade > 0 "
                sqlHavingSomentePraVencer = " AND  datediff(curdate(), Validade) < 60"

                sqlOrdem="Validade"
            end if

            if ref("AbaixoMinimo")="S" then
                sqlAbaixo = " AND (if(EstoqueMinimoTipo='U',((select sum(ep.Quantidade) from estoqueposicao ep where ep.ProdutoID = pro.id and ep.TipoUnidade='U' group by ep.ProdutoID)+  IFNULL((select sum(ep.Quantidade*pro.ApresentacaoQuantidade) from estoqueposicao ep where ep.ProdutoID = pro.id and ep.TipoUnidade='C' group by ep.ProdutoID),0) < EstoqueMinimo),  (select sum(ep.Quantidade) from estoqueposicao ep where ep.ProdutoID = pro.id and ep.TipoUnidade='C' group by ep.ProdutoID) < EstoqueMinimo) )"

            elseif ref("AbaixoMinimo")="N" then 
                sqlAbaixo = " AND ( (posicaoConjunto>=EstoqueMinimo) OR ( (posicaoUnidade+(posicaoConjunto*ApresentacaoQuantidade)) > EstoqueMinimo) )"
            end if
'(select Validade from estoqueposicao where ProdutoID=pro.id AND Validade<now() ORDER BY Validade DESC LIMIT 1) Vencido, (select Validade from estoqueposicao where ProdutoID=pro.id "&sqlCampoValDe &" ORDER BY Validade LIMIT 1)
            sqlstring = ("SELECT pro.*, (select Validade from estoqueposicao where ProdutoID=pro.id AND Validade < now() AND Quantidade > 0 ORDER BY Validade DESC LIMIT 1) Vencido, (select Validade from estoqueposicao where ProdutoID=pro.id "&sqlCampoValDe &" ORDER BY Validade LIMIT 1) Validade, "&_
             "(SELECT ifnull(DiasVencimentoProduto, 5) DiasVencimentoProduto FROM sys_config LIMIT 1) DiasAvisoValidadeGeral FROM ("&_
            " SELECT pro.*, estpos.id PosicaoID, procat.NomeCategoria, profab.NomeFabricante,proloc.NomeLocalizacao "&_
            "FROM produtos pro "&_
            "LEFT JOIN produtoscategorias procat ON procat.id=pro.CategoriaID "&_
            "LEFT JOIN produtosfabricantes profab ON profab.id=pro.FabricanteID "&_
            "LEFT JOIN produtoslocalizacoes proloc ON proloc.id=pro.LocalizacaoID "&_
            "LEFT JOIN estoqueposicao estpos ON estpos.ProdutoID=pro.id "&_
            "WHERE pro.sysActive = 1 "& sqlsomentePraVencer & sqlProd & sqlTipoProduto & sqlPrincipioAtivo & sqlCod & sqlCodInd & sqlCat & sqlFab & sqlLoc & sqlValDe & sqlVal & sqlAbaixo &""&_
            " "&sqlHavingSomentePraVencer&" "&_
            "GROUP BY pro.id "&_
            ") pro "&_
            "ORDER BY "&sqlOrdem)


            set prod = db.execute(sqlstring)
            while not prod.EOF
                Validade = prod("Validade")
                disabled = ""
                title = ""
                addClass="label label-info"
                DiasAvisoValidade = prod("DiasAvisoValidade")
                if prod("DiasAvisoValidade")&"" = "" then
                    DiasAvisoValidade = prod("DiasAvisoValidadeGeral")
                end if

                if prod("Validade")&"" <>"" then
                    'if prod("Validade") =< dateAdd("d", DiasAvisoValidade, date()) then
                    diferenca = dateDiff("d",date(),prod("Validade"))
                    if (diferenca >= 0 and diferenca <= Cint(DiasAvisoValidade)) then
                        Validade = prod("Validade")&""
                        addClass = "label label-warning"
                        if prod("Validade") =< date() then
                            addClass = "label label-danger"
                        end if
                    end if
                  
                end if
                if Validade&""="" then
                    Validade = prod("Vencido")
                    addClass = "label label-danger"
                end if

                if prod("PosicaoID")&""<>"" then
                    disabled = " disabled "
                    title = "Esse item possui movimentação."
                end if
            %>

                <tbody>
                <tr id="linha<%=prod("id")%>">
                    <td><%=prod("NomeProduto")%></td>
                    <td><%=prod("Codigo")%></td>
                    <td><%=prod("NomeCategoria")%></td>
                    <td><%=prod("NomeFabricante")%></td>
                    <td><%=prod("NomeLocalizacao")%></td>
                    <td><span class="<%=addClass%>"><%=Validade%></span></td>
                    <td class="hidden-print"><a class="btn btn-xs btn-primary" href="./?P=Produtos&Pers=1&I=<%=prod("id")%>"><i class="far fa-edit"></i></a></td>
                    <td class="hidden-print" title="<%=title%>">
                        <%
                        if aut("|produtosX|")=1 then
                        %>
                        <button class="btn btn-xs btn-danger <%=disabled%>" onClick="removeItem(<%=prod("id")%>)"><i class="far fa-remove"></i></button>
                        <%
                        end if
                        %>
                    </td>
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
<% end if %>

<script>
function removeItem(ID){
    $.get("ListaProdutos.asp?ItemID="+ID+"&Acao=X",
        $(this).serialize(),
        function (data) {

        }).done(function (){
           location.reload();
        });
}
</script>