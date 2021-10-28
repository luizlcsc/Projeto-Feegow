<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->

<%
ConvenioID = req("ConvenioID")
Page       = req("Page")&""
OnlyTable  = req("OnlyTable")

if ConvenioID = "" then
    response.write("Parâmetro ConvenioID não informado")
    response.status = 400
    response.end
end if

if Page = "" then
    Page = 1
    session("conveniosValoresDespesasBusca")  = null
    session("conveniosValoresDespesasTabela") = null
    session("conveniosValoresDespesasTipo")   = null
    session("conveniosValoresDespesasForma")  = null
else
    Page = CInt(Page)
end if


if ref("filter") = "1" then
    session("conveniosValoresDespesasBusca")  = ref("filter-busca")
    session("conveniosValoresDespesasTabela") = ref("filter-tabela")
    session("conveniosValoresDespesasTipo")   = ref("filter-tipo")
    session("conveniosValoresDespesasForma")  = ref("filter-forma")
end if
filterBusca  = session("conveniosValoresDespesasBusca")
filterTabela = session("conveniosValoresDespesasTabela")
filterTipo   = session("conveniosValoresDespesasTipo")
filterForma  = session("conveniosValoresDespesasForma")


sqlItensWhere = ""
if filterBusca <> "" then
    sqlItensWhere = sqlItensWhere & " AND (p.NomeProduto LIKE '%" & filterBusca & "%' OR " &_
                  " tpt.Codigo LIKE '%" & filterBusca & "%')"
end if
if filterTabela <> "" then
    sqlItensWhere = sqlItensWhere & " AND (tpt.TabelaID =  '" & filterTabela & "')"
end if
if filterTipo <> "" then
    sqlItensWhere = sqlItensWhere & " AND (cd.id =  '" & filterTipo & "')"
end if
if filterForma <> "" then
    sqlItensWhere = sqlItensWhere & " AND (tpv.FormaCobranca =  '" & filterForma & "')"
end if

sqlCountGuias = "SELECT COUNT(DISTINCT g.id)  FROM tissguiasadt g " &_
                "INNER JOIN tissguiaanexa ga ON ga.GuiaID = g.id " &_
                "LEFT JOIN tisslotes l ON g.LoteID = l.id " &_
                "WHERE g.sysActive = 1 AND g.ConvenioID = '" & ConvenioID & "'" &_
                "AND ga.ProdutoID = p.id AND ga.TabelaProdutoID = tpt.TabelaID " &_
                "AND (l.Enviado IS NULL OR l.Enviado = 0)"

sqlItens = "SELECT tpv.id, tpt.id AS ProdutoTabelaID, p.id as ProdutoID, p.NomeProduto, tpt.TabelaID, " &_
           "tab.descricao AS Tabela, tpt.Codigo, tpv.Descricao, cd.Descricao AS CD, tpv.Valor, tpv.NaoCobre, " &_
           "COALESCE(tpv.ConvenioID, '" & ConvenioID & "') AS ConvenioID, tpv.FormaCobranca, " &_
           "(" & sqlCountGuias & ") as QtdGuias " &_
           "FROM produtos p " &_
           "LEFT JOIN cliniccentral.tisscd cd ON cd.id = p.CD " &_
           "LEFT JOIN tissprodutostabela tpt ON tpt.ProdutoID = p.id AND tpt.sysActive = 1 " &_
           "LEFT JOIN tissprodutosvalores tpv ON tpv.ProdutoTabelaID = tpt.id AND tpv.ConvenioID = '" & ConvenioID & "'" &_
           "LEFT JOIN cliniccentral.tabelasprocedimentos tab ON tab.id = tpt.TabelaID " &_
           "WHERE p.sysActive = 1 " & sqlItensWhere & " " &_
           "GROUP BY p.id, tpt.id "

set resCountItens = db.execute("SELECT COUNT(*) as count FROM (" & sqlItens & ") t")

limitPerPage   = 50
itensCount     = CInt(resCountItens("count"))
totalPages     = itensCount / limitPerPage
if Int(totalPages) <> totalPages then
    totalPages = Int(totalPages) + 1
else
    totalPages = Int(totalPages)
end if

offSet = (Page - 1) * limitPerPage

set resItens = db.execute(sqlItens & " ORDER BY p.NomeProduto, tpt.id LIMIT " & limitPerPage & " OFFSET " & offSet)

resJson = recordToJSON(resItens)
if not resItens.bof then
    resItens.movefirst
end if

%>

<% if OnlyTable = "" then %>

<style>
    #convenios-valores-despesas header {
        border-bottom: 1px solid #ebebeb;
        margin-bottom: 15px;
    }

    #convenios-valores-despesas input[type='checkbox'].form-control {
        height: 1.2em;
    }

