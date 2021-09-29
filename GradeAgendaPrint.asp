<!--#include file="connect.asp"-->
<!DOCTYPE html>
<html lang="en">
	<head>
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<meta charset="utf-8" />
		<title>Feegow Software :: <%=session("NameUser")%></title>

		<meta name="description" content="" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		<!-- basic styles -->

		<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
        <style type="text/css">
			h3{
				font-weight:bold;
				text-transform:uppercase;
			}
		</style>
	</head>
    <body>
    	<div class="container">
            <%
            db_execute("delete from tempAgenda where usuarioID = "&session("User"))
            
            if req("Data")="" then
                Data=date()
            else
                Data=req("Data")
            end if
            ProfissionalID=req("ProfissionalID")
            DiaSemana=weekday(Data)
            mesCorrente=month(Data)
            
            set Prof = db.execute("select id,NomeProfissional from profissionais where id="&ProfissionalID)
            if not Prof.EOF then
                %>
                <h2 class="text-center"><%=Prof("NomeProfissional")%></h2>
                <%
            end if
			%>
            <h4 class="text-center"><%=formatdatetime(Data, 1)%></h4>
            <%
            
            %>
            <input type="hidden" name="DataBloqueio" id="DataBloqueio" value="<%=Data%>" />
            <%
            '1////////////////////////DEFININDO A GRADE
            set pGrade=db.execute("select * from Horarios where ProfissionalID = "&ProfissionalID&" and Dia = "&weekday(Data))
            if pGrade.EOF then
                Grade="00:15"
                Horario=cdate("00:00:00")
                HorarioFinal=cdate("23:59:59")
                Atende="S"
                Pausa=""
                PausaDe="00:00"
                PausaAs="00:00"
            else
                Grade=cdate(hour(pGrade("Intervalos"))&":"&minute(pGrade("Intervalos")))
                Horario=cdate(hour(pGrade("HoraDe"))&":"&minute(pGrade("HoraDe")))
                HorarioFinal=cdate(hour(pGrade("HoraAs"))&":"&minute(pGrade("HoraAs")))
                Atende=pGrade("Atende")
                Pausa=pGrade("Pausa")
                PausaDe=cdate(hour(pGrade("PausaDe"))&":"&minute(pGrade("PausaDe")))
                PausaAs=cdate(hour(pGrade("PausaAs"))&":"&minute(pGrade("PausaAs")))
            end if
            Intervalo=datediff("n","00:00:00",Grade)
            if Intervalo<=0 then Intervalo=15 end if
            '1\\\\\\\\\\\\\\\\\\\\\\\\\\\\DEFININDO A GRADE
            '2////////////////////////////GRAVANDO A GRADE NA TBL TEMP
            
            strVI = "insert into tempAgenda (Hora, UsuarioID, ConsultaID, VCIB) values "
            if Atende="S" then
                while ccur(Horario)<=ccur(HorarioFinal)
                    if Pausa="S" and cDate(PausaDe)<=cDate(Horario) and cDate(PausaAs)>cDate(Horario) then
                        VCIB="I"
                    else
                        VCIB="V"
                    end if
                    strVI = strVI&" ('"&hour(Horario)&":"&minute(Horario)&"', "&session("User")&", '0', '"&VCIB&"'), "
                    Horario=dateadd("n",Intervalo,Horario)
                wend
                if right(strVI,2)=", " then
                    strVI = left(strVI, len(strVI)-2)
                    db.execute(strVI)
                end if
            end if
            
            set locais = db.execute("select * from assfixalocalxprofissional where ProfissionalID="&ProfissionalID&" and DiaSemana="&weekday(Data))
            if not locais.eof then
                while not locais.eof
                    Horario=cdate(hour(locais("HoraDe"))&":"&minute(locais("HoraDe")))
                    HorarioFinal=cdate(hour(locais("HoraA"))&":"&minute(locais("HoraA")))
                    LocalID = locais("LocalID")
                    strVI = "insert into tempAgenda (Hora, UsuarioID, ConsultaID, VCIB, LocalID) values "
                    del = "delete from tempagenda where UsuarioID="&session("User")&" and isnull(LocalID) and VCIB='V' and Hora>=time('"&Horario&"') and Hora<=time('"&HorarioFinal&"')"
            '		response.Write(del)
                    db.execute(del)
                    while ccur(Horario)<=ccur(HorarioFinal)
                        VCIB="V"
                        strVI = strVI&" ('"&formatdatetime(Horario,4)&"', "&session("User")&", '0', '"&VCIB&"', "&LocalID&"), "
                        Horario=dateadd("n",Intervalo,Horario)
                    wend
                    if right(strVI,2)=", " then
                        strVI = left(strVI, len(strVI)-2)
                        db.execute(strVI)
                    end if
                locais.movenext
                wend
                locais.close
                set locais=nothing
                if Pausa="S" then
                    db_execute("delete from tempagenda where VCIB='V' and UsuarioID="&session("User")&" and not isnull(LocalID) and Hora>=time('"&PausaDe&"') and Hora<=time('"&PausaAs&"')")
                end if
            end if
            '2\\\\\\\\\\\\\\\\\\\\\\\\\\GRAVANDO A GRADE NA TBL TEMP
            '3//////////////////////////GRAVA AS agendamentos
            set pCon=db.execute("select id, Hora, HoraFinal, Data, ProfissionalID, Tempo from agendamentos where Data = '"&mydate(Data)&"' and ProfissionalID = "&ProfissionalID&" order by Hora")
            while not pCon.EOF
                db_execute("insert into tempAgenda (Hora, UsuarioID, ConsultaID, VCIB) values ('"&hour(pCon("Hora"))&":"&minute(pCon("Hora"))&"', '"&session("User")&"', '"&pCon("id")&"', 'C')")
                if not isNull(pCon("Tempo")) then
                    DeletarDe=hour(pCon("Hora"))&":"&minute(pCon("Hora"))
                    if isNull(pCon("Tempo")) or not isNumeric(pCon("Tempo")) then
                        pcontempo=0
                    else
                        pcontempo=pCon("Tempo")
                    end if
                    'response.Write(pcontempo&" - "&hour(pCon("Hora"))&":"&minute(pCon("Hora")))
                    DeletarAte=dateAdd("n",pcontempo,hour(pCon("Hora"))&":"&minute(pCon("Hora")))
                    if pcontempo>0 then
                        set vcaV=db.execute("select * from tempAgenda where Hora=TIME('"&hour(DeletarAte)&":"&minute(DeletarAte)&"') and UsuarioID = "&session("User"))
                        if vcaV.eof and cdate(DeletarAte)<=cDate(HorarioFinal) then
                            db_execute("insert into tempAgenda (Hora, UsuarioID, ConsultaID, VCIB) values ('"&hour(DeletarAte)&":"&minute(DeletarAte)&"', '"&session("User")&"', '0', 'V')")
                        end if
                    end if
                    if pcontempo=0 then
                        igual="="
                    else
                        igual=""
                    end if
                    db_execute("delete from tempAgenda where usuarioID = "&session("User")&" and (VCIB='I' or VCIB='V') and Hora>=TIME('"&hour(DeletarAte)&":"&minute(DeletarAte)&"') and Hora<"&igual&"TIME('"&hour(DeletarAte)&":"&minute(DeletarAte)&"')")
                    db_execute("delete from tempAgenda where not ConsultaID="&pCon("id")&" and Hora=TIME('"&hour(pCon("Hora"))&":"&minute(pCon("Hora"))&"') and VCIB='C'")
                    db_execute("delete from tempAgenda where Hora=TIME('"&hour(pCon("Hora"))&":"&minute(pCon("Hora"))&"') and not VCIB like 'C' and not VCIB like 'B'")
                    db_execute("delete from tempAgenda where Hora>TIME('"&hour(pCon("Hora"))&":"&minute(pCon("Hora"))&"') and Hora<TIME('"&hour(pCon("HoraFinal"))&":"&minute(pCon("HoraFinal"))&"') and VCIB like 'V'")
                end if
            pCon.moveNext
            wend
            pCon.close
            set pCon=nothing
            '3\\\\\\\\\\\\\\\\\\\\\\\\\\GRAVA AS agendamentos
            '4//////////////////////////GRAVA OS COMPROMISSOS (BLOQUEIOS)
            'COMPROMISSOS NÃO SÃO agendamentos!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            sqlCompro = "select * from compromissos where ProfissionalID="&ProfissionalID&" and DataDe<='"&mydate(Data)&"' and DataA>='"&mydate(Data)&"' order by HoraDe"
            'response.Write(sqlCompro)
            set pCom=db.execute(sqlCompro)
            while not pCom.EOF
                if inStr(pCom("DiasSemana"),DiaSemana) then
                    db_execute("insert into tempAgenda (Hora, UsuarioID, ConsultaID, VCIB) values ('"&hour(pCom("HoraDe"))&":"&minute(pCom("HoraDe"))&"', '"&session("User")&"', '"&pCom("id")&"', 'B')")
                    db_execute("delete from tempAgenda where usuarioID='"&session("User")&"' and (VCIB='I' or VCIB='V') and Hora>=TIME('"&hour(pCom("HoraDe"))&":"&minute(pCom("HoraDe"))&"') and Hora<TIME('"&hour(pCom("HoraA"))&":"&minute(pCom("HoraA"))&"')")
                end if
            pCom.moveNext
            wend
            pCom.close
            set pCom=nothing
            
            db_execute("delete from tempAgenda where Hora=time('00:00') and not VCIB='B'")
            '4\\\\\\\\\\\\\\\\\\\\\\\\\\GRAVA OS COMPROMISSOS (BLOQUEIOS)
            '5//////////////////////////LISTA OS HORÁRIOS
            'set pTemp=db.execute("select * from tempAgenda where usuarioID="&session("User")&" order by Hora")
            set pTemp=db.execute("select t.*, l.NomeLocal from tempagenda as t left join locais as l on l.id=t.LocalID where usuarioID="&session("User")&" order by Hora")
            
            %>
            <table class="table table-condensed table-bordered" style="width:100%">
