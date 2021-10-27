<!--#include file="connect.asp"-->

<%
'on error resume next

db_execute("delete from cliniccentral.rel_analise WHERE UsuarioID="&session("User"))

'distinct com os tipos de despesas que existem no período selecionado
'Faz 3, um com o id, outro com o contador começando do zero e outro com o valor

'Para definir o valor do item proporcionaliza o valor total pelo valor da parcela em questão no período

'1. pega todos os movimentos do período e seus valores
'2. pega todas as invoices desses movimentos e seus valores totais
'3. pega todos os itens dessas invoices e seus valores
'4. proporcionaliza os valores movimento X invoice X item, onde Invoice total forma o fator, vezes o amount do item da categoria -  é por aí

tipo = req("Pars")

Data = req("Data")
if Data = "" then
	Data = date()
end if

Mes = month(Data)
Ano = year(Data)

De = DiaMes("P", Data)
Ate = DiaMes("U", Data)
CD="D"
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
                <li class="hidden"><a href="javascript:callReport('Plano', '<%=tipo%>&Data=<%=dateadd("m", -1, Data)%>');"><i class="far fa-chevron-left"></i></a></li>
                <li><button class="btn btn-default" onClick="$('#Data').val('<%=dateadd("m", -1, Data)%>')"><i class="far fa-chevron-left"></i></button></li>
                <li><a href="#"><%=ucase(monthname(Mes)) &" - "& Ano%></a></li>
                <li><button class="btn btn-default" onClick="$('#Data').val('<%=dateadd("m", 1, Data)%>')"><i class="far fa-chevron-right"></i></button></li>
                <li class="hidden"><a href="javascript:callReport('Plano', '<%=tipo%>&Data=<%=dateadd("m", 1, Data)%>');"><i class="far fa-chevron-right"></i></a></li>
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

<div class="row">
	<div class="col-xs-12" id="container"></div>
</div>
<table class="table table-hover" style="cursor:pointer">

