<!--#include file="connect.asp"-->
<!--#include file="invoiceEstilo.asp"-->
<%
if session("DateFrom")="" then
	session("DateFrom") = dateadd("m", -1, date())
end if
if session("DateTo")="" then
	session("DateTo") = date()
end if
%>

<style>
@media print
{
    .no-print, .no-print *
    {
        display: none !important;
    }
}
</style>

<br>
<div class="panel">
<div class="panel-body">
<form id="frmExtrato">
    <script>
		$(document).ready(function(e) {
            $("#Filtrate").click();
        });
    </script>
    <div class="widget-box transparent">
        <div class="widget-header widget-header-flat">
            <!--<h4 class=""><i class="far fa-inbox blue"></i> MEU CAIXA <small>&raquo; movimentações do caixa atual</small></h4>-->
        </div>
    </div>
    <div class="row">
        <div class="col-md-4">
            <%'= simpleSelectCurrentAccounts("Conta", "4, 5", Conta, " required","") %>
            <h5>CAIXA: <%=session("NameUser")%></h5>
        </div>
		<div class="col-md-5" id="listaCaixas">
        </div>
         <%
        if session("Unidades")<>"|0|" AND 1=2 then
        %>
        <%=quickfield("multiple", "Unidades", "Unidades", 4, "", "select * from sys_financialcompanyunits where sysActive", "UnitName", "")%>
<input type="hidden" value="<%=ref("AccountID")%>" name="StatementAccountID" id="StatementAccountID" />
        <%else%>
        <input type="hidden" name="Unidades" value="0">
        <%end if%>
        
        <input type="hidden" name="AccountID" value="7_<%=session("CaixaID")%>">

        <div class="col-lg-offset-1 col-md-1">
            <button class="btn btn-sm btn-info no-print" name="Filtrate" onclick="print()" type="button"><i class="far fa-print bigger-110"></i> Imprimir</button>
        </div>
        <div class="col-md-1">
            <button class="btn btn-sm btn-success no-print" name="Filtrate" onclick="downloadExcel()" type="button"><i class="far fa-table bigger-110"></i> Excel</button>
        </div>
    </div>
    <div class="row">
        <div id="Extrato" class="col-xs-12">
            <center><em>Você precisa estar com o caixa aberto para ver as movimentações.</em></center>
        </div>
    </div>
</form>
</div>
</div>



<form id="formExcel" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>
<script>
function downloadExcel(){
    $("#htmlTable").val($("#Extrato").html());
    var tk = localStorage.getItem("tk");

    $("#formExcel").attr("action", domain+"reports/download-excel?title=ExtratoCaixa&tk="+tk).submit();
}
</script>

<script type="text/javascript">
    $(".crumb-active a").html("Meu Caixa");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("movimentações do caixa atual");
    $(".crumb-icon a span").attr("class", "far fa-inbox blue");

    $.post("ExtratoConteudo.asp?T=MeuCaixa", $("#frmExtrato").serialize(), function(data){
        $("#Extrato").html(data)
    });
<!--#include file="financialCommomScripts.asp"-->
</script>
<%'=session("Banco") %>