<%
function centralSMS(checado, DataAgendamento, HoraAgendamento, AgendamentoID)
	LicencaID = replace(session("Banco"), "clinic", "")
	dbc.execute("delete from smsfila where LicencaID="&LicencaID&" and AgendamentoID="&AgendamentoID)
	if checado="S" then
		sql = "select * from sys_smsemail"
		set reg = db.execute(sql)
		if reg.eof then
			txtPadrao = "[NomePaciente], não se esqueça de sua consulta com [NomeProfissional] às [HoraAgendamento] do dia [DataAgendamento]."
			db_execute("insert into sys_smsemail (AtivoEmail, TextoEmail, ConfirmarPorEmail, TempoAntesEmail, AtivoSMS, TextoSMS, ConfirmarPorSMS, TempoAntesSMS) values ('on', '"&txtPadrao&"', 'S', '02:00:00', 'on', '"&txtPadrao&"', 'S', '02:00:00')")
			set reg = db.execute(sql)
		end if
		if cdate(DataAgendamento&" "&HoraAgendamento)>now() then
			'dados para replace
			set age = db.execute("select * from agendamentos where id="&AgendamentoID)
			set pac = db.execute("select NomePaciente, Cel1, Cel2 from pacientes where id="&age("PacienteID"))
			if not pac.eof then
				NomePaciente = trim(pac("NomePaciente"))
				if instr(NomePaciente, " ") then
					splPac = split(NomePaciente, " ")
					NomePaciente = splPac(0)
				end if
			end if
			set pro = db.execute("select * from profissionais where id="&age("ProfissionalID"))
			if not pro.EOF then
				set Trat = db.execute("select * from tratamento where id="&pro("TratamentoID"))
				if not Trat.eof then
					Tratamento = trat("Tratamento")
				end if
				NomeProfissional = Tratamento&" "&pro("NomeProfissional")
			end if
			TratamentoProfissional = ""
			
			Mensagem = reg("TextoSMS")
			Mensagem = replace(Mensagem, "[NomePaciente]", NomePaciente)
			Mensagem = replace(Mensagem, "[TratamentoProfissional]", "")
			Mensagem = replace(Mensagem, "[NomeProfissional]", NomeProfissional)
			Mensagem = replace(Mensagem, "[HoraAgendamento]", cdate( hour(age("Hora"))&":"&minute(age("Hora"))&":"&second(age("Hora")) ) )
			Mensagem = replace(Mensagem, "[DataAgendamento]", age("Data"))
			Mensagem = left(Mensagem, 160)
			
			'fecha dados para replace
			DataHoraEnvio = datediff("n", cdate(hour(reg("TempoAntesSMS"))&":"&minute(reg("TempoAntesSMS"))&":"&minute(reg("TempoAntesSMS"))), "00:00:00")
