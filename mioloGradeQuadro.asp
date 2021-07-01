<table width="100%" class="table table-hover table-striped ConteudoHorarios">
<%
IntervaloOriginal = Intervalo
set pGrade=db.execute("select * from locais where id="&LocalID&" and not isNull(d"&diaSemana&")")
if not pGrade.EOF then
	if pGrade("d"&diaSemana)>0 then
		Intervalo=pGrade("d"&diaSemana)
	end if
end if

'1\\\\\\\\\\\\\\\\\\\\\\\\\\\\DEFININDO A GRADE
'2////////////////////////////GRAVANDO A GRADE NA TBL TEMP
'ct=0
sqlInsertV = "insert into tempQuaDis (Hora, UsuarioID, ConsultaID, VCPB, LocalID, ProfissionalID, Tempo) values "
while cdate(Horario)<=cdate(HorarioFinal)
	VCPB="V"
	sqlInsertV = sqlInsertV & "('"&formatdatetime(Horario,3)&"', "&session("User")&", '0', '"&VCPB&"', '"&LocalID&"', '0', '"&Intervalo&"'),"
	Horario=dateadd("n",Intervalo,formatdatetime(Horario,3))
wend
if sqlInsertV<>"insert into tempQuaDis (Hora, UsuarioID, ConsultaID, VCPB, LocalID, ProfissionalID, Tempo) values " then
	sqlInsertV = left(sqlInsertV, len(sqlInsertV)-1)
	db_execute(sqlInsertV)
end if

'2\\\\\\\\\\\\\\\\\\\\\\\\\\GRAVANDO A GRADE NA TBL TEMP
'3//////////////////////////GRAVA AS CONSULTAS
set pCon=db.execute("select id, Hora, Data, ProfissionalID, LocalID, Tempo from agendamentos where Data="&mydatenull(Data)&" and LocalID="&LocalID&" order by Hora")
while not pCon.EOF
	esteIntervalo=Intervalo
	if isnumeric(pcon("Tempo")) then
		if pCon("Tempo")>0 then
			esteIntervalo=pCon("Tempo")
		else
			esteIntervalo=30
		end if
	else
		esteIntervalo=30
	end if
	db_execute("insert into tempQuaDis (Hora, UsuarioID, ConsultaID, VCPB, LocalID, ProfissionalID, Tempo) values ('"&formatdatetime(pCon("Hora"),3)&"', '"&session("User")&"', '"&pCon("id")&"', 'C', '"&LocalID&"', '0', '"&esteIntervalo&"')")
	if not isNull(pCon("Tempo")) then
		DeletarDe=formatdatetime(pCon("Hora"),3)
		DeletarAte=dateAdd("n",esteIntervalo,formatdatetime(pCon("Hora"),3))
		if esteIntervalo>0 then
			set vcaV=db.execute("select * from tempQuaDis where Hora=time('"&formatdatetime(DeletarAte,3)&"') and UsuarioID="&session("User")&" and LocalID="&LocalID)
			if vcaV.eof then
				db_execute("insert into tempQuaDis (Hora, UsuarioID, ConsultaID, VCPB, LocalID, ProfissionalID, Tempo) values ('"&formatdatetime(DeletarAte,3)&"', '"&session("User")&"', '0', 'V', "&LocalID&", '0', '"&Intervalo&"')")
			end if
		end if
		if esteIntervalo=0 then
			igual="="
		else
			igual=""
		end if
		db_execute("delete from tempQuaDis where usuarioID="&session("User")&" and VCPB='V' and Hora>=time('"&formatdatetime(DeletarDe,3)&"') and Hora<"&igual&"time('"&formatdatetime(DeletarAte,3)&"') and LocalID="&LocalID)
		db_execute("delete from tempQuaDis where not ConsultaID="&pCon("id")&" and Hora=time('"&formatdatetime(pCon("Hora"),3)&"') and VCPB='C' and usuarioID="&session("User")&" and LocalID="&LocalID)
	end if
pCon.moveNext
wend
pCon.close
set pCon=nothing
'3\\\\\\\\\\\\\\\\\\\\\\\\\\GRAVA AS CONSULTAS
'4//////////////////////////GRAVA OS COMPROMISSOS (BLOQUEIOS)
'COMPROMISSOS NÃO SÃO CONSULTAS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
set pCom=db.execute("select * from Compromissos where LocalID="&LocalID&" and DataDe<='"&Data&"' and DataA>='"&Data&"' order by HoraDe")
while not pCom.EOF
	if inStr(pCom("DiasSemana"),DiaSemana) then
		db_execute("insert into tempQuaDis (Hora, UsuarioID, ConsultaID, VCPB, LocalID, ProfissionalID) values ('"&formatdatetime(pCom("HoraDe"),3)&"', '"&session("User")&"', '"&pCom("id")&"', 'B', "&LocalID&", '"&pCom("ProfissionalID")&"')")' FALTA O TEMPO AQUI
		db_execute("delete from tempQuaDis where usuarioID="&session("User")&" and VCPB='V' and Hora>=time('"&formatdatetime(pCom("HoraDe"),3)&"') and Hora<time('"&formatdatetime(pCom("HoraA"),3)&"') and LocalID="&LocalID)
	end if
