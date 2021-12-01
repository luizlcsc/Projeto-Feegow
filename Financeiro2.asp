<!--#include file="connect.asp"-->

<script type="text/javascript">
    $(".crumb-active").html("<a href='#'>Financeiro</a>");
    $(".crumb-icon a span").attr("class", "fa fa-money");
    $(".crumb-trail").removeClass("hidden");
    $(".crumb-trail").html("painel principal");
</script>

<%
response.buffer

if aut("contasareceber")=1 and aut("contasapagar")=1 and aut("movement")=1 then


DataReferencia=req("DataReferencia")

if DataReferencia="" then
    DataReferencia=date()
end if
%>
<br />
	<div class="panel">
    	<div class="panel-body">
        	<div class="col-xs-12" id="container" style="min-width: 310px; height: 400px; margin: 0 auto"></div>
        </div>
        <div class="panel-body">
            <div class="col-md-12">
                <h4>Saldo Geral</h4>
                <form action="" id="form-saldo">
                    <input type="hidden" name="P" value="Financeiro">
                    <input type="hidden" name="Pers" value="1">
                    <div class="row">
                        <%=quickfield("datepicker", "DataReferencia", "Data do saldo", 3, DataReferencia, "", "", "")%>
                    </div>
                </form>
                <h2 id="SaldoGeral">Carregando...</h2><br>
                <div class="row">
                <%
				set unidadesSql = db.execute("select unidades from "&session("Table")&" where id="&session("idInTable"))
				if not unidadesSql.EOF then
					unidades = unidadesSql("unidades")
					if unidadesSql("unidades")&""<>"" then
						whereUnidades = "AND empresa in("&replace(unidades,"|","")&")"
					end if
				end if
				Data=date()

				SaldoGeral = 0
				
				set contas = db.execute("select * from sys_financialcurrentaccounts where AccountType in(1, 2) and sysActive=1 "&whereUnidades)
				while not contas.EOF
					response.flush()
                    set SaldoContas = db.execute("SELECT SUM(entrada)-SUM(saida) Saldo FROM movimentacoesfinanceiras WHERE contaid="&contas("id"))
                    if not SaldoContas.eof then
                        Saldo = SaldoContas("Saldo")
                    else
                        Saldo = "0,00"
                    end if
					SaldoGeral = SaldoGeral+Saldo
					%>
                    <div class="col-xs-3 img-thumbnail" style="padding-left:42px">
                        <a href="?P=Extrato&Pers=1&T=1_<%=contas("id") %>">
                            <img style="position:absolute; left:5px; margin-top:2px" src="https://cdn.feegow.com/feegowclinic-v7/assets/banks/financeiro.png" width="32" height="32">
                            <strong><%=left(contas("AccountName"),23)%></strong><br>R$ <%=formatnumber(Saldo, 2)%>
                        </a>
                    </div>
                <%
				contas.movenext
				wend
				contas.close
				set contas=nothing
				%>
                </div>
            </div>
            <div class="col-md-6">
            
            </div>
        </div>

    </div>













<script>
$("#SaldoGeral").html('R$ <%=formatnumber(SaldoGeral, 2)%>');

$("#DataReferencia").change(function() {
    $("#form-saldo").submit()
});