</style>

<section id="convenios-valores-despesas">

    <header class="filters">
        <form id="convenios-valores-despesas-filters">
            <input type="hidden" name="filter" value="1">
            <div class="row">
                <div class="col-md-5">
                    <div class="form-group">
                        <label for="filter-busca">Busca rápida de item</label>
                        <input id="filter-busca" name="filter-busca" class="form-control" type="text" value="<%=filterBusca%>" placeholder="Digite o nome, código ou descrição do item..."/>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="form-group">
                        <label for="filter-tabela">Tabela</label>
                        <%= quickfield("simpleSelect", "filter-tabela", "", 3, filterTabela, "select id, descricao from cliniccentral.tabelasprocedimentos where (Despesa=1 or Despesa is null) and Ativo='S'", "descricao", " no-select2 empty ") %>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="form-group">
                        <label for="filter-tipo">Tipo (CD)</label>
                        <%= quickfield("simpleSelect", "filter-tipo", "", 3, filterTipo, "select id, descricao from cliniccentral.tisscd", "descricao", " no-select2 empty ") %>
                    </div>
                </div>

                <div class="col-md-1">
                    <button class="btn btn-primary pull-right" type="submit" style="margin-top: 22px">Filtrar</button>
                </div>
            </div>

            <div class="row">
                <div class="col-md-3">
                    <div class="form-group">
                        <label for="filter-forma">Forma de cobrança do item</label>
                        <select id="filter-forma" name="filter-forma" class="form-control">
                            <option value="">Selecione</option>
                            <option value="U">Unidade</option>
                            <option value="C">Conjunto</option>
                        </select>
                    </div>
                </div>

                <div class="col-md-offset-7 col-md-2">
                    <button class="btn btn-sm btn-success pull-right" type="button" style="margin-top: 22px"
                        onclick="conveniosValoresDespesas.atualizarGuias()">
                        Atualizar as guias
                    </button>
                </div>
            </div>
        </form>
    </header>
    <main>
<% end if %>

        <div class="row">
            <div class="col-md-12" id="convenios-valores-despesas-list">
                <table class="table table-striped table-bordered table-hover">
                    <thead>
                        <tr class="info">
                            <th><input id="check-all" type="checkbox" aria-label="Marcar todos"></th>
                            <th>Item</th>
                            <th>Tabela</th>
                            <th>Código</th>
                            <th>Descrição</th>
                            <th>Tipo (CD)</th>
                            <th>Valor Unitário</th>
                            <th>Forma de cobrança</th>
                            <th>Qtd. guias</th>
                            <th>Não cobre</th>
                            <th style="min-width: 70px">&nbsp;</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if resItens.eof then %>
                        <tr>
                            <td colspan="11">Nenhum item encontrado.</td>
                        </tr>
                        <%
                        end if
                        index = 0
                        while not resItens.eof
                        %>
                        <tr>
                            <td><input type="checkbox" class="check-item" aria-label="Marcar" data-index="<%=index%>"></td>
                            <td><%=resItens("NomeProduto")%></td>
                            <td><%=resItens("Tabela")%></td>
                            <td><%=resItens("Codigo")%></td>
                            <td><%=resItens("Descricao")%></td>
                            <td><%=resItens("CD")%></td>
                            <td class="text-right">
                            <%
                                if not isNull(resItens("Valor")) then
                                    response.write(formatnumber(resItens("Valor"), 2))
                                end if
                            %>
                            </td>
                            <td>
                                <%
                                    Select Case resItens("FormaCobranca")
                                        Case "U":
                                            Response.Write("Unidade")
                                        Case "C":
                                            Response.Write("Conjunto")
                                        Case Else
                                            Response.Write("&nbsp;")
                                    End Select
                                %>
                            </td>
                            <td class="text-right"><%=resItens("QtdGuias")%></td>
                            <td class="text-center">
                                <% if resItens("NaoCobre") = "1" then%>
                                    <i class="far fa-ban text-danger"></i>
                                <% end if %>
                            </td>
                            <td>
                                <button type="button" class="btn btn-xs btn-info btn-edit" title="Editar" data-toggle="tooltip"
                                    onclick="conveniosValoresDespesas.openModal(<%=index%>)">
                                    <i class="far fa-edit"></i>
                                </button>
                                <button type="button" class="btn btn-xs btn-danger btn-naocobre" title="Não cobre"
                                    data-toggle="tooltip" onclick="conveniosValoresDespesas.updateNaoCobre(<%=index%>)">
                                    <i class="far fa-remove"></i>
                                </button>
                            </td>
                        </tr>
                        <%
                        index = index + 1
                        resItens.movenext
                        wend
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <nav>
            <div class="text-center">
                <ul class="pagination pagination-sm">
                    <%
                    for iPage = 1 to totalPages
                    %>
                        <li class="page-item <%if Page = iPage then response.write("active") end if%>">
                            <a class="page-link" href="#" onclick="conveniosValoresDespesas.buscar(<%=iPage%>)"><%=iPage%></a>
                        </li>
                    <% next %>
                </ul>
            </div>
        </nav>

        <script>
            var conveniosValoresJson = <%=resJson%>;
        </script>

