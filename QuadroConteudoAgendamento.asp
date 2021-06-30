<%
strSMz=split(strConsultas,"|")
if contaConsultas>1 and ubound(strSMz)>=6 then
	if strSMz(5)="V" then
		Valor=strSMz(6)
	else
		set pPlan=db.execute("select NomeConvenio from convenios where id = '"&strSMz(6)&"'")
		if not pPlan.EOF then
			Valor="<center>"&pPlan("NomeConvenio")
		end if
	end if
end if
if ubound(strSMz)>=8 then
	set ppac=db.execute("select id,NomePaciente,Foto from Pacientes where id = '"&strSMz(8)&"'")
	if not ppac.eof then
		Paciente=ppac("NomePaciente")
		Imagem=ppac("Foto")
	else
		Paciente="Paciente exclu�do."
		Imagem=""
	end if
	set pSta=db.execute("select * from StaConsulta where id = '"&strSMz(4)&"'")
	if not pSta.EOF then
		StaConsulta=pSta("StaConsulta")
		idSta=pSta("id")
	else
		StaConsulta="Status de agendamento n�o identificado."
	end if
	set pTip=db.execute("select NomeProcedimento from procedimentos where id = "&strSMz(0)&"")
	if not pTip.EOF then
		TipoCompromisso=pTip("NomeProcedimento")
	else
		TipoCompromisso="Compromisso n�o especificado."
	end if
	if contaConsultas<=1 then
		conteudoClick=" onclick=""abreAgenda('"&replace(formatdatetime(pTemp("Hora"),4),":","")&"', "&strSMz(7)&", '"&Data&"', '"&LocalID&"', '"&ProfissionalID&"')"""
		'       chamaAgendamento('', '"&strSMz(0)&"', '"&strSMz(2)&"', '', '"&Data&"', '', '"&Data&"', 'Q', '"&strSMz(8)&"', '"&strSMz(5)&"', '"&strSMz(6)&"',0);"""
		'conteudoClick=" onclick=""chamaAgendamento('"&strSMz(7)&"', '"&strSMz(0)&"', '"&strSMz(2)&"', '"&DrId&"', '"&Data&"', '"&formatdatetime( pTemp("Hora"),3)&"', '"&Data&"', 'Q', '"&strSMz(8)&"', '"&strSMz(5)&"', '"&strSMz(6)&"',0);"""
	else
		conteudoClick=""
	end if
