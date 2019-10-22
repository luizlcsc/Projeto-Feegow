<%
Session.Timeout=600
session.LCID=1046
'ConnString = "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&session("Banco")&";uid=root;pwd=pipoca453;"
ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database="&session("Banco")&";uid=root;pwd=pipoca453;"
Set db = Server.CreateObject("ADODB.Connection")
db.Open ConnString

function permissoesPadrao()
'	permissoesPadrao = "chatI, contatosV, contatosI, contatosA, contatosX, sys_financialcurrentaccountsV, sys_financialcurrentaccountsI, sys_financialcurrentaccountsA, sys_financialcurrentaccountsX, formasrectoV, formasrectoI, formasrectoA, formasrectoX, origensV, origensI, origensA, origensX, contasapagarV, contasapagarI, contasapagarA, contasapagarX, contasareceberV, contasareceberI, contasareceberA, contasareceberX, contratadoexternoV, contratadoexternoI, contratadoexternoA, contratadoexternoX, fornecedoresV, fornecedoresI, fornecedoresA, fornecedoresX, funcionariosV, funcionariosI, funcionariosA, funcionariosX, locaisgruposV, locaisgruposI, locaisgruposA, locaisgruposX, lancamentosV, lancamentosI, lancamentosA, lancamentosX, locaisV, locaisI, locaisA, locaisX, movementV, movementI, movementA, movementX, orcamentosV, orcamentosI, orcamentosA, orcamentosX, pacotesV, pacotesI, pacotesA, pacotesX, procedimentosV, procedimentosI, procedimentosA, procedimentosX, profissionalexternoV, profissionalexternoI, profissionalexternoA, profissionalexternoX, tabelasV, tabelasI, tabelasA, tabelasX, sys_financialexpensetypeV, sys_financialexpensetypeI, sys_financialexpensetypeA, sys_financialexpensetypeX, sys_financialincometypeV, sys_financialincometypeI, sys_financialincometypeA, sys_financialincometypeX, sys_financialcompanyunitsV, sys_financialcompanyunitsI, sys_financialcompanyunitsA, sys_financialcompanyunitsX, buiformsV, buiformsI, buiformsA, buiformsX, chamadaporvozA, configconfirmacaoA, configrateioV, configrateioI, configrateioA, configrateioX, emailsV, emailsI, emailsA, emailsX, configimpressosV, configimpressosA, produtoscategoriasV, produtoscategoriasI, produtoscategoriasA, produtoscategoriasX, produtosfabricantesV, produtosfabricantesI, produtosfabricantesA, produtosfabricantesX, lctestoqueV, lctestoqueI, lctestoqueA, lctestoqueX, produtoslocalizacoesV, produtoslocalizacoesI, produtoslocalizacoesA, produtoslocalizacoesX, produtosV, produtosI, produtosA, produtosX, conveniosV, conveniosI, conveniosA, conveniosX, faturasV, guiasV, guiasI, guiasA, guiasX, conveniosplanosV, conveniosplanosI, conveniosplanosA, conveniosplanosX, repassesV, repassesI, repassesA, repassesX, formsaeV, formsaeI, formsaeA, arquivosV, arquivosI, arquivosA, arquivosX, atestadosV, atestadosI, atestadosA, atestadosX, pacientesV, pacientesI, pacientesA, pacientesX, historicopacienteV, contapacV, contapacI, contapacX, areceberpacienteV, areceberpacienteI, areceberpacienteA, areceberpacienteX, diagnosticosV, diagnosticosI, diagnosticosA, diagnosticosX, envioemailsI, imagensV, imagensI, imagensA, imagensX, formslV, formslI, formslA, pedidosexamesV, pedidosexamesI, pedidosexamesX, prescricoesV, prescricoesI, prescricoesA, prescricoesX, recibosV, recibosI, recibosA, recibosX, agendaV, agendaI, agendaA, agendaX, horariosV, horariosA, contaprofV, contaprofI, contaprofX, profissionaisV, profissionaisI, profissionaisA, profissionaisX, relatoriosestoqueV, relatoriosfinanceiroV, relatoriospacienteV, chamadatxtV, chamadavozV, senhapA, usuariosI, usuariosA, usuariosX, bloqueioagendaV, bloqueioagendaA, bloqueioagendaI, bloqueioagendaX, ageoutunidadesV, ageoutunidadesA, ageoutunidadesI, ageoutunidadesX, relatoriosfaturamentoV, relatoriosfaturamentoV, relatoriosagendaV"
	permissoesPadrao = "|ageoutunidadesV|, |ageoutunidadesI|, |ageoutunidadesA|, |ageoutunidadesX|, |agendaV|, |agendaI|, |agendaA|, |agendaX|, |bloqueioagendaV|, |bloqueioagendaI|, |bloqueioagendaA|, |bloqueioagendaX|, |horariosV|, |horariosA|, |historicopacienteV|, |chatI|, |contatosV|, |contatosI|, |contatosA|, |contatosX|, |sys_financialcurrentaccountsV|, |sys_financialcurrentaccountsI|, |sys_financialcurrentaccountsA|, |sys_financialcurrentaccountsX|, |formasrectoV|, |formasrectoI|, |formasrectoA|, |formasrectoX|, |origensV|, |origensI|, |origensA|, |origensX|, |contasapagarV|, |contasapagarI|, |contasapagarA|, |contasapagarX|, |contasareceberV|, |contasareceberI|, |contasareceberA|, |contasareceberX|, |contratadoexternoV|, |contratadoexternoI|, |contratadoexternoA|, |contratadoexternoX|, |fornecedoresV|, |fornecedoresI|, |fornecedoresA|, |fornecedoresX|, |funcionariosV|, |funcionariosI|, |funcionariosA|, |funcionariosX|, |locaisgruposV|, |locaisgruposI|, |locaisgruposA|, |locaisgruposX|, |lancamentosV|, |lancamentosI|, |lancamentosA|, |lancamentosX|, |locaisV|, |locaisI|, |locaisA|, |locaisX|, |movementV|, |movementI|, |movementA|, |movementX|, |orcamentosV|, |orcamentosI|, |orcamentosA|, |orcamentosX|, |pacotesV|, |pacotesI|, |pacotesA|, |pacotesX|, |procedimentosV|, |procedimentosI|, |procedimentosA|, |procedimentosX|, |profissionalexternoV|, |profissionalexternoI|, |profissionalexternoA|, |profissionalexternoX|, |tabelasV|, |tabelasI|, |tabelasA|, |tabelasX|, |sys_financialexpensetypeV|, |sys_financialexpensetypeI|, |sys_financialexpensetypeA|, |sys_financialexpensetypeX|, |sys_financialincometypeV|, |sys_financialincometypeI|, |sys_financialincometypeA|, |sys_financialincometypeX|, |sys_financialcompanyunitsV|, |sys_financialcompanyunitsI|, |sys_financialcompanyunitsA|, |sys_financialcompanyunitsX|, |buiformsV|, |buiformsI|, |buiformsA|, |buiformsX|, |chamadaporvozA|, |configconfirmacaoA|, |configrateioV|, |configrateioI|, |configrateioA|, |configrateioX|, |emailsV|, |emailsI|, |emailsA|, |emailsX|, |configimpressosV|, |configimpressosA|, |produtoscategoriasV|, |produtoscategoriasI|, |produtoscategoriasA|, |produtoscategoriasX|, |produtosfabricantesV|, |produtosfabricantesI|, |produtosfabricantesA|, |produtosfabricantesX|, |lctestoqueV|, |lctestoqueI|, |lctestoqueA|, |lctestoqueX|, |produtoslocalizacoesV|, |produtoslocalizacoesI|, |produtoslocalizacoesA|, |produtoslocalizacoesX|, |produtosV|, |produtosI|, |produtosA|, |produtosX|, |conveniosV|, |conveniosI|, |conveniosA|, |conveniosX|, |faturasV|, |guiasV|, |guiasI|, |guiasA|, |guiasX|, |conveniosplanosV|, |conveniosplanosI|, |conveniosplanosA|, |conveniosplanosX|, |repassesV|, |repassesI|, |repassesA|, |repassesX|, |formsaeV|, |formsaeI|, |formsaeA|, |arquivosV|, |arquivosI|, |arquivosA|, |arquivosX|, |atestadosV|, |atestadosI|, |atestadosA|, |atestadosX|, |pacientesV|, |pacientesI|, |pacientesA|, |pacientesX|, |contapacV|, |contapacI|, |contapacX|, |areceberpacienteV|, |areceberpacienteI|, |areceberpacienteA|, |areceberpacienteX|, |diagnosticosV|, |diagnosticosI|, |diagnosticosA|, |diagnosticosX|, |envioemailsI|, |imagensV|, |imagensI|, |imagensA|, |imagensX|, |formslV|, |formslI|, |formslA|, |pedidosexamesV|, |pedidosexamesI|, |pedidosexamesX|, |prescricoesV|, |prescricoesI|, |prescricoesA|, |prescricoesX|, |recibosV|, |recibosI|, |recibosA|, |recibosX|, |contaprofV|, |contaprofI|, |contaprofX|, |profissionaisV|, |profissionaisI|, |profissionaisA|, |profissionaisX|, |relatoriosagendaV|, |relatoriosestoqueV|, |relatoriosfaturamentoV|, |relatoriosfinanceiroV|, |relatoriospacienteV|, |chamadatxtV|, |chamadavozV|, |senhapA|, |usuariosI|, |usuariosA|, |usuariosX|"
end function

function centralSMS(checado, DataAgendamento, HoraAgendamento, AgendamentoID)
	LicencaID = replace(session("Banco"), "clinic", "")
	dbc.execute("delete from smsfila where LicencaID="&LicencaID&" and AgendamentoID="&AgendamentoID)
	if checado="S" then
		sql = "select * from sys_smsemail"
		set reg = db.execute(sql)
		if reg.eof then
			txtPadrao = "[NomePaciente], não se esqueça de sua consulta com [NomeProfissional] às [HoraAgendamento] do dia [DataAgendamento]."
			db_execute("insert into sys_smsemail (AtivoEmail, TextoEmail, ConfirmarPorEmail, TempoAntesEmail, AtivoSMS, TextoSMS, ConfirmarPorSMS, TempoAntesSMS, HAntesEmail, HAntesSMS) values ('on', '"&txtPadrao&"', 'S', '02:00:00', 'on', '"&txtPadrao&"', 'S', '02:00:00', 24, 24)")
			set reg = db.execute(sql)
		end if

		if cdate(DataAgendamento&" "&HoraAgendamento)>=cdate( dateadd( "h", 1, now() ) ) then
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
				set Trat = db.execute("select * from tratamento where id like '"&pro("TratamentoID")&"'")
				if not Trat.eof then
					Tratamento = trat("Tratamento")
				end if
				NomeProfissional = Tratamento&" "&pro("NomeProfissional")
			end if
			TratamentoProfissional = ""

			if age("MensagemDiferenciada")="S" and not isnull(age("MensagemDiferenciada")) then
				Mensagem = age("TextoSMS")
				Enviar = "S"
			elseif age("MensagemDiferenciada")="D" and not isnull(age("MensagemDiferenciada")) then
				Mensagem = ""
				Enviar = "N"
			else
				Mensagem = reg("TextoSMS")
				Enviar = "S"
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
'''			DataHoraEnvio = datediff("n", cdate(hour(reg("TempoAntesSMS"))&":"&minute(reg("TempoAntesSMS"))&":"&minute(reg("TempoAntesSMS"))), "00:00:00")
'			response.Write("|"&cdate()&"|")
			DataHoraEnvio = reg("HAntesSMS")*(-1)
'			response.Write("alert('"&DataHoraEnvio&"');")
			DataHoraEnvio = dateadd("h", DataHoraEnvio, DataAgendamento&" "&HoraAgendamento)
			
			
			UnidadeID = 0
			set pUnidade = db.execute("select u.id from locais l left join sys_financialcompanyunits u on u.id=l.UnidadeID where l.id like '"&age("LocalID")&"'")
			if not pUnidade.eof then
				if not isnull(pUnidade("id")) then
					UnidadeID = pUnidade("id")
				end if
			end if
			Mensagem = replaceTags(Mensagem, age("PacienteID"), session("UserID"), UnidadeID)
			'response.Write("insert into smsfila (LicencaID, DataHora, AgendamentoID, Mensagem) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"')")
			if len(pac("Cel1"))>5 and Enviar="S" then
				dbc.execute("insert into smsfila (LicencaID, DataHora, AgendamentoID, Mensagem, Celular) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"', '55"&replace(replace(replace(replace(pac("Cel1"), "(", ""), ")", ""), "-", ""), " ", "")&"')")
			end if
			if len(pac("Cel2"))>5 and Enviar="S" then
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
			db_execute("insert into sys_smsemail (AtivoEmail, TextoEmail, ConfirmarPorEmail, TempoAntesEmail, AtivoSMS, TextoSMS, ConfirmarPorSMS, TempoAntesSMS, HAntesEmail, HAntesSMS) values ('on', '"&txtPadrao&"', 'S', '02:00:00', 'on', '"&txtPadrao&"', 'S', '02:00:00', 24, 24)")
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
				set Trat = db.execute("select * from tratamento where id like '"&pro("TratamentoID")&"'")
				if not Trat.eof then
					Tratamento = trat("Tratamento")
				end if
				NomeProfissional = Tratamento&" "&pro("NomeProfissional")
			end if
			TratamentoProfissional = ""
			
			if age("MensagemDiferenciada")="S" and not isnull(age("MensagemDiferenciada")) then
				Mensagem = age("TextoEmail")
				Enviar = "S"
			elseif age("MensagemDiferenciada")="D" and not isnull(age("MensagemDiferenciada")) then
				Mensagem = ""
				Enviar = "N"
			else
				Mensagem = reg("TextoEmail")
				Enviar = "S"
			end if
			Mensagem = replace(Mensagem, "[NomePaciente]", NomePaciente)
			Mensagem = replace(Mensagem, "[TratamentoProfissional]", "")
			Mensagem = replace(Mensagem, "[NomeProfissional]", NomeProfissional)
			Mensagem = replace(Mensagem, "[HoraAgendamento]", cdate( hour(age("Hora"))&":"&minute(age("Hora"))&":"&second(age("Hora")) ) )
			Mensagem = replace(Mensagem, "[DataAgendamento]", age("Data"))
			if reg("ConfirmarPorEmail")="S" and not isnull(reg("ConfirmarPorEmail")) then
				Mensagem = Mensagem&" [Confirmacao.Mensagem]"
			end if
			'Mensagem = left(Mensagem, 160)
			
			'fecha dados para replace
'''			DataHoraEnvio = datediff("n", cdate(hour(reg("TempoAntesEmail"))&":"&minute(reg("TempoAntesEmail"))&":"&minute(reg("TempoAntesEmail"))), "00:00:00")
			DataHoraEnvio = reg("HAntesEmail")*(-1)
