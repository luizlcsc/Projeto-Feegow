<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Gerar Rateio");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("calcular e lançar rateio de despesas");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>

	<%
    ContaCredito = req("ContaCredito")
    FormaID = req("FormaID")
    Lancado = req("Lancado")
    Status = req("Status")
    De = req("De")
    Ate = req("Ate")
	if De="" then
		De = date()
	end if
	if Ate="" then
		Ate = dateadd("m", 1, date())
	end if

    set cat = db.execute("select group_concat('|',id, '|' separator ', ') Categorias from sys_financialexpensetype where sysActive=1  AND Rateio=1 order by Name")
    Categorias = cat("Categorias")
    %>
    <form action="" id="gerarRateio" name="gerarRateio" method="get">
        <input type="hidden" name="P" value="GerarRateio" />
        <input type="hidden" name="Pers" value="1" />
        <br />
        <div class="panel hidden-print">
            <div class="panel-body">
            <div class="row">
                <div class="col-md-4">
                    <div class="row">
                        <%= quickField("datepicker", "De", "Per&iacute;odo", 6, De, "", "", " placeholder='De' required='required'") %>
                        <%= quickField("datepicker", "Ate", "&nbsp;", 6, Ate, "", "", " placeholder='At&eacute;' required='required'") %>
                    </div>
                    <div class="row">
                        <%= quickfield("number", "Percentual", "Percentual - %", 6, 100, "", "", "") %>
                        <%= quickfield("simpleSelect", "Distribuicao", "Distribuição", 6, Distribuicao, "select 'L' id, 'Recebimento líquido' Descricao UNION ALL select 'I', 'Dividir igualmente' UNION ALL select 'B', 'Produção bruta'", "Descricao", " semVazio ") %>
                    </div>
                    <div class="row">
                        <%= quickfield("empresaMulti", "Empresas", "Empresas", 12, session("Unidades"), "", "", "") %>
                    </div>
                </div>
                <%= quickfield("selectCheck", "Profissionais", "Profissionais", 4, Profissionais, "select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", "") %>
                <%= quickfield("selectCheck", "Categorias", "Categorias", 4, Categorias, "select * from sys_financialexpensetype where sysActive=1 order by Name", "Name", "") %>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <button class="btn btn-primary pull-right"><i class="far fa-search"></i> Buscar</button>
                </div>
            </div>
        </div>
            </div>

        <div class="panel">
            <div class="panel-body" id="resultadoGerarRateio"></div>
        </div>
    </form>
<script language="javascript">
$("#gerarRateio").submit(function(){
    $("#resultadoGerarRateio").html('Calculando...');
    $.post("resultadoGerarRateio.asp", $(this).serialize(), function (data) {
        $("#resultadoGerarRateio").html(data);
    });
    return false;
});
</script>