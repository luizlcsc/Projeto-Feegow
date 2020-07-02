<!--#include file="connect.asp"-->
<%
dia = req("D")
diaSemana = weekday(dia)
EquipamentoID = req("EquipamentoID")

set feriados = db.execute("select * from feriados where Data="&mydatenull(dia)&"")
while not feriados.eof
	%>
	<em><strong><%=ucase(feriados("NomeFeriado"))%></strong></em><br><br>
	<%
feriados.movenext
wend
feriados.close
set feriados=nothing

set contar = db.execute("select count(id) as total from agendamentos where EquipamentoID="&EquipamentoID&" and Data="&mydatenull(dia))
set comp = db.execute("select HoraDe, HoraA, Titulo from compromissos where ProfissionalID=-"&EquipamentoID&" and DataDe <="&mydatenull(dia)&" and DataA>="&mydatenull(dia)&" and DiasSemana like '%"&diaSemana&"%' order by HoraDe")
%>
<strong>RESUMO DO DIA</strong>
<br>
<%=contar("total")%> agendamento(s)
<%
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

contar.close
set contar = nothing
%>

<!--#include file="disconnect.asp"-->