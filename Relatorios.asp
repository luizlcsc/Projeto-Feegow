<script src="js/highcharts.js"></script>
<script src="js/exporting.js"></script>
<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="modal.asp"-->



<script type="text/javascript">
    $(".crumb-active a").html("Relatórios");
    $(".crumb-icon a span").attr("class", "far fa-list");
</script>

<%
permissoesUsuario = split(replace(session("Permissoes"),"|",""), ",")
TemAcesso = "0"
For i = 0 To Ubound(permissoesUsuario)
    if instr(permissoesUsuario(i),"relatorios")>0 then
        set getRel = dbc.execute("select * from cliniccentral.relatorios as r where r.Permissoes ='"&trim(permissoesUsuario(i))&"' and r.sysActive=1 LIMIT 1")
        if not getRel.eof then
            TemAcesso = "1"
        end if
    end if
Next
if TemAcesso<>"1" and session("Admin")<>1 then
%>
<script type="text/javascript">
    $(document).ready(function(){
        $("#CentralRelatorios").attr("disabled", true);
    });
</script>
<%
end if
%>



<br />
<div class="panel">
    <div class="panel-body" id="relConteudo">
        <div class="alert alert-system bg-primary dark" style="display: flex; flex-direction: column; align-items: center; text-align: center;">
            <h3>
                Nova central de relatórios disponível.<br><br><a href="#" onclick="openReport()" id="CentralRelatorios" class="btn btn-danger btn-sm"><i class="far fa-external-link"></i> Acessar versão BETA</a>
            </h3>
        </div>
    </div>
</div>

<script type="text/javascript">
function callReport(F, Pars){
    $("#relConteudo").html("<center><i class=\"far fa-spinner fa-spin green bigger-125\"></i> Carregando...</center>");
    $.post(F+".asp?Pars="+Pars, '', function(data, status){ $("#relConteudo").html(data) });
}


function openNewReport(ReportName, modelID) {
    var tk = localStorage.getItem("tk");

  window.open(
    domain + '/reports/r/'+ReportName+'?no-show=1&modelID='+modelID+'&tk='+tk,
    '_blank' // <- This is what makes it open in a new window.
  );
}

function openReport() {
    // alert("Prezado cliente, por favor aguarde alguns instantes para acessar o relatório.")
    // return;
    <%
    defaultReport = "duration-of-service"
    teste = split(replace(session("Permissoes"),"|",""),",")
    For i = 0 To Ubound(teste)
        if instr(teste(i),"relatorios")>0  then
            set rel =  dbc.execute("select r.arquivo from cliniccentral.relatorios as r where r.Permissoes='"&trim(teste(i))&"' and sysActive=1 LIMIT 1")
                if not rel.eof then
                    defaultReport=rel("arquivo")
                end if
            response.write "console.log('"&trim(teste(i))&"');"
            exit for
        end if
    Next
    'defaultReport = "duration-of-service"

    'if aut("relatoriosagendaV")=1 then


    'elseif aut("relatoriosfaturamentoV")=1 then
    '    defaultReport = "production"
    'end if

    %>
    var tk = localStorage.getItem("tk");

  window.open(
    domain + '/reports/r/<%=defaultReport%>?no-show=1&DATA_INICIO=<%=date()%>&DATA_FIM=<%=date()%>&tk='+tk,
    '_blank' // <- This is what makes it open in a new window.
  );
}
</script>


































<!--aqui comeca o antigo
                <div class="widget-box">
                    <div class="widget-header header-color-green2">
                        <h4 class="lighter smaller"> <i class="far fa-arrow-left"></i> Recolher</h4>
                    </div>

                    <div class="widget-body">
                        <div class="widget-main padding-8">
                            <div id="tree2" class="tree"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-9" id="divRelatorio">
            	Selecione um relat&oacute;rio ao lado.
            </div>
        </div>
-->
<script type="text/javascript">
            var $assets = "assets";//this will be used in fuelux.tree-sampledata.js
</script>

<%
set fs=Server.CreateObject("Scripting.FileSystemObject")
if fs.FileExists("relatorios.js") then
  response.write("<script src='relatorios.js'></script>")
end if
%>

<script src="assets/js/fuelux/fuelux.tree.min.js"></script>
<script type="text/javascript">
	jQuery(function($){
/*
$('#tree1').ace_tree({
	dataSource: treeDataSource ,
	multiSelect:true,
	loadingHTML:'<div class="tree-loading"><i class="far fa-refresh icon-spin blue"></i></div>',
	'open-icon' : 'icon-minus',
	'close-icon' : 'icon-plus',
	'selectable' : true,
	'selected-icon' : 'icon-ok',
	'unselected-icon' : 'icon-remove'
});
*/
try {
$('#tree2').ace_tree({
	dataSource: treeDataSource2 ,
	loadingHTML:'<div class="tree-loading"><i class="far fa-refresh fa-spin blue"></i></div>',
	'open-icon' : String('fa-folder-open'),
	'close-icon' : String('fa-folder-close'),
	'selectable' : false,
	'selected-icon' : null,
	'unselected-icon' : null
});
}catch(e)
{
    console.log("corrigir depois");
}


/**
$('#tree1').on('loaded', function (evt, data) {
});

$('#tree1').on('opened', function (evt, data) {
});

$('#tree1').on('closed', function (evt, data) {
});

$('#tree1').on('selected', function (evt, data) {
});
*/
});