'			response.Write("|"&cdate()&"|")
			DataHoraEnvio = dateadd("h", DataHoraEnvio, DataAgendamento&" "&HoraAgendamento)
			
			UnidadeID = 0
			set pUnidade = db.execute("select u.id from locais l left join sys_financialcompanyunits u on u.id=l.UnidadeID where l.id like '"&age("LocalID")&"'")
			if not pUnidade.eof then
				if not isnull(pUnidade("id")) then
					UnidadeID = pUnidade("id")
				end if
			end if
			Mensagem = replaceTags(Mensagem, age("PacienteID"), session("UserID"), UnidadeID)
			'response.Write("insert into smsfila (LicencaID, DataHora, AgendamentoID, Mensagem) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"')")
			if len(pac("Email1"))>5 and Enviar="S" then
				dbc.execute("insert into emailsfila (LicencaID, DataHora, AgendamentoID, Mensagem, Titulo, Email) values ("&LicencaID&", "&myDateTime(DataHoraEnvio)&", "&AgendamentoID&", '"&rep(Mensagem)&"', 'Lembrete de Agendamento para "&age("Data")&"', '"&rep(pac("Email1"))&"')")
			end if
			if len(pac("Email2"))>5 and Enviar="S" then
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
	ref = replace(request.Form(Val), "'", "''")
end function

function req(Val)
	req = replace(request.QueryString(Val), "'", "''")
end function

function refNull(Val)
	if request.Form(Val)="" then
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
	if isDate(Val) and Val<>"" and not isnull(Val) then
'		response.Write("{"&year(Val)&"}")
        if year(Val)<1980 then
            Val = day(Val)&"/"&month(Val)&"/"&year(date())
        end if
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

function myDateJunto(Val)
	if isDate(Val) and Val<>"" then
		myDateJunto = zeroEsq(year(Val), 4) & zeroEsq(month(Val), 2) & zeroEsq(day(Val), 2)
	else
		myDateJunto = "00000000"
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
		<select class="select2-single" id="<%= id %>" name="<%= id %>" data-placeholder="Selecione"<%= others %>>
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
					set Associations = db.execute("select * from cliniccentral.sys_financialaccountsAssociation where id="&splAssociations(i))
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
		<select class="form-control select2-single" id="<%= id %>" name="<%= id %>"<%= others %>>
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
					set Associations = db.execute("select * from cliniccentral.sys_financialaccountsAssociation where id="&splAssociations(t))
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
	if isnull(id) or id=0 then
		id = 5
	end if
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
'		response.Write(strCA)
		set getTextValue = db.execute(strCA)
		if not getTextValue.EOF then
			textValue = getTextValue(""&resultado(2)&"")
		end if
	end if
	%><%if label<>"" then%><label><%=label%></label><br /><%end if%>

<input type="hidden" name="<%=name%>" id="<%=name%>" value="<%=value%>" />
<div class="input-group">
    <span for="search<%=name%>" class="input-group-addon">
        <i class="fa fa-search"></i>
    </span>
    <input type="text" placeholder="Digite..." class="form-control" id="search<%=name%>" name="search<%=name%>" value="<%=textValue%>" autocomplete="off" <%= othersToInput %>>
</div>
	</span>
	<div id="resultSelect<%=name%>" style="position:absolute; display:none; overflow:hidden; background-color:#f3f3f3; z-index:1000;">
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
	if isnumeric(userID) and not isnull(userID) and userID<>"" then
        if ccur(userID)>0 then
		    set goTable = db.execute("select Nome from cliniccentral.licencasusuarios where id="&userID)
		    if not goTable.EOF then
			    nameInTable = goTable("Nome")
		    else
			    nameInTable = " - "
		    end if
        else
		    userID = ccur(userID) * (-1)
		    set userMulti = db.execute("select Nome from cliniccentral.licencasusuariosmulti where id="&userID)
		    if userMulti.EOF then
			    nameInTable = "* Atendente"
		    else
			    nameInTable = "* "& userMulti("Nome")
		    end if
        end if
    end if
end function

function nameInAccount(conta)
	nameInAccount = ""
    if not isnull(conta) and instr(conta, "_") then
	    splf = split(conta, "_")
	    set contaf = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&splf(0))
	    if not contaf.eof then
		    set pcontaf = db.execute("select * from "&contaf("table")&" where id="&splf(1))
		    if not pcontaf.eof then
			    nameInAccount = pcontaf(""&contaf("column")&"")
		    end if
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

function numeros(txt)
	tamanho = len(txt)
	for inum = 1 to tamanho
	  if Isnumeric(mid(txt,inum,1)) then
		 numeros = numeros & mid(txt,inum,1)
	  end if
	next
end function

function quickField(fieldType, fieldName, label, width, fieldValue, sqlOrClass, columnToShow, additionalTags)
	if instr(Omitir, "|"&lcase(fieldName)&"|")>0 then
		OmitirCampo = " hidden"
	else
		OmitirCampo = ""
	end if
	if label<>"" then
		abreDivBoot = "<div class=""col-md-"&width&OmitirCampo&""" id=""qf"&lcase(fieldName)&""">"
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
		case "textSearch"
			response.Write(LabelFor)
			%>
			<input type="text" class="form-control <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>" value="<%=fieldValue%>"<%=additionalTags%> />
			<%
		case "password"
			response.Write(LabelFor)
			%>
			<input type="password" class="form-control <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>" value="<%=fieldValue%>"<%=additionalTags%> />
			<%
		case "number"
			response.Write(LabelFor)
			%>
			<input type="number" class="form-control <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>" value="<%=fieldValue%>"<%=additionalTags%> />
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
			if fieldType<>"email" and not isnull(fieldValue) and fieldValue<>"" then
				newFieldValue = numeros(fieldValue)
				if len(newFieldValue)<10 or len(newFieldValue)>11 then
					mask = ""
				else
					fieldValue = newFieldValue
				end if
			end if
			response.Write(LabelFor)
			%>
            <div class="input-group">
                <span class="input-group-addon">
                    <%
					if session("OtherCurrencies")="phone" then
						%>
                        <a href="callto:0<%=fieldValue%>"><i class="fa fa-<%= icone %> bigger-110"></i></a>
                        <%
					else
						%>
 	                   <i class="fa fa-<%= icone %> bigger-110"></i>
						<%
					end if
					%>
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
            <strong>R$</strong>
            </span>
            <input id="<%=fieldName%>" class="form-control input-mask-brl <%=sqlOrClass%>" type="text" style="text-align:right" name="<%=fieldName%>" value="<%=fieldValue%>"<%=additionalTags%>>
            </div>
			<%
		case "select"
			response.Write(LabelFor)
			if instr(additionalTags, "empty") then
				vazio = ""
			else
				vazio = "0"
			end if
			%>
            <select name="<%= fieldName %>" id="<%= fieldName %>" class="form-control select2-single width-80"<%=additionalTags%>>
            <%if instr(additionalTags, "semVazio")=0 then%>
            <option value="<%=vazio%>">Selecione</option>
            <%
			end if
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
		case "users"
			response.Write(LabelFor)
			%>
            <select name="<%= fieldName %>" class="<%=sqlOrClass%> form-control" id="<%= fieldName %>"<%=additionalTags%>>
            <option value="">Todos</option>
            <%
			set doSql = db.execute("(select u.id, p.NomeProfissional Nome from sys_users u left join profissionais p on p.id=u.idInTable WHERE `Table`='ProfissionaiS' AND NOT ISNULL(NomeProfissional) AND p.Ativo='on') UNION ALL (select u.id, f.NomeFuncionario from sys_users u left join funcionarios f on f.id=u.idInTable WHERE `Table`='Funcionarios' AND NOT ISNULL(NomeFuncionario) AND f.Ativo='on') ORDER BY Nome")
			while not doSql.EOF
				%><option value="<%=doSql("id")%>"<% If doSql("id")=fieldValue or cstr(doSql("id"))=fieldValue Then %> selected="selected"<% End If %>><%=doSql("Nome")%></option>
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
			if instr(additionalTags, "empty") then
				vazio = ""
			else
				vazio = "0"
			end if
			%>
            <select name="<%= fieldName %>" id="<%= fieldName %>" class="select2-single form-control"<%=additionalTags%>>
            <%if instr(additionalTags, "semVazio")=0 then%>
            <option value="<%=vazio%>">Selecione</option>
            <%
			end if
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
			<select multiple class="multisel tag-input-style" id="<%=fieldName%>" name="<%=fieldName%>"<%=additionalTags%>>
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
        case "selectCheck"
			response.Write(LabelFor)
            %>
            <div style="height:150px; overflow:scroll; overflow-x:hidden">
            <label><input class="ace" onClick="$('.<%=fieldName%>').prop('checked', $(this).prop('checked'))" type="checkbox" name="Checkall" value=""><span class="lbl"> Selecionar todos</span></label><br>
            <%
            set listItems = db.execute(sqlOrClass)
            while not listItems.eof
                %>
                <label><input class="<%= fieldName %> ace" type="checkbox" name="<%= fieldName %>" id="<%=fieldName & listItems("id")%>" value="|<%=listItems("id")%>|"<% if instr(fieldValue, "|"&listItems("id")&"|") then response.write(" checked ") end if %> /><span class="lbl"> <%=listItems(""&columnToShow&"")%></span></label><br>
                <%
            listItems.movenext
            wend
            listItems.close
            set listItems=nothing
            %>
            </div>
            <%
        case "selectRadio"
			response.Write(LabelFor)
            set listItems = db.execute(sqlOrClass)
            while not listItems.eof
                %>
                <span class="radio-custom radio-primary"><input class="<%= fieldName %>" type="radio" name="<%= fieldName %>" id="<%=fieldName & listItems("id")%>" value="<%=listItems("id")%>"<% if cstr(fieldValue&"")=cstr(listItems("id")) then response.write(" checked ") end if %> /><label for="<%=fieldName & listItems("id")%>"> <%=listItems(""&columnToShow&"")%></label></span><br>
                <%
            listItems.movenext
            wend
            listItems.close
            set listItems=nothing
		case "cor"
			response.Write(LabelFor)
			%>
            <div class="admin-form">
                <label class="field sfcolor">
                    <input type="text" name="<%= fieldName %>" id="<%= fieldName %>" class="gui-input" placeholder="Selecione" value="<%=fieldValue %>">
                </label>
            </div>
            <script type="text/javascript">
                $(document).ready(function(){
                    var cPicker1 = $("#<%=fieldName%>");

                    var cContainer1 = cPicker1.parents('.sfcolor').parent();

                    $("#<%=fieldName%>").spectrum({
                        preferredFormat: "hex",
                        color: '<%=fieldValue%>',
                        appendTo: cContainer1,
                        containerClassName: 'sp-left'
                    });


                    $("#<%=fieldName%>").show();
                });

            </script>
            <%
		case "datepicker"
			response.Write(LabelFor)
			%>
            <div class="input-group">
            <input id="<%= fieldName %>" class="form-control date-picker <%=sqlOrClass%>" type="text" value="<%= fieldValue %>" name="<%= fieldName %>" data-date-format="dd/mm/yyyy"<%=additionalTags%>>
            <span class="input-group-addon<%if instr(sqlOrClass, "input-sm")>0 then%> input-sm<%end if%>">
            <i class="fa fa-calendar bigger-110"></i>
            </span>
            </div>
			<%
		case "timepicker"
			response.Write(LabelFor)
			if isdate(fieldValue) then
				fieldValue = formatdatetime(fieldValue, 4)
			else
				fieldValue = "00:00"
			end if
			%>
            <div class="input-group bootstrap-timepicker">
                <input id="<%=fieldName%>" name="<%=fieldName%>" value="<%=fieldValue%>" type="text" class="form-control input-mask-l-time" />
                <span class="input-group-addon">
                    <i class="fa fa-clock-o bigger-110"></i>
                </span>
            </div>
			<%
		case "simpleCheckbox"
			%>
			<div class="checkbox-custom checkbox-primary">
                <input type="checkbox" class="ace <%=sqlOrClass%>" name="<%= fieldName %>" id="<%= fieldName %>" value="S"<%if fieldValue="S" then response.write("checked") end if %> /> <label class="checkbox" for="<%= fieldName %>"> <%= label %></label>
			</div>
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
				<select name="<%=fieldName%>" id="<%=fieldName%>" class="form-control<%=sqlOrClass%>" <%=additionalTags%>>
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
		case "empresaMulti"
			'response.Write("["&session("Unidades")&"]")
            set filiais = db.execute("select * from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 order by UnitName")
			if filiais.eof then
				%>
				<input type="hidden" name="<%=fieldName%>" id="<%=fieldName%>" value="0" />
				<%
			else
				response.Write(LabelFor)
				%>
				<select name="<%=fieldName%>" id="<%=fieldName%>" multiple class="form-control multisel <%=sqlOrClass%>">
				<%
				set empresa = db.execute("select * from empresa")
				if not empresa.eof then
					if not isnull(empresa("NomeEmpresa")) and instr(session("Unidades"), "|0|") then
						response.write("<option value=""0""")
                        if instr(fieldValue, "|0|") then
                            response.write(" selected ")
                        end if
                        response.Write(">"&empresa("NomeEmpresa")&"</option>")
					end if
				end if
				while not filiais.eof
					if instr(fieldValue, "|"&filiais("id")&"|") then
						response.write("<option value='"&filiais("id")&"'")
						If instr(fieldValue, "|"&filiais("id")&"|") Then
							response.write(" selected='selected' ")
						end if
					    response.write(">"&filiais("UnitName") &"</option>")
					end if
					
				filiais.movenext
				wend
				filiais.close
				set filiais=nothing
				%>
				</select>
			    <%
			end if
		case "empresaMultiIgnore"
			'response.Write("["&session("Unidades")&"]")
            set filiais = db.execute("select * from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 order by UnitName")
			if filiais.eof then
				%>
				<input type="hidden" name="<%=fieldName%>" id="<%=fieldName%>" value="0" />
				<%
			else
				response.Write(LabelFor)
				%>
				<select name="<%=fieldName%>" id="<%=fieldName%>" multiple class="form-control chosen-select <%=sqlOrClass%>">
				<%
				set empresa = db.execute("select * from empresa")
				if not empresa.eof then
					if not isnull(empresa("NomeEmpresa")) then
						response.write("<option value=""|0|""")
                        if instr(fieldValue, "|0|") then
                            response.write(" selected ")
                        end if
                        response.Write(">"&empresa("NomeEmpresa")&"</option>")
					end if
				end if
				response.write("<option disabled=""disabled"" style=""border-bottom:1px dotted #CCC; border-top:1px dotted #CCC;""></option>")
				while not filiais.eof
						response.write("<option value='|"&filiais("id")&"|'")
						If instr(fieldValue, "|"&filiais("id")&"|") Then
							response.write(" selected='selected' ")
						end if
					    response.write(">"&filiais("UnitName") &"</option>")
					
				filiais.movenext
				wend
				filiais.close
				set filiais=nothing
				%>
				</select>
			    <%
			end if
		case "empresaMultiSelect"
			'response.Write("["&session("Unidades")&"]")
            set filiais = db.execute("select * from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 order by UnitName")
			if filiais.eof then
				%>
				<input type="hidden" name="<%=fieldName%>" id="<%=fieldName%>" value="" />
				<%
			else
				response.Write(LabelFor)
				%>
				<select name="<%=fieldName%>" id="<%=fieldName%>" multiple class="form-control chosen-select <%=sqlOrClass%>">
				<%
				set empresa = db.execute("select * from empresa")
				if not empresa.eof then
					if not isnull(empresa("NomeEmpresa")) and instr(session("Unidades"), "|0|") then
						%><option value="|0|"<%if instr(fieldValue, "|0|") then%> selected<%end if%>><%=empresa("NomeEmpresa")%></option>
						<%
					end if
				end if
				%><option disabled="disabled" style="border-bottom:1px dotted #CCC; border-top:1px dotted #CCC;"></option><%
				while not filiais.eof
					if instr(session("Unidades"), "|"&filiais("id")&"|") then
						%><option value="|<%=filiais("id")%>|"<%
						If instr(fieldValue, "|"&filiais("id")&"|") Then
							%> selected="selected"<%
						end if
					end if
					%>><%=filiais("UnitName") %></option>
					<%
				filiais.movenext
				wend
				filiais.close
				set filiais=nothing
				%>
				</select>
			    <%
			end if
		case "empresaMultiCheck"
			'response.Write("["&session("Unidades")&"]")
            set filiais = db.execute("select * from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 order by UnitName")
			if filiais.eof then
				%>
				<input type="hidden" name="<%=fieldName%>" id="<%=fieldName%>" value="|0|" />
				<%
			else
				response.Write(LabelFor)

				set empresa = db.execute("select * from empresa")
				if not empresa.eof then
					if not isnull(empresa("NomeEmpresa")) and instr(session("Unidades"), "|0|") then
						%><label><input class="ace" type="checkbox" name="<%=fieldName%>" value="|0|"<%if instr(fieldValue, "|0|") then%> checked<%end if%>><span class="lbl"> <%=empresa("NomeEmpresa")%></span></label><br>
						<%
					end if
				end if
				while not filiais.eof
					If instr(session("Unidades"), "|"&filiais("id")&"|") Then
						%>
						<label><input class="ace" type="checkbox" name="<%=fieldName%>" value="|<%=filiais("id")%>|"
						<%
						If instr(fieldValue, "|"&filiais("id")&"|") Then
							%> checked<%
						end if
						%>><span class="lbl"> <%=filiais("UnitName") %></span></label><br>
						<%
					end if
				filiais.movenext
				wend
				filiais.close
				set filiais=nothing
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
    if CD="" or isnull(CD) then
        CD = "D"
    end if
	if not isNull(PaymentMethodID) then
		response.Write("<img width=""18"" src=""assets/img/"&PaymentMethodID&CD&".png"" /> ")
		set pmd = db.execute("select PaymentMethod from sys_financialpaymentmethod where id="&PaymentMethodID)
		if not pmd.EOF then
			response.Write("<small>"& pmd("PaymentMethod") &" &raquo; </small>")
		end if
    end if