<tbody>
<%
while not pTemp.EOF
	Classe=pTemp("VCIB")
	if Classe="V" or Classe="I" then
		if Classe="I" then
			agendar="intervalo "
		else
			if UtilizarFila<>"" or session("RemSol")<>"" or session("RepSol")<>"" then
				agendar = ""
			else
				agendar="agendar "
			end if
		end if
		if Remarcar="" then
			%>
			<tr id="<%=replace(formatDateTime(pTemp("Hora"),4), ":", "")%>" contextmenu="<%=pTemp("LocalID")%>" class="<%= agendar  %><%if minute(hora)>0 then%> fc-minor<%end if%>">
              <th class="fc-agenda-axis fc-widget-header"><%=formatDateTime(pTemp("Hora"),4)%></th>
              <td></td><td></td><td></td><td></td>
			  <td class="fc-col0 fc-thu fc-widget-content fc-state-highlight fc-today"><%
			  if UtilizarFila<>"" then
			  	%><button type="button" onclick="filaEspera('U_<%=UtilizarFila%>_<%=formatDateTime(pTemp("Hora"),4)%>')" class="btn btn-xs btn-primary"><i class="far fa-chevron-left"></i> Agendar Aqui</button><%
			  elseif session("RemSol")<>"" then
			  	%><button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(pTemp("Hora"),4)%>')" class="btn btn-xs btn-warning"><i class="far fa-chevron-left"></i> Agendar Aqui</button><%
			  elseif session("RepSol")<>"" then
			  	%><button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(pTemp("Hora"),4)%>')" class="btn btn-xs btn-warning"><i class="far fa-chevron-left"></i> Repetir Aqui</button><%
			  else
			  	%>&nbsp;<small class="grey pull-right"><%=pTemp("NomeLocal")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</small><%
			  end if
			  
			  %></td>
            </tr>
			<%
		else
			if desab="" then
				%>
				<tr class="Remarcar Linhas" onclick="Remarcar('<%=ConsultaRem%>', 'Confirmar', <%=Data%>, '<%=hour(pTemp("Hora"))&":"&minute(pTemp("Hora"))%>', '<%=req("ProfissionalID")%>');"><td width="25" bgcolor="#F8F8F8"></td>
				<td width="20" bgcolor="#F8F8F8"><strong><%=formatDateTime(pTemp("Hora"),4)%></strong></td>
				<td colspan="4" class="Linhas"><input type="button" value="Remarcar para este Hor&aacute;rio" /></td></tr>
				<%
			else
				%>
				<tr class="Indisponivel Linhas"><td width="25" bgcolor="#F8F8F8"></td>
				<td width="20" bgcolor="#F8F8F8"><strong><%=formatDateTime(pTemp("Hora"),4)%></strong></td>
				<td colspan="4" class="Linhas">Hor&aacute;rio Indispon&iacute;vel</td></tr>
				<%
			end if
		end if
	elseif Classe="B" then
		set pBloq=db.execute("select * from Compromissos where id="&pTemp("ConsultaID"))
		if not pBloq.EOF then
			%>
			<tr id="<%=replace(formatDateTime(pTemp("Hora"),4), ":", "")%>" class="intervalo hand" onclick="abreBloqueio(<%=pTemp("ConsultaID")%>, '', '')">
              <th class="fc-agenda-axis fc-widget-header"><%=formatDateTime(pTemp("Hora"),4)%></th>
			  <td class="fc-col0 fc-thu fc-widget-content fc-state-highlight fc-today"><img class="carinha" src="assets/img/bloqueio.png" />&nbsp;<small><%if pBloq("Titulo")="" then response.Write("<em>Bloqueio de hor&aacute;rio</em>") else response.Write(server.HTMLEncode(pBloq("Titulo"))) end if%></small></td>
            </tr>
            <%
		end if
	elseif Classe="C" then
		if Remarcar="S" then
			%>
			<tr class="Indisponivel Linhas"><td width="25" bgcolor="#F8F8F8"></td>
			<td width="20" bgcolor="#F8F8F8"><strong><%=formatDateTime(pTemp("Hora"),4)%></strong></td>
			<td colspan="4" class="Linhas">Hor&aacute;rio Indispon&iacute;vel</td></tr>
			<%
		else
			set contaAgendamentos = db.execute("select count(id) as total from agendamentos where Data="&mydatenull(Data)&" and Hora='"&hour(pTemp("Hora"))&":"&minute(ptemp("Hora"))&"' and ProfissionalID="&ProfissionalID)
			totalAgendamentos = ccur(contaAgendamentos("total"))
			set pagendamentos=db.execute("select * from agendamentos where Data="&mydatenull(Data)&" and Hora='"&hour(pTemp("Hora"))&":"&minute(ptemp("Hora"))&"' and ProfissionalID like '"&ProfissionalID&"'")
			MaximoAgendamentos=1
			if not pagendamentos.eof then
				set pProc=db.execute("select * from procedimentos where id = '"&pagendamentos("TipoCompromissoID")&"'")
				if not pProc.EOF then
					if pProc("ObrigarTempo")="S" then ObrigarTempo="S" else ObrigarTempo="N" end if
					if isNull(pProc("MaximoAgendamentos")) or not isnumeric(pProc("MaximoAgendamentos")) then MaximoAgendamentos=1 else MaximoAgendamentos=pProc("MaximoAgendamentos") end if
				end if
				if isNull(pagendamentos("Tempo")) or not isnumeric(pagendamentos("Tempo")) then Tempo=0 else Tempo=pagendamentos("Tempo") end if
			end if
			contaagendamentos=0
			if totalAgendamentos=1 then
				contaagendamentos=1
				%><!--#include file="ConteudoAgendamentoPrint.asp"--><%
			elseif totalAgendamentos>1 then
				%><tr class="fc-minor"><th class="fc-agenda-axis fc-widget-header"><%=formatDateTime(pTemp("Hora"),4)%></th>
                <td class="fc-col0 fc-thu fc-widget-content fc-state-highlight fc-today"><img class="carinha" src="assets/img/multiplo.png" /> <%=pProc("NomeProcedimento")%>: <%
				while not pagendamentos.EOF
					set pac = db.execute("select * from pacientes where id="&pagendamentos("PacienteID"))
					if not pac.eof then
						%>
						<button class="btn btn-xs btn-info" type="button" onclick="abreAgenda('<%=replace(left(cdate( hour(pTemp("Hora"))&":"&minute(pTemp("Hora")) ),5), ":", "")%>', <%=pagendamentos("id")%>, '<%=Data%>')"><%=pac("NomePaciente")%></button>
						<%
					end if
					contaagendamentos=contaagendamentos+1
				pagendamentos.moveNext
				wend
				pagendamentos.close
				set pagendamentos=nothing
				%><%if ccur(contaagendamentos)<ccur(MaximoAgendamentos) then%></td><td><button type="button" onclick="abreAgenda('<%=replace(left(cdate( hour(pTemp("Hora"))&":"&minute(pTemp("Hora")) ),5), ":", "")%>', 0, '<%=Data%>', '<%=pTemp("LocalID")%>')" class="btn btn-success btn-xs"><i class="far fa-plus"></i></button><%end if%></td></tr><%
			end if
            contaAgendamentos.close
            set contaAgendamentos = nothing
		end if
	else
	tipoMarcacao=""
	end if
pTemp.moveNext
wend
pTemp.close
set pTemp=nothing
'5\\\\\\\\\\\\\\\\\\\\\\\\\\LISTA OS HORÁRIOS%>
</tbody>
</table>
        </div>
    </body>
</html>



<%
db_execute("delete from tempAgenda where usuarioID like '"&session("User")&"'")
'response.write "Processado em " & FormatNumber( Timer - InicioProcessamento, 7 ) & " segundos"
%>

<script>
print();
</script>
<!--#include file = "disconnect.asp"-->
