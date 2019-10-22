<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

DataDe = request.QueryString("De")
DataAte = request.QueryString("Ate")
if DataDe="" then
	DataDe = "01/"&month(date())&"/"&year(date())
end if
if DataAte="" then
	DataAte = dateadd("m", 1, DataDe)
	DataAte = dateadd("d", -1, DataAte)
end if
%>
<h3 class="text-center">Resultado por Origem</h3>
<h4 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h4>

<table class="table table-striped table-condensed" width="100%">
	<thead>
        <tr>
            <th class="text-center">PACIENTE</th>
            <th class="text-center">ORIGEM</th>
            <th class="text-center">VALOR TOTAL</th>
            <th class="text-center">VALOR PAGO</th>
        </tr>
	</thead>
    <tbody>
      <%
	  TotalValorTotal = 0
	  set mov = db.execute("select m.*, p.NomePaciente, o.Origem from sys_financialmovement m LEFT JOIN pacientes p on p.id=m.AccountIDDebit LEFT JOIN origens o on o.id=p.Origem where m.Type='Bill' and m.CD='C' and Date>="&mydatenull(DataDe)&" and Date<="&mydatenull(DataAte)&" and not isnull(o.origem) order by o.origem")
	  while not mov.eof
		
		ValorPago = mov("ValorPago")
		if isnull(ValorPago) then
			ValorPago = 0
		end if
		
		TotalValorTotal = TotalValorTotal+ValorTotal
		TotalValorPago = TotalValorPago+ValorPago

	  	ValorTotal = formatnumber(mov("Value"),2)
		ValorPago = formatnumber(ValorPago, 2)
	  	%>
		<tr>
        	<td><%= mov("NomePaciente") %></td>
        	<td><%= mov("Origem") %></td>
        	<td class="text-right"><%= ValorTotal %></td>
        	<td class="text-right"><%= ValorPago %></td>
        </tr>
		<%
	  mov.movenext
	  wend
	  mov.close
	  set mov=nothing
	  %>
    </tbody>
    <tfoot>
    	<tr>
        	<td class="text-right" colspan="2"><strong>TOTAL GERAL:</strong></td>
          <td class="text-right"><strong><%=formatnumber(TotalValorTotal,2)%></strong></td>
            <td class="text-right"><strong><%=formatnumber(TotalValorPago,2)%></strong></td>
        </tr>
    </tfoot>
</table>