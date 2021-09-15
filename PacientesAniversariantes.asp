<!--#include file="connect.asp"-->
<%
if not isdate(req("De")) or req("De")="" then
	De=date()
else
	De=cdate(req("De"))
end if

if not isdate(req("A")) or req("A")="" then
	A=dateAdd("m", 1, date())
else
	A=cdate(req("A"))
end if

if A<De then
	A=dateAdd("m", 1, De)
end if

if year(A)>year(De) then
	A = dateadd("d", -1, "01/01/"&year(A))
end if
%>
<h4>Pacientes Aniversariantes</h4>

<form id="Relatorio" name="Relatorio" method="get" action="">
<input type="hidden" name="Pers" value="1" />
<input type="hidden" name="E" value="E" />
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
</form>

<form method="post" action="Etiquetas.asp" target="_blank">
<%if req("E")="E" then%>
<table class="table table-bordered table-striped" width="100%" border="0">
<tr><th width="1%"><label><input type="checkbox" class="ace" checked="checked" /><span class="lbl"></span></label></th><th>Nome</th><th>Sexo</th><th>Nascimento</th><th>Pr&oacute;x. Anivers&aacute;rio</th><th>&Uacute;lt. Consulta</th></tr>
<%
c=0
set p = db.Execute("Select * from pacientes where sysActive=1 and not isnull(Nascimento) order by day(Nascimento), month(Nascimento)")
while  not p.eof
	Aniversario = cdate(day(p("Nascimento"))&"/"&month(p("Nascimento"))&"/"&year(De))
	if Aniversario<date() then
		Aniversario = dateadd("yyyy", 1, Aniversario)
	end if
	if ( day(p("Nascimento"))>=day(De) and month(p("Nascimento"))=month(De) or month(p("Nascimento"))>month(De) ) and ( day(p("Nascimento"))<=day(A) and month(p("Nascimento"))=month(A) or month(p("Nascimento"))<month(A) ) then
	c=c+1
		gerEt="S"
%><tr onClick="location.href='./?P=Pacientes&Pers=1&I=<%=p("id")%>';">
<td><label><input type="checkbox" class="ace" checked="checked" /><span class="lbl"></span></label></td>
<td><%=p("NomePaciente")%><input type="hidden" name="Et" value="<%=p("id")%>" /></td>
<td><%=getSexo(p("Sexo"))%></td>
<td><%=p("Nascimento")%></td>
<%
set pult=db.execute("select * from agendamentos where PacienteID="&p("id")&" and StaID<>6 order by Data desc")
if pult.eof then
ultDat="Nunca"
else
ultDat=pult("Data")
end if

Aniversario = datediff("d", date(), Aniversario)
select case Aniversario
	case 0
		Aniversario = "Hoje"
	case 1
		Aniversario = "Amanh&atilde;"
	case else
		Aniversario = Aniversario&" dias"
end select
%>
<td><%=Aniversario%></td>
<td><div align="left"><%=ultDat%></div></td>
</tr>
<%
	end if
p.moveNext
wend
set p=nothing
%>
</table>
<p><%=c%> paciente(s) encontrado(s).<%end if%>
</p>
<!--#include file="gerEt.asp"-->
</form>
</body></html>