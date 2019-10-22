<!--#include file="connect.asp"-->
<%
Data = req("Data")
if Data = "" then
	Data = date()
end if

Mes = month(Data)
Ano = year(Data)

De = DiaMes("P", Data)
Ate = DiaMes("U", Data)
tipo = req("Pars")
%>
<script>
	function cd(CategoriaID){
		location.href="<%="./?P=ContasCD&Pers=1&T="&CD&"&De="&De&"&Ate="&Ate&"&U="&U&"&CategoriaID="%>"+CategoriaID;
	}
</script>

<form id="frmfiltros">

    <div class="row">
        <h2 class="col-xs-8">ANÁLISE DE <%=tipo%> <small>&raquo; <a class="btn btn-xs hidden-print" href="#" onClick="$('#filtros').toggleClass('hidden')">mais filtros</a></small></h2>
    
    
    
    
        <div class="col-xs-4">
            <ul class="pagination pagination-md pull-right">
                <li class="hidden"><a href="javascript:callReport('Plano', '<%=tipo%>&Data=<%=dateadd("m", -1, Data)%>');"><i class="fa fa-chevron-left"></i></a></li>
                <li><button class="btn btn-default" onClick="$('#Data').val('<%=dateadd("m", -1, Data)%>')"><i class="fa fa-chevron-left"></i></button></li>
                <li><a href="#"><%=ucase(monthname(Mes)) &" - "& Ano%></a></li>
                <li><button class="btn btn-default" onClick="$('#Data').val('<%=dateadd("m", 1, Data)%>')"><i class="fa fa-chevron-right"></i></button></li>
                <li class="hidden"><a href="javascript:callReport('Plano', '<%=tipo%>&Data=<%=dateadd("m", 1, Data)%>');"><i class="fa fa-chevron-right"></i></a></li>
            </ul>
        </div>
    </div>
    
	<input type="hidden" name="Data" id="Data" value="<%=Data%>">
	<input type="hidden" name="Pars" value="<%=tipo%>">
    <div class="clearfix form-actions hidden" id="filtros">
      <div class="row">
        <%=quickField("empresaMultiCheck", "U", "Unidade", 7, req("U"), "", "", "")%>
        <div class="col-md-5"><label><input type="checkbox" name="Ocultar" value="S"<%if req("Ocultar")="S" then%> checked<%end if%> class="ace"><span class="lbl"> Ocultar valores zerados</span></label>
            <br>
            <button class="btn btn-sm btn-primary" id="btnFiltrar">FILTRAR</button>
        </div>
      </div>
    </div>
</form>

<h1>Análise de Receitas</h1>


<table class="table">
    <thead>

    </thead>
    <tbody>
        <tr>
            <td>1. RECEITAS</td>
            <td class="text-right">0,00</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;1.1. SERVIÇOS</td>
            <td class="text-right">0,00</td>
        </tr>
        <%
        c = 0
        sql = "select ifnull(tp.TipoProcedimento, 'Não categorizado') NomeTipo, p.TipoProcedimentoID from itensinvoice ii LEFT JOIN procedimentos p on p.id=ii.ItemID LEFT JOIN tiposprocedimentos tp on tp.id=p.TipoProcedimentoID LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID WHERE ii.Tipo='S' AND i.sysDate>="&mydatenull(De)&" AND i.sysDate<="&mydatenull(Ate)&" GROUP BY NomeTipo ORDER BY tp.TipoProcedimento DESC"
  '      response.write(sql)
        set iserv = db.execute(sql)
        while not iserv.eof
            c = c+1
            %>
            <tr>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.1.<%=c &". "&  iserv("NomeTipo") %></td>
                <td class="text-right"><%=fn(subtotal) %></td>
            </tr>
            <%
            set procs = db.execute("select p.NomeProcedimento, SUM(ii.ValorUnitario) Total FROM itensinvoice ii LEFT JOIN procedimentos p on p.id=ii.ItemID WHERE ii.Tipo='S' AND p.TipoProcedimentoID="&treatvalzero(iserv("TipoProcedimentoID"))&" GROUP BY p.NomeProcedimento ORDER BY p.NomeProcedimento")
            while not procs.eof
                %>
                <tr>
                    <td>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <%=procs("NomeProcedimento") %>
                    </td>
                    <td class="text-right"><%=fn(procs("Total")) %></td>
                </tr>
                <%
            procs.movenext
            wend
            procs.close
            set procs=nothing
        iserv.movenext
        wend
        iserv.close
        set iserv=nothing
        %>
    </tbody>
</table>


<script type="text/javascript">
$(function () {

    var colors = Highcharts.getOptions().colors,
        categories = [<%
		splChart = split(titChart, "|")
		for k=0 to ubound(splChart)%>'<%=splChart(k)%>', <%next%>],
        data = [
		<%
		c = 0
		splChart = split(titChart, "|")
		splValChart = split(valChart, "|")
		
		splSubtit = split(subtitChart, "|^")
		splSubval = split(subvalChart, "|^")
		
		for j=0 to ubound(splChart)
		%>
		{
            y: <%=splValChart(j)%>,
            color: colors[<%=c%>],
            drilldown: {
                name: '<%=splChart(j)%>',
                categories: [<%=splSubtit(j)%>],
                data: [<%=splSubval(j)%>],
                color: colors[<%=c%>]
            }
        },
		<%
		c = c+1
		next
		%> 
		],
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
            text: ''
        },
        yAxis: {
            title: {
                text: ''
            }
        },
        plotOptions: {
            pie: {
                shadow: false,
                center: ['50%', '50%']
            }
        },
        tooltip: {
            valueSuffix: ''
        },
        series: [{
            name: 'Categoria',
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
            name: 'Subcategoria',
            data: versionsData,
            size: '100%',
            innerSize: '60%',
            dataLabels: {
                formatter: function () {
                    // display only if larger than 1
                    return this.y > 1 ? '<b>' + this.point.name + ':</b> R$ ' + this.y : null;
                }
            }
        }]
    });
});

$('#frmfiltros').submit(function(){
	$('#btnFiltrar').html('Filtrando...');
	$.get("AnaliseReceitas.asp?"+$('#frmfiltros').serialize(), function(data) { $('#relConteudo').html(data) });
	return false;
})
</script>