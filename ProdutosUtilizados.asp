<!--#include file="connect.asp"-->
<!--#include file="modalcontrato.asp"-->
<%
subTitulo = "Produtos Utilizados"

%>
<div class="panel timeline-add">
    <div class="panel-heading">
        <span class="panel-title"> <%=subTitulo %>
        </span>
    </div>

    <div class="panel">
        <div class="panel-body">
            <div class="col-md-1 col-md-offset-11">
                <button title="Lançamentos de estoque" onclick="modalEstoque(0, 0, 0)"  type="button" class="btn btn-alert btn-block btn-sm"><i class="far fa-medkit"></i></button>
            </div>
            <br>
            <%

            set produt = db.execute("SELECT el.*, p.NomeProduto, pc.NomeCategoria, p.ApresentacaoNome, SUBSTRING(uni.Descricao, 6) DescricaoUnidade  "&_
                                    "FROM estoquelancamentos el INNER JOIN produtos p ON p.id=el.ProdutoID LEFT JOIN produtoscategorias pc ON pc.id=p.CategoriaID LEFT JOIN cliniccentral.tissunidademedida uni ON uni.id=p.ApresentacaoUnidade "&_
                                    "WHERE el.EntSai='S' AND el.PacienteID="&PacienteID&" ORDER BY el.Data")
            if produt.eof then
                %>
                <div class="info text-center" style="padding: 10px">
                     Nenhum produto baixado para o paciente.
                </div>

                <%
            else
            %>

            <h3>Produtos baixados
            <button type="button" class="btn btn-xs btn-default far fa-level-down baixados"> esconder</button></h3>

            <table class="table table-hover table-bordered table-striped ">
                <thead>
                    <tr class="info">
                        <th width="1%"></th>
                        <th>Quant.</th>
                        <th>Produto</th>
                        <th>Tipo</th>
                        <th>Código</th>
                        <th>Categoria</th>
                        <th>Lote</th>
                        <th>Validade</th>
                        <th>Data da Saída</th>
                        <th>Observação</th>
                        <th>Usuário</th>
                    </tr>
                </thead>
                <tbody class="ProdutosBaixados">
                    <%
                    QuantTotal=0
                    while not produt.eof
                        TipoUnidade=""
                        if produt("TipoUnidade")="C" then
                            TipoUnidade = produt("ApresentacaoNome")
                        elseif produt("TipoUnidade")="U" then
                            TipoUnidade = produt("DescricaoUnidade")
                        end if
                        %>
                        <!--<tr>-->
                            <!--<th></th>-->
                            <!--<th colspan="10"><i>Atendimento</i></th>-->
                        <!--</tr>-->
                        <tr>
                            <td>
                                <a  href="./?P=Produtos&I=<%=produt("ProdutoID") %>&Pers=1" target="_blank"><button type="button" class="btn btn-xs btn-primary"><i class="far fa-external-link"></i></button></a>
                            </td>
                            <td class="text-right"><%=produt("Quantidade")%>x</td>
                            <td><%=produt("NomeProduto")%></td>
                            <td><%=TipoUnidade%></td>
                            <td><%=produt("CBID")%></td>
                            <td><%=produt("NomeCategoria")%></td>
                            <td><%=produt("Lote")%></td>
                            <td><%=produt("Validade")%></td>
                            <td><%=produt("Data")%></td>
                            <td><%=produt("Observacoes")%></td>
                            <td><%=nameInTable(produt("sysUser"))%></td>
                        </tr>
                        <%
                    QuantTotal = QuantTotal + 1
                    produt.movenext
                    wend
                    produt.close
                    set produt = nothing
                    %>
                    <tr>
                        <th colspan="3">Quantidade: <%=QuantTotal%></th>
                        <th colspan="9"></th>
                    </tr>
                </tbody>
            </table>
            <%
            end if
            set anexos = db.execute("(SELECT fi.id, ii.AtendimentoID,ii.ItemID ProdutoID, p.NomeProduto, p.Codigo, ii.Quantidade, ii.ValorUnitario, ii.Executado Medida, 'Particular' Forma, fi.sysDate Data "&_
                                     "FROM itensinvoice ii "&_
                                     "INNER JOIN sys_financialinvoices fi ON fi.id=ii.InvoiceID LEFT JOIN produtos p ON p.id=ii.ItemID "&_
                                     "WHERE fi.AssociationAccountID=3 AND ii.Tipo='M' AND fi.AccountID="&PacienteID&") "&_
                                     "UNION ALL "&_
                                     "(SELECT gs.id, gs.AtendimentoID,ga.ProdutoID, p.NomeProduto, ga.CodigoProduto Codigo, ga.Quantidade, ga.ValorUnitario , 'U' Medida, c.NomeConvenio Forma, ga.Data "&_
                                     "FROM tissguiasadt gs "&_
                                     "LEFT JOIN tissguiaanexa ga ON ga.GuiaID=gs.id LEFT JOIN convenios c ON c.id=gs.ConvenioID LEFT JOIN produtos p ON p.id=ga.ProdutoID "&_
                                     "WHERE gs.PacienteID="&PacienteID&")")
            if anexos.eof then
                %>
                <div class="info text-center" style="padding: 10px">
                     Nenhum produto baixado para o paciente.
                </div>

                <%
            else
            %>
            <br>
            <br>
            <br>
            <h3>Produtos não lançados
            <button type="button" class="btn btn-xs btn-default far fa-level-down naobaixados"> esconder</button></h3>

            <table class="table table-hover table-bordered table-striped">
                <thead>
                    <tr class="warning">
                        <th width="1%"></th>
                        <th>Quant.</th>
                        <th>Produto</th>
                        <th>Tipo</th>
                        <th>Código</th>
                        <th>Forma</th>
                        <th>Valor</th>
                        <th>Data</th>
                        <th width="5%"></th>

                    </tr>
                </thead>
                <tbody class="ProdutosNaoLancado">
                    <%
                    QuantTotal=0
                    while not anexos.eof
                        TipoUnidade=""
                        if anexos("Medida")="C" then
                            TipoUnidade = "Conjunto"
                        elseif anexos("Medida")="U" then
                            TipoUnidade = "Unidade"
                        end if
                        if anexos("Forma")="Particular" then
                            link = "./?P=invoice&I="&anexos("id")&"&A=&Pers=1&T=C"
                        else
                            link = "./?P=tissguiasadt&I="&anexos("id")&"&Pers=1"
                        end if

                        %>
                        <!--<tr>-->
                            <!--<th></th>-->
                            <!--<th colspan="10"><i>Atendimento</i></th>-->
                        <!--</tr>-->
                        <tr>
                            <td>
                                <a  href="<%=link%>" target="_blank"><button type="button" class="btn btn-xs btn-primary"><i class="far fa-external-link"></i></button></a>
                            </td>
                            <td class="text-right"><%=anexos("Quantidade")%>x</td>
                            <td><%=anexos("NomeProduto")%></td>
                            <td><%=TipoUnidade%></td>
                            <td><%=anexos("Codigo")%></td>
                            <td><%=anexos("Forma")%></td>
                            <td><%=formatnumber(anexos("ValorUnitario"),2)%></td>
                            <td><%=anexos("Data")%></td>
                            <td>
                                <button type="button" class="btn btn-xs btn-success" onclick="modalEstoque('', <%=anexos("ProdutoID")%>, <%=anexos("ProdutoID")%>)"><i class="far fa-level-up"></i> Lançar</button>
                            </td>

                        </tr>
                        <%
                        QuantTotal = QuantTotal + 1
                        anexos.movenext
                    wend
                    anexos.close
                    set anexos = nothing
                    %>
                    <tr>
                        <th colspan="3">Quantidade: <%=QuantTotal%></th>
                        <th colspan="6"></th>
                    </tr>
                </tbody>
            </table>
            <%
            end if
            %>
        </div>
    </div>
</div>

<script>

function modalEstoque(ItemInvoiceID, ProdutoID, ProdutoInvoiceID){
    $("#modal-table").modal("show");
    $.get("invoiceEstoque.asp?CD=<%=CD%>&I="+ ProdutoID +"&ItemInvoiceID="+ ItemInvoiceID + "&ProdutoInvoiceID=" + ProdutoInvoiceID, function (data) {
        $("#modal").html( data );
    });
}

$(".baixados").click(function(){
    $(".ProdutosBaixados").addClass("hidden");
    $(".baixados").addClass("disabled");
});

$(".naobaixados").click(function(){
    $(".ProdutosNaoLancado").addClass("hidden");
    $(".naobaixados").addClass("disabled");
});
</script>