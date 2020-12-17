<%
'server.scripttimeout = 2000
response.buffer
%>
<!--#include file="connect.asp"-->

<style>
#container {
	height: 600px;
}

.highcharts-figure, .highcharts-data-table table {
    min-width: 310px; 
	max-width: 800px;
	overflow: auto;
    margin: 1em auto;
}

.highcharts-data-table table {
	font-family: Verdana, sans-serif;
	border-collapse: collapse;
	border: 1px solid #EBEBEB;
	margin: 10px auto;
	text-align: center;
	width: 100%;
	max-width: 500px;
}
.highcharts-data-table caption {
    padding: 1em 0;
    font-size: 1.2em;
    color: #555;
}
.highcharts-data-table th {
	font-weight: 600;
    padding: 0.5em;
}
.highcharts-data-table td, .highcharts-data-table th, .highcharts-data-table caption {
    padding: 0.5em;
}
.highcharts-data-table thead tr, .highcharts-data-table tr:nth-child(even) {
    background: #f8f8f8;
}
.highcharts-data-table tr:hover {
    background: #f1f7ff;
}
</style>

<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/streamgraph.js"></script>
<script src="https://code.highcharts.com/modules/series-label.js"></script>
<script src="https://code.highcharts.com/modules/annotations.js"></script>
<script src="https://code.highcharts.com/modules/exporting.js"></script>
<script src="https://code.highcharts.com/modules/export-data.js"></script>
<script src="https://code.highcharts.com/modules/accessibility.js"></script>

<figure class="highcharts-figure">
    <div id="container"></div>
    <p class="highcharts-description">
    </p>
</figure>

<script>
var colors = Highcharts.getOptions().colors;
Highcharts.chart('container', {

    chart: {
        type: 'streamgraph',
        marginBottom: 30,
        zoomType: 'x'
    },

    // Make sure connected countries have similar colors
    colors: [
        colors[0],
        colors[1],
        colors[2],
        colors[3],
        colors[4],
        // East Germany, West Germany and Germany
        Highcharts.color(colors[5]).brighten(0.2).get(),
        Highcharts.color(colors[5]).brighten(0.1).get(),

        colors[5],
        colors[6],
        colors[7],
        colors[8],
        colors[9],
        colors[0],
        colors[1],
        colors[3],
        // Soviet Union, Russia
        Highcharts.color(colors[2]).brighten(-0.1).get(),
        Highcharts.color(colors[2]).brighten(-0.2).get(),
        Highcharts.color(colors[2]).brighten(-0.3).get()
    ],

    title: {
        floating: true,
        align: 'left',
        text: 'Evolução de clientes por data de entrada'
    },
    subtitle: {
        floating: true,
        align: 'left',
        y: 30,
        text: ''
    },

    xAxis: {
        maxPadding: 0,
        type: 'category',
        crosshair: true,
        categories: [
            <% set e = db.execute("select distinct MesEntrada, AnoEntrada from temp_evrec order by AnoEntrada, MesEntrada")
            while not e.eof
                response.write("'"& zeroesq(e("MesEntrada"),2)&"/"& e("AnoEntrada")&"',")
            e.movenext
            wend
            e.close
            set e=nothing
            %>
        ],
        labels: {
            align: 'left',
            reserveSpace: false,
            rotation: 270
        },
        lineWidth: 0,
        margin: 20,
        tickWidth: 0
    },

    yAxis: {
        visible: false,
        startOnTick: false,
        endOnTick: false
    },

    legend: {
        enabled: false
    },
    plotOptions: {
        series: {
            label: {
                minFontSize: 5,
                maxFontSize: 15,
                style: {
                    color: 'rgba(255,255,255,0.75)'
                }
            }
        }
    },

    // Data parsed with olympic-medals.node.js
    series: 
    [
    <%
    set Ano = db.execute("select distinct AnoEntrada from temp_evrec order by AnoEntrada")
    while not Ano.eof
    %>
    {
        name: "<%= Ano("AnoEntrada") %>",
        data: [
            <%
            set e = db.execute("select distinct e.MesEntrada, e.AnoEntrada from temp_evrec e order by e.AnoEntrada, e.MesEntrada")
            while not e.eof
                set fat = db.execute("select ifnull(sum(ValorFatura), 0) Total from temp_evrec WHERE AnoEntrada="& Ano("AnoEntrada") &" AND MesFatura="& e("MesEntrada") &" and AnoFatura="& e("AnoEntrada"))
                while not fat.eof
                    response.flush()
                    response.write( replace(replace(fn(fat("Total")), ".", ""), ",", ".") &"," )
                fat.movenext
                wend
                fat.close
                set fat = nothing
            e.movenext
            wend
            e.close
            set e=nothing
            %>
        ]
    }, 
    <%
    Ano.movenext
    wend
    Ano.close
    set Ano = nothing
    %>
    ],

    exporting: {
        sourceWidth: 800,
        sourceHeight: 600
    }

});
</script>