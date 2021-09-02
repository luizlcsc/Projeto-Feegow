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
            <button type="button" class="btn btn-primary" onClick="sendToSave()">Salvar</button>
        </div>
    </div>
  </div>
</div>

<hr>

<div id="conteudo" class="mt50">
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
            load()
            $("#modalImposto").modal("hide")
        }
    });
    return false; 
}

load = () =>{
    $.get( "loadImpostosAssociacao.asp?convenio=<%=ConvenioID%>", function( data ) {
        if(!data){
            $("#conteudo").html("<p><i class='fa fa-exclamation-triangle'></i> Sem Regras cadastradas</p>")
        }else{
            formatRule(JSON.parse(data))
        }
    });
    return false; 
}

formatMoney = (val)=>{
    if (val.indexOf(",") < 0){
        return val+",00"
    }
    return val
}

apagarRegra = (id) =>{
}
var html= ""
formatRule = (dados) =>{
    $('#conteudo').html("")
        html=`
        <table id="percentual-conta" class="table table-bordered table-striped">
            <tr class="primary">						
                <th width="12%">Imposto</th>
                <th width="12%">Contratos</th>
                <th width="16%">Plano de Contas</th>
                <th width="16%">Centro de Custo</th>
                <th width="12%">valor</th>
                <th width="12%">De</th>
                <th width="12%">Ate</th>
                <th width="2%">Ação</th>
            </tr>
            <tbody>`
        dados.map((dado)=>{
        html +=`<tr>
                    <td>`+dado.imposto+`</td>
                    <td>`
                    for (let index = 0; index < dado.contratos.length; index++) {
                        const contrato = dado.contratos[index];
                            if (index>0){
                                html+=","
                            }
                            html += "<span>"+contrato.contrato_nome+"</span>"
                    }
        html +=    `</td>
                    <td>`+dado.planoContas+`</td>
                    <td>`+dado.CentroCusto+`</td>
                    <td>`+dado.valor+`%</td>
                    <td>R$ `+formatMoney(dado.de)+`</td>
                    <td>R$ `+formatMoney(dado.ate)+`</td>
                    <td><button type="button" class="btn btn-sm btn-danger pull-right" title="Excluir" onclick="if(confirm('Tem certeza de que deseja excluir essa regra?'))apagarRegra(`+dado.id+`);">
                            <i class="fa fa-trash icon-trash"></i>
                        </button></td>
                </tr>`
        })
        html+=`</tbody>
        </table>
            `

    $('#conteudo').append(html)
}

load()
<!--#include file="JQueryFunctions.asp"-->
</script>