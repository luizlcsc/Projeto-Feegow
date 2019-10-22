<table width="100%" class="table table-hover table-striped ConteudoHorarios">
<%
IntervaloOriginal = Intervalo
set pGrade=db.execute("select * from locais where id="&LocalID&" and not isNull(d"&diaSemana&")")
if not pGrade.EOF then
	if pGrade("d"&diaSemana)>0 then
		Intervalo=pGrade("d"&diaSemana)
	end if
end if

'5//////////////////////////LISTA OS HORÁRIOS
set comps=db.execute("select a.id, a.Data, a.Hora, a.LocalID, a.StaID, p.NomePaciente from agendamentos a "&_
"left join pacientes p on p.id=a.PacienteID "&_ 
"where a.LocalID="&LocalID&" and a.Data="&mydatenull(Data)&"order by Hora")
while not comps.EOF
	%>
	<tr>
    	<td><img src="assets/img/<%=comps("StaID")%>.png"></td>
    	<td><%=formatdatetime(comps("Hora"), 4)%></td>
    	<td><%=comps("NomePaciente")%></td>
    </tr>
	<%
comps.moveNext
wend
comps.close
set comps=nothing

Intervalo = IntervaloOriginal
%></table>