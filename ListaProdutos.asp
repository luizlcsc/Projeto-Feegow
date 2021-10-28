<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Estoque");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Lista");
    $(".crumb-icon a span").attr("class", "far fa-medkit");
</script>
    <%
    praVencer = req("praVencer")
    Ate = req("Ate")
    De = req("De")
    Ordem = req("Ordem")
    if Ordem&""="" then
        Ordem = "Nome"
    end if
    AbaixoMinimo = req("AbaixoMinimo")
    TipoProduto = req("TipoProduto")&""
    if TipoProduto&""="" then
        TipoProduto = "1"
    end if

    if req("Acao")="X" then
        db.execute("UPDATE produtos SET sysActive=-1 WHERE id="&treatvalzero(req("ItemID")))
        %>
        <script>
        new PNotify({
            title: 'Item excluído com sucesso',
            type: 'success',
            delay: 5000
        });
        </script>
        <%
    end if

    if aut("|produtosI|")=1 then
    %>
    <script type="text/javascript">
        $("#rbtns").html('<a id="InserirProduto" class="btn btn-sm btn-success" href="?P=Produtos&Pers=1&I=N&TipoProduto=<%=TipoProduto%>"><i class="far fa-plus"></i> INSERIR</a>');
    </script>
    <%
    end if

    %>

<form id="frmListaProdutos">
    <div class="panel">
        <div class="panel-body mt20 hidden-print">
            <div class="row">
                <input type="hidden" name="praVencer" id="praVencer" value="<%=praVencer%>">

                <% if TipoProduto = 1 then %>
                    <%=quickfield("simpleSelect", "ProdutoID", "Produto", 2, ProdutoID, "select id, NomeProduto from produtos where sysActive=1 order by NomeProduto", "NomeProduto", "") %>
                    <%=quickfield("simpleSelect", "TipoProduto", "Tipo Produto", 2, TipoProduto, "select id, TipoProduto from cliniccentral.produtostipos WHERE id <> 5 order by id", "TipoProduto", " semVazio no-select2 ") %>
                <% else %>
                    <%=quickfield("simpleSelect", "ProdutoID", "Taxas", 2, ProdutoID, "select id, NomeProduto from produtos where TipoProduto = '"&TipoProduto&"' and sysActive=1 order by NomeProduto", "NomeProduto", "") %>
                    <%=quickfield("simpleSelect", "TipoProduto", "Tipo Produto", 2, TipoProduto, "select id, TipoProduto from cliniccentral.produtostipos order by id", "TipoProduto", " semVazio no-select2 ") %>
                <% end if %>
                <%if TipoProduto<>1 then%>
                    <input type="hidden" name="TipoProduto" id="TipoProduto" value="<%=TipoProduto%>">
                <%end if%>

                <%=quickField("text", "Codigo", "Código", 2, Codigo, "", "", "")%>
                <%=quickfield("simpleSelect", "CategoriaID", "Categoria", 2, CategoriaID, "select id, NomeCategoria from produtoscategorias where sysActive=1 order by NomeCategoria", "NomeCategoria", "") %>
                <%=quickfield("simpleSelect", "FabricanteID", "Fabricante", 2, FabricanteID, "select id, NomeFabricante from produtosfabricantes where sysActive=1 order by NomeFabricante", "NomeFabricante", "") %>
                <%=quickfield("simpleSelect", "LocalizacaoID", "Localização", 2, LocalizacaoID, "select id, NomeLocalizacao from produtoslocalizacoes where sysActive=1 order by NomeLocalizacao", "NomeLocalizacao", "") %>

            </div>
            <div class="row mt20">
            <%=quickField("text", "CodigoIndividual", "Código Individual", 2, CodigoIndividual, "", "", "")%>
            <%=quickfield("simpleSelect", "AbaixoMinimo", "Abaixo do Mínimo", 2, AbaixoMinimo, "SELECT 'S' as id, 'SIM' as valor UNION ALL SELECT 'N', 'NÃO'", "valor", " no-select2 ") %>
            <%'= quickfield("datepicker", "De", "Válido De", 2, De, "", "", "") %>
            <%'= quickfield("datepicker", "Ate", "Válido Até", 2, Ate, "", "", "") %>
            <%=quickfield("simpleSelect", "Ordem", "Ordernar Por", 2, Ordem, "select 'Nome' id, 'Nome' Ordem union all select 'Validade' id, 'Validade' Ordem ", "Ordem", " semVazio no-select2") %>
                <div class="col-md-2">
                    <button class="btn btn-sm btn-primary  mt20"><i class="far fa-search bigger-110"></i> Buscar</button>
                    <button class="btn btn-sm btn-info mt20" name="Filtrate" onclick="print()" type="button"><i class="far fa-print bigger-110"></i></button>
                    <button class="btn btn-sm btn-success mt20" name="Filtrate" onclick="downloadExcel()" type="button"><i class="far fa-table bigger-110"></i></button>
                </div>

            </div>
            <div class="row mt20">
                <div class="col-md-2 Modulo-Medicamento">
                    <%= selectInsert("Princípio Ativo", "PrincipioAtivo", PrincipioAtivo, "cliniccentral.principioativo", "Principio", "", "", "") %>
                </div>
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

function removeItem(ID){
    $.get("ListaProdutos.asp?ItemID="+ID+"&Acao=X", $(this).serialize(), function (data) {
        new PNotify({
            title: 'Item excluído com sucesso',
            type: 'success',
            delay: 5000
        });
        $("#linha"+ID).remove();
    });
};

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

    if($("#TipoProduto").val() != 1){$("#TipoProduto").attr("disabled", true);};
    if($("#TipoProduto").val() != 4){
        $(".Modulo-Medicamento").addClass("hidden");
    }

    if($("#TipoProduto").val() == 5){
        $("#frmListaProdutos").addClass("hidden");
    }




    $("#TipoProduto").on("click", function (){
        var TipoProduto = $("#TipoProduto").val();

        $("#InserirProduto").attr("href", "?P=Produtos&Pers=1&I=N&TipoProduto="+TipoProduto);
        if(TipoProduto != 4){
            $(".Modulo-Medicamento").addClass("hidden");
        }else{
            $(".Modulo-Medicamento").removeClass("hidden");
        };
    });


</script>