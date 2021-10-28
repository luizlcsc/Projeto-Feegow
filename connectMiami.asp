<%
Session.Timeout=600
session.LCID=1046
ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set db = Server.CreateObject("ADODB.Connection")
db.Open ConnString

function permissoesPadrao()
	permissoesPadrao = "chatI, contatosV, contatosI, contatosA, contatosX, sys_financialcurrentaccountsV, sys_financialcurrentaccountsI, sys_financialcurrentaccountsA, sys_financialcurrentaccountsX, contasapagarV, contasapagarI, contasapagarA, contasapagarX, contasareceberV, contasareceberI, contasareceberA, contasareceberX, contratadoexternoV, contratadoexternoI, contratadoexternoA, contratadoexternoX, fornecedoresV, fornecedoresI, fornecedoresA, fornecedoresX, funcionariosV, funcionariosI, funcionariosA, funcionariosX, locaisgruposV, locaisgruposI, locaisgruposA, locaisgruposX, lancamentosV, lancamentosI, lancamentosA, lancamentosX, locaisV, locaisI, locaisA, locaisX, movementV, movementI, movementA, movementX, orcamentosV, orcamentosI, orcamentosA, orcamentosX, pacotesV, pacotesI, pacotesA, pacotesX, procedimentosV, procedimentosI, procedimentosA, procedimentosX, profissionalexternoV, profissionalexternoI, profissionalexternoA, profissionalexternoX, tabelasV, tabelasI, tabelasA, tabelasX, sys_financialexpensetypeV, sys_financialexpensetypeI, sys_financialexpensetypeA, sys_financialexpensetypeX, sys_financialincometypeV, sys_financialincometypeI, sys_financialincometypeA, sys_financialincometypeX, sys_financialcompanyunitsV, sys_financialcompanyunitsI, sys_financialcompanyunitsA, sys_financialcompanyunitsX, buiformsV, buiformsI, buiformsA, buiformsX, chamadaporvozA, configconfirmacaoA, configrateioV, configrateioI, configrateioA, configrateioX, emailsV, emailsI, emailsA, emailsX, configimpressosV, configimpressosA, produtoscategoriasV, produtoscategoriasI, produtoscategoriasA, produtoscategoriasX, produtosfabricantesV, produtosfabricantesI, produtosfabricantesA, produtosfabricantesX, lctestoqueV, lctestoqueI, lctestoqueA, lctestoqueX, produtoslocalizacoesV, produtoslocalizacoesI, produtoslocalizacoesA, produtoslocalizacoesX, produtosV, produtosI, produtosA, produtosX, conveniosV, conveniosI, conveniosA, conveniosX, faturasV, guiasV, guiasI, guiasA, guiasX, conveniosplanosV, conveniosplanosI, conveniosplanosA, conveniosplanosX, repassesV, repassesI, repassesA, repassesX, formsaeV, formsaeI, formsaeA, arquivosV, arquivosI, arquivosA, arquivosX, atestadosV, atestadosI, atestadosA, atestadosX, pacientesV, pacientesI, pacientesA, pacientesX, historicopacienteV, contapacV, contapacI, contapacX, areceberpacienteV, areceberpacienteI, areceberpacienteA, areceberpacienteX, diagnosticosV, diagnosticosI, diagnosticosA, diagnosticosX, envioemailsI, imagensV, imagensI, imagensA, imagensX, formslV, formslI, formslA, pedidosexamesV, pedidosexamesI, pedidosexamesX, prescricoesV, prescricoesI, prescricoesA, prescricoesX, recibosV, recibosI, recibosA, recibosX, agendaV, agendaI, agendaA, agendaX, horariosV, horariosA, contaprofV, contaprofI, contaprofX, profissionaisV, profissionaisI, profissionaisA, profissionaisX, relatoriosestoqueV, relatoriosfinanceiroV, relatoriospacienteV, chamadatxtV, chamadavozV, senhapA, usuariosI, usuariosA, usuariosX"
end function

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
			set age = db.execute("select a.*, p.TextoEmail, p.TextoSMS, p.MensagemDiferenciada, p.NomeProcedimento from agendamentos a left join procedimentos p on p.id=a.TipoCompromissoID where a.id="&AgendamentoID)
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
			if age("MensagemDiferenciada")="S" and not isnull(age("MensagemDiferenciada")) then
				Mensagem = age("TextoSMS")
			else
				Mensagem = reg("TextoSMS")
			end if
			Mensagem = replace(Mensagem, "[NomePaciente]", NomePaciente)
			Mensagem = replace(Mensagem, "[TratamentoProfissional]", "")
			Mensagem = replace(Mensagem, "[NomeProfissional]", NomeProfissional)
			Mensagem = replace(Mensagem, "[HoraAgendamento]", cdate( hour(age("Hora"))&":"&minute(age("Hora"))&":"&second(age("Hora")) ) )
			Mensagem = replace(Mensagem, "[DataAgendamento]", age("Data"))
			Mensagem = trim(Mensagem)
			if reg("ConfirmarPorSMS")="S" and not isnull(reg("ConfirmarPorSMS")) then
				Mensagem = left(Mensagem, 116)&" Responda CONFIRMA ou CANCELA"
			else
				Mensagem = left(Mensagem, 144)
			end if
			
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

function zEsq(Val, Quant)
	while len(Val)<Quant
		Val = "0"&Val
	wend
	zEsq = Val
end function

function quantidadeEstoque(ProdutoID, Lote, Validade)
	if isdate(Validade) then sqlValidade="Validade="&mydatenull(Validade) else sqlValidade="isnull(Validade)" end if
'	response.Write("select * from estoquelancamentos where ProdutoID="&ProdutoID&" and Lote like '"&Lote&"' and Validade like '"&Validade&"'")
	set quant = db.execute("select * from estoquelancamentos where ProdutoID="&ProdutoID&" and Lote like '"&Lote&"' and "&sqlValidade)
	quantidadeEstoque = 0
	while not quant.eof
		if quant("EntSai")="E" then
			quantidadeEstoque = quantidadeEstoque+quant("QuantidadeTotal")
		else
			quantidadeEstoque = quantidadeEstoque-quant("QuantidadeTotal")
		end if
	quant.movenext
	wend
	quant.close
	set quant = nothing
end function

function n2z(val)
	if isnull(val) then
		n2z=0
	else
		n2z=val
	end if
end function