<% if OnlyTable = "" then %>
    </main>

    <div id="convenios-valores-despesas-modal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <form>

                    <input type="hidden" id="modal-input-id" name="id">
                    <input type="hidden" id="modal-input-convenio-id" name="ConvenioID" value="<%=ConvenioID%>">
                    <input type="hidden" id="modal-input-produto-id" name="ProdutoID">
                    <input type="hidden" id="modal-input-produto-tabela-id" name="ProdutoTabelaID">

                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <h4 class="modal-title">Edição da despesa</h4>
                    </div>
                    <div class="modal-body">
                        <p class="item-title">Item: <span>XXXXX</span></p>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="TabelaID">Tabela</label>
                                    <%= quickfield("simpleSelect", "TabelaID", "", 3, "", "select id, descricao from cliniccentral.tabelasprocedimentos where (Despesa=1 or Despesa is null) and Ativo='S'", "descricao", " no-select2 empty required ") %>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="Codigo">Código</label>
                                    <%=selectProc("", "Codigo", "", "Codigo", "TabelaID", "Codigo", "modal-input-descricao", " required data-produto ", "CD", "ApresentacaoUnidade", "Valor") %>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="modal-input-forma">Forma de Cobrança</label>
                                    <select id="modal-input-forma" name="FormaCobranca" class="form-control" required>
                                        <option value="">Selecione</option>
                                        <option value="U">Unidade</option>
                                        <option value="C">Conjunto</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-8">
                                <div class="form-group">
                                    <label for="modal-input-descricao">Descrição</label>
                                    <input id="modal-input-descricao" name="Descricao" type="text" class="form-control" required>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="modal-input-valor">Valor</label>
                                    <div class="input-group">
                                        <span class="input-group-addon"><strong>R$</strong></span>
                                        <input id="modal-input-valor" name="Valor" type="text" class="form-control text-right input-mask-brl" required>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <label for="modal-input-naocobre">Não Cobre</label>
                                <div class="mn">
                                    <div class="switch switch-danger switch-inline">
                                        <input checked="checked" name="NaoCobre" id="modal-input-naocobre" type="checkbox" value="1" />
                                        <label class="mn" for="modal-input-naocobre"></label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary">Salvar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>

        var conveniosValoresDespesas = (function() {

            const elModal       = $('#convenios-valores-despesas-modal');
            const elFiltersForm = $('#convenios-valores-despesas-filters');

            function init() {

                elFiltersForm.on('submit', function(event) {
                    event.preventDefault();
                    buscar(1, $(this).serialize());
                });

                elModal.find('.input-mask-brl').maskMoney({prefix: '', thousands: '.', decimal: ',', affixesStay: true});
                elModal.find('form')
                    .on('submit', function(event) {
                        event.preventDefault();
                        save();
                    })
                    .on('keydown', function(ev) {
                        return ev.key !== "Enter";
                    });

                elModal.find('#modal-input-naocobre').on('change', function() {
                    if ($(this).is(':checked')) {
                        elModal.find('#modal-input-forma, #modal-input-descricao, #modal-input-valor').prop('required', '');
                    } else {
                        elModal.find('#modal-input-forma, #modal-input-descricao, #modal-input-valor').prop('required', 'required');
                    }
                });

                $('[data-toggle="tooltip"]').tooltip();
                bindCheckboxesEvents();
            }

            function bindCheckboxesEvents() {
                const elCheckAll    = $('#check-all');
                const elCheckItens  = $('.check-item');
                elCheckAll.on('click', function () {
                    elCheckItens.prop('checked', $(this).prop('checked'));
                });

                elCheckItens.on('click', function () {
                    let haveUncheck = false;
                    elCheckItens.each(function() {
                        if (!$(this).prop('checked')) {
                            haveUncheck = true;
                            return false;
                        }
                    });
                    elCheckAll.prop('checked', !haveUncheck);
                });
            }

            function buscar(page, filters) {
                if (!page) {
                    page = 1;
                }
                $.post('ConveniosValoresDespesas.asp?ConvenioID=<%=ConvenioID%>&Page=' + page + '&OnlyTable=1',filters,
                    function(result) {
                        $('#convenios-valores-despesas main').html(result);
                        bindCheckboxesEvents();
                        $('[data-toggle="tooltip"]').tooltip();
                    }
                );
            }

            function openModal(index) {
                const item = conveniosValoresJson[index];

                const valor = item.Valor ? parseFloat(item.Valor.replace(',', '.'))
                    .toFixed(2)
                    .replace('.', ',')
                    .replace(/\B(?=(\d{3})+(?!\d))/g, '.') : '';

                elModal.find('#modal-input-id').val(item.id);
                elModal.find('#modal-input-produto-id').val(item.ProdutoID);
                elModal.find('#modal-input-produto-tabela-id').val(item.ProdutoTabelaID);

                elModal.find('.item-title span').html(item.NomeProduto);
                elModal.find('#TabelaID').val(item.TabelaID);
                elModal.find('#Codigo').val(item.Codigo);
                elModal.find('#modal-input-forma').val(item.FormaCobranca);
                elModal.find('#modal-input-descricao').val(item.Descricao);
                elModal.find('#modal-input-valor').val(valor);
                if (item.NaoCobre === "1" || item.NaoCobre === 1) {
                    elModal.find('#modal-input-naocobre').prop('checked', 'checked').trigger('change');
                } else {
                    elModal.find('#modal-input-naocobre').prop('checked', '').trigger('change');
                }

                enableForm();

                elModal.modal({backdrop: 'static', keyboard: false});
            }

            function disableForm() {
                elModal.find('input, select, button').prop('disabled', 'disabled');
            }

            function enableForm() {
                elModal.find('input, select, button').prop('disabled', '');
            }

            function save() {
                const dados = elModal.find('form').serialize();

                disableForm();
                $.post('ConveniosValoresDespesasSave.asp', dados, function() {
                    elModal.modal('hide');
                    buscar();
                    new PNotify({
                    title: 'Salvo com sucesso',
                    sticky: true,
                    type: 'success',
                    delay: 1000
                });
                }).fail(function() {
                    enableForm();
                    new PNotify({
                        title: 'Não foi possível salvar.',
                        text: 'Tente novamente mais tarde',
                        sticky: true,
                        type: 'danger',
                        delay: 1000
                    });

                });
            }

            function updateNaoCobre(index) {
                const item = conveniosValoresJson[index];

                if (item.ProdutoTabelaID === '') {
                    alert('Associe o produto a uma tabela.');
                    openModal(index);
                    return;
                }

                if (item.NaoCobre === "1") {
                    alert("O item já está inativo para este convênio. Clique em Editar caso queira alterar.");
                    return;
                }

                $.post('ConveniosValoresDespesasSave.asp', {...item, ...{NaoCobre: 1}}, function() {
                    buscar();
                    new PNotify({
                        title: 'Salvo com sucesso',
                        sticky: true,
                        type: 'success',
                        delay: 1000
                    });
                }).fail(function() {
                    new PNotify({
                        title: 'Não foi possível salvar.',
                        text: 'Tente novamente mais tarde',
                        sticky: true,
                        type: 'danger',
                        delay: 1000
                    });

                });
            }

            function atualizarGuias() {
                const checkedItens = $('.check-item:checked');
                if (checkedItens.length === 0) {
                    alert('Selecione os itens para atualizar.');
                    return;
                }

                const formData = new URLSearchParams();
                formData.append('ConvenioID', <%=ConvenioID%>);

                checkedItens.each(function() {
                    const item = conveniosValoresJson[$(this).data('index')];
                    if (item.id) {
                        formData.append('ids', item.id);
                    }
                });

                $.ajax('ConveniosValoresDespesasUpdateGuias.asp', {
                    method: 'POST',
                    data: formData,
                    processData: false
                }).success(function(response) {
                    new PNotify({
                        title: 'Salvo com sucesso',
                        text: response,
                        sticky: true,
                        type: 'success',
                        delay: 3000
                    });
                }).fail(function(response) {
                    if (response.status === 422) {
                        new PNotify({
                            title: 'Não foi possível salvar.',
                            text: response.responseText,
                            sticky: true,
                            type: 'danger',
                            delay: 3000
                        });
                    } else {
                        new PNotify({
                            title: 'Não foi possível salvar.',
                            text: 'Tente novamente mais tarde',
                            sticky: true,
                            type: 'danger',
                            delay: 1000
                        });
                    }

                });

            }

            this.buscar         = buscar;
            this.openModal      = openModal;
            this.atualizarGuias = atualizarGuias;
            this.updateNaoCobre = updateNaoCobre;

            init();

            return this;
        }());
    </script>
</section>
<% end if %>