<!--#include file="connect.asp"-->

<div id="container" style="min-width: 410px; max-width: 600px; height: 400px; margin: 0 auto"></div>

<%

%>

<script type="text/javascript">
    $(function () {

        Highcharts.chart('container', {
            chart: {
                type: 'funnel',
                marginRight: 100
            },
            title: {
                text: 'Funil de Vendas',
                x: -50
            },
            plotOptions: {
                series: {
                    dataLabels: {
                        enabled: true,
                        format: '<b>{point.name}</b> ({point.y:,.0f})',
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black',
                        softConnector: true
                    },
                    neckWidth: '30%',
                    neckHeight: '25%'

                    //-- Other available options
                    // height: pixels or percent
                    // width: pixels or percent
                }
            },
            legend: {
                enabled: false
            },
            series: [{
                name: 'Etapa',
                data: [
                    ['Prospecção', 15654],
                    ['Potencial', 4064],
                    ['Agendado', 1987],
                    ['Proposta', 976],
                    ['Fechado', 846]
                ]
            }]
        });
    });
</script>