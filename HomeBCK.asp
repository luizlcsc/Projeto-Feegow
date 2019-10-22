<%
LocalTime = request.QueryString("LocalTime")
if LocalTime<>"" then
	DifTempo = datediff("s", time(), LocalTime)
	session("DifTempo") = DifTempo
	response.Redirect("./?P=Home&Pers=1")
end if
'response.Write("|||"&DifTempo&"|||<br />"&time())
%>
<script src="js/highcharts.js"></script>
<script src="js/exporting.js"></script>
<div class="row">
	<div class="col-md-6" id="agendamentos"></div>
	<div class="col-md-6" id="procedimentos"></div>
	<div class="col-md-12" id="financeiro"><h3 align="center">Resumo da semana...</h3></div>
</div>
<script language="javascript">
function agendamentos() {
    $('#agendamentos').highcharts({
        chart: {
            type: 'spline'
        },
        title: {
            text: 'Agendamentos'
        },
        subtitle: {
            text: ''
        },
        xAxis: {
            categories: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab']
        },
        yAxis: {
            title: {
                text: 'Quantidade'
            },
            labels: {
                formatter: function () {
                    return this.value + '°';
                }
            }
        },
        tooltip: {
            crosshairs: true,
            shared: true
        },
        plotOptions: {
            spline: {
                marker: {
                    radius: 4,
                    lineColor: '#666666',
                    lineWidth: 1
                }
            }
        },
        series: [{
            name: 'Marcado - confirmado',
            marker: {
                symbol: 'square'
            },
            data: [7, 6, 9, 14, 7, 5, {
                y: 11,
                marker: {
                    symbol: 'url(assets/img/7.png)'
                }
            }]

        },{
            name: 'Marcado - nao confirmado',
            marker: {
                symbol: 'square'
            },
            data: [13, 20, 15, 17, 18, 18, {
                y: 20,
                marker: {
                    symbol: 'url(assets/img/1.png)'
                }
            }]

        },{
            name: 'Atendido',
            marker: {
                symbol: 'square'
            },
            data: [2, 7, 2, {
                y: 3,
                marker: {
                    symbol: 'url(assets/img/3.png)'
                }
            }, 1, 4, 5]

        }, {
            name: 'Faltou',
            marker: {
                symbol: 'diamond'
            },
            data: [{
                y: 4,
                marker: {
                    symbol: 'url(assets/img/6.png)'
                }
            }, 5, 8, 7, 7, 8, 6]
        }]
    });
}


function procedimentos() {
    $('#procedimentos').highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: 0,//null,
            plotShadow: false
        },
        title: {
            text: 'Atendimentos Realizados'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                    style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                    }
                }
            }
        },
        series: [{
            type: 'pie',
            name: 'Percentual',
            data: [
                ['Consulta',   45.0],
                ['Botox',       26.8],
                {
                    name: 'Fisioterapia',
                    y: 12.8,
                    sliced: true,
                    selected: true
                },
                ['Drenagem',    8.5],
                ['Depilacao a Laser',     6.2],
                ['Outros',   0.7]
            ]
        }]
    });
}


function financeiro() {
    $('#financeiro').highcharts({

        chart: {
            type: 'column',
            marginTop: 80,
            marginRight: 40
        },

        title: {
            text: 'Contas a Pagar e a Receber'
        },

        xAxis: {
            categories: ['Segunda', 'Terca', 'Quarta', 'Quinta', 'Sexta']
        },

        yAxis: {
            allowDecimals: false,
            min: 0,
            title: {
                text: 'Valor'
            }
        },

        tooltip: {
            headerFormat: '<b>{point.key}</b><br>',
            pointFormat: '<span style="color:{series.color}">\u25CF</span> {series.name}: {point.y} / {point.stackTotal}'
        },

        plotOptions: {
            column: {
                stacking: 'normal',
                depth: 40
            }
        },

        series: [{
            name: 'Em Aberto',
            data: [311.45, 48.50, 875.25, 288.80, 574.00],
            stack: 'A Pagar',
			color:'#ff0000'
        }, {
            name: 'Pago',
            data: [532.45, 328.00, 474.25, 723.00, 221.25],
            stack: 'A Pagar',
			color:'#069'
        }, {
            name: 'A Receber',
            data: [347.00, 0.00, 444.00, 499.00, 333.33],
            stack: 'A Receber',
			color:'grey'
        }, {
            name: 'Recebido',
            data: [214.58, 547.58, 600.00, 200.00, 199.54],
            stack: 'A Receber',
			color:'green'
        }]
    });
}

$(document).ready(function(){
	setTimeout(function(){agendamentos()}, 1000);
	setTimeout(function(){procedimentos()}, 1800);
	setTimeout(function(){financeiro()}, 3000);
	setTimeout(function(){apaga()}, 4000);
	function apaga(){
		$("text[zIndex='8']").css("display", "none");
	}
});
</script>