function centralEmail(checado, DataAgendamento, HoraAgendamento, AgendamentoID)
	LicencaID = replace(session("Banco"), "clinic", "")
	dbc.execute("delete from emailsfila where LicencaID="&LicencaID&" and AgendamentoID="&AgendamentoID)
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
			set age = db.execute("select a.*, p.TextoEmail, p.TextoSMS, p.MensagemDiferenciada, p.NomeProcedimento from agendamentos a left join procedimentos p on p.id=a.TipoCompromissoID where a.id="&AgendamentoID)
			set pac = db.execute("select NomePaciente, Email1, Email2 from pacientes where id="&age("PacienteID"))
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
			
			if age("MensagemDiferenciada")="S" and not isnull(age("MensagemDiferenciada")) then
				Mensagem = age("TextoEmail")
			else
				Mensagem = reg("TextoEmail")
			end if
			Mensagem = replace(Mensagem, "[NomePaciente]", NomePaciente)
			Mensagem = replace(Mensagem, "[TratamentoProfissional]", "")
			Mensagem = replace(Mensagem, "[NomeProfissional]", NomeProfissional)
			Mensagem = replace(Mensagem, "[HoraAgendamento]", cdate( hour(age("Hora"))&":"&minute(age("Hora"))&":"&second(age("Hora")) ) )
			Mensagem = replace(Mensagem, "[DataAgendamento]", age("Data"))
			'Mensagem = left(Mensagem, 160)
			
			'fecha dados para replace
			DataHoraEnvio = datediff("n", cdate(hour(reg("TempoAntesEmail"))&":"&minute(reg("TempoAntesEmail"))&":"&minute(reg("TempoAntesEmail"))), "00:00:00")
'			response.Write("|"&cdate()&"|")
			DataHoraEnvio = dateadd("n", DataHoraEnvio, DataAgendamento&" "&HoraAgendamento)
			
			
			'response.Write("insert into smsfila (LicencaID, DataHora, AgendamentoID, Mensagem) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"')")
			if len(pac("Email1"))>5 then
				dbc.execute("insert into emailsfila (LicencaID, DataHora, AgendamentoID, Mensagem, Titulo, Email) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"', 'Lembrete de Agendamento para "&age("Data")&"', '"&rep(pac("Email1"))&"')")
			end if
			if len(pac("Email2"))>5 then
				dbc.execute("insert into emailsfila (LicencaID, DataHora, AgendamentoID, Mensagem, Titulo, Email) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"', 'Lembrete de Agendamento para "&age("Data")&"', '"&rep(pac("Email2"))&"')")
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

function getCorPele(Val)
	select case Val
		case 1
			getCorPele = "Branca"
		case 2
			getCorPele = "Negra"
		case 3
			getCorPele = "Parda"
		case 4
			getCorPele = "Amarela"
		case 5
			getCorPele = "Vermelha"
		case else
			getCorPele = "N&atilde;o informado"
	end select
end function

function getEstadoCivil(Val)
	select case Val
		case 1
			getEstadoCivil = "Casado"
		case 2
			getEstadoCivil = "Solteiro"
		case 3
			getEstadoCivil = "Divorciado"
		case 4
			getEstadoCivil = "Vi&uacute;vo"
		case else
			getEstadoCivil = "N&atilde;o informado"
	end select
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
		rep = replace(trim(Val&" "), "'", "''")
	end if
end function

function ref(Val)
	ref = replace(ref(Val), "'", "''")
end function

function req(Val)
	req = replace(req(Val), "'", "''")
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
	if isnumeric(Val) and Val<>"" and not isnull(Val) then
		treatValZero = replace(Val, ".", "")
		treatValZero = replace(treatValZero, ",", ".")
		treatValZero = "'"&treatValZero&"'"
	else
		treatValZero = 0
	end if
end function

function treatValTISS(Val)
	if isnumeric(Val) and Val<>"" then
		Val = formatnumber(Val,2)
		Val = replace(Val, ".", "")
		treatValTISS = replace(Val, ",", ".")
	else
		treatValTISS = "0.00"
	end if
end function

function treatValNULL(Val)
	if isnumeric(Val) and Val<>"" then
		Val = formatnumber(Val,2)
		Val = replace(Val, ".", "")
		treatValNULL = replace(Val, ",", ".")
	else
		treatValNULL = "NULL"
	end if
end function


function myDate(Val)
	if isDate(Val) and Val<>"" then
		myDate = year(Val)&"-"&month(Val)&"-"&day(Val)
	else
		myDate = "NULL"
	end if
end function

function myDateTISS(Val)
	if isDate(Val) and Val<>"" then
		Val = formatdatetime(Val,2)
		myDateTISS = right(Val,4)&"-"&mid(Val,4,2)&"-"&left(Val,2)
	else
		myDateTISS = ""
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
		if year(val)<1960 then
			myDateTime = "NULL"
		end if
	else
		myDateTime = "NULL"
	end if
end function

function myTime(Val)
	if isDate(Val) and Val<>"" then
		myTime = "'"&formatdatetime(Val,3)&"'"
	else
		myTime = "NULL"
	end if
end function

function myTimeTISS(Val)
	if isDate(Val) and Val<>"" then
		myTimeTISS = formatdatetime(Val,3)
	else
		myTimeTISS = ""
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
		<select class="width-80 chosen-select" id="<%= id %>" name="<%= id %>" data-placeholder="Selecione"<%= others %>>
			<option value="">&nbsp;</option>
			<%
			set caixas = db.execute("select * from caixa where isnull(dtFechamento)")
			while not caixas.eof
				%>
                <option value="7_<%=caixas("id")%>"<% If selectedValue="7_"&caixas("id") Then %> selected="selected"<% End If %>><%= caixas("Descricao") %></option>
				<%
			caixas.movenext
			wend
			caixas.close
			set caixas=nothing
			for i=0 to uBound(splAssociations)
				if splAssociations(i)="0" then
					%>
					<option value="0"<% If selectedValue="0" Then %> selected="selected"<% End If %>>Posi&ccedil;&atilde;o (Empresa)</option>
                    <option value="PRO"<% If selectedValue="PRO" Then %> selected="selected"<% End If %>>Profissional Executor</option>
					<%
				elseif splAssociations(i)="00" then
					%>
					<option value="0"<% If selectedValue="0" Then %> selected="selected"<% End If %>>Posi&ccedil;&atilde;o (Empresa)</option>
					<%
				else
					set Associations = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&splAssociations(i))
					while not Associations.EOF
						set AssRegs = db.execute(Associations("sql")&" limit 10000")
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
				end if
			next
			%>
		</select>
	<%
end function

function simpleSelectCurrentAccounts(id, associations, selectedValue, others)
	splAssociations = split(associations,", ")
	%>
		<select class="form-control" id="<%= id %>" name="<%= id %>"<%= others %>>
			<option value="">&nbsp;</option>
			<%
			for t=0 to uBound(splAssociations)
				if splAssociations(t)="0" then
					%>
					<option value="0"<% If selectedValue="0" Then %> selected="selected"<% End If %>>Posi&ccedil;&atilde;o (Empresa)</option>
                    <option value="PRO"<% If selectedValue="PRO" Then %> selected="selected"<% End If %>>Profissional Executor</option>
					<%
				elseif splAssociations(t)="00" then
					%>
					<option value="0"<% If selectedValue="0" Then %> selected="selected"<% End If %>>Posi&ccedil;&atilde;o (Empresa)</option>
					<%
				else
					set Associations = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&splAssociations(t))
					while not Associations.EOF
						set AssRegs = db.execute(Associations("sql")&" limit 10000")
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
				end if
			next
			%>
		</select>
	<%
