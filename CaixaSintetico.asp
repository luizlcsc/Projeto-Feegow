<!--#include file="connect.asp"-->
<style>
.pointer{
	cursor:pointer;
}
.consulta, .sadt{
	display:none;
}
</style>
<%

if req("De")="" then
	De = date()
	Ate = date()
else
	De = req("De")
	Ate = req("Ate")
end if

if De=Ate then
	Subdata = De
else
	Subdata = De &" a "& Ate
end if
%>

<script>
	function cd(CategoriaID){
//		location.href="<%="./?P=ContasCD&Pers=1&CD=D&De="&De&"&Ate="&Ate&"&U="&U&"&CategoriaID="%>"+CategoriaID;
	}
</script>
<form class="panel mt20" id="frmfiltros">

	<div class="panel-heading">
		<span class="panel-title">
		<%
			if req("Cx") = "S" then
				%>
                Caixa - Sintético
                <%
			else
				%>
                Movimentação - Sintético
                <%
			end if
		%>
		</span>
	</div>
	<div class="panel-body">
		<input type="hidden" name="Cx" value="<%=req("Cx")%>">
		<div class="row hidden-print">
			<%=quickField("datepicker", "De", "De", 2, De, "", "", "")%>
			<%=quickField("datepicker", "Ate", "Até", 2, Ate, "", "", "")%>
			<div class="col-md-1 pt25"><a class="btn btn-block btn-default" href="#" onClick="$('#filtros').toggleClass('hidden')"><i class="far fa-filter"></i></a></div>
			<div class="col-md-1 pt25"><button type="button" class="btn btn-block btn-info pull-right" onclick="print()"><i class="far fa-print"></i></button></div>
			<div class="col-md-2 pt25"><button id="btnFiltrar" class="btn btn-block btn-primary"><i class="far fa-search"></i> Gerar</button></div>
		</div>
		<hr class="hidden-print short alt" />
		<div class="row visible-print">
			<h2 class="text-center">CAIXA - SINTÉTICO <br>
				<small><%=subData%></small>
			</h2>
		</div>
	</div>

	<input type="hidden" name="Data" id="Data" value="<%=Data%>">
	<input type="hidden" name="Pars" value="<%=tipo%>">
	<div class="panel-body form-actions hidden" id="filtros">
		<div class="row">
			<div class="col-xs-12">
				<label><input class="todos btn btn-xs" type="checkbox" value="1" ><span class="lbl">Marcar / Desmarcar todos</span></label>
			</div>
		</div>
		<div class="row">
			<%=quickField("empresaMultiCheck", "U", "Unidade", 12, Unidades, "", "", "")%>
		</div>

		</div>
	</div>
</form>

<div class="row">
	<div class="col-xs-12" id="containeXr"></div>
</div>

