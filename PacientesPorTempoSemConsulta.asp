<!--#include file="connect.asp"-->
<%
if req("De")="" then
	De=dateadd("m", -1, date())
else
	De=req("De")
end if

if req("A")="" then
	A=date()
else
	A=req("A")
end if
%>
<h4>Pacientes por Tempo de Aus&ecirc;ncia</h4>
<form id="Relatorio" name="Relatorio" method="get" action="">
<input type="hidden" name="Pers" value="1" />
<input type="hidden" name="P" value="Relatorio" />
<input type="hidden" name="TipoRel" value="<%=req("TipoRel")%>" />
<div class="clearfix form-actions">
<%=quickField("datepicker", "De", "Data In&iacute;cio", 3, left(De, 10), "", "", "")%>
<%=quickField("datepicker", "A", "Data Fim", 3, left(A, 10), "", "", "")%>
<label>&nbsp;</label><br />
<button class="btn btn-success" name="Gerar"><i class="far fa-list"></i> Gerar</button>
<br />
<br />
</div>
<table class="table table-bordered table-striped" width="100%" border="0">
<tr><th>Nome</th><th>Sexo</th><th>Nascimento</th><th>&Uacute;lt. Consulta</th></tr>
<%
c=0
set p = db.Execute("Select * from pacientes where sysActive=1 order by NomePaciente")
while  not p.eof
	set vca=db.execute("select * from agendamentos where PacienteID like '"&p("id")&"' and not StaID like '6' and data between '"&mydate(De)&"' and '"&myDate(A)&"'")
	if vca.eof then
	c=c+1
%><tr onclick="location.href='?P=Pacientes&I=<%=p("id")%>&Pers=1';">
<td><div align="left"><%=p("NomePaciente")%></div></td>
<td><div align="left"><%=getSexo(p("Sexo"))%></div></td>
<td><div align="left"><%=p("Nascimento")%></div></td>
<%
set pult=db.execute("select * from agendamentos where PacienteID like '"&p("id")&"' and not StaID like '6' order by Data desc")
if pult.eof then
	ultDat="Nunca"
else
	ultDat=pult("Data")
end if

%>
<td><div align="left"><%=ultDat%></div></td>
</tr>
<%
	end if
p.moveNext
wend
set p=nothing
%>
</table>
<br />
<br />
<%=c%> paciente(s) encontrado(s).
</form>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
</script>