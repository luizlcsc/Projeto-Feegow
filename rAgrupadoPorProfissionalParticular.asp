<!--#include file="connect.asp"-->

<style type="text/css">
body, tr, td, th {
	font-size:11px;
	padding:2px!important;
}
</style>

<%
DataDe = req("DataDe")
DataAte = req("DataAte")
%>
<h3 class="text-center">Produ&ccedil;&atilde;o M&eacute;dica - Particular</h3>
<h4 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h4>

      <%
	  Total = 0
	  set prof = db.execute("select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional")
	  while not prof.eof
	  %>
<table class="table" width="100%">
	<thead>
        <tr>
            <th>DATA</th>
        	<th>PACIENTE</th>
            <th class="text-center">SERVI&Ccedil;O / PROCEDIMENTO</th>
            <th class="text-center">VALOR</th>
            <th class="text-center">DESCONTO</th>
            <th class="text-center">ACR&Eacute;SC.</th>
            <th class="text-right">CL&Iacute;NICA</th>
            <th class="text-right">PRESTADOR</th>
            <th class="text-right">DESPESAS</th>
            <th class="text-right">L&Iacute;QUIDO</th>
        </tr>
	</thead>
    <tbody>
		<tr>
        	<th colspan="5">PROFISSIONAL: <%=ucase(prof("NomeProfissional"))%></th>
        </tr>
        <%
		ProfissionalID = prof("id")
		
		set G = db.execute("select ii.*, p.NomePaciente, proc.NomeProcedimento from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID LEFT JOIN pacientes p on p.id=i.AccountID LEFT JOIN procedimentos proc on proc.id=ii.ItemID where  ii.ProfissionalID="&ProfissionalID&" and ii.DataExecucao>="&mydatenull(DataDe)&" and ii.DataExecucao<="&mydatenull(DataAte)&" order by ii.DataExecucao")
'		set G = db.execute("select * from tissguiaconsulta where ProfissionalID="&prof("id")&" and sysActive=1  and DataAtendimento>="&mydatenull(DataDe)&" and DataAtendimento<="&mydatenull(DataAte)&" order by DataAtendimento")
		Subtotal = 0
		Subdesco = 0
		Subacres = 0
		while not G.eof
			Subtotal = Subtotal+G("ValorUnitario")
			Subdesco = Subdesco+G("Desconto")
			Subacres = Subacres+G("Acrescimo")
			%>
			<tr>
            	<td><%=G("DataExecucao")%></td>
            	<td><%=G("NomePaciente")%></td>
            	<td><%=G("NomeProcedimento")%></td>
            	<td class="text-right"><%=formatnumber(G("ValorUnitario"),2)%></td>
                <td class="text-right"><%=formatnumber(G("Desconto"),2)%></td>
                <td class="text-right"><%=formatnumber(G("Acrescimo"),2)%></td>
                <td class="text-right">0,00</td>
                <td class="text-right">0,00</td>
                <td class="text-right">0,00</td>
                <td class="text-right">0,00</td>
            </tr>
			<%
		G.movenext
		wend
		G.close
		set G=nothing
		%>
		<tr>
        	<td class="text-right" colspan="3"><strong>SUBTOTAL:</strong></td>
            <td class="text-right"><strong><%=formatnumber(Subtotal,2)%></strong></td>
            <td class="text-right"><strong><%=formatnumber(Subdesco,2)%></strong></td>
            <td class="text-right"><strong><%=formatnumber(Subacres,2)%></strong></td>
            <td class="text-right"><strong>0,00</strong></td>
            <td class="text-right"><strong>0,00</strong></td>
            <td class="text-right"><strong>0,00</strong></td>
            <td class="text-right"><strong>0,00</strong></td>
        </tr>
    </tbody>
</table>
<hr style="page-break-after:always" />
	  <%
	  prof.movenext
	  wend
	  prof.close
	  set prof = nothing
	  %>
