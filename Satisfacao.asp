<!--#include file="connect.asp"-->

<!doctype html>
<html>

<head>
	<title>Line Chart</title>
	<script src="js/Chart.min.js"></script>
	<script src="js/utils.js"></script>
	<style>
	canvas{
		-moz-user-select: none;
		-webkit-user-select: none;
		-ms-user-select: none;
	}
	</style>
</head>
<body>
	<div id="container" style="width: 75%;">
		<canvas id="canvas"></canvas>
	</div>
	<script>
		var MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
		var color = Chart.helpers.color;
		var barChartData = {
			labels: ['Qualidômetro'],
			datasets: [



<%
tAtivo = 0
tInativo = 0
set tot = db.execute("select (select count(id) from cliniccentral.licencasusuarios where not isnull(QualiServer) and QualiServer BETWEEN 1 and 5 and Ativo=1) totalA, "&_
    " (select count(id) from cliniccentral.licencasusuarios where not isnull(QualiServer) and QualiServer BETWEEN 1 and 5 and Ativo=0) totalI")
TotalA = ccur(tot("TotalA"))
TotalI = ccur(tot("TotalI"))
set n = db.execute("select n.*, (select count(id) from cliniccentral.licencasusuarios where QualiServer=n.id and Ativo=1 and not isnull(Ativo)) qtdAtivo, (select count(id) from cliniccentral.licencasusuarios where QualiServer=n.id and Ativo=0 and not isnull(Ativo)) qtdInativo from cliniccentral.qualidometrostatus n order by n.id desc")
while not n.eof
    QtdAtivo = ccur(n("QtdAtivo"))
    QtdInativo = ccur(n("QtdInativo"))
    tAtivo = tAtivo+QtdAtivo
    tInativo = tInativo+QtdInativo
    db.execute("replace into cliniccentral.qualievo (id, Nota, Quantidade) values (concat(replace(curdate(), '-', ''), "& n("id") &"), "& n("id") &", "& QtdAtivo &")")
    %>
    {
		label: '<%= fn( 100*(QtdAtivo/TotalA) ) &" - "& QtdAtivo %>',
		backgroundColor: '<%= "#"& n("Cor") %>',
		borderColor: '<%= "#"& n("Cor") %>',
		borderWidth: 2,
		data: [
			<%= QtdAtivo %>,
		]
	},
<%'= n("id") &" - Ativo: "& QtdAtivo &" ("& fn( 100*(QtdAtivo/TotalA) ) &" - Inativo: "& QtdInativo &" ("& fn( 100*(QtdInativo/TotalI) ) &") <br>" %>
<%
n.movenext
wend
n.close
set n = nothing

'Total ativo: "& tAtivo &" <br />
'Total inativo: "& tInativo &" <br />
' TotalA 
'<br />
' TotalI 
%>

]

		};

		window.onload = function() {
			var ctx = document.getElementById('canvas').getContext('2d');
			window.myBar = new Chart(ctx, {
				type: 'bar',
				data: barChartData,
				options: {
					responsive: true,
					legend: {
						position: 'top',
                        display: true,
                        labels: {
                            fontColor: '#000'
                        }
					},
					title: {
						display: true,
						text: 'Chart.js Bar Chart'
					}
				}
			});

		};

		document.getElementById('randomizeData').addEventListener('click', function() {
			var zero = Math.random() < 0.2 ? true : false;
			barChartData.datasets.forEach(function(dataset) {
				dataset.data = dataset.data.map(function() {
					return zero ? 0.0 : randomScalingFactor();
				});

			});
			window.myBar.update();
		});

		var colorNames = Object.keys(window.chartColors);
		document.getElementById('addDataset').addEventListener('click', function() {
			var colorName = colorNames[barChartData.datasets.length % colorNames.length];
			var dsColor = window.chartColors[colorName];
			var newDataset = {
				label: 'Dataset ' + (barChartData.datasets.length + 1),
				backgroundColor: color(dsColor).alpha(0.5).rgbString(),
				borderColor: dsColor,
				borderWidth: 1,
				data: []
			};

			for (var index = 0; index < barChartData.labels.length; ++index) {
				newDataset.data.push(randomScalingFactor());
			}

			barChartData.datasets.push(newDataset);
			window.myBar.update();
		});

		document.getElementById('addData').addEventListener('click', function() {
			if (barChartData.datasets.length > 0) {
				var month = MONTHS[barChartData.labels.length % MONTHS.length];
				barChartData.labels.push(month);

				for (var index = 0; index < barChartData.datasets.length; ++index) {
					// window.myBar.addData(randomScalingFactor(), index);
					barChartData.datasets[index].data.push(randomScalingFactor());
				}

				window.myBar.update();
			}
		});

		document.getElementById('removeDataset').addEventListener('click', function() {
			barChartData.datasets.pop();
			window.myBar.update();
		});

		document.getElementById('removeData').addEventListener('click', function() {
			barChartData.labels.splice(-1, 1); // remove the label first

			barChartData.datasets.forEach(function(dataset) {
				dataset.data.pop();
			});

			window.myBar.update();
		});
	</script>
</body>

</html>







<%
if 0 then

    tAtivo = 0
    tInativo = 0
    set tot = db.execute("select (select count(id) from cliniccentral.licencasusuarios where not isnull(QualiServer) and QualiServer BETWEEN 1 and 5 and Ativo=1) totalA, "&_
        " (select count(id) from cliniccentral.licencasusuarios where not isnull(QualiServer) and QualiServer BETWEEN 1 and 5 and Ativo=0) totalI")
    TotalA = ccur(tot("TotalA"))
    TotalI = ccur(tot("TotalI"))
    set n = db.execute("select n.*, (select count(id) from cliniccentral.licencasusuarios where QualiServer=n.id and Ativo=1 and not isnull(Ativo)) qtdAtivo, (select count(id) from cliniccentral.licencasusuarios where QualiServer=n.id and Ativo=0 and not isnull(Ativo)) qtdInativo from cliniccentral.qualidometrostatus n order by n.id desc")
    while not n.eof
        QtdAtivo = ccur(n("QtdAtivo"))
        QtdInativo = ccur(n("QtdInativo"))
        tAtivo = tAtivo+QtdAtivo
        tInativo = tInativo+QtdInativo
        %>
    <%= n("id") &" - Ativo: "& QtdAtivo &" ("& fn( 100*(QtdAtivo/TotalA) ) &" - Inativo: "& QtdInativo &" ("& fn( 100*(QtdInativo/TotalI) ) &")" %> <br>
    <%
    n.movenext
    wend
    n.close
    set n = nothing
    %>
    Total ativo: <%= tAtivo %> <br />
    Total inativo: <%= tInativo %> <br />
    <%= TotalA %>
    <br />
    <%= TotalI %>
<% end if %>