end function

function accountName(AccountAssociationID, AccountID)
    if not isnull(AccountAssociationID) and not isnull(AccountAssociationID) then
	    set getAssociation = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&AccountAssociationID)
	    if not getAssociation.eof then
		    set getAccount = db.execute("select `"&getAssociation("column")&"` from `"&getAssociation("table")&"` where id="&AccountID)
		    if not getAccount.EOF then
			    accountName = getAccount(""&getAssociation("column")&"")
		    end if
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
			'if getMovement("Currency")<>session("DefaultCurrency") then
			'	Value = Value / Rate
			'end if
			accountBalance = accountBalance+Value
		else
			'if getMovement("Currency")<>session("DefaultCurrency") then
			'	Value = Value / Rate
			'end if
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
			accountBalance = "<span class=""badge badge-danger arrowed-in badge-sm""><i class='icon-thumbs-down bigger-120'></i> Saldo negativo de R$&nbsp;"&formatnumber(accountBalance,2)&"</span>"
		elseif accountBalance>0 then
			accountBalance = "<span class=""badge badge-success arrowed-in badge-sm""><i class='icon-thumbs-up bigger-120'></i> Saldo positivo de R$&nbsp;"&formatnumber(accountBalance,2)&"</span>"
		else
			accountBalance = "<span class=""badge badge-sm arrowed-in"">Saldo: R$&nbsp;"&formatnumber(accountBalance,2)&"</span>"
		end if
	end if
	
end function

function getCD(Credit, Debit)
'	if 
end function



function selectInsert(label, name, value, resource, showColumn, othersToSelect, othersToInput, campoSuperior)
	if value<>"" and isnumeric(value) then
		if ccur(value)<>0 then
			set getTextValue = db.execute("select id, "&showColumn&" from "&resource&" where id="&value)
			if not getTextValue.EOF then
				textValue = getTextValue(""&showColumn&"")
			end if
		end if
	end if

    if instr(othersToInput&"", "placeholder='")>0 then
        splPH = split(othersToInput&"", "placeholder='")
        splPH2 = split(splPH(1), "'")
        placeholder = splPH2(0)
    end if
	%><%if label<>"" then%><label><%=label%></label><br /><%end if%>
    <select id="<%=name %>" name="<%=name %>" class="form-control" <%=othersToSelect %> <%'=othersToInput %> data-campoSuperior="<%=campoSuperior%>" data-resource="<%=resource %>" data-showColumn="<%=showColumn %>">
        <option value="<%=value %>" selected="selected"><%=textValue %></option>
    </select>


	<script type="text/javascript">
	        s2aj("<%=name%>", '<%=resource%>', '<%=showColumn%>', '<%=campoSuperior%>', '<%=placeholder%>');

	        $("#<%=name%>").change(function(){
	            //console.log( $("#<%=name%>").html() );
	            if( $(this).val()=="-1" ){

	                $.post("sii.asp", { 
	                    v:$("#<%=name%> option[data-select2-tag='true']:last").text(), 
	                    t:'<%=name%>',
	                    campoSuperior:$('#<%=campoSuperior%>').val(),
	                    showColumn:$(this).attr("data-showColumn"),
	                    resource:$(this).attr("data-resource")
	                }, function (data) {
	                    eval( data );
	                });



	                console.log( $("#<%=name%> option[data-select2-tag='true']:last").text() );
	            }
	          //  $(this).select2("destroy");
	        });



	    //        $(this).html("<option value='56'>lalala</option>");
	    //        s2aj("CategoriaID", 'produtoscategorias', 'NomeCategoria');
	    //if( $(this).val()==null ){
	    //    console.log( $(this) );
	    //}
	    //   console.log( $(this).val() );


    </script>
	<%
end function




function selectInsertOLD(label, name, value, resource, showColumn, othersToSelect, othersToInput, campoSuperior)
	'1. o padrão do insert é o primeiro
	'2. o valor do campo pode ser do tipo conta (quando tem mais de 1, ex.: 1_232) ou id (ex.: 4)
	'3. só preenche se quiser
	if value<>"" and isnumeric(value) then
		if ccur(value)<>0 then
			set getTextValue = db.execute("select id, "&showColumn&" from "&resource&" where id="&value)
			if not getTextValue.EOF then
				textValue = getTextValue(""&showColumn&"")
			end if
		end if
	end if
    if instr(othersToInput, "placeholder")=0 then
        ph = " placeholder=""Digite..."""
    end if
    
	%><%if label<>"" then%><label><%=label%></label><br /><%end if%>
	<input type="hidden" name="<%=name%>" id="<%=name%>" value="<%=value%>" />
    <span class="input-icon input-icon-right width-100">
		<input onClick="si<%=replace(name, "-", "_")%>()" type="text" <%=ph %> class="form-control" id="search<%=name%>" name="search<%=name%>" value="<%=textValue%>" autocomplete="off" <%= othersToInput %>>
		<i class="fa fa-search" id="spin<%=name%>"></i>
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
			$("#spin<%=name%>").removeClass("fa-spinner fa-spin");
			$("#spin<%=name%>").addClass("fa-search");
        });
    }
    
    var typingTimer<%=replace(name, "-", "_")%>;
    $(document).ready(function(){
      $("#search<%=name%>").keyup(function(e){
		if(e.keyCode!=40){
			$("#<%=name%>").val("0");
	        si<%=replace(name, "-", "_")%>();
		}
      });
      $("#search<%=name%>").focusout(function(){
          setTimeout(function(){
            $("#resultSelect<%=name%>").css("display", "none");
          }, 200);
		  if( $("#<%=name%>").val()=="0" ){
			  $(this).val("");
		  }
		  if( $("#search<%=name%>").val()=="" ){
			  $("#<%=name%>").val("0");
		  }
      });
      $("#search<%=name%>").click(function(){
        this.select();
      });
    });
	    //$(event.target).attr('class')!!!!!
    
    function si<%=replace(name, "-", "_")%>(){
//        if($("#search<%=name%>").val().length>=0){
            $("#resultSelect<%=name%>").fadeIn();
            $("#resultSelect<%=name%>").html("buscando...");
			$("#spin<%=name%>").removeClass("fa-search");
			$("#spin<%=name%>").addClass("fa-spinner fa-spin");
            clearTimeout(typingTimer<%=replace(name, "-", "_")%>);
            if ($("#search<%=name%>").val) {
                typingTimer<%=replace(name, "-", "_")%> = setTimeout(f_<%=replace(name, "-", "_")%>, 400);
            }
//        }else{
//            $("#resultSelect<%=name%>").css("display", "none");
//            $("#<%=name%>").val("0");
//        }
    }
    </script>
	<%
end function






function selectProc(label, name, value, thisField, TabelaField, CodigoField, DescricaoField, othersToInput)
	'1. o padrão do insert é o primeiro
	'2. o valor do campo pode ser do tipo conta (quando tem mais de 1, ex.: 1_232) ou id (ex.: 4)
	'3. só preenche se quiser
	%><%if label<>"" then%><label><%=label%></label><br /><%end if%>
    <span class="input-icon input-icon-right width-100">
		<input type="text" class="form-control" id="<%=name%>" name="<%=name%>" value="<%=value%>" autocomplete="off" <%= othersToInput %>>
		<i class="fa fa-search"></i>
	</span>
	<div id="resultSelect<%=name%>" style="position:absolute; display:none; overflow:hidden; background-color:#f3f3f3; width:400px; z-index:1000;">
    	buscando...
    </div>