$(function () {
    $('#container').highcharts({
        title: {
            text: 'Resumo da Semana'
        },
        xAxis: {
            categories: ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado']
        },
        labels: {
            items: [{
                html: 'Total entradas e saídas',
                style: {
                    left: '50px',
                    top: '18px',
                    color: (Highcharts.theme && Highcharts.theme.textColor) || 'black'
                }
            }]
        },
<%
	DiaAtual = weekday(date())
	
	Inicio = DiaAtual-1
	Inicio = dateAdd("d", (Inicio*(-1)), date())
	Fim = dateAdd("d", 6, Inicio)
	
	Dia = Inicio
	
	RP = 0
	RR = 0
	DP = 0
	DR = 0
	
	while Dia<=Fim
		'Receita prevista
		set recPrev = db.execute("select sum(Value) Valor from sys_financialmovement where Type='Bill' and CD='C' and Date="&mydatenull(Dia)&"")
		if isnull(recPrev("Valor")) then
			ValorRP = 0
			ValorRPL = 0
		else
			ValorRP = replace(recPrev("Valor"), ",", ".")
			ValorRPL = recPrev("Valor")
		end if
		strRecPrev = strRecPrev & ValorRP & ", "
	
		'Receita realizada
		set recReal = db.execute("select sum(Value) Valor from sys_financialmovement where Type='Pay' and CD='D' and Date="&mydatenull(Dia)&"")
		if isnull(recReal("Valor")) then
			ValorRR = 0
			ValorRRL = 0
		else
			ValorRR = replace(recReal("Valor"), ",", ".")
			ValorRRL = recReal("Valor")
		end if
		strRecReal = strRecReal & ValorRR & ", "
	
		'Despesa prevista
		set desPrev = db.execute("select sum(Value) Valor from sys_financialmovement where Type='Bill' and CD='D' and Date="&mydatenull(Dia)&"")
		if isnull(desPrev("Valor")) then
			ValorDP = 0
			ValorDPL = 0
		else
			ValorDP = replace(desPrev("Valor"), ",", ".")
			ValorDPL = desPrev("Valor")
		end if
		strDesPrev = strDesPrev & ValorDP & ", "
	
		'Despeza realizada
		set desReal = db.execute("select sum(Value) Valor from sys_financialmovement where Type='Pay' and CD='C' and Date="&mydatenull(Dia)&"")
		if isnull(desReal("Valor")) then
			ValorDR = 0
			ValorDRL = 0
		else
			ValorDR = replace(desReal("Valor"), ",", ".")
			ValorDRL = desReal("Valor")
		end if
		strDesReal = strDesReal & ValorDR & ", "
	
		strSaldo = strSaldo & replace( ccur(ValorRPL)-ccur(ValorDPL) , ",", ".") & ", "
	
	
		RP = RP + ccur(ValorRPL)
		RR = RR + ccur(ValorRRL)
		DP = DP + ccur(ValorDPL)
		DR = DR + ccur(ValorDRL)
	
	
	
		Dia = Dia+1
	wend
	
	
	
	
	
	
	
	%>
			series: [{
				type: 'column',
				name: 'Receita prevista',
				color: '#919DE8',
				data: [<%=left(strRecPrev, len(strRecPrev)-2)%>]
			}, {
				type: 'column',
				color: 'green',
				name: 'Receita realizada',
				data: [<%=left(strRecReal, len(strRecReal)-2)%>]
			}, {
				type: 'column',
				name: 'Saída prevista',
				color: 'orange',
				data: [<%=left(strDesPrev, len(strRecPrev)-2)%>]
			}, {
				type: 'column',
				name: 'Saída realizada',
				color: 'red',
				data: [<%=left(strDesReal, len(strDesReal)-2)%>]
			}, {
				type: 'spline',
				name: 'Saldo previsto',
				color: 'black',
				data: [<%=left(strSaldo, len(strSaldo)-2)%>],
				marker: {
					lineWidth: 2,
					lineColor: Highcharts.getOptions().colors[3],
					fillColor: 'white'
				}
			}, {
				type: 'pie',
				name: 'Total do fluxo',
				data: [{
					name: 'Receita prevista',
					y: <%=replace(RP, ",", ".")%>,
					color: '#919DE8'
				}, {
					name: 'Receita realizada',
					y: <%=replace(RR, ",", ".")%>,
					color: 'green'
				}, {
					name: 'Saída prevista',
					y: <%=replace(DP, ",", ".")%>,
					color: 'orange'
				}, {
					name: 'Saída realizada',
					y: <%=replace(DR, ",", ".")%>,
					color: 'red'
				}],
				center: [100, 80],
				size: 100,
				showInLegend: false,
				dataLabels: {
					enabled: false
				}
			}]
		});
	});
	<!--#include file="financialCommomScripts.asp"-->
	</script>
<%
end if
%>