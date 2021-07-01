<!--#include file="connect.asp"-->
<%
DataDe = req("DataDe")
DataAte = req("DataAte")
%>
<h3 class="text-center">Produ&ccedil;&atilde;o M&eacute;dica - Agrupado por Conv&ecirc;nio</h3>
<h4 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h4>

<table class="table" width="100%">
	<thead>
        <tr>
        	<th>CONV&Ecirc;NIO</th>
            <th class="text-right">FATURAMENTO</th>
            <th class="text-right">CL&Iacute;NICA</th>
            <th class="text-right">PRESTADOR</th>
            <th class="text-right">DESPESAS</th>
        </tr>
	</thead>
    <tbody>
      <%
	  Total = 0
	  set prof = db.execute("select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional")
	  while not prof.eof
	  %>
		<tr>
        	<th colspan="5">USU&Aacute;RIO: <%=ucase(prof("NomeProfissional"))%></th>
        </tr>
        <%
		Subtotal = 0
		set conv = db.execute("select * from convenios where sysActive=1 order by NomeConvenio")
		while not conv.eof
			set somaGC = db.execute("select sum(ValorProcedimento) as total from tissguiaconsulta where ProfissionalID="&prof("id")&" and ConvenioID="&conv("id")&" and sysActive=1 and DataAtendimento>="&mydatenull(DataDe)&" and DataAtendimento<="&mydatenull(DataAte))
			set somaGS = db.execute("select sum(i.ValorTotal) as total from tissprocedimentossadt as i left join tissguiasadt as g on i.GuiaID=g.id where i.ProfissionalID="&prof("id")&" and i.Data>="&mydatenull(DataDe)&" and i.Data<="&mydatenull(DataAte)&" and g.ConvenioID="&conv("id")&" and g.sysActive=1")
			TotalGC = somaGC("total")
			if isnull(TotalGC) then
				TotalGC=0
			end if
			TotalGS = somaGS("total")
			if isnull(TotalGS) then
				TotalGS = 0
			end if
			TotalG = TotalGC+TotalGS
			Subtotal = Subtotal+TotalG
			if TotalG<>0 then
				%>
				<tr>
					<td><%=ucase(conv("NomeConvenio"))%></td>
					<td class="text-right"><%=formatnumber(TotalG,2)%></td>
					<td class="text-right">0,00</td>
					<td class="text-right">0,00</td>
					<td class="text-right">0,00</td>
				</tr>
				<%
			end if
		conv.movenext
		wend
		conv.close
		set conv=nothing
		
		Total= Total+Subtotal
		%>
		<tr>
        	<td class="text-right"><strong>SUBTOTAL:</strong></td>
            <td class="text-right"><strong><%=formatnumber(Subtotal,2)%></strong></td>
            <td class="text-right"><strong>0,00</strong></td>
            <td class="text-right"><strong>0,00</strong></td>
            <td class="text-right"><strong>0,00</strong></td>
        </tr>
		<%
	  prof.movenext
	  wend
	  prof.close
	  set prof = nothing
	  %>
    </tbody>
    <tfoot>
    	<tr>
        	<td class="text-right"><strong>TOTAL GERAL:</strong></td>
          <td class="text-right"><strong><%=formatnumber(Total,2)%></strong></td>
            <td class="text-right"><strong>0,00</strong></td>
            <td class="text-right"><strong>0,00</strong></td>
            <td class="text-right"><strong>0,00</strong></td>
        </tr>
    </tfoot>
</table>