<%
c0 = 0
spl = split(tipo, ", ")
for i=0 to ubound(spl)
	c0 = c0+1
	c1 = 0

	if spl(i)="RECEITAS" then
        CD = "C"
        tabCat = "sys_financialincometype"
	    set n1 = db.execute("SELECT * FROM sys_financialincometype WHERE Category=0 ORDER BY Ordem")
	    set movs = db.execute("select m.InvoiceID, m.`Value`, (select count(id) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) Parcelas, (select SUM(Value) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) TotalInvoice FROM sys_financialmovement m LEFT JOIN sys_financialinvoices i on m.InvoiceID=i.id WHERE month(m.Date)="&Mes&" AND year(m.Date)="&Ano&" AND m.CD='"&CD&"' AND m.Type='Bill' AND i.CompanyUnitID in ("&replace(req("U"), "|", "")&")")
	    while not movs.eof

    '			response.Write("Esta parcela: "&movs("Value")&" - Total da Invoice: "&movs("TotalInvoice")&" - Parcelas: "&movs("Parcelas")&"<br>")

		    set itens = db.execute("SELECT * FROM itensinvoice WHERE InvoiceID="&movs("InvoiceID"))
		    while not itens.EOF
			    ValorItem = itens("Quantidade") * itens("ValorUnitario") - itens("Desconto") + itens("Acrescimo")
			    if movs("TotalInvoice")>0 then
				    Fator = 100 / movs("TotalInvoice")
			    else
				    Fator = 0
			    end if
			    PercItem = Fator * ValorItem
			    ValorProp = movs("Value") * (PercItem / 100)

    '				response.Write("- &gt; Total do item: "&ValorItem&" - Percentual item: "&PercItem&" - Valor Proporcional: "&ValorProp&" - Categoria: "&itens("CategoriaID")&"<br>")

			    db_execute("insert into cliniccentral.rel_analise (UsuarioID, CategoriaID, Valor) values ("&session("User")&", "&treatvalzero(itens("CategoriaID"))&", "&treatvalzero(ValorProp)&")")
		    itens.movenext
		    wend
		    itens.close
		    set itens=nothing
	    movs.movenext
	    wend
	    movs.close
	    set movs=nothing

	else
        CD = "D"
        tabCat = "sys_financialexpensetype"
	    set n1 = db.execute("SELECT * FROM sys_financialexpensetype WHERE Category=0 ORDER BY Ordem")
	    set movs = db.execute("select m.InvoiceID, m.`Value`, (select count(id) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) Parcelas, (select SUM(Value) from sys_financialmovement WHERE InvoiceID=m.InvoiceID) TotalInvoice FROM sys_financialmovement m LEFT JOIN sys_financialinvoices i on m.InvoiceID=i.id WHERE month(m.Date)="&Mes&" AND year(m.Date)="&Ano&" AND m.CD='"&CD&"' AND m.Type='Bill' AND i.CompanyUnitID in ("&replace(req("U"), "|", "")&")")
	    while not movs.eof

    '			response.Write("Esta parcela: "&movs("Value")&" - Total da Invoice: "&movs("TotalInvoice")&" - Parcelas: "&movs("Parcelas")&"<br>")

		    set itens = db.execute("SELECT * FROM itensinvoice WHERE InvoiceID="&movs("InvoiceID"))
		    while not itens.EOF
			    ValorItem = itens("Quantidade") * itens("ValorUnitario") - itens("Desconto") + itens("Acrescimo")
			    if movs("TotalInvoice")>0 then
				    Fator = 100 / movs("TotalInvoice")
			    else
				    Fator = 0
			    end if
			    PercItem = Fator * ValorItem
			    ValorProp = movs("Value") * (PercItem / 100)

    '				response.Write("- &gt; Total do item: "&ValorItem&" - Percentual item: "&PercItem&" - Valor Proporcional: "&ValorProp&" - Categoria: "&itens("CategoriaID")&"<br>")

			    db_execute("insert into cliniccentral.rel_analise (UsuarioID, CategoriaID, Valor) values ("&session("User")&", "&treatvalzero(itens("CategoriaID"))&", "&treatvalzero(ValorProp)&")")
		    itens.movenext
		    wend
		    itens.close
		    set itens=nothing
	    movs.movenext
	    wend
	    movs.close
	    set movs=nothing

    end if
		
		
	sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where CategoriaID!=0 AND CategoriaID IS NOT NULL AND UsuarioID="&session("User")
	set valRecursivo = db.execute(sqlVal)
	%>
	<tr onClick="cd('')">
		<td><%=c0%>. <%=spl(i)%></td>
		<td class="text-right hidden">0</td>
		<td class="text-right"><%=fn(valRecursivo("cTotal"))%></td>
	</tr>
	<%
	while not n1.EOF
		c1 = c1+1
				
		sqlv = ""
		set grupos = db.execute("SELECT group_concat(t1.id) g1, group_concat(t2.id) g2, group_concat(t3.id) g3, group_concat(t4.id) g4 FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.category = t1.id LEFT JOIN sys_financialexpensetype AS t3 ON t3.category = t2.id LEFT JOIN sys_financialexpensetype AS t4 ON t4.category = t3.id WHERE t1.Category="&n1("id"))
		if grupos("g1")&""<>"" then
			sqlv = " OR CategoriaID in ("&grupos("g1")&")"
		end if
		if grupos("g2")&""<>"" then
			sqlv = sqlv & " OR CategoriaID in ("&grupos("g2")&")"
		end if
		if grupos("g3")&""<>"" then
			sqlv = sqlv & " OR CategoriaID in ("&grupos("g3")&")"
		end if
		if grupos("g4")&""<>"" then
			sqlv = sqlv & " OR CategoriaID in ("&grupos("g4")&")"
		end if
		
		sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where UsuarioID="&session("User")&" and (CategoriaID="&n1("id")
		if sqlv<>"" then
			sqlVal = sqlVal & sqlv
		end if
		sqlVal = sqlVal & sqlv &")"
		
        'select sum(Valor) cTotal from cliniccentral.rel_analise where UsuarioID=83456 and (CategoriaID=50 OR CategoriaID in () OR CategoriaID in ()) <font face="Arial" size=2>

		'response.Write(sqlVal)
		set valRecursivo = db.execute(sqlVal)


		titChart = titChart & n1("Name") &"|"
		valChart = valChart & replace(replace(formatnumber(0&valRecursivo("cTotal"),2), ".", ""), ",", ".") &"|"
		
		subtitChart = subtitChart & "|^"
		subvalChart = subvalChart & "|^"
		%>
		<tr<%if (valRecursivo("cTotal")=0 or isnull(valRecursivo("cTotal"))) AND req("Ocultar")="S" then%> class="hidden"<%end if%> onClick="cd(<%=n1("id")%>)">
			<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=c0 &"."& c1%>. <%=n1("Name")%></td>
			<td class="text-right hidden">0</td>
			<td class="text-right"><%=formatnumber(0&valRecursivo("cTotal"),2)%></td>
		</tr>
		<%
		c2 = 0
		set n2 = db.execute("SELECT * FROM sys_financialexpensetype WHERE Category="&n1("id")&" ORDER BY Ordem")
		while not n2.EOF
			set val = db.execute("select sum(Valor) Total from cliniccentral.rel_analise where UsuarioID="&session("User")&" and CategoriaID="&n2("id"))
			c2 = c2+1
			
			sqlv = ""
			set grupos = db.execute("SELECT group_concat(t1.id) g1, group_concat(t2.id) g2, group_concat(t3.id) g3, group_concat(t4.id) g4 FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.category = t1.id LEFT JOIN sys_financialexpensetype AS t3 ON t3.category = t2.id LEFT JOIN sys_financialexpensetype AS t4 ON t4.category = t3.id WHERE t1.Category="&n2("id"))
			if not isnull(grupos("g1")) then
				sqlv = " OR CategoriaID in ("&grupos("g1")&")"
			end if
			if not isnull(grupos("g2")) then
				sqlv = sqlv & " OR CategoriaID in ("&grupos("g2")&")"
			end if
			if not isnull(grupos("g3")) then
				sqlv = sqlv & " OR CategoriaID in ("&grupos("g3")&")"
			end if
			if not isnull(grupos("g4")) then
				sqlv = sqlv & " OR CategoriaID in ("&grupos("g4")&")"
			end if
			
			sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where UsuarioID="&session("User")&" and (CategoriaID="&n2("id")
			if sqlv<>"" then
				sqlVal = sqlVal & sqlv
			end if
			sqlVal = sqlVal & sqlv &")"
			
			'response.Write(sqlVal)
			set valRecursivo = db.execute(sqlVal)


			subtitChart = subtitChart & "'"& replace(n2("Name")&" ", "'", "") &"'" & ", "
			subvalChart = subvalChart & replace(replace(formatnumber(0&valRecursivo("cTotal"),2), ".", ""), ",", ".") & ", "
			%>
			<tr<%if (valRecursivo("cTotal")=0 or isnull(valRecursivo("cTotal"))) AND req("Ocultar")="S" then%> class="hidden"<%end if%> onClick="cd(<%=n2("id")%>)">
				<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=c0 &"."& c1 &"."& c2%>. <%=n2("Name")%></td>
				<td class="text-right hidden"><%=formatnumber(0&val("Total"),2)%></td>
				<td class="text-right"><%=formatnumber(0&valRecursivo("cTotal"),2)%></td>
			</tr>
			<%
			c3 = 0
			set n3 = db.execute("SELECT * FROM sys_financialexpensetype WHERE Category="&n2("id")&" ORDER BY Ordem")
			while not n3.EOF
				set val = db.execute("select sum(Valor) Total from cliniccentral.rel_analise where UsuarioID="&session("User")&" and CategoriaID="&n3("id"))
				c3 = c3+1
				
				sqlv = ""
				set grupos = db.execute("SELECT group_concat(t1.id) g1, group_concat(t2.id) g2, group_concat(t3.id) g3, group_concat(t4.id) g4 FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.category = t1.id LEFT JOIN sys_financialexpensetype AS t3 ON t3.category = t2.id LEFT JOIN sys_financialexpensetype AS t4 ON t4.category = t3.id WHERE t1.Category="&n3("id"))
				if not isnull(grupos("g1")) then
					sqlv = " OR CategoriaID in ("&grupos("g1")&")"
				end if
				if not isnull(grupos("g2")) then
					sqlv = sqlv & " OR CategoriaID in ("&grupos("g2")&")"
				end if
				if not isnull(grupos("g3")) then
					sqlv = sqlv & " OR CategoriaID in ("&grupos("g3")&")"
				end if
				if not isnull(grupos("g4")) then
					sqlv = sqlv & " OR CategoriaID in ("&grupos("g4")&")"
				end if
				
				sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where UsuarioID="&session("User")&" and (CategoriaID="&n3("id")
				if sqlv<>"" then
					sqlVal = sqlVal & sqlv
				end if
				sqlVal = sqlVal & sqlv &")"
				
				'response.Write(sqlVal)
				set valRecursivo = db.execute(sqlVal)
				%>
				<tr<%if (valRecursivo("cTotal")=0 or isnull(valRecursivo("cTotal"))) AND req("Ocultar")="S" then%> class="hidden"<%end if%> onClick="cd(<%=n3("id")%>)">
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=c0 &"."& c1 &"."& c2 &"."& c3%>. <%=n3("Name")%></td>
					<td class="text-right hidden"><%=formatnumber(0&val("Total"),2)%></td>
					<td class="text-right"><%=formatnumber(0&valRecursivo("cTotal"),2)%></td>
				</tr>
				<%
				c4 = 0
				set n4 = db.execute("SELECT * FROM sys_financialexpensetype WHERE Category="&n3("id")&" ORDER BY Ordem")
				while not n4.EOF
					set val = db.execute("select sum(Valor) Total from cliniccentral.rel_analise where UsuarioID="&session("User")&" and CategoriaID="&n4("id"))
					c4 = c4+1
				
					sqlv = ""
					set grupos = db.execute("SELECT group_concat(t1.id) g1, group_concat(t2.id) g2, group_concat(t3.id) g3, group_concat(t4.id) g4 FROM sys_financialexpensetype AS t1 LEFT JOIN sys_financialexpensetype AS t2 ON t2.category = t1.id LEFT JOIN sys_financialexpensetype AS t3 ON t3.category = t2.id LEFT JOIN sys_financialexpensetype AS t4 ON t4.category = t3.id WHERE t1.Category="&n4("id"))
					if not isnull(grupos("g1")) then
						sqlv = " OR CategoriaID in ("&grupos("g1")&")"
					end if
					if not isnull(grupos("g2")) then
						sqlv = sqlv & " OR CategoriaID in ("&grupos("g2")&")"
					end if
					if not isnull(grupos("g3")) then
						sqlv = sqlv & " OR CategoriaID in ("&grupos("g3")&")"
					end if
					if not isnull(grupos("g4")) then
						sqlv = sqlv & " OR CategoriaID in ("&grupos("g4")&")"
					end if
					
					sqlVal = "select sum(Valor) cTotal from cliniccentral.rel_analise where UsuarioID="&session("User")&" and (CategoriaID="&n4("id")
					if sqlv<>"" then
						sqlVal = sqlVal & sqlv
					end if
					sqlVal = sqlVal & sqlv &")"
					
					'response.Write(sqlVal)
					set valRecursivo = db.execute(sqlVal)
					%>
					<tr<%if (valRecursivo("cTotal")=0 or isnull(valRecursivo("cTotal"))) AND req("Ocultar")="S" then%> class="hidden"<%end if%> onClick="cd(<%=n4("id")%>)">
						<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=c0 &"."& c1 &"."& c2 &"."& c3 &"."& c4%>. <%=n4("Name")%></td>
                        <td class="text-right hidden"><%=formatnumber(0&val("Total"),2)%></td>
                        <td class="text-right"><%=formatnumber(0&valRecursivo("cTotal"),2)%></td>
					</tr>
					<%
				n4.movenext
				wend
				n4.close
				set n4=nothing
			n3.movenext
			wend
			n3.close
			set n3=nothing
		n2.movenext
		wend
		n2.close
		set n2=nothing
	n1.movenext
	wend
	n1.close
	set n1=nothing
next

'db_execute("delete from cliniccentral.rel_analise WHERE UsuarioID="&session("User"))

'Percentuais devem aparecer no gráfico.

'Categorias e depois procedimentos, e colocar procedimentos sem categoria.%>
</table>

<%
titChart = left(titChart, len(titChart)-1)
valChart = left(valChart, len(valChart)-1)

subtitChart = right(subtitChart, len(subtitChart)-2)
subvalChart = right(subvalChart, len(subvalChart)-2)
%>

<script>
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
	$.get("Plano.asp?"+$('#frmfiltros').serialize(), function(data) { $('#relConteudo').html(data) });
	return false;
})
</script>