pCom.moveNext
wend
pCom.close
set pCom=nothing
'4\\\\\\\\\\\\\\\\\\\\\\\\\\GRAVA OS COMPROMISSOS (BLOQUEIOS)
'5//////////////////////////LISTA OS HORÁRIOS
set pTemp=db.execute("select * from tempQuaDis where usuarioID="&session("User")&" and LocalID="&LocalID&" order by Hora")
while not pTemp.EOF
	Classe=pTemp("VCPB")
	if Classe="V" then

	%><!--#include file="corQuadro.asp"--><%
		desab=""
		onclick=" onclick=""abreAgenda('"&replace(formatDateTime(pTemp("Hora"),4),":","")&"', 0, '"&Data&"', "&LocalID&", "&idProf&")"""
		if Remarcar="" then
			%><tr class="<%=Classe%> Linhas"<%=onclick%> title="<%=nomeProf%>">
            <td width="1%" style="width:2px; height:16px; background-color:<%=corProf%>; font-weight:bold; color:<%=corProf%>"><span>!<small style="color:#fff"><%=ucase(sigla)%></small></span></td>
			<td width="20" tbl-quadro><input type="button" class="btn btn-info btn-xs" value="<%=formatDateTime(pTemp("Hora"),4)%>"<%=desab%> /></td>
			<td colspan="4" class="Linhas" valign="bottom"></td></tr>
			<%
		else
			if desab="" then
				%>
				<tr class="Remarcar Linhas" onclick="Remarcar('<%=ConsultaRem%>', 'Confirmar', <%=Data%>, '<%=pTemp("Hora")%>', '<%=req("DrId")%>');"><td width="25"></td>
				<td width="20"><strong><%=formatDateTime(hour(pTemp("Hora"))&":"&minute(pTemp("Hora")),4)%></strong></td>
				<td colspan="4" class="Linhas"><input type="button" value="Remarcar para este Hor&aacute;rio" /></td></tr>
				<%
			else
				%>
				<tr class="Indisponivel Linhas"><td width="25"></td>
				<td width="20"><strong><%=formatDateTime(hour(pTemp("Hora"))&":"&minute(pTemp("Hora")),4)%></strong></td>
				<td colspan="4" class="Linhas">Hor&aacute;rio Indispon&iacute;vel</td></tr>
				<%
			end if
		end if
	elseif Classe="C" then
		if Remarcar="S" then
			%>
			<tr class="Indisponivel Linhas"><td width="25"></td>
			<td width="20"><strong><%=formatDateTime(hour(pTemp("Hora"))&":"&minute(pTemp("Hora")),4)%></strong></td>
			<td colspan="4" class="Linhas">Hor&aacute;rio Indispon&iacute;vel</td></tr>
			<%
		else
			''response.Write("select * from Consultas where Data like '"&Data&"' and Hora=time('"&hour(pTemp("Hora"))&":"&minute(pTemp("Hora"))&"') and LocalID like '"&LocalID&"'")
			set pConsultas=db.execute("select * from agendamentos where Data="&mydatenull(Data)&" and Hora=time('"&formatdatetime(pTemp("Hora"),3)&"') and LocalID="&LocalID)
			strConsultas=""
			contaConsultas=0
			while not pConsultas.EOF
				if contaConsultas=0 then
					set pProc=db.execute("select * from procedimentos where id="&pConsultas("TipoCompromissoID"))
					if not pProc.EOF then
						if pProc("ObrigarTempo")="S" then ObrigarTempo="S" else ObrigarTempo="N" end if
						if isNull(pProc("MaximoAgendamentos")) then MaximoAgendamentos=1 else MaximoAgendamentos=pProc("MaximoAgendamentos") end if
					end if
					if isNull(pConsultas("Tempo")) or not isnumeric(pConsultas("Tempo")) then Tempo=0 else Tempo=pConsultas("Tempo") end if
				end if
				'response.Write("0.Procedimento | 1.ObrigarTempo | 2.TempoObrigado | 3.MaximoAgendamentos | 4.StatusConsulta | 5. RDValorPlano | 6. ValorPlano | 7. idConsulta | 8. Pacientes<br>")
				if strConsultas="" then
					strConsultas=pConsultas("TipoCompromissoID")&"|"&ObrigarTempo&"|"&Tempo&"|"&MaximoAgendamentos&"|"&pConsultas("StaID")&"|"&pConsultas("rdValorPlano")&"|"&pConsultas("ValorPlano")&"|"&pConsultas("id")&"|"&pConsultas("PacienteID")
				else
					strConsultas=strConsultas&"{"&pConsultas("PacienteID")
				end if
				DrAdicionar=pConsultas("ProfissionalID")
				contaConsultas=contaConsultas+1
			pConsultas.moveNext
			wend
			pConsultas.close
			set pConsultas=nothing
			%><tr><td><!--#include file="QuadroConteudoAgendamento.asp"--></td></tr><%
		end if
	else
	tipoMarcacao=""
	end if
pTemp.moveNext
wend
pTemp.close
set pTemp=nothing
db_execute("delete from tempQuaDis where usuarioID="&session("User")&" and LocalID="&LocalID)

Intervalo = IntervaloOriginal
%></table>