<div class="panel m20">
	<div class="panel-body">
		<%
		tipoCD = "D, C"
		splTipoCD = split(tipoCD, ", ")

		for r=0 to ubound(splTipoCD)
			TipoCD = splTipoCD(r)
			if TipoCD="D" then
				Titulo = "ENTRADAS"
			else
				Titulo = "SAÍDAS"
			end if
			%>

			<table class="table table-bordered table-hover table-condensed">
				<thead>
					<tr>
						<th><%=Titulo%></th>
						<th width="20%">VALOR</th>
					</tr>
				</thead>
				<tbody>
			<%
			set transnull = db.execute("select * from sys_financialcreditcardtransaction where isnull(Parcelas)")
			while not transnull.EOF
				db_execute("update sys_financialcreditcardtransaction set Parcelas=(select count(id) from sys_financialcreditcardreceiptinstallments where TransactionID="&transnull("id")&") where id="&transnull("id"))
			transnull.movenext
			wend
			transnull.close
			set transnull=nothing

			'on error resume next

			db_execute("delete from cliniccentral.rel_fechamento"&TipoCD&" WHERE UsuarioID="&session("User"))

			if req("Cx")="S" then
				sqlCx = " AND NOT ISNULL(CaixaID) AND CaixaID<>0"
			end if

			Unidades = req("U")
			if Unidades="" then Unidades=session("Unidades") end if

			sql = "SELECT m.* FROM sys_financialmovement m WHERE m.Date BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" AND Type='Pay' AND CD='"&TipoCD&"' AND UnidadeID in ("&replace(Unidades, "|", "")&") AND m.Type!='Transfer' " & sqlCx
			'response.Write(sql)
			set m = db.execute(sql)
			while not m.eof
				BandeiraID = ""
				DataCheque = ""
				DiasCheque = ""
				MetodoID = m("PaymentMethodID")
				Parcelas = ""
				if MetodoID=8 then
					set cc=db.execute("select distinct tr.Parcelas from sys_financialcreditcardtransaction tr WHERE tr.MovementID="&m("id"))
					if not cc.eof then
						Parcelas = cc("Parcelas")
						BandeiraID = m("AccountIDDebit")
					end if
				elseif MetodoID=2 then
					set cq = db.execute("select * from sys_financialreceivedchecks WHERE MovementID="&m("id"))
					if not cq.eof then
						DataCheque = cq("CheckDate")
						if isdate(DataCheque) and not isnull(DataCheque) then
							DiasCheque = datediff("d", m("Date"), cq("CheckDate"))
						end if
					end if
				end if
				if isnull(Parcelas) then
					Parcelas = 1
				end if
				sqlIns = "insert into cliniccentral.rel_fechamento"&TipoCD&" (MovimentoID, MetodoID, UnidadeID, UsuarioID, Parcelas, Data, Valor, BandeiraID, DiasCheque) values ("&m("id")&", "&MetodoID&", "&treatvalzero(m("UnidadeID"))&", "&session("User")&", "&treatvalnull(Parcelas)&", "&mydatenull(m("Date"))&", "&treatvalzero(m("Value"))&", "& treatvalnull(BandeiraID) &", "& treatvalnull( DiasCheque ) &")"
				'if DiasCheque<>"" then
				'	response.Write(sqlIns)
				'end if
				db.execute(sqlIns)
			m.movenext
			wend
			m.close
			set m=nothing

			total = 0
			set dist = db.execute("select distinct MetodoID, pm.PaymentMethod, (select sum(Valor) from cliniccentral.rel_fechamento"&TipoCD&" where UsuarioID="&session("User")&" and MetodoID=m.MetodoID) Valor from cliniccentral.rel_fechamento"&TipoCD&" m LEFT JOIN cliniccentral.sys_financialpaymentmethod pm on pm.id=m.MetodoID WHERE m.UsuarioID="&session("User")&" ORDER BY pm.PaymentMethod")
			while not dist.EOF
				total = total + dist("Valor")
				%>
				<tr<%if dist("MetodoID")<>2 and dist("MetodoID")<>8 then%> class="pointer" onClick="ajxAfter('CaixaDetalhes', '&U=<%= Unidades %>&MetodoID=<%=dist("MetodoID")%>', 1, 'div_<%=TipoCD & dist("MetodoID")%>')"<%end if%> id="div_<%=TipoCD & dist("MetodoID")%>">
					<td><strong><%=dist("PaymentMethod")%></strong></td>
					<td class="text-right"><strong><%=formatnumber( 0&dist("Valor"), 2) %></strong></td>
				</tr>
				<%
				if dist("MetodoID")=8 then
					set band = db.execute("select distinct m.BandeiraID, b.AccountName NomeBandeira, (select sum(Valor) from cliniccentral.rel_fechamento"&TipoCD&" WHERE UsuarioID="&session("User")&" AND BandeiraID=m.BandeiraID) Subtotal from cliniccentral.rel_fechamento"&TipoCD&" m LEFT JOIN sys_financialcurrentaccounts b on b.id=m.BandeiraID WHERE m.UsuarioID="&session("User")&" AND m.MetodoID=8 ORDER BY b.AccountName")
					while not band.eof
						%>
						<tr>
							<td>&nbsp;&nbsp;&nbsp;&nbsp;<%=band("NomeBandeira")%></td>
							<td class="text-right"><%=formatnumber(0&band("Subtotal"), 2)%></td>
						</tr>
						<%
						set parcs = db.execute("select distinct m.Parcelas, (select sum(Valor) from cliniccentral.rel_fechamento"&TipoCD&" WHERE UsuarioID="&session("User")&" AND MetodoID=8 AND BandeiraID="&treatvalnull(band("BandeiraID"))&" AND Parcelas=m.Parcelas) Subtotal from cliniccentral.rel_fechamento"&TipoCD&" m WHERE m.UsuarioID="&session("User")&" AND m.MetodoID=8 AND m.BandeiraID="&treatvalnull(band("BandeiraID"))&" ORDER BY m.Parcelas")
						while not parcs.EOF
							%>
							<tr onClick="ajxAfter('CaixaDetalhes', '&U=<%= Unidades %>&MetodoID=<%=dist("MetodoID")%>&BandeiraID=<%=band("BandeiraID")%>&Parcelas=<%=parcs("Parcelas")%>', 1, 'div_<%=TipoCD & dist("MetodoID")%>_<%=band("BandeiraID")%>_<%=parcs("Parcelas")%>')" class="pointer" id="div_<%=TipoCD & dist("MetodoID")%>_<%=band("BandeiraID")%>_<%=parcs("Parcelas")%>">
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										<%=parcs("Parcelas")%> parcelas
								</td>
								<td class="text-right"><%=formatnumber(0&parcs("Subtotal"), 2)%></td>
							</tr>
							<%
						parcs.movenext
						wend
						parcs.close
						set parcs=nothing
					band.movenext
					wend
					band.close
					set band=nothing
				elseif dist("MetodoID")=2 then
					set dc = db.execute("select distinct m.DiasCheque, (select sum(Valor) from cliniccentral.rel_fechamento"&TipoCD&" WHERE UsuarioID="&session("User")&" AND MetodoID=2 AND DiasCheque=m.DiasCheque) Subtotal from cliniccentral.rel_fechamento"&TipoCD&" m WHERE m.UsuarioID="&session("User")&" AND m.MetodoID=2 ORDER BY m.DiasCheque")
					while not dc.EOF
						if dc("DiasCheque")<2 then
							DescCq = "&Agrave; vista"
						else
							DescCq = dc("DiasCheque") & " dias"
						end if
						%>
						<tr id="div_<%=TipoCD & dist("MetodoID")%>_<%=dc("DiasCheque")%>" onClick="ajxAfter('CaixaDetalhes', '&U=<%= Unidades %>&MetodoID=<%=dist("MetodoID")%>&DiasCheque=<%=dc("DiasCheque")%>', 1, 'div_<%=TipoCD & dist("MetodoID")%>_<%=dc("DiasCheque")%>')" class="pointer">
							<td>&nbsp;&nbsp;&nbsp;&nbsp;
									<%=DescCq%></td>
							<td class="text-right"><%=formatnumber(0&dc("Subtotal"), 2)%></td>
						</tr>
						<%
					dc.movenext
					wend
					dc.close
					set dc=nothing
				end if

			dist.movenext
			wend
			dist.close
			set dist=nothing

			'db_execute("delete from cliniccentral.rel_fechamento"&TipoCD&" WHERE UsuarioID="&session("User"))
			%>
				</tbody>
				<tfoot>
					<tr>
						<td><strong>TOTAL</strong></td>
						<td class="text-right"><strong><%=formatnumber(total,2)%></strong></td>
					</tr>
				</tfoot>
			</table>
			<%
		next
		%>

		<table class="table table-bordered table-hover table-condensed">
			<thead>
				<tr>
					<th>CONVÊNIO</th>
					<th width="20%">VALOR</th>
				</tr>
			</thead>
			<tbody>
			<%
			set gc = db.execute("select ConvenioID, SUM(ValorProcedimento) Total, c.NomeConvenio FROM tissguiaconsulta g LEFT JOIN convenios c on c.id=g.ConvenioID WHERE DataAtendimento BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" AND UnidadeID in ("&replace(Unidades, "|", "")&") IS NOT NULL GROUP BY ConvenioID ORDER BY NomeConvenio")
			if not gc.EOF then
				set gTot = db.execute("select SUM(ValorProcedimento) Total FROM tissguiaconsulta WHERE DataAtendimento BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" AND UnidadeID in ("&replace(Unidades, "|", "")&")")
				if not isnull(gTot("Total")) then
					TotalConsulta = gTot("Total")
				else
					TotalConsulta = 0
				end if
				%>
				<tr class="pointer" onClick="$('.consulta').removeClass('consulta'); $(this).removeClass('pointer');">
					<td><strong>Guias de Consulta</strong></td>
					<td class="text-right"><strong><%=formatnumber(TotalConsulta, 2)%></strong></td>
				</tr>
				<%
			end if
			while not gc.EOF
				%>
				<tr class="consulta">
					<td style="padding-left:30px;"><%=gc("NomeConvenio")%></td>
					<td class="text-right"><%=formatnumber(gc("Total"), 2)%></td>
				</tr>
				<%
			gc.movenext
			wend
			gc.close
			set gc=nothing

			totalSADT = 0
			set gs = db.execute("select g.ConvenioID, SUM(pg.ValorTotal) Total, IFNULL(c.NomeConvenio, '-') NomeConvenio FROM tissguiasadt g LEFT JOIN tissprocedimentossadt pg on pg.GuiaID=g.id LEFT JOIN convenios c on c.id=g.ConvenioID WHERE pg.Data BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" AND g.UnidadeID in ("&replace(Unidades, "|", "")&") AND g.ConvenioID IS NOT NULL GROUP BY g.ConvenioID ORDER BY NomeConvenio")
			if not gs.EOF then
				%>
				<tr class="pointer" onClick="$('.sadt').removeClass('sadt'); $(this).removeClass('pointer');">
					<td><strong>Guias de SP/SADT</strong></td>
					<td class="text-right" id="totalSADT"><strong><%=formatnumber(TotalSADT, 2)%></strong></td>
				</tr>
				<%
			end if
			while not gs.EOF
				totalSADT = totalSADT+gs("Total")
				%>
				<tr class="sadt">
					<td style="padding-left:30px;"><%=gs("NomeConvenio")%></td>
					<td class="text-right"><%=formatnumber(gs("Total"), 2)%></td>
				</tr>
				<%
			gs.movenext
			wend
			gs.close
			set gs=nothing
			%>
			</tbody>
		</table>

	</div>
</div>



<script>
$("#totalSADT").html("<strong><%=formatnumber(totalSADT, 2)%></strong>");

$(function () {
	$(".todos").on('click', function(){
		var marcado = $(this).prop("checked")
		if(marcado){
			$(".ace").prop("checked", true)
		}else{
			$(".ace").prop("checked", false)
		}
	});
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
	$.get("CaixaSintetico.asp?"+$('#frmfiltros').serialize(), function(data) { $('#relConteudo').html(data) });
	return false;
})

function ajxAfter(P, I, Pers, Div){
	$("#"+Div).attr('onclick', '');
	$("#"+Div).removeClass('pointer');
	$.ajax({
		type: "POST",
		url: "ajxContent.asp?P="+P+"&I="+I+"&Pers="+Pers+"&q=&Div="+Div,
		success: function( data )
		{
			$("#"+Div).after(data);
		}
	});
}

<!--#include file="JQueryFunctions.asp"-->
<!--#include file="financialCommomScripts.asp"-->
</script>