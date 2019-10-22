<%
session("banco")="clinic100000"
%>
<!--#include file="connect.asp"-->
<!DOCTYPE html>
<html lang="en">
	<head>
        <meta http-equiv="refresh" content="150">
        <link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<meta charset="utf-8" />
		<title>Feegow Software :: Tomas Valadares</title>

		<meta name="description" content="" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		<!-- basic styles -->

		<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
		<!--link rel="stylesheet" href="assets/css/animate.css" />-->

		<!--[if IE 7]>
		  <link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" />
		<![endif]-->

		<!-- page specific plugin styles -->
		<link rel="stylesheet" href="assets/css/jquery-ui-1.10.3.custom.min.css" />
		<link rel="stylesheet" href="assets/css/chosen.css" />
		<link rel="stylesheet" href="assets/css/datepicker.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-timepicker.css" />
		<link rel="stylesheet" href="assets/css/daterangepicker.css" />
		<link rel="stylesheet" href="assets/css/colorpicker.css" />
		<link rel="stylesheet" href="assets/css/jquery.gritter.css" />
		<link rel="stylesheet" href="assets/css/select2.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-editable.css" />
        <!-- fonts -->

		<link rel="stylesheet" href="assets/css/ace-fonts.css" />

		<!-- ace styles -->

		<link rel="stylesheet" href="assets/css/ace.min.css" />
		<link rel="stylesheet" href="assets/css/ace-rtl.min.css" />
		<link rel="stylesheet" href="assets/css/ace-skins.min.css" />

		<!--[if lte IE 8]>
		  <link rel="stylesheet" href="assets/css/ace-ie.min.css" />
		<![endif]-->

		<!-- inline styles related to this page -->
		<style>
            
			.spinner-preview {
				width:100px;
				height:100px;
				text-align:center;
				margin-top:60px;
			}
			
			.dropdown-preview {
				margin:0 5px;
				display:inline-block;
			}
			.dropdown-preview  > .dropdown-menu {
				display: block;
				position: static;
				margin-bottom: 5px;
			}
			.editavel {
				border:2px #f3f3f3 dashed;
			}
			.fc-widget-content:hover {
				background-color:#FFC;
			}
			.fc-widget-content {
				cursor:pointer;
			}
			.select-insert li {
				margin:0;
				padding:0;
			}
			.select-insert li {
				cursor:pointer;
				list-style-type:none;
				margin:0;
				padding:3px;
				font-size:14px;
				color:#000;
				background-color:#FFF;
			}
			.select-insert li:hover {
				background-color:#999;
			}
			.min-tabs {
				min-height:500px;
			}
			.vertical-text {
				transform: rotate(90deg);
				transform-origin: left top 0;
			}
			.ace-settings-container{
				top:145px!important;
			}
			.ace-settings-box{
				width:500px;
				border:#f00 2px solid!important;
				height:400px;
			}
			.xx{
			/*	padding:0 30px;*/
			}
            body{
                overflow-x:hidden;
            }

            .containermv {
                height: 107px;
                overflow: hidden;
                background: white;
                position: relative;
                box-sizing: border-box;
            }

            .marquee {
                top: 6em;
                position: relative;
                box-sizing: border-box;
                animation: marquee 15s linear infinite;
            }

            .marquee:hover {
                animation-play-state: paused;
            }

            /* Make it move! */
            @keyframes marquee {
                0%   { top:   8em }
                100% { top: -11em }
            }

            /* Make it look pretty */
            .microsoft .marquee {
	            margin: 0;
                padding: 0 1em;
                line-height: 1.5em;
                font: 1em 'Segoe UI', Tahoma, Helvetica, Sans-Serif;
            }

            .microsoft:before, .microsoft::before,
            .microsoft:after,  .microsoft::after {
                left: 0;
                z-index: 1;
                content: '';
                position: absolute;
                pointer-events: none;
                width: 100%; height: 2em;
                background-image: linear-gradient(180deg, #FFF, rgba(255,255,255,0));
            }

            .microsoft:after, .microsoft::after {
                bottom: 0;
                transform: rotate(180deg);
            }

            .microsoft:before, .microsoft::before {
                top: 0;
            }

            /* Style the links */
            .vanity {
                color: #333;
                text-align: center;
                font: .75em 'Segoe UI', Tahoma, Helvetica, Sans-Serif;
            }

            .vanity a, .microsoft a {
                color: #1570A6;
                transition: color .5s;
                text-decoration: none;
            }

            .vanity a:hover, .microsoft a:hover {
                color: #F65314;
            }

            /* Style toggle button */
            .toggle {
	            display: block;
                margin: 2em auto;
            }
			</style>
            <!-- ace settings handler -->

		<script src="assets/js/ace-extra.min.js"></script>
        <!-- colocado por feegow para calendario funcionar -->
    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
    <script type="text/javascript" src="assets/js/jquery.validate.min.js"></script>
	
	<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
	<script src="ckeditornew/adapters/jquery.js"></script>
	
	<script type="text/javascript" src="assets/js/qtip/jquery.qtip.js"></script>
		<!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->

		<!--[if lt IE 9]>
		<script src="assets/js/html5shiv.js"></script>
		<script src="assets/js/respond.min.js"></script>
		<![endif]-->
    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="https://code.highcharts.com/highcharts-more.js"></script>
    <script src="https://code.highcharts.com/modules/exporting.js"></script>

	</head>
    <body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-8">
                <%
                set p=db.execute("select p.*, u.id User from profissionais p left join sys_users u on (u.table='profissionais' and u.idInTable=p.id) where ativo='on' and sysActive=1")
                while not p.eof
                    %>
                    <div class="clearfix form-actions">
                        <div class="col-md-1">
                            <img src="uploads/<%=p("Foto") %>" class="img-thumbnail" width="100" height="100" style="width:100px; height:100px; object-fit:cover" />
                        </div>
                        <div class="col-md-4" id="presenca<%=p("User") %>"></div>
                        <div class="col-md-2 btn btn-pink chamada" style="display:none" id="chamada<%=p("User") %>"></div>
                        <div class="col-md-2 btn btn-success atendimento" style="display:none" id="atendimento<%=p("User") %>"></div>
                        <div class="col-md-2 btn btn-white livre" style="display:none" id="livre<%=p("User") %>"></div>
                        <div class="col-md-3 pull-right containermv microsoft">


                            <p class="marquee">
                                <%
                                set tar = db.execute("select t.*, pro.Foto FROM tarefas t LEFT JOIN sys_users u on u.id=t.De LEFT JOIN profissionais pro on (pro.id=u.idInTable and u.table='profissionais') WHERE (t.Para like '%|"&p("User")&"|%' or t.Para like concat('%|-', '"&p("CentroCustoID")&"', '|%') ) AND (staDe<>'Finalizada' or staPara<>'Finalizada')")
                                while not tar.eof
                                    Solicitantes = tar("Solicitantes")
                                    if tar("Urgencia")=5 then
                                        classe = "danger"
                                        classeSol = "white"
                                    elseif tar("Urgencia")=4 then
                                        classe = "warning"
                                        classeSol = "white"
                                    else
                                        classe = "default"
                                        classeSol = "red"
                                    end if
                                    if instr(Solicitantes, "3_") then
                                        set sol = db.execute("select NomePaciente from pacientes where id="&replace(Solicitantes, "3_", ""))
                                        if not sol.eof then
                                            Solicitantes = "<small class='"&classeSol&"'>&raquo; " & sol("NomePaciente") & "</small>"
                                        end if
                                    end if
                                    %>
                                <span class="btn btn-<%=classe %> btn-block text-right" style="text-align:left">
			                        <img alt="Foto" style="height:40px; width:40px; object-fit:cover" src="uploads/<%=tar("Foto")%>" class="img-thumbnail" /> <%=tar("Titulo") %> <%=Solicitantes %>
                                </span>
                                    <br />

                                    <%
                                tar.movenext
                                wend
                                tar.close
                                set tar=nothing
                                %>
                            </p>


                        </div>
                    </div>
                    <%
                p.movenext
                wend
                p.close
                set p=nothing
                %>
            </div>
            <div class="col-md-4">
                <div class="clearfix form-actions row padding-10">
                    <div class="row col-md-12 text-right">
                        <img src="assets/img/4k.png" style="width:130px" />
                    </div>
                    <hr />
                    <%
                    'grafico 1 ->    
                    %>
                    <div id="prospeccoesVendedor1" style="min-width: 310px; height: 300px; margin: 0 auto"></div>
                    <script type="text/javascript">
                        $(function () {
                            Highcharts.chart('prospeccoesVendedor1', {
                                chart: {
                                    type: 'area'
                                },
                                title: {
                                    text: 'Prospeções - Fábio'
                                },
                                subtitle: {
                                    text: 'Source: Wikipedia.org'
                                },
                                xAxis: {
                                    categories: ['1750', '1800', '1850', '1900', '1950', '1999', '2050'],
                                    tickmarkPlacement: 'on',
                                    title: {
                                        enabled: false
                                    }
                                },
                                yAxis: {
                                    title: {
                                        text: 'Billions'
                                    },
                                    labels: {
                                        formatter: function () {
                                            return this.value / 1000;
                                        }
                                    }
                                },
                                tooltip: {
                                    split: true,
                                    valueSuffix: ' millions'
                                },
                                plotOptions: {
                                    area: {
                                        stacking: 'normal',
                                        lineColor: '#666666',
                                        lineWidth: 1,
                                        marker: {
                                            lineWidth: 1,
                                            lineColor: '#666666'
                                        }
                                    }
                                },
                                series: [{
                                    name: 'Asia',
                                    data: [502, 635, 809, 947, 1402, 3634, 5268]
                                }, {
                                    name: 'Africa',
                                    data: [106, 107, 111, 133, 221, 767, 1766]
                                }, {
                                    name: 'Europe',
                                    data: [163, 203, 276, 408, 547, 729, 628]
                                }, {
                                    name: 'America',
                                    data: [18, 31, 54, 156, 339, 818, 1201]
                                }, {
                                    name: 'Oceania',
                                    data: [2, 2, 2, 6, 13, 30, 46]
                                }]
                            });
                        });
                    </script>
                    <%
                    '<- gráfico 1
                    'gráfico 2 ->
                    %>
                    <hr />
                    <div id="oportunidadesAbertas" style="min-width: 310px; height: 300px; margin: 0 auto;"></div>
                    <script type="text/javascript">
                        $(function () {
                            Highcharts.chart('oportunidadesAbertas', {

                                chart: {
                                    type: 'bubble',
                                    plotBorderWidth: 1,
                                    zoomType: 'xy'
                                },

                                title: {
                                    text: 'OPORTUNIDADES ABERTAS'
                                },

                                xAxis: {
                                    gridLineWidth: 1
                                },

                                yAxis: {
                                    startOnTick: false,
                                    endOnTick: false
                                },

                                series: [{
                                    data: [
                                        [9, 81, 63],
                                        [98, 5, 89],
                                        [51, 50, 73],
                                        [41, 22, 14],
                                        [58, 24, 20],
                                        [78, 37, 34],
                                        [55, 56, 53],
                                        [18, 45, 70],
                                        [42, 44, 28],
                                        [3, 52, 59],
                                        [31, 18, 97],
                                        [79, 91, 63],
                                        [93, 23, 23],
                                        [44, 83, 22]
                                    ],
                                    marker: {
                                        fillColor: {
                                            radialGradient: { cx: 0.4, cy: 0.3, r: 0.7 },
                                            stops: [
                                                [0, 'rgba(255,255,255,0.5)'],
                                                [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0.5).get('rgba')]
                                            ]
                                        }
                                    }
                                }, {
                                    data: [
                                        [42, 38, 20],
                                        [6, 18, 1],
                                        [1, 93, 55],
                                        [57, 2, 90],
                                        [80, 76, 22],
                                        [11, 74, 96],
                                        [88, 56, 10],
                                        [30, 47, 49],
                                        [57, 62, 98],
                                        [4, 16, 16],
                                        [46, 10, 11],
                                        [22, 87, 89],
                                        [57, 91, 82],
                                        [45, 15, 98]
                                    ],
                                    marker: {
                                        fillColor: {
                                            radialGradient: { cx: 0.4, cy: 0.3, r: 0.7 },
                                            stops: [
                                                [0, 'rgba(255,255,255,0.5)'],
                                                [1, Highcharts.Color(Highcharts.getOptions().colors[1]).setOpacity(0.5).get('rgba')]
                                            ]
                                        }
                                    }
                                }]

                            });
                        });
                    </script>

                    <%
                    '<- gráfico 2

                    %>
                </div>

                Gráficos de treinamentos agendados
                <br />
                Gráfico de treinamentos realizados
                <br />
                Gráfico de demonstrações de cada vendedor agendadas
                <br />
                Gráfico de demonstrações de cada vendedor realizadas
                <br />
                Meta e atingimento dela
                <br />
                Ligações perdidas
                <br />
                Percentual de motivos de ligações recebidas
            </div>
        </div>
    </div>
<script type="text/javascript">
    function constante() {
        $.ajax({
            type: "POST",
            url: "constantePainel.asp",
            success: function (data) {
                eval(data);
            }
        });
    }
    setTimeout(function () { constante() }, 1500);
    setInterval(function () { constante() }, 10000);</script>

</body>


</html>