end if
%><!--#include file="corQuadro.asp"--><%
set pcondia=db.execute("select * from agendamentos where id = '"&pTemp("ConsultaID")&"'")
if not pcondia.eof then
	set pProf=db.execute("select NomeProfissional, Cor from profissionais where id = '"&pcondia("ProfissionalID")&"'")
	if not pProf.EOF then
		Profissional=pProf("NomeProfissional")
		corProfSel=pProf("Cor")
	else
		Profissional="Profissional n�o selecionado."
		corProfSel="#FFFFFF"
	end if
	%>
	<tr class="C Linhas" style="cursor:default" title="<%=Profissional%>">
	<td<%= conteudoClick %> width="1%" style="width:2px; height:16px; background-color:<%=corProfSel%>; font-weight:bold; color:<%=corProf%>"><span>!<small style="color:#fff"><%=ucase(sigla)%></small></span></td>
	<td<%= conteudoClick %> width="1%"><input type="button" class="btn btn-xs btn-warning" value="<%=formatdatetime(pTemp("Hora"),4)%>"<%if contaConsultas>1 then%> disabled="disabled"<%end if%> /></td>
	<td><%if contaConsultas<=1 then%><img src="assets/img/<%=idSta%>.png" align="absmiddle" /><%else%><img src="assets/img/grupo.png" /><%end if%>
	<%
	if ubound(strSMz)>=8 then
		if isnumeric(strSMz(3)) then
			if ccur(strSMz(3))>1 then
				contaPacsMT=split(strSMz(8),"{")
				nrPacsMT=0
				for l=0 to uBound(contaPacsMT)
					nrPacsMT=nrPacsMT+1
				next
				if ccur(strSMz(3))>ccur(nrPacsMT) then
				'	btnAdicionarPaciente="<input type=""button"" value=""adicionar paciente &gt;"" onclick=""parent.ConsultaAgendamento.location='ConsultaAgendamento.asp?DrId="&req("DrId")&"&Hora="&formatdatetime(HorarioExibido,4)&"&Data="&Data&"&PacienteID=0&ProcedimentoFixo="&strSMz(0)&"';"" />"
					 btnAdicionarPaciente="<input type=""button"" value=""+"" style=""width:20px;"" onclick=""chamaAgendamento(0,'"&strSMz(0)&"','"&strSMz(2)&"','"&DrAdicionar&"','"&Data&"','"&formatDateTime(pTemp("Hora"),3)&"','"&Data&"','Q',0,0,0,'"&LocalID&"');"" />"
				else
					btnAdicionarPaciente=""
				end if
			else
				btnAdicionarPaciente=""
			end if
		end if
		if inStr(strSMz(8),"{")=0 then
			StaConsulta=idSta
			set pSta=db.execute("select * from StaConsulta where id = '"&StaConsulta&"'")
			if not pSta.eof then
				NomeStaConsulta=pSta("StaConsulta")
			else
				NomeStaConsulta=""
			end if
			%><span<%= conteudoClick %> style="cursor:pointer"<%if not isnull(Imagem) and not Imagem="" then%> onMouseOver="document.getElementById('divU<%=strSMz(7)%>').style.display='block';" onMouseOut="document.getElementById('divU<%=strSMz(7)%>').style.display='none';"<%end if%>><%=left(trim(Paciente&" "),17)%><small class="lighter hidden"> &raquo; <%= TipoCompromisso %></small></span>
			
			
			<div id="divU<%=strSMz(7)%>" align="center" style="visibility:visible; opacity:0.85; filter:alpha(opacity=85); display:none; position:absolute; color:#FFF; padding:5px; background-color:#333; width:185px; height: 130px;"><%if not isnull(Imagem) and not Imagem="" then%><img src="<%=PastaIMG%><%=Imagem%>" width="100"><%end if%><hr><strong><%=Paciente%></strong><hr /><div style="background-color:#ffffff;color:#000000;padding:2px;"><img src="<%=StaConsulta%>.jpg"> <%=NomeStaConsulta%></div></div>
			
			<%=btnAdicionarPaciente%><%
		else
			%><strong><input type="text" id="NomePac<%=replace(formatdatetime(hour(pTemp("Hora"))&":"&minute(pTemp("Hora")),4),":","")%>" value="GRUPO" style="width:50px; height:20px; background-color:#FFFF00; font-weight:bold; font-size:10px; border:dotted 1px #CCCCCC; cursor:default" readonly="readonly" /></strong><%=btnAdicionarPaciente%><%
			mtPacientes=split(strSMz(8),"{")
			ipac=0
			for k=0 to uBound(mtPacientes)
				set pPacM=db.execute("select id, Foto, NomePaciente from pacientes where id = '"&mtPacientes(k)&"'")
				if not pPacM.EOF then
					Imagem=pPacM("Foto")
					set pIdCon=db.execute("select * from agendamentos where Hora=time('"&formatdatetime(pTemp("Hora"),3)&"') and Data="&mydatenull(Data)&" and PacienteID like '"&mtPacientes(k)&"'")
					if not pIdCon.EOF then
						idConsulta=pIdCon("id")
						tipoValConsulta=pIdCon("rdValorPlano")
						ValConsulta=pIdCon("ValorPlano")
						StaConsulta=pIdCon("StaID")
						HoraMult = pIdCon("Hora")
						DataMult = pIdCon("Data")
						LocalIDMult = pIdCon("LocalID")
						ProfissionalIDMult = pIdCon("ProfissionalID")
					else
						idConsulta=0
						tipoValConsulta=strSMz(5)
						ValConsulta=strSMz(6)
						StaConsulta=strSMz(4)
					end if
					set pStaM=db.execute("select * from StaConsulta where id = '"&StaConsulta&"'")
					if pStaM.EOF then
						StaConsulta=""
						NomeStaConsulta=""
					else
						NomeStaConsulta=pStaM("StaConsulta")
					end if
					ipac=ipac+1
					'(horario, id, data, LocalID, ProfissionalID
					%><input type="button" value="<%=left(trim(pPacM("NomePaciente")),1)%>" title="<%=pPacM("NomePaciente")%>" style="width:38px; border: dotted #CCC 1px; cursor:pointer; text-align:right; font-weight:bold; background-color:#FFF; background-repeat:no-repeat; height:24px; background-image:url(<%=StaConsulta%>.jpg)" onclick="abreAgenda('<%=replace(formatdatetime(HoraMult,4),":","")%>', <%=idConsulta%>, '<%=DataMult%>', '<%=LocalIDMult%>', '<%=ProfissionalIDMult%>');" onMouseOver="document.getElementById('divM<%=idConsulta%>').style.display='block';" onMouseOut="document.getElementById('divM<%=idConsulta%>').style.display='none';" /><div id="divM<%=idConsulta%>" align="center" style="visibility:visible; opacity:0.85; filter:alpha(opacity=85); display:none; position:absolute; color:#FFF; padding:5px; background-color:#333; width:185px; height: 130px;"><%if not isnull(Imagem) and not Imagem="" then%><img src="<%=PastaIMG%><%=Imagem%>" width="100"><%end if%><hr><strong><%=pPacM("NomePaciente")%></strong><hr /><div style="background-color:#ffffff;color:#000000;padding:2px;"><img src="<%=StaConsulta%>.jpg"> <%=NomeStaConsulta%></div>
		</div>
					
					<%
				end if
			next
		end if
	end if
	%>
	</td>
	</tr>
<%end if%>
