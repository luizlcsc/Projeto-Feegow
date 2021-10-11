<!--#include file="connect.asp"-->
<%
if req("De")="" then
	De=dateadd("m", -1, date())
else
	De=req("De")
end if
if req("Ate")="" then
	Ate=dateadd("m", 1, date())
else
	Ate=req("Ate")
end if
%>
<script type="text/javascript">
    $(".crumb-active a").html("Cartões de Crédito e Débito");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("administração de recebimento de cartões");
    $(".crumb-icon a span").attr("class", "far fa-credit-card");
</script>

<form id="frmCC" method="get">
    <input type="hidden" name="P" value="<%=req("P")%>">
    <input type="hidden" name="Pers" value="<%=req("Pers")%>">
    <br>
    <div class="panel hidden-print">
        <div class="panel-heading">
            <span class="panel-title">Buscar recebimentos</span>
            <span class="panel-controls">
                <button class="btn btn-sm btn-info" name="Filtrate" onclick="print()" type="button"><i class="far fa-print bigger-110"></i> Imprimir</button>
                <button class="btn btn-sm btn-success" name="Filtrate" onclick="downloadExcel()" type="button"><i class="far fa-table bigger-110"></i> Excel</button>

                <button id="btnBuscar" class="btn btn-primary"><i class="far fa-search"></i> Buscar</button>
            </span>
        </div>
        <div class="panel-body">
            <div class="row">
                <%= quickfield("multiple", "Conta", "Selecione o cartão", 3, req("Conta"), "select id, CONCAT(AccountName, ' ', IFNULL(IF(Empresa = 0, (SELECT Sigla from empresa where id=1), (SELECT Sigla from sys_financialcompanyunits where id = Empresa)), '') ) NomeConta from sys_financialcurrentaccounts where "&franquiaUnidade("'[Unidades]' like CONCAT('%|',Empresa,'|%')  AND")&" AccountType in(3, 4) AND sysActive=1", "NomeConta", " required") %>

                <div class="col-md-2">
                    <div class="checkbox-custom checkbox-success">
                        <input type="checkbox" name="Baixados" id="Baixados" value="S" class="ace" <%if req("Baixados")="S" then%> checked <%end if%>><label class="checkbox" for="Baixados">Baixados</label>
                    </div>
                    <div class="checkbox-custom checkbox-warning">
                        <input type="checkbox" name="Pendentes" id="Pendentes" value="S" class="ace" <%if req("Pendentes")="S" or req("De")="" then%> checked <%end if%>><label for="Pendentes" class="checkbox"> Pendentes</label></div>
                </div>
                <%= quickField("datepicker", "De", "De", 2, De, "", "", "") %>
                <%= quickField("datepicker", "Ate", "até", 2, Ate, "", "", "") %>
                 <div class="col-md-3 pt25">
                    <span class="radio-custom"><input type="radio" id="dataCompra" name="dataBusca" value="Date" /><label for="dataCompra">Data de compra</label></span><br/>
                    <span class="radio-custom"><input type="radio" id="dataCredito" name="dataBusca" value="DateToReceive" checked /><label for="dataCredito">Data de crédito</label></span>
                </div>
            </div>
            <div class="row">
                <input type="hidden" id="Pagina" value="1" name="PaginaAtual"/>
                <%=quickField("text", "Transacao", "Transação", 2, "", "", "", "")%>
                <%=quickField("text", "Autorizacao", "Autorização", 2, "", "", "", "")%>
                <%= quickfield("multiple", "Bandeira", "Selecione a bandeira", 3, req("Bandeira"), "SELECT Bandeira,Bandeira as id FROM cliniccentral.bandeiras_cartao", "Bandeira", "") %>
            </div>
        </div>
    </div>
</form>

<div class="panel">
    <div class="panel-body pn" id="resultado">
        <%server.Execute("CartaoCreditoResultado.asp") %>
    </div>
</div>

<div id="divCartaoLote" class="panel" style="display: none">
    <div class="panel-body"></div>
</div>

<form id="formCartaoCredito" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>
<script>
function buscaPagina(pagina){
    $("#Pagina").val(pagina);
    $("#frmCC").submit();
}

function downloadExcel(){
    $("#htmlTable").val($("#resultado").html());
    var tk = localStorage.getItem("tk");

    $("#formCartaoCredito").attr("action", domain+"/reports/download-excel?title=CartaoCredito&tk="+tk).submit();
}
</script>

<script type="text/javascript">
    $("#frmCC").submit(function () {
        $.post("CartaoCreditoResultado.asp", $(this).serialize(), function (data) {
            $("#resultado").html(data);
        });
        return false;
    });

function baixa(I, A, Par, Pars,unidade, dataCredito = null){
	$("#btn"+I).attr("disabled", "disabled");
	if (!dataCredito){
	    dataCredito = $("#DateToReceive"+I).val();
	}
	$.post("CartaoCreditoBaixa.asp", {
		I:I,
		A:A,
		Fee:$("#Fee"+I).val(),
		Taxa:$("#Taxa"+I).val(),
		ValorCredito:$("#ValorCredito"+I).val(),
		ValorParcela:$("#parc"+I).val(),
		DateToReceive:dataCredito,
		Par:Par,
		Pars:Pars,
        unidadeid: unidade
	},
	function(data){ eval(data);nextProcesso && nextProcesso();});
}


function treatval(valor){
	valor = valor.replace('.', '');
	valor = valor.replace(',', '.');
	return valor;
}
function tvrev(valor){
	valor = valor.replace('.', '');
}

function atualizaValor(arg) {
    var idParc = $(arg).attr("data-id");
    var perc = parseFloat(treatval($(arg).val()));
    var valParc = parseFloat(treatval($("#parc" + idParc).val()));
    var juros = (valParc * perc) * 0.01;
    var valFinal = (valParc - juros).toFixed(2).toString().replace('.', ',');

    $("#ValorCredito" + idParc).val(valFinal);

    if (typeof recalcValorBaixar !== 'undefined'){
                recalcValorBaixar();
            }

}

$("#resultado").on("keyup", "input[id^='Fee']",function () {atualizaValor(this)});



<!--#include file="jQueryFunctions.asp"-->

</script>