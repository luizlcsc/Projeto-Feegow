<!--#include file="connect.asp"-->
<%
dia = req("D")
diaSemana = weekday(dia)
ProfissionalID = req("ProfissionalID")

set feriados = db.execute("select * from feriados where Data="&mydatenull(dia)&"")
while not feriados.eof
	%>
	<em><strong><%=ucase(feriados("NomeFeriado"))%></strong></em><br><br>
	<%
feriados.movenext
wend
feriados.close
set feriados=nothing

set contar = db.execute("select count(id) as total from agendamentos where ProfissionalID="&ProfissionalID&" and Data="&mydatenull(dia))
set contarEncaixes = db.execute("select count(id) as total from agendamentos where ProfissionalID="&ProfissionalID&" and Data="&mydatenull(dia)&" AND Encaixe=1")

set comp = db.execute("select HoraDe, HoraA, Titulo from compromissos where ProfissionalID="&ProfissionalID&" and DataDe <="&mydatenull(dia)&" and DataA>="&mydatenull(dia)&" and DiasSemana like '%"&diaSemana&"%' order by HoraDe")
set ageOcu = db.execute("select hlivres from agendaocupacoes where ProfissionalID="&ProfissionalID&" and Data="&mydatenull(dia))
%>
<strong>RESUMO DO DIA</strong>
<br>
<%=contar("total")%> agendamento(s)
<%
if not ageOcu.EOF then
%>
<br/>
<%=ageOcu("hlivres")%> horários disponíveis
<%
end if
if not contarEncaixes.EOF then
%>
<br/>
<%=contarEncaixes("total")%> encaixe(s)
<%
end if

while not comp.eof
	if comp("Titulo")="" then
		Titulo = "Bloqueio"
	else
		Titulo = comp("Titulo")
	end if
	HoraDe = formatdatetime(comp("HoraDe"),4)
	HoraA = formatdatetime(comp("HoraA"),4)
	if HoraDe="00:00" and HoraA="23:59" then
		Periodo = "Dia inteiro"
	elseif HoraDe="00:00" and HoraA<>"23:59" then
		Periodo = "At&eacute; as "& HoraA
	elseif HoraDe<>"00:00" and HoraA="23:59" then
		Periodo = "A partir de "& HoraDe
	else
		Periodo = HoraDe &" a "& HoraA
	end if
	%><br>
	<%=Titulo%> (<%=Periodo%>)
	<%
comp.movenext
wend
comp.close
set comp=nothing
%>

<!--#include file="disconnect.asp"-->