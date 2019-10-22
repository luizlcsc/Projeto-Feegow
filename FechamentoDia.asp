<!--#include file="connect.asp"-->
<%
Data = date()
%>
<div class="page-header">
	<h1 class="lighter blue">Fechamento do Dia<small></small></h1>
</div>

<div class="clearfix form-actions">
	<%=quickField("datepicker", "Data", "Data", 3, Data, "input-mask-date input-sm", "", "")%>
</div>


<%
set prof = db.execute("select aa.ProfissionalID, p.NomeProfissional from agendamentoseatendimentos aa left join profissionais p on p.id=aa.ProfissionalID where aa.Tipo='executado' and aa.Data="&mydatenull(Data)&" group by aa.ProfissionalID")
while not prof.eof
	%>
	<h3><%=prof("NomeProfissional")%></h3>
    <table class="table table-striped table-bordered">
    	<thead>
        	<tr>
            	<th>Paciente</th>
            	<th>Procedimento</th>
            	<th></th>
            	<th></th>
            	<th></th>
            	<th></th>
            	<th></th>
            	<th></th>
            </tr>
        </thead>
		<tbody>
        	<tr>
            	<td></td>
            </tr>
        </tbody>
    </table>
	<%
prof.movenext
wend
prof.close
set prof = nothing
%>