<script language="javascript">
function f_<%=replace(name, "-", "_")%>(){
	$.post("selectProc.asp",{
		   selectID:'<%=name%>',
		   typed:$("#<%=name%>").val(),
		   resource:'<%=resource%>',
		   thisField:'<%=thisField%>',
		   Tabela: $('#<%=TabelaField%>').val(),
		   CodigoField:'<%=CodigoField%>',
		   DescricaoField:'<%=DescricaoField%>'
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



function selectList(label, name, value, resource, showColumn, othersToSelect, othersToInput, campoSuperior)
	'1. o padrão do insert é o primeiro
	'2. o valor do campo pode ser do tipo conta (quando tem mais de 1, ex.: 1_232) ou id (ex.: 4)
	'3. só preenche se quiser
	%><%if label<>"" then%><label><%=label%></label><br /><%end if%>
    <div class="input-group">
        <span for="firstname" class="input-group-addon">
    		<i class="fa fa-search"></i>
        </span>
		<input type="text" class="form-control" id="<%=name%>" name="<%=name%>" value="<%=value%>" autocomplete="off" <%= othersToInput %>>
	</div>
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
'Permissao = "|"&Permissao&"|"
'	set Pstr=db.execute("select id,Permissoes from sys_users where id="&session("User")&"")
'	if not Pstr.eof then
'	strP=Pstr("Permissoes")
		if inStr(session("Permissoes"),Permissao)>0 or session("Admin")=1 then
'		if inStr(strP,Permissao)>0 then
			Aut=1
		else
			Aut=0
		end if
'	end if
'Autorizado="Sim"
end function

function autForm(FormID, TipoAut, PreenchedorID)
	autForm = false
	set perm = db.execute("select * from buipermissoes where FormID="&FormID)
	if perm.eof then
		'if session("table")="profissionais" then
			autForm = true
		'end if
	else
		while not perm.eof
			if instr(perm("Permissoes"), TipoAut)>0 then
				if lcase(session("table"))="funcionarios" then
					if perm("Tipo")="F" and (instr(perm("Grupo"), "|"&session("idInTable")&"|")>0 or instr(perm("Grupo"), "|0|")>0) then
						autForm = true
					end if
				elseif lcase(session("table"))="profissionais" then
					if perm("Tipo")="P" and (instr(perm("Grupo"), "|"&session("idInTable")&"|")>0 or instr(perm("Grupo"), "|0|")>0) then
						autForm = true
					end if
					if perm("Tipo")="E" and instr(perm("Grupo"), "|0|")>0 then
						autForm = true
					end if
					if autForm=false and perm("Tipo")="E" then
						set esp = db.execute("select EspecialidadeID from profissionais where id="&session("idInTable")&" and not isnull(EspecialidadeID) and not EspecialidadeID=0")
						if not esp.eof then
							if instr(perm("Grupo"), "|"&esp("EspecialidadeID")&"|")>0 then
								autForm = true
							end if
						end if
					end if
				end if
			end if
		perm.movenext
		wend
		perm.close
		set perm=nothing
	end if
end function

function formSave(FormID, btnSaveID, AcaoSeguinte)
	%>
    $("#<%=FormID%>").submit(function() {
		$("#<%=btnSaveID%>").html('salvando');
		$("#<%=btnSaveID%>").attr('disabled', 'disabled');
        $.post("save.asp", $("#<%=FormID%>").serialize())
        .done(function(data) {
          $("#<%=btnSaveID%>").html('<i class="fa fa-save"></i> Salvar');
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
		if request.QueryString("Lancto")<>"" then
			strLancto = "&Lancto="&request.QueryString("Lancto")
		end if
        if req("Solicitantes")<>"" then
            strSolicitantes = "&Solicitantes="&req("Solicitantes")
        end if
		response.Redirect("?P="&tableName&"&I="&vie("id")&"&Pers="&request.QueryString("Pers") &strLancto & strSolicitantes)
	else
		set data = db.execute("select * from "&tableName&" where id="&id)
		if data.eof then
			response.Redirect("?P="&tableName&"&I=N&Pers="&request.QueryString("Pers"))
		end if
	end if
end function

function Subform(NomeTabela, Coluna, regPrin, FormID)
	%>
	<!--#include file="Subform.asp"-->
	<%
end function

function dominioRepasse(FormaID, ProfissionalID, ProcedimentoID, UnidadeID)
'        response.write(FormaID)
FormaID = replace(FormaID, "|", "")
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
				if instr(FormaID, "_") and instr(dom("Formas"), "|P|")>0 then
					queima = 0
				else
					queima = 1
				end if
			end if
		end if
		if instr(dom("Profissionais"), "|"&replace(ProfissionalID, "5_", "")&"|")>0 then
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

	'-> unidades
	macro = macro&"	<div class=""btn-group"">"
	macro = macro&"	  <button class=""btn dropdown-toggle btn-xs btn-info"" data-toggle=""dropdown"">Unidade <span class=""caret""></span></button>"
	macro = macro&"	  <ul class=""dropdown-menu"">"
	strUni = "Nome, Endereco, Bairro, Cidade, Estado, Tel1, Cel1, Email1, CNPJ, CNES"
	splUni = split(strUni, ", ")
	for unk=0 to ubound(splUni)
		macro = macro&"		  <li><a href=""javascript:macroJS('"&editor&"', '[Unidade."&splUni(unk)&"]')"">[Unidade."&splUni(unk)&"]</a></li>"
	next
	macro = macro&"	  </ul>"
	macro = macro&"	</div>"
	'<-- unidades

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
	if (isnumeric(PacienteID) and not isnull(PacienteID)) then
		if instr(valor, "[Paciente.")>0 then
            strPac = "select p.*, ec.EstadoCivil, s.NomeSexo as Sexo, g.GrauInstrucao, o.Origem, c.NomeConvenio from pacientes as p left join estadocivil as ec on ec.id=p.EstadoCivil left join sexo as s on s.id=p.Sexo left join grauinstrucao as g on g.id=p.GrauInstrucao left join origens as o on o.id=p.Origem LEFT JOIN convenios c on c.id=p.ConvenioID1 where p.id="&PacienteID
        '    response.Write( strPac )
			set pac = db.execute(strPac)
			set rec = db.execute("select * from cliniccentral.sys_resourcesfields where resourceID=1")
			while not rec.eof
				Coluna = rec("columnName")
				'response.Write("{"&Coluna&"}")
				Val = pac(""&Coluna&"")
				select case Coluna
					case "NomePaciente"
						Tag = "Nome"
					case "CorPele"
						Tag = "Cor"
						set cor = db.execute("select * from corpele where id like '"&pac("CorPele")&"'")
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
	else
		quebraConta = split(PacienteID, "_")
		Assoc = quebraConta(0)
		Conta = quebraConta(1)
		select case Assoc
			case "2"
				sql = "select *, NomeFornecedor Nome, RG Documento, CPF CPF_CNPJ from fornecedores where id="&Conta
			case "3"
				sql = "select *, NomePaciente Nome, CPF CPF_CNPJ from pacientes where id="&Conta
				idPaciente = Conta
			case "4"
				sql = "select *, NomeFuncionario Nome, RG Documento, CPF CPF_CNPJ from funcionarios where id="&Conta
			case "5"
				sql = "select *, NomeProfissional Nome, DocumentoProfissional Documento, CPF CPF_CNPJ from profissionais where id="&Conta
			case "6"
				sql = "select *, NomeConvenio Nome, '' Documento, Telefone Tel1, Email Email1, CNPJ CPF_CNPF, '' Cel1 from convenios where id="&Conta
		end select
		camposASubs = "Nome, Endereco, Bairro, Cidade, Estado, Tel1, Cel1, Email1, CPF_CNPJ, Documento"
		correSubs = split(camposASubs, ", ")
		set registro = db.execute(sql)
		for corre=0 to ubound(correSubs)
'			if session("banco")="clinic811" then
'				valor = replace(valor, trim("[Conta."&correSubs(corre)&"] "), "database" )
'			else
				valor = replace(valor, trim("[Conta."&correSubs(corre)&"] "), trim(registro(""&correSubs(corre)&"")&" ") )
'			end if
		next
	end if
	if instr(valor, "[Usuario.")>0 then
		valor = replace(valor, "[Usuario.Nome]", nameInTable(UserID))
	end if
	if instr(valor, "[Profissional.")>0 then
		set user = db.execute("select * from sys_users where id="&session("User"))
		if not user.EOF then
			if lcase(user("Table"))="profissionais" then
				set pro = db.execute("select * from profissionais where id="&user("idInTable"))
				if not pro.EOF then
					set Trat = db.execute("select * from tratamento where id="&treatvalzero(pro("TratamentoID")))
					if not Trat.eof then
						Tratamento = trat("Tratamento")
					end if
					NomeProfissional = Tratamento&" "&pro("NomeProfissional")
					valor = replace(valor, "[Profissional.Nome]", NomeProfissional)
					set codigoConselho = db.execute("select * from conselhosprofissionais where id like '"&pro("Conselho")&"'")
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
			sql = "select *, unitName Nome from sys_financialcompanyunits where id="&UnidadeID
		end if
		camposASubs = "Nome, Endereco, Numero, Complemento, Bairro, Cidade, Estado, Tel1, Cel1, Email1, CNPJ, CNES"
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
		
	if instr(valor, "[Conta.")>0 then
		valor = replace(valor, "[Conta.", "[Paciente.")
		valor = replaceTags(valor, idPaciente, UserID, UnidadeID)
	end if
	replaceTags = valor
end function

function HoraToID(val)
	if isdate(val) and val<>"" and isnull(val)=false then
		HoraToID = formatdatetime(val, 4)
		HoraToID = replace(HoraToID, ":", "")
	else
		HoraToID = ""
	end if
end function

function versaoAgenda()
	if session("banco")="clinic522" or session("banco")="clinic909" or session("banco")="clinic84" or session("banco")="clinic90" or session("banco")="clinic100" or session("banco")="clinic107" or session("banco")="clinic207" or session("banco")="clinic214" or session("banco")="clinic408" or session("banco")="clinic450" or session("banco")="clinic811" or session("banco")="clinic105" or session("banco")="clinic1124" or session("banco")="clinic1169" or session("banco")="clinic274" or session("banco")="clinic1224" or session("banco")="clinic1165" or session("banco")="clinic935" or session("banco")="clinic856" or session("banco")="clinic1289" or session("banco")="clinic1294" or session("banco")="clinic600" or session("banco")="clinic1208" or session("banco")="clinic1352" or session("banco")="clinic1444" or session("banco")="clinic672" or session("banco")="clinic1297" or session("banco")="clinic1399" or session("banco")="clinic1459" or 1=1 then
		versaoAgenda=1
	else
		versaoAgenda=0
	end if
end function

function calculaFator(GuiaID)
    set pConvGuia = db.execute("select c.segundoProcedimento, c.terceiroProcedimento, c.quartoProcedimento from convenios c where c.id like '"&ref("gConvenioID")&"'")
    if not pConvGuia.eof then
	    set contaItens = db.execute("select count(id) as total from tissprocedimentossadt where GuiaID="&GuiaID)
	    nItens = ccur(contaItens("total"))
	    if nItens=0 or isnull(nItens) then
        	calculaFator = 100
	    elseif nItens=1 then
			calculaFator = pConvGuia("segundoProcedimento")
		elseif nItens=2 then
			calculaFator = pConvGuia("terceiroProcedimento")
        else
			calculaFator = pConvGuia("quartoProcedimento")
		end if
        if isnull(calculaFator) then
            calculaFator=1
        else
            calculaFator=calculaFator/100
        end if
    else
        calculaFator = 1
    end if
end function

function newForm(modID, pacID)
	db_execute("insert into `buiformspreenchidos` (ModeloID, PacienteID, sysUser) values ("&modID&", "&pacID&", "&session("User")&")")
	set pult = db.execute("select id from `buiformspreenchidos` order by id desc limit 1")
	newForm = pult("id")
	db_execute("insert into `_"&modID&"` (id, PacienteID, sysUser) values ("&newform&", "&pacID&", "&session("User")&")")
	set valcampos = db.execute("select * from buicamposforms where FormID="&modID&" and TipoCampoID not in(7, 9, 10, 11, 13, 14) and not isnull(ValorPadrao)")
	while not valcampos.EOF
		PreValor = replaceTags(valcampos("ValorPadrao"), pacID, session("User"), session("UnidadeID"))
		PreValor = rep(PreValor)
		sql = "update `_"&modID&"` set `"&valcampos("id")&"`='"&PreValor&"' where id="&newForm
	'	response.Write(sql)
		db_execute(sql)
	valcampos.movenext
	wend
	valcampos.close
	set valcampos = nothing
end function

function dIcone(resource)
	select case lcase(resource)
		case "pacientes"
			dIcone = "user"
		case "profissionais"
			dIcone = "user-md"
		case "funcionarios"
			dIcone = "user"
		case "fornecedores"
			dIcone = "user"
		case "procedimentos"
			dIcone = "stethoscope"
		case "pacotes"
			dIcone = "stethoscope"
		case "convenios"
			dIcone = "credit-card"
		case "origens"
			dIcone = "list"
		case "buiforms"
			dIcone = "bar-chart"
		case "configimpressos"
			dIcone = "file"
		case "sys_financialcurrentaccounts"
			dIcone = "money"
		case "rateio"
			dIcone = "puzzle-piece"
		case "configconfirmacoes"
			dIcone = "mobile-phone"
		case "contatos"
			dIcone = "mobile-phone"
		case "produtos", "produtoskits"
			dIcone = "medkit"
		case "chamadaporvoz"
			dIcone = "volume-up"
		case "settings"
			dIcone = "hospital-o"
		case "formarecto"
			dIcone = "credit-card"
		case "feriados"
			dIcone = "road"
		case "outrasconfiguracoes"
			dIcone = "cogs"
		case "locaisgrupos"
			dIcone = "crosshairs"
		case "locais"
			dIcone = "map-marker"
        case "sys_financialinvoices"
            dIcone = "usd"
        case "equipamentos"
            dIcone = "laptop"
        case "sys_financialcompanyunits"
            dIcone = "hospital-o"
        case "centrocusto"
            dIcone = "sitemap"
        case "tabelaparticular"
            dIcone = "money"
	end select
end function

function header(recurso, titulo, hsysActive, hid, hPers, hPersList)
	recurso = lcase(recurso)
'    header = "<script type=""text/javascript"">$(document).ready(function(){ $("".crumb-active a"").html("""&titulo&""");"
    header = "<script type=""text/javascript""> $("".crumb-active a"").html("""&titulo&""");"
    header = header & "$("".crumb-icon a"").html(""<span class='fa fa-"&dIcone(recurso)&"'></span>"");"


'	header = header & "<div class=""widget-box transparent""><div class=""widget-header widget-header-flat"">"
'    header = header & "    <h4><i class=""fa fa-"&dIcone(recurso)&" blue""></i> "&titulo&"</h4>"
'    header = header & "        <div class=""widget-toolbar""><div>"
	if recurso="sys_financialinvoices" then
		if req("T")="C" then
			recursoPerm = "contasareceber"
		else
			recursoPerm = "contasapagar"
		end if
		if isnumeric(hid) then
			OrdemInicial = "id"
			set lista = db.execute("select (select id from "&recurso&" where "&OrdemInicial&"<r."&OrdemInicial&" and sysActive=1 and CD='"&req("T")&"' order by "&OrdemInicial&" desc limit 1) anterior, (select id from "&recurso&" where "&OrdemInicial&">r."&OrdemInicial&" and sysActive=1 and CD='"&req("T")&"' order by "&OrdemInicial&" limit 1) proximo from "&recurso&" r where id="&hid)
			if not lista.EOF then
				if not isnull(lista("anterior")) and aut(recursoPerm&"V") then
					rbtns = rbtns & "<a title='Anterior' href='?P=invoice&T="&req("T")&"&Pers="&hPers&"&I="&lista("anterior")&"' class='btn btn-sm btn-default hidden-xs'><i class='fa fa-chevron-left'></i></a> "
				end if
				rbtns = rbtns & "<a title='Lista' href='?P=ContasCD&T="&req("T")&"&Pers=1' class='btn btn-sm btn-default'><i class='fa fa-list'></i></a> "
				if not isnull(lista("proximo")) and aut(recursoPerm&"V") then
					rbtns = rbtns & "<a title='Próximo' href='?P=invoice&T="&req("T")&"&Pers="&hPers&"&I="&lista("proximo")&"' class='btn btn-sm btn-default hidden-xs'><i class='fa fa-chevron-right'></i></a> "
				end if
			end if
		end if
		if aut(recursoPerm&"I")=1 then
			rbtns = rbtns & "<a title='Nova' href='?P=invoice&Pers="&hPers&"&I=N&T="&req("T")&"' class='btn btn-sm btn-default'><i class='fa fa-plus'></i></a> "
		end if
        'response.Write(recursoPerm)
		if (hsysActive=1 and aut(recursoPerm&"A")=1) or (hsysActive=0 and aut(recursoPerm&"I")=1) or (aut("aberturacaixinhaI") and session("CaixaID")<>"" and hsysActive=0) or (hsysActive=1 and data("CaixaID")=session("CaixaID") and aut("aberturacaixinhaA")) then
				rbtns = rbtns & "<button class='btn btn-sm btn-primary' type='button' onclick='$(\""#btnSave\"").click()'>&nbsp;&nbsp;<i class='fa fa-save'></i> <strong> SALVAR</strong>&nbsp;&nbsp;</button> "
		end if

		if req("T")="D" then
			nomePerm = "contasapagar"
		    rbtns = rbtns & "<button class='btn btn-info btn-sm' onclick='imprimir()' type='button'><i class='fa fa-print bigger-110'></i></button>"
		else
			nomePerm = "contasareceber"
		    rbtns = rbtns & "<button class='btn btn-info btn-sm' onclick='imprimir()' type='button'><i class='fa fa-print bigger-110'></i></button>"
            
            set vcaCont = db.execute("select id, NomeModelo from contratosmodelos where sysActive=1")
            if not vcaCont.eof then
                rbtns = rbtns & " <div class='btn-group'><button class='btn btn-info btn-sm dropdown-toggle' data-toggle='dropdown' title='Adicionar Contrato'><i class='fa fa-file'></i></button>"
                rbtns = rbtns & "<ul class='dropdown-menu dropdown-info pull-right'>"
                while not vcaCont.eof
                    rbtns = rbtns & "<li><a href='javascript:addContrato("&vcaCont("id")&", "&hid&", $(\""#AccountID\"").val())'><i class='fa fa-plus'></i> "&vcaCont("NomeModelo")&"</a></li>"
                vcaCont.movenext
                wend
                vcaCont.close
                set vcaCont=nothing
                rbtns = rbtns & "</ul></div>"
            end if

		end if
		if session("Banco") = "clinic2496" OR session("Banco") = "clinic100000" Then
            rbtns = rbtns & "&nbsp; <button id='btn_NFe' title='Nota Fiscal' class='btn btn-warning btn-sm' onclick='modalNFE("&data("statusNFe")&")' type='button'><i class='fa fa-file-text bigger-110'></i></button>"
	    End if
		if aut(nomePerm&"X") or data("CaixaID")=session("CaixaID") then
			rbtns = rbtns & "&nbsp; <button class='btn btn-danger btn-sm disable' onclick='deleteInvoice()' type='button'><i class='fa fa-trash bigger-110'></i></button>"
		end if
'		rbtns = rbtns & "</div></div></div></div>"
        header = header & "$(""#rbtns"").html("""& rbtns &""")"
'        header = header & "});</script>"
        header = header & "</script>"
	    realSave = "<button class=""btn btn-sm btn-primary hidden"" id=""btnSave"">&nbsp;&nbsp;<i class=""fa fa-save""></i> <strong> SALVAR</strong>&nbsp;&nbsp;</button>"
	
	
	
	
	
	
	else
		if isnumeric(hid) then
			set nomeColuna = db.execute("select initialOrder from cliniccentral.sys_resources where tableName='"&recurso&"' limit 1")
			if not nomeColuna.EOF then
				set lista = db.execute("select (select id from "&recurso&" where "&nomeColuna("initialOrder")&"<r."&nomeColuna("initialOrder")&" and sysActive=1 order by "&nomeColuna("initialOrder")&" desc limit 1) anterior, (select id from "&recurso&" where "&nomeColuna("initialOrder")&">r."&nomeColuna("initialOrder")&" and sysActive=1 order by "&nomeColuna("initialOrder")&" limit 1) proximo from "&recurso&" r where id="&hid)
			else
				set lista = db.execute("select (select id from "&recurso&" where id<"&hid&" and sysActive=1 order by id desc limit 1) anterior, (select id from "&recurso&" where id>"&hid&" and sysActive=1 order by id limit 1) proximo")
			end if
            if recurso="pacientes" then
'                rbtns = rbtns & "<div class='switch switch-info switch-inline'>  <input id='exampleCheckboxSwitch1' type='checkbox' checked=''>  <label for='exampleCheckboxSwitch1'></label></div>"
                rbtns = rbtns & "<div title='Ativar / Inativar paciente' class='mn hidden-xs' style='float:left'><div class='switch switch-info switch-inline'><input checked name='Ativo' id='Ativo' type='checkbox' /><label style='height:30px' class='mn' for='Ativo'></label></div></div> &nbsp; "
            end if
			if not lista.EOF then
				if not isnull(lista("anterior")) then
					rbtns = rbtns & "<a title='Anterior' href='?P="&recurso&"&Pers="&hPers&"&I="&lista("anterior")&"' class='btn btn-sm btn-default hidden-xs'><i class='fa fa-chevron-left'></i></a> "
				end if
				rbtns = rbtns & "<a title='Lista' href='?P="&recurso&"&Pers="&hPersList&"' class='btn btn-sm btn-default'><i class='fa fa-list'></i></a> "
				if not isnull(lista("proximo")) then
					rbtns = rbtns & "<a title='Próximo' href='?P="&recurso&"&Pers="&hPers&"&I="&lista("proximo")&"' class='btn btn-sm btn-default hidden-xs'><i class='fa fa-chevron-right'></i></a> "
				end if
			end if
		end if
		if aut(recurso&"I")=1 and recurso<>"profissionais" and recurso<>"funcionarios" then
			rbtns = rbtns & "<a title='Novo' href='?P="&recurso&"&Pers="&hPers&"&I=N' class='btn btn-sm btn-default'><i class='fa fa-plus'></i></a> "
		end if
		if recurso="pacientes" then
			rbtns = rbtns & "<button title='Imprimir Ficha' type='button' id='btnFicha' class='btn btn-sm btn-default'><i class='fa fa-print'></i></button> "
			rbtns = rbtns & "<button title='Compartilhar Dados' type='button' id='btnCompartilhar' class='btn btn-sm btn-default hidden-xs'><i class='fa fa-share-alt'></i></button> "
		end if
		rbtns = rbtns & "<a title='Histórico de Alterações' href='javascript:log()' class='btn btn-sm btn-default hidden-xs'><i class='fa fa-history'></i></a> "
		'rbtns = rbtns & "<script>function log(){$('#modal-table').modal('show');$.get('DefaultLog.asp?R="&recurso&"&I="&hid&"', function(data){$('#modal').html(data);})}</script>"
		if recurso<>"profissionais" and recurso<>"funcionarios" and recurso<>"convenios" then
			if (hsysActive=1 and aut(recurso&"A")=1) or (hsysActive=0 and aut(recurso&"I")=1) then
					rbtns = rbtns & "<button class='btn btn-sm btn-primary' type='button' onclick='$(\""#save\"").click()'>&nbsp;&nbsp;<i class='fa fa-save'></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button> "
			end if
		end if
        header = header & "$(""#rbtns"").html("""& rbtns &""")"
'        header = header & "});</script>"
        header = header & "</script>"
		header = header & "<script>function log(){$('#modal-table').modal('show');$.get('DefaultLog.asp?R="&recurso&"&I="&hid&"', function(data){$('#modal').html(data);})}</script>"
	    realSave = "<button class=""btn btn-sm btn-primary hidden"" id=""save"">&nbsp;&nbsp;<i class=""fa fa-save""></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button>"
		
		
	end if
    header = realSave & header
	
end function

sub gravaConvPac(ConvenioID, PacienteID)
	if isnumeric(ConvenioID) and not isnull(ConvenioID) and isnumeric(PacienteID) and not isnull(PacienteID) then
		set vpac = db.execute("select * from pacientes where id="&PacienteID&" and (ConvenioID1="&ConvenioID&" OR ConvenioID2="&ConvenioID&" OR ConvenioID3="&ConvenioID&")")
		if vpac.EOF then
			set vpac2 = db.execute("select * from pacientes where id="&PacienteID)
			if not vpac2.eof then
				if isnull(vpac2("ConvenioID1")) OR vpac2("ConvenioID1")=0 then
					GravaAqui = 1
				elseif isnull(vpac2("ConvenioID2")) OR vpac2("ConvenioID2")=0 then
					GravaAqui = 2
				elseif isnull(vpac2("ConvenioID3")) OR vpac2("ConvenioID3")=0 then
					GravaAqui = 3
				else
					GravaAqui = ""
				end if
			end if
			if GravaAqui<>"" then
				db_execute("update pacientes set ConvenioID"&GravaAqui&"="&ConvenioID&", PlanoID"&GravaAqui&"=0 where id="&PacienteID)
			end if
		end if
	end if
end sub

function valConvenio(ConvenioID, PlanoID, PacienteID, ProcedimentoID)
	valConvenio = 0
	if not isnull(ConvenioID) and isnumeric(ConvenioID) then
		set valConv = db.execute("select * from tissprocedimentosvalores where ProcedimentoID="&ProcedimentoID&" and ConvenioID="&ConvenioID)
		if not valConv.EOF then
			if NaoCobre="S" then
				valConvenio = "N"
			else
				valConvenio = valConv("Valor")
			end if
		end if
		if isnull(PlanoID) or not isnumeric(PlanoID) or PlanoID="" then
			if not isnull(PacienteID) and isnumeric(PacienteID) and PacienteID<>"" then
				set pplan = db.execute("select * from pacientes where id="&PacienteID)
				if not pplan.EOF then
					if pplan("ConvenioID1")=ConvenioID then
						nPlano = 1
					elseif pplan("ConvenioID2")=ConvenioID then
						nPlano = 2
					elseif pplan("ConvenioID3")=ConvenioID then
						nPlano = 3
					else
						nPlano = ""
					end if
					if nPlano<>"" then
						PlanoID = pplan("PlanoID"&nPlano)
					end if
				end if
			end if
		end if
		
		if not isnull(PlanoID) and isnumeric(PlanoID) and PlanoID<>"" and not valConv.EOF then
			'response.Write("select * from tissprocedimentosvaloresplanos where AssociacaoID="&valConv("id")&" and PlanoID="&PlanoID)
			set valPlan = db.execute("select * from tissprocedimentosvaloresplanos where AssociacaoID like '"&valConv("id")&"' and PlanoID like '"&PlanoID&"'")
			if not valPlan.EOF then
				if valPlan("NaoCobre")="S" then
					valConvenio = "N"
				else
					valConvenio = valPlan("Valor")
				end if
			end if
		end if

	end if
end function

function dataGoogle(Data, Hora)
	dt = formatdatetime(Data, 2)
	dataGoogle = right(dt, 4)&"-"&mid(dt, 4, 2)&"-"&left(dt, 2) &"T"&formatdatetime(Hora, 3)&".000-03:00"
'	2016-03-15T10:25:00.000-03:00
end function

function googleCalendar(Acao, Email, AgendamentoID, ProfissionalID, NomePaciente, Data, Hora, Tempo, NomeProcedimento, Notas)
	if Email="vca" then
		set vca = db.execute("select * from profissionais where id like '"&ProfissionalID&"'")
		if not vca.EOF then
			if vca("GoogleCalendar")<>"" and instr(vca("GoogleCalendar"), "@")>0 then
				Email = vca("GoogleCalendar")
			end if
		end if
	end if
	if NomePaciente="" and Email<>"vca" and Acao<>"X" and isnumeric(AgendamentoID) and AgendamentoID<>"" then
		set dadosAge = db.execute("select a.Data, a.Hora, a.Tempo, pac.NomePaciente, proc.NomeProcedimento from agendamentos a LEFT JOIN pacientes pac on pac.id=a.PacienteID LEFT JOIN procedimentos proc on proc.id=a.TipoCompromissoID WHERE a.id="&AgendamentoID)
		if not dadosAge.EOF then
			NomePaciente = dadosAge("NomePaciente")
			Data = dadosAge("Data")
			Hora = dadosAge("Hora")
			Tempo = dadosAge("Tempo")
			NomeProcedimento = dadosAge("NomeProcedimento")
		end if
	end if
	if Tempo="" or isnull(Tempo) or Tempo="0" or not isnumeric(Tempo) then
		Tempo=15
	end if
	if Acao="I" and Email<>"vca" and NomePaciente<>"" then
		Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
			Inicio = dataGoogle(Data, Hora)
			HoraFinal = dateadd("n", Tempo, Hora)
			Fim = dataGoogle(Data, HoraFinal)
		'	response.Write("alert('http://localhost/feegowclinic/calendar/salvar_dados.php?Email="&Email&"&AgendamentoID="&AgendamentoID&"&NomePaciente="&NomePaciente&"&Inicio="&Inicio&"&Fim="&Fim&"&NomeProcedimento="&NomeProcedimento&"\tempo="&Tempo&"')")
			objWinHttp.Open "GET", "http://localhost/weegow/feegowclinic/calendar/salvar_dados.php?Email="&Email&"&AgendamentoID="&AgendamentoID&"&NomePaciente="&NomePaciente&"&Inicio="&Inicio&"&Fim="&Fim&"&NomeProcedimento="&NomeProcedimento
		objWinHttp.Send
		resposta = objWinHttp.ResponseText
		db_execute("insert into googleagenda (AgendamentoID, ProfissionalID, GoogleID) values ("&AgendamentoID&", "&ProfissionalID&", '"&resposta&"')")
		Set objWinHttp = Nothing
	elseif Acao="X" then
		set vcaAge = db.execute("select * from googleagenda where AgendamentoID="&AgendamentoID)
		if not vcaAge.EOF then
			Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
				objWinHttp.Open "GET", "http://localhost/weegow/feegowclinic/calendar/excluir_dados.php?EventoID="&vcaAge("GoogleID")
'				response.Write("http://localhost/feegowclinic/calendar/excluir_dados.php?EventoID="&vcaAge("GoogleID"))
			objWinHttp.Send
			resposta = objWinHttp.ResponseText
			db_execute("delete from googleagenda where AgendamentoID="&AgendamentoID)
			Set objWinHttp = Nothing
		end if
	end if
end function

function device()
	agente = lcase(request.ServerVariables("HTTP_USER_AGENT"))
	if instr(agente, "iphone")>0 then
		device = "Iphone"
	elseif instr(agente, "android")>0 then
		device = "Android"
	else
		device = ""
	end if
end function

function db_execute(txt)
'	set fs=Server.CreateObject("Scripting.FileSystemObject")
'	set f=fs.OpenTextFile("c:\inetpub\wwwroot\feegowclinic\teste.txt",8,true)
'		f.WriteLine(txt&";")
'	f.close
'	set f=nothing
'	set fs=nothing
 '       response.write(txt)
	db.execute(txt)
    '    response.Write("{"& txt &"}")
    db_execute("insert into cliniccentral.updates (codigoSQL, Banco) values ('"&rep(txt)&"', '"&session("Banco")&"')")
end function

function DiaMes(PU, Dt)
	DiaMes = cdate("1/"&month(Dt)&"/"&year(Dt))
	if PU="U" then
		DiaMes = dateadd("m", 1, DiaMes)
		DiaMes = dateadd("d", -1, DiaMes)
	end if
end function

function gravaRepasse(SN, DominioID, ItemInvoiceID, ItemGuiaID, ProfissionalID)
	if isnumeric(ItemInvoiceID) and ItemInvoiceID<>"" then
		db_execute("delete from rateiorateios WHERE ItemInvoiceID="&ItemInvoiceID&" AND ( ISNULL(ItemContaAPagar) OR ItemContaAPagar=0 )")
	end if

	if SN=true or SN="S" then
		
		
		
		'response.Write("Gravando as funcoes deste item invoice<br>")
		set func = db.execute("select * from rateiofuncoes where DominioID="&DominioID)
		while not func.eof
			ContaPadrao = func("ContaPadrao")
			if ContaPadrao="PRO" then
				ContaPadrao = ProfissionalID
			end if
			if func("Valor")<>0 and not isnull(func("Valor")) then
				'Para particulares
				if ItemInvoiceID<>"" and isnumeric(ItemInvoiceID) then
					'antes  de dar este insert ve se tem algum rr com este iteminvoiceid AND funcaoID, senao nao insere
					set vcaRR = db.execute("SELECT * FROM rateiorateios WHERE ItemInvoiceID="&treatvalnull(ItemInvoiceID)&" AND FuncaoID="&func("id")&" AND NOT ISNULL(ItemContaAPagar)")
					if vcaRR.EOF then
						db_execute("INSERT INTO rateiorateios (ItemInvoiceID, ItemGuiaID, Funcao, TipoValor, Valor, ContaCredito, sysDate, FM, ProdutoID, ValorUnitario, Quantidade, sysUser, Sobre, FuncaoID) VALUES ("&treatvalnull(ItemInvoiceID)&", "&treatvalnull(ItemGuiaID)&", '"&rep(func("Funcao"))&"', '"&rep(func("TipoValor"))&"', "&treatvalzero(func("Valor"))&", '"&ContaPadrao&"', date(now()), '"&func("FM")&"', "&treatvalzero(func("ProdutoID"))&", "&treatvalzero(func("ValorUnitario"))&", "&treatvalzero(func("Quantidade"))&", "&session("User")&", "&treatvalzero(func("Sobre"))&", "&func("id")&")")
					end if
				end if
				'Para convenios
				''''''fazer a rotina de cima mudando pra ItemGuiaID
			end if
		'	response.Write("<br>")
		func.movenext
		wend
		func.close
		set func=nothing
	end if
end function

function iteminvoiceAP(ItemInvoiceID)
	set dadosii = db.execute("select ii.*, i.AccountID from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID WHERE ii.id="&ItemInvoiceID)
	if not daddosii.eof then
		if dadosii("Executado")="S" then '//para inserir ou atualizar algum ap



			set vcaAtend = db.execute("select * from atendimentos where ProfissionalID="&dadosii("ProfissionalID")&" AND PacienteID="&dadosii("AccountID")&" AND Data="&mydatenull(dadosii("Data")))
			if not vcaAtend.EOF then
				AtendimentoID = vcaAtend("id")
			else
				db_execute("INSERT INTO atendimentos (PacienteID, AgendamentoID, Data, HoraInicio, HoraFim, sysUser, ProfissionalID, UnidadeID) values ("&dadosii("AccountID")&", 0, "&mydatenull(dadosii("DataExecucao"))&", "&mytime(dadosii("HoraExecucao"))&", "&mytime(dadosii("HoraFim"))&", "&session("User")&", "&dadosii("ProfissionalID")&", "&treatvalzero(dadosii("CompanyUnitID"))&")")
				set pult = db.execute("select id from atendimentos where sysUser="&session("User")&" order by id desc limit 1")
				AtendimentoID = pult("id")
			end if
			




		end if
	end if
end function

function fn(valnum)
	if not isnull(valnum) and isnumeric(valnum) and valnum<>"" then
		fn = formatnumber(valnum, 2)
	else
		fn = "0,00"
	end if
end function

function ft(valHora)
	if not isnull(valHora) and isdate(valHora) and valHora<>"" then
		ft = formatdatetime(valHora, 4)
	else
		ft = ""
	end if
end function

function limpa(limtabela, limcoluna, limid)
	Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
	objWinHttp.Open "GET", "http://localhost/weegow/feegowclinic/RTFtoHTML.php?banco="&session("banco")&"&tabela="&limtabela&"&coluna="&limcoluna&"&id="&limid
	objWinHttp.Send
	strHTML = objWinHttp.ResponseText
	Set objWinHttp = Nothing
	Valor = trim(Valor)
	Valor = replace(strHTML, chr(10), "<br>")

	db_execute("update `"&limtabela&"` set `"&limcoluna&"`='"&rep(Valor)&"' where id="&limid)
end function

function btnParcela(MovimentacaoID, ValorPago, Valor, Vencimento, CD, CaixaID)
	input = "<label>"
    if CD="C" then
         permInv = "|contasapagarI|"
   else
        permInv = "|contasareceberI|"
    end if
    if aut(permInv) OR (session("CaixaID")<>"" and aut("|aberturacaixinhaI|")) then
        input = input & "<input id=""Parcela"&MovimentacaoID&""" type=""checkbox"" class=""ace parcela"" value=""|"&MovimentacaoID&"|"" name=""Parcela"" ><span class=""lbl""></span> "
    elseif aut(permInv)=0 and session("CaixaID")="" and aut("|aberturacaixinhaI|") then
        input = input & "<input id=""Parcela"&MovimentacaoID&""" type=""checkbox"" class=""ace"" value=""|"&MovimentacaoID&"|"" onclick=""alert('Você está com seu caixa fechado. Por favor, abra seu caixa para pagar esta conta.')"" ><span class=""lbl""></span> "
    else
        input = input & "</label>"
    end if

	if ValorPago=0 then
		classe = "danger"
		txt = input & "R$ <span id='pend"&MovimentacaoID&"'>" &  fn( Valor ) &"</span>"
	elseif ValorPago>0 and ValorPago+0.3<Valor then
		classe = "warning parte-paga"
		txt = input & "<span id='pend"&MovimentacaoID&"'>" &  fn( Valor-ValorPago ) &" de " &  fn( Valor ) &"</span>"
	else
		classe = "success parte-paga"
		txt = "<i class=""fa fa-check""></i> R$ <span id='pend"&MovimentacaoID&"'>" &  fn( Valor ) &"</span>"
	end if
    if Vencimento<>"" then
        spanVenc = " title=""Vencimento: "&Vencimento&""" "
    else
        spanVenc = ""
    end if
    if MovimentacaoID>0 then
        zoom = "<a class='btn btn-xs btn-default' href=""javascript:modalPaymentDetails('"&MovimentacaoID&"');""> <i class=""fa fa-search-plus bigger-140 white""></i></a>"
    else
        zoom = ""
    end if
	btnParcela = "<span "& spanVenc &" class='label label-md btn-block label-"&classe&" text-right'>"&txt &"</span>" & zoom
end function

function inputsRepasse(ItemID, FormaID, ProfissionalID, ProcedimentoID, UnidadeID)
    %>
    alert(<%=dominioRepasse(FormaID, ProfissionalID, ProcedimentoID, UnidadeID) %>);
    <%
end function

function salvaRepasse(LinhaID, ItemID)
    gLinhaID = LinhaID
    gItemID = ItemID
    'verifica se este item da invoice teve algum repasse q ja foi pro contas a pagar. se tiver, nao mexe mais nos repasses que foram consolidados pra este item
    set vcaLancado = db.Execute("select * from rateiorateios where not isnull(ItemContaAPagar) and ItemInvoiceID="&gItemID)
    if vcaLancado.eof then
        set ii = db.execute("select ii.*, i.CompanyUnitID UnidadeID, i.FormaID, i.ContaRectoID from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID where ii.id="&gItemID)
        DominioID = dominioRepasse(ii("FormaID")&"_"&ii("ContaRectoID"), ii("ProfissionalID"), ii("ItemID"), ii("UnidadeID"))
        if ii("Executado")="S" then
            DataExecucao = ii("DataExecucao")
            ProcedimentoID = ii("ItemID")
            FormaID = ii("FormaID")
            set fun = db.execute("select * from rateiofuncoes where DominioID="&DominioiD)
            while not fun.eof
                Variavel = ""
                Sobre = fun("Sobre")
                FuncaoID = fun("id")
                FM = fun("FM")
                if FM="" or isnull(FM) then
                    FM="F"
                end if
                ContaCredito = fun("ContaPadrao")
                '->Aqui começa a distribuir
                if FM="F" then
                    if ContaCredito="PRO" then
                        ContaCredito = ii("Associacao")&"_"&ii("ProfissionalID")
                    elseif ContaCredito="" then
                        ContaCredito = ref("r_ContaCredito_" & gLinhaID & "_" & FuncaoID)
                        Variavel = "S"
                    end if
                    if fun("Valor")>0 then
                        call insRat(gItemID, fun("Funcao"), fun("TipoValor"), fun("Valor"), ContaCredito, DataExecucao, ii("FormaID"), fun("Sobre"), FM, 0, 0, 0, session("User"), FuncaoID, Variavel)
                    end if
                elseif FM="E" then
                    set eq = db.execute("select * from procedimentosequipeparticular where ProcedimentoID="&ProcedimentoID)
                    while not eq.eof
                        FuncaoID = eq("id")*(-1)
                        ContaCredito = eq("ContaPadrao")
                        if ContaCredito="PRO" then
                            ContaCredito = ii("Associacao")&"_"&ii("ProfissionalID")
                        elseif ContaCredito="" then
                            ContaCredito = ref("r_ContaCredito_"&gLinhaID&"_"&FuncaoID)
                            Variavel = "S"
                        end if
                        if eq("Valor")>0 then
                            call insRat(gItemID, eq("Funcao"), eq("TipoValor"), eq("Valor"), ContaCredito, DataExecucao, FormaID, Sobre, FM, 0, 0, 0, session("User"), FuncaoID, Variavel)
                        end if
                    eq.movenext
                    wend
                    eq.close
                    set eq=nothing
                elseif FM="M" then
                    if fun("Variavel")="S" then
                    '    ValorUnidade = fun()
                        Quantidade = ref("r_Quantidade_"&gLinhaID&"_"&FuncaoID)
                    else
                        Quantidade = fun("Quantidade")
                    end if
                    call insRat(gItemID, fun("Funcao"), fun("TipoValor"), fun("Valor"), ContaCredito, DataExecucao, FormaID, Sobre, FM, fun("ProdutoID"), fun("ValorUnitario"), Quantidade, session("User"), FuncaoID, fun("Variavel"))
                elseif FM="K" then
                    set pk = db.Execute("select pk.* from procedimentoskits k LEFT JOIN produtosdokit pk on pk.KitID=k.KitID where k.ProcedimentoID="&ProcedimentoID&" AND k.Casos like '%|P|%'")
                    while not pk.eof
                        FuncaoID = pk("id")*(-1)
                        FM = "M"
                        if pk("Variavel")="S" then
                            Quantidade = ref("r_Quantidade_"&gLinhaID&"_"&FuncaoID)
                            if pk("Quantidade")>0 then
                                ValorUnidade = pk("Valor") / pk("Quantidade")
                            else
                                ValorUnidade = pk("Valor")
                            end if
                            if isnumeric(Quantidade) and Quantidade<>"" then
                                ValorDoVariavel = ccur(Quantidade) * ValorUnidade
                            else
                                ValorDoVariavel = 0
                            end if
                            Valor = ValorDoVariavel
                        else
                            Quantidade = pk("Quantidade")
                            Valor = pk("Valor")
                            ValorUnidade = Valor
                        end if
                        call insRat(gItemID, fun("Funcao"), "V", Valor, 0, DataExecucao, FormaID, Sobre, FM, pk("ProdutoID"), ValorUnidade, Quantidade, session("User"), FuncaoID, pk("Variavel"))
                    pk.movenext
                    wend
                    pk.close
                    set pk=nothing
                end if
                '<- Aqui termina de distribuir
            fun.movenext
            wend
            fun.close
            set fun=nothing
        end if
    end if
end function

function insRat(ItemInvoiceID, Funcao, TipoValor, Valor, ContaCredito, sysDate, FormaID, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysUser, FuncaoID, Variavel)
    
    sqlInsRat = "insert into rateiorateios (ItemInvoiceID, Funcao, TipoValor, Valor, ContaCredito, sysDate, FormaID, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysUser, FuncaoID, Variavel) values ("&ItemInvoiceID&", '"&Funcao&"', '"&TipoValor&"', "&treatvalzero(Valor)&", '"&ContaCredito&"', "&mydatenull(sysDate)&", "&treatvalzero(FormaID)&", "&treatvalzero(Sobre)&", '"&FM&"', "&treatvalzero(ProdutoID)&", "&treatvalzero(ValorUnitario)&", "&treatvalzero(Quantidade)&", "&session("User")&", "&FuncaoID&", '"&Variavel&"')"
 '       response.write(sqlInsRat)
    db_execute(sqlInsRat)
end function

function escreveParcelas (De, Ate)
    if De=1 and Ate=1 then
        escreveParcelas = "1 parcela"
    elseif De<>Ate then
        escreveParcelas = De&" a "&Ate&" parcelas"
    elseif De=Ate and De>1 then
        escreveParcelas = De & " parcelas"
    end if
    'response.Write(escreveParcelas)
end function

function calculaRepasse(RepasseID, Sobre, ValorTotal, ValorRepasse, TipoValor)
    if TipoValor="V" then
        calculaRepasse = ValorRepasse
    else
        'se for sobre subtotal busca os anteriores pra calculo preciso
        calculaRepasse = ValorTotal * (ValorRepasse/100)
    end if
end function

function getSequencial(GuiaID)
    set profs = db.execute("select Sequencial from tissprofissionaissadt where not isnull(Sequencial) and GuiaID="&GuiaID&" order by Sequencial desc")
    if profs.eof then
        getSequencial = 1
    else
        getSequencial = profs("Sequencial")+1
    end if
end function

function matProcGuia(ProcGSID, ConvenioID)
    set pProcGSID = db.execute("select * from tissprocedimentossadt where id="&ProcGSID)
    set vcaEsteProc = db.execute("select id from tissguiaanexa where ProcGSID="&ProcGSID)
    if not pProcGSID.eof and vcaEsteProc.eof then
        'pega os materiais de kits e insere
        set pkit = db.execute("select pckit.*, pkit.TabelaID from procedimentoskits pckit left join produtoskits pkit on pckit.KitID=pkit.id where pckit.ProcedimentoID="&pProcGSID("ProcedimentoID")&" and (pckit.Casos like '%|ConvALL|%' OR (pckit.Casos like '%|ConvEXCEPT|%' and not pckit.Casos like '%|"&ConvenioID&"|%') OR (pckit.Casos like '%|ConvONLY|%' and pckit.Casos like '%|"&ConvenioID&"|%'))")
        while not pkit.eof
            set ppdkit = db.Execute("select pdk.*, p.CD, p.ApresentacaoUnidade, p.RegistroANVISA, p.Codigo CodigoNoFabricante, p.AutorizacaoEmpresa, p.NomeProduto from produtosdokit pdk LEFT JOIN produtos p on p.id=pdk.ProdutoID where pdk.KitID="&pkit("KitID"))
            while not ppdkit.eof
                sqlIns = "insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, TabelaProdutoID, ProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao, ProcGSID) values ("&pProcGSID("GuiaID")&", "&treatvalzero(ppdkit("CD"))&", "&mydatenull(pProcGSID("Data"))&", "&mytime(pProcGSID("HoraInicio"))&", "&mytime(pProcGSID("HoraFim"))&", "&pkit("TabelaID")&", "&ppdkit("ProdutoID")&", '"&ppdkit("Codigo")&"', "&treatvalzero(ppdkit("Quantidade"))&", "&treatvalzero(ppdkit("ApresentacaoUnidade"))&", 1, "&treatvalzero(ppdkit("Valor"))&", "&treatvalzero(ppdkit("Valor")*ppdkit("Quantidade"))&", '"&ppdkit("RegistroANVISA")&"', '"&ppdkit("CodigoNoFabricante")&"', '"&ppdkit("AutorizacaoEmpresa")&"', '"&ppdkit("NomeProduto")&"', "&ProcGSID&")"
               ' response.write(sqlIns)
                db_execute(sqlIns)
            ppdkit.movenext
            wend
            ppdkit.close
            set ppdkit=nothing
        pkit.movenext
        wend
        pkit.close
        set pkit=nothing

        'pega os materiais de associados e insere
		set vDesp = db.execute("select pp.id as ppid, pp.*, pv.*, pt.*, p.CD, p.NomeProduto, p.RegistroANVISA, p.AutorizacaoEmpresa, p.ApresentacaoUnidade, p.Codigo as CodigoNoFabricante from tissprodutosprocedimentos as pp left join tissprodutosvalores as pv on pv.id=pp.ProdutoValorID left join tissprodutostabela as pt on pt.id=pv.ProdutoTabelaID left join produtos as p on p.id=pt.ProdutoID left join tissprocedimentosvalores as procval on procval.id=pp.AssociacaoID where procval.ConvenioID like '"&ConvenioID&"' and procval.ProcedimentoID like '"&pProcGSID("ProcedimentoID")&"'")
		while not vDesp.eof
			Valor = vDesp("Valor")
            if isnull(Valor) then
                set pval = db.execute("select pv.Valor from tissprodutostabela pt left join tissprodutosvalores pv on pt.id=pv.ProdutoTabelaID where pv.ConvenioID="&ConvenioID&" and pt.ProdutoID="&vDesp("ProdutoID"))
                if not pval.eof then
                    Valor = pval("Valor")
                end if
            end if
			if isnull(Valor) then Valor=0 end if
			Quantidade = vDesp("Quantidade")
			if isnull(Quantidade) then Quantidade=1 end if
			ValorTotal = Quantidade*Valor
			if not isnull(vDesp("ProdutoID")) then
                sqlIns = "insert into tissguiaanexa (GuiaID, CD, Data, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao, ProcGSID) values ("&pProcGSID("GuiaID")&", "&treatvalzero(vDesp("CD"))&", "&mydatenull(pProcGSID("Data"))&", "&treatvalzero(vDesp("ProdutoID"))&", "&treatvalzero(vDesp("TabelaID"))&", '"&vDesp("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(vDesp("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotal)&", '"&vDesp("RegistroANVISA")&"', '"&vDesp("CodigoNoFabricante")&"', '"&vDesp("AutorizacaoEmpresa")&"', '"&rep(vDesp("NomeProduto"))&"', "&ProcGSID&")"
                'response.write(sqlIns)
				db_execute(sqlIns)
			end if
		vDesp.movenext
		wend
		vDesp.close
		set vDesp=nothing
		'<- materiais deste procedimento nesta guia
		db_execute("update tissguiasadt set "&_ 
		"Procedimentos=(select sum(ValorTotal) from tissprocedimentossadt where GuiaID="&pProcGSID("GuiaID")&"),"&_ 
		"GasesMedicinais=(select sum(ValorTotal) from tissguiaanexa where CD=1 and GuiaID="&pProcGSID("GuiaID")&"), "&_ 
		"Medicamentos=(select sum(ValorTotal) from tissguiaanexa where CD=2 and GuiaID="&pProcGSID("GuiaID")&"), "&_ 
		"Materiais=(select sum(ValorTotal) from tissguiaanexa where CD=3 and GuiaID="&pProcGSID("GuiaID")&"), "&_ 
		"TaxasEAlugueis=(select sum(ValorTotal) from tissguiaanexa where CD=7 and GuiaID="&pProcGSID("GuiaID")&"), "&_ 
		"OPME=(select sum(ValorTotal) from tissguiaanexa where CD=8 and GuiaID="&pProcGSID("GuiaID")&") "&_ 
		"where id="&pProcGSID("GuiaID"))
    end if
end function

function zeroEsq(val, quant)
    zeroEsq = right("0000000000000000000000000000000000"&val, quant)
end function

function fSysActive(NomeCampo, psysActive, PacienteID)
    if session("OtherCurrencies")="phone" then
        %>
        <label><input type="radio" name="<%=NomeCampo %>" class="ace dadosContato" onclick="saveSta(-2, <%=PacienteID%>)" value="-2"<%if psysActive=-2 then response.write(" checked ") end if %> /><span class="lbl"> <small>Lead</small></span></label>
        <label><input type="radio" name="<%=NomeCampo %>" class="ace dadosContato" onclick="saveSta(-3, <%=PacienteID%>)" value="-3"<%if psysActive=-3 then response.write(" checked ") end if %> /><span class="lbl"> <small>Pré-cad.</small></span></label>
        <label><input type="radio" name="<%=NomeCampo %>" class="ace dadosContato" onclick="saveSta(1, <%=PacienteID%>)" value="1"<%if psysActive=1 then response.write(" checked ") end if %> /><span class="lbl"> <small>Paciente</small></span></label>
        <script type="text/javascript">
            function saveSta(Sta, PacienteID){
                $.post("saveSta.asp", {Sta:Sta, PacienteID:PacienteID}, function(data){eval(data)});
            }
        </script>
        <%
    else
        %>
        <input type="hidden" name="<%=NomeCampo %>" value="1" />
        <%
    end if
end function

function podeExcluir(xCaixaID, xType, xCD, xAccountAssociationIDCredit)
    if (xCaixaID=session("CaixaID") and aut("|aberturacaixinhaX|") and xType="Pay") or (aut("|contasareceberX|") and xCD="D" and xType="Pay") or (aut("|areceberpacienteX|") and xCD="D" and xAccountAssociationIDCredit=3 and xType="Pay") or (aut("|contasapagarA|") and xCD="C" and xType="Pay") or (aut("|lancamentosX|") and xType="Transfer") then
        podeExcluir = true
    else
        podeExcluir = false
    end if
end function

function dispEquipamento(Data, Hora, Intervalo, EquipamentoID)
    dispEquipamento = ""
    if isnumeric(Intervalo) and Intervalo<>"" and not isnull(Intervalo) then
        Intervalo = ccur(Intervalo)
    else
        Intervalo = 0
    end if
    HoraFinal = dateadd("n", Intervalo, Hora)
    if isnumeric(EquipamentoID) and EquipamentoID<>"" and not isnull(EquipamentoID) then
        if ccur(EquipamentoID)<>0 then
            sqlDisp = "SELECT a.Hora, a.HoraFinal, p.NomeProfissional FROM agendamentos a LEFT JOIN profissionais p on p.id=a.ProfissionalID WHERE a.Data="&mydatenull(Data)&" AND "&_
                    "("&_
                    "("&mytime(Hora)&">=a.Hora AND "&mytime(Hora)&"<a.HoraFinal)"&_
                    " OR "&_
                    "("&mytime(HoraFinal)&">a.Hora AND "&mytime(HoraFinal)&"<a.HoraFinal)"&_
                    " OR "&_
                    "("&mytime(Hora)&"<a.Hora AND "&mytime(HoraFinal)&">a.HoraFinal)"&_
                    " OR "&_
                    "("&mytime(Hora)&"=a.Hora)"&_
                    ") AND a.EquipamentoID="&EquipamentoID
     '       response.Write(sqlDisp)
            set vcaAgEq = db.execute(sqlDisp)
            if not vcaAgEq.eof then
                dispEquipamento = "Este equipamento já está agendado para o profissional "&vcaAgEq("NomeProfissional")&" nesta data entre as "&formatdatetime(vcaAgEq("Hora"),4)&" e "&formatdatetime(vcaAgEq("HoraFinal"),4)
            end if
        end if
    end if
    'dispEquipamento = ""
end function

function replacePagto(txt, Total)
	on error resume next
	'response.Write(txt&"<hr>")
	txt = trim(txt&" ")
	'primeiro separa todas as tags que existem na expressao
	spl = split(txt, "{{")
	for i=0 to ubound(spl)
		if instr(spl(i), "}}")>0 then
			spl2 = split(spl(i), "}}")
			Crua = spl2(0)
			Formula = lcase(Crua)
			Formula = replace(Formula, "total", Total)
			Formula = eval(Formula)
			Formula = formatnumber(Formula, 2)
			if isnumeric(Formula) then
				Formula = "R$ "&Formula
			else
				Formula = "{{ERRO_NA_FORMULA}}"
			end if
			txt = replace(txt, "{{"&Crua&"}}", Formula)
	'		response.Write(Formula&"<br><br>")
		end if
	next
	'response.Write(txt)
    replacePagto = txt
end function

private function geraRecorrente(i)
    if i=0 then
        sql = "select * from invoicesfixas where PrimeiroVencto<=date(now()) and sysActive=1"
    else
        sql = ""
    end if
    set fx = db.execute(sql)
    while not fx.eof
        Geradas = fx("Geradas")&""
        PrimeiroVencto = fx("PrimeiroVencto")
        Vencto = PrimeiroVencto
        Conta = 0
        Intervalo = fx("Intervalo")
        TipoIntervalo = fx("TipoIntervalo")
        while Vencto<=date()
                Conta = Conta+1
                
            if instr(Geradas, "|"&Conta&"|")=0 then
                'cria->
                db_execute("insert into sys_financialinvoices (Name, AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser, sysDate, FixaID, FixaNumero) values ('"&rep(fx("Name"))&"', "&fx("AccountID")&", "&fx("AssociationAccountID")&", "&treatvalzero(fx("Value"))&", 1, 'BRL', "&treatvalzero(fx("CompanyUnitID"))&", "&fx("Intervalo")&", '"&fx("TipoIntervalo")&"', '"&fx("CD")&"', 1, "&treatvalzero(fx("sysUser"))&", "&mydatenull(Vencto)&", "&fx("id")&", "&Conta&")")
                set pult = db.execute("select id from sys_financialinvoices where FixaID="&fx("id")&" order by id desc")
                if fx("CD")="C" then
                    AccountAssociationIDDebit = fx("AssociationAccountID")
                    AccountIDDebit = fx("AccountID")
                    AccountAssociationIDCredit = 0
                    AccountIDCredit = 0
                else
                    AccountAssociationIDDebit = 0
                    AccountIDDebit = 0
                    AccountAssociationIDCredit = fx("AssociationAccountID")
                    AccountIDCredit = fx("AccountID")
                end if
                db_execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, ValorPago, UnidadeID) values ("&AccountAssociationIDCredit&", "&AccountIDCredit&", "&AccountAssociationIDDebit&", "&AccountIDDebit&", "&treatvalzero(fx("Value"))&", "&mydatenull(Vencto)&", '"&fx("CD")&"', 'Bill', 'BRL', 1, "&pult("id")&", 1, "&fx("sysUser")&", 0, "&fx("CompanyUnitID")&")")
                db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Descricao, Executado, sysUser)  (select '"&pult("id")&"', Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Descricao, Executado, sysUser from itensinvoicefixa where InvoiceID="&fx("id")&")")
                
                db_execute("update invoicesfixas set Geradas = concat(ifnull(Geradas, ''), '|"&Conta&"|') where id="&fx("id"))
                '<- cria
            end if
                Vencto = dateadd(TipoIntervalo, Intervalo, Vencto)
        wend
    fx.movenext
    wend
    fx.close
    set fx = nothing
end function

function statusTarefas(De, Para)
'    response.write("select id from sys_users where id="&De&" or id in("&replace(Para, "|", "")&")")
    set puser = db.execute("select id from sys_users where id="&De&" or id in("&replace(Para, "|", "")&")")
    while not puser.eof
        notifTarefas = ""
 '       response.write("select id, staPara from tarefas where De="&puser("id")&" and staPara in('Respondida')")
        set tarDe = db.execute("select id, staPara from tarefas where De="&puser("id")&" and staPara in('Respondida')")
        while not tarDe.eof
            notifTarefas = notifTarefas & "|"& tarDe("id") & "," & tarDe("staPara")
        tarDe.movenext
        wend
        tarDe.close
        set tarDe = nothing

        set tarPara = db.Execute("select id, DtPrazo, HrPrazo from tarefas where Para like '%|"& puser("id") &"|%' and staDe in('Pendente', 'Enviada')")
        while not tarPara.eof
            notifTarefas = notifTarefas & "|" & tarPara("id") & "," & tarPara("DtPrazo") & " " & ft(tarPara("HrPrazo"))
        tarPara.movenext
        wend
        tarPara.close
        set tarPara = nothing

'        response.write("update sys_users set notifTarefas='"&notifTarefas&"' where id="&puser("id"))
        db_execute("update sys_users set notifTarefas='"&notifTarefas&"' where id="&puser("id"))
    puser.movenext
    wend
    puser.close
    set puser=nothing
end function

function callAction(Numero, Canal, Contato)
    if len(Numero)>3 then
        Set Regex = New RegExp 
        Regex.Pattern = "[^0-9]"
        Regex.Global = True
        NumeroLimpo = Regex.Replace(Trim(Numero),"")
        callAction = "<a href=""javascript:btb("&Canal&", '"& NumeroLimpo &"', '"&Contato&"')"" class='label label-sm label-purple arrowed arrowed-in-right'><small>"&Numero&"</small></a>"
    end if
end function

function fechaPonto(UsuarioID)
    db_execute("update ponto set Fim=Inicio where UsuarioID="&UsuarioID&" and Data<curdate() and isnull(Fim)")
end function

function tempoTrab(UsuarioID, Exibicao)
        TempoTotal = 0
        set ptempo = db.execute("select Inicio, ifnull(Fim, curtime()) Fim from ponto where UsuarioID="&UsuarioID&" and Data=curdate() order by Inicio")
        if pTempo.EOF then
            Status = "<span class='pull-right label label-sm label-danger arrowed-in arrowed-in-right'>Ausente</span>"
            strStatus = "Ausente"
            chegou = "N"
        end if

        'if Exibicao = "Grafico" then
            Data = date()
            DiaSemana = weekday(Data)
            Hora = cdate("00:00")
            PrimeiroTempo = ""
		    set Horarios = db.execute("select ass.*, l.NomeLocal from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID=(select idInTable from sys_users where id="&UsuarioID&") and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe")
		    if Horarios.EOF then
	            set Horarios = db.execute("select ass.*, l.NomeLocal from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID=(select idInTable from sys_users where id="&UsuarioID&") and ass.DiaSemana="&DiaSemana&" order by ass.HoraDe")
		    end if


            Fator = 0.7
            BarraGrade = "<div style=""height:40px"" class=""progress progress-bar-grey progress-striped no-margin active"">"

                PrimeiroTempo=""
                TempoTrab = 0
                while not ptempo.eof

                    if PrimeiroTempo="" then
                        PrimeiroTempo = datediff("n", ft("07:00"), ft(ptempo("Inicio")))
                        BarraGrade = BarraGrade & "<div class=""progress-bar progress-bar-grey"" style=""width: "&cint(PrimeiroTempo *Fator)&"px""></div>"
                    else
                        BarraGrade = BarraGrade & "<div class=""progress-bar progress-bar-grey"" style=""width: "&cint(datediff("n", UltimoHorario, ptempo("Inicio") ) *Fator)&"px""></div>"
                    end if
                    Tempo = datediff("n", ptempo("Inicio"), ptempo("Fim"))
                    BarraGrade = BarraGrade & "<div class=""progress-bar progress-bar-warning barra"&UsuarioID&""" style=""width: "&cint(Tempo *Fator)&"px""></div>"
                    UltimoHorario = ptempo("Fim")
                    TempoTrab = TempoTrab + Tempo



                    Inicio = ft(ptempo("Inicio"))
                    Fim = ft(ptempo("Fim"))
                    Tempo = datediff("n", Inicio, Fim)
                    TempoTotal = TempoTotal + Tempo
                ptempo.movenext
                wend
                ptempo.close
                set ptempo = nothing

            BarraGrade = BarraGrade & " <small> "& TempoTrab & "</small></div>"

            BarraGrade = BarraGrade & "<div style=""height:15px"" class=""progress progress-bar-grey no-margin progress-striped active"">"

                PrimeiroTempo=""
                TempoGrade = 0
                
                while not Horarios.eof
                    TemGrade = "S"
                    if Chegada="" then
                        Chegada = ft(Horarios("HoraDe"))
                    end if
                    if PrimeiroTempo="" then
                        PrimeiroTempo = datediff("n", ft("07:00"), ft(Horarios("HoraDe")))
                        BarraGrade = BarraGrade & "<div class=""progress-bar progress-bar-grey"" style=""width: "&cint(PrimeiroTempo *Fator)&"px""></div>"
                    else
                        BarraGrade = BarraGrade & "<div class=""progress-bar progress-bar-grey"" style=""width: "&cint(datediff("n", UltimoHorario, Horarios("HoraDe") ) *Fator)&"px""></div>"
                    end if
                    Tempo = datediff("n", Horarios("HoraDe"), Horarios("HoraA"))
                    BarraGrade = BarraGrade & "<div class=""progress-bar progress-bar-inverse"" style=""width: "&cint(Tempo *Fator)&"px""></div>"
                    UltimoHorario = Horarios("HoraA")
                    TempoGrade = TempoGrade + Tempo
                Horarios.movenext
                wend
                Horarios.close
                set Horarios = nothing

            BarraGrade = BarraGrade & " <small> &nbsp;"& TempoGrade & "</small></div>"

            if TempoTrab>=TempoGrade then
                BarraGrade = BarraGrade & "<script>$('.barra"&UsuarioID&"').removeClass('progress-bar-warning');</script>"
                BarraGrade = BarraGrade & "<script>$('.barra"&UsuarioID&"').addClass('progress-bar-success');</script>"
            end if
            if Chegou="N" and TemGrade="S" then
                if cdate(Chegada)<time() then
                    BarraGrade = BarraGrade & "<script>$('#livre"&UsuarioID&"').css('display', 'block');$('#livre"&UsuarioID&"').css('background-color', '#f00');$('#livre"&UsuarioID&"').html('ATRASADO');</script>"
                end if
            end if
        '    tempoTrab = tempoTrab &"<div class=""progress progress-striped active""><div class=""progress-bar progress-bar-purple"" style=""width: 35%""></div><div class=""progress-bar progress-bar-success"" style=""width: 35%""></div></div>" & PrimeiroTempo
        'end if


        if Exibicao="Status" then
            if Status="" then
                set vcaNULL = db.execute("select id from ponto where UsuarioID="&UsuarioID&" and isnull(Fim) and Data=curdate()")
                if not vcaNULL.eof then
                    Status = "<span class='pull-right label label-sm label-info arrowed-in arrowed-in-right'>Presente</span>"
                else
                    Status = "<span class='pull-right label label-sm label-danger arrowed-in arrowed-in-right'>Ausente</span>"
                end if
            end if
            tempoTrab = Status
        end if
        if Exibicao="strStatus" then
            if strStatus="" then
                set vcaNULL = db.execute("select id from ponto where UsuarioID="&UsuarioID&" and isnull(Fim) and Data=curdate()")
                if not vcaNULL.eof then
                    strStatus = "Presente"
                else
                    strStatus = "Ausente"
                end if
            end if
            tempoTrab = strStatus
        end if
        if Exibicao = "Grafico" then
            tempoTrab = BarraGrade
        end if
end function

private function statusPagto(AgendamentoID, PacienteID, Data, rdValorPlano, ValorPlano, StaID, ProcedimentoID, ProfissionalID)
    '0 = a definir
    '-1 = neutro (não sinalizar nada)
    '-2 = exclamação vermelha
    '1 = ok
    executados = ""
    aexecutar = ""
    if not isnull(StaID) and StaID<>"" and isnumeric(StaID) then
        StaID = ccur(StaID)
    end if
    'se nao tem paciente ou data, pega esses dados do agendamento
    if PacienteID="" or isnull(PacienteID) or Data="" or isnull(Data) or rdValorPlano="" or isnull(rdValorPlano) then
        set age = db.execute("select * from agendamentos where id="&treatvalzero(AgendamentoID))
        if not age.eof then
            PacienteID = age("PacienteID")
            Data = age("Data")
            rdValorPlano = age("rdValorPlano")
            ValorPlano = age("ValorPlano")
            StaID = age("StaID")
            ProcedimentoID = age("TipoCompromissoID")
            ProfissionalID = age("ProfissionalID")
        end if
    end if
    if AgendamentoID="" then
        set age = db.execute("select * from agendamentos where PacienteID="&treatvalzero(PacienteID)&" and Data="&mydatenull(Data))
        if not age.eof then
            PacienteID = age("PacienteID")
            Data = age("Data")
            rdValorPlano = age("rdValorPlano")
            ValorPlano = age("ValorPlano")
            StaID = age("StaID")
            ProcedimentoID = age("TipoCompromissoID")
            ProfissionalID = age("ProfissionalID")
        end if
    end if

    'variavel dos itens aexecutar

    if StaID=2 or StaID=3 or StaID=4 or StaID=5 or StaID=12 then

        if rdValorPlano="V" then
            Valor = ValorPlano
            ConvenioID = 0
        else
            Valor = valConvenio(ValorPlano, "", PacienteID, ProcedimentoID)
            ConvenioID = ValorPlano
        end if

        if Valor>0 then
            if StaID=4 or StaID=5 or StaID=12 then
                aexecutar = rdValorPlano &"|"& ProcedimentoID & "|" & ProfissionalID & "|" & ConvenioID &"|"& fn(Valor) &";"
            else
                executados = rdValorPlano &"|"& ProcedimentoID & "|" & ProfissionalID & "|" & ConvenioID &"|"& fn(Valor) &";"
            end if
        end if

        've se incrementa mais a lista de executados
        set ate = db.Execute("select ap.ProcedimentoID, ap.ValorPlano, ap.rdValorPlano, a.ProfissionalID, ap.ValorFinal from atendimentos a LEFT JOIN atendimentosprocedimentos ap on ap.AtendimentoID=a.id where a.PacienteID="&PacienteID&" and a.Data="&mydatenull(Data)&"")
        while not ate.eof
            ProcedimentoID = ate("ProcedimentoID")
            ProfissionalID = ate("ProfissionalID")
            ValorPlano = ate("ValorPlano")
            Valor = ate("ValorFinal")
            rdValorPlano = ate("rdValorPlano")
            if rdValorPlano="V" then
                ConvenioID = 0
            else
                ConvenioID = ValorPlano
            end if
            if Valor>0 then
                executados = executados & rdValorPlano &"|"& ProcedimentoID & "|" & ProfissionalID & "|" & ConvenioID &"|"& fn(Valor) &";"
            end if
        ate.movenext
        wend
        ate.close
        set ate=nothing

        'verifica os atendimentos particulares ->
        if instr(aexecutar, "V|") or instr(executados, "V|") then
            HaParticular = 1
            set ii = db.Execute("select ii.ItemID ProcedimentoID, ii.ProfissionalID, ifnull(ii.Quantidade * (ii.ValorUnitario+ii.Acrescimo-ii.Desconto), 0) ValorTotal, ifnull((select sum(Valor) from itensdescontados where ItemID=ii.id), 0) ValorPago from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID where ProfissionalID="&treatvalnull(ProfissionalID)&" and DataExecucao="& mydatenull(Data) &" and i.AccountID="&treatvalnull(PacienteID)&" and i.AssociationAccountID=3")
            while not ii.eof
                if ii("ValorPago")>=ii("ValorTotal") then
                    strItemPago = "V|"& ii("ProcedimentoID") &"|"& ii("ProfissionalID") &"|0|"& fn(ii("ValorTotal")) &";"
                    aexecutar = replace( aexecutar, strItemPago, "" )
                    executados = replace( executados, strItemPago, "" )
                end if
            ii.movenext
            wend
            ii.close
            set ii=nothing
        end if

 '       if HaParticular=1 then
 '           if instr(aexecutar, "V|")=0 and instr(executados, "V|")=0 then
 '               okParticular = 1
 '           else
 '               okParticular = 0
 '           end if
 '       else
 '           okParticular = 1
 '       end if
        '<-
        'verifica os atendimentos de convênio ->
        '    response.Write("alert('"&aexecutar&" \n "&executados&"');")
        if instr(aexecutar, "P|") or instr(executados, "P|") then
            HaConvenio = 1
            set gcons = db.Execute("select gc.ProcedimentoID, gc.ProfissionalID, gc.ProfissionalEfetivoID, gc.ValorProcedimento, gc.ConvenioID from tissguiaconsulta gc where gc.PacienteID="&treatvalnull(PacienteID)&" and gc.DataAtendimento="&mydatenull(Data)&_ 
            " UNION ALL "&_
            " select gis.ProcedimentoID, gis.ProfissionalID, NULL, gis.ValorTotal, gs.ConvenioID from tissguiasadt gs left join tissprocedimentossadt gis on gis.GuiaID=gs.id where gs.PacienteID="&treatvalnull(PacienteID)&" and gis.Data="&mydatenull(Data))
            while not gcons.eof
                if isnull(gcons("ProfissionalEfetivoID")) or gcons("ProfissionalEfetivoID")=0 then
                    ProfissionalID = gcons("ProfissionalID")
                else
                    gcons("ProfissionalEfetivoID")
                end if
                strItemPago = "P|"& gcons("ProcedimentoID") &"|"& ProfissionalID &"|"& gcons("ConvenioID") &"|"& fn(gcons("ValorProcedimento")) &";"
                aexecutar = replace( aexecutar, strItemPago, "" )
                executados = replace( executados, strItemPago, "" )
            gcons.movenext
            wend
            gcons.close
            set gcons=nothing
        end if


        if HaParticular=1 or HaConvenio=1 then
            if aexecutar="" and executados="" then
                statusPagto = 1
            else
                statusPagto = -2
            end if
        else
            okParticular = 1
        end if
        '<-

    else
        statusPagto = -1
    end if

    db_execute("update agendamentos set FormaPagto="& treatvalzero(statusPagto) &" where PacienteID="&treatvalnull(PacienteID)&" and Data="&mydatenull(Data))
            'faz uma variavel $aexecutar e $executados
    

    'se esse procedimento desse agendamento é pago, coloca na lista de procedimentos que devem ser cobrados

    'incrementa a lista de procedimentos que devem ser cobrados com os atendimentos desse paciente pra esse dia

    'se estiver como aguardando, verifica os lancamentos feitos desse paciente para esse dia
end function

function sinalAgenda(val)
    sinalAgenda = ""
    if not isnull(val) and isnumeric(val) and val<>"" then
        val = ccur(val)
        select case val
            case -2
                sinalAgenda = "<i class=""fa fa-exclamation-circle text-danger""></i>"
            case 1
                sinalAgenda = "<i class=""fa fa-check-circle-o text-success""></i>"
        end select
    end if
end function

Function TirarAcento(Palavra)
CAcento = "àáâãäèéêëìíîïòóôõöùúûüÀÁÂÃÄÈÉÊËÌÍÎÒÓÔÕÖÙÚÛÜçÇñÑ"
SAcento = "aaaaaeeeeiiiiooooouuuuAAAAAEEEEIIIOOOOOUUUUcCnN"
Texto = ""
If Palavra <> "" then
        For X = 1 To Len(Palavra)
               Letra = Mid(Palavra,X,1)
               Pos_Acento = InStr(CAcento,Letra)
               If Pos_Acento > 0 Then Letra = mid(SAcento,Pos_Acento,1)
               Texto = Texto & Letra
        Next
        TirarAcento = Texto
End If
End Function  
Function TrocarAcento(Palavra)
CAcento = "àáâãäèéêëìíîïòóôõöùúûüÀÁÂÃÄÈÉÊËÌÍÎÒÓÔÕÖÙÚÛÜçÇñÑ"
Texto = ""
If Palavra <> "" Then
        For X = 1 to Len(Palavra)
               Letra = Mid(Palavra,X,1)
               Pos_Acento = InStr(CAcento,Letra)
              If Pos_Acento > 0 Then Letra = "_"
             Texto = Texto & Letra
        Next
      TrocarAcento = Texto
End If
End Function

function agendaOcupacoes(ProfissionalID, Data) 
	set ocup = db.execute("select * from agendaocupacoes where ProfissionalID="&ProfissionalID&" and month(Data)="&month(Data)&" and year(Data)="&year(Data)&" order by Data")
	while not ocup.eof
		oHLivres = ocup("HLivres")
		oHAgendados = ocup("HAgendados")
		oHBloqueados = ocup("HBloqueados")
		oTotais = oHLivres+oHAgendados+oHBloqueados
		if oTotais=0 then
			percOcup=100
			percLivre = 0
		else
			oFator = 100 / oTotais
			percOcup = cInt( oFator* (oHAgendados+oHBloqueados) )
			percLivre = cInt( oFator* oHLivres )
		end if
		%>
		$("#prog<%=replace(ocup("Data"), "/", "")%>").html('<% If percOcup>0 Then %><div class="progress-bar progress-bar-danger" style="width: <%=percOcup%>%;"></div><% End If %><%if percLivre>0 then%><div class="progress-bar progress-bar-success" style="width: <%=percLivre%>%;"></div><% End If %>');
		<%
	ocup.movenext
	wend
	ocup.close
	set ocup = nothing
end function

function bdg(div, valor)
    if valor="0" then
        valor = ""
    end if
    bdg = "$('#"& div &"').html('"& valor &"');"
end function

function odonto()
    if session("Odonto")="" then
        EspecialidadesOdonto = "154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 238, 239, 240, 241, 242, 243, 244, 245"
        set vcaOdonto = db.execute("select p.EspecialidadeID from profissionais p LEFT JOIN profissionaisespecialidades e on e.ProfissionalID=p.id WHERE p.EspecialidadeID IN("& EspecialidadesOdonto &") or e.EspecialidadeID IN ("& EspecialidadesOdonto &")")
        if NOT vcaOdonto.EOF then
            session("Odonto")=1
        end if
    end if
end function

function btnSalvar(id)
    btnSalvar = "<button class='btn btn-block btn-primary hidden' id='save'><i class='fa fa-save'></i>Salvar</button>"&_
    "<script type='text/javascript'>"&_
        "$('#rbtns').html('<a onclick=""$(\'#"&id&"\').click()"" class=""btn btn-sm btn-success"" type=""button""><i class=""fa fa-save""></i> Salvar</a>');"&_
    "</script>"
end function


function getEspera(Profissionais)
    splProfs = split(Profissionais, ",")
    for y=0 to ubound(splProfs)
        eProfissional = trim(splProfs(y))
        if eProfissional<>"" then
            if eProfissional<>"0" then
                db_execute("update sys_users set Espera = (select count(id) total from agendamentos where Data=curdate() and StaID IN (4) and ProfissionalID="& eProfissional &") where `Table`='profissionais' and `idInTable`="& eProfissional )
            end if
        end if
    next


    set esperaT = db.execute("select UnidadeID, count(UnidadeID) EsperaTotal from (select ifnull(l.UnidadeID, 0) UnidadeID, ifnull(a.ProfissionalID, 0) ProfissionalID from agendamentos a left join locais l on a.LocalID=l.id where Data=curdate() and StaID=4 order by l.UnidadeID) t group by UnidadeID")
    while not esperaT.eof
        esperaTotal = esperaTotal & "|"& esperaT("UnidadeID") &", "& EsperaT("EsperaTotal") &"|"
    esperaT.movenext
    wend
    esperaT.close
    set esperaT=nothing    

    set esperaV = db.execute("select UnidadeID, count(UnidadeID) EsperaVazia from (select ifnull(l.UnidadeID, 0) UnidadeID, ifnull(a.ProfissionalID, 0) ProfissionalID from agendamentos a left join locais l on a.LocalID=l.id where Data=curdate() and StaID=4 and ProfissionalID=0 order by l.UnidadeID) t group by UnidadeID")
    while not esperaV.eof
        esperaVazia = esperaVazia & "|"& esperaV("UnidadeID") &", "& EsperaV("EsperaVazia") &"|"
    esperaV.movenext
    wend
    esperaV.close
    set esperaV=nothing    

    db_execute("update sys_users set EsperaTotal='"&EsperaTotal&"'")
    db_execute("update sys_users set EsperaVazia='"&EsperaVazia&"'")
            
end function

function plural(qtd, singular)
    select case singular
        case ""
            plural = "s"
        case "al"
            plural = "ais"
    end select
    if qtd<=1 then
        plural = singular
    end if
end function

private function corPago(classe_cor, valorItem, valorPago)
        if valorPago>=valorItem or valorItem=0 then
            cor = "green"
            classe = "success"
        elseif valorPago=0 then
            cor = "#f00"
            classe = "danger"
        else
            cor = "orange"
            classe = "warning"
        end if
    if classe_cor="classe" then
        corPago = classe
    end if
end function

function imoon(nome)
    tamanho = 17
    select case nome
        case 1
            icone = "question-circle"
            cor = "alert"
            fornecedor = "fa"
            tamanho = 20
        case 2
            icone = "play2"
            cor = "system"
            fornecedor = "imoon"
        case 3
            icone = "happy2"
            cor = "success"
            fornecedor = "imoon"
        case 4
            icone = "neutral2"
            cor = "warning"
            fornecedor = "imoon"
        case 5
            icone = "volume-up"
            cor = "primary"
            fornecedor = "fa"
        case 6
            icone = "wondering2"
            cor = "danger"
            fornecedor = "imoon"
        case 7, 9, 10
            icone = "grin2"
            cor = "warning"
            fornecedor = "imoon"
        case 8
            icone = "eye"
            cor = "primary"
            fornecedor = "fa"
        case 11
            icone = "minus-circle"
            cor = "danger"
            fornecedor = "fa"
            tamanho = 20
        case 12
            icone = "arrow-right3"
            cor = "primary"
            fornecedor = "imoon"
        case 15
            icone = "refresh"
            cor = "info"
            fornecedor = "fa"
            tamanho = 18
        case 16
            icone = "cancel-circle"
            cor = "dark"
            fornecedor = "imoon"
    end select
    imoon = "<span class="""&fornecedor &" "& fornecedor &"-"& icone & " text-"& cor &""" style=""font-size:"& tamanho &"px""></span>"
end function
%>