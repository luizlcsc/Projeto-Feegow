<!--#include file="connect.asp"-->
<%
ConvenioID = req("ConvenioID")


sqlImposto = "Select * from impostos where sysActive = 1"

sqlContrato = "SELECT id, CodigoNaOperadora FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" AND sysActive = 1 AND CodigoNaOperadora <> '' "

sqlCentroCusto = "select * from centrocusto c where sysActive = 1"

sqlPlanoDeContas = "select * from sys_financialexpensetype sf2 where sysActive = 1"
%>

<style>
    .mt50{
        margin-top:50px
    }
</style>

<button id="criarRegra" type="button" class="btn btn-success btn-lg" data-toggle="modalImposto" data-target="#modalImposto" onClick="criarRegra()">
  + Criar imposto
</button>


<!-- Modal -->
<div class="modal fade" id="modalImposto" tabindex="-1" role="dialog" aria-labelledby="modalImposto">
  <div class="modal-dialog modal-lg" role="document">
    <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 class="modal-title" id="myModalLabel">Imposto</h4>
        </div>
        <div class="modal-body" style="min-height: 300px;">
            <form id="regra" class="col-md-12">
                <div class="row">
                    <%= quickfield("simpleSelect", "Imposto" , "Imposto"   , 6, Imposto, sqlImposto, "nome", "") %>
                    <%= quickfield("multiple", "Contratos", "Contratos" , 6, Contratos, sqlContrato,"CodigoNaOperadora", "") %>
                </div>
                <div class="row">
                    <%= quickfield("simpleSelect", "planoConta" , "Plano de Contas"   , 6, planoDecontas, sqlPlanoDeContas, "Name", "") %>
                    <%= quickfield("simpleSelect", "centroCusto" , "Centro de custo"   , 6, NomeCentroCusto, sqlCentroCusto, "NomeCentroCusto", "") %>
                    <%=quickField("porcentagem"     , "valor"    , "Valor" , 3, valor, " sql-mask-2-digits ", "", " ")%>
                    <div class="col-md-3"></div>
                    <%=quickField("currency"     , "de"       , "De " , 3, de, " sql-mask-2-digits  ", "", " ")%>
                    <%=quickField("currency"     , "ate"      , "Até" , 3, ate, " sql-mask-2-digits  ", "", " ")%>
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-primary" onClick="sendToSave()">Save changes</button>
        </div>
    </div>
  </div>
</div>

<hr>

<div class="mt50">
    <i class="fa fa-spinner fa-spin orange bigger-125"></i> Carregando...
<div>

<script type="text/javascript">
criarRegra = ()=>{
    $("#modalImposto").modal("show")
}

sendToSave = () =>{
    let data = $("#regra").serialize()
    envio(data)
      
}

envio = (data) =>{
    $.ajax({
        type:"POST",
        url:"saveImpostosAssociacao.asp?acao=N&convenio=<%=ConvenioID%>",
        data:data,
        success:function(data){
            $("#GradeAgenda").html(data);
        }
    });
    return false; 
}

load = () =>{
 $.ajax({
        type:"get",
        url:"loadImpostosAssociacao.asp?convenio=<%=ConvenioID%>",
        success:function(data){
            console.log(data)
        }
    });
    return false; 
}

load()
<!--#include file="JQueryFunctions.asp"-->
</script>