end function

function aaTable(id)
	set getTable = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&id)
	if getTable.eof then
		aaTabela = ""
		aaRecurso = ""
		aaColuna = ""
	else
		aaTabela = getTable("Table")
		aaRecurso = getTable("AssociationName")
		aaColuna = getTable("column")
	end if
	aaTable = array(aaTabela, aaRecurso, aaColuna)
end function

function selectInsertCA(label, name, value, associations, othersToSelect, othersToInput, campoSuperior)
	'1. o padrão do insert é o primeiro
	'2. o valor do campo pode ser do tipo conta (quando tem mais de 1, ex.: 1_232) ou id (ex.: 4)
	'3. só preenche se quiser
	if value<>"" and value<>"_" and instr(value, "_")>0 then
		splCA = split(value, "_")
		aa = splCA(0)
		ca = splCA(1)
'		response.Write("{"&value&"}")
		resultado = aaTable(aa)
		strCA = "select id, "&resultado(2)&" from "&resultado(0)&" where id="&ca
		'response.Write(strCA)
		set getTextValue = db.execute(strCA)
		if not getTextValue.EOF then
			textValue = getTextValue(""&resultado(2)&"")
		end if
	end if
	%><%if label<>"" then%><label><%=label%></label><br /><%end if%>
	<input type="hidden" name="<%=name%>" id="<%=name%>" value="<%=value%>" />
    <span class="input-icon input-icon-right width-100">
		<input type="text" class="form-control" id="search<%=name%>" name="search<%=name%>" value="<%=textValue%>" autocomplete="off" <%= othersToInput %>>
		<i class="far fa-search"></i>
	</span>
	<div id="resultSelect<%=name%>" style="position:absolute; display:none; overflow:hidden; background-color:#f3f3f3; width:400px; z-index:1000;">
    	buscando...
    </div>
<script language="javascript">
function f_<%=replace(name, "-", "_")%>(){
	$.post("selectInsertCA.asp",{
		   selectID:'<%=name%>',
		   typed:$("#search<%=name%>").val(),
		   associations:'<%=associations%>',
		   othersToSelect:'<%= othersToSelect %>'<%if campoSuperior<>"" then%>,
		   campoSuperior:$("#<%=campoSuperior%>").val()<%end if%>
		   },function(data,status){
	  $("#resultSelect<%=name%>").html(data);	  
	});
}

var typingTimer<%=replace(name, "-", "_")%>;
$(document).ready(function(){
  $("#search<%=name%>").keyup(function(){
	if($("#search<%=name%>").val().length>0){
		$("#resultSelect<%=name%>").css("display", "block");
		$("#resultSelect<%=name%>").html("buscando...");
		clearTimeout(typingTimer<%=replace(name, "-", "_")%>);
		if ($("#search<%=name%>").val) {
			typingTimer<%=replace(name, "-", "_")%> = setTimeout(f_<%=replace(name, "-", "_")%>, 400);
		}
	}else{
		$("#resultSelect<%=name%>").css("display", "none");
		$("#<%=name%>").val("0");
	}
  });
  $("#search<%=name%>").click(function(){
	this.select();
  });
});
</script>
	<%
end function


function nameInTable(userID)
	set user = db.execute("select * from sys_users where id = '"&userID&"'")
	if not user.eof then
		set goTable = db.execute("select * from "&user("Table")&" where id="&user("idInTable"))
		if not goTable.EOF then
			nameInTable = goTable(""&user("NameColumn")&"")
		else
			nameInTable = " - "
		end if
	end if
end function

function nameInAccount(conta)
	nameInAccount = ""
	splf = split(conta, "_")
	set contaf = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&splf(0))
	if not contaf.eof then
		set pcontaf = db.execute("select * from "&contaf("table")&" where id="&splf(1))
		if not pcontaf.eof then
			nameInAccount = pcontaf(""&contaf("column")&"")
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

