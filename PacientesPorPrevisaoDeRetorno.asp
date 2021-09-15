<!--#include file="connect.asp"-->
<%
if not isdate(req("De")) or req("De")="" then
	De=date()
else
	De=req("De")
end if

if not isdate(req("A")) or req("A")="" then
	A=dateAdd("m", 1, date())
else
	A=req("A")
end if
%>
<h4>Pacientes por Previs&atilde;o de Retorno</h4>
<form id="Relatorio" name="Relatorio" method="get" action="">
<input type="hidden" name="Pers" value="1" />
<input type="hidden" name="P" value="Relatorio" />
<input type="hidden" name="TipoRel" value="<%=req("TipoRel")%>" />
<input type="hidden" name="E" value="E" />
<div class="clearfix form-actions">
<%=quickField("datepicker", "De", "Data In&iacute;cio", 3, left(De, 10), "", "", "")%>
<%=quickField("datepicker", "A", "Data Fim", 3, left(A, 10), "", "", "")%>
<label>&nbsp;</label><br />
<button class="btn btn-success" name="Gerar"><i class="far fa-list"></i> Gerar</button>
<br />
<br />
</div>
<%if req("E")="E" then%>
<table class="table table-bordered table-striped" width="100%" border="0">
<tr bgcolor="#CCCCCC"><th>Nome</th><th>Sexo</th><th>Nascimento</th>
<th>&Uacute;lt. Consulta</th><th>Previs&atilde;o de Retorno</th></tr>
<%
c=0
set p = db.Execute("select pr.*, p.* from pacientesretornos as pr left join pacientes as p on p.id=pr.PacienteID where not isnull(pr.Data) and pr.Data>='"&mydate(De)&"' and pr.Data<='"&mydate(A)&"'")
while  not p.eof
	c=c+1
%><tr onclick="location.href='./?P=Pacientes&Pers=1&I=<%=p("id")%>';">
<td><div align="left"><%=p("NomePaciente")%></div></td>
<td><div align="left"><%=getsexo(p("Sexo"))%></div></td>
<td><div align="left"><%=p("Nascimento")%></div></td>
<%
set pult=db.execute("select id, PacienteID, Data from agendamentos where PacienteID="&p("PacienteID")&" and StaID<>6 order by Data desc")
if pult.eof then
	ultDat="Nunca"
else
	ultDat=pult("Data")
end if

%>
<td><div align="left"><%=ultDat%></div></td>
<td><div align="left"><%=p("Data")%></div></td>
</tr>
<%
p.moveNext
wend
p.close
set p=nothing
%>
</table>
<br />
<br />
<%=c%> paciente(s) encontrado(s).<%end if%>
</form>

<script language="javascript">
<!--#include file="jqueryfunctions.asp"-->
</script>