function report(R){
	$("#divRelatorio").html("<center><i class=\"far fa-spinner fa-spin orange bigger-125\"></i> Carregando...</center>");
	$.ajax({
		type:"GET",
		url:R+".asp?TipoRel="+R,
		success:function(data){
			$("#divRelatorio").html(data);
		}
	});
}











/*
$(function () {

    var colors = Highcharts.getOptions().colors,
        categories = ['Folha de Pagto', 'Materiais e Medic.', 'Custos Operacionais', 'Marketing', 'Outros'],
        data = [{
            y: 56.33,
            color: colors[0],
            drilldown: {
                name: 'Folha de Pagto',
                categories: ['Graça Tavares', 'Antônio Carlos', 'Aline J. Alexandre', 'Cynthia Mello', 'Antonio Carlos', 'Maria da Silva'],
                data: [1.06, 0.5, 17.2, 8.11, 5.33, 24.13],
                color: colors[0]
            }
        }, {
            y: 10.38,
            color: colors[1],
            drilldown: {
                name: 'Materiais e Medicamentos',
                categories: ['Toxina Bot.', 'Seringa', 'Iodo', 'Gase', 'Cataflan', 'Dipirona', 'Luvas'],
                data: [0.33, 0.15, 0.22, 1.27, 2.76, 2.32, 2.31, 1.02],
                color: colors[1]
            }
        }, {
            y: 24.03,
            color: colors[2],
            drilldown: {
                name: 'Custos Operacionais',
                categories: ['Telefone', 'Internet', 'TV a Cabo', 'Aluguel', 'Condomínio',
                    'Bala', 'Brinde', 'Camisa', 'Uniforme', 'Passagens', 'Hospedagem', 'Alimentação', 'Passagem', 'Ticket Refeição'
                    ],
                data: [0.14, 1.24, 0.55, 0.19, 0.14, 0.85, 2.53, 0.38, 0.6, 2.96, 5, 4.32, 3.68, 1.45],
                color: colors[2]
            }
        }, {
            y: 4.77,
            color: colors[3],
            drilldown: {
                name: 'Marketing',
                categories: ['Outdoor', 'TV', 'Revista Veja', 'Panfletos', 'Busdoor', 'Painel', 'Rádio'],
                data: [0.3, 0.42, 0.29, 0.17, 0.26, 0.77, 2.56],
                color: colors[3]
            }
        }, {
            y: 0.2,
            color: colors[5],
            drilldown: {
                name: 'Proprietary or Undetectable',
                categories: [],
                data: [],
                color: colors[5]
            }
        }, {
            y: 0.91,
            color: colors[4],
            drilldown: {
                name: 'Opera versions',
                categories: ['Opera v12.x', 'Opera v27', 'Opera v28', 'Opera v29'],
                data: [0.34, 0.17, 0.24, 0.16],
                color: colors[4]
            }
        }],
        browserData = [],
        versionsData = [],
        i,
        j,
        dataLen = data.length,
        drillDataLen,
        brightness;


    // Build the data arrays
    for (i = 0; i < dataLen; i += 1) {

        // add browser data
        browserData.push({
            name: categories[i],
            y: data[i].y,
            color: data[i].color
        });

        // add version data
        drillDataLen = data[i].drilldown.data.length;
        for (j = 0; j < drillDataLen; j += 1) {
            brightness = 0.2 - (j / drillDataLen) / 5;
            versionsData.push({
                name: data[i].drilldown.categories[j],
                y: data[i].drilldown.data[j],
                color: Highcharts.Color(data[i].color).brighten(brightness).get()
            });
        }
    }

    // Create the chart
    $('#container').highcharts({
        chart: {
            type: 'pie'
        },
        title: {
            text: 'Distribuição das Despesas - Dezembro/2015'
        },
        yAxis: {
            title: {
                text: 'Total percent market share'
            }
        },
        plotOptions: {
            pie: {
                shadow: false,
                center: ['50%', '50%']
            }
        },
        tooltip: {
            valueSuffix: '%',
			valuePrefix: ''
        },
        series: [{
            name: 'Browsers',
            data: browserData,
            size: '60%',
            dataLabels: {
                formatter: function () {
                    return this.y > 5 ? this.point.name : null;
                },
                color: '#ffffff',
                distance: -30
            }
        }, {
            name: 'Versions',
            data: versionsData,
            size: '80%',
            innerSize: '60%',
            dataLabels: {
                formatter: function () {
                    // display only if larger than 1
                    return this.y > 1 ? '<b>' + this.point.name + ':</b> ' + '' + this.y + '%' : null;
                }
            }
        }]
    });
});
*/
</script>