function quickField(fieldType, fieldName, label, width, fieldValue, sqlOrClass, columnToShow, additionalTags)
	if label<>"" then
		abreDivBoot = "<div class=""col-md-"&width&""">"
		fechaDivBoot = "</div>"
		if label=" " then
			LabelFor = ""
		else
			LabelFor = "<label for="""&fieldName&""">"&label&"</label><br />"
		end if
    else
		abreDivBoot = ""
		fechaDivBoot = ""
		LabelFor = ""
	end if
	
	response.Write(abreDivBoot)
	select case fieldType
		case "text"
			response.Write(LabelFor)
			%>
			<input type="text" class="form-control <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>" value="<%=fieldValue%>"<%=additionalTags%> />
			<%
		case "email", "phone", "mobile"
			if fieldType="phone" then
				icone = "phone"
				subType = "text"
				mask = " input-mask-phone"
			elseif fieldType="mobile" then
				icone = "mobile-phone"
				subType = "text"
				mask = " input-mask-celphone"
			elseif fieldType="email" then
				icone = "envelope-o"
				subType = "email"
				mask = ""
			end if
			response.Write(LabelFor)
			%>
            <div class="input-group">
                <span class="input-group-addon">
                    <i class="far fa-<%= icone %> bigger-110"></i>
                </span>
                <input type="text" placeholder="" value="<%=fieldValue%>" class="form-control<%=mask%> <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>" maxlength="150"<%=additionalTags%> />
            </div>
			<%
		case "memo"
			response.Write(LabelFor)
			%>
			<textarea class="form-control <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>"<%=additionalTags%>><%=fieldValue%></textarea>
			<%
		case "palavras"
			response.Write(LabelFor)
			%>
			<input type="text" name="<%=fieldName%>" id="<%=fieldName%>" value="<%=fieldValue%>" placeholder="Digite e ENTER..." />
			<script type="text/javascript">
			jQuery(function($) {							//we could just set the data-provide="tag" of the element inside HTML, but IE8 fails!
				var tag_input = $('#<%=fieldName%>');
				if(! ( /msie\s*(8|7|6)/.test(navigator.userAgent.toLowerCase())) ) 
				{
					tag_input.tag(
					  {
						placeholder:tag_input.attr('placeholder'),
						//enable typeahead by specifying the source array
						source: ace.variable_US_STATES,//defined in ace.js >> ace.enable_search_ahead
					  }
					);
				}
				else {
					//display a textarea for old IE, because it doesn't support this plugin or another one I tried!
					tag_input.after('<textarea id="'+tag_input.attr('id')+'" name="'+tag_input.attr('name')+'" rows="3">'+tag_input.val()+'</textarea>').remove();
					//$('#form-field-tags').autosize({append: "\n"});
				}
			});
            </script>
			<%
		case "editor"
			response.Write(LabelFor)
			%>
			<textarea class="form-control" name="<%=fieldName%>" id="<%=fieldName%>"<%=additionalTags%>><%=fieldValue%></textarea>
            <script>
            $(function () {  
                CKEDITOR.config.height = <%=sqlOrClass%>;
                $('#<%=fieldName%>').ckeditor();
            });
			</script>
			<%
		case "currency"
			response.Write(LabelFor)
			if not isnull(fieldValue) and not fieldValue="" and isnumeric(fieldValue) then
				fieldValue = formatnumber(fieldValue,2)
			end if
			%>
            <div class="input-group">
            <span class="input-group-addon">
            <strong><%=session("CurrencySymbol")%></strong>
            </span>
            <input id="<%=fieldName%>" class="form-control input-mask-brl <%=sqlOrClass%>" type="text" style="text-align:right" name="<%=fieldName%>" value="<%=fieldValue%>"<%=additionalTags%>>
            </div>
			<%
		case "select"
			response.Write(LabelFor)
			%>
            <select name="<%= fieldName %>" id="<%= fieldName %>" class="chosen-select width-80"<%=additionalTags%>>
            <%
			set doSql = db.execute(sqlOrClass)
			while not doSql.EOF
'				response.Write(cstr(doSql("id"))&"="&fieldValue)
				%><option value="<%=doSql("id")%>"<% If doSql("id")=fieldValue or cstr(doSql("id"))=fieldValue Then %> selected="selected"<% End If %>><%=doSql(""&columnToShow&"")%></option>
				<%
			doSql.movenext
			wend
			doSql.close
			set doSql=nothing
            %>
            </select>
            <%
		case "selectCentral"
		%><!--#include file="connectCentral.asp"--><%
			response.Write(LabelFor)
			%>
            <select name="<%= fieldName %>" id="<%= fieldName %>" class="chosen-select width-80"<%=additionalTags%>>
            <%
			set doSql = dbc.execute(sqlOrClass)
			while not doSql.EOF
'				response.Write(cstr(doSql("id"))&"="&fieldValue)
				%><option value="<%=doSql("id")%>"<% If doSql("id")=fieldValue or cstr(doSql("id"))=fieldValue Then %> selected="selected"<% End If %>><%=doSql(""&columnToShow&"")%></option>
				<%
			doSql.movenext
			wend
			doSql.close
			set doSql=nothing
            %>
            </select>
            <%
		case "simpleSelect"
			response.Write(LabelFor)
			if instr(additionalTags, "empty")>0 then
				vazio = ""
			else
				vazio = "0"
			end if
			%>
            <select name="<%= fieldName %>" id="<%= fieldName %>" class="form-control"<%=additionalTags%>>
            <option value="<%=vazio%>">Selecione</option>
            <%
			set doSql = db.execute(sqlOrClass)
			while not doSql.EOF
				idSQL = doSql("id")
				if isnull(idSQL) then
					idSQL = ""
				end if
				%><option value="<%=idSQL%>"<% If idSQL=fieldValue or cstr(idSQL)=fieldValue Then %> selected="selected"<% End If %>><%=doSql(""&columnToShow&"")%></option>
				<%
			doSql.movenext
			wend
			doSql.close
			set doSql=nothing
            %>
            </select>
            <%
		case "multiple"
			response.Write(LabelFor)
			%>
			<select multiple="" class="width-80 chosen-select tag-input-style" id="<%=fieldName%>" name="<%=fieldName%>"<%=additionalTags%>>
			<%
			set listItems = db.execute(sqlOrClass)
			while not listItems.EOF
			%>
			<option value="|<%=listItems("id")%>|"<%if inStr(fieldValue, "|"&listItems("id")&"|")>0 then%> selected="selected"<%end if%>><%=listItems(""&columnToShow&"")%></option>
			<%
			listItems.movenext
			wend
			listItems.close
			set listItems=nothing
			%>
			</select>
            <%
		case "cor"
			%>
            <select name="<%= fieldName %>" id="<%= fieldName %>" class="hide">
            <%
			set doSql = db.execute(sqlOrClass)
			while not doSql.EOF
				%><option value="<%=doSql(""&columnToShow&"")%>"<% If doSql(""&columnToShow&"")=fieldValue Then %> selected="selected"<% End If %>><%=doSql(""&columnToShow&"")%></option>
				<%
			doSql.movenext
			wend
			doSql.close
			set doSql=nothing
            %>
            </select> <label for="<%=fieldName%>"> &nbsp;<%=label%></label>
            <%
		case "datepicker"
			response.Write(LabelFor)
			%>
            <div class="input-group">
            <input id="<%= fieldName %>" class="form-control date-picker <%=sqlOrClass%>" type="text" value="<%= fieldValue %>" name="<%= fieldName %>" data-date-format="dd/mm/yyyy"<%=additionalTags%>>
            <span class="input-group-addon<%if instr(sqlOrClass, "input-sm")>0 then%> input-sm<%end if%>">
            <i class="far fa-calendar bigger-110"></i>
            </span>
            </div>
			<%
		case "timepicker"
			response.Write(LabelFor)
			%>
            <div class="input-group bootstrap-timepicker">
                <input id="<%=fieldName%>" name="<%=fieldName%>" value="<%=fieldValue%>" type="text" class="form-control" />
                <span class="input-group-addon">
                    <i class="far fa-clock-o bigger-110"></i>
                </span>
            </div>
            <script language="javascript">
            $('#<%=fieldName%>').timepicker({
                minuteStep: 1,
                showSeconds: true,
                showMeridian: false
            }).next().on(ace.click_event, function(){
                $(this).prev().focus();
            });
            </script>
			<%
		case "simpleCheckbox"
			%>
            <br />
			<input type="checkbox" class="ace <%=sqlOrClass%>" name="<%= fieldName %>" id="<%= fielName %>" value="<%= fieldValue %>" /> <span class="lbl"> <%= label %></span>
			<%
		case "contratado"
            response.Write(LabelFor)
			%>
            <select name="<%=fieldName%>" id="<%=fieldName%>" class="form-control">
            <%
            set empresa = db.execute("select * from empresa")
            if not empresa.eof then
                if not isnull(empresa("NomeEmpresa")) then
                    %><option value="0"><%=empresa("NomeEmpresa")%></option>
                    <%
                end if
            end if
            %><option disabled="disabled" style="border-bottom:1px dotted #CCC; border-top:1px dotted #CCC;"></option><%
            set filiais = db.execute("select * from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 order by UnitName")
            while not filiais.eof
                %><option value="-<%=filiais("id")%>"<% If fieldValue=(filiais("id")*(-1)) or fieldValue=cstr(filiais("id")*(-1)) Then %> selected="selected"<%end if%>><%=filiais("UnitName")%></option>
                <%
            filiais.movenext
            wend
            filiais.close
            set filiais=nothing
            %><option disabled="disabled" style="border-bottom:1px dotted #CCC; border-top:1px dotted #CCC;"></option><%
            set prof = db.execute("select id, NomeProfissional from profissionais where sysActive=1 order by NomeProfissional")
            while not prof.eof
                %>
                <option value="<%=prof("id")%>"<% If fieldValue=prof("id") or fieldValue=cstr(prof("id")) Then %> selected="selected"<%end if%>><%=prof("NomeProfissional")%></option>
                <%
            prof.movenext
            wend
            prof.close
            set prof=nothing
            %>
            </select>
        <%
		case "empresa"
			'response.Write("["&session("Unidades")&"]")
            set filiais = db.execute("select * from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 order by UnitName")
			if filiais.eof then
				%>
				<input type="hidden" name="<%=fieldName%>" id="<%=fieldName%>" value="0" />
				<%
			else
				response.Write(LabelFor)
				%>
				<select name="<%=fieldName%>" id="<%=fieldName%>" class="form-control<%=sqlOrClass%>">
				<%
				set empresa = db.execute("select * from empresa")
				if not empresa.eof then
					if not isnull(empresa("NomeEmpresa")) and instr(session("Unidades"), "|0|") then
						%><option value="0"><%=empresa("NomeEmpresa")%></option>
						<%
					end if
				end if
				%><option disabled="disabled" style="border-bottom:1px dotted #CCC; border-top:1px dotted #CCC;"></option><%
				while not filiais.eof
					if instr(session("Unidades"), "|"&filiais("id")&"|") then
						%><option value="<%=filiais("id")%>"<%
						If fieldValue=filiais("id") or fieldValue=cstr(filiais("id")) Then
							%> selected="selected"<%
						end if
					end if
					%>><%=filiais("UnitName")%></option>
					<%
				filiais.movenext
				wend
				filiais.close
				set filiais=nothing
				%>
				</select>
			<%
			end if
	end select
	response.Write(fechaDivBoot)
end function

function Idade(DataNascimento)
	Idade=datediff("yyyy",DataNascimento,date())
	if (month(DataNascimento)>month(date())) or (month(DataNascimento)=month(date()) and day(DataNascimento)>day(date())) then
		Idade=Idade-1
	end if

	UltNivPas=dateadd("yyyy",Idade,DataNascimento)
	MesesIdade=datediff("m",UltNivPas,date())
	if (day(UltNivPas)>day(date)) and MesesIdade>0 then
		MesesIdade=MesesIdade-1
	end if
	
	UltMesPas=dateadd("m",MesesIdade,UltNivPas)
	DiasIdade=datediff("d",UltMesPas,date())
	
	if DiasIdade=1 then EscreveDias="dia" else EscreveDias="dias" end if
	if MesesIdade=1 then EscreveMeses="m&ecirc;s" else EscreveMeses="meses" end if
	if Idade=1 then EscreveAnos="ano" else EscreveAnos="anos" end if
	if Idade>0 then
		escreveIdade = escreveIdade&"&nbsp;"&Idade&"&nbsp;"& EscreveAnos
	end if
	if MesesIdade>0 then
		escreveIdade = escreveIdade&",&nbsp;"&MesesIdade&"&nbsp;"&EscreveMeses
	end if
	if DiasIdade>0 then
		escreveIdade = escreveIdade&",&nbsp;"&DiasIdade&"&nbsp;"& EscreveDias
	end if
	if left(escreveIdade, 1)="," then
		escreveIdade = right(escreveIdade, len(escreveIdade)-1)
	end if
	if isDate(DataNascimento) then
		if cdate(DataNascimento)>date() then
			Idade = "N&atilde;o nasceu ainda"
		elseif cdate(DataNascimento)=date() then
			Idade = "Nascido hoje"
		else
			Idade = escreveIdade
		end if
	else
		Idade = "Nascimento n&atilde;o informado"
	end if
end function

function iconMethod(PaymentMethodID, CD)
	if not isNull(PaymentMethodID) then
		response.Write("<img width=""18"" src=""assets/img/"&PaymentMethodID&CD&".png"" />")
    end if
end function

function accountName(AccountAssociationID, AccountID)
	set getAssociation = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&AccountAssociationID)
	if not getAssociation.eof then
		set getAccount = db.execute("select * from "&getAssociation("table")&" where id="&AccountID)
		if not getAccount.EOF then
			accountName = getAccount(""&getAssociation("column")&"")
		end if
	end if
end function


function accountBalance(AccountID, Flag)
	splAccountInQuestion = split(AccountID, "_")
	AccountAssociationID = splAccountInQuestion(0)
	AccountID = splAccountInQuestion(1)

	accountBalance = 0
	set getMovement = db.execute("select * from sys_financialMovement where ((AccountAssociationIDCredit="&AccountAssociationID&" and AccountIDCredit="&AccountID&") or (AccountAssociationIDDebit="&AccountAssociationID&" and AccountIDDebit="&AccountID&")) and Date<='"&myDate(date())&"' order by Date")
	while not getMovement.eof
		Value = getMovement("Value")
		AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
		AccountIDCredit = getMovement("AccountIDCredit")
		AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
		AccountIDDebit = getMovement("AccountIDDebit")
		PaymentMethodID = getMovement("PaymentMethodID")
		Rate = getMovement("Rate")
		'defining who is the C and who is the D
		if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
			CD = "C"
			if getMovement("Currency")<>session("DefaultCurrency") then
				Value = Value / Rate
			end if
			accountBalance = accountBalance+Value
		else
			if getMovement("Currency")<>session("DefaultCurrency") then
				Value = Value / Rate
			end if
			CD = "D"
			accountBalance = accountBalance-Value
		end if
		'-
		cType = getMovement("Type")
	getMovement.movenext
	wend
	getMovement.close
	set getMovement = nothing

	if AccountAssociationID=1 or AccountAssociationID=7 then
		accountBalance = accountBalance*(-1)
	end if

	if Flag=1 then
		if accountBalance<0 then
			accountBalance = "<span class=""label label-danger arrowed-in""><i class='icon-thumbs-down bigger-120'></i> Saldo negativo de "&session("CurrencySymbol")&"&nbsp;"&formatnumber(accountBalance,2)&"</span>"
		elseif accountBalance>0 then
			accountBalance = "<span class=""label label-success arrowed-in""><i class='icon-thumbs-up bigger-120'></i> Saldo positivo de "&session("CurrencySymbol")&"&nbsp;"&formatnumber(accountBalance,2)&"</span>"
		else
			accountBalance = "<span class=""label label-lg arrowed-in"">Saldo: "&session("CurrencySymbol")&"&nbsp;"&formatnumber(accountBalance,2)&"</span>"
		end if
	end if
	
end function

function getCD(Credit, Debit)
'	if 
end function

function selectInsert(label, name, value, resource, showColumn, othersToSelect, othersToInput, campoSuperior)
	'1. o padrão do insert é o primeiro
	'2. o valor do campo pode ser do tipo conta (quando tem mais de 1, ex.: 1_232) ou id (ex.: 4)
	'3. só preenche se quiser
	if value<>"" and isnumeric(value) and value<>0 then
		set getTextValue = db.execute("select id, "&showColumn&" from "&resource&" where id="&value)
		if not getTextValue.EOF then
			textValue = getTextValue(""&showColumn&"")
		end if
	end if
	%><%if label<>"" then%><label><%=label%></label><br /><%end if%>
	<input type="hidden" name="<%=name%>" id="<%=name%>" value="<%=value%>" />
    <span class="input-icon input-icon-right width-100">
		<input type="text" class="form-control" id="search<%=name%>" name="search<%=name%>" value="<%=textValue%>" autocomplete="off" <%= othersToInput %>>
		<i class="far fa-search"></i>
	</span>
	<div id="resultSelect<%=name%>" style="position:absolute; display:none; overflow:hidden; background-color:#f3f3f3; width:400px; z-index:1000;">
    	buscando...
    </div>
<script language="javascript">
function f_<%=replace(name, "-", "_")%>(){
	$.post("selectInsert.asp",{
		   selectID:'<%=name%>',
		   typed:$("#search<%=name%>").val(),
		   resource:'<%=resource%>',
		   showColumn:'<%=showColumn%>',
		   othersToSelect:'<%= othersToSelect %>'<%if campoSuperior<>"" then%>,
		   campoSuperior:$("#<%=campoSuperior%>").val()<%end if%>
		   },function(data,status){
	  $("#resultSelect<%=name%>").html(data);	  
	});
}

var typingTimer<%=replace(name, "-", "_")%>;
$(document).ready(function(){
  $("#search<%=name%>").keyup(function(){
	if($("#search<%=name%>").val().length>0){
		$("#resultSelect<%=name%>").css("display", "block");
		$("#resultSelect<%=name%>").html("buscando...");
		clearTimeout(typingTimer<%=replace(name, "-", "_")%>);
		if ($("#search<%=name%>").val) {
			typingTimer<%=replace(name, "-", "_")%> = setTimeout(f_<%=replace(name, "-", "_")%>, 400);
		}
	}else{
		$("#resultSelect<%=name%>").css("display", "none");
		$("#<%=name%>").val("0");
	}
  });
  $("#search<%=name%>").click(function(){
	this.select();
  });
});
</script>
	<%
end function

function selectList(label, name, value, resource, showColumn, othersToSelect, othersToInput, campoSuperior)
	'1. o padrão do insert é o primeiro
	'2. o valor do campo pode ser do tipo conta (quando tem mais de 1, ex.: 1_232) ou id (ex.: 4)
	'3. só preenche se quiser
	%><%if label<>"" then%><label><%=label%></label><br /><%end if%>
    <span class="input-icon input-icon-right width-100">
		<input type="text" class="form-control" id="<%=name%>" name="<%=name%>" value="<%=value%>" autocomplete="off" <%= othersToInput %>>
		<i class="far fa-search"></i>
	</span>
	<div id="resultSelect<%=name%>" style="position:absolute; display:none; overflow:hidden; background-color:#f3f3f3; width:400px; z-index:1000;">
    	buscando...
    </div>
<script language="javascript">
function f_<%=replace(name, "-", "_")%>(){
	$.post("selectList.asp",{
		   selectID:'<%=name%>',
		   typed:$("#<%=name%>").val(),
		   resource:'<%=resource%>',
		   showColumn:'<%=showColumn%>',
		   othersToSelect:'<%= othersToSelect %>'<%if campoSuperior<>"" then%>,
		   campoSuperior:$("#<%=campoSuperior%>").val()<%end if%>
		   },function(data,status){
	  $("#resultSelect<%=name%>").html(data);	  
	});
}

var typingTimer<%=replace(name, "-", "_")%>;
$(document).ready(function(){
  $("#<%=name%>").keyup(function(){
	if($("#<%=name%>").val().length>0){
		$("#resultSelect<%=name%>").css("display", "block");
		$("#resultSelect<%=name%>").html("buscando...");
		clearTimeout(typingTimer<%=replace(name, "-", "_")%>);
		if ($("#<%=name%>").val) {
			typingTimer<%=replace(name, "-", "_")%> = setTimeout(f_<%=replace(name, "-", "_")%>, 400);
		}
	}else{
		$("#resultSelect<%=name%>").css("display", "none");
	}
  });
});
</script>
	<%
end function

function selectCurrencies(Name, SelectedValue, width, label)
	If session("OtherCurrencies")<>"" Then
		%>
        <div class="col-md-<%=width%>">
        <label><%=label%></label><br />
		<select class="form-control" id="<%=Name%>" name="<%=Name%>">
			<option value="<%=session("DefaultCurrency")%>"<%if SelectedValue=session("DefaultCurrency") then%> selected="selected"<%end if%>><%=session("DefaultCurrency")%></option>
			<%
			splOther = split(session("OtherCurrencies"), "|")
			for i=0 to ubound(splOther)
				%>
				<option value="<%=splOther(i)%>"<%if SelectedValue=splOther(i) then%> selected="selected"<%end if%>><%=splOther(i)%></option>
				<%
			next
			%>
		</select>
        </div>
		<%
	else
		%><input type="hidden" name="<%=Name%>" id="<%=Name%>" value="<%= session("DefaultCurrency") %>" />
        <%
	end if
end function

function getRate()
	set conf = db.execute("select * from sys_Config")
	getRate = conf("Rate")
end function

function Aut(Permissao)
'	set Pstr=db.execute("select id,Permissoes from sys_users where id="&session("User")&"")
'	if not Pstr.eof then
'	strP=Pstr("Permissoes")
		if inStr(session("Permissoes"),Permissao)>0 then
'		if inStr(strP,Permissao)>0 then
			Aut=1
		else
			Aut=0
		end if
'	end if
'Autorizado="Sim"
end function

function formSave(FormID, btnSaveID, AcaoSeguinte)
	%>
    $("#<%=FormID%>").submit(function() {
		$("#<%=btnSaveID%>").html('salvando');
		$("#<%=btnSaveID%>").attr('disabled', 'disabled');
        $.post("save.asp", $("#<%=FormID%>").serialize())
        .done(function(data) {
          $("#<%=btnSaveID%>").html('<i class="far fa-save"></i> Salvar');
		  $("#<%=btnSaveID%>").removeAttr('disabled');
          eval(data);
          <%=AcaoSeguinte%>
        });
        return false;
    })
	<%
end function

function insertRedir(tableName, id)
	if id="N" then
		sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
		set vie = db.execute(sqlVie)
		if vie.eof then
			db_execute("insert into "&tableName&" (sysUser, sysActive) values ("&session("User")&", 0)")
			set vie = db.execute(sqlVie)
		end if
		'===> Exceções
		if req("Lancto")<>"" then
			strLancto = "&Lancto="&req("Lancto")
		end if
		response.Redirect("?P="&tableName&"&I="&vie("id")&"&Pers="&req("Pers") &strLancto)
	else
		set data = db.execute("select * from "&tableName&" where id="&id)
		if data.eof then
			response.Redirect("?P="&tableName&"&I=N&Pers="&req("Pers"))
		end if
	end if
end function

function Subform(NomeTabela, Coluna, regPrin, FormID)
	%>
	<!--#include file="Subform.asp"-->
	<%
end function

function dominioRepasse(FormaID, ProfissionalID, ProcedimentoID)
'conferir -> FormaID pode ser |P| para todos particulares, |C| para todos convênios, |00_0| para forma predefinida de recto e > |0| para qualquer id de convênio
	dominioRepasse = 0
	pontomaior = 0
	set dom = db.execute("select * from rateiodominios order by Tipo desc")
	while not dom.eof
		esteponto = 0
		queima = 0
		if instr(dom("Formas"), "|"&FormaID&"|")>0 then
			esteponto = esteponto+1
		else
			if trim(dom("Formas"))<>"" then
'				if instr(FormaID, "_") and instr(dom("Formas"), "|P|")>0 then
'					queima = 0
'				else
					queima = 1
'				end if
			end if
		end if
		if instr(dom("Profissionais"), "|"&ProfissionalID&"|")>0 then
			esteponto = esteponto+1
		else
			if trim(dom("Profissionais"))<>"" then
				queima = 1
			end if
		end if
		if instr(dom("Procedimentos"), "|"&ProcedimentoID&"|")>0 then
			esteponto = esteponto+1
		else
			if trim(dom("Procedimentos"))<>"" then
				queima = 1
			end if
		end if

		if queima=0 and esteponto>pontomaior then
			dominioRepasse = dom("id")
			pontomaior = esteponto
		end if
	dom.movenext
	wend
	dom.close
	set dom = nothing
end function

function materiaisInformados(DominioID, Usuario, AtendProcID)
	set mat = db.execute("select * from rateiofuncoes where DominioID="&DominioID&" and FM='M'")
	while not mat.eof
		db_execute("insert into atendimentosmateriais (AtendProcID, InfConf, ProdutoID, ValorUnitario, Quantidade, sysUser) values ("&AtendProcID&", 'I', "&mat("ProdutoID")&", "&treatvalzero(mat("ValorUnitario"))&", "&treatvalzero(mat("Quantidade"))&", "&session("User")&")")
	mat.movenext
	wend
	mat.close
	set mat=nothing
end function

function getValorPago(ParcelaID, ValorPago)
	 if isnull(ValorPago) then
	 	if isnull(ParcelaID) then
			ValorPago = 0
		else
			AlreadyDiscounted = 0
			set getAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&ParcelaID)
			while not getAlreadyDiscounted.EOF
	'			response.Write( AlreadyDiscounted&"+"&getAlreadyDiscounted("DiscountedValue") &chr(13) )
				AlreadyDiscounted = AlreadyDiscounted+getAlreadyDiscounted("DiscountedValue")
			getAlreadyDiscounted.movenext
			wend
			getAlreadyDiscounted.close
			set getAlreadyDiscounted = nothing
	
			PaymentMovement = 0
			set getPaymentMovement = db.execute("select * from sys_financialDiscountPayments where MovementID="&ParcelaID)
			while not getPaymentMovement.EOF
				PaymentMovement = PaymentMovement+getPaymentMovement("DiscountedValue")
			getPaymentMovement.movenext
			wend
			getPaymentMovement.close
			set getPaymentMovement = nothing
			
			getValorPago = ccur(AlreadyDiscounted) + ccur(PaymentMovement)
			db_execute("update sys_financialmovement set ValorPago="&treatvalzero(getValorPago)&" where id="&ParcelaID)
			db_execute("update tempparcelas set ValorPago="&treatvalzero(getValorPago)&" where id="&ParcelaID)
		end if
	 else
	 	getValorPago = ValorPago
	 end if
	 getValorPago = ccur(getValorPago)
end function

function macro(editor)
	macro = "<div class=""btn-toolbar pull-right"">"
	macro = macro&"<div class=""btn-group"">"
	macro = macro&"	<div class=""btn-group"">      <div>Inserir Macro&nbsp;&nbsp;</div>     </div>"
	macro = macro&"	<div class=""btn-group"">"
	macro = macro&"	  <button class=""btn dropdown-toggle btn-xs btn-info"" data-toggle=""dropdown"">Paciente <span class=""caret""></span></button>"
	macro = macro&"	  <ul class=""dropdown-menu"">"
	strPac = "[Paciente.Nome]|^[Paciente.Idade]|^[Paciente.CPF]|^[Paciente.Prontuario]|^[Paciente.Endereco]|^[Paciente.Numero]|^[Paciente.Cidade]|^[Paciente.Estado]|^[Paciente.Cep]|^[Paciente.Nascimento]|^[Paciente.Sexo]|^[Paciente.Cor]|^[Paciente.Altura]|^[Paciente.Peso]|^[Paciente.IMC]|^[Paciente.Religiao]|^[Paciente.Tel1]|^[Paciente.Tel2]|^[Paciente.Cel1]|^[Paciente.Cel2]|^[Paciente.Email1]|^[Paciente.Email2]|^[Paciente.Profissao]|^[Paciente.Documento]|^[Paciente.EstadoCivil]|^[Paciente.Origem]|^[Paciente.IndicadoPor]|^[Paciente.Observacoes]|^[Paciente.Convenio]|^[Paciente.Matricula]|^[Paciente.Validade]"
	splPac = split(strPac, "|^")
	for pak=0 to ubound(splPac)
		macro = macro&"		  <li><a href=""javascript:macroJS('"&editor&"', '"&splPac(pak)&"')"">"&splPac(pak)&"</a></li>"
	next
	macro = macro&"	  </ul>"
	macro = macro&"	</div>"
	macro = macro&"	<div class=""btn-group"">"
	macro = macro&"	  <button class=""btn dropdown-toggle btn-xs btn-info"" data-toggle=""dropdown"">Profissional <span class=""caret""></span></button>"
	macro = macro&"	  <ul class=""dropdown-menu"">"
	strPro = "[Profissional.Nome]|^[Profissional.Documento]"
	splPro = split(strPro, "|^")
	for prk=0 to ubound(splPro)
		macro = macro&"		  <li><a href=""javascript:macroJS('"&editor&"', '"&splPro(prk)&"')"">"&splPro(prk)&"</a></li>"
	next
	macro = macro&"	  </ul>"
	macro = macro&"	</div>"
	macro = macro&"	<div class=""btn-group"">"
	macro = macro&"	  <button class=""btn dropdown-toggle btn-xs btn-info"" data-toggle=""dropdown"">Sistema <span class=""caret""></span></button>"
	macro = macro&"	  <ul class=""dropdown-menu"">"
	strSis = "[Data.DDMMAAAA]|^[Data.Extenso]|^[Sistema.Hora]"
	splSis = split(strSis, "|^")
	for sik=0 to ubound(splSis)
		macro = macro&"		  <li><a href=""javascript:macroJS('"&editor&"', '"&splSis(sik)&"')"">"&splSis(sik)&"</a></li>"
	next
	macro = macro&"	  </ul>"
	macro = macro&"	</div>"
	macro = macro&"</div>"
	macro = macro&"</div>"
	macro = macro&"<script>function macroJS(editor, tag){ $('#'+editor).val( $('#'+editor).val()+tag ) }</script>"
end function

function replaceTags(valor, PacienteID, UserID, UnidadeID)
	valor = trim(valor&" ")
	if instr(valor, "[Paciente.")>0 then
			set pac = db.execute("select p.*, ec.EstadoCivil, s.NomeSexo as Sexo, g.GrauInstrucao, o.Origem, c.NomeConvenio from pacientes as p left join estadocivil as ec on ec.id=p.EstadoCivil left join sexo as s on s.id=p.Sexo left join grauinstrucao as g on g.id=p.GrauInstrucao left join origens as o on o.id=p.Origem LEFT JOIN convenios c on c.id=p.ConvenioID1 where p.id="&PacienteID)
		set rec = db.execute("select * from cliniccentral.sys_resourcesfields where resourceID=1")
		while not rec.eof
			Coluna = rec("columnName")
			Val = pac(""&Coluna&"")
			select case Coluna
				case "NomePaciente"
					Tag = "Nome"
				case "CorPele"
					Tag = "Cor"
					set cor = db.execute("select * from corpele where id="&pac("CorPele"))
					if not cor.eof then
						val = cor("NomeCorPele")
					else
						val = ""
					end if
				case else
					Tag = Coluna
			end select
			val = trim(val&" ")
			valor = replace(valor, "[Paciente."&Tag&"]", Val)
		rec.movenext
		wend
		rec.close
		set rec=nothing

		valor = replace(valor, "[Paciente.Idade]", idade(pac("Nascimento")))
		valor = replace(valor, "[Paciente.Prontuario]", pac("id"))
		valor = replace(valor, "[Paciente.Convenio]", trim(pac("NomeConvenio")&" ") )
		valor = replace(valor, "[Paciente.Matricula]", trim(pac("Matricula1")&" ") )
		valor = replace(valor, "[Paciente.Validade]", trim(pac("Validade1")&" ") )
	end if
	if instr(valor, "[Profissional.")>0 then
		set user = db.execute("select * from sys_users where id="&session("User"))
		if not user.EOF then
			if lcase(user("Table"))="profissionais" then
				set pro = db.execute("select * from profissionais where id="&user("idInTable"))
				if not pro.EOF then
					set Trat = db.execute("select * from tratamento where id="&pro("TratamentoID"))
					if not Trat.eof then
						Tratamento = trat("Tratamento")
					end if
					NomeProfissional = Tratamento&" "&pro("NomeProfissional")
					valor = replace(valor, "[Profissional.Nome]", NomeProfissional)
					set codigoConselho = db.execute("select * from conselhosprofissionais where id = '"&pro("Conselho")&"'")
					if not codigoConselho.eof then
						DocumentoProfissional = codigoConselho("codigo")&": "&pro("DocumentoConselho")&"-"&pro("UFConselho")
						valor = replace(valor, "[Profissional.Documento]", DocumentoProfissional)
					end if
				end if
			end if
		end if
	end if
	valor = replace(valor, "[Data.DDMMAAAA]", date())
	valor = replace(valor, "[Data.Extenso]", formatdatetime(date(),1) )
	valor = replace(valor, "[Sistema.Hora]", time())
	if instr(valor, "[Unidade.")>0 then
		if UnidadeID=0 then
			sql = "select *, NomeEmpresa Nome from empresa"
		else
			sql = "select *, unitName Nome from sys_financialcompanyunits where id = '"&UnidadeID&"'"
		end if
		camposASubs = "Nome, Endereco, Bairro, Cidade, Estado, Tel1, Cel1, Email1, CNPJ, CNES"
		correSubs = split(camposASubs, ", ")
		set registro = db.execute(sql)
		for corre=0 to ubound(correSubs)
			valor = replace(valor, "[Unidade."&correSubs(corre)&"]", registro(""&correSubs(corre)&"") )
		next
	end if

'		set cli = db.execute("select * from sys_financialcompanyunits order by id")
'		if not cli.eof then
'			'*****************>>>>>>>>>> depois colocar um select pra mudar a unidade
'			EnderecoClinica = cli("Endereco")&", "&cli("Numero")&" "&cli("Complemento")
'			CidadeClinica = cli("Cidade")
'			EstadoClinica = cli("Estado")
'			Tel1Clinica = cli("Tel1")
'			Tel2Clinica = cli("Tel2")
'		end if
		
	replaceTags = valor
end function
%>