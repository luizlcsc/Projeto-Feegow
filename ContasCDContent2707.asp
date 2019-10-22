<!--#include file="connect.asp"-->
<%

geraRecorrente(0)

if req("X")<>"" then
	db_execute("delete from sys_financialinvoices where id="&req("X"))
	db_execute("delete from sys_financialmovement where InvoiceID="&req("X"))
end if

c=0
Total=0
GranTotalPago=0
TotalVencido = 0
TotalAVencer = 0

CD = req("T")

if CD="C" then
	TabelaCategoria = "sys_financialincometype"
else
	TabelaCategoria = "sys_financialexpensetype"
end if
%>

<div class="row">
  <div class="col-md-12">
	<table class="table table-striped table-bordered table-hover">
	<thead>
		<tr class="success">
			<th>Data</th>
			<th>Conta</th>
			<th>Descri&ccedil;&atilde;o</th>
			<th>Valor</th>
			<th>Pago</th>
			<th width="1%"></th>
		</tr>
	</thead>
	<%
	Balance = 0
	linhas = 0
	ExibiuPrimeiraLinha = "N"
	SaldoAnteriorFim = 0
	if ref("CompanyUnitID")<>"" then
		sqlUN = " AND i.CompanyUnitID IN("& replace(ref("CompanyUnitID"), "|", "") &") "
	end if

	if ref("AccountID")<>"" and instr(ref("AccountID"), "_") then
		splAcc = split(ref("AccountID"), "_")
		sqlAccount = " AND i.AssociationAccountID="&splAcc(0)&" AND i.AccountID="&splAcc(1)&" "
	end if
	
	if ref("Pagto")="Q" then
		sqlPagto = " AND m.Value<=m.ValorPago "
	elseif ref("Pagto")="N" then
		sqlPagto = " AND (m.Value>m.ValorPago OR isnull(m.ValorPago)) "
	end if

	if ref("CategoriaID")<>"" and isnumeric(ref("CategoriaID")) and ref("CategoriaID")<>"0" then
		lfCat = " LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id AND ii.Tipo='O' "
		sqlCat = " AND ii.CategoriaID="&ref("CategoriaID")&" "
		gpCat = " GROUP BY m.id "
	end if

    sqlMov = "select i.AccountID ContaID, i.AssociationAccountID Assoc, i.CompanyUnitID UnidadeID, m.Value, m.InvoiceID, m.id, m.Name, m.Date, ifnull(m.ValorPago, 0) ValorPago, m.Obs FROM sys_financialMovement m left join sys_financialinvoices i on i.id=m.InvoiceID "& lfCat &" WHERE m.Type='Bill' AND m.Date BETWEEN "&mydatenull(ref("De"))&" AND "&mydatenull(ref("Ate"))&" AND m.CD='"&CD&"' AND i.sysActive=1 "& sqlUN & sqlAccount & sqlPagto & sqlCat & gpCat &" order by m.Date"
'    response.write(sqlMOv)
	set mov = db.execute( sqlMov )
	while not mov.eof

        
		Valor = mov("Value")
		ValorPago = mov("ValorPago")
		Descricao = ""
		SaldoAnterior = Balance
		Conta = accountName(mov("Assoc"), mov("ContaID"))
		linkBill = "./?P=invoice&I="&mov("InvoiceID")&"&A=&Pers=1&T="&CD
		if Valor<=ValorPago then
			Paid = "<i class='fa fa-check text-success' title='Quitado'></i>"
		else
            if mov("Date")>date() then
    			Paid = ""
                TotalAVencer = TotalAVencer + (Valor-ValorPago)
            else
                Paid = "<i class='fa fa-exclamation-circle text-danger' title='Vencido'></i>"
                TotalVencido = TotalVencido + (Valor-ValorPago)
            end if
		end if

		c=c+1
		Total = Total+Valor
		GranTotalPago = GranTotalPago+ValorPago


		cItens = 0
		Descricao = ""
		set itens = db.execute("select * from itensinvoice where InvoiceID="&mov("InvoiceID"))
		while not itens.eof
			if itens("Tipo")="S" then
				set proc = db.execute("select id, NomeProcedimento from procedimentos where id="&itens("ItemID"))
				if not proc.eof then
					Descricao = Descricao & ", " & left(proc("NomeProcedimento"), 23)
				end if
			elseif itens("Tipo")="O" then
				Descricao = Descricao & ", " & left(itens("Descricao"), 23)
			end if
			if itens("Quantidade")>1 then
				Descricao = Descricao &" ("&itens("Quantidade")&")"
			end if
			cItens = cItens+1
		itens.movenext
		wend
		itens.close
		set itens=nothing
