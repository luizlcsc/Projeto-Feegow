<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Produtos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("lista de produtos");
    $(".crumb-icon a span").attr("class", "fa fa-medkit");
</script>
<%
    Ate = req("Ate")
    De = req("De")
    Ordem = req("Ordem")
    if Ordem&""="" then
        Ordem = "Nome"
    end if
    AbaixoMinimo = req("AbaixoMinimo")
%>
<form id="frmListaProdutos">
    <div class="panel">
        <div class="panel-body mt20 hidden-print">
            <div class="row">
                <%=quickfield("simpleSelect", "ProdutoID", "Produto", 2, ProdutoID, "select id, NomeProduto from produtos where sysActive=1 order by NomeProduto", "NomeProduto", "") %>
                <%=quickField("text", "Codigo", "Código", 2, Codigo, "", "", "")%>
                <%=quickField("text", "CodigoIndividual", "Código Individual", 2, CodigoIndividual, "", "", "")%>
                <%=quickfield("simpleSelect", "CategoriaID", "Categoria", 2, CategoriaID, "select id, NomeCategoria from produtoscategorias where sysActive=1 order by NomeCategoria", "NomeCategoria", "") %>
                <%=quickfield("simpleSelect", "FabricanteID", "Fabricante", 2, FabricanteID, "select id, NomeFabricante from produtosfabricantes where sysActive=1 order by NomeFabricante", "NomeFabricante", "") %>
                <%=quickfield("simpleSelect", "LocalizacaoID", "Localização", 2, LocalizacaoID, "select id, NomeLocalizacao from produtoslocalizacoes where sysActive=1 order by NomeLocalizacao", "NomeLocalizacao", "") %>
                
            </div>
            <div class="row mt20">
            <%=quickfield("simpleSelect", "AbaixoMinimo", "Abaixo do Mínimo", 2, AbaixoMinimo, "SELECT 'S' as id, 'SIM' as valor UNION ALL SELECT 'N', 'NÃO'", "valor", "") %>
            <%= quickfield("datepicker", "De", "Válido De", 2, De, "", "", "") %>
            <%= quickfield("datepicker", "Ate", "Válido Até", 2, Ate, "", "", "") %>
            <%=quickfield("simpleSelect", "Ordem", "Ordernar Por", 2, Ordem, "select 'Nome' id, 'Nome' Ordem union all select 'Validade' id, 'Validade' Ordem ", "Ordem", " semVazio no-select2") %>


            <div class="col-md-offset-1 col-md-3">
                <button class="btn btn-sm btn-primary  mt20"><i class="fa fa-search bigger-110"></i> Buscar</button>
                <button class="btn btn-sm btn-info mt20" name="Filtrate" onclick="print()" type="button"><i class="fa fa-print bigger-110"></i></button>
                <button class="btn btn-sm btn-success mt20" name="Filtrate" onclick="downloadExcel()" type="button"><i class="fa fa-table bigger-110"></i></button>
            </div>

        </div>
    </div>
</form>

<div class="panel">
    <div class="panel-body" id="divListaProdutosConteudo">
    </div>
</div>

<form id="formExcel" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>

<script type="text/javascript">

function downloadExcel(){
    $("#htmlTable").val($("#divListaProdutosConteudo").html());
    var tk = localStorage.getItem("tk");

    $("#formExcel").attr("action", domain+"/reports/download-excel?title=ListaProdutos&tk="+tk).submit();
}


$("#frmListaProdutos").submit(function () {
    $.post("ListaProdutosConteudo.asp", $(this).serialize(), function (data) {
        $("#divListaProdutosConteudo").html(data);

    });
    return false;
});

    $("#frmListaProdutos").submit();


</script>