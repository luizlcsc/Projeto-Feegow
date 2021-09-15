<!--#include file="connect.asp"-->

<style type="text/css">
    .vt {
        vertical-align:top!important;
    }
</style>

<script type="text/javascript">
    $(".crumb-active a").html("Valores de Itens");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("valores padrão dos itens na tabela");
    $(".crumb-icon a span").attr("class", "far fa-usd");
</script>
<form id="frmVI" method="post">
    <input type="hidden" name="E" value="E" />
    <div class="panel mt15">
        <div class="panel-heading">
            <span class="panel-controls hidden pnsub">
                <button type="submit" class="btn btn-sm btn-primary"><i class="far fa-save"></i> Salvar</button>
                <button type="button" class="btn btn-sm btn-success" onclick="ipt()" ><i class="far fa-plus"></i> Adicionar</button>
                <button type="button" class="btn btn-sm btn-danger" onclick="xpt()"><i class="far fa-times"></i> Excluir</button>
            </span>
        </div>
        <div class="panel-body">
            <%= quickfield("simpleSelect", "fcd", "Filtrar por CD", 2, "", "select id, descricao from cliniccentral.tisscd", "descricao", " no-select2 onchange=""filterAll()"" empty ") %>
            <div class="col-md-3">
                <%= selectInsert("Item", "fitem", "", "produtos", "NomeProduto", " onchange=""filterAll()""", "", "") %>
            </div>
            <%= quickfield("simpleSelect", "ftabela", "Tabela", 2, "", "select id, concat(descricao,' (',codigo,')')descricao from cliniccentral.tabelasprocedimentos where (Despesa=1 or Despesa is null) and Ativo='S'", "descricao", " no-select2 onchange=""filterAll()"" empty ") %>
            <%= quickfield("simpleSelect", "fconvenio", "Convênio", 2, "", "select id, NomeConvenio from convenios where sysActive = 1 order by NomeConvenio", "NomeConvenio", " no-select2 onchange=""filterAll()"" empty ") %>
            <div class="col-md-2" style="padding-top: 27px">
                <button type="button" class="btn btn-sm btn-primary" onclick="filterAll()">Filtrar</button>
                <button type="button" class="btn btn-sm btn-default" onclick="clearFilters()">Limpar</button>
            </div>
        </div>
        <div class="panel-body">
            <table class="table table-bordered table-condensed table-striped table-hover">
                <thead>
                    <tr class="info">
                        <th width="1%">
                            <span class="checkbox-custom" style="position:relative; bottom:10px">
                                <input type="checkbox"  id="checkall" onclick="$('input[name=pt]').prop('checked', $(this).prop('checked'))" /><label for="checkall"></label>
                            </span>
                        </th>
                        <th width="15%">Tabela</th>
                        <th width="25%">Item</th>
                        <th width="15%">Código</th>
                        <th width="15%">CD</th>
                        <th width="15%">Un. Medida</th>
                        <th width="15%">Valor Unitário</th>
                    </tr>
                </thead>
                <tbody>
                <%

    db.execute("UPDATE tissprodutosprocedimentos pp set pp.ProdutoTabelaID=(select ProdutoTabelaID from tissprodutosvalores where id=pp.ProdutoValorID) where isnull(pp.ProdutoTabelaID)")

                response.Buffer

                set pt = db.execute("select pt.*, p.NomeProduto, p.CD, p.ApresentacaoUnidade from tissprodutostabela pt left join produtos p on p.id=pt.ProdutoID where pt.sysActive=1 order by p.NomeProduto")
                while not pt.eof
                    response.flush()

                    if ref("E")="E" then
                    else
                        btnAddVP = "<div id='btn[PTID]' class='btn-group'><button type='button' class='btn btn-xs btn-default dropdown-toggle mt10 mb10' data-toggle='dropdown' aria-expanded='false'><i class='far fa-plus'></i> Exceção por convênio<span class='caret ml5'></span></button><ul class='dropdown-menu' role='menu'>"
                        set convs = db.execute("select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio")
                        while not convs.eof
                            btnAddVP = btnAddVP & "<li><a href='javascript:apv([PTID], "& convs("id") &")'>"& convs("NomeConvenio") &"</a></li>"
                        convs.movenext
                        wend
                        convs.close
                        set convs=nothing

                        btnAddVP = btnAddVP & "</ul></div>"

                   ' db.execute("update tissprodutostabela set idUnico="& pt("id") &" where Codigo='"&pt("Codigo")&"' and ProdutoID="& pt("ProdutoID")&" and TabelaID="& pt("TabelaID") &"")
                    %>
                    <tr class="<%= classeHidden %> litem">
                        <td class="vt" width="1%">
                            <span class="checkbox-custom checkbox-light" style="position:relative; bottom:10px">
                                <input type="checkbox" name="pt" id="pt<%= pt("id") %>" value="<%= pt("id") %>" /><label for="pt<%= pt("id") %>"></label>
                            </span>
                        </td>
                        <td class="vt" width="15%"><%= quickfield("simpleSelect", "TabelaID"& pt("id"), "", 12, pt("TabelaID"), "select id, concat(descricao,' (',codigo,')')descricao from cliniccentral.tabelasprocedimentos where (Despesa=1 or Despesa is null) and Ativo='S'", "descricao", " no-select2 onchange=""altG('TabelaID', $(this).val())"" ") %></td>
                        <td class="vt" width="25%"><%= selectInsert("", "ProdutoID"& pt("id"), pt("ProdutoID"), "produtos", "NomeProduto", "", "", "") %></td>
                        <td class="vt" width="15%"><%=selectProc("", "Codigo"& pt("id"), pt("Codigo"), "codigo", "TabelaID"& pt("id"), "Codigo"& pt("id"), "ProdutoID"& pt("id"), " required='required' produto ", "CD"& pt("id"), "ApresentacaoUnidade"& pt("id"), "Valor"& pt("id")) %></td>
                        <td class="vt" width="15%"><%= quickfield("simpleSelect", "CD"& pt("id"), "", 12, pt("CD"), "select id, descricao from cliniccentral.tisscd", "descricao", " no-select2 onchange=""altG('CD', $(this).val())"" ") %></td>
                        <td class="vt" width="15%"><%= quickfield("simpleSelect", "ApresentacaoUnidade"& pt("id"), "", 12, pt("ApresentacaoUnidade"), "select id, descricao from cliniccentral.tissunidademedida", "descricao", " no-select2 onchange=""altG('ApresentacaoUnidade', $(this).val())"" ") %></td>
                        <td class="vt" width="15%"><%= quickfield("currency", "Valor"& pt("id"), "", 12, pt("Valor"), "", "", " onKeyup=""altG('Valor', $(this).val())"" ") %>

                            <%= replace(btnAddVP, "[PTID]", pt("id")) %>
                            <div class="produtos-valores">
                        <%
                        sqlDel = "delete from tissprodutosvalores where ProdutoTabelaID="& pt("id") &" and Valor like "& treatvalzero(pt("Valor"))
                        
                        'db.execute( sqlDel )

                        set pv = db.execute("select pv.*, c.NomeConvenio from tissprodutosvalores pv LEFT JOIN convenios c ON c.id=pv.ConvenioID where pv.ProdutoTabelaID="& pt("id") &" order by pv.ProdutoTabelaID, pv.ConvenioID")

                        if not pv.eof then
                            %>
                                <%
                                'response.write( sqlDel )
                                ultimoPTConvenio = ""
                                while not pv.eof
                                    if ultimoPTConvenio = pv("ProdutoTabelaID") &"_"& pv("ConvenioID") then
                                        db.execute("delete from tissprodutosvalores where id="& pv("id"))
                                    end if
                                    ultimoPTConvenio = pv("ProdutoTabelaID") &"_"& pv("ConvenioID")

                                    btnx = " <button type='button' class='btn btn-xs btn-danger' onclick='xpv("& pv("id") &")'><i class='far fa-remove'></i></button>"

                                    call quickfield("currency", "pv"&pv("id"), pv("NomeConvenio") & btnx, 12, fn(pv("Valor")), "", "", " data-convenio=""" & pv("ConvenioID") & """ ")
                                pv.movenext
                                wend
                                pv.close
                                set pv=nothing
                                %>
                            <%
                        end if
                        %>
                        </div>
                        </td>
                    </tr>
                    <%
                    end if
                pt.movenext
                wend
                pt.close
                set pt=nothing
                %>
                </tbody>
            </table>
        </div>
    </div>
</form>
<script type="text/javascript">

$("#frmVI").submit(function(){
    $.post("ValoresItensUpdate.asp", $(this).serialize(), function(data){
        eval(data);
    });
    return false;
});
$(".pnsub").removeClass("hidden");

function ipt() {
    $.get("ValoresItensUpdate.asp?Inserir=Inserir", function (data) { eval(data) });
}


function altG(Campo, Valor) {
    //$("[name^=CD]").val(Valor);
    $("input[name=pt]").each(function () {
        if ($(this).prop("checked") == true) {
            $("#"+Campo+$(this).val()).val(Valor);
        }
    });
}

function xpt() {
    if(confirm('Tem certeza de que deseja excluir os itens selecionados?')){
        $.post("ValoresItensExcluir.asp", $("input[name='pt']").serialize(), function(data){ eval(data) });
    }
}

function xpv(I) {
    $.post("ValoresItensExcluir.asp?PV="+I, "", function(data){ eval(data) });
}

function apv(PT, C){
    $.get("ValoresItensExcluir.asp?PT="+PT+"&C="+C, function(data){
        $("#btn"+PT).after(data);
    });
}

function filterAll() {
    $(".litem, .litem .qf").removeClass("hidden");

    const filterCD       = $('#fcd').val();
    const filterItem     = $('#fitem').val();
    const filterTabela   = $('#ftabela').val();
    const filterConvenio = $('#fconvenio').val();

    filtro('CD', filterCD);
    filtro('ProdutoID', filterItem);
    filtro('TabelaID', filterTabela);
    filtro('Convenio', filterConvenio);
}

function clearFilters() {
    $('#fcd, #fitem, #ftabela, #fconvenio').val('').trigger('change');
}

function filtro(Campo, Valor) {
    if (Valor != "") {
        if (Campo === 'Convenio') {
            $("input[name^=pv]").each(function() {
                if ($(this).data('convenio') != Valor) {
                    $(this).closest('.qf').addClass('hidden');

                    if ($(this).closest('.produtos-valores').find('.qf:not(.hidden)').length === 0) {
                        $(this).closest('tr').addClass('hidden');
                    }
                }
            });
        } else {
            $("select[name^="+Campo+"]").each(function() {
                if ($(this).val() != Valor) {
                    $(this).closest('tr').addClass('hidden');
                }
            });
        }
    }
}

$("#frmVI").on("change","[data-resource='produtos']:not('#fitem')",function() {
    var r = $(this).parents("tr").find("[name='pt']").val();
    $.get("CarregaValorPadraoItem.asp?I="+r+"&ProdutoID="+$(this).val(), function(data) {
        eval(data);
    });
});

function addpt(){
    
}

    <%
    if ref("E")="E" then
        %>
        location.href="./?P=ValoresItens&Pers=1&T=<%= time()%>";
        <%
    end if
    %>
</script>
<%= request.form() %>