'		if cItens>1 then
'			Descricao = cItens&" itens"
'		end if
		if len(Descricao)>1 then
			Descricao = right(Descricao, len(Descricao)-2)
		end if
		if isnull(Valor) then
			Valor = 0
		end if
		%>
		<tr>
			<td width="8%" class="text-right"><%= mov("Date") %></td>
			<td><%= Conta %></td>
			<td><a href="<%= linkBill %>"><%=Descricao%>
					<%if len(mov("Name"))>0 and Descricao<>"" then%> - <%end if%><%=left(mov("Name"),20)%>
				</a><br /><%=mov("Obs")%>
				</td>
			<td class="text-right" nowrap> <%= fn(Valor) %>&nbsp;<%= Paid %> <%=displayCD%></td>
			<td class="text-right"><%= fn(ValorPago) %></td>
			<td nowrap="nowrap">
				<div class="action-buttons">
					<a title="Editar" class="btn btn-xs btn-success" href="<%=linkBill%>"><i class="fa fa-edit bigger-130"></i></a>
					<a title="Detalhes" class="btn btn-xs btn-info" href="javascript:modalPaymentDetails('<%=mov("id")%>')">
                       <i class="fa fa-search-plus bigger-130"></i></a>
				</div>
			</td>
		</tr>
		<%
	mov.movenext
	wend
	mov.close
	set mov = nothing


if cdate(ref("Ate"))>date() then
    set fixa = db.execute("select f.* from invoicesfixas f where f.sysActive=1 and f.CD='"&CD&"' and PrimeiroVencto<="&mydatenull(ref("Ate"))&"")
    while not fixa.eof
        set itens = db.execute("select ifnull(proc.NomeProcedimento, i.Descricao) Item from itensinvoicefixa i left join procedimentos proc on proc.id=i.ItemID where i.InvoiceID="&fixa("id"))
        ItensFixa = ""
        while not itens.eof
            ItensFixa = itens("Item") & "<br>" &ItensFixa
        itens.movenext
        wend
        itens.close
        set itens=nothing
        
        Geradas = fixa("Geradas")&""
        
        Vencto = fixa("PrimeiroVencto")
        cFix = 0
        RepetirAte = fixa("RepetirAte")
        if isnull(RepetirAte) then
            RepetirAte = cdate("01/01/2500")
        else
            RepetirAte = cdate(fixa("RepetirAte"))
        end if
        while Vencto<=cdate(ref("Ate")) and cdate(Vencto)<=RepetirAte
            cFix = cFix+1
            if instr(Geradas, "|"& cFix &"|")=0 then
                %>
                <tr>
                    <td class="text-right"><%=Vencto %> <%'=RepetirAte %></td>
                    <td><%=accountName(fixa("AssociationAccountID"), fixa("AccountID")) %></td>
                    <td><%=ItensFixa %></td>
                    <td class="text-right"><%=fn(fixa("Value")) %></td>
                    <td class="text-right">0,00</td>
                    <td>
                        <div class="action-buttons">
                            <a class="btn btn-xs" href="javascript:if(confirm('Esta conta fixa está prevista. Ao editá-la a mesma será consolidada. Deseja prosseguir?'))consolidar(<%=fixa("id")%>, <%=cFix %>, '<%=Vencto %>')"><i class="fa fa-edit grey bigger-130"></i></a>
                        </div>
                    </td>
                </tr>
                <%
                Total = Total+fixa("Value")
            end if
            Vencto = dateAdd(fixa("TipoIntervalo"), fixa("Intervalo")*cFix, fixa("PrimeiroVencto"))
        wend
    fixa.movenext
    wend
    fixa.close
    set fixa=nothing
end if
    %>
        <tfoot>
	        <tr>
		        <th colspan="3"><%=c%> registro<%if c>1 then response.Write("s") end if %></th>
		        <th class="text-right"><%=fn(Total)%></th>
		        <th class="text-right"><%=fn(GranTotalPago)%></th>
                <th></th>
	        </tr>
	    </tfoot>
    </table>
      <%

if c=0 then
	%>
	<div class="col-md-12 text-center">N&atilde;o h&aacute; lan&ccedil;amentos para o per&iacute;odo consultado.</div>
	<%
end if
%>
  </div>
</div>


<script type="text/javascript">
    function consolidar(I, N, D){
        $.get("consolidar.asp?I="+I+"&N="+N+"&D="+D, function(data){eval(data)});
    }

    $(function () {
        $('#container').highcharts({
            chart: {
                margin:0,
                backgroundColor:null,
                plotBorderWidth: null,
                plotShadow: false,
                type: 'pie',
                height: 140,
                legend: {
                    enabled:false
                },
            },
            title: {
                text: ''
            },
            tooltip: {
                pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: 'pointer',
                    dataLabels: {
                        enabled: false,
                        format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                        style: {
                            color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                        }
                    }
                }
            },
            series: [{
                name: 'Percentual',
                colorByPoint: true,
                data: [{
                    color:'green',
                    name: 'Liquidado: R$ <%=fn(GranTotalPago)%>',
                    y: <%=treatval(GranTotalPago)%>,
                    sliced:true
                }, {
                    color:'red',
                    name: 'Vencido: R$ <%=fn(TotalVencido)%>',
                    y: <%=treatval(TotalVencido)%>
                }, {
                    color:'#999',
                    name: 'A vencer: R$ <%=fn(TotalAVencer)%>',
                    y: <%=treatval(TotalAVencer)%>
                }]
            }]
        });
    });
</script>