'			response.Write("|"&cdate()&"|")
			DataHoraEnvio = dateadd("n", DataHoraEnvio, DataAgendamento&" "&HoraAgendamento)
			
			
			'response.Write("insert into smsfila (LicencaID, DataHora, AgendamentoID, Mensagem) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"')")
			if len(pac("Cel1"))>5 then
				dbc.execute("insert into smsfila (LicencaID, DataHora, AgendamentoID, Mensagem, Celular) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"', '55"&replace(replace(replace(replace(pac("Cel1"), "(", ""), ")", ""), "-", ""), " ", "")&"')")
			end if
			if len(pac("Cel2"))>5 then
				dbc.execute("insert into smsfila (LicencaID, DataHora, AgendamentoID, Mensagem, Celular) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"', '55"&replace(replace(replace(replace(pac("Cel2"), "(", ""), ")", ""), "-", ""), " ", "")&"')")
			end if
		end if
	end if
end function

function getSexo(S)
	if S=1 then
		getsexo = "Masculino"
	elseif S=2 then
		getSexo = "Feminino"
	else
		getSexo = ""
	end if
end function

function altNotif(UserID, TarefaID, Status, IX)
	set u = db.execute("select * from sys_users where id="&UserID)
	if not u.eof then
		notiftarefas = u("notiftarefas")
		if IX = "I" then
			response.Write("update sys_users set notiftarefas='"&notiftarefas&"|"&TarefaID&","&Status&"' where id="&UserID)
			db_execute("update sys_users set notiftarefas='"&notiftarefas&"|"&TarefaID&","&Status&"' where id="&UserID)
		else
			if instr(notiftarefas, ",")>0 then
				spl = split(notiftarefas, "|")
				novaStr = ""
				for i=0 to ubound(spl)
					if instr(spl(i), ",")>0 then
						spl2 = split(spl(i), ",")
						if isnumeric(spl2(0)) then
							if ccur(spl2(0))<>TarefaID then
								novaStr = novaStr&"|"&spl(i)
							end if
						end if
					end if
				next
				response.Write("update sys_users set notiftarefas='"&novastr&"' where id="&UserID)
				db_execute("update sys_users set notiftarefas='"&novastr&"' where id="&UserID)
			end if
		end if
	end if
end function

function gravaChamada(rfProfissionalID, rfPaciente)
	sql = "select * from sys_chamadaporvoz"
	set configChamada = db.execute(sql)
	if configChamada.eof then
		db_execute("insert into sys_chamadaporvoz (Texto, Sexo, Usuarios) values ('[TratamentoProfissional] [NomeProfissional] chama paciente [NomePaciente] para atendimento', '2', 'ALL')")
		set configChamada = db.execute(sql)
	end if
	if instr(configChamada("Usuarios"), "ALL") then
		db_execute("update sys_users set chamar='"&rfProfissionalID&"_"&rfPaciente&"'")
	else
		spl = split(configChamada("Usuarios"), "|")
		for i=0 to ubound(spl)
			if isnumeric(spl(i)) then
				db_execute("update sys_users set chamar='"&rfProfissionalID&"_"&rfPaciente&"' where id="&spl(i))
			end if
		next
	end if
end function

function rep(Val)
	if isnull(Val) then
		rep=""
	else
		rep = replace(Val, "'", "''")
	end if
end function

function ref(Val)
	ref = replace(ref(Val), "'", "''")
end function

function refNull(Val)
	if ref(Val)="" then
		refNull = "NULL"
	else
		refNull = ref(Val)
	end if
end function

function treatVal(Val)
	treatVal = replace(Val, ".", "")
	treatVal = replace(treatVal, ",", ".")
end function

function treatValZero(Val)
	if isnumeric(Val) then
		treatValZero = replace(Val, ".", "")
		treatValZero = replace(treatValZero, ",", ".")
		treatValZero = "'"&treatValZero&"'"
	else
		treatValZero = 0
	end if
end function

function myDate(Val)
	if isDate(Val) and Val<>"" then
		myDate = year(Val)&"-"&month(Val)&"-"&day(Val)
	else
		myDate = "NULL"
	end if
end function

function myDateNULL(Val)
	if isDate(Val) and Val<>"" then
		myDateNULL = "'"&year(Val)&"-"&month(Val)&"-"&day(Val)&"'"
	else
		myDateNULL = "NULL"
	end if
end function

function myDateTime(Val)
	if isDate(Val) and Val<>"" then
		myDateTime = "'"&year(Val)&"-"&month(Val)&"-"&day(Val)&" "&hour(val)&":"&minute(val)&":"&second(val)&"'"
	else
		myDateTime = "NULL"
	end if
end function

function myTime(Val)
	if isDate(Val) and Val<>"" then
		myTime = "'"&Val&"'"
	else
		myTime = "NULL"
	end if
end function

function FormValPadImg(ModeloID, FormID)
	set camposIMG = db.execute("select * from buicamposforms where FormID="&ModeloID&" and TipoCampoID=3 and not isnull(ValorPadrao) and not ValorPadrao like ''")
	while not camposIMG.EOF
		db_execute("update `_"&ModeloID&"` set `"&camposIMG("id")&"`='"&camposIMG("ValorPadrao")&"' where id="&FormID)
	camposIMG.movenext
	wend
	camposIMG.close
	set camposIMG=nothing
end function

function selectCurrentAccounts(id, associations, selectedValue, others)
	splAssociations = split(associations,", ")
	%>
	<label for="<%= id %>">
	<%=CreditorOrDebtor%>
	</label>
		<br />
		<select class="width-80 chosen-select" id="<%= id %>" name="<%= id %>" data-placeholder="Selecione"<%=others%>>
			<option value="">&nbsp;</option>
			<%
			for i=0 to uBound(splAssociations)
				set Associations = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&splAssociations(i))
				while not Associations.EOF
					set AssRegs = db.execute(Associations("sql"))
					while not AssRegs.EOF
					%><option value="<%=Associations("id")&"_"&AssRegs("id")%>"<%if Associations("id")&"_"&AssRegs("id")=selectedValue then%> selected="selected"<%end if%>><%= AssRegs(""&Associations("column")&"") %> &raquo; <%= Associations("AssociationName") %></option>
					<%
					AssRegs.movenext
					wend
					AssRegs.close
					set AssRegs = nothing
				Associations.movenext
				wend
				Associations.close
				set Associations=nothing
			next
			%>
		</select>
	<%
end function

function nameInTable(userID)
	set user = db.execute("select * from sys_users where id="&userID)
	if not user.eof then
		set goTable = db.execute("select * from "&user("Table")&" where id="&user("idInTable"))
		if not goTable.EOF then
			nameInTable = goTable(""&user("NameColumn")&"")
		else
			nameInTable = " - "
		end if
	end if
end function

function fotoInTable(userID)
	fotoInTable = "assets/img/user.png"
	set user = db.execute("select * from sys_users where id="&userID)
	if not user.eof then
		set goTable = db.execute("select * from "&user("Table")&" where id="&user("idInTable"))
		if not goTable.EOF then
			if goTable("Foto")<>"" and not isnull(goTable("Foto")) then
				fotoInTable = "uploads/"&goTable("Foto")
			end if
		end if
	end if
end function
%>