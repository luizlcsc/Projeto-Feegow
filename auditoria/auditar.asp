<!--#include file="../connect.asp"-->
<div class="panel" style="margin-top: 10px">
	<div class="panel-heading">Auditoria</div>

    <div class="panel-body">
<div class="row">
    <%=quickField("simpleSelect", "unidade", "Unidade", 2, "", "select * from vw_unidades where sysActive=1 order by 2", "NomeFantasia", "") %>

        <div class="col-md-2">
        <div class="input-group inline" >
        <label>Data Inicial</label>

            <input type="text" name="data-ini" class="form-control input-mask-date date-pickerinput-mask-date" id="dataIni" data-date-format="dd/mm/yyyy">
<!--            <span class="input-group-addon">-->
<!--                <i class="fa fa-calendar bigger-110"></i>-->
<!--            </span>-->
        </div>
        </div>
        <div class="col-md-2">
        <div class="input-group inline">
        <label>Data Final</label>
            <input type="text" name="data-ini" class="form-control input-mask-date date-pickerinput-mask-date" id="dataFinal" data-date-format="dd/mm/yyyy">
<!--            <span class="input-group-addon">-->
<!--                <i class="fa fa-calendar bigger-110"></i>-->
<!--            </span>-->
        </div>
        </div>
        <div class="col-md-2">
            <div class="input-group inline" style=" top:20px;">
                <button class="btn btn-info" id="filtrando">Filtrar</button>
            </div>
        </div>
    </div>


<div class="row" style="margin-top: 10px">
<div class="loading" style="text-align: center;position: relative;"></div>
    <div class="col-md-12" id="container-table">
        <table id="table-auditoria1" class="table table-striped table-bordered table-hover">
            <thead>
                <tr class="primary">

                </tr>
            </thead>
            <tbody>
                <tr class="info">

                </tr>
            </tbody>
        </table>
        <table id="table-auditoria2" class="table table-striped table-bordered table-hover">
            <thead>
                <tr class="primary">
                </tr>
            </thead>
            <tbody>
                <tr class="info">

                </tr>
            </tbody>
        </table>
        <table id="table-auditoria3" class="table table-striped table-bordered table-hover">
            <thead>
                <tr class="primary">

                </tr>
            </thead>
            <tbody>
                <tr class="info">

                </tr>
            </tbody>
        </table>
    </div>
</div>
</div>
<script>

var criarTabelaComCaixa = (data) => {
    var header = [];
    if(data.ContaAPagarComCaixa.data.length){
        $.each(data.ContaAPagarComCaixa.labels,function(index,val){
            header.push(val);
            $("#table-auditoria1 thead tr").append("<td>  "+ val +" </td>");
        });
        constroiLinhas(data.ContaAPagarComCaixa.data,"#table-auditoria1 tbody",header,"ContaAPagarComCaixa");
    }
}
var criarTabelaSemCaixa = (data) => {
    var header = [];
    if(data.ContaAPagarSemCaixa.data.length){
        $.each(data.ContaAPagarSemCaixa.labels,function(index,val){
            header.push(val);
            $("#table-auditoria2 thead tr").append("<td>  "+ val +" </td>");
        });
        constroiLinhas(data.ContaAPagarSemCaixa.data,"#table-auditoria2 tbody",header,"ContaAPagarSemCaixa");
    }
}

var listaUnidades = () => {

    $.ajax({
        url: domain + "api/financial/auditoria/list",
        type: 'post',
        dataType: 'json',
        data: JSON.stringify(objct),
            success(data){
                limpaTudo()
                criarTabelaComCaixa(data);
                criarTabelaSemCaixa(data);
                criarTabelaCancelamentos(data);
            },
            fail(data){
                limpaTudo()
                console.log(data);
            }
    });

}

var criarTabelaCancelamentos = (data) => {
    var header = [];
    if(data.ContaCancelada.data.length){
        $.each(data.ContaCancelada.labels,function(index,val){
            header.push(val);
            $("#table-auditoria3 thead tr").append("<td>  "+ val +" </td>");
        });
        constroiLinhas(data.ContaCancelada.data,"#table-auditoria3 tbody",header,"ContaCancelada");
    }
}

var constroiLinhas = (data,tabela,header,evento) => {
    var linha = [];
    $.each(data,function(index,val){
        linha.push("<tr>");
         $.each(header, function(key, value){
             linha.push("<td>" + val[value] + "</td>");
         });
         let param = val['_InTable'] + ",\""+evento+"\"";
         linha.push("<td> <button class='btn btn-danger btn-sm' id='auditar' onclick='clickAutic("+ param +")'>Auditado</button></td>");
         linha.push("</tr>");
    });

    $(tabela).append(linha.join());
}
var limpaTudo = () => {

    $("#table-auditoria3 thead tr").html("");
    $("#table-auditoria3 tbody tr").html("");
    $("#table-auditoria2 thead tr").html("");
    $("#table-auditoria2 tbody tr").html("");
    $("#table-auditoria1 thead tr").html("");
    $("#table-auditoria1 tbody tr").html("");
}

$("#filtrando").click(function(){
    let objct = {};
    objct.tk = localStorage.getItem('tk');
    let dataInicial = $("#dataIni").val();
    let dataFinal = $("#dataFinal").val();
    objct.services = [];
    objct.services.push({service:"ContaAPagarComCaixa",alias :"ContaAPagarComCaixa",filters:{unidade:$("#unidade").val(),dataInicio:dataInicial,dataFim:dataFinal}});
    objct.services.push({service:"ContaAPagarSemCaixa",filters:{unidade:$("#unidade").val(),dataInicio:dataInicial,dataFim:dataFinal}});
    objct.services.push({service:"ContaCancelada",filters:{unidade:$("#unidade").val(),dataInicio:dataInicial,dataFim:dataFinal}});

    console.log(JSON.stringify(objct));

    $.ajax({
        url: domain + "api/financial/auditoria/list",
        type: 'post',
        dataType: 'json',
        data: JSON.stringify(objct),
            beforeSend: function(){
                $(".loading").html("<img src='newImages/atualizando.gif'/>");
            },
            success(data){
                $(".loading").html("");
                limpaTudo()
                criarTabelaComCaixa(data);
                criarTabelaSemCaixa(data);
                criarTabelaCancelamentos(data);
            },
            fail(data){
                $(".loading").html("");
                limpaTudo()
                console.log(data);
            },
    });
});



function clickAutic(TableId,evento){
    let objct = {};
    objct.auditar = [];
    objct.auditar.push({service:evento,id:TableId});
    objct.tk = localStorage.getItem('tk');
    console.log(objct.auditar);
    $.ajax({
       url: domain + "api/financial/auditoria/list",
       type: 'post',
       dataType: 'json',
       data: JSON.stringify(objct),
           success(data){
               console.log(data);
           },
           fail(data){
               limpaTudo();
               console.log(data);
           }
    });
};




</script>