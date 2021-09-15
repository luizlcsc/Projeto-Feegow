<!--#include file="../connect.asp"-->
<style>
.acao{
width: 1%;
}
</style>
<script type="text/javascript">
    $(".crumb-active a").html("Auditoria");
    $(".crumb-icon a span").attr("class", "far fa-eye");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Financeiro");
</script>
<div class="panel" style="margin-top: 10px">
	<div class="panel-heading">Auditoria</div>

    <div class="panel-body">
<div class="row">
        <%
        if session("UnidadeID") <> 0 then %>
            <%=quickField("simpleSelect", "unidade", "Unidade", 2, "", "SELECT * FROM sys_financialcompanyunits WHERE sysActive=1 AND id = "&session("UnidadeID")&" ", "NomeFantasia", "") %>
        <% else %>
            <%=quickField("simpleSelect", "unidade", "Unidade", 2, "", "SELECT * FROM sys_financialcompanyunits WHERE sysActive=1 ORDER BY 2", "NomeFantasia", "") %>
        <% end if %>
        <%=quickField("datepicker", "dataIni", "De", 2, date(), "", "", "")%>
        <%=quickField("datepicker", "dataFinal", "Até", 2, date(), "", "", "")%>
             <div class="col-md-2">
                  <div class="input-group inline" style=" top:20px;">
                      <button class="btn btn-info" id="filtrando">Filtrar</button>
                  </div>
              </div>
        <div class="col-md-12">
            <div class="services row mt15">

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
    </div>
</div>
</div>
<script>
var getServices = function(){

    $.ajax({
        url: domain + "api/financial/auditoria/listService?tk="+localStorage.getItem('tk'),
        type: 'get',
        dataType: 'json',
        success(data){
            $(".services").html(data.map((item,key) =>
              `<div class="col-md-4 checkbox-custom">
                      <input type="checkbox" class="services_names" value="${item.service}" id="checkboxDefault${key}">
                      <label for="checkboxDefault${key}">${item.title}</label>
               </div>`))
        },
        fail(data){
            $(".loading").html("");
        },
    });
}

var criarTabelaGenerica = (data) => {
    var table = "";
    Object.keys(data).map((itemAuditavel) =>{
            let itemAuditavelObj = data[itemAuditavel];
            if(!( data[itemAuditavel].data.length > 0)){
                return;
            }
            table += `<tr class="info"><th colspan="100%" style="text-align:center"><h3>${data[itemAuditavel].title}</h3></th></tr>`;
            table += `<tr class="info">`;
            table += Object.values(data[itemAuditavel].labels).map((item) => {
                return `<th>${item}</th>`;
            }).join();
            table += "<td class='acao'>Ação</td>";

            table +=  "</tr>";

            table += data[itemAuditavel].data.map((row) => {

                 let url = itemAuditavelObj.url.base;
                 itemAuditavelObj.url.params.forEach((item) => {
                     url = url.replace(`[${item}]`,row[item])
                 });

                 let trHtml  = "<tr>";
                 trHtml += Object.values(data[itemAuditavel].labels).map((item) => {
                     if(!row[item]){
                         row[item] = "";
                     }
                     let style = "";

                     if(row[item].includes("R$")){
                         style = "style='text-align:right'";
                     }

                     return `<td ${style}>${row[item]}</td>`;
                 }).join();
                 trHtml += `<td class='acao' style="white-space: nowrap;">
                                <button class='btn btn-primary btn-xs' id='auditar' onclick='clickAutic(${row._InTable},"${itemAuditavel}")'><i class='far fa-check'></i></button>
                                <a target="_blank" class='btn btn-success btn-xs' id='auditar' href="${url}"><i class='far fa-edit'></i></a>
                            </td>`;

                 trHtml += "</tr>";
                return trHtml;
            }).join();
    });

    if(table === ""){
            $("#table-auditoria1").html("<tr><td class='text-center'>Nenhum registro encontrado.</td></tr>");
    }else{
        $("#table-auditoria1").html(table);
    }


}

let filtrar = () =>{
        $("#table-auditoria1").html("");
        let unidade = $("#unidade").val();
        let dataInicio = $("#dataIni").val();
        let dataFim = $("#dataFinal").val();

        if(dataInicio){
            dataInicio = moment(dataInicio, 'DD/MM/YYYY').format("YYYY-MM-DD")
        }

        if(dataFim){
            dataFim = moment(dataFim, 'DD/MM/YYYY').format("YYYY-MM-DD")
        }

        let objct = {};
        objct.tk = localStorage.getItem('tk');
        objct.services = [];

        let servicesNames = [];
        $(".services_names:checked").each((i,k) => servicesNames.push(k.value) )

        servicesNames.forEach((service) => {
            objct.services.push({service,filters:{unidade,dataInicio,dataFim}});
        });

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
                    criarTabelaGenerica(data);

                },
                fail(data){
                    $(".loading").html("");
                    limpaTudo()
                },
        });
}

$("#filtrando").click(filtrar);

function clickAutic(TableId,evento){
    $(".loading").html("<img src='newImages/atualizando.gif'/>");

    let objct = {};
    objct.auditar = [];
    objct.auditar.push({service:evento,id:TableId});
    objct.tk = localStorage.getItem('tk');
   // console.log(objct.auditar);
    $.ajax({
       url: domain + "api/financial/auditoria/list",
       type: 'post',
       dataType: 'json',
       data: JSON.stringify(objct),
           success(data){
                filtrar();
               //console.log(data);
           },
           fail(data){
               limpaTudo();
           }
    });
};


$(document).ready(() => getServices());

</script>