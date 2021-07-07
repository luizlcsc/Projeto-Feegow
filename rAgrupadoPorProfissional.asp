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
<h3 class="text-center">Produ&ccedil;&atilde;o M&eacute;dica</h3>
<h4 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h4>

      <%
	  Total = 0
	  set prof = db.execute("select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional")
	  while not prof.eof
	  %>
<table class="table table-bordered" width="100%">
	<thead>
		<tr>
        	<th colspan="5" class="warning">PROFISSIONAL: <%=ucase(prof("NomeProfissional"))%></th>
        </tr>
        <tr class="success">
        	<th>PACIENTE</th>
            <th>CONV&Ecirc;NIO</th>
            <th>DATA</th>
            <th>SERVI&Ccedil;O / PROCEDIMENTO</th>
            <th>FATURADO</th>
        </tr>
	</thead>
    <tbody>
        <%
		set G = db.execute("select pac.NomePaciente, c.NomeConvenio, gc.DataAtendimento, gc.id, p.NomeProcedimento, gc.ValorProcedimento from tissguiaconsulta as gc left join procedimentos as p on gc.ProcedimentoID=p.id left join convenios as c on c.id=gc.ConvenioID left join pacientes as pac on pac.id=gc.PacienteID where ProfissionalID="&prof("id")&" and gc.sysActive=1 and DataAtendimento>="&mydatenull(DataDe)&" and DataAtendimento<="&mydatenull(DataAte)&" union all select pac.NomePaciente, c.NomeConvenio, gsi.`Data`, gs.id, p.NomeProcedimento, gsi.ValorTotal from tissprocedimentossadt as gsi left join tissguiasadt as gs on gs.id=gsi.GuiaID left join procedimentos as p on gsi.ProcedimentoID=p.id left join convenios as c on c.id=gs.ConvenioID left join pacientes as pac on pac.id=gs.PacienteID where ProfissionalID="&prof("id")&" and gs.sysActive=1 and `Data`>="&mydatenull(DataDe)&" and `Data`<="&mydatenull(DataAte)&" order by DataAtendimento")
'		set G = db.execute("select * from tissguiaconsulta where ProfissionalID="&prof("id")&" and sysActive=1  and DataAtendimento>="&mydatenull(DataDe)&" and DataAtendimento<="&mydatenull(DataAte)&" order by DataAtendimento")
		Subtotal = 0
		while not G.eof
			Subtotal = Subtotal+G("ValorProcedimento")
			%>
			<tr>
            	<td><%=G("NomePaciente")%></td>
            	<td><%=G("NomeConvenio")%></td>
            	<td><%=G("DataAtendimento")%></td>
            	<td><%=G("NomeProcedimento")%></td>
            	<td class="text-right"><%=formatnumber(G("ValorProcedimento"),2)%></td>
            </tr>
			<%
		G.movenext
		wend
		G.close
		set G=nothing
		%>
		<tr>
        	<td class="text-right" colspan="4"><strong>SUBTOTAL:</strong></td>
            <td class="text-right"><strong><%=formatnumber(Subtotal,2)%></strong></td>
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
