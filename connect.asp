<!--#include file="functions.asp"-->
<!--#include file="Classes/Connection.asp"-->

<%
Session.Timeout=600
session.LCID=1046
if session("Servidor")="" then
    sServidor = "localhost"
else
    sServidor = session("Servidor")
end if
set db = newConnection(session("Banco"), sServidor)
'db.Open ConnString
LicenseID=replace(session("Banco"), "clinic", "")
PorteClinica = session("PorteClinica") 

if PorteClinica="" then
    set LicencaSQL = db.execute("select COALESCE(PorteClinica,-1) PorteClinica FROM cliniccentral.licencas WHERE id="&treatvalzero(LicenseId))
    if not LicencaSQL.eof then
        PorteClinica = ccur(LicencaSQL("PorteClinica"))
        session("PorteClinica")= PorteClinica
        PorteClinica = PorteClinica
    end if
end if

function permissoesPadrao()
'	permissoesPadrao = "chatI, contatosV, contatosI, contatosA, contatosX, sys_financialcurrentaccountsV, sys_financialcurrentaccountsI, sys_financialcurrentaccountsA, sys_financialcurrentaccountsX, formasrectoV, formasrectoI, formasrectoA, formasrectoX, origensV, origensI, origensA, origensX, contasapagarV, contasapagarI, contasapagarA, contasapagarX, contasareceberV, contasareceberI, contasareceberA, contasareceberX, contratadoexternoV, contratadoexternoI, contratadoexternoA, contratadoexternoX, fornecedoresV, fornecedoresI, fornecedoresA, fornecedoresX, funcionariosV, funcionariosI, funcionariosA, funcionariosX, locaisgruposV, locaisgruposI, locaisgruposA, locaisgruposX, lancamentosV, lancamentosI, lancamentosA, lancamentosX, locaisV, locaisI, locaisA, locaisX, movementV, movementI, movementA, movementX, orcamentosV, orcamentosI, orcamentosA, orcamentosX, pacotesV, pacotesI, pacotesA, pacotesX, procedimentosV, procedimentosI, procedimentosA, procedimentosX, profissionalexternoV, profissionalexternoI, profissionalexternoA, profissionalexternoX, tabelasV, tabelasI, tabelasA, tabelasX, sys_financialexpensetypeV, sys_financialexpensetypeI, sys_financialexpensetypeA, sys_financialexpensetypeX, sys_financialincometypeV, sys_financialincometypeI, sys_financialincometypeA, sys_financialincometypeX, sys_financialcompanyunitsV, sys_financialcompanyunitsI, sys_financialcompanyunitsA, sys_financialcompanyunitsX, buiformsV, buiformsI, buiformsA, buiformsX, chamadaporvozA, configconfirmacaoA, configrateioV, configrateioI, configrateioA, configrateioX, emailsV, emailsI, emailsA, emailsX, configimpressosV, configimpressosA, produtoscategoriasV, produtoscategoriasI, produtoscategoriasA, produtoscategoriasX, produtosfabricantesV, produtosfabricantesI, produtosfabricantesA, produtosfabricantesX, lctestoqueV, lctestoqueI, lctestoqueA, lctestoqueX, produtoslocalizacoesV, produtoslocalizacoesI, produtoslocalizacoesA, produtoslocalizacoesX, produtosV, produtosI, produtosA, produtosX, conveniosV, conveniosI, conveniosA, conveniosX, faturasV, guiasV, guiasI, guiasA, guiasX, conveniosplanosV, conveniosplanosI, conveniosplanosA, conveniosplanosX, repassesV, repassesI, repassesA, repassesX, formsaeV, formsaeI, formsaeA, arquivosV, arquivosI, arquivosA, arquivosX, atestadosV, atestadosI, atestadosA, atestadosX, pacientesV, pacientesI, pacientesA, pacientesX, historicopacienteV, contapacV, contapacI, contapacX, areceberpacienteV, areceberpacienteI, areceberpacienteA, areceberpacienteX, diagnosticosV, diagnosticosI, diagnosticosA, diagnosticosX, envioemailsI, imagensV, imagensI, imagensA, imagensX, formslV, formslI, formslA, pedidosexamesV, pedidosexamesI, pedidosexamesX, prescricoesV, prescricoesI, prescricoesA, prescricoesX, recibosV, recibosI, recibosA, recibosX, agendaV, agendaI, agendaA, agendaX, horariosV, horariosA, contaprofV, contaprofI, contaprofX, profissionaisV, profissionaisI, profissionaisA, profissionaisX, relatoriosestoqueV, relatoriosfinanceiroV, relatoriospacienteV, chamadatxtV, chamadavozV, senhapA, usuariosI, usuariosA, usuariosX, bloqueioagendaV, bloqueioagendaA, bloqueioagendaI, bloqueioagendaX, ageoutunidadesV, ageoutunidadesA, ageoutunidadesI, ageoutunidadesX, relatoriosfaturamentoV, relatoriosfaturamentoV, relatoriosagendaV"
	permissoesPadrao = "|ageoutunidadesV|, |ageoutunidadesI|, |ageoutunidadesA|, |ageoutunidadesX|, |agendaV|, |agendaI|, |agendaA|, |agendaX|, |bloqueioagendaV|, |bloqueioagendaI|, |bloqueioagendaA|, |bloqueioagendaX|, |horariosV|, |horariosA|, |historicopacienteV|, |chatI|, |contatosV|, |contatosI|, |contatosA|, |contatosX|, |sys_financialcurrentaccountsV|, |sys_financialcurrentaccountsI|, |sys_financialcurrentaccountsA|, |sys_financialcurrentaccountsX|, |formasrectoV|, |formasrectoI|, |formasrectoA|, |formasrectoX|, |origensV|, |origensI|, |origensA|, |origensX|, |contasapagarV|, |contasapagarI|, |contasapagarA|, |contasapagarX|, |contasareceberV|, |contasareceberI|, |contasareceberA|, |contasareceberX|, |contratadoexternoV|, |contratadoexternoI|, |contratadoexternoA|, |contratadoexternoX|, |fornecedoresV|, |fornecedoresI|, |fornecedoresA|, |fornecedoresX|, |funcionariosV|, |funcionariosI|, |funcionariosA|, |funcionariosX|, |locaisgruposV|, |locaisgruposI|, |locaisgruposA|, |locaisgruposX|, |lancamentosV|, |lancamentosI|, |lancamentosA|, |lancamentosX|, |locaisV|, |locaisI|, |locaisA|, |locaisX|, |movementV|, |movementI|, |movementA|, |movementX|, |orcamentosV|, |orcamentosI|, |orcamentosA|, |orcamentosX|, |pacotesV|, |pacotesI|, |pacotesA|, |pacotesX|, |procedimentosV|, |procedimentosI|, |procedimentosA|, |procedimentosX|, |profissionalexternoV|, |profissionalexternoI|, |profissionalexternoA|, |profissionalexternoX|, |tabelasV|, |tabelasI|, |tabelasA|, |tabelasX|, |sys_financialexpensetypeV|, |sys_financialexpensetypeI|, |sys_financialexpensetypeA|, |sys_financialexpensetypeX|, |sys_financialincometypeV|, |sys_financialincometypeI|, |sys_financialincometypeA|, |sys_financialincometypeX|, |sys_financialcompanyunitsV|, |sys_financialcompanyunitsI|, |sys_financialcompanyunitsA|, |sys_financialcompanyunitsX|, |buiformsV|, |buiformsI|, |buiformsA|, |buiformsX|, |chamadaporvozA|, |configconfirmacaoA|, |configrateioV|, |configrateioI|, |configrateioA|, |configrateioX|, |emailsV|, |emailsI|, |emailsA|, |emailsX|, |configimpressosV|, |configimpressosA|, |produtoscategoriasV|, |produtoscategoriasI|, |produtoscategoriasA|, |produtoscategoriasX|, |produtosfabricantesV|, |produtosfabricantesI|, |produtosfabricantesA|, |produtosfabricantesX|, |lctestoqueV|, |lctestoqueI|, |lctestoqueA|, |lctestoqueX|, |produtoslocalizacoesV|, |produtoslocalizacoesI|, |produtoslocalizacoesA|, |produtoslocalizacoesX|, |produtosV|, |produtosI|, |produtosA|, |produtosX|, |conveniosV|, |conveniosI|, |conveniosA|, |conveniosX|, |faturasV|, |guiasV|, |guiasI|, |guiasA|, |guiasX|, |conveniosplanosV|, |conveniosplanosI|, |conveniosplanosA|, |conveniosplanosX|, |repassesV|, |repassesI|, |repassesA|, |repassesX|, |formsaeV|, |formsaeI|, |formsaeA|, |arquivosV|, |arquivosI|, |arquivosA|, |arquivosX|, |atestadosV|, |atestadosI|, |atestadosA|, |atestadosX|, |pacientesV|, |pacientesI|, |pacientesA|, |pacientesX|, |contapacV|, |contapacI|, |contapacX|, |areceberpacienteV|, |areceberpacienteI|, |areceberpacienteA|, |areceberpacienteX|, |diagnosticosV|, |diagnosticosI|, |diagnosticosA|, |diagnosticosX|, |envioemailsI|, |imagensV|, |imagensI|, |imagensA|, |imagensX|, |formslV|, |formslI|, |formslA|, |pedidosexamesV|, |pedidosexamesI|, |pedidosexamesX|, |prescricoesV|, |prescricoesI|, |prescricoesA|, |prescricoesX|, |recibosV|, |recibosI|, |recibosA|, |recibosX|, |contaprofV|, |contaprofI|, |contaprofX|, |profissionaisV|, |profissionaisI|, |profissionaisA|, |profissionaisX|, |relatoriosagendaV|, |relatoriosestoqueV|, |relatoriosfaturamentoV|, |relatoriosfinanceiroV|, |relatoriospacienteV|, |chamadatxtV|, |chamadavozV|, |senhapA|, |usuariosI|, |usuariosA|, |usuariosX|, |agestafinA|, |agestafinX|, |agehorantI|, |altunirectoA|, |localagendaS|, |vacinapacienteV|, |vacinapacienteI|, |vacinapacienteX|"
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
			AgendamentoStatusID = age("StaID")

			if AgendamentoStatusID=1  then
                if not pac.eof then
                    NomePaciente = trim(pac("NomePaciente"))
                    if instr(NomePaciente, " ") then
                        splPac = split(NomePaciente, " ")
                        NomePaciente = splPac(0)
                    end if
                end if
                set pro = db.execute("select * from profissionais where id="&age("ProfissionalID"))
                if not pro.EOF then
                    set Trat = db.execute("select * from tratamento where id = '"&pro("TratamentoID")&"'")
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


                if instr(Mensagem, "[TipoProcedimento]") then
                    set proc = db.execute("select p.NomeProcedimento,t.TipoProcedimento from procedimentos p LEFT JOIN tiposprocedimentos t ON t.id=p.TipoProcedimentoID where p.id="&age("TipoCompromissoID"))
                    if not proc.eof then
                        TipoProcedimento = trim(proc("TipoProcedimento"))
                    end if
                end if

                Mensagem = replace(Mensagem, "[TipoProcedimento]", TipoProcedimento)
                Mensagem = replace(Mensagem, "[NomePaciente]", NomePaciente)
                Mensagem = replace(Mensagem, "[TratamentoProfissional]", "")
                Mensagem = replace(Mensagem, "[NomeProfissional]", NomeProfissional)
                Mensagem = replace(Mensagem, "[HoraAgendamento]", formatdatetime( hour(age("Hora"))&":"&minute(age("Hora")) , 4) )
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
	end if
end function

function zEsq(Val, Quant)
	while len(Val)<Quant
		Val = "0"&Val
  wend
  zEsq = Val
  end function


private function quantidadeEstoqueVELHO(ProdutoID, Lote, Validade)
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

private function quantidadeEstoqueIMPORT(ProdutoID, Lote, Validade, UltimoID)
	if isdate(Validade) then sqlValidade="Validade="&mydatenull(Validade) else sqlValidade="isnull(Validade)" end if
'	response.Write("select * from estoquelancamentos where ProdutoID="&ProdutoID&" and Lote like '"&Lote&"' and Validade like '"&Validade&"'")
	set quant = db.execute("select * from estoquelancamentos where ProdutoID="&ProdutoID&" and Lote like '"&Lote&"' and id<"&UltimoID&" and isnull(PosicaoE) and "&sqlValidade)
	quantidadeEstoqueIMPORT = 0
	while not quant.eof
		if quant("EntSai")="E" then
			quantidadeEstoqueIMPORT = quantidadeEstoqueIMPORT+quant("QuantidadeTotal")
		else
			quantidadeEstoqueIMPORT = quantidadeEstoqueIMPORT-quant("QuantidadeTotal")
		end if
	quant.movenext
	wend
	quant.close
	set quant = nothing
end function


function quantidadeEstoque(PosicaoID)
    if PosicaoID&""<>"" then
        set quant = db.execute("select ifnull(p.ApresentacaoQuantidade, 1) ApresentacaoQuantidade, ep.Quantidade, ep.TipoUnidade FROM estoqueposicao ep LEFT JOIN produtos p ON p.id=ep.ProdutoID WHERE ep.id="&PosicaoID)
        if not quant.eof then
            if quant("TipoUnidade")="C" then
                quantidadeEstoque = quant("ApresentacaoQuantidade") * quant("Quantidade")
            else
                quantidadeEstoque = quant("Quantidade")
            end if
        end if
    else
        quantidadeEstoque = 0
    end if
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
				set Trat = db.execute("select * from tratamento where id = '"&pro("TratamentoID")&"'")
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
			Mensagem = replace(Mensagem, "[HoraAgendamento]", formatdatetime( hour(age("Hora"))&":"&minute(age("Hora"))&":"&second(age("Hora")),4 ) )
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

function gravaChamada(rfProfissionalID, rfPaciente, UnidadeID)
	sql = "select * from sys_chamadaporvoz"
	set configChamada = db.execute(sql)
	if configChamada.eof then
		db_execute("insert into sys_chamadaporvoz (Texto, Sexo, Usuarios) values ('[TratamentoProfissional] [NomeProfissional] chama paciente [NomePaciente] para atendimento', '2', 'ALL')")
		set configChamada = db.execute(sql)
	end if
	if instr(configChamada("Usuarios"), "ALL") then
		db_execute("update sys_users set chamar='"&rfProfissionalID&"_"&rfPaciente&"' where (UnidadeID="&treatvalnull(UnidadeID)&" or UnidadeID IS NULL)")
	else
		spl = split(configChamada("Usuarios"), "|")
		for i=0 to ubound(spl)
			if isnumeric(spl(i)) then
				db_execute("update sys_users set chamar='"&rfProfissionalID&"_"&rfPaciente&"' where id="&spl(i)&" AND (UnidadeID="&treatvalnull(UnidadeID)&" or UnidadeID IS NULL)")
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

function treatValNULLFormat(Val,Number)
	if isnumeric(Val) and Val<>"" then
		Val = formatnumber(Val,Number)
		Val = replace(Val, ".", "")
		treatValNULLFormat = replace(Val, ",", ".")
	else
		treatValNULLFormat = "NULL"
	end if
end function


function myDateWithDefault(Val,DefaultDate)
	if isDate(Val) and Val<>"" then
		myDateWithDefault = year(Val)&"-"&month(Val)&"-"&day(Val)
	else
		myDateWithDefault = DefaultDate
	end if
end function


function myDate(Val)
	if isDate(Val) and Val<>"" then
		myDate = year(Val)&"-"&zeroesq(month(Val), 2)&"-"& zeroEsq(day(Val), 2)
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
		myDateNULL = "'"&year(Val)&"-"& zeroEsq(month(Val), 2) &"-"& zeroEsq(day(Val), 2) &"'"
		'myDateNULL = "'"&year(Val)&"-"& month(Val) &"-"& day(Val) &"'"
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
		<select id="<%= id %>" name="<%= id %>" class="form-control" data-placeholder="Selecione"<%= others %>>
			<option value="">SELECIONAR NO LANÇAMENTO</option>
			<%
			set caixas = db.execute("select * from caixa where isnull(dtFechamento) and 1=2")
			while not caixas.eof
				%>
                <option value="7_<%=caixas("id")%>"<% If selectedValue="7_"&caixas("id") Then %> selected="selected"<% End If %>><%= caixas("Descricao") %></option>
				<%
			caixas.movenext
			wend
			caixas.close
			set caixas=nothing
			for iiiiii=0 to uBound(splAssociations)
				if splAssociations(iiiiii)="0" then
					%>
					<option value="0"<% If selectedValue="0" Then %> selected="selected"<% End If %>>POSIÇÃO (EMPRESA)</option>
                    <option value="PRO"<% If selectedValue="PRO" Then %> selected="selected"<% End If %>>PROFISSIONAL EXECUTOR</option>
                    <option value="LAU"<% If selectedValue="LAU" Then %> selected="selected"<% End If %>>PROFISSIONAL LAUDADOR</option>
                    <option value="SOL"<% If selectedValue="SOL" Then %> selected="selected"<% End If %>>PROFISSIONAL SOLICITANTE</option>
					<%
				elseif splAssociations(iiiiii)="00" then
					%>
					<option value="0"<% If selectedValue="0" Then %> selected="selected"<% End If %>>Posi&ccedil;&atilde;o (Empresa)</option>
					<%
				else
					set Associations = db.execute("select * from cliniccentral.sys_financialaccountsAssociation where id="&splAssociations(iiiiii))
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

function simpleSelectCurrentAccountsFilterOption(id, associations, selectedValue, others,procedimento)

    IF procedimento = "" OR procedimento = "0" THEN
        call simpleSelectCurrentAccounts(id,associations,selectedValue,others,"")
        exit function
    END IF

	splAssociations = split(associations,", ")
	%>
		<select class="form-control select2-single" id="<%= id %>" name="<%= id %>"<%= others %>>
			<option value="">&nbsp;</option>
			<%


			set procedimentoItem = db.execute("SELECT COALESCE(NULLIF(SomenteEspecialidades,''),'|-123|') SomenteEspecialidades, COALESCE(NULLIF(SomenteProfissionais,''),'|-123|') SomenteProfissionais,COALESCE(NULLIF(SomenteFornecedor,''),'|-123|') SomenteFornecedor,COALESCE(NULLIF(SomenteProfissionaisExterno,''),'|-123|') SomenteProfissionaisExterno,OpcoesAgenda FROM procedimentos WHERE id = "&procedimento)

			SomenteProfissionais        = ""
			SomenteFornecedor           = ""
			SomenteProfissionaisExterno = ""
			SomenteEspecialidades       = ""

			IF procedimentoItem("OpcoesAgenda")&"" = "4" THEN
                SomenteProfissionais  = procedimentoItem("SomenteProfissionais")
                set procedimentosExec = db.execute("SELECT coalesce(GROUP_CONCAT('|',id_profissional,'|'),'|-123|') as SomenteProfissionais FROM procedimento_profissional_unidade WHERE id_procedimento = "&procedimento&" AND id_unidade = "&session("UnidadeID")&";")

                IF NOT procedimentosExec.EOF THEN
                    SomenteProfissionais = procedimentosExec("SomenteProfissionais")
                END IF

                SomenteFornecedor           = procedimentoItem("SomenteFornecedor")
                SomenteProfissionaisExterno = procedimentoItem("SomenteProfissionaisExterno")
                SomenteEspecialidades       = procedimentoItem("SomenteEspecialidades")
			END IF

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
                        sqlFilter = ""
					    sqlAsso = Associations("sql")

					    IF splAssociations(t) = "5" THEN

					        sqlFilter = "where "&franquiaUnidade(" (id IN (SELECT ProfissionalID FROM profissionais_unidades WHERE UnidadeID IN ("&session("unidadeID")&"))OR NULLIF(Unidades,'') IS NULL) AND ")

					        IF SomenteEspecialidades&"" <> "" THEN
					            SomenteEspecialidades = decodeArrayPipe(SomenteEspecialidades)

                                sqlSomenteEspecialidades = " or id in ((SELECT prof.id ID                                                                                              "&chr(13)&_
                                                           "        FROM profissionais prof                                                                                 "&chr(13)&_
                                                           " LEFT JOIN profissionaisespecialidades pe ON pe.id=prof.id                                                      "&chr(13)&_
                                                           " WHERE (pe.EspecialidadeID IN ("&SomenteEspecialidades&") OR prof.EspecialidadeID IN ("&SomenteEspecialidades&"))) )"
					        END IF

					        IF SomenteProfissionais&"" <> "" AND SomenteEspecialidades&"" <> "" THEN
					            sqlFilter = sqlFilter&" ( '"&SomenteProfissionais&"' like CONCAT('%|',id,'|%') "&sqlSomenteEspecialidades&" ) AND "
					        END IF

					        IF SomenteProfissionais&"" <> "" AND SomenteEspecialidades&"" = "" THEN
                                sqlFilter = sqlFilter&" ( '"&SomenteProfissionais&"' like CONCAT('%|',id,'|%') ) AND "
                            END IF

                            sqlAsso = Replace(sqlAsso, "where ",sqlFilter)
                        END IF

                        IF  splAssociations(t) = "2" THEN
                            sqlFilter = "where "&franquiaUnidade(" Unidades like '%|"&session("UnidadeID")&"|%' AND ")

                            IF SomenteFornecedor&"" <> "" THEN
                                sqlFilter = sqlFilter&" '"&SomenteFornecedor&"' like CONCAT('%|',id,'|%') AND "
                            END IF

                            sqlAsso = Replace(sqlAsso, "where ",sqlFilter)
                        END IF

                        IF  splAssociations(t) = "8" THEN
                            sqlFilter = "where "&franquiaUnidade(" "&franquiaUnidade(" COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),false) AND "))

                            IF SomenteProfissionaisExterno&"" <> "" THEN
                                sqlFilter = sqlFilter&" '"&SomenteProfissionaisExterno&"' like CONCAT('%|',id,'|%') AND "
                            END IF

                            sqlAsso = Replace(sqlAsso, "where ",sqlFilter)
                        END IF

					    IF splAssociations(t) = "4" THEN
					        sqlFilter = "where "&franquiaUnidade(" "&franquiaUnidade(" COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),false) AND "))
                            sqlAsso = Replace(sqlAsso, "where ",sqlFilter)
					    END IF

                        IF splAssociations(t) = "1" THEN
                            sqlAsso = Replace(sqlAsso, "where ", "WHERE "&franquiaUnidade(" COALESCE(cliniccentral.overlap(concat('|',Empresa,'|'),COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE) and "))
                        END IF

						set AssRegs = db.execute(sqlAsso&" limit 10000")
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


function simpleSelectCurrentAccounts(id, associations, selectedValue, others, selectText)
	splAssociations = split(associations,", ")
	%>
		<select class="form-control select2-single" id="<%= id %>" name="<%= id %>"<%= others %>>
			<option value=""><%=selectText%> &nbsp;</option>
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
                        sqlAssociation = Associations("sql")&" limit 10000"
                        'casos de profissional excluido
                        if selectedValue&""<>"" then
                            sqlAssociation = replace(sqlAssociation, "where", " where (concat('"&Associations("id")&"_',ID)='"&selectedValue&"') OR ")
                        end if
						set AssRegs = db.execute(sqlAssociation)
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
        <i class="far fa-search"></i>
    </span>
    <input type="text" placeholder="Digite..." class="form-control" id="search<%=name%>" name="search<%=name%>" value="<%=textValue%>" autocomplete="off" <%= othersToInput %>>
</div>
	</span>
	<div id="resultSelect<%=name%>" style="position:absolute; display:none; overflow:hidden; background-color:#fff; z-index:1000;" class="ResultSelectContent">
    	<i class="far fa-circle-o-notch fa-spin fa-fw"></i> Buscando...
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
		$("#resultSelect<%=name%>").html("<i class='far fa-circle-o-notch fa-spin fa-fw'></i> Buscando...");
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
				fotoInTable = "uploads/"& replace(session("Banco"), "clinic", "") &"/Perfil/"&goTable("Foto")
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

    if device()="Android" or (device()<>"" and lcase(fieldType)="datepicker") then 'máscara não funciona no android
        sqlOrClass = replace(sqlOrClass&"", "input-mask-", "")
    end if

	if instr(Omitir, "|"&lcase(fieldName)&"|")>0 then
		OmitirCampo = " hidden"
	else
		OmitirCampo = ""
	end if
	if label<>"" then
        if instr(additionalTags, "required")>0 then
            ast = " *"
        else
            ast = ""
        end if
		abreDivBoot = "<div class=""col-md-"&width&OmitirCampo&" qf"" id=""qf"&lcase(fieldName)&""">"
		fechaDivBoot = "</div>"
		if label=" " then
			LabelFor = ""
		else
			LabelFor = "<label for="""&fieldName&""">"&label & ast&"</label><br />"
		end if
    else
		abreDivBoot = ""
		fechaDivBoot = ""
		LabelFor = ""
	end if

	response.Write(abreDivBoot)
        if (fieldType="memo" or fieldType="editor") and instr(lcase(request.ServerVariables("HTTP_USER_AGENT")), "chrome")>0 then
%>
            <button type="button" onclick="mdSpee('<%=fieldName %>')" id="spee<%=fieldName %>" class="btn btn-xs btn-record btn-danger btn-rounded pull-right btn-spee"><i class="fas fa-microphone"></i></button>

<%
    end if
    select case fieldType
		case "text"
			response.Write(LabelFor)
			%>
			<input type="text" class="form-control <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>" value="<%=fieldValue%>"<%=additionalTags%> />
			<%
		case "CPF"
			response.Write(LabelFor)
			%>
			<div class="input-group">
                <input type="text" class="form-control <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>" value="<%=fieldValue%>"<%=additionalTags%> />

                <span class="input-group-addon">
                   <div class="checkbox-custom checkbox-warning">
                        <input id="SemCPF-<%=fieldName%>" name="SemCPF" type="checkbox" class="ace" onchange="$('#<%=fieldName%>').attr('required', !$(this).is(':checked')).attr('readonly', $(this).is(':checked'))"  style="font-size: 10px"/>

                        <label class="checkbox" for="SemCPF-<%=fieldName%>" style="color: #000!important; padding-top: 6px; margin-right: 0px!important; ;font-weight: 500; font-size: 9px;margin-bottom: 0!important;margin-top: 0!important;">Sem CPF</label>
                    </div>
                </span>
            </div>

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
				icone = "envelope"
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
            if session("DDDAuto")<>"" then
                DDDAuto=session("DDDAuto")
            end if

            if fieldValue&""="" and DDDAuto<>"" and fieldType<>"email" then
                fieldValue="("&DDDAuto&") "
            end if

			response.Write(LabelFor)
			%>
            <div class="input-group">
                <span class="input-group-addon">
                    <%
					if session("OtherCurrencies")="phone" then
						%>
                        <a href="callto:0<%=fieldValue%>"><i class="far fa-<%= icone %> bigger-110"></i></a>
                        <%
					else
						%>
 	                   <i class="far fa-<%= icone %> bigger-110"></i>
						<%
					end if
					%>
                </span>
                <%if device()<>"Android" then %>
                <input type="text" placeholder="" value="<%=fieldValue%>" class="form-control<%=mask%> <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>" maxlength="150"<%=additionalTags%> />
                <%else %>
                <input type="<% if fieldType="phone" or fieldType="mobile" then %>tel<% else %>text<% end if %>" placeholder="" value="<%=fieldValue%>" class="form-control <%=sqlOrClass%>" name="<%=fieldName%>" id="<%=fieldName%>" maxlength="150"<%=additionalTags%> />
                <%end if %>
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
                CKEDITOR.config.shiftEnterMode= CKEDITOR.ENTER_P;
                CKEDITOR.config.enterMode= CKEDITOR.ENTER_BR;
                CKEDITOR.config.height = <%=sqlOrClass%>;
                $('#<%=fieldName%>').ckeditor();
            });
			</script>
			<%
		case "currency", "float"
			response.Write(LabelFor)
			if not isnull(fieldValue) and not fieldValue="" and isnumeric(fieldValue) then
			    if instr(sqlOrClass, "sql-mask-4-digits") or fieldType="float" then
                    fieldValue = formatnumber(fieldValue,4)
                else
                    fieldValue = formatnumber(fieldValue,2)
			    end if
			end if
			%>
			 <% if fieldType = "currency" then %>
            <div class="input-group">

                <span class="input-group-addon">
                <strong>R$</strong>
            <% end if %>
            </span>
            <input id="<%=fieldName%>" class="form-control input-mask-brl <%=sqlOrClass%>" type="text" style="text-align:right" name="<%=fieldName%>" value="<%=fieldValue%>"<%=additionalTags%>>
             <% if fieldType = "currency" then %>
            </div>
            <% end if %>
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

			if instr(additionalTags, "no-select2")>0 then
				select2 = ""
			else
				select2 = "select2-single"
                additionalTags = replace(additionalTags, "no-select2", "")
			end if
			%>
            <select name="<%= fieldName %>" id="<%= fieldName %>" class="<%=select2 %> form-control"<%=additionalTags%>>
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
				%><option value="<%=idSQL%>"<% If idSQL=fieldValue or cstr(idSQL)=cstr(fieldValue&"") Then %> selected="selected"<% End If %>><%=doSql(""&columnToShow&"")%></option>
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
            multipleValorEntrada = fieldValue
			while not listItems.EOF
			%>
			<option value="|<%=listItems("id")%>|"<%if inStr(multipleValorEntrada, "|"&listItems("id")&"|")>0 then%> selected="selected"<%end if%>><%=listItems(""&columnToShow&"")%></option>
			<%
			listItems.movenext
			wend
			listItems.close
			set listItems=nothing
			%>
			</select>
            <%

        case "multipleModal"
            'Envio de Ações Edit,Insert ao clicar no salvar do modal. Ex.: P=paginaDaAcao&acao=update&refresh=true
            if columnToShow<>"" then
                acaoSQL = "&"&columnToShow
            end if
            btn="<button type='button' id='btn_"&fieldName&"' name='btn_"&fieldName&"' class='btn btn-default btn-block' onclick='openComponentsModalPost(`quickField_multipleModal.asp?I="&fieldName&acaoSQL&"`, {v: $(""#"&fieldName&""").val()}, `Gerenciar "&label&"`, true, function(data){closeComponentsModal(true)})'> "&_
                    "<i class='far fa-plus'></i> "&label&" <span></span>"&_
                "</button>" 

            'CONDIÇÃO PARA O USO DA VARIÁVEL fieldValue
            if additionalTags<>"" then
                additionalTags_array=Split(additionalTags,"_")
                'EXEMPLO PARA REMOVER REGISTROS SEPARADOS POR VÍRGULA remove_1,2,3...
                if additionalTags_array(0)="remove" then
                    itensRemove_array=Split(additionalTags_array(1),",")
                    for each itensRemove in itensRemove_array
                        fieldValue = replace(fieldValue,itensRemove,"")
                    'response.write("<script>console.log('"&itensRemove&" XX ')</script>")
                    next
                    fieldValue = replace(fieldValue,additionalTags_array(1),"")
                    if left(fieldValue,1) = "," then
                        fieldValue=right(fieldValue,(len(fieldValue)-1))
                    end if
                end if
            end if
            
            input = "<div class='text-right'><input type='hidden' name='"&fieldName&"' id='"&fieldName&"' value='"&fieldValue&"'></div>"
                        
            response.write(btn&input)
            
            'DEFINE QUERYS PARA CONSULTAS E GRAVA EM SESSÃO
            'Select Case X .....
            Session("multipleModal_session")=sqlOrClass        


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
                <span class="radio-custom radio-primary"><input <%=additionalTags%> class="<%= fieldName %>" type="radio" name="<%= fieldName %>" id="<%=fieldName & listItems("id")%>" value="<%=listItems("id")%>"<% if cstr(fieldValue&"")=cstr(listItems("id")) then response.write(" checked ") end if %> /><label for="<%=fieldName & listItems("id")%>"> <%=listItems(""&columnToShow&"")%></label></span><br>
                <%
            listItems.movenext
            wend
            listItems.close
            set listItems=nothing
		case "cor" %>
		    <script>
		        let url = new URL(window.location.href);
                let parametro = url.searchParams.get("P");

                if(parametro === 'Equipamentos') {
                    document.getElementById("cor-agenda").style = "display: none;";
                    document.getElementById("cor-agenda").disabled = true;
                }
            </script>
		    <div id="cor-agenda">
			    <% response.Write(LabelFor) %>
                <div class="admin-form">
                    <label class="field sfcolor">
                        <input type="text" name="<%= fieldName %>" id="<%= fieldName %>" class="gui-input" placeholder="Selecione" value="<%=fieldValue %>">
                    </label>
                </div>
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
        case "simpleColor"
            response.Write(LabelFor)
            %>
            <style>
            .sp-palette-container{
                padding-top: 10px;
                padding-right: 15px;
                padding-bottom: 300px;
                padding-left: 15px;
            }
            </style>
            <div class="admin-form">
                <label class="field sfcolor">
                    <input type="text" name="<%= fieldName %>" id="<%= fieldName %>" class="gui-input" placeholder="Selecione"  value="<%=fieldValue %>">
                </label>
            </div>
            <script type="text/javascript">
                $(document).ready(function(){
                    var cPicker1 = $("#<%=fieldName%>");

                    var cContainer1 = cPicker1.parents('.sfcolor').parent();

                    $("#<%=fieldName%>").spectrum({
                        preferredFormat: "hex",
                        showPaletteOnly : true ,
                        showPalette : true ,
                        hideAfterPaletteSelect : true ,
                        color: '<%=fieldValue %>',
                        palette: [
                            ['black', 'white', 'blanchedalmond', 'red', 'yellow', 'green', 'blue', 'violet']
                        ]
                        });


                    $("#<%=fieldName%>").show();
                });

            </script>
        <%
		case "datepicker"
			response.Write(LabelFor)
			%>
            <div class="input-group">
            <%if device()="" then
             classDatePicker = "date-picker"
             if instr(additionalTags,"no-datepicker") then
                 classDatePicker = ""
             end if
             if instr(additionalTags,"datepicker-vazio") then
                 classDatePicker = "date-pickerinput-mask-date"
             end if
            %>
                <input id="<%= fieldName %>" autocomplete="off" class="form-control input-mask-date <%=classDatePicker%> <%=sqlOrClass%>" type="text" value="<%= fieldValue %>" name="<%= fieldName %>" data-date-format="dd/mm/yyyy"<%=additionalTags%>>
            <%else
                aditionalTags = replace(aditionalTags, "input-mask-date", "")
                %>
                <input id="<%= fieldName %>" class="form-control <%=sqlOrClass%>" type="date" value="<%= mydate(fieldValue) %>" name="<%= fieldName %>" data-date-format="dd/MM/yyyy"<%=additionalTags%>>
            <%end if %>
            <span class="input-group-addon<%if instr(sqlOrClass, "input-sm")>0 then%> input-sm<%end if%>">
            <i class="far fa-calendar bigger-110"></i>
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
            <%if device()="" then %>
                <input id="<%=fieldName%>" name="<%=fieldName%>" value="<%=fieldValue%>" type="text" class="form-control input-mask-l-time" <%=additionalTags%>/>
            <%else
                aditionalTags = replace(aditionalTags, "input-mask-date", "")
                %>
                <input id="<%=fieldName%>" name="<%=fieldName%>" value="<%=fieldValue%>" type="time" class="form-control" />
            <%end if %>

                <span class="input-group-addon">
                    <i class="far fa-clock bigger-110"></i>
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
                if not isnull(empresa("NomeFantasia")) then
                    %><option value="0"><%=empresa("NomeFantasia")%></option>
                    <%
                end if
            end if
            %><option disabled="disabled" style="border-bottom:1px dotted #CCC; border-top:1px dotted #CCC;"></option><%
            set filiais = db.execute("select * from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 order by UnitName")
            while not filiais.eof
                %><option value="-<%=filiais("id")%>"<% If fieldValue=(filiais("id")*(-1)) or fieldValue=cstr(filiais("id")*(-1)) Then %> selected="selected"<%end if%>><%=filiais("NomeFantasia")%></option>
                <%
            filiais.movenext
            wend
            filiais.close
            set filiais=nothing
            %><option disabled="disabled" style="border-bottom:1px dotted #CCC; border-top:1px dotted #CCC;"></option><%
            set prof = db.execute("select id, NomeProfissional from profissionais where sysActive=1 and ativo='on' order by NomeProfissional")
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
				additionalTags = replace(additionalTags, "no-select2", "")

				%>
				<select name="<%=fieldName%>" id="<%=fieldName%>" class="select2-single form-control<%=sqlOrClass%>" <%=additionalTags%>>
				<%
				set empresa = db.execute("select * from empresa")
				if not empresa.eof then
					if not isnull(empresa("NomeFantasia")) and instr(session("Unidades"), "|0|") then
						%><option value="0"><%=empresa("NomeFantasia")%></option>
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
					%>><%=filiais("NomeFantasia")%></option>
					<%
				filiais.movenext
				wend
				filiais.close
				set filiais=nothing
                if columnToShow="rateio" then
				%>
                <option value="-1" <% if fieldValue=-1 then %> selected="selected" <% end if %>>RATEIO</option>
                <% end if %>
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
					if not isnull(empresa("NomeFantasia")) and instr(session("Unidades"), "|0|") then
						response.write("<option value=""|0|""")
                        if instr(fieldValue, "|0|") then
                            response.write(" selected ")
                        end if
                        response.Write(">"&empresa("NomeFantasia")&"</option>")
					end if
				end if
				while not filiais.eof
					if instr(fieldValue, "|"&filiais("id")&"|")>0 then
						response.write("<option value='|"&filiais("id")&"|'")
						If instr(fieldValue, "|"&filiais("id")&"|") Then
							response.write(" selected='selected' ")
						end if
					    response.write(">"&filiais("NomeFantasia") &"</option>")
					end if

				filiais.movenext
				wend
				filiais.close
				set filiais=nothing
				if columnToShow="rateio" then
				%>
                <option value="-1" <% if fieldValue=-1 then %> selected="selected" <% end if %>>RATEIO</option>
                <% end if %>
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
				<select name="<%=fieldName%>" id="<%=fieldName%>" multiple class="form-control multisel <%=sqlOrClass%>">
				<%
				set empresa = db.execute("select * from empresa")
				response.write("<optgroup label='Empresa principal'>")
				if not empresa.eof then
					if not isnull(empresa("NomeFantasia")) then
                        if instr(session("Unidades")&"", "|0|")>0 then
						    response.write("<option value=""|0|""")
                            if instr(fieldValue, "|0|") then
                                response.write(" selected ")
                            end if
                            response.Write(">"&empresa("NomeFantasia")&"</option>")
					    end if
                    end if
				end if
				response.write("</optgroup><optgroup label='Filiais'>")
				while not filiais.eof
                    if instr(session("Unidades")&"", "|"& filiais("id") &"|")>0 then
					    response.write("<option value='|"&filiais("id")&"|'")
					    If instr(fieldValue, "|"&filiais("id")&"|") Then
						    response.write(" selected='selected' ")
					    end if
					    response.write(">"&filiais("NomeFantasia") &"</option>")
                    end if
				filiais.movenext
				wend
				filiais.close
				set filiais=nothing
				response.write("</optgroup>")
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
					if not isnull(empresa("NomeFantasia")) and instr(session("Unidades"), "|0|") then
						%><option value="|0|"<%if instr(fieldValue, "|0|") then%> selected<%end if%>><%=empresa("NomeFantasia")%></option>
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
					if not isnull(empresa("NomeFantasia")) and instr(session("Unidades"), "|0|") then
						%><label><input class="ace" type="checkbox" name="<%=fieldName%>" value="|0|"<%if instr(fieldValue, "|0|") then%> checked<%end if%>><span class="lbl"> <%=empresa("NomeFantasia")%></span></label><br>
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
						%>><span class="lbl"> <%=filiais("NomeFantasia") %></span></label><br>
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


function IdadeAbreviada(DataNascimento)
    if isDate(DataNascimento) then
        if cdate(DataNascimento)>date() then
            IdadeAbreviada = "N&atilde;o nasceu ainda"
        elseif cdate(DataNascimento)=date() then
            IdadeAbreviada = "Nascido hoje"
        else
            IdadeAbre = datediff("yyyy",DataNascimento,date())
            if (month(DataNascimento)>month(date())) or (month(DataNascimento)=month(date()) and day(DataNascimento)>day(date())) then
            		IdadeAbre=IdadeAbre-1
            	end if
            UltNivPas=dateadd("yyyy",IdadeAbre,DataNascimento)
            MesesIdade=datediff("m",UltNivPas,date())
            if (day(UltNivPas)>day(date)) and MesesIdade>0 then
                MesesIdade=MesesIdade-1
            end if

            if IdadeAbre>1 then
                ano = " anos"
            elseif IdadeAbre=1 then
                ano = " ano"
            elseif IdadeAbre=0 then
                 IdadeAbre = MesesIdade

                 if IdadeAbre=1 then
                    ano = " mês"
                 else
                    ano = " meses"
                 end if
            end if
            IdadeAbreviada = IdadeAbre&ano
        end if
    else
        IdadeAbreviada = "Não informado"
    end if

end function

function iconMethod(PaymentMethodID, CD)
    if CD="" or isnull(CD) then
        CD = "D"
    end if
	if not isNull(PaymentMethodID) then
		response.Write("<img width=""18"" src=""assets/img/"&PaymentMethodID&CD&".png"" /> ")
		set pmd = db.execute("select PaymentMethod from cliniccentral.sys_financialpaymentmethod where id="&PaymentMethodID)
		if not pmd.EOF then
			response.Write("<small>"& pmd("PaymentMethod") &" &raquo; </small>")
		end if
    end if
end function

function accountName(AccountAssociationID, AccountID)
    if instr(AccountID, "_")>0 then
        splCreditado = split(AccountID, "_")
        AccountAssociationID = splCreditado(0)
        AccountID = splCreditado(1)
    end if
    if not isnull(AccountAssociationID) and AccountID&"" <>"" then
	    set getAssociation = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&AccountAssociationID)
	    if not getAssociation.eof then
	        sql = "select `"&getAssociation("column")&"` from `"&getAssociation("table")&"` where id="&AccountID
		    set getAccount = db.execute(sql)
		    if not getAccount.EOF then
			    accountName = getAccount(""&getAssociation("column")&"")
		    end if
	    end if
    else
        if AccountID&""="0" then
            AccountName = "Posição"
        end if
    end if
end function


function accountBalance(AccountID, Flag)
	splAccountInQuestion = split(AccountID, "_")
	AccountAssociationID = splAccountInQuestion(0)
	AccountID = splAccountInQuestion(1)

	accountBalance = 0
	set getMovement = db.execute("select * from sys_financialMovement where ((AccountAssociationIDCredit="&AccountAssociationID&" and AccountIDCredit="&AccountID&") or (AccountAssociationIDDebit="&AccountAssociationID&" and AccountIDDebit="&AccountID&")) and Date<='"&myDate(date())&"' order by Date")

	if not getMovement.eof then
        while not getMovement.eof
            Value = getMovement("Value")
            AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
            AccountIDCredit = getMovement("AccountIDCredit")
            AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
            AccountIDDebit = getMovement("AccountIDDebit")
            PaymentMethodID = getMovement("PaymentMethodID")
            Rate = getMovement("Rate")
            'defining who is the C and who is the D
            'if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
            if AccountAssociationIDCredit&""=AccountAssociationID&"" and AccountIDCredit&""=AccountID&"" then
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

    end if

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
    if instr(othersToInput, "required")>0 and label&""<>"" then
        ast = " *"
    else
        ast = ""
    end if
	%><%if label<>"" then%><label><%=label & ast%></label><br /><%end if%>
    <select id="<%=name %>" name="<%=name %>" class="form-control" <%=othersToSelect %> <%'=othersToInput %> data-campoSuperior="<%=campoSuperior%>" data-resource="<%=resource %>" data-showColumn="<%=showColumn %>">
        <option value="<%=value %>" selected="selected"><%=textValue %></option>
    </select>


	<script type="text/javascript">
	        s2aj("<%=name%>", '<%=resource%>', '<%=showColumn%>', '<%=campoSuperior%>', '<%=placeholder%>', "<%=othersToInput%>");
            
	        $("#<%=name%>").change(function(){
	            //console.log( $("#<%=name%>").html() );
	            if( $(this).val()=="-1" ){

	                var valorDigitado = $("#<%=name%> option[data-select2-tag='true']:last").text();

	                if(confirm("Tem certeza que deseja inserir \""+valorDigitado+"\"?")){
	                    $.post("sii.asp", {
                            v:$("#<%=name%> option[data-select2-tag='true']:last").text(),
                            t:'<%=name%>',
                            campoSuperior:$('#<%=campoSuperior%>').val(),
                            showColumn:$(this).attr("data-showColumn"),
                            resource:$(this).attr("data-resource")
                        }, function (data) {
                            eval( data );
                        });
	                }else {
	                    $("#<%=name%>").select2("val","");
	                }
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
		<i class="far fa-search" id="spin<%=name%>"></i>
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






function selectProc(label, name, value, thisField, TabelaField, CodigoField, DescricaoField, othersToInput, CDField, UnidadeMedidaField, ValorField)
	'1. o padrão do insert é o primeiro
	'2. o valor do campo pode ser do tipo conta (quando tem mais de 1, ex.: 1_232) ou id (ex.: 4)
	'3. só preenche se quiser

	urlPost = "selectProc.asp"

	if instr(othersToInput, "produto") then
	    urlPost = "procuraMaterial.asp"
	end if

	if instr(othersToInput, "adicionar-valor") then
	    AdicionarValor = 1
	end if

	%><%if label<>"" then%><label><%=label%></label><br /><%end if%>
    <span class="input-icon input-icon-right width-100">
		<input type="text" class="form-control" id="<%=name%>" name="<%=name%>" value="<%=value%>" autocomplete="off" <%= othersToInput %>>
		<i class="far fa-search"></i>
	</span>
	<div id="resultSelect<%=name%>" class="ResultSearchInput">
    	<span class="m5"> <i class="far fa-circle-o-notch fa-spin fa-fw"></i> Buscando...</span>
    </div>
<script language="javascript">
function f_<%=replace(name, "-", "_")%>(){
	$.post("<%=urlPost%>",{
		   selectID:'<%=name%>',
		   typed:$("#<%=name%>").val(),
		   resource:'<%=resource%>',
		   thisField:'<%=thisField%>',
		   Tabela: $('#<%=TabelaField%>').val(),
		   TabelaField:'<%=TabelaField%>',
		   CodigoField:'<%=CodigoField%>',
		   DescricaoField:'<%=DescricaoField%>',
		   CDField:'<%=CDField%>',
		   UnidadeMedidaField:'<%=UnidadeMedidaField%>',
		   AdicionarValor:'<%=AdicionarValor%>',
		   ValorField:'<%=ValorField%>'
		   },function(data,status){
	  $("#resultSelect<%=name%>").html(data);
	});
}

var typingTimer<%=replace(name, "-", "_")%>;
$(document).ready(function(){
  $("#<%=name%>").keyup(function(){
	if($("#<%=name%>").val().length>0){
		$("#resultSelect<%=name%>").css("display", "block");
		$("#resultSelect<%=name%>").html("<span class='m5'> <i class='far fa-circle-o-notch fa-spin fa-fw'></i> Buscando...</span>");
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
    		<i class="far fa-search"></i>
        </span>
		<input type="text" class="form-control" id="<%=name%>" name="<%=name%>" value="<%=value%>" autocomplete="off" <%= othersToInput %>>
	</div>
	<div id="resultSelect<%=name%>" style="position:absolute; display:none; background-color:#f3f3f3; z-index:10000; padding:5px">
        <div>
            <button class="btn btn-xs btn-default pull-right" style="padding-bottom:5px;" onclick="$('#resultSelect<%=name%>').css('display', 'none')" type="button">Fechar sugestões</button>
        </div>
        <div>
            <div id="contentresultSelect<%=name%>" style="width:400px; height:300px; overflow-y:scroll; z-index:1000;">
        	    buscando...
            </div>
        </div>
    </div>
<script type="text/javascript">
function f_<%=replace(name, "-", "_")%>(){
	$.post("selectList.asp",{
           I:'<%=req("I")%>',
		   selectID:'<%=name%>',
		   typed:$("#<%=name%>").val(),
		   resource:'<%=resource%>',
		   showColumn:'<%=showColumn%>',
		   othersToSelect:'<%= othersToSelect %>'<%if campoSuperior<>"" then%>,
		   campoSuperior:$("#<%=campoSuperior%>").val()<%end if%>
		   },function(data,status){
	  $("#contentresultSelect<%=name%>").html(data);
	});
}

var typingTimer<%=replace(name, "-", "_")%>;
$(document).ready(function(){
  $("#<%=name%>").keyup(function(){
	if($("#<%=name%>").val().length>0){
		$("#resultSelect<%=name%>").css("display", "block");
		$("#contentresultSelect<%=name%>").html("buscando...");
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
       ' Aut=AutPlano(Permissao)
'	end if
'Autorizado="Sim"
end function


function AutPlano(Recurso)
    PermissaoOK = false
    'não tem plano, plano ID = 1(free) ou 3(pro)
    if isnull(session("Plano")) or session("PlanoID")=4 or session("PlanoID")=1 then
        if session("Admin")=1 then
            PermissaoOK = true
        elseif inStr(session("Permissoes"),Recurso)>0 then
            PermissaoOK = True
        end if
    else
        RecursoPlano = replace(Recurso,"|","")
        x=Len(RecursoPlano)

        if x > 0 then
            RecursoPlano = left(RecursoPlano, x-1)
        end if

        'verifica se recurso existe no plano, se sim, se o usuario tem permissao ao recurso
        if inStr(session("Plano"), RecursoPlano)> 0  then
            if session("Admin")=1 then
                PermissaoOK = true
            elseif inStr(session("Permissoes"),Recurso)>0 then
                PermissaoOK = True
            end if
        end if
    end if

    if PermissaoOK then
        AutPlano=1
    else
        AutPlano=0
    end if
end function


'remove tags html de uma string
FUNCTION stripHTML(strHTML)
  Dim objRegExp, strOutput, tempStr
  Set objRegExp = New Regexp
  objRegExp.IgnoreCase = True
  objRegExp.Global = True
  objRegExp.Pattern = "<(.|n)+?>"
  'Replace all HTML tag matches with the empty string
  strOutput = objRegExp.Replace(strHTML, "")
  'Replace all < and > with &lt; and &gt;
  strOutput = Replace(strOutput, "<", "&lt;")
  strOutput = Replace(strOutput, ">", "&gt;")
  stripHTML = strOutput    'Return the value of strOutput
  Set objRegExp = Nothing
END FUNCTION

function autForm(FormID, TipoAut, PreenchedorID)
	autForm = false
	set perm = db.execute("select * from buipermissoes where FormID="&FormID)
	if perm.eof then
        if session("table")="profissionais" then
            autForm = true

        end if
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
          $("#<%=btnSaveID%>").html('<i class="far fa-save"></i> Salvar');
		  $("#<%=btnSaveID%>").removeAttr('disabled');
          eval(data);

		  if(data.toLowerCase().indexOf("erro") <= 0){
            <%=AcaoSeguinte%>
          }
        }).fail(function(data) {
            $("#<%=btnSaveID%>").html('<i class="far fa-save"></i> Salvar');
            $("#<%=btnSaveID%>").removeAttr('disabled');

            showMessageDialog("Os dados não foram salvos. Tente novamente mais tarde.", "danger");
          });
        return false;
    })
	<%
end function

function insertRedir(tableName, id)
	if id="N" then
		sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
		set vie = db.execute(sqlVie)

		 SempreCriarLinhaNova = False
        tablename = lcase(tablename)

'em guias sadt/consulta tem a possibilidade de voltar a numeracao.
        if tablename="tissguiaconsulta" or tablename="tissguiasadt" or tablename="tissguiahonorarios" then
            SempreCriarLinhaNova = True
        end if

        criar = vie.eof or SempreCriarLinhaNova

        IF session("Status") = "F" AND (tableName = "pacientes" OR tableName = "profissionais" ) THEN
           Set d =Server.CreateObject("Scripting.Dictionary")
           d.Add "profissionais","1"
           d.Add "pacientes","100"

           sql = "select count(*) >= "&d.Item(tableName)&" as quantidade from "&tableName&" WHERE TRUE and sysActive=0"
           set quantidadeDB = db.execute(sql)
           quantidade = quantidadeDB("quantidade")

           IF quantidade THEN
                response.Redirect("?P="&tableName&"&Pers=Follow&limitExceeded=1")
                response.end
           END IF
        END IF

		if criar then
			db_execute("insert into "&tableName&" (sysUser, sysActive) values ("&session("User")&", 0)")

			if SempreCriarLinhaNova then
    			'deleta os sysactive 0 de datas passadas para nao ficar muito paa nao ficar muito lixo na tabela
			    db_execute("DELETE FROM "&tablename&" WHERE sysActive=0 AND date(sysDate) < curdate()")
			    sqlVie = sqlVie & " order by id desc LIMIT 1"
			end if
			set vie = db.execute(sqlVie)
		end if
		'===> Exceções
		if req("Lancto")<>"" then
			strLancto = "&Lancto="&req("Lancto")
		end if
		if req("ApenasProcedimentosNaoFaturados")<>"" then
			strApenasNaoFaturados = "&ApenasProcedimentosNaoFaturados="&req("ApenasProcedimentosNaoFaturados")
		end if
        if req("Solicitantes")<>"" then
            strSolicitantes = "&Solicitantes="&req("Solicitantes")
        end if

        's = "INSERT INTO log (recurso,I,sysUser,colunas,valorAnterior,valorAtual) VALUES ('"&tableName&"',"&vie("id")&","&session("User")&",'','','')"

        'db.execute(s)
        if req("cmd")<>"" then
            qsCmd = "&cmd="&req("cmd")
        end if

		response.Redirect("?P="&tableName&"&I="&vie("id")&"&Pers="&req("Pers") &strLancto & strApenasNaoFaturados & strSolicitantes& qsCmd)
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

function dominioRepasse(FormaID, ProfissionalID, ProcedimentoID, UnidadeID, TabelaID, EspecialidadeID, DataExec, HoraExec)
'        response.write(FormaID)
FormaID = replace(FormaID&"", "|", "")
'conferir -> FormaID pode ser |P| para todos particulares, |C| para todos convênios, |00_0| para forma predefinida de recto e > |0| para qualquer id de convênio
	dominioRepasse = 0
	EspecialidadeIDsent = EspecialidadeID&""
	pontomaior = 0
    ProfissionalID= replace(ProfissionalID, "5_","")

    set pprofs = db.Execute("select GrupoID from profissionais where not isnull(GrupoID) and GrupoID<>0 and id="& treatvalzero(ProfissionalID))
    if not pprofs.eof then
        GrupoProfissionalID = pprofs("GrupoID")
    end if

    set pproc = db.Execute("select GrupoID from procedimentos where not isnull(GrupoID) and GrupoID<>0 and id="& treatvalzero(ProcedimentoID))
    if not pproc.eof then
        GrupoProcedimentoID = "-"& pproc("GrupoID")
    end if

    if ProfissionalID&""<>"" and isnumeric(ProfissionalID&"") then
        set vesp = db.execute("select EspecialidadeID from profissionais where id="& ProfissionalID&" and not isnull(EspecialidadeID) and EspecialidadeID<>0")
        if not vesp.eof then
            EspecialidadeID = "-"& vesp("EspecialidadeID")
        else
            EspecialidadeID = ""
        end if
    end if
    'se a especialidade for valida postada leva em conta a postada
    if EspecialidadeIDsent<>"" and isnumeric(EspecialidadeIDsent) and EspecialidadeIDsent<>"0" then
        EspecialidadeID = "-"& EspecialidadeIDsent
    end if

'essa abordagem eh extremamente mais performatica pois filtra o numero de registros
    if req("debugarRepasse")="1" or True then
	set dom = db.execute("select * from rateiodominios WHERE "&_
	"(IFNULL(Unidades,'')='' or Unidades LIKE '%|"&UnidadeID&"|%') "&_
	" AND (IFNULL(Tabelas,'')='' or Tabelas LIKE '%|"&TabelaID&"|%') "&_
	" AND ((IFNULL(Profissionais,'')='' or Profissionais LIKE '%|"&ProfissionalID&"|%') or "&_
	"  (IFNULL(Profissionais,'')='' or Profissionais LIKE '%|"&EspecialidadeID&"|%'))"&_

	" AND ((IFNULL(Procedimentos,'')='' or Procedimentos LIKE '%|"&ProcedimentoID&"|%') OR "&_
	"  (IFNULL(Procedimentos,'')='' or Procedimentos LIKE '%|"&GrupoProcedimentoID&"|%')) "&_
	"order by Tipo desc")
	else
	    set dom = db.execute("select * from rateiodominios order by Tipo desc")
	end if

	while not dom.eof
        Tabelas = dom("Tabelas")&""
        Unidades = dom("Unidades")&""
        Formas = dom("Formas")&""
        GruposProfissionais = dom("GruposProfissionais")&""
        Dias = dom("Dias")&""
        Horas = dom("Horas")&""


		esteponto = 0
		queima = 0


		if instr(Formas, "|"&FormaID&"|")>0 then
			esteponto = esteponto+1
		else
			if trim(Formas)<>"" then
				if instr(FormaID, "_") and instr(Formas, "|P|")>0 then
					queima = 0
				else
					queima = 1
				end if
			end if
		end if
		if instr(Tabelas, "|"&TabelaID&"|")>0 then
			esteponto = esteponto+1
		else
			if Tabelas<>"" then
				queima = 1
			end if
		end if
		if instr(dom("Profissionais"), "|"&replace(ProfissionalID&"", "5_", "")&"|")>0 or instr(dom("Profissionais"), "|"&EspecialidadeID&"|")>0 then
		    if instr(dom("Profissionais"), "|"&replace(ProfissionalID&"", "5_", "")&"|")>0 then
			    esteponto = esteponto+1
		    end if

		    if instr(dom("Profissionais"), "|"&EspecialidadeID&"|")>0 then
			    esteponto = esteponto+1
		    end if
		else
			if trim(dom("Profissionais"))<>"" then
				queima = 1
			end if
		end if
		Procedimentos = dom("Procedimentos")
		if instr(Procedimentos, "|"&ProcedimentoID&"|")>0 then
			esteponto = esteponto+1
		else
			if trim(Procedimentos)<>"" then
                'antes de queimar, ve o grupo desse procedimento e incrementa ou queima
                if GrupoProcedimentoID<>"" then
                    if instr(Procedimentos, "|"&GrupoProcedimentoID&"|")>0 then
			            esteponto = esteponto+1
                    else
        				queima = 1
                    end if
                else
                    queima = 1
                end if
			end if
		end if

        if Tabelas<>"" and isnumeric(FormaID&"") and instr(Formas, "|"& FormaID &"|")=0 then
            queima = 1
        end if

		if trim(GruposProfissionais)<>"" then

            'antes de queimar, ve o grupo desse procedimento e incrementa ou queima

            if GrupoProfissionalID<>"" then

                if instr(GruposProfissionais, "|"&GrupoProfissionalID&"|")>0 then
			        esteponto = esteponto+1
                else
        			queima = 1
                end if
            else
                queima = 1
            end if
		end if
		if instr(Unidades, "|"&UnidadeID&"|")>0 then
			esteponto = esteponto+1
		else
			if trim(Unidades)<>"" then
				queima = 1
			end if
		end if
        if isDate(DataExec&"") and trim(Dias)<>"" then
		    if instr(Dias, weekday(DataExec))>0 then
			    esteponto = esteponto+1
		    else
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
	macro = "<div class=""btn-toolbar"">"
	macro = macro&"<div class=""btn-group"">"
	macro = macro&"	<div class=""btn-group"">      <div>Inserir Macro&nbsp;&nbsp;</div>     </div>"

    '-> pacientes
    macro = macro&"	<div class=""btn-group"">"
    macro = macro&"	  <button class=""btn dropdown-toggle btn-xs btn-info"" data-toggle=""dropdown"">Paciente <span class=""caret""></span></button>"
    macro = macro&"	  <ul class=""dropdown-menu"">"
    strPac = "[Paciente.Nome]|^[Paciente.Idade]|^[Paciente.CPF]|^[Paciente.Prontuario]|^[Paciente.Endereco]|^[Paciente.Numero]|^[Paciente.Complemento]|^[Paciente.Cidade]|^[Paciente.Estado]|^[Paciente.Cep]|^[Paciente.Nascimento]|^[Paciente.Sexo]|^[Paciente.Cor]|^[Paciente.Altura]|^[Paciente.Peso]|^[Paciente.IMC]|^[Paciente.Religiao]|^[Paciente.Tel1]|^[Paciente.Tel2]|^[Paciente.Cel1]|^[Paciente.Cel2]|^[Paciente.Email1]|^[Paciente.Email2]|^[Paciente.Profissao]|^[Paciente.Documento]|^[Paciente.EstadoCivil]|^[Paciente.Origem]|^[Paciente.IndicadoPor]|^[Paciente.Observacoes]|^[Paciente.Convenio]|^[Paciente.Matricula]|^[Paciente.Validade]"
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
	strUni = "Nome, NomeFantasia, Endereco, Numero, Complemento, Bairro, Cidade, Estado, Tel1, Cel1, Email1, CNPJ, CNES"
	splUni = split(strUni, ", ")
	for unk=0 to ubound(splUni)
		macro = macro&"		  <li><a href=""javascript:macroJS('"&editor&"', '[Unidade."&splUni(unk)&"]')"">[Unidade."&splUni(unk)&"]</a></li>"
	next
	macro = macro&"	  </ul>"
	macro = macro&"	</div>"

    if editor<>"Cabecalho" and editor<>"Rodape" then
        '-> agendamento
        macro = macro&"	<div class=""btn-group"">"
        macro = macro&"	  <button class=""btn dropdown-toggle btn-xs btn-info"" data-toggle=""dropdown"">Agendamento <span class=""caret""></span></button>"
        macro = macro&"	  <ul class=""dropdown-menu"">"
        strUni = "Hora, Data, HoraChegada"
        splUni = split(strUni, ", ")
        for unk=0 to ubound(splUni)
            macro = macro&"		  <li><a href=""javascript:macroJS('"&editor&"', '[Agendamento."&splUni(unk)&"]')"">[Agendamento."&splUni(unk)&"]</a></li>"
        next
        macro = macro&"	  </ul>"
        macro = macro&"	</div>"
	end if


    '<-- profissionais
    macro = macro&"	<div class=""btn-group"">"
    macro = macro&"	  <button class=""btn dropdown-toggle btn-xs btn-info"" data-toggle=""dropdown"">Profissional <span class=""caret""></span></button>"
    macro = macro&"	  <ul class=""dropdown-menu"">"
    strPro = "[Profissional.Nome]|^[Profissional.Documento]|^[Profissional.Assinatura]"
    splPro = split(strPro, "|^")
    for prk=0 to ubound(splPro)
        macro = macro&"		  <li><a href=""javascript:macroJS('"&editor&"', '"&splPro(prk)&"')"">"&splPro(prk)&"</a></li>"
    next
    macro = macro&"	  </ul>"
    macro = macro&"	</div>"


    '<-- sistema
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

function replateTagsPaciente(valor,PacienteID)
    if instr(valor, "[Paciente.")>0 then
        strPac = "SELECT  "&_
        "c1.NomeConvenio AS 'Convenio1', c2.NomeConvenio AS 'Convenio2',c3.NomeConvenio AS 'Convenio3'  "&_
        ",pla1.NomePlano AS 'Plano1', pla2.NomePlano AS 'Plano2',pla3.NomePlano AS 'Plano3'  "&_
        ",p.*, ec.EstadoCivil, s.NomeSexo as Sexo, g.GrauInstrucao, o.Origem  "&_
        "from pacientes as p  "&_
        "left join estadocivil as ec on ec.id=p.EstadoCivil  "&_
        "left join sexo as s on s.id=p.Sexo  "&_
        "left join grauinstrucao as g on g.id=p.GrauInstrucao  "&_
        "left join origens as o on o.id=p.Origem  "&_
        "LEFT JOIN convenios c1 ON c1.id=p.ConvenioID1  "&_
        "LEFT JOIN convenios c2 ON c2.id=p.ConvenioID2  "&_
        "LEFT JOIN convenios c3 ON c3.id=p.ConvenioID3  "&_
        "LEFT JOIN conveniosplanos pla1 ON pla1.id=p.PlanoID1  "&_
        "LEFT JOIN conveniosplanos pla2 ON pla2.id=p.PlanoID2  "&_
        "LEFT JOIN conveniosplanos pla3 ON pla3.id=p.PlanoID3  "&_
        "where p.id="&treatvalzero(PacienteID) 
        'response.write("<pre>"&replace(strPac,"  ","<br>")&"</pre>")
        set pac = db.execute(strPac)

        if not pac.eof then

            set ResponsavelSQL = db.execute("SELECT Nome, CPFParente CPF FROM pacientesrelativos WHERE sysActive=1 AND PacienteID="&pac("id")&" AND Dependente='S'")

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
                        set cor = db.execute("select * from corpele where id = '"&pac("CorPele")&"'")
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
            valor = replace(valor, "[Paciente.Nascimento]", pac("Nascimento")&"")
            valor = replace(valor, "[Paciente.Documento]", pac("Documento")&"")
            valor = replace(valor, "[Paciente.Prontuario]", pac("id"))

            'POSSIBILIDADE DE UTILIZAR PLANOS E CONVENIOS SECUNDÁRIOS
            valor = replace(valor, "[Paciente.Convenio1]", pac("Convenio1")&"")
            valor = replace(valor, "[Paciente.Convenio2]", pac("Convenio2")&"")
            valor = replace(valor, "[Paciente.Convenio3]", pac("Convenio3")&"")
            valor = replace(valor, "[Paciente.Plano1]", pac("Plano1")&"")
            valor = replace(valor, "[Paciente.Plano2]", pac("Plano2")&"")
            valor = replace(valor, "[Paciente.Plano3]", pac("Plano3")&"")
            'REDUNDANCIA NOS PLANOS E CONVENIOS 1 TAGs EXISTENTES
            valor = replace(valor, "[Paciente.Convenio]", trim(pac("Convenio1")&" ") )
            valor = replace(valor, "[Paciente.Plano]", trim(pac("Plano1")&" ") )

            valor = replace(valor, "[Paciente.Matricula]", trim(pac("Matricula1")&" ") )
            valor = replace(valor, "[Paciente.Validade]", trim(pac("Validade1")&" ") )
            valor = replace(valor, "[Paciente.Email]", trim(pac("Email1")&" ") )
            valor = replace(valor, "[Paciente.Cpf]", trim(pac("CPF")&" ") )
            valor = replace(valor, "[Paciente.Telefone]", trim(pac("Cel1")&" ") )

            if not ResponsavelSQL.eof then
                NomeResponsavel = ResponsavelSQL("Nome")&""
                CpfResponsavel = ResponsavelSQL("CPF")&""
			else
				NomeResponsavel= pac("NomePaciente")
            end if
            valor = replace(valor, "[Responsavel.Nome]", NomeResponsavel )
            valor = replace(valor, "[Responsavel.Cpf]", CpfResponsavel )

        end if
    end if
    replateTagsPaciente= valor
end function

function replaceTags(valor, PacienteID, UserID, UnidadeID)
	valor = trim(valor&" ")
	if (isnumeric(PacienteID) and not isnull(PacienteID)) then
		valor = replateTagsPaciente(valor, PacienteID)
	else
		quebraConta = split(PacienteID, "_")
		Assoc = quebraConta(0)
		Conta = quebraConta(1)

		if Assoc="3" then
		    PacienteID = Conta
		end if


		select case Assoc
			case "2"
				sql = "select *, NomeFornecedor Nome, RG Documento, CPF CPF_CNPJ from fornecedores where id="&Conta
			case "3"
				sql = "select *, NomePaciente Nome, CPF CPF_CNPJ from pacientes where id="&Conta
                valor = replateTagsPaciente(valor,Conta)
				idPaciente = Conta
			case "4"
				sql = "select *, NomeFuncionario Nome, RG Documento, CPF CPF_CNPJ from funcionarios where id="&Conta
			case "5"
				sql = "select *, NomeProfissional Nome, DocumentoProfissional Documento, CPF CPF_CNPJ from profissionais where id="&Conta
			case "6"
				sql = "select *, NomeConvenio Nome, '' Documento, Telefone Tel1, Email Email1, CNPJ CPF_CNPJ, '' Cel1 from convenios where id="&Conta
            case "8"
                sql = "select *, NomeProfissional Nome, DocumentoProfissional Documento, CPF CPF_CNPJ from profissionalexterno where id="&Conta
		end select
		camposASubs = "Nome, Endereco, Bairro, Cidade, Estado, Tel1, Cel1, Email1, CPF_CNPJ, Documento"
		correSubs = split(camposASubs, ", ")
		set registro = db.execute(sql)
		for corre=0 to ubound(correSubs)
'			if session("banco")="clinic811" then
'				valor = replace(valor, trim("[Conta."&correSubs(corre)&"] "), "database" )
'			else            
            if correSubs(corre) = "Nome" then
                NomePacienteUCaseTrim = trim(registro(""&correSubs(corre)&"")&" ")
                NomePacienteUCaseTrim = ucase(NomePacienteUCaseTrim)

			    valor = replace(valor, trim("[Conta."&correSubs(corre)&"] "),  NomePacienteUCaseTrim)
            else
                valor = replace(valor, trim("[Conta."&correSubs(corre)&"] "), trim(registro(""&correSubs(corre)&"")&" ") )
            end if     
'			end if
		next
	end if
	if instr(valor, "[Usuario.")>0 then
		valor = replace(valor, "[Usuario.Nome]", nameInTable(UserID))
	    if instr(valor, "[Usuario.CPF")>0 then
	        set UsuarioCpfSQL = db.execute("SELECT CPF FROM `"&session("table")& "` WHERE id="&session("idInTable"))
	        if not UsuarioCpfSQL.eof then
	            valor = replace(valor, "[Usuario.CPF]" , UsuarioCpfSQL("CPF"))
	        end if
	    end if
	end if

    if Assoc="3" then
        if instr(valor, "[Responsavel.") > 0 then
            'response.write("SELECT IFNULL(rela.Nome, pac.NomePaciente) NomePaciente, IFNULL(rela.CPFParente, pac.CPF) CPF FROM pacientesrelativos rela LEFT JOIN pacientes pac ON pac.id=rela.NomeID WHERE rela.Dependente='S' AND rela.PacienteID="&PacienteID)
            set PacienteResponsavelSQL = db.execute("SELECT IFNULL(rela.Nome, pac.NomePaciente) NomePaciente, IFNULL(rela.CPFParente, pac.CPF) CPF FROM pacientesrelativos rela LEFT JOIN pacientes pac ON pac.id=rela.NomeID WHERE rela.Dependente='S' AND rela.PacienteID="&PacienteID)

            if not PacienteResponsavelSQL.eof then
                NomeResponsavelPaciente = PacienteResponsavelSQL("NomePaciente")&""
                CpfResponsavelPaciente = PacienteResponsavelSQL("CPF")&""
                valor = replace(valor, "[Responsavel.Nome]", NomeResponsavelPaciente)
                valor = replace(valor, "[Responsavel.CPF]", CpfResponsavelPaciente)
            else
                set ResponsavelPacienteSQL = db.execute("SELECT CPF,NomePaciente FROM pacientes WHERE id="&PacienteID)
        
                CpfPaciente = ResponsavelPacienteSQL("CPF")&""
                valor = replace(valor, "[Responsavel.CPF]", CpfPaciente)

                NomePacienteUCase = ResponsavelPacienteSQL("NomePaciente")&""
                NomePacienteUCase = ucase(NomePacienteUCase)

                valor = replace(valor, "[Responsavel.Nome]", NomePacienteUCase)
                'aqui aqui aqui aqui aqui
                valorSplt = split(valor, "[Responsavel.Iniciar]")

                'response.write(valor)

                if ubound(valorSplt) > 0 then
                    arrValor2 = split(valorSplt(1), "[Responsavel.Finalizar]")

                    valor1 = valorSplt(0)
                    valor2 = arrValor2(1)

                    valor = valor1 & valor2
                end if
            end if
            valor = replace(valor, "[Responsavel.Iniciar]","")
            valor = replace(valor, "[Responsavel.Finalizar]","")
        
        end if
	end if

	ProfissionalID=0
	ProfissionalTag="[Profissional."
	if instr(valor, "[Profissional.")>0 then
		set user = db.execute("select * from sys_users where id="&session("User"))
		if not user.EOF then
			if lcase(user("Table"))="profissionais" then
				ProfissionalID=user("idInTable")
			end if
		end if
	end if
	if instr(valor, "[ProfissionalAgendado.")>0 then
		set AgendamentoSQL = db.execute("SELECT ProfissionalID FROM agendamentos WHERE PacienteID="&PacienteID&" AND Data=CURDATE() LIMIT 1")
		if not AgendamentoSQL.eof then
		    ProfissionalID = AgendamentoSQL("ProfissionalID")
            ProfissionalTag="[ProfissionalAgendado."
		end if
	end if

	if ProfissionalID>0 then
	    set pro = db.execute("select * from profissionais where id="&ProfissionalID)
        if not pro.EOF then
            set Trat = db.execute("select * from tratamento where id="&treatvalzero(pro("TratamentoID")))
            if not Trat.eof then
                Tratamento = trat("Tratamento")
            end if

            NomeProfissional = Tratamento&" "&pro("NomeProfissional")
            CPFProfissional = pro("CPF")&""

            valor = replace(valor, ProfissionalTag&"Nome]", NomeProfissional)
            valor = replace(valor, ProfissionalTag&"CPF]", CPFProfissional)
            set codigoConselho = db.execute("select * from conselhosprofissionais where id = '"&pro("Conselho")&"'")
            if not codigoConselho.eof then
                DocumentoProfissional = codigoConselho("codigo")&": "&pro("DocumentoConselho")&"-"&pro("UFConselho")
                valor = replace(valor, ProfissionalTag&"Documento]", DocumentoProfissional)
            end if
        end if
	end if

	valor = replace(valor, "[Data.DDMMAAAA]", date())
    valor = replace(valor, "[Data.Extenso]", formatdatetime(date(),1) )
    valor = replace(valor, "[Sistema.Extenso]", formatdatetime(date(),1) )
    valor = replace(valor, "[Sistema.Data]", date() )
	valor = replace(valor, "[Sistema.Hora]", time())

	'aqui usa as tags referentes ao agendamento do paciente - para formularios de folha de rosto por ex
	if instr(valor, "[Agendamentos.")>0 OR instr(valor, "[Agendamento.")>0 then
	    set AgendamentoSQL = db.execute("SELECT agendamentos.id, agendamentos.Data, agendamentos.Hora, profissionais.NomeProfissional, IFNULL(TIME(logsmarcacoes.DataHora),'') as 'HoraChegada' FROM agendamentos LEFT JOIN profissionais ON profissionais.id=agendamentos.ProfissionalID LEFT JOIN logsmarcacoes ON logsmarcacoes.ConsultaID=agendamentos.id AND Sta=4 AND ARX='R' AND logsmarcacoes.Obs LIKE '%status.%' WHERE agendamentos.Data=CURDATE() AND agendamentos.PacienteID="&treatvalzero(PacienteID)&" LIMIT 1")
	    camposASubs = "Data, Hora, NomeProfissional, HoraChegada"
        correSubs = split(camposASubs, ", ")
	    if not AgendamentoSQL.eof then
            for corre=0 to ubound(correSubs)
                AgendamentoTag = AgendamentoSQL(""&correSubs(corre)&"")
                if correSubs(corre) = "Hora" then
                    AgendamentoTag = formatdatetime(AgendamentoTag, 4)
                end if
                valor = replace(valor, "[Agendamento."&correSubs(corre)&"]", AgendamentoTag&"" )
            next

            PreValor = valor
            if instr(PreValor, "[Agendamentos.Iniciar]")>0 and instr(PreValor, "[Agendamentos.Finalizar]")>0 then
            'response.write("oi")
                splItens = split(PreValor, "[Agendamentos.Iniciar]")
                splItens2 = split(splItens(1), "[Agendamentos.Finalizar]")
                modeloItens = splItens2(0)
                EsteItem = ""
                AgendamentosItens = ""
                set ii = db.execute("SELECT profissionais.NomeProfissional, convenios.NomeConvenio, procedimentos.NomeProcedimento, agendamentos.TipoCompromissoID,agendamentos.ValorPlano,agendamentos.rdValorPlano FROM agendamentos "&_
                                     "INNER JOIN procedimentos ON procedimentos.id=agendamentos.TipoCompromissoID "&_
                                     "INNER JOIN profissionais ON profissionais.id=agendamentos.ProfissionalID "&_
                                     "LEFT JOIN convenios ON convenios.id=agendamentos.ValorPlano AND agendamentos.rdValorPlano='P' "&_
                                     "WHERE agendamentos.id="&AgendamentoSQL("id")&"	 "&_
                                     "union "&_
                                     "SELECT profissionais.NomeProfissional, convenios.NomeConvenio, procedimentos.NomeProcedimento, agendamentosprocedimentos.TipoCompromissoID,agendamentosprocedimentos.ValorPlano,agendamentosprocedimentos.rdValorPlano FROM agendamentosprocedimentos "&_
                                     "INNER JOIN agendamentos ON agendamentos.id=agendamentosprocedimentos.AgendamentoID "&_
                                     "INNER JOIN procedimentos ON procedimentos.id=agendamentosprocedimentos.TipoCompromissoID "&_
                                     "INNER JOIN profissionais ON profissionais.id=agendamentos.ProfissionalID "&_
                                     "LEFT JOIN convenios ON convenios.id=agendamentosprocedimentos.ValorPlano AND agendamentosprocedimentos.rdValorPlano='P' "&_
                                     "WHERE agendamentosprocedimentos.AgendamentoID="&AgendamentoSQL("id"))
                while not ii.eof
                    EsteItem = replace(modeloItens, "[Procedimento.Nome]", ii("NomeProcedimento")&"")
                    if ii("rdValorPlano")="V" then
                        EsteItem = replace(EsteItem, "[Procedimento.Pagamento]", "R$ "&fn(ii("ValorPlano"))&"")
                    else
                        EsteItem = replace(EsteItem, "[Procedimento.Pagamento]", ii("NomeConvenio")&"")
                    end if
                    EsteItem = replace(EsteItem, "[Profissional.Nome]", ii("NomeProfissional")&"")
                    AgendamentosItens = AgendamentosItens & EsteItem
                ii.movenext
                wend
                ii.close
                set ii=nothing

                valor = splItens(0) & AgendamentosItens & splItens2(1)
                valor = replace(valor, "[Agendamentos.Listagem]", AgendamentosItens)

            end if
        else
            for corre=0 to ubound(correSubs)
                valor = replace(valor, "[Agendamento."&correSubs(corre)&"]", "-" )
            next
            valor = replace(valor, "[Agendamento.Pagamento]", "-" )
            valor = replace(valor, "[Agendamento.Nome]", "-" )
            valor = replace(valor, "[Agendamentos.Iniciar]", "-" )
            valor = replace(valor, "[Agendamentos.Finalizar]", "-" )
            valor = replace(valor, "[Procedimento.Nome]", "-" )
            valor = replace(valor, "[Procedimento.Pagamento]", "-" )
	    end if
	end if

	if isnull(UnidadeID) or UnidadeID="" then
	    UnidadeID=0
	end if

	if instr(valor, "[Unidade.")>0 then
        valor = valor&""
		if UnidadeID=0 then
			sql = "select *, NomeEmpresa Nome from empresa"
		else
			sql = "select *, unitName Nome from sys_financialcompanyunits where id="&UnidadeID
		end if
		camposASubs = "Nome, NomeFantasia, Endereco, Numero, Complemento, Bairro, Cidade, Cep, Estado, Tel1, Cel1, Email1, CNPJ, CNES, Coordenadas, Sigla"
		correSubs = split(camposASubs, ", ")
		set registro = db.execute(sql)
		for corre=0 to ubound(correSubs)
			valor = replace(valor, "[Unidade."&correSubs(corre)&"]", registro(""&correSubs(corre)&"")&"" )
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
    if device()="" then
        header = header & "$("".crumb-icon a"").html(""<span class='far fa-"&dIcone(recurso)&"'></span>"");"
    else
        header = header & "$("".crumb-icon a"").html(""<span class='far fa-"&dIcone(recurso)&"'></span> "& ucase(titulo) &""");"
    end if

'	header = header & "<div class=""widget-box transparent""><div class=""widget-header widget-header-flat"">"
'    header = header & "    <h4><i class=""far fa-"&dIcone(recurso)&" blue""></i> "&titulo&"</h4>"
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
					rbtns = rbtns & "<a title='Anterior' href='?P=invoice&T="&req("T")&"&Pers="&hPers&"&I="&lista("anterior")&"' class='btn btn-sm btn-default hidden-xs'><i class='far fa-chevron-left'></i></a> "
				end if
				if aut(recursoPerm&"V") then
				    rbtns = rbtns & "<a title='Lista' href='?P=ContasCD&Buscar=1&T="&req("T")&"&Pers=1' class='btn btn-sm btn-default'><i class='far fa-list'></i></a> "
				end if
				if not isnull(lista("proximo")) and aut(recursoPerm&"V") then
					rbtns = rbtns & "<a title='Próximo' href='?P=invoice&T="&req("T")&"&Pers="&hPers&"&I="&lista("proximo")&"' class='btn btn-sm btn-default hidden-xs'><i class='far fa-chevron-right'></i></a> "
				end if
			end if
		end if
		if aut(recursoPerm&"I")=1 then
			rbtns = rbtns & "<a title='Nova' href='?P=invoice&Pers="&hPers&"&I=N&T="&req("T")&"' class='btn btn-sm btn-default'><i class='far fa-plus'></i></a> "
		end if
        'response.Write(recursoPerm)
		if (hsysActive=1 and aut(recursoPerm&"A")=1) or (hsysActive=0 and aut(recursoPerm&"I")=1) or (aut("aberturacaixinhaI") and session("CaixaID")<>"" and hsysActive=0) or (hsysActive=1 and data("CaixaID")=session("CaixaID") and aut("aberturacaixinhaA")) or (aut("contasareceberI")=0 and aut("areceberpacienteI")) then
				rbtns = rbtns & "<button class='btn btn-sm btn-primary' type='button' onclick='$(\""#btnSave\"").click()'>&nbsp;&nbsp;<i class='far fa-save'></i> <strong> SALVAR</strong>&nbsp;&nbsp;</button> "

		end if

		if req("T")="D" then
			nomePerm = "contasapagar"
			rbtns = rbtns & "&nbsp <div class='btn-group'>     <button type='button' class='btn-sm btn btn-success dropdown-toggle' data-toggle='dropdown'><span class='far fa-upload'></span></button> <ul class='dropdown-menu' role='menu'>    <li><a onclick='addBoleto("&hid&")' href='#'>Boleto</a></li>      <li><a onclick='addXmlNFe("&hid&")' href='#'>NF-e</a></li>  <li><a onclick='cnabBeta("&hid&")' href='#'>Cnab <label class='label label-primary'>Beta</label></a></li>   </ul>  </div> &nbsp"
		    rbtns = rbtns & "<button class='btn btn-info btn-sm' onclick='imprimirReciboInvoice()' type='button'><i class='far fa-print bigger-110'></i></button>"
		else
			nomePerm = "contasareceber"
		    rbtns = rbtns & "<button type='button' class='btn btn-info btn-sm rgrec' title='Gerar recibo' onClick='listaRecibos()'><i class='far fa-print bigger-110'></i></button>"

            set vcaCont = db.execute("select id, NomeModelo from contratosmodelos WHERE (sysActive=1) AND (UrlContrato='' OR UrlContrato IS NULL)")
            if not vcaCont.eof then
                rbtns = rbtns & " <div class='btn-group contratobloqueio'><button class='btn btn-info btn-sm dropdown-toggle contratobt'><i class='far fa-file'></i></button>"
                rbtns = rbtns & "<ul class='dropdown-menu dropdown-info pull-right' style='overflow-y: scroll; max-height: 400px;'>"
                while not vcaCont.eof
                    rbtns = rbtns & "<li><a href='javascript:addContrato("&vcaCont("id")&", "&hid&", $(\""#AccountID\"").val())'><i class='far fa-plus'></i> "&vcaCont("NomeModelo")&"</a></li>"
                vcaCont.movenext
                wend
                vcaCont.close
                set vcaCont=nothing
                rbtns = rbtns & "<li class='divider'></li><li><a href='javascript:addContrato(0, "&hid&", $(\""#AccountID\"").val())'>Contratos Gerados</a></li>"

                rbtns = rbtns & "</ul></div>"
            end if

		end if
        set RecursosAdicionaisSQL = db.execute("SELECT SplitNF FROM sys_config WHERE id=1")

        if not RecursosAdicionaisSQL.eof then
            if False then
                if recursoAdicional(7)=4 then
                    'if session("Banco") = "clinic2496" OR session("Banco") = "clinic100000" OR session("Banco") = "clinic4285" OR session("Banco") = "clinic984" OR session("Banco") = "clinic2263" Then
                    if RecursosAdicionaisSQL("SplitNF")<>1 then
                        rbtns = rbtns & "&nbsp; <button id='btn_NFe' title='Nota Fiscal' class='btn btn-warning btn-sm' onclick='modalNFE()' type='button'><i class='far fa-file-text bigger-110'></i></button>"
                    end if
                End if
            end if
	        if recursoAdicional(34)=4 then
                rbtns = rbtns & "&nbsp; <button id='btn_NFeBeta' title='Nota Fiscal' class='btn btn-warning btn-sm' onclick='modalNFEBeta()' type='button'><i class='far fa-file-text bigger-110'></i></button>"
            end if
	    End if
		if aut(nomePerm&"X") or data("CaixaID")=session("CaixaID") then
		    PermissaoExclusao=True
        elseif data("CD")="D" and aut("|repassesX|")=1 then
            set InvoiceRepasseSQL = db.execute("SELECT rr.id FROM itensinvoice ii  "&_
                                               "INNER JOIN rateiorateios rr ON rr.ItemContaAPagar=ii.id "&_
                                               "WHERE ii.InvoiceID="&data("id")&" LIMIT 1")

            if not InvoiceRepasseSQL.eof then
                PermissaoExclusao=True
            end if
		end if

		if PermissaoExclusao then
            rbtns = rbtns & "&nbsp; <button class='btn btn-danger btn-sm disable' onclick='deleteInvoice()' type='button'><i class='far fa-trash bigger-110'></i></button>"
		end if

'		rbtns = rbtns & "</div></div></div></div>"
        header = header & "$(""#rbtns"").html("""& rbtns &""")"
'        header = header & "});</script>"
        header = header & "</script>"
	    realSave = "<button class=""btn btn-sm btn-primary hidden"" id=""btnSave"">&nbsp;&nbsp;<i class=""far fa-save""></i> <strong> SALVAR</strong>&nbsp;&nbsp;</button>"






	else
		if isnumeric(hid) then
			set nomeColuna = db.execute("select initialOrder from cliniccentral.sys_resources where tableName='"&recurso&"' limit 1")

            if recurso="pacientes" then
'                rbtns = rbtns & "<div class='switch switch-info switch-inline'>  <input id='exampleCheckboxSwitch1' type='checkbox' checked=''>  <label for='exampleCheckboxSwitch1'></label></div>"
                rbtns = rbtns & "<div title='Ativar / Inativar paciente' class='mn hidden-xs' style='float:left'><div class='switch switch-info switch-inline'><input checked name='Ativo' id='Ativo' type='checkbox' /><label style='height:26px' class='mn' for='Ativo'></label></div></div> &nbsp; "
            end if

            if aut("|profissionaisV|")=1 then
                rbtns = rbtns & "<a title='Anterior' href='ListagemPaginacao.asp?P="&recurso&"&Identifier="&nomeColuna("initialOrder")&"&Pers="&hPers&"&Operation=Previous&I="&hid&"' class='btn btn-sm btn-default hidden-xs'><i class='far fa-chevron-left'></i></a> "
                rbtns = rbtns & "<a id='Header-List' title='Lista' href='?P="&recurso&"&Pers="&hPersList&"' class='btn btn-sm btn-default'><i class='far fa-list'></i></a> "
                rbtns = rbtns & "<a title='Próximo' href='ListagemPaginacao.asp?P="&recurso&"&Identifier="&nomeColuna("initialOrder")&"&Pers="&hPers&"&Operation=Next&I="&hid&"' class='btn btn-sm btn-default hidden-xs'><i class='far fa-chevron-right'></i></a> "
            end if
		end if
		if aut(recurso&"I")=1 and recurso<>"profissionais" and recurso<>"funcionarios" then
			rbtns = rbtns & "<a id='Header-New' title='Novo' href='?P="&recurso&"&Pers="&hPers&"&I=N' class='btn btn-sm btn-default'><i class='far fa-plus'></i></a> "
		end if
		if recurso="pacientes" then
			rbtns = rbtns & "<button title='Imprimir Ficha' type='button' id='btnFicha' class='btn btn-sm btn-default hidden-xs'><i class='far fa-print'></i></button> "
			rbtns = rbtns & "<button title='Compartilhar Dados' type='button' id='btnCompartilhar' class='btn btn-sm btn-default hidden-xs'><i class='far fa-share-alt'></i></button> "
		end if
		rbtns = rbtns & "<a title='Histórico de Alterações' href='javascript:log()' class='btn btn-sm btn-default hidden-xs'><i class='far fa-history'></i></a> "
		'rbtns = rbtns & "<script>function log(){$('#modal-table').modal('show');$.get('DefaultLog.asp?R="&recurso&"&I="&hid&"', function(data){$('#modal').html(data);})}</script>"
		if recurso<>"profissionais" and recurso<>"funcionarios" and recurso<>"fornecedores" then
			if (hsysActive=1 and aut(recurso&"A")=1) or (hsysActive=0 and aut(recurso&"I")=1) then
					rbtns = rbtns & "<button class='btn btn-sm btn-primary' type='button' id='Salvar' onclick='$(\""#save\"").click()'>&nbsp;&nbsp;<i class='far fa-save'></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button> "
            else
                    %>
                    </form>
                    <form>
                    <script>
                    $(function() {
                        $("#content form")
                        .removeAttr("action")
                        .removeAttr("id")
                        .removeAttr("method")
                        .removeAttr("name")
                        .attr("onsubmit","return false");
                        
                        $(window).keydown(function(event){
                            if( (event.keyCode == 13)) {
                                if( $("#sidebar-search").is(':focus')){
                                    return true;
                                }
                                event.preventDefault();
                                return false;
                                }
                         });
                    });
                    </script>
                    <%
			end if
		end if
        header = header & "$(""#rbtns"").html("""& rbtns &""")"
'        header = header & "});</script>"
        header = header & "</script>"
		header = header & "<script>function log(){openComponentsModal('DefaultLog.asp?Impressao=1&R="&recurso&"&I="&hid&"', {},'Log de alterações', true)}</script>"
	    realSave = "<button class=""btn btn-sm btn-primary hidden"" id=""save"">&nbsp;&nbsp;<i class=""far fa-save""></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button>"


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
    PacienteID = round(PacienteID)
	if not isnull(ConvenioID) and isnumeric(ConvenioID) then
		set valConv = db.execute("select * from tissprocedimentosvalores where ProcedimentoID="&treatvalzero(ProcedimentoID)&" and ConvenioID="&treatvalzero(ConvenioID))
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

function dataGoogleNovo(Data, Hora, FusoHorario)
	dt = formatdatetime(Data, 2)
	dataGoogleNovo = right(dt, 4)&"-"&mid(dt, 4, 2)&"-"&left(dt, 2) &"T"&formatdatetime(Hora, 3)&".000"&FusoHorario
'	2016-03-15T10:25:00.000-03:00
end function

function isHorarioVerao()
    isHorarioVerao=False
end function

function googleCalendarNovo(Acao, Email, AgendamentoID, ProfissionalID, NomePaciente, Data, Hora, Tempo, NomeProcedimento, Notas, FusoHorario)
	if Email="vca" then
		set vca = db.execute("select * from profissionais where id = '"&ProfissionalID&"'")
		if not vca.EOF then
			if vca("GoogleCalendar")<>"" and instr(vca("GoogleCalendar"), "@")>0 then
				Email = vca("GoogleCalendar")
			end if
		end if
	end if
	if NomePaciente="" and Email<>"vca" and Acao<>"X" and isnumeric(AgendamentoID) and AgendamentoID<>"" then
		set dadosAge = db.execute("select a.LocalID, a.Data, a.Hora, a.Tempo, pac.NomePaciente, proc.NomeProcedimento from agendamentos a LEFT JOIN pacientes pac on pac.id=a.PacienteID LEFT JOIN procedimentos proc on proc.id=a.TipoCompromissoID WHERE a.id="&AgendamentoID)
		if not dadosAge.EOF then
			NomePaciente = dadosAge("NomePaciente")
			Data = dadosAge("Data")

			SubtrairHoras = -1

			'if session("Banco") = "clinic3776" then
			 '   Hora = dadosAge("Hora")
            ' else
                Hora = dateadd("h", SubtrairHoras,dadosAge("Hora"))
			'end if
           ' response.write("<br>")
           ' response.write(Hora)
			Tempo = dadosAge("Tempo")
			NomeProcedimento = dadosAge("NomeProcedimento")
		end if
	end if
	if Tempo="" or isnull(Tempo) or Tempo="0" or not isnumeric(Tempo) then
		Tempo=15
	end if
	if Acao="I" and Email<>"vca" and NomePaciente<>"" then
		Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
         '   response.write(Hora)
          '  response.write("<br>")
         
			Inicio = dataGoogleNovo(Data, Hora, FusoHorario)
            '    response.write(Inicio)
           '     response.write("<br>")
			HoraFinal = dateadd("n", Tempo, Hora)
			Fim = dataGoogleNovo(Data, HoraFinal, FusoHorario)
			objWinHttp.Open "GET", "https://app.feegow.com/v7-master/calendar/salvar_dados.php?Email="&Email&"&AgendamentoID="&AgendamentoID&"&NomePaciente="&NomePaciente&"&Inicio="&Inicio&"&Fim="&Fim&"&NomeProcedimento="&NomeProcedimento
		objWinHttp.Send
		resposta = objWinHttp.ResponseText
		'response.write(resposta)
	'	response.end
		db_execute("insert into googleagenda (AgendamentoID, ProfissionalID, GoogleID) values ("&AgendamentoID&", "&ProfissionalID&", '"&resposta&"')")
		Set objWinHttp = Nothing
	elseif Acao="X" then
		set vcaAge = db.execute("select * from googleagenda where AgendamentoID="&AgendamentoID)
		if not vcaAge.EOF then
		    GoogleID=vcaAge("GoogleID")
			Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
				objWinHttp.Open "GET", "https://app.feegow.com/v7-master/calendar/excluir_dados.php?EventoID="&GoogleID
			objWinHttp.Send
			resposta = objWinHttp.ResponseText
			db_execute("delete from googleagenda where AgendamentoID="&AgendamentoID)
			Set objWinHttp = Nothing
		end if
	end if
end function

function googleCalendar(Acao, Email, AgendamentoID, ProfissionalID, NomePaciente, Data, Hora, Tempo, NomeProcedimento, Notas)
	if Email="vca" then
		set vca = db.execute("select * from profissionais where id = '"&ProfissionalID&"'")
		if not vca.EOF then
			if vca("GoogleCalendar")<>"" and instr(vca("GoogleCalendar"), "@")>0 then
				Email = vca("GoogleCalendar")
			end if
		end if
	end if
	if NomePaciente="" and Email<>"vca" and Acao<>"X" and isnumeric(AgendamentoID) and AgendamentoID<>"" then
		set dadosAge = db.execute("select a.LocalID, a.Data, a.Hora, a.Tempo, pac.NomePaciente, proc.NomeProcedimento from agendamentos a LEFT JOIN pacientes pac on pac.id=a.PacienteID LEFT JOIN procedimentos proc on proc.id=a.TipoCompromissoID WHERE a.id="&AgendamentoID)
		if not dadosAge.EOF then
			NomePaciente = dadosAge("NomePaciente")
			Data = dadosAge("Data")

			SubtrairHoras = 0'-1

			'if session("Banco") = "clinic3776" then
			 '   Hora = dadosAge("Hora")
            ' else
                Hora = dateadd("h", SubtrairHoras,dadosAge("Hora"))
			'end if
           ' response.write("<br>")
           ' response.write(Hora)
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
			objWinHttp.Open "GET", "https://app.feegow.com/v7-master/calendar/salvar_dados.php?Email="&Email&"&AgendamentoID="&AgendamentoID&"&NomePaciente="&NomePaciente&"&Inicio="&Inicio&"&Fim="&Fim&"&NomeProcedimento="&NomeProcedimento
		objWinHttp.Send
		resposta = objWinHttp.ResponseText
		db_execute("insert into googleagenda (AgendamentoID, ProfissionalID, GoogleID) values ("&AgendamentoID&", "&ProfissionalID&", '"&resposta&"')")
		Set objWinHttp = Nothing
	elseif Acao="X" then
		set vcaAge = db.execute("select * from googleagenda where AgendamentoID="&AgendamentoID)
		if not vcaAge.EOF then
		    GoogleID=vcaAge("GoogleID")
			Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
				objWinHttp.Open "GET", "https://app.feegow.com/v7-master/calendar/excluir_dados.php?EventoID="&GoogleID
				'response.Write("http://localhost/feegowclinic/calendar/excluir_dados.php?EventoID="&GoogleID)
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

'para tablets etc
function mobileDevice()
	agente = lcase(request.ServerVariables("HTTP_USER_AGENT"))
	if instr(agente, "iphone")>0 then
		mobileDevice = "Iphone"
	elseif instr(agente, "android")>0 then
		mobileDevice = "Android"
	elseif instr(agente, "ipad")>0 then
		mobileDevice = "IPad"
	elseif instr(agente, "tablet")>0 then
		mobileDevice = "Tablet"
	else
		mobileDevice = ""
	end if
end function

function db_execute(txt)
executeInReadOnly = False

    sqlStatement = txt

    if sqlStatement&""<>"" then
        tipoLog = split(sqlStatement, " ")(0)
        tipoLog = LCase(tipoLog)
        recursoLog = split(sqlStatement, " ")(1)
        recursoLog = LCase(recursoLog)
    end if

    if tipoLog = "select" then
        executeInReadOnly = True
    end if
    if executeInReadOnly and False then
        set db_execute = dbReadOnly.execute(sqlStatement)
    else
        set db_execute = db.execute(sqlStatement)
    end if

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
	objWinHttp.Open "GET", "https://app.feegow.com/base/RTFtoHTML.php?banco="&session("banco")&"&tabela="&limtabela&"&coluna="&limcoluna&"&id="&limid &"&IP="& sServidor
	objWinHttp.Send
	strHTML = objWinHttp.ResponseText
	Set objWinHttp = Nothing
	Valor = trim(Valor)
	Valor = replace(strHTML, chr(10), "<br>")

	db_execute("update `"&limtabela&"` set `"&limcoluna&"`='"&rep(Valor)&"' where id="&limid)
end function

function btnParcela(MovimentacaoID, ValorPago, Valor, Vencimento, CD, CaixaID)
	input = "<label style='margin-bottom:0'>"
    if CD="C" then
         permInv = "|contasareceberI|"
   else
		permInv = "|contasapagarI|"
    end if
    if aut(permInv) OR (session("CaixaID")<>"" and aut("|aberturacaixinhaI|")) then
        input = input & "<input style='margin:0' id=""Parcela"&MovimentacaoID&""" type=""checkbox"" class=""ace parcela"" value=""|"&MovimentacaoID&"|"" name=""Parcela"" ><span class=""lbl""></span> "
    elseif aut(permInv)=0 and session("CaixaID")="" and aut("|aberturacaixinhaI|") then
        input = input & "<input style='margin:0' id=""Parcela"&MovimentacaoID&""" type=""checkbox"" class=""ace"" value=""|"&MovimentacaoID&"|"" onclick=""alert('Você está com seu caixa fechado. Por favor, abra seu caixa para pagar esta conta.')"" ><span class=""lbl""></span> "
    else
        input = input & "</label>"

        've se eh conta a receber de paciente
        if aut("|areceberpacienteI|") then
            set MovementAccountTypeSQL = db.execute("SELECT AccountAssociationIDCredit FROM sys_financialmovement WHERE AccountAssociationIDDebit = 3 AND id ="&MovimentacaoID)

            if not MovementAccountTypeSQL.eof then
                input = input & "<input style='margin:0' id=""Parcela"&MovimentacaoID&""" type=""checkbox"" class=""ace parcela"" value=""|"&MovimentacaoID&"|"" name=""Parcela"" ><span class=""lbl""></span> "
            end if
        end if
    end if

	if ValorPago=0 and Valor >0 or MovimentacaoID=-1 then
		classe = "danger"
		txt = input & "R$ <span id='pend"&MovimentacaoID&"'>" &  fn( Valor ) &"</span>"
	'elseif ValorPago>0 and ValorPago+0.3<Valor then
    elseif ValorPago>0 and ValorPago+0.02<Valor then
		classe = "warning parte-paga"
		txt = input & "<span id='pend"&MovimentacaoID&"'>" &  fn( Valor-ValorPago ) &" de " &  fn( Valor ) &"</span>"
	else
		classe = "success parte-paga"
		txt = "<i class=""far fa-check""></i> R$ <span id='pend"&MovimentacaoID&"'>" &  fn( Valor ) &"</span>"
	end if
    if Vencimento<>"" then
        spanVenc = " title=""Vencimento: "&Vencimento&""" "
    else
        spanVenc = ""
    end if
    if MovimentacaoID>0 then
        zoom = "<a class='btn btn-xs btn-default' title='Ver detalhes' href=""javascript:modalPaymentDetails('"&MovimentacaoID&"');""> <i class=""far fa-search-plus bigger-140 white""></i></a>"
        btnAnexo = "<a class='btn btn-xs btn-system' style='float:right' href=""javascript:modalPaymentAttachments('"&MovimentacaoID&"');"" title='Anexar um arquivo'> <i class=""far fa-paperclip bigger-140 white""></i></a>"
    else
        zoom = ""
        btnAnexo= ""
        btnTef=""
    end if

	btnParcela = "<div class='btn-group btn-group-movement'><span "& spanVenc &" class='btn btn-xs btn-"&classe&" text-right'>"&txt &"</span>"&zoom& btnAnexo &"</div>"

	btnParcela = btnParcela
end function

function inputsRepasse(ItemID, FormaID, ProfissionalID, ProcedimentoID, UnidadeID)
    %>
    alert(<%=dominioRepasse(FormaID, ProfissionalID, ProcedimentoID, UnidadeID, "") %>);
    <%
end function

function salvaRepasse(LinhaID, ItemID)
    gLinhaID = LinhaID
    gItemID = ItemID
    'verifica se este item da invoice teve algum repasse q ja foi pro contas a pagar. se tiver, nao mexe mais nos repasses que foram consolidados pra este item
    set vcaLancado = db.Execute("select * from rateiorateios where not isnull(ItemContaAPagar) and ItemInvoiceID="&gItemID)
    if vcaLancado.eof then
        set ii = db.execute("select ii.*, i.CompanyUnitID UnidadeID, i.FormaID, i.ContaRectoID, i.TabelaID from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID where ii.id="&gItemID)
        DominioID = dominioRepasse(ii("FormaID")&"_"&ii("ContaRectoID"), ii("ProfissionalID"), ii("ItemID"), ii("UnidadeID"), ii("TabelaID"), ii("EspecialidadeID"))
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


       if ConvenioID<>"" then
            sqlProdutoValor = "SELECT p.*, tpp.Quantidade,IF (tpt.Valor = 0, tpv.Valor,tpt.Valor)Valor,tpt.TabelaID,tpt.Codigo,tpt.ProdutoID,p.Codigo as CodigoNoFabricante FROM tissprocedimentosvalores pv LEFT JOIN tissprodutosprocedimentos tpp ON tpp.AssociacaoID=pv.id LEFT JOIN tissprodutostabela tpt ON tpt.id=tpp.ProdutoTabelaID LEFT JOIN tissprodutosvalores tpv ON tpv.ProdutoTabelaID=tpt.id AND tpv.ConvenioID=pv.ConvenioID LEFT JOIN produtos p ON p.id = tpt.ProdutoID WHERE pv.ProcedimentoID= "&pProcGSID("ProcedimentoID")&" AND pv.ConvenioID="&  ConvenioID

           set ProdutoValorSQL = db.execute(sqlProdutoValor)

           if not ProdutoValorSQL.eof then
                while not ProdutoValorSQL.eof
                    Valor = ProdutoValorSQL("Valor")
                    Quantidade = ProdutoValorSQL("Quantidade")
                    ValorTotalProduto = Quantidade *  Valor

                    if Valor > 0 then
                        sql = "insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("& treatvalnull(pProcGSID("GuiaID")) &", "&treatvalzero(ProdutoValorSQL("CD"))&", "&myDateNULL( pProcGSID("Data") )&", "&myTime(pProcGSID("HoraInicio"))&", "&myTime(pProcGSID("HoraFim"))&", "&treatvalzero(ProdutoValorSQL("ProdutoID"))&", "&treatvalzero(ProdutoValorSQL("TabelaID"))&", '"&ProdutoValorSQL("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(ProdutoValorSQL("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotalProduto)&", '"&ProdutoValorSQL("RegistroANVISA")&"', '"&ProdutoValorSQL("CodigoNoFabricante")&"', '"&ProdutoValorSQL("AutorizacaoEmpresa")&"', '"&rep(ProdutoValorSQL("NomeProduto"))&"')"
                        'response.write( sql )
                        db.execute( sql )
                    end if
                ProdutoValorSQL.movenext
                wend
                ProdutoValorSQL.close
                set ProdutoValorSQL = nothing
           end if



           ' nova por kit ate morrer ----------------
           sqlKit="select pckit.*,pkit.id, pkit.TabelaID  from procedimentoskits pckit left join produtoskits pkit on pckit.KitID=pkit.id where pckit.ProcedimentoID="& pProcGSID("ProcedimentoID") &" and (pckit.Casos like '%|ConvALL|%' OR (pckit.Casos like '%|ConvEXCEPT|%' and not pckit.Casos like '%|"&ConvenioID&"|%') OR (pckit.Casos like '%|ConvONLY|%' and pckit.Casos like '%|"&ConvenioID&"|%'))"
           set KitSQL = db.execute(sqlKit)
           if not KitSQL.eof then
                 while not KitSQL.eof
                    TabelaID = KitSQL("TabelaID")
                    sqlProdutosDoKit = "select p.*, pt.Codigo, pt.Valor, pt.TabelaID, pt.id ProdutoTabelaID, p.Codigo as CodigoNoFabricante, pt.ProdutoID ,pdk.Quantidade FROM produtosdokit pdk LEFT JOIN produtos p ON p.id=pdk.ProdutoID LEFT JOIN tissprodutostabela pt ON pt.ProdutoID=p.id WHERE NOT ISNULL(p.NomeProduto) AND pdk.KitID="& KitSQL("KitID") &" GROUP BY p.id ORDER BY p.NomeProduto"
                    ' response.write(sqlProdutosDoKit)
                    set ProdutosKitSQL = db.execute(sqlProdutosDoKit)

                    while not ProdutosKitSQL.eof
                        Valor = ProdutosKitSQL("Valor")
                        if not isnull(ProdutosKitSQL("ProdutoTabelaID")) then
                            set ProdutoValorSQL = db.execute("select * from tissprodutosvalores pv where pv.ConvenioID="& ConvenioID &" and pv.ProdutoTabelaID="& ProdutosKitSQL("ProdutoTabelaID"))
                            if not ProdutoValorSQL.eof then
                                Valor = ProdutoValorSQL("Valor")
                            end if
                        end if
                        Quantidade = ProdutosKitSQL("Quantidade")
                        ValorTotalProduto = Quantidade *  Valor

                        if Valor>0 then
                            db_execute("insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&treatvalnull(GuiaID)&", "&treatvalzero(ProdutosKitSQL("CD"))&", "&myDateNULL(pProcGSID("Data"))&", "&myTime(pProcGSID("HoraInicio"))&", "&myTime(pProcGSID("HoraFim"))&", "&treatvalzero(ProdutosKitSQL("ProdutoID"))&", "&treatvalzero(ProdutosKitSQL("TabelaID"))&", '"&ProdutosKitSQL("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(ProdutosKitSQL("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotalProduto)&", '"&ProdutosKitSQL("RegistroANVISA")&"', '"&ProdutosKitSQL("CodigoNoFabricante")&"', '"&ProdutosKitSQL("AutorizacaoEmpresa")&"', '"&rep(ProdutosKitSQL("NomeProduto"))&"')")
                        end if
                     ProdutosKitSQL.movenext
                     wend
                     ProdutosKitSQL.close
                     set ProdutosKitSQL = nothing
                 KitSQL.movenext
                 wend
                 KitSQL.close
                 set KitSQL = nothing
           end if
       end if

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
    if session("OtherCurrencies")="phone" or recursoAdicional(9) = 4 or recursoAdicional(21) = 4 or recursoAdicional(4) = 4 then
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

function dispEquipamento(Data, Hora, Intervalo, EquipamentoID, AgendamentoID)
    dispEquipamento = ""
    
    if AgendamentoID&"" <> "" then
        andAgendamentoID = " AND a.id <>"&AgendamentoID
    end if

    if isnumeric(Intervalo) and Intervalo<>"" and not isnull(Intervalo) then
        Intervalo = ccur(Intervalo)
    else
        Intervalo = 0
    end if
    HoraFinal = dateadd("n", Intervalo, Hora)
    if isnumeric(EquipamentoID) and EquipamentoID<>"" and not isnull(EquipamentoID) then
        if ccur(EquipamentoID)<>0 then
            sqlDisp = "SELECT a.Hora, a.HoraFinal, p.NomeProfissional FROM agendamentos a LEFT JOIN profissionais p on p.id=a.ProfissionalID WHERE a.sysActive=1 AND a.StaID not in(11) and a.Data="&mydatenull(Data)&" AND "&_
                    "("&_
                    "("&mytime(Hora)&">=a.Hora AND "&mytime(Hora)&"< ADDTIME(a.Hora, SEC_TO_TIME(a.Tempo*59.99)))"&_
                    " OR "&_
                    "("&mytime(HoraFinal)&">a.Hora AND "&mytime(HoraFinal)&"< ADDTIME(a.Hora, SEC_TO_TIME(a.Tempo*59.99)))"&_
                    " OR "&_
                    "("&mytime(Hora)&"<a.Hora AND "&mytime(HoraFinal)&"> ADDTIME(a.Hora, SEC_TO_TIME(a.Tempo*59.99)))"&_
                    " OR "&_
                    "("&mytime(Hora)&"=a.Hora)"&_
                    ") AND a.EquipamentoID="&EquipamentoID&andAgendamentoID
                    
            'response.Write(sqlDisp)

            if getConfig("LiberarEncaixeEquipamentos") <> "1" then
                set vcaAgEq = db.execute(sqlDisp)
                if not vcaAgEq.eof then
                    dispEquipamento = "Este equipamento já está agendado para o profissional "&vcaAgEq("NomeProfissional")&" nesta data entre as "&formatdatetime(vcaAgEq("Hora"),4)&" e "&formatdatetime(vcaAgEq("HoraFinal"),4)
                end if
            end if
        end if
    end if
    ' dispEquipamento = ""
end function

function replacePagto(txt, Total)
	on error resume next
	'response.Write(txt&"<hr>")
	txt = trim(txt&" ")
	'priameiro separa todas as tags que existem na expressao
	spl = split(txt, "{{")
	for i=0 to ubound(spl)
		if instr(spl(i), "}}")>0 then
			spl2 = split(spl(i), "}}")
			Crua = spl2(0)
			Formula = lcase(Crua)
			Formula = replace(Formula, "total", treatvalnull(Total))
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
        sql = "select * from invoicesfixas where coalesce(TipoContaFixaID<>2,true) And PrimeiroVencto<=date(now()) and (isnull(RepetirAte) or RepetirAte>=date(now())) and sysActive=1"
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
                set pult = db.execute("select id from sys_financialinvoices where FixaID="&fx("id")&" order by id desc LIMIT 1")
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
                db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Descricao, Executado, sysUser,CentroCustoID)  (select '"&pult("id")&"', Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Descricao, Executado, sysUser,CentroCustoID from itensinvoicefixa where InvoiceID="&fx("id")&")")
                db_execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, ValorPago, UnidadeID) values ("&AccountAssociationIDCredit&", "&AccountIDCredit&", "&AccountAssociationIDDebit&", "&AccountIDDebit&", "&treatvalzero(fx("Value"))&", "&mydatenull(Vencto)&", '"&fx("CD")&"', 'Bill', 'BRL', 1, "&pult("id")&", 1, "&fx("sysUser")&", 0, "&fx("CompanyUnitID")&")")

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
    if instr(Para, "-") > 0 then

        UserIdSpl = split(replace(Para, "|", ""), ",")

        for j=0 to ubound(UserIdSpl)
            itemSPL = UserIdSpl(j)

            if instr(itemSPL, "-") > 0 then
                itemSPL = replace(itemSPL,"-", "")
                UsuariosIdSQL = "SELECT GROUP_CONCAT('|',Usuarios,'|') Usuarios FROM( "&_
                                "    SELECT up.id Usuarios "&_
                                "    FROM profissionais p "&_
                                "    LEFT JOIN sys_users up ON up.idInTable=p.id "&_
                                "    WHERE p.CentroCustoID = "&itemSPL&_
                                "    UNION ALL "&_
                                "    SELECT uf.id  "&_
                                "    FROM funcionarios f "&_
                                "    LEFT JOIN sys_users uf ON uf.idInTable=f.id "&_
                                "    WHERE f.CentroCustoID = "&itemSPL&_
                                " ) AS t"

                set UsuariosID = db.execute(UsuariosIdSQL)
                if j = 0 then
                    itemID = UsuariosID("Usuarios")
                else
                    itemID = itemID&","&UsuariosID("Usuarios")
                end if
            else
                itemID = itemID&",|"&trim(itemSPL)&"|"
            end if
        next
    else
        itemID = Para
    end if
'   Retirando valores de grupo e colocando id da tabela sys_User no campo Para da tabela tarefas
    db.execute("update tarefas set Para='"&itemID&"' where id="&req("I"))
'    response.write("select id from sys_users where id="&De&" or id in("&replace(itemID, "|", "")&")")
    set puser = db.execute("select id from sys_users where id="&De&" or id in("&replace(itemID, "|", "")&")")
    while not puser.eof
        notifTarefas = ""
 '       response.write("select id, DtPrazo, HrPrazo from tarefas where Para like '%|"& puser("id") &"|%' AND staPara <> 'Finalizada' ")
        set tarPara = db.Execute("select id, DtPrazo, HrPrazo from tarefas where Para like '%|"& puser("id") &"|%' AND staPara <> 'Finalizada' ")
        while not tarPara.eof
            notifTarefas = notifTarefas & "|" & tarPara("id") & "," & tarPara("DtPrazo") & " " & ft(tarPara("HrPrazo"))
        tarPara.movenext
        wend
        tarPara.close
        set tarPara = nothing

    '    response.write("update sys_users set notifTarefas='"&notifTarefas&"' where id="&puser("id"))
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

private function alertar(tag, txtAlert)
    if tag then
        iniTag = "<script>"
        fimTag = "</script>"
    end if
    'response.write(iniTag & "alert("""& txtAlert &""");"& fimTag )
    'response.write(iniTag & "console.log("""& txtAlert &""");"& fimTag )
end function

'private function statusPagto(PacienteID, Datas)
private function statusPagto(AgendamentoID, PacienteID, Datas, rdValorPlano, ValorPlano, StaID, ProcedimentoID, ProfissionalID)
    '0 = a definir
    '-1 = neutro (não sinalizar nada)
    '-2 = exclamação vermelha
    '1 = ok

    splsDatas = split(Datas, ", ")
    statusEnvolvidos = "2, 3, 4, 5, 101, 102, 103, 104, 105, 106"
    for ida=0 to ubound(splsDatas)
        sData = splsDatas(ida)
        if isdate(sData) and not isnull(sData) and PacienteID&""<>"" and isnumeric(PacienteID&"") then
'            sqlAgAt = "select 'agendamentos' tabela, id, rdValorPlano, ifnull(ValorPlano, 0) ValorPlano, ifnull(ProfissionalID, 0) ProfissionalID, ifnull(TipoCompromissoID, 0) TipoCompromissoID, FormaPagto from agendamentos where sysActive=1 AND PacienteID="& PacienteID &" and Data="& mydatenull(sData) &" and StaID IN ("& statusEnvolvidos &")"
            sqlAgAt = "select 'agendamentos' tabela, ag.id, ag.rdValorPlano, ifnull(ag.ValorPlano, 0) ValorPlano, ifnull(ag.ProfissionalID, 0) ProfissionalID, ifnull(ag.TipoCompromissoID, 0) TipoCompromissoID, ag.FormaPagto from agendamentos ag where sysActive=1 AND ag.PacienteID="& PacienteID &" and ag.Data="& mydatenull(sData) &" and ag.StaID IN ("& statusEnvolvidos &") "&_
            " UNION ALL select 'agendamentos', agm.id, agp.rdValorPlano, ifnull(agp.ValorPlano, 0), ifnull(agm.ProfissionalID, 0), ifnull(agp.TipoCompromissoID, 0), agm.FormaPagto FROM agendamentos agm LEFT JOIN agendamentosprocedimentos agp ON agp.AgendamentoID=agm.id where agm.PacienteID="& PacienteID &" and agm.Data="& mydatenull(sData) &" and agm.StaID IN ("& statusEnvolvidos &") and not isnull(agp.id) "&_
            " UNION ALL	SELECT 'atendimentos', ate.id, atp.rdValorPlano, ifnull(atp.ValorPlano, 0), ifnull(ate.ProfissionalID, 0), ifnull(atp.ProcedimentoID, 0), 0 FROM atendimentos ate LEFT JOIN atendimentosprocedimentos atp ON ate.id=atp.AtendimentoID WHERE ate.PacienteID="& PacienteID &" AND ate.`Data`="& mydatenull(sData) &""

            'if session("Banco")="clinic4285" then
            'response.write("{"& sqlAgAt &"}")
            'end if

            set ag = db.Execute( sqlAgAt )
            statusPagto = 0
            queimaData = 0

            while not ag.eof
                sID = ag("id")
                srdValorPlano = ag("rdValorPlano")
                sValorPlano = ccur(ag("ValorPlano"))
                sProfissionalID = ccur(ag("ProfissionalID"))
                sProcedimentoID = ccur(ag("TipoCompromissoID"))
                statusPagtoAnterior = ag("FormaPagto")

                if sProfissionalID=0 then
                    sqlsProfissional = ""
                    sqlsProfissionalGC = ""
                    sqlsProfissionalGS = ""
                else
                    sqlsProfissionalV = " and ii.ProfissionalID="& sProfissionalID &" "
                    sqlsProfissionalGC = " and (gc.ProfissionalID="& sProfissionalID &" or gc.ProfissionalEfetivoID="& sProfissionalID &") "
                    sqlsProfissionalGS = " and gis.ProfissionalID="& sProfissionalID &" "
                end if
                if srdValorPlano="V" then
                    if sValorPlano=0 then
                        statusPagto = -1
                    else
                    'vinicius: fiz isso pois em alguns casos quando aplicava desconto, o valor do atendimento nao tinha como mudar o valor
                        sqlIIAG = "select ii.id from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE i.AccountID="& treatvalzero(PacienteID) &" and AssociationAccountID=3 and ii.Tipo='S' and ii.ItemID="& sProcedimentoID &" and FLOOR((ii.Quantidade * (ii.ValorUnitario+ii.Acrescimo-ii.Desconto)))>=FLOOR("& treatvalzero(sValorPlano) &"-ii.Desconto+ii.Acrescimo) and FLOOR(ifnull((select sum(Valor) from itensdescontados where ItemID=ii.id), 0))>=FLOOR("& treatvalzero(sValorPlano) &"-ii.Desconto+ii.Acrescimo) and ii.DataExecucao="& mydatenull(sData) &" " & sqlsProfissionalV

                        set ii = db.Execute( sqlIIAG )
                        if ii.eof then
                            if ag("tabela")<>"atendimentos" and statusPagto <> 1 then
                                statusPagto = -2
                            end if
                        else
                            statusPagto = 1
                        end if
                    end if
                elseif srdValorPlano="P" then
                    Valor = valConvenio(sValorPlano, "", PacienteID, sProcedimentoID)

                    if isnumeric(Valor) then
                        if Valor>0 then
                            set gcons = db.Execute("select gc.ProcedimentoID, gc.ProfissionalID, gc.ProfissionalEfetivoID, gc.ValorProcedimento, gc.ConvenioID from tissguiaconsulta gc where gc.PacienteID="&treatvalnull(PacienteID) & sqlsProfissionalGC &" and gc.DataAtendimento="&mydatenull(sData)&_
                            " UNION ALL "&_
                            " select gis.ProcedimentoID, gis.ProfissionalID, NULL, gis.ValorTotal, gs.ConvenioID from tissguiasadt gs left join tissprocedimentossadt gis on gis.GuiaID=gs.id where gs.PacienteID="&treatvalnull(PacienteID) & sqlsProfissionalGS &" and gis.Data="&mydatenull(sData))
                            if gcons.eof then
                                statusPagto = -2
                            else
                                statusPagto = 1
                            end if
                        end if
                    end if
                end if
                if ag("tabela")="agendamentos" then
                    db_execute("update agendamentos set FormaPagto="& statusPagto &" where id="& sID)
                end if
                if statusPagto=-2 then
                    queimaData = 1
                end if
            ag.movenext
            wend
            ag.close
            set ag=nothing

            if queimaData=1 then
                db_execute("update agendamentos set FormaPagto=-2 where PacienteID="& treatvalnull(PacienteID) &" and Data="& mydatenull(sData) &"")
                'response.write("alert("""& queimaData &""");")
            end if
        end if
    next
end function

function sinalAgenda(val)
    sinalAgenda = ""
    if not isnull(val) and isnumeric(val) and val<>"" then
        val = ccur(val)
        select case val
            case -2
                sinalAgenda = "<i class=""far fa-exclamation-circle text-danger""></i>"
            case 1
                sinalAgenda = "<i class=""far fa-check-circle-o text-success""></i>"
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
        sqlProfissional = ""

        if session("Table")="profissionais" then
            sqlProfissional = " AND p.id = "&session("idInTable")
        end if

        EspecialidadesOdonto = "154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 238, 239, 240, 241, 242, 243, 244, 245"

        sqlOdonto = "SELECT * FROM ( "&_
                    "    select p.EspecialidadeID from profissionais p  "&_
                    "    WHERE p.Ativo='on' AND p.sysActive=1  "&sqlProfissional&" "&_
                    "    UNION ALL  "&_
                    "    select e.EspecialidadeID from profissionais p  "&_
                    "    LEFT JOIN profissionaisespecialidades e on e.ProfissionalID=p.id  "&_
                    "    WHERE p.Ativo='on' AND p.sysActive=1  "&sqlProfissional&" "&_
                    "    )t "&_
                    "    INNER JOIN especialidades esp ON esp.id=t.EspecialidadeID "&_
                    ""&_
                    "    WHERE esp.especialidade LIKE '%odonto%' OR esp.especialidade LIKE '%dentista%'"

        set vcaOdonto = db.execute(sqlOdonto)

        if NOT vcaOdonto.EOF then
            session("Odonto")=1
        else
            session("Odonto")=0
        end if
    end if
end function

function btnSalvar(id)
    btnSalvar = "<button class='btn btn-block btn-primary hidden' id='save'><i class='far fa-save'></i>Salvar</button>"&_
    "<script type='text/javascript'>"&_
        "$('#rbtns').html('<a onclick=""$(\'#"&id&"\').click()"" class=""btn btn-sm btn-success"" type=""button""><i class=""far fa-save""></i> Salvar</a>');"&_
    "</script>"
end function


function getEspera(Profissionais)

    splProfs = split(Profissionais, ",")
    for y=0 to ubound(splProfs)
        eProfissional = trim(splProfs(y))
        if eProfissional<>"" then
            if eProfissional<>"0" then
                db.execute("update sys_users set Espera = (select count(id) total from agendamentos where Data=curdate()  and sysActive=1 and StaID IN (4) and ProfissionalID="& eProfissional &") where `Table`='profissionais' and `idInTable`="& eProfissional )
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
    imoon = "<span class="""&fornecedor &" "& fornecedor &"-"& icone & " text-"& cor &" badge-icon-status "" style=""font-size:"& tamanho &"px""></span>"
end function

function newrep()
    if 1=1 or session("banco")="clinic2263" or session("banco")="clinic3656"  or session("banco")="clinic522" or session("banco")="clinic105" or session("banco")="clinic100000" or session("banco")="clinic3882" or session("banco")="clinic4421" then
        newrep = 1
    else
        newrep = 0
    end if
end function

function saveIIO(InvoiceID, ItemInvoiceID, Row)
    if newrep()=1 then
        sqlIIO = "select * from itensinvoiceoutros where InvoiceID="& InvoiceID &" and ItemInvoiceID="& Row
        'response.write("console.log("""& sqlIIO &""")")
        set iio = db.execute( sqlIIO)
        while not iio.eof
            iioID = iio("id")
            ValorUnitario = iio("ValorUnitario")
            Conta = iio("Conta")
            Quantidade = iio("Quantidade")
            ProdutoID = iio("ProdutoID")
            if iio("ValorVariavel")="S" then
                ValorUnitario = ref("V"& iioID)
            end if
            if iio("ContaVariavel")="S" then
                Conta = ref("C"& iioID)
            end if
            if iio("ProdutoVariavel")="S" then
                ProdutoID = ref("Prod"& iioID)
            end if
            if iio("Variavel")="S" then
                Quantidade = ref("Q"& iioID)
            end if
            if Conta="0" then
                Conta = ""
            end if

            sqlUP = "update itensinvoiceoutros set ValorUnitario="& treatvalzero(ValorUnitario) &", Conta='"& Conta &"', ItemInvoiceID="& NewItemID &", ProdutoID="& treatvalzero(ProdutoID) &", Quantidade="& treatvalzero(Quantidade) &", sysActive=1 where id="& iioID
            'response.write(" console.log("""& sql &""") ")
            db.execute( sqlUP )
        iio.movenext
        wend
        iio.close
        set iio = nothing
    end if
end function

function subitemRepasse(FM, Funcao, tipoValor, Valor, ContaPadrao, ProdutoID, ValorUnitario, Quantidade, Variavel, ValorVariavel, ContaVariavel, ProdutoVariavel, TabelasPermitidas, ProdutoKitOuEquipe, FuncaoID, iioID)
    NomeCampo = iioID '"O"& Row &"O"& ProdutoKitOuEquipe &"O"& FuncaoID &"O"& iioID

    'response.write("<div class='row'>")
    select case FM
        case "F"
            if ContaVariavel="S" then
                valorRequired = "  "

                'Colocar o campo como readonly se houver consolidado no rateio
                set valuesF = db.execute("select * from itensinvoiceoutros where id=" & iioID)
                if not valuesF.eof then
                    sqlRateio = "select count(*) total from rateiorateios where ItemInvoiceID = " & valuesF("ItemInvoiceID")
                    set getRateio = db.execute(sqlRateio)
                    if not getRateio.eof then
                        if ccur(getRateio("total")) > 0 then
                            valorRequired = " readonly "
                        end if
                    end if
                end if



                TabelasPermitidas = "5, 4, 3, 2, 6, 1, 8"
                if session("Banco")="clinic6118" then
                    TabelasPermitidas = "5"
                end if
                %>
                <div class="col-md-3">
                    <%=selectInsertCA(FuncaoID &". "& Funcao&"&nbsp;", "C"& NomeCampo, ContaPadrao, TabelasPermitidas, "", valorRequired, "") %>
                </div>
                <input type="hidden" name="F<%=Row %>" value="<%=NomeCampo %>" />
                <%
            end if
            if ValorVariavel="S" then
                %>
                <%=quickfield("currency", "V"& NomeCampo, Funcao & NomeProduto, 2, ValorUnitario, "", "", "") %>
                <input type="hidden" name="V<%=Row %>" value="<%=NomeCampo %>" />
                <%
            end if
        case "M"
            if Variavel="S" or ValorVariavel="S" or ContaVariavel="S" or ProdutoVariavel="S" then
                NomeProduto = ""
                if ProdutoVariavel="S" then
                    %>
                    <div class="col-md-2"><%=FuncaoID %>.
                        <%=selectInsert("Produto", "Prod"& NomeCampo, ProdutoID, "produtos", "NomeProduto", "", "", "") %>
                    </div>
                    <input type="hidden" name="P<%=Row %>" value="<%=NomeCampo %>" />
                    <%
                else
                    set prod = db.execute("select NomeProduto  FROM produtos WHERE id="&ProdutoID)
                    if not prod.eof then
                        NomeProduto = prod("NomeProduto")
                    end if
                end if
                if Variavel="S" then
                    %>
                    <%=quickfield("text", "Q"& NomeCampo, FuncaoID & ". Qtd. "& NomeProduto, 2, fn(Quantidade), "input-mask-brl", "", "") %>
                    <input type="hidden" name="Q<%=Row %>" value="<%=NomeCampo %>" />
                    <%
                end if
                if ValorVariavel="S" then
                    %>
                    <%=quickfield("currency", "V"& NomeCampo, FuncaoID & ". Valor unit. "& NomeProduto, 2, ValorUnitario, "", "", "") %>
                    <input type="hidden" name="V<%=Row %>" value="<%=NomeCampo %>" />
                    <%
                end if
                if ContaVariavel="S" then
                    %>
                    <div class="col-md-3">
                        <%=selectInsertCA(FuncaoID & ". Creditar a", "C"& NomeCampo, ContaPadrao, "5, 4, 3, 2, 6, 1", "", "", "") %>
                    </div>
                    <input type="hidden" name="F<%=Row %>" value="<%=NomeCampo %>" />
                    <%
                end if
            end if
            'response.write("</div>")
    end select

end function

private function descQuant(Quantidade, TipoUnidade, ApresentacaoNome, ApresentacaoUnidade)
    if Quantidade>1 then
        s = "s"
    else
        s = ""
    end if
    if instr(ApresentacaoUnidade&"", " - ")>0 then
        splApUn = split(ApresentacaoUnidade, " - ")
        ApresentacaoUnidade = splApUn(1)
    end if
    if TipoUnidade="C" then
        descQuant = Quantidade &" "& lcase(ApresentacaoNome) & s
    else
        descQuant = Quantidade &" "& lcase(ApresentacaoUnidade) & s
    end if
end function

private function calcQuantidadeTotal(TipoUnidade, QuantidadeConjunto, Quantidade)
    if TipoUnidade="U" then
        calcQuantidadeTotal = ccur(Quantidade)
    else
        calcQuantidadeTotal = ccur(Quantidade) * QuantidadeConjunto
    end if
end function

private function calcValPosicao(QuantidadeAtual, ValorAtual, QuantidadeInserida, ValorInserido)
    QuantidadeAtual = ccur(QuantidadeAtual)
    ValorAtual = ccur(ValorAtual)
    QuantidadeInserida = ccur(QuantidadeInserida)
    ValorInserido = ccur(ValorInserido)
    if 0 then
        %>
        console.log('<%= "( ("&QuantidadeAtual&"*"&ValorAtual&") + ("&QuantidadeInserida&"*"&ValorInserido&") ) / ("&QuantidadeAtual&" + "&QuantidadeInserida&")" %>');
        <%
    end if
    Divisor = (QuantidadeAtual + QuantidadeInserida)
    if Dividor<>0 then
        calcValPosicao = ( (QuantidadeAtual*ValorAtual) + (QuantidadeInserida*ValorInserido) ) / Divisor
    else
        calcValPosicao = 0
    end if
end function

'private function LanctoEstoque(LancamentoID, PosicaoID, P, Tipo, TipoUnidade, Quantidade, Data, FornecedorID, Lote, Validade, NotaFiscal, Valor, UnidadePagto, Observacoes, Responsavel, PacienteID, Lancar, LocalizacaoID, ItemInvoiceID, AtendimentoID, tipoResultado, CBID, ProdutoInvoiceID, Individualizar)
private function LanctoEstoque(LancamentoID, PosicaoID, P, Tipo, TipoUnidadeOriginal, TipoUnidade, Quantidade, Data, FornecedorID, Lote, Validade, NotaFiscal, Valor, UnidadePagto, Observacoes, Responsavel, PacienteID, Lancar, LocalizacaoID, ItemInvoiceID, AtendimentoID, tipoResultado, CBID, ProdutoInvoiceID, ResponsavelOriginal, LocalizacaoIDOriginal, Individualizar, CBIDs, InvoiceID, Motivo)
    set prod = db.execute("select * from produtos where id="&P)
    ApresentacaoQuantidade = prod("ApresentacaoQuantidade")
    if isnull(ApresentacaoQuantidade) or ApresentacaoQuantidade<=0 then
        ApresentacaoQuantidade = 1
    end if
    UnidadesTentadas = calcQuantidadeTotal(TipoUnidade, ApresentacaoQuantidade, Quantidade)
    if Tipo="S" or Tipo="M" then
	    QuantidadeDisponivel = quantidadeEstoque(PosicaoID)
	    if UnidadesTentadas>QuantidadeDisponivel then
		    erro = "Quantidade em estoque indispon&iacute;vel para retirada."
	    end if
    end if

    if ProdutoInvoiceID<>"" then
        set ii = db.execute("select * from itensinvoice where id="& ProdutoInvoiceID)
        if not ii.eof then
            UnidadesInvoice = calcQuantidadeTotal(ii("Executado"), ApresentacaoQuantidade, ii("Quantidade"))
        else
            UnidadesInvoice = 0
        end if
        UnidadesLancadas = 0
        set lan = db.Execute("select * from estoquelancamentos where ProdutoInvoiceID="& ProdutoInvoiceID)
        while not lan.eof
            UnidadesLancadas = UnidadesLancadas + calcQuantidadeTotal(lan("TipoUnidade"), ApresentacaoQuantidade, lan("Quantidade"))
        lan.movenext
        wend
        lan.close
        set lan=nothing
        if (UnidadesTentadas+UnidadesLancadas) > UnidadesInvoice then
            erro = "A quantidade lançada na movimentação de estoque não pode ser maior que a quantidade informada neste lançamento financeiro."
        end if
    end if
    if Lancar="S" then
        if Valor="" or Valor="0,00" then
            erro = "Digite um valor para lançar na conta."
        end if
        if UnidadePagto="" then
            erro = "Selecione uma unidade de pagamento para lançar na conta."
        end if
        if Tipo="E" then
            if FornecedorID="" or FornecedorID="0" then
                erro = "Selecione um fornecedor."
            end if
            if Motivo="" then
                erro = "Selecione um Motivo."
            end if
        end if
        if Tipo="S" then
            if PacienteID="" or PacienteID="0" then
                erro = "Selecione um paciente para lançar na conta."
            end if
        end if
    end if


    'comita a transacao
    if isnumeric(PacienteID) then
        sqlPacienteID = CLng(PacienteID)
    else
        sqlPacienteID = 0
    end if

    if erro<>"" and tipoResultado<>"ignore" then
	    %>
        new PNotify({
            title: 'N&Atilde;O LAN&Ccedil;ADO!',
            text: '<%=erro%>',
            type: 'danger',
            delay: 4000
        });
	    <%
    else
        if tipoResultado<>"ignore" then

	        db_execute("insert into estoquelancamentos (ProdutoID, EntSai, Quantidade, TipoUnidadeOriginal, TipoUnidade, Data, FornecedorID, Lote, Validade, NF, Valor, UnidadePagto, Observacoes, Responsavel, PacienteID, Lancar, sysUser, QuantidadeConjunto, QuantidadeTotal, LocalizacaoID, ItemInvoiceID, AtendimentoID, CBID, posicaoAnte, ProdutoInvoiceID, ResponsavelOriginal, LocalizacaoIDOriginal, Individualizar, CBIDs, MotivoID) values ("&P&", '"&Tipo&"', "&treatvalzero(Quantidade)&", '"& TipoUnidadeOriginal &"', '"&TipoUnidade&"', "&mydatenull(Data)&", '"& FornecedorID &"', '"&Lote&"', "&mydatenull(Validade)&", '"&NotaFiscal&"', "&treatvalzero(Valor)&", '"&UnidadePagto&"', '"&Observacoes&"', '"&Responsavel&"', "& treatvalnull(PacienteID) &", '"& Lancar &"', "&session("User")&", "&treatvalzero(QuantidadeConjunto)&", "&treatvalzero(UnidadesTentadas)&", "& treatvalzero( LocalizacaoID ) &", "& treatvalnull( ItemInvoiceID ) &", "& treatvalnull( AtendimentoID ) &", '"& CBID &"', (select group_concat( concat(id, '=', concat(Quantidade, '|', ValorPosicao)) SEPARATOR ', ') from estoqueposicao where ProdutoID="& P &" and Quantidade<>0), "& treatvalnull(ProdutoInvoiceID) &", '"& ResponsavelOriginal &"', "& treatvalzero(LocalizacaoIDOriginal) &", '"& Individualizar &"', '"& CBIDs &"',"& treatvalnull(Motivo) &")")
            set pultLancto = db.execute("select id from estoquelancamentos order by id desc limit 1")
            LancamentoID = pultLancto("id")
        end if

        've se é entrada
        if isnull(Valor) or Valor="" then
            Valor=0
        end if
        if Validade="" or isnull(Validade) then
            sqlValidade = " AND ISNULL(Validade) "
        else
            sqlValidade = " AND Validade="&mydatenull(Validade)
        end if
        if Tipo="E" then
            've se é conjunto ou unidade. uma ação pra cada
            'if TipoUnidade="C" then
                'response.write( sqlVCA )
                if TipoUnidade<>UnidadePagto then
                    if TipoUnidade="C" and UnidadePagto="U" then
                        ValorCalcular = ccur(Valor) * ccur(ApresentacaoQuantidade)
                    else
                        ValorCalcular = ccur(Valor) / ccur(ApresentacaoQuantidade)
                    end if
                else
                    ValorCalcular = Valor
                end if
                sqlVCA = "select * from estoqueposicao where ProdutoID="&P&" AND TipoUnidade='"&TipoUnidade&"' AND Lote like '"&Lote&"' AND ifnull(LocalizacaoID, 0)= "& treatvalzero(LocalizacaoID) &" AND CBID LIKE '"& CBID &"' AND Responsavel like '"&Responsavel&"' AND IFNULL(PacienteID, 0) = "& sqlPacienteID & sqlValidade
                set vca = db.execute( sqlVCA )
                if not vca.eof then
                    ValorPosicao = calcValPosicao(vca("Quantidade"), vca("ValorPosicao"), Quantidade, ValorCalcular)
                    db_execute("update estoqueposicao set Quantidade=(Quantidade+"&treatvalzero(Quantidade)&"), ValorPosicao="& treatvalzero(ValorPosicao) &" where id="&vca("id"))
                    PosicaoID = vca("id")
                else
                    ValorPosicao = calcValPosicao(0, 0, Quantidade, ValorCalcular)
                    db_execute("insert INTO estoqueposicao (ProdutoID, Quantidade, TipoUnidade, Responsavel, CBID, LocalizacaoID, Lote, Validade, ValorPosicao, PacienteID) VALUES ("&P&", "& treatvalzero(Quantidade) &", '"& TipoUnidade &"', '"& Responsavel &"', '"& CBID &"', "& treatvalzero( LocalizacaoID ) &", '"& Lote &"', "& mydatenull(Validade) &", "& treatvalzero(ValorPosicao) &", "& sqlPacienteID & ")")
                    set pult = db.execute("select id from estoqueposicao order by id desc limit 1")
                    PosicaoID = pult("id")
                end if
            'end if
            PosicaoE = PosicaoID
            PosicaoS = 0
        elseif Tipo="S" or Tipo="M" then
            sqlPosSaida = "select * from estoqueposicao where ProdutoID="&P&" AND TipoUnidade='"& TipoUnidadeOriginal &"' AND Lote like '"&Lote&"' AND ifnull(LocalizacaoID, 0)="& treatvalzero(LocalizacaoIDOriginal) &" AND CBID LIKE '"& CBID &"' AND Responsavel like '"& ResponsavelOriginal &"' AND IFNULL(PacienteID, 0) = "& sqlPacienteID & sqlValidade
            set posSaida = db.execute(sqlPosSaida)
            'jamais dar saida de uma posicao que nao foi criada previamente
            if not posSaida.eof then
                ApresentacaoQuantidade= prod("ApresentacaoQuantidade")
                if isnull(ApresentacaoQuantidade) then
                    ApresentacaoQuantidade=1
                end if
                ApresentacaoQuantidade = ccur(ApresentacaoQuantidade)
                ValorUnidade = posSaida("ValorPosicao")/ApresentacaoQuantidade
                if TipoUnidade=posSaida("TipoUnidade") then
                    db_execute("update estoqueposicao set Quantidade=(Quantidade-"&treatvalzero(Quantidade)&") where id="&posSaida("id"))
                elseif posSaida("TipoUnidade")="C" and TipoUnidade="U" then
                    Quantidade = ccur(Quantidade)
                    ConjuntosRetirados = cint(Quantidade/ApresentacaoQuantidade)
                    if ConjuntosRetirados=0 or (Quantidade>ccur(ConjuntosRetirados*ApresentacaoQuantidade)) then
                        ConjuntosRetirados = ConjuntosRetirados+1
                    end if
                    Sobra = ccur((ConjuntosRetirados*ApresentacaoQuantidade)-Quantidade)
                    if Sobra>0 then
                        sqlPosSobra = "select * from estoqueposicao where ProdutoID="&P&" AND TipoUnidade='U' AND Lote like '"&Lote&"' AND ifnull(LocalizacaoID, 0)="& treatvalzero(LocalizacaoIDOriginal) &" AND CBID LIKE '"& CBID &"' AND Responsavel like '"& ResponsavelOriginal &"' AND IFNULL(PacienteID, 0) = "& sqlPacienteID & sqlValidade
                        set posSobra = db.execute( sqlPosSobra )
                        if posSobra.eof then
                            ValorPosicao = calcValPosicao(0, 0, Sobra, ValorUnidade)
                            db_execute("insert into estoqueposicao (ProdutoID, Quantidade, TipoUnidade, Responsavel, CBID, LocalizacaoID, Lote, Validade, ValorPosicao, PacienteID) select ProdutoID, "& treatvalzero(Sobra) &", 'U', Responsavel, '"& CBID &"', LocalizacaoID, Lote, Validade, "& treatvalzero(ValorPosicao) &", PacienteID FROM estoqueposicao WHERE id="& posSaida("id"))
                        else
                            ValorPosicao = calcValPosicao(posSobra("Quantidade"), posSobra("ValorPosicao"), Sobra, ValorUnidade)
                            db_execute("update estoqueposicao set Quantidade=(Quantidade+"& treatvalzero(Sobra) &"), ValorPosicao="& treatvalzero(ValorPosicao) &" where id="& posSobra("id"))
                        end if
                    end if


                    db_execute("update estoqueposicao SET Quantidade=(Quantidade-"& treatvalzero(ConjuntosRetirados) &") WHERE id="& posSaida("id"))
                end if
                if Tipo="M" then
                    if TipoUnidade="C" then
                        ValorNovo = posSaida("ValorPosicao")
                    else
                        ValorNovo = ValorUnidade
                    end if
                    if Individualizar="" then 'somente movimentou sem individualizar
                        sqlVCAmov = "select * from estoqueposicao where ProdutoID="&P&" AND TipoUnidade='"&TipoUnidade&"' AND Lote like '"&posSaida("Lote")&"' AND ifnull(LocalizacaoID, 0)="& treatvalzero(LocalizacaoID) &" AND CBID LIKE '"& CBID &"' AND Responsavel like '"& Responsavel &"' AND IFNULL(PacienteID, 0) = "& sqlPacienteID & sqlValidade
                        'call alertar(0, sqlVCAmov)
                        set vca = db.execute( sqlVCAmov )
                        if not vca.eof then
                            ValorNovo = calcValPosicao(vca("Quantidade"), vca("ValorPosicao"), Quantidade, posSaida("ValorPosicao"))
                            db_execute("update estoqueposicao set Quantidade=(Quantidade+"&treatvalzero(Quantidade)&") where id="&vca("id"))
                            PosicaoE = vca("id")
                        else
                            db_execute("insert INTO estoqueposicao (ProdutoID, Quantidade, TipoUnidade, Responsavel, CBID, LocalizacaoID, Lote, Validade, ValorPosicao, PacienteID) VALUES ("&P&", "& treatvalzero(Quantidade) &", '"& TipoUnidade &"', '"& Responsavel &"', '"& CBID &"', "& treatvalzero( LocalizacaoID ) &", '"& posSaida("Lote") &"', "& mydatenull(posSaida("Validade")) &", "& treatvalzero( ValorNovo ) &", " & sqlPacienteID & ")")
                        end if
                    else'Individualizou
                        tInd = ccur(Quantidade)
                        cInd = 0
                        splCBIDs = split(CBIDs, ", ")
                        for icb=0 to ubound(splCBIDs)
                            CodigoIndividual = splCBIDs(icb)
                            sqlVCAInd = "select * from estoqueposicao where ProdutoID="&P&" AND TipoUnidade='"&TipoUnidade&"' AND Lote like '"&posSaida("Lote")&"' AND ifnull(LocalizacaoID, 0)="& treatvalzero(LocalizacaoID)&" AND CBID LIKE '"& CodigoIndividual &"' AND Responsavel like '"& Responsavel &"' AND IFNULL(PacienteID, 0) = "& sqlPacienteID & sqlValidade
                            'response.write("//"& sqlVCAInd )
                            set vcaInd = db.execute( sqlVCAInd )
                            if vcaInd.eof then
                                db_execute("insert INTO estoqueposicao (ProdutoID, Quantidade, TipoUnidade, Responsavel, CBID, LocalizacaoID, Lote, Validade, ValorPosicao, PacienteID) VALUES ("&P&", "& 1 &", '"& TipoUnidade &"', '"& Responsavel &"', '"& CodigoIndividual &"', "& treatvalzero( LocalizacaoID ) &", '"& posSaida("Lote") &"', "& mydatenull( posSaida("Validade") ) &", "& treatvalzero( ValorNovo ) &", " & sqlPacienteID & ")")
                            else
                                db_execute("update estoqueposicao SET Quantidade=Quantidade+1 WHERE id="& vcaInd("id"))
                            end if
                        next
                    end if
                end if
            else

                id = req("PosicaoID")
                if id&"" <> "" then
                    'Dando baixa no estoque quando é colocado um paciente na saida
                    set EstoquePosicaoSQL = db_execute("SELECT Quantidade FROM estoqueposicao WHERE id="&req("PosicaoID"))
                    db_execute("update estoqueposicao set Quantidade=(Quantidade-"&treatvalzero(Quantidade)&") where id="&req("PosicaoID"))

                end if
                'mas ele tem que achar essa posicao de saida pq tem que ter saido de algum lugar... caso contrario eh sql errado
            '   call alertar(0, "nao achou essa posicao de saida")
             '  call alertar(0, sqlPosSaida)
           end if

            'ref individualiza e ref cind?????? acabar com isso



            PosicaoS = PosicaoID
        end if
        if tipoResultado="eval" then
	        %>
            new PNotify({
                title: 'LAN&Ccedil;ADO!',
                text: 'Salvo com sucesso.',
                type: 'success',
                delay: 4000
            });
	        $("#modal-table").modal("hide");
            <%if ItemInvoiceID="" and AtendimentoID="" then %>
                atualizaLanctos();
            <%elseif AtendimentoID<>"" then %>
                modalEstoqueAtend(<%= AtendimentoID %>);
            <%else %>

	        <%
            end if
            if Lancar="S" then
                if InvoiceID&""="" then
                    InvoiceID = 0
                end if
                call estoqueLancaConta(LancamentoID, "nothing",InvoiceID)
            end if
        end if
    end if
end function

private function estoqueLancaConta(LancamentoID, resultado,InvoiceID)
    sqlLanc = "select l.*, at.Data, at.UnidadeID from estoquelancamentos l left join atendimentosprocedimentos ap on l.AtendimentoID=ap.id left join atendimentos at on at.id=ap.AtendimentoID where l.id="& LancamentoID
    'response.write( sqlLanc )
    set lanc = db.execute( sqlLanc )
    PacienteID = lanc("PacienteID")
    FornecedorID = lanc("FornecedorID")
    ProdutoID = lanc("ProdutoID")
    DataAtendimento = lanc("Data")
    UnidadeID = lanc("UnidadeID")
    Quantidade = lanc("Quantidade")
    TipoQuantidade = lanc("TipoUnidade")
    AtendimentoID = lanc("AtendimentoID")
    nroNFe = lanc("NF")
    if lanc("EntSai")="S" then
        Associacao = 3
        ContaID = PacienteID
        CD = "C"
        Operacao = "venda"
    else
        splForn = split(FornecedorID, "_")
        Associacao = splForn(0)
        ContaID = splForn(1)
        CD = "D"
        Operacao = "compra"
    end if
    Valor = lanc("Valor")
    UnidadePagto = lanc("UnidadePagto")

    set prod = db.execute("select Preco"&operacao&", Tipo"&operacao&", ifnull(ApresentacaoQuantidade, 1) ApresentacaoQuantidade from produtos where id="& ProdutoID)
    if prod.eof then
        erro = "Produto excluído."
    else
        ApresentacaoQuantidade = prod("ApresentacaoQuantidade")
        if isnull(Valor) or Valor=0 then
            '-> Valor = ve como é o valor de saída do produto, proporcionaliza ao gasto e cobra
            Valor = prod("Preco"&Operacao)
            UnidadePagto = prod("Tipo"&Operacao)
            if isnull(Valor) or Valor=0 or isnull(UnidadePagto) or UnidadePagto="" then
                erro = "Para inserir este lançamento no financeiro você precisa definir um valor de "& Operacao &" no cadastro do produto."
            end if
        end if
    end if

    if erro="" then
        if UnidadePagto<>TipoQuantidade then
            if TipoQuantidade="U" and UnidadePagto="C" then
                Valor = Valor / ApresentacaoQuantidade
            elseif TipoQuantidade="C" and UnidadePagto="U" then
                Valor = Valor * ApresentacaoQuantidade
            end if
        end if
        ValorFinal = Quantidade * Valor

        IF InvoiceID > 0 THEN
            sqlIns = "UPDATE sys_financialmovement SET Value=VALUE + "&treatvalzero(ValorFinal)&" WHERE AccountIDDebit = "& ContaID &" and  AccountAssociationIDDebit = "& Associacao &" AND InvoiceID = "&InvoiceID
            db.execute( sqlIns )
            sqlIns = "UPDATE sys_financialinvoices SET Value=VALUE + "&treatvalzero(ValorFinal)&" WHERE ID = "&InvoiceID
            db.execute( sqlIns )
        END IF

        IF NOT InvoiceID > 0 THEN
            sqlIns = "insert into sys_financialinvoices (AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser, sysDate, CaixaID, nroNFe) values ("& ContaID &", "& Associacao &", "& treatvalzero(ValorFinal) &", 1, 'BRL', "& treatvalzero(UnidadeID)&", 1, 'm', '"&CD&"', 1, "&session("User")&", curdate(), "& treatvalnull(session("CaixaID")) &", "& treatvalnull(nroNFe) &")"
            'response.write( sqlIns )
            db.execute( sqlIns )
            set pult = db.execute("select id from sys_financialinvoices where sysUser="& session("User") &" order by id desc limit 1")
            InvoiceID = pult("id")
            sqlIns = "insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, CaixaID, UnidadeID) values (0, 0, "& Associacao &", "& ContaID &", "& treatvalzero(ValorFinal) &", curdate(), '"&CD&"', 'Bill', 'BRL', 1, "& InvoiceID &", 1, "& session("User") &", "& treatvalnull(session("CaixaID")) &", "& treatvalzero(UnidadeID) &")"
            db.execute( sqlIns )
        END IF


        db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Executado, GrupoID, AgendamentoID, sysUser, ProfissionalID, Acrescimo, Associacao, CentroCustoID) values ("& InvoiceID &", 'M', "& treatvalzero(Quantidade) &", 0, "& ProdutoID &", "& treatvalzero(Valor) &", 0, '"& TipoQuantidade &"', 0, 0, "& session("User") &", 0, 0, 0, 0)")
        set pultii = db.execute("select id from itensinvoice where sysUser="&session("User")&" order by id desc limit 1")
        ItemInvoiceID = pultii("id")
        db_execute("update estoquelancamentos set ProdutoInvoiceID="& ItemInvoiceID &" WHERE id="& LancamentoID)
        if resultado="eval" then
            %>
            modalEstoqueAtend(<%= AtendimentoID %>);
            <%
        end if
    else
        if resultado="eval" then
            %>
            alert('<%= erro %>');
            <%
        end if
    end if
end function


function prebtb(Contato, Numero, Campo)
    Numero = lcase(Numero&"")
	Contato = Contato&""
	if instr(Contato, "_")=0 then
		Contato = "3_"& Contato
	end if
    if Numero<>"" and not isnull(Numero) then
        %>
        <div class="btn-group">
            <button type="button" class="btn btn-xs btn-gradient btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><%=Numero %></button>
            <ul class="dropdown-menu" role="menu">
                <li>
                    <a href="#">NOVA INTERAÇÃO</a>
                </li>
                <li class="divider"></li>
                <%
                set cc = db.execute("select * from chamadascanais where Campos like '%"& Campo &"%'")
                while not cc.eof

                    %>
                    <li>
                        <a <% if cc("id")=8 then %>href="https://web.whatsapp.com/send?phone=55<%= replace(replace(replace(replace(Numero,"-",""),"(",""), ")" ,"")," ","") %>" target="_blank"<% else %>href=""#"<% end if%> onclick="btb(<%=cc("id") %>, '<%= Numero %>', '<%=Contato %>')"><i class="far fa-<%=cc("Icone") %>"></i> <%=cc("NomeCanal") %></a>
                    </li>
                    <%
                cc.movenext
                wend
                cc.close
                set cc=nothing
                %>
            </ul>
        </div>
        <%
    end if
end function

private function disparaEmail(ProfissionalID, txtEmail, PacienteID, ProcedimentoID)
    if txtEmail<>"" then
        if (session("Banco")="clinic100000" or session("Banco")="clinic105" or session("Banco")="clinic3134" or session("Banco")="clinic4219") and txtEmail<>"" then
            disparaEmail = 1
            set pac = db.execute("select (select NomePaciente from pacientes where id="& treatvalzero(PacienteID)&") NomePaciente, (select NomeProcedimento from procedimentos where id="&treatvalzero(ProcedimentoID)&") NomeProcedimento")
            txtEmail = txtEmail & "<br>Paciente: "& pac("NomePaciente") &"<br>Procedimento: "& pac("NomeProcedimento")
            set prof = db.execute("select Email1 from profissionais where id="& treatvalzero(ProfissionalID) &" and Email1 like '%@%'")
            if not prof.eof then
                'on error resume next
                'call SendMail(prof("Email1"), "Alterações de Agenda", txtEmail)
                'db_execute("insert into cliniccentral.emailsagendamento (LicencaID, UserID, Email, Assunto, Texto) values ("& replace(session("Banco"), "clinic", "") &", "& session("User") &", '"& prof("Email1") &"', 'Alterações de Agenda', '"& rep(txtEmail) &"')")
            end if
        end if
    end if
end function


private function FazPosicao(ProdutoID)
    set lanctos = db.execute("SELECT * FROM estoquelancamentos WHERE ProdutoID="& ProdutoID & " AND ISNULL(PosicaoE) ORDER BY sysDate")
    while not lanctos.eof
        if lanctos("EntSai")="S" or lanctos("EntSai")="M" then
            PosicaoID = lanctos("PosicaoS")
        else
            PosicaoID = lanctos("PosicaoE")
        end if
        call LanctoEstoque(lanctos("id"), PosicaoID, ProdutoID, lanctos("EntSai"), lanctos("TipoUnidadeOriginal"), lanctos("TipoUnidade"), lanctos("Quantidade"), lanctos("Data"), lanctos("FornecedorID"), lanctos("Lote"), lanctos("Validade"), lanctos("NF"), lanctos("Valor"), lanctos("UnidadePagto"), lanctos("Observacoes"), lanctos("Responsavel"), lanctos("PacienteID"), lanctos("Lancar"), lanctos("LocalizacaoID"), lanctos("ItemInvoiceID"), lanctos("AtendimentoID"), "ignore", lanctos("CBID"), lanctos("ProdutoInvoiceID"), lanctos("Individualizar"),0)
    lanctos.movenext
    wend
    lanctos.close
    set lanctos = nothing
end function


private function linhaAgenda(n, ProcedimentoID, Tempo, rdValorPlano, Valor, PlanoID, ConvenioID, Convenios, EquipamentoID, LocalID, GradeApenasProcedimentos, GradeApenasConvenios)
    ischeckin = false
    ischeckin = req("Checkin")="1"
    
    if rdValorPlano="V" then
        ConvenioID=0
    end if
    %>
    <tr class="linha-procedimento" id="la<%=n %>" data-id="<%=n %>">
        <% if ischeckin then %>
            <td class="<%= staPagto %>" style="border:none">
                <% if staPagto="success" then %>
                    <i class=" far fa-check-circle text-success"></i>
                <% else %>
                    <input type="checkbox" checked="checked" name="LanctoCheckin" class="ckpagar Bloco<%= Bloco %>" value="<%= ConsultaID &"_"& n %>" /></td>
                <% end if %>
        <% end if %>
        <td>
        <%
        if ischeckin then
            set sqldados = db.execute("select p.NomeProcedimento from Procedimentos as p where p.id="&ProcedimentoID)
            if not sqldados.eof then
                NomeProcedimento = "<label>"&sqldados("NomeProcedimento")&"</label>"
            end if 
            %>
            <input type="hidden" name="ProcedimentoID<%=n%>" id="ProcedimentoID<%=n%>" value="<%=ProcedimentoID%>">
            <%=NomeProcedimento%> 
            <%
        else
            
            SomenteConvenios = ""
            if ConvenioID <> 0 then
                SomenteConvenios = "ConvenioID"
            end if
        
           call selectInsert("", "ProcedimentoID"& n, ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""parametros(this.id, this.value); atualizarTempoProcedimentoProfissional(this)"" data-agenda="""" data-exibir="""&GradeApenasProcedimentos&"""", "agenda", SomenteConvenios) 
        end if
        %>
        </td>
        <td>
            <%
            TempoChange = ""
            if aut("|agendaalteracaoprecadastroA|")=0 then
                TempoChange=" readonly"
            end if
            if ischeckin then
            %>
                <input type="hidden" name="Tempo<%=n%>" id="Tempo<%=n%>" value="<%=Tempo%>">
                <span><%=Tempo%></span> 
            <% else %>
                <%=quickField("number", "Tempo"&n, "", 2, Tempo, "", "", " placeholder='Em minutos'"&TempoChange)%>
            <% end if %>
        </td>
        <td>
            <%if ischeckin then
                formapg = "Particular"
                if rdValorPlano="P" then
                    formapg = "Convênio"
                end if
                %>
                <input type="radio" class="hidden" name="rdValorPlano<%=n %>" id="rdValorPlanoV<%=n%>" <% If formapg = "Particular" Then %> checked="checked"<% End If %> value="V">
                <input type="radio"  class="hidden"  name="rdValorPlano<%=n %>" id="rdValorPlanoP<%=n%>" <% If formapg = "Convênio" Then %> checked="checked"<% End If %> value="P">
                    <label><%=formapg%></label> 
                <%
            else
            %>
        
            <div class="radio-custom radio-primary"><input onchange="parametros('ProcedimentoID', $('#ProcedimentoID').val());" type="radio" name="rdValorPlano<%=n %>" id="rdValorPlanoV<%=n %>" required value="V"<% If rdValorPlano="V" Then %> checked="checked"<% End If %> class="ace valplan clforma" style="z-index:-1" onclick="valplan('<%=n%>', 'V')" /><label for="rdValorPlanoV<%=n %>" class="radio"> Particular</label></div>
            <%
                if Convenios<>"Nenhum" and (GradeApenasConvenios<> "|P|" or isnull(GradeApenasConvenios)) then
                %>
                <div class="radio-custom radio-primary"><input type="radio" data-n="<%=n %>" name="rdValorPlano<%=n %>" id="rdValorPlanoP<%=n %>" required value="P"<% If rdValorPlano="P" Then %> checked="checked"<% End If %> class="ace valplan clforma" onclick="valplan('<%=n%>', 'P')" style="z-index:-1" /><label for="rdValorPlanoP<%=n %>" class="radio"> Conv&ecirc;nio</label></div>
                <%
                end if 
            end if
            %>
        </td>
        <td>
            <div class="col-md-12" id="divValor<%=n %>" <% If rdValorPlano<>"V" Then %> style="display:none"<% End If %>>
                <div class="row">
                    <div class="col-md-12">
                        <%
                        if (aut("|valordoprocedimentoA|")=0 and aut("|valordoprocedimentoV|")=1) or ischeckin then
                        %>

                            <input data-valor="<%=Valor%>" type="hidden" id="Valor<%=n %>" name="Valor<%=n %>" value="<%=Valor%>" class="valorprocedimento">
                            R$ <span id="ValorText<%=n %>"><%=fn(Valor)%></span>
                            <script >
                              $("#Valor<%=n %>").change(function() {
                                  $("#ValorText<%=n %>").html($(this).val());
                              });
                            </script>
                        <%
                        elseif aut("areceberpacienteV")=1 and aut("|valordoprocedimentoV|")=1 then
                        %>
                            <%=quickField("text", "Valor"&n, "", 5, fn(Valor), " text-right input-mask-brl valorprocedimento ", "", fieldReadonly&" data-valor="&Valor)%>
                            <%
                        else
                            %>

                            <input data-valor="<%=Valor%>" type="hidden" id="Valor<%=n %>" name="Valor<%=n %>" value="<%=Valor%>">
                            <%
                        end if
                        %>
                    </div>
                </div>
            </div>
            <div class="col-md-12" id="divConvenio<%=n %>" <% If rdValorPlano<>"P" Then %> style="display:none"<% End If %>>
                <%
                if ischeckin then
                    if not isnull(ConvenioID) and ConvenioID<>"" then
                        set ConvenioSQL = db.execute("SELECT NomeConvenio FROM convenios "&_
                                                    " WHERE id="&ConvenioID&"")
                        if not ConvenioSQL.eof then
                            if PlanoID&""<>"" then
                                set PlanoSQL = db.execute("SELECT NomePlano FROM conveniosplanos "&_
                                                    " WHERE id="&PlanoID&" AND sysActive=1 AND NomePlano!=''")
                                if not PlanoSQL.eof then
                                    NomePlano = "<label> - Plano:</label><span>"&PlanoSQL("NomePlano")&"</span>"
                                end if
                            end if 
                            
                            %>
                            <input type="hidden" name="ConvenioID<%=n%>" id="ConvenioID<%=n%>" value="<%=ConvenioID%>">
                            <input type="hidden" name="PlanoID<%=n%>" id="PlanoID<%=n%>" value="<%=PlanoID%>">
                            <span><%=ConvenioSQL("NomeConvenio")%></span>
                            <%=NomePlano%>
                            <%
                        end if
                    end if
                else
                    if not isnull(ConvenioID) and ConvenioID<>"" then
                        ObsConvenios = ""
                        set ConvenioSQL = db.execute("SELECT Obs FROM convenios WHERE id="&ConvenioID&" AND Obs!='' AND Obs IS NOT NULL")
                        planosOptions = getPlanosOptions(ConvenioID, PlanoID&"_"&n)
                        if planosOptions<>"" then
                        %>
                    <script >
                    $(document).ready(function() {
                        $("#divConvenio<%=n%>").after("<%=planosOptions%>");
                        $("#PlanoID<%=n%>").select2();
                    })
                    </script>
                        <%
                        end if
                        if not ConvenioSQL.eof then
                            ObsConvenio = replace(ConvenioSQL("Obs"),"""","\'")
                            %>
                            <button title="Observações do convênio" id="ObsConvenios" style="z-index: 99;position: absolute;left:-16px" class="btn btn-system btn-xs" type="button" onclick="ObsConvenio(<%=ConvenioID%>)"><i class="far fa-align-justify"></i></button>
                            <%
                        end if
                    end if
                    if Convenios="Todos" then
                    %>
                    <%=selectInsert("", "ConvenioID"&n, ConvenioID, "convenios", "NomeConvenio", " data-exibir="""&GradeApenasConvenios&""" onchange=""parametros(this.id, this.value+'_'+$('#ProcedimentoID').val());""", "", "")%>
                    <%
                    else
                        if (len(Convenios)>2 or (isnumeric(Convenios) and not isnull(Convenios))) and instr(Convenios&" ", "Nenhum")=0 then
                        %>
                        <%=quickfield("simpleSelect", "ConvenioID"&n, "Conv&ecirc;nio", 12, ConvenioID, "select id, NomeConvenio from convenios where sysActive=1 AND Ativo='ON' AND id in("&Convenios&") order by NomeConvenio", "NomeConvenio", " onchange=""parametros(this.id, this.value+'_'+$('#ProcedimentoID').val());""") %>
                        <%
                        end if
                    end if
                end if
                %>

            </div>

        </td>
        <td><%
        disabled = ""
        if fieldReadonly = " readonly " then 
            disabled = " disabled " 
        end if
        
        if ischeckin then
            set localSQL = db.execute("select NomeLocal from locais where sysActive=1 and id="&treatvalzero(LocalID))
            if not localSQL.eof then
                NomeLocal = "<span>"&localSQL("NomeLocal")&"</span>"
            end if
            %>
            <input type="hidden" name="LocalID<%=n %>" id="LocalID<%=n %>" value="<%=LocalID%>" />
            <%=NomeLocal%>
            <%
        else
            if aut("localagendaA")=0 then
                call quickfield("simpleSelect", "LocalIDx", "", 2, LocalID, "select * from locais where sysActive=1", "NomeLocal", " disabled ")
                response.write("<input type='hidden' name='LocalID"&n&"' id='LocalID' value='"& LocalID &"'>")
            else
                call selectInsert("", "LocalID"&n, LocalID, "locais", "NomeLocal", " "&disabled, " ", "")
            end if
        end if

         %></td>
        <td>
            <%if (req("Tipo")="Quadro" or req("EquipamentoID")="" or req("EquipamentoID")="undefined" or req("EquipamentoID")="0") and not ischeckin then%>
                <%=quickfield("select", "EquipamentoID"&n, "", 2, EquipamentoID, "select * from equipamentos where sysActive=1", "NomeEquipamento", ""&disabled) %>
            <%else 
                set equipSQL = db.execute("select NomeEquipamento from equipamentos where sysActive=1 and id="&treatvalzero(EquipamentoID))
                if not equipSQL.eof then
                    NomeEquipamento = "<span>"&equipSQL("NomeEquipamento")&"</span>"
                end if
            %>
                <input type="hidden" name="EquipamentoID<%=n %>" id="EquipamentoID<%=n %>" value="<%=EquipamentoID%>" />
                <%=NomeEquipamento%>
            <%end if %>
        </td>
        <td>
            <input type="hidden" name="ProcedimentosAgendamento" value="<%=n %>" />
            <%if not ischeckin then%>
                <button onclick="procs('X', <%=n %>)" class="btn btn-xs btn-danger " type="button"><i class="far fa-remove"></i></button>
            <%end if%>

            <div class="btn-group mt5">
                <button type="button" class="btn btn-info btn-xs dropdown-toggle rgrec" data-toggle="dropdown" title="Gerar recibo" aria-expanded="false"><i class="far fa-print bigger-110"></i></button>
                <ul class="dropdown-menu dropdown-info pull-right">
                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Protocolo')"><i class="far fa-plus"></i> Protocolo de laudo </a></li>
                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Impresso')"><i class="far fa-plus"></i> Impresso </a></li>
                    <li><a href="javascript:printProcedimento($('#ProcedimentoID<%=n %>').val(),$('#PacienteID').val(), $('#ProfissionalID').val(),'Etiqueta')"><i class="far fa-plus"></i> Etiqueta </a></li>
                </ul>
            </div>
        </td>
    </tr>
    <tr id="restr<%= n %>"></tr>
    <%
end function

private function atuAge(AgendamentoID)
    'set procs = db.execute("select group_concat(concat(replace(ifnull(Cor, ''), '#', '^#'), ' ', NomeProcedimento) separator ', ') procedimentos from procedimentos where id=(select TipoCompromissoID from agendamentos where id="& AgendamentoID &") or id in(select TipoCompromissoID from agendamentosprocedimentos where AgendamentoID="& AgendamentoID &")")
    'set procs = db.execute("select group_concat(NomeProcedimento separator ', ') procedimentos from procedimentos where id=(select TipoCompromissoID from agendamentos where id="& AgendamentoID &") or id in(select TipoCompromissoID from agendamentosprocedimentos where AgendamentoID="& AgendamentoID &")")
        set procs = db.execute("SELECT GROUP_CONCAT(t.procedimentos SEPARATOR ', ') procedimentos FROM ( "&_
        "SELECT GROUP_CONCAT(NomeProcedimento SEPARATOR ', ') procedimentos "&_
        "FROM procedimentos "&_
        "WHERE id=( "&_
        "SELECT TipoCompromissoID "&_
        "FROM agendamentos "&_
        "WHERE id="& AgendamentoID &") "&_
        "UNION  ALL "&_
        "SELECT GROUP_CONCAT(NomeProcedimento SEPARATOR ', ') procedimentos "&_
        "FROM procedimentos "&_
        "WHERE id in( "&_
        "SELECT TipoCompromissoID "&_
        "FROM agendamentosprocedimentos "&_
        "WHERE AgendamentoID="& AgendamentoID &")) AS t")
    
    procedimentos = procs("procedimentos")
    db_execute("update agendamentos ag LEFT JOIN pacientes pac ON pac.id=ag.PacienteID set ag.NomePaciente=pac.NomePaciente, ag.Tel1=pac.Tel1, ag.Cel1=pac.Cel1, ag.Email1=pac.Email1, ag.Procedimentos='"& rep(Procedimentos) &"' where ag.id="& AgendamentoID)
end function

private function allAtuAge(Data)
    set nulos = db.execute("select id from agendamentos where Data="&mydatenull(Data)&" and isnull(Procedimentos) and isnull(NomePaciente)")
    while not nulos.eof
        call atuAge( nulos("id") )
    nulos.movenext
    wend
    nulos.close
    set nulos=nothing
end function

private function showProcs(pStr, ppptipo)
    novaStr = pStr&""
    if instr(novaStr, "^#") then
        splStr = split(novaStr, "^#")
        for istr=0 to ubound(splStr)
            if instr(splStr(istr), " ") then
                'novaStr = novaStr & "|" & splStr(istr)
                splStr2 = split(splStr(istr), " ")
                hexaCirc = splStr2(0)
            else
                hexaCirc = ""
            end if
            if ppptipo="bolinha" then
                novaStr = replace(novaStr, ""& hexaCirc, "<div class=bolinha style=\'background-color:#"& hexaCirc &"\'></div>")
            elseif ppptipo="corrido" then
                novaStr = replace(novaStr, hexaCirc, "")
            end if
        next
    end if
    showProcs = replace(novaStr, "^#", "")
end function

private function refazPosicao(ProdutoID)
        'response.write(session("Banco"))
    db_execute("update estoquelancamentos set CBID='' WHERE ISNULL(CBID)")
    db_execute("update estoquelancamentos set LocalizacaoID=0 WHERE ISNULL(LocalizacaoID)")

    if session("Banco")="clinic2385" then
        db_execute("update estoqueposicao set Quantidade=0 where ProdutoID="& ProdutoID)
        set dist = db.execute("select distinct TipoUnidade, Responsavel, Validade, CBID, LocalizacaoID from estoquelancamentos where ProdutoID="& ProdutoID)
        while not dist.eof
            if not isnull(dist("Validade")) then
                sqlValidade = " AND Validade="& mydatenull(dist("Validade")) &" "
            else
                sqlValidade = ""
            end if

            sqlWhere =  " from estoquelancamentos where TipoUnidade='"&dist("TipoUnidade")&"' and Responsavel Like '"& dist("Responsavel") &"' and CBID like  '"& dist("CBID") &"' and LocalizacaoID="& dist("LocalizacaoID") &" " & sqlValidade &" AND ProdutoID="& ProdutoID

            sqlEnts = "select ifnull(sum(Quantidade), 0) Entradas "& sqlWhere &" AND EntSai='E'"
            sqlSais = "select ifnull(sum(Quantidade), 0) Saidas "& sqlWhere &" AND EntSai='S'"
            'response.write( sqlEnts &";<br>")
            'response.write( sqlSais &";<br>")
            set ents = db.execute( sqlEnts )
            set sais = db.execute( sqlSais )

            set vca = db.execute("select * from estoqueposicao where TipoUnidade='"&dist("TipoUnidade")&"' and Responsavel Like '"& dist("Responsavel") &"' and CBID like  '"& dist("CBID") &"' and ifnull(LocalizacaoID, 0)="& treatvalzero(dist("LocalizacaoID")) &" " & sqlValidade &" AND ProdutoID="& ProdutoID)
            Quantidade = ccur(ents("Entradas")) - ccur(sais("Saidas"))
            if not vca.eof then
                db_execute("update estoqueposicao set Quantidade="& treatvalzero(Quantidade) &" where id="& vca("id"))
            else
                db_execute("insert into estoqueposicao (ProdutoID, Quantidade, TipoUnidade, Responsavel, CBID, LocalizacaoID, Validade) values ("& ProdutoID &", "& treatvalzero(Quantidade) &", '"& dist("TipoUnidade") &"', '"& dist("Responsavel") &"', '"& dist("CBID") &"', "& treatvalzero(dist("LocalizacaoID")) &", "& mydatenull(dist("Validade")) &")")
            end if
        dist.movenext
        wend
        dist.close
        set dist=nothing
    else
        db_execute("update estoqueposicao set Quantidade=0 where ProdutoID="& ProdutoID)
        set lanctos = db.execute("select * from estoquelancamentos where ProdutoID="& ProdutoID &" order by id")
        while not lanctos.eof
    '        if lanctos("EntSai")="E" then
     '           PosicaoES = lanctos("PosicaoE")
      '      else
       '         PosicaoES = lanctos("PosicaoS")
        '    end if
            'LanctoEstoque(LancamentoID, PosicaoID, P, Tipo, TipoUnidade, Quantidade, Data, FornecedorID, Lote, Validade, NotaFiscal, Valor, UnidadePagto, Observacoes, Responsavel, PacienteID, Lancar, LocalizacaoID, ItemInvoiceID, AtendimentoID, tipoResultado, CBID, ProdutoInvoiceID)
            call LanctoEstoque(lanctos("id"), PosicaoES, ProdutoID, lanctos("EntSai"), lanctos("TipoUnidadeOriginal"), lanctos("TipoUnidade"), lanctos("Quantidade"), lanctos("Data"), lanctos("FornecedorID"), lanctos("Lote"), lanctos("Validade"), lanctos("NF"), lanctos("Valor"), lanctos("UnidadePagto"), lanctos("Observacoes"), lanctos("Responsavel"), lanctos("PacienteID"), lanctos("Lancar"), lanctos("LocalizacaoID"), lanctos("ItemInvoiceID"), lanctos("AtendimentoID"), "ignore", lanctos("CBID"), lanctos("ProdutoInvoiceID"), lanctos("ResponsavelOriginal"), lanctos("LocalizacaoIDOriginal"), lanctos("Individualizar"), lanctos("CBIDs"),0,0)
        lanctos.movenext
        wend
        lanctos.close
        set lanctos = nothing
    end if

end function


private function BaixaAutomatica(Data, ProfissionalID, EspecialidadeID, ProcedimentoID, rdValorPlano, ValorPlano, PacienteID, StaID, AgendamentoID, TabelaID)
    if isnumeric(ValorPlano) and not isnull(ValorPlano) then
        ValorPlano = ccur(ValorPlano)
    else
        ValorPlano = 0
    end if
    if isnumeric(StaID) and not isnull(StaID) then
        StaID = ccur(StaID)
        if (StaID=4 or StaID=3) and rdValorPlano="V" and ValorPlano>0 then
            set conf = db.execute("select * from sys_config")
            if not conf.eof then
                BaixaAuto = conf("BaixaAuto")&""
            end if
            if BaixaAuto="S" then
                set vcaBaixa = db.execute("select ii.id from itensinvoice ii left join sys_financialinvoices i on i.id=ii.InvoiceID where ii.Executado='S' and i.AssociationAccountID=3 and i.AccountID="& treatvalzero(PacienteID) &" and ii.Tipo='S' and DataExecucao="& mydatenull(Data) &" and ii.ItemID="& treatvalzero(ProcedimentoID))
                'se ainda nao foi baixado continua...
                if vcaBaixa.eof then
                    set vcaIIabaixar = db.execute("select ii.id from itensinvoice ii left join sys_financialinvoices i on i.id=ii.InvoiceID where ii.Executado='' and i.AssociationAccountID=3 and i.AccountID="& treatvalzero(PacienteID) &" and ii.Tipo='S' and ii.ItemID="& treatvalzero(ProcedimentoID) )
                    if not vcaIIabaixar.eof then
                        'baixando automaticamente um item que já existia
                        db_execute("update itensinvoice set DataExecucao="& mydatenull(Data) &",EspecialidadeID="&treatvalnull(EspecialidadeID)&", ProfissionalID="& treatvalzero(ProfissionalID) &", Executado='S' where id="& vcaIIabaixar("id"))
                    else
                        'criando a invopice já baixada

                        db_execute("insert into sys_financialinvoices (AccountID, AssociationAccountID, Value, TabelaID, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, FormaID, ContaRectoID, nroNFe, sysActive, CaixaID, sysUser, sysDate) values ("& treatvalzero(PacienteID) &", 3, "& treatvalzero(ValorPlano) &", "&treatvalnull(TabelaID)&", 1, 'BRL', "& treatvalzero(session("UnidadeID")) &", 1, 'm', 'C', 0, 0, NULL, 1, "& treatvalnull(CaixaID) &", "&session("User") &", "& myDateNULL(Data) &")")
                        set pultinv = db.execute("select id from sys_financialinvoices where sysActive=1 and sysUser="&session("User")&" order by id desc limit 1")
                        InvoiceID = pultinv("id")

                        db_execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, CaixaID, UnidadeID) values (0, 0, 3, "& treatvalzero(PacienteID) &", "& treatvalzero(ValorPlano) &", "&mydatenull(Data)&", 'C', 'Bill', 'BRL', 1, "& InvoiceID &", 1, "& session("User") &", "&treatvalnull(session("CaixaID")) &", "& treatvalzero(session("UnidadeID")) &")")

                        db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, CentroCustoID, ItemID, ValorUnitario, Desconto, Descricao, Executado, DataExecucao, HoraExecucao, AgendamentoID, sysUser, ProfissionalID, EspecialidadeID, HoraFim, Acrescimo, AtendimentoID, Associacao, PacoteID) values ("& InvoiceID &", 'S', 1, 0, 0, "&treatvalzero(ProcedimentoID)&", "& treatvalzero(ValorPlano) &", 0, '', 'S', "& mydatenull(Data) &", NULL, "&treatvalzero( AgendamentoID )&", "& session("User") &", "& treatvalzero(ProfissionalID) &", "&treatvalnull(EspecialidadeID)&", NULL, 0, 0, 5, 0)")

                    end if
                end if
            end if
        end if
    end if
end function

function lanctoQuantidade(ApresentacaoQuantidade, TipoUnidade, Quantidade)
    if TipoUnidade="U" then
        lanctoQuantidade = Quantidade
    else
        lanctoQuantidade = Quantidade * ApresentacaoQuantidade
    end if
end function

private function lrResult( lrStatus, lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse, lrLinha, lrFM, lrSobre, modoCalculo )
    select case lrFM
        case "F"
            titDescricao = "Função cadastrada diretamente na regra de repasse."
            if instr(lrCreditado, "_") then
                    totalRepasses = totalRepasses + lrValorRepasse
            end if
        case "M"
            titDescricao = "Material cadastrado diretamente na regra de repasse."
            totalMateriais = totalMateriais + lrValorRepasse
        case "K"
            titDescricao = "Produto cadastrado nos materiais do procedimento."
            totalMateriais = totalMateriais + lrValorRepasse
        case "E"
            titDescricao = "Função cadastrada na equipe do procedimento."
            if instr(lrCreditado, "_") then
                    totalRepasses = totalRepasses + lrValorRepasse
            end if
        case "Q"
            titDescricao = "Material baixado do estoque."
            totalMateriais = totalMateriais + lrValorRepasse
    end select

    lrSobre = lrSobre+1

    contaLR = contaLR + 1
    if right(lrNomeFuncao&"", 15)="Desconto cartão" then
        totalTaxas = totalTaxas + lrValorRepasse
    end if

    %>
    <tr>
            <td nowrap><%'= lrLinha %></td>
        <td>
                <%
                wSobre = 0
                while wSobre<lrSobre
                    %>
                    <i class="far fa-long-arrow-right"></i>
                    <%
                    wSobre = wSobre+1
                wend
                %>

            &nbsp; <span data-rel="tooltip" data-placement="right" title="" data-original-title="<%= titDescricao %>"><%= lrNomeFuncao %></span></td>
        <td><%= accountName(NULL, lrCreditado) %></td>
        <td class="text-right"> <% if modoCalculo="I" then response.Write(" <i class='far fa-info-circle text-warning' title='Cálculo invertido - Profissional paga à clínica'></i> ") end if %> <%= fn(lrValorRepasse) %></td>
    </tr>
    <%

        if req("InvoiceID")<>"" and 0 then
            db_execute("insert into temp_nfsplit set sysUser="&session("User")&", InvoiceID="&req("InvoiceID")&", Conta='"&lrCreditado&"', Valor="& treatvalzero(lrValorRepasse) &"")
        end if

end function

function getNomeLocalUnidade(UnidadeID)

        UnidadeTabela = "sys_financialcompanyunits"
        UnidadeID = UnidadeID

        if UnidadeID=0 then
            UnidadeTabela = "empresa"
            UnidadeID=1
        end if

        set UnidadeLocalSQL = db.execute("SELECT Sigla,NomeFantasia FROM "&UnidadeTabela&" WHERE id="&treatvalzero(UnidadeID))
        if not UnidadeLocalSQL.eof then
            if UnidadeLocalSQL("Sigla")&""<>"" then
                getNomeLocalUnidade = UnidadeLocalSQL("Sigla")
            else
                getNomeLocalUnidade = UnidadeLocalSQL("NomeFantasia")
            end if
        else
            getNomeLocalUnidade=""
        end if
end function

function descTI(T)
    select case T
        case "S"
            descTI = "Serviços"
        case "P"
            descTI = "Produtos"
        case "O"
            descTI = "Outros"
    end select
end function

function scp()
    if session("Banco")="clinic5459" or session("Banco")="clinic3882" or session("Banco")="clinic2263" or session("Banco")="clinic522" or session("Banco")="clinic2691" or session("Banco")="clinic5968" or session("Banco")="clinic100000" or session("Banco")="clinic5459" then
        scp = 1
    else
        scp = 0

    end if
end function

function logMessage(resource,itemId,message)
    db_execute("INSERT INTO log (Operacao,I,recurso,valorAtual,sysUser) VALUES ('M', "&treatvalzero(itemId)&", '"&resource&"', '"&message&"',"&treatvalzero(session("User"))&")")
end function

function updateStatusAgendamentos()
    hora = "18:00"
    set ConfigSQL = db.execute("SELECT AlterarStatusAgendamentosNoFimDoDia FROM sys_config WHERE id=1")
    AlterarStatus=False

    if not ConfigSQL.eof then
        if ConfigSQL("AlterarStatusAgendamentosNoFimDoDia")="S" then
            AlterarStatus=True
        end if
    end if

    if time()>cdate(hora) and AlterarStatus then
        db_execute("UPDATE agendamentos SET StaID=6 WHERE Data > DATE_SUB(CURDATE(), INTERVAL 3 DAY) AND Data < CURDATE() AND StaID IN (1,7)")
        db_execute("UPDATE agendamentos SET StaID=3 WHERE Data > DATE_SUB(CURDATE(), INTERVAL 3 DAY) AND Data < CURDATE() AND StaID IN (2,4,5,101,103,105)")
    end if
end function

function reconsolidar(Tipo, ItemID)
    if session("AutoConsolidar")="S" then
        set ConfigSQL = db.execute("SELECT SplitNF FROM sys_config WHERE id=1")
        if not ConfigSQL.eof then
            if ConfigSQL("SplitNF")=1 then
                db_execute("DELETE FROM nfe_notasemitidas WHERE situacao=0 AND numeronfse is null and InvoiceID="&ItemID)
            end if
        end if

        set vca = db.execute("select * from reconsolidar where Tipo='"& Tipo &"' and ItemID="& ItemID )
        if vca.eof then
            db.execute("insert into reconsolidar (Tipo, ItemID, sysUser) values ('"& Tipo &"', "& ItemID &", "& session("User") &")")
        end if
        %>
        $("#AutoConsolidar").attr("src", "AutoConsolidar.asp?I=<%=req("InvoiceID")%>&AC=1&T<%= time() %>");
        <%
    end if
end function

function accountUser(UserID)
    set pu = db.execute("select concat(replace(replace(lcase(`Table`), 'profissionais', '5'), 'funcionarios', '4'), '_', idInTable) Conta from sys_users where id="& UserID)
    if not pu.eof then
        accountUser = pu("Conta")
    end if
end function


function addNotificacao(TipoNotificacaoID, UsuarioID, NotificacaoIDRelativo, Prioridade, StatusID, Metadata)
    db.execute("INSERT INTO notificacoes (TipoNotificacaoID, UsuarioID, NotificacaoIDRelativo, Prioridade, StatusID, Metadata, CriadoPorID) VALUES ('"&TipoNotificacaoID&"', '"&UsuarioID&"', '"&NotificacaoIDRelativo&"', '"&Prioridade&"', '"&StatusID&"', '"&Metadata&"', "&session("User")&")")
    db.execute("UPDATE sys_users SET TemNotificacao=1 WHERE id="&UsuarioID)
end function

function updateUserNotifications(UserID)
    set TemNotifificacaoSQL = db.execute("SELECT id FROM notificacoes WHERE UsuarioID="&treatvalzero(UserID)&" AND StatusID IN (1,2) LIMIT 1")

    TemNotifiacao=0
    if not TemNotifificacaoSQL.eof then
            TemNotifiacao=1
    end if

    db.execute("UPDATE sys_users SET TemNotificacao="&TemNotifiacao&" WHERE id="&UserID)
end function


function recursoAdicional(RecursoAdicionalID)
    LicencaID=replace(session("Banco"), "clinic", "")
    Status = 0
    set RecursoAdicionalSQL = db.execute("SELECT Status FROM cliniccentral.clientes_servicosadicionais WHERE LicencaID="&treatvalzero(LicencaID)&" AND ServicoID="&treatvalzero(RecursoAdicionalID)&" order by DataContratacao desc limit 1")
    if not RecursoAdicionalSQL.eof then
        Status=RecursoAdicionalSQL("Status")

		if Status=11 then
			Status=4
		end if
    end if

    recursoAdicional=Status
end function

function getPlanosOptions(ConvenioID, PlanoID)
    if instr(PlanoID, "_")>0 then
        PlanoIDSplit = split(PlanoID,"_")
        PlanoID = PlanoIDSplit(0)
        Indice = PlanoIDSplit(1)

    end if

    set PlanosConvenioSQL = db.execute("SELECT NomePlano, id FROM conveniosplanos WHERE sysActive=1 and NomePlano!='' and ConvenioID="&ConvenioID)
    if not PlanosConvenioSQL.eof then

        planosOption="<option value=''>Selecione</option>"

        while not PlanosConvenioSQL.eof
            planoSelected = ""
            if PlanoID&"" = PlanosConvenioSQL("id")&"" then
                planoSelected=" selected "
            end if

            planosOption = planosOption&"<option "&planoSelected&" value='"&PlanosConvenioSQL("id")&"'>"&PlanosConvenioSQL("NomePlano")&"</option>"
        PlanosConvenioSQL.movenext
        wend
        PlanosConvenioSQL.close
        set PlanosConvenioSQL=nothing

        getPlanosOptions = "<div id='divConvenioPlano"&Indice&"' class='col-md-12 mt5' ><label for='PlanoID"&Indice&"'>Plano</label><select name='PlanoID"&Indice&"' id='PlanoID"&Indice&"' class='form-control'>"& planosOption &"</select></div>"
    else
        getPlanosOptions=""
    end if
end function

function calcValorProcedimento(ProcedimentoID, TabelaID, UnidadeID, ProfissionalID, EspecialidadeID, GrupoID,byref informacaoValor)

    set ValorProcedimentoSQL  = db.execute("SELECT Valor, NomeProcedimento FROM procedimentos WHERE id="&ProcedimentoID)
    DataReferencia            = ref("Data")
    obsLog                    = "procedimento (id:"&ProcedimentoID&")"
    eTabelaParticular         = false
    objDeTransferencia        = ""
    procedimentoNome          = ValorProcedimentoSQL("NomeProcedimento") &" #"&ProcedimentoID
    procedimentoValorOriginal = ValorProcedimentoSQL("valor")
    objDeTransferencia        = objDeTransferencia&"procedimento:'"&procedimentoNome&"',ProcedimentoID:'"&ProcedimentoID&"', valor:'"&procedimentoValorOriginal&"'"
    eVariacao                 = false

    if DataReferencia="" then
        DataReferencia = date()
    end if

    if not ValorProcedimentoSQL.eof then
        procValor=ValorProcedimentoSQL("Valor")
        obsLog = obsLog&" valor ("&procValor&")"
        sqlTabelaID = ""

        sqlProcedimentoTabela = "SELECT p.NomeProcedimento, p.Valor as valorOriginal, ptv.id, ptv.Valor, Profissionais, TabelasParticulares, pt.NomeTabela as nomeTabela, pt.id as tabelaIdDoValor, Especialidades FROM procedimentostabelasvalores ptv INNER JOIN procedimentostabelas pt ON pt.id=ptv.TabelaID /* left join tabelaparticular t2 on cliniccentral.overlap(pt.TabelasParticulares , concat('|',t2.id,'|')) */ join procedimentos p on p.id = ptv.ProcedimentoID WHERE ProcedimentoID="&ProcedimentoID&" AND "&_
        "(Especialidades='' OR Especialidades IS NULL OR Especialidades LIKE '%|"&EspecialidadeID&"|%' ) AND "&_
        "(Profissionais='' OR Profissionais IS NULL OR Profissionais LIKE '%|"&ProfissionalID&"|%' or '"&ProfissionalID&"'='' ) AND "&_
        "(TabelasParticulares='' OR TabelasParticulares IS NULL OR TabelasParticulares LIKE '%|"&TabelaID&"|%' OR TabelasParticulares LIKE '%|ALL|%' ) AND "&_
        "(pt.Unidades='' OR pt.Unidades IS NULL OR pt.Unidades LIKE '%|"&UnidadeID&"|%' ) AND "&_
        "pt.Fim>="&mydatenull(DataReferencia)&" AND pt.Inicio<="&mydatenull(DataReferencia)&" AND pt.sysActive=1 AND pt.Tipo='V' "
        ultimoPonto=0

        set ProcedimentoVigenciaSQL = db_execute(sqlProcedimentoTabela)

        if not ProcedimentoVigenciaSQL.eof then


            tabelaIdDoValor = ProcedimentoVigenciaSQL("tabelaIdDoValor")
            tabelaNomeDoValor = ProcedimentoVigenciaSQL("nomeTabela") &" #"&tabelaIdDoValor
            eTabelaParticular = true
            novoValor = procValor

            while not ProcedimentoVigenciaSQL.eof
                estePonto=0

                if instr(ProcedimentoVigenciaSQL("Profissionais"), "|"&ProfissionalID&"|")>0 then
                    estePonto = estePonto + 1
                end if

                if instr(ProcedimentoVigenciaSQL("TabelasParticulares"), "|"&TabelaID&"|")>0 then
                    estePonto = estePonto + 1
                end if

                if instr(ProcedimentoVigenciaSQL("Especialidades"), "|"&EspecialidadeID&"|")>0 then
                    estePonto = estePonto + 1
                end if

                if estePonto>=ultimoPonto then
                    ultimoPonto=estePonto
                    ptvID = ProcedimentoVigenciaSQL("id")
                    procValor = ProcedimentoVigenciaSQL("Valor")
                end if

            ProcedimentoVigenciaSQL.movenext
            wend
            ProcedimentoVigenciaSQL.close
            set ProcedimentoVigenciaSQL=nothing
            obsLog = obsLog&" novo valor ("&procValor&") referente a procedimentostabelasvalores (id:"&ptvID&")"
        end if
    end if

    valorCusto = 0

    IF instr(ProfissionalID, "2_") > 0 THEN
         ProfissionalIDSplit = split(ProfissionalID,"_")
         AssociationAccountID = ProfissionalIDSplit(0)
         AccountID = ProfissionalIDSplit(1)

         'response.write("SET @unidadeid = '"&UnidadeID&"';")
         'response.write("SET @tabelaid = '"&TabelaID&"';")
         'response.write("SET @procedimentoid = '"&ProcedimentoID&"';")
         'response.write("SET @AssociationAccountID = '"&AssociationAccountID&"';")
         'response.write("SET @AccountID = '"&AccountID&"';")
         'response.write("SET @_Tipo = 'p';")

         db.execute("SET @unidadeid = '"&UnidadeID&"';")
         db.execute("SET @tabelaid = '"&TabelaID&"';")
         db.execute("SET @procedimentoid = '"&ProcedimentoID&"';")
         db.execute("SET @AssociationAccountID = '"&AssociationAccountID&"';")
         db.execute("SET @AccountID = '"&AccountID&"';")
         db.execute("SET @_Tipo = 'p';")

         set valorParcial = db.execute("SELECT coalesce(sp_valortabela(NOW(), @unidadeid, @tabelaid, @procedimentoid, @AssociationAccountID, @AccountID, @_Tipo),0) as custo;")

         IF NOT valorParcial.EOF THEN
            valorCusto = valorParcial("custo")
            procValor = procValor - valorCusto
         END IF

         IF NOT valorCusto > 0 THEN
            'response.write("SELECT coalesce(sp_valortabela(NOW(), @unidadeid, @tabelaid, @procedimentoid, @AssociationAccountID, @AccountID, 'c'),0) as custo;")
            set valorCustoObj = db_execute("SELECT coalesce(sp_valortabela(NOW(), @unidadeid, @tabelaid, @procedimentoid, @AssociationAccountID, @AccountID, 'c'),0) as custo;")

            IF NOT valorCustoObj.EOF THEN
                valorCusto = valorCustoObj("custo")
            END IF
         END IF

    END IF

    if PacoteID<>"" then
        set ValorPacoteSQL = db_execute("SELECT pi.ValorUnitario FROM pacotesitens pi WHERE pi.PacoteID="&treatvalzero(PacoteID)&" AND pi.ProcedimentoID="&ProcedimentoID)
        if not ValorPacoteSQL.eof then
            procValor=ValorPacoteSQL("ValorUnitario")
            obsLog = obsLog&" (Pacote) com valor ("&procValor&")"
        end if
    end if


    sqlVarPreco = "select * from("&_
                       "select (if(instr(Procedimentos, '|"&ProcedimentoID&"|'), 0, 1)) PrioridadeProc, t.* from (select * from varprecos WHERE "&_
                       "((Procedimentos='' OR Procedimentos IS NULL)  "&_
                       "OR (Procedimentos LIKE '%|"&ProcedimentoID&"|%' AND Procedimentos LIKE '%|ONLY|%') "&_
                       "OR (Procedimentos NOT LIKE '%|"&ProcedimentoID&"|%' AND Procedimentos LIKE '%|EXCEPT|%') "&_
                       "OR (Procedimentos LIKE '%|GRUPO_"&GrupoID&"|%' AND Procedimentos LIKE '%|ONLY|%') "&_
                       "OR (Procedimentos NOT LIKE '%|GRUPO_"&GrupoID&"|%' AND Procedimentos LIKE '%|EXCEPT|%') "&_
                       "OR (Procedimentos LIKE '%|ALL|%') "&_
                       ") AND "&_
                       "(Profissionais='' OR Profissionais IS NULL OR Profissionais LIKE '%|"&ProfissionalID&"|%' ) AND "&_
                       "(Especialidades='' OR Especialidades IS NULL OR Especialidades LIKE '%|"&EspecialidadeID&"|%' ) AND "&_
                       "(Tabelas='' OR Tabelas IS NULL OR Tabelas LIKE '%|"&TabelaID&"|%' ) AND "&_
                       "(Unidades='' OR Unidades='0' OR Unidades IS NULL OR Unidades LIKE '%|"&UnidadeID&"|%' ) ORDER BY Ordem"&_
                   ") t ) t2 order by PrioridadeProc desc"

    set vcaTab = db_execute(sqlVarPreco)

    while not vcaTab.eof
        ApenasPrimeiroAtendimento = vcaTab("ApenasPrimeiroAtendimento")
        PermiteVariacao=True
        if ApenasPrimeiroAtendimento="S" then
            set PrimeiroAgendamentoSQL = db_execute("SELECT a.Data FROM agendamentos a WHERE a.PacienteID="&treatvalzero(PacienteID)&" AND a.StaID=3")
            if not PrimeiroAgendamentoSQL.eof then
                PermiteVariacao=False
            end if
        end if

        if PermiteVariacao then
            'response.Write("//"& sqlVarPreco )
            pmId = vcaTab("id")
            pmTipo = vcaTab("Tipo")
            pmValor = vcaTab("Valor")
            pmTipoValor = vcaTab("TipoValor")
        end if
    vcaTab.movenext
    wend
    vcaTab.close
    set vcaTab=nothing

    if pmTipo="F" then
        Valor2 = pmValor
        obsLog = obsLog&" modificado pelo valor fixo da regra de variacao (id: "&pmId&") valor final "&Valor2
    elseif pmTipo="D" or pmTipo="A" then
        eTabelaParticular= false
        eVariacao = true
        obsLog = obsLog&" modificado pela regra de variacao (id: "&pmId&")"

        if pmTipoValor="V" then
            pmDescAcre = pmValor
            obsLog = obsLog&" valor de R$"&pmDescAcre
        else
            pmFator = pmValor/100
            pmDescAcre = pmFator * procValor
            obsLog = obsLog&" percentual "&pmValor&"%"

        end if
        if pmTipo="D" then
            pmValor = procValor - pmDescAcre
            obsLog = obsLog&" de desconto"
        else
            pmValor = procValor + pmDescAcre
            obsLog = obsLog&" de acressimo"
        end if
        Valor2 = pmValor
        obsLog = obsLog&", valor final("&Valor2&")"

    end if

    session("obslog") = "Agendamento(id:"&ref("ConsultaID")&") grade(id:"&ref("GradeID")&")"&obsLog
    
    if eTabelaParticular then
        objDeTransferencia = objDeTransferencia&", nomeTabela:"""&tabelaNomeDoValor&""", idTabela:"&tabelaIdDoValor
    elseif eVariacao then
        objDeTransferencia = objDeTransferencia&", variacao :"&pmId
    end if


    if Valor2="" then
        novoValor = procValor
        calcValorProcedimento = procValor
    else
        novoValor = Valor2
        calcValorProcedimento= Valor2
    end if
    objDeTransferencia = objDeTransferencia&", novoValor:'"&novoValor&"',valorCusto:"&treatvalzero(valorCusto)
    response.Charset="utf-8"
    informacaoValor = "{"&objDeTransferencia&"}"

end function

function gravaLog(query, operacaoForce)

End function

function getLastAdded(table)
    getLastAdded = 0
    set rs = db.execute("SELECT id FROM "&table&" ORDER BY 1 DESC LIMIT 1")
    if not rs.eof then
        getLastAdded = rs("id")
    end if
End function


function arqEx(nArquivo, nTipo)

	if nArquivo&""="" then
        arqEx = ""
	else
		arqEx = "https://functions.feegow.com/load-image?licenseId="&LicenseID&"&folder="&nTipo&"&file="&nArquivo
	end if
end function

function getConfig(configName)
    set ConfigSQL = db.execute("SELECT IFNULL(cp.Valor, cc.ValorPadrao) ValorPadrao FROM cliniccentral.config_opcoes cc LEFT JOIN config_gerais cp ON cc.id = cp.ConfigID WHERE Coluna='"&configName&"'") 
    getConfig = 0
    if not ConfigSQL.eof then 
        c = ConfigSQL("ValorPadrao")
		if c&""="" then
			c = 0
		end if
		getConfig = c
    end if
end function


function franquiaUnidade(sqlfranquia)
    IF NOT ModoFranquiaUnidade THEN
        EXIT function
    END IF

    sqlfranquia = replace(sqlfranquia,"[UnidadeID]",session("UnidadeID"))
    'sqlfranquia = replace(sqlfranquia,"[Unidades]","|0|")
    sqlfranquia = replace(sqlfranquia,"[Unidades]","|"&session("Unidades")&"|")

    franquiaUnidade = sqlfranquia
end function


function franquia(sqlfranquia)
    IF getConfig("ModoFranquia")&"" <> "1" THEN
        EXIT function
    END IF

    IF ModoFranquiaUnidade THEN
        sqlfranquia = replace(sqlfranquia,"[UnidadeID]",session("UnidadeID"))
        sqlfranquia = replace(sqlfranquia,"[Unidades]","|"&session("UnidadeID")&"|")
    END IF

    IF ModoFranquiaCentral THEN
        sqlfranquia = replace(sqlfranquia,"[UnidadeID]",session("UnidadeID"))
        sqlfranquia = replace(sqlfranquia,"[Unidades]",session("Unidades"))
    END IF

    franquia = sqlfranquia
end function


function isUsuarioEmMaisDeUmaUnidade(xT,xI)
    xxxsql = "SELECT (SELECT count(*) > 1 as qtd FROM sys_financialcompanyunits WHERE cliniccentral.overlap(Unidades,CONCAT('|',id,'|'))) as quantidadeUnidades from "&xT&" WHERE id = "&xI
    set quantidadesResult = db.execute(xxxsql)
    isUsuarioEmMaisDeUmaUnidade = quantidadesResult("quantidadeUnidades") = "1"
end function



function confereCaixa()
    if session("CaixaID") <> "" then
        sqlDonoDoCaixa = "select sysUser from caixa c where id = "& session("CaixaID")
        set donoDocaixa = db.execute(sqlDonoDoCaixa)

        if not donoDocaixa.eof then

            idDonoDoCaixa = donoDocaixa("sysUser")

            if idDonoDoCaixa <> session("User") then
                set caixaID = db.execute("select id from caixa where sysUser="&session("User")&" and isnull(dtFechamento) order by id desc limit 1")
                if not caixaID.eof then
                    session("CaixaID") = caixaID("id")
                else
                    Session.Contents.Remove("CaixaID")
                end if
            end if
        else
            Session.Contents.Remove("CaixaID")
        end if
    end if
end function


function isAmorSaude()

    if LicenseID=7211 or LicenseID=8854 or LicenseID=100000 then
        isAmorSaude=True
    else
        isAmorSaude=False
    end if
end function


function franquiaAmorSaude(sqlfranquia)
    IF NOT ModoFranquia THEN
        EXIT function
    END IF

    IF NOT isAmorSaude() THEN
        EXIT function
    END IF

    IF ModoFranquiaUnidade THEN
        sqlfranquia = replace(sqlfranquia,"[UnidadeID]",session("UnidadeID"))
        sqlfranquia = replace(sqlfranquia,"[Unidades]","|"&session("UnidadeID")&"|")
    END IF

    IF ModoFranquiaCentral THEN
        sqlfranquia = replace(sqlfranquia,"[UnidadeID]",session("UnidadeID"))
        sqlfranquia = replace(sqlfranquia,"[Unidades]",session("Unidades"))
    END IF

    franquiaAmorSaude = sqlfranquia
end function


Function FieldExists(ByVal rs, ByVal fieldName)
    On Error Resume Next
    FieldExists = rs.Fields(fieldName).name <> ""
    If Err <> 0 Then FieldExists = False
    Err.Clear
End Function


function DefaultSessionUnidadeID(UsuarioID)
        qtdUnidadesArray = split(session("Unidades"), ",")
        UnidadeID=0
        UnidadeDefinida=False

        'verifica se o usuario ja se logou na data
        if ubound(qtdUnidadesArray) > 0 then
            set PrimeiroLoginDoDiaSQL = db.execute("SELECT id FROM cliniccentral.licencaslogins WHERE UserID="&UsuarioID&" AND date(DataHora)=curdate()")
            if PrimeiroLoginDoDiaSQL.eof then
                UnidadeID = -1
                UnidadeDefinida=True
                UnidadeMotivoDefinicao = "Primeiro login do dia"
            end if
        end if

        if UnidadeID=0 then
            if instr(session("Unidades"),"|"&sysUser("UnidadeID")&"|")>0 then
                UnidadeID = sysUser("UnidadeID")
            end if

            if ubound(qtdUnidadesArray) > 0 then
                UnidadeID= replace(qtdUnidadesArray(0), "|","")
            else
                if session("Unidades")&"" <> "" then
                    UnidadeID= replace(session("Unidades"), "|","")
                end if
            end if
        end if

        'seta a unidade de acordo com a que o usuario tem permissa
        if not UnidadeDefinida then
            if ubound(qtdUnidadesArray) > 0 then
                UnidadeID= replace(qtdUnidadesArray(0), "|","")
            else
                if session("Unidades")&"" <> "" then
                    UnidadeID= replace(session("Unidades"), "|","")
                end if
            end if
            UnidadeDefinida = True
            UnidadeMotivoDefinicao = "Primeira unidade do array do usuário"
        end if
        IF UnidadeID = -1 THEN
            set UltimaUnidadeSQL  = db.execute("SELECT UnidadeID FROM sys_users WHERE id="&session("User"))

            if not UltimaUnidadeSQL.eof then
                UnidadeID=UltimaUnidadeSQL("UnidadeID")

                if isnumeric(UnidadeID) then
                    UnidadeID=ccur(UnidadeID)
                end if
            end if
        END IF


        DefaultSessionUnidadeID = UnidadeID
end function


ModoFranquia        = getConfig("ModoFranquia") = "1"
if ModoFranquia then
    PorteClinica = 5
end if

ModoFranquiaCentral = getConfig("ModoFranquia") = "1" AND session("UnidadeID") = "0"
ModoFranquiaUnidade = getConfig("ModoFranquia") = "1" AND session("UnidadeID") <> "0"


function verificaBloqueioConta(lockTypeId, accountTypeId, AccountId, UnidadeId, datafechamento)

   IF getConfig("FechamentoDeData")<>"1"  THEN
         verificaBloqueioConta = 0
         EXIT FUNCTION
   END IF

    if InStr(1, datafechamento, "/", 1)> 0 then
        arrayDatapagamento  = split(datafechamento,"/")
        datafechamento= arrayDatapagamento(2)&"-"&arrayDatapagamento(1)&"-"&arrayDatapagamento(0)
    end if

    AccountId = replace(AccountId,"'","")
    UnidadeId = replace(UnidadeId,"'","")
    datafechamento = replace(datafechamento,"'","")
    sql = " SELECT COUNT(id) as qtd " &_
          " FROM sys_financiallockaccounts fla " &_
          " WHERE date(fla.data ) >= date('"&datafechamento&"') " &_
          " AND fla.UnidadeId = "&UnidadeId&" " &_
          " AND fla.sysactive = 1 " &_
          " -- AND fla.sysuserConfirmacao IS NOT null "
    set quant = db.execute(sql)
    if not quant.eof then
        if quant("qtd") <> "0" then
            verificaBloqueioConta = 1
        else
            verificaBloqueioConta = 0
        end if
    else
        verificaBloqueioConta = 0
    end if
end function

function decodeArrayPipe(arrayString)
    resultDecodeArrayBarraEmPe=replace(arrayString&"", "|", "")

    if resultDecodeArrayBarraEmPe&"" = "" then
        resultDecodeArrayBarraEmPe="NULL"
    end if

    decodeArrayPipe=resultDecodeArrayBarraEmPe
end function

function isServerHomologacao

    Dominio = session("Servidor")
    isServerHomologacao = instr(Dominio, "test")>0

end function


function getPerfil

    IF session("PerfilDescricao") <> "" THEN
        getPerfil = session("PerfilDescricao")
        exit function
    END IF

    strOrdem = "Padrao"

    IF lcase(session("Table"))="funcionarios" THEN
        strOrdem = "PadraoFuncionario"
    END IF

    set ResultPermissoes = db_execute("SELECT regraspermissoes.Regra FROM usuarios_regras JOIN regraspermissoes ON regraspermissoes.id = usuarios_regras.regra WHERE usuario = "&session("User")&" AND unidade = "&session("UnidadeID")&" or "&strOrdem&" = 1 ORDER BY "&strOrdem&" ")

    IF NOT ResultPermissoes.EOF THEN
        getPerfil = ResultPermissoes("Regra")
        session("PerfilDescricao") = getPerfil
        exit function
    END IF

    getPerfil = "Não possível identificar"
end function


function hasPermissaoTela(visualizar)

    IF not (aut(visualizar)=1) THEN %>
        <h1 class="text-center">
            Você não tem permissão a visualizar esta tela.
        </h1>
    <%
    response.end
    END IF
end function

function iconMethod(PaymentMethodID, PaymentMethod, CD ,origem)
    if CD="" or isnull(CD) then
        CD = "D"
    end if
	if not isNull(PaymentMethodID) then
		response.Write("<img width=""18"" src=""assets/img/"&PaymentMethodID&CD&".png"" /> ")


        if origem <> "" then
        response.Write("<small>"& PaymentMethod &" ("&origem&") </small>")
        else
        response.Write("<small>"& PaymentMethod &" </small>")
        end if
    end if
end function


function invoicePaga(invoiceID)
 
    invoicePaga =false
 
set dadosInvoice = db.execute("SELECT SUM(m.ValorPago) valorPago, i.Value "&_
" FROM sys_financialinvoices i"&_
" JOIN sys_financialmovement m ON m.InvoiceID = i.id "&_
" WHERE i.id = "&invoiceID&_
"")

if not dadosInvoice.eof then
if dadosInvoice("valorPago") => dadosInvoice("Value") then
            invoicePaga =true
end if
end if
 
end function

function getConfAO(NomeConfig)
    sqlVCA = "select * from aoconfig where NomeConfig='"& NomeConfig &"'"
    set vca = db.execute(sqlVCA)
    if vca.eof then
        db.execute("insert into aoconfig set NomeConfig='"& NomeConfig &"'")
        set vca = db.execute(sqlVCA)
    end if
    getConfAO = vca("Val")
end function


function getClientDataHora(UnidadeID)
            
    HorarioVerao = ""
    if UnidadeID=0 then
        set getNome = db.execute("select FusoHorario, HorarioVerao from empresa")
        if not getNome.eof then
            FusoHorario = getNome("FusoHorario")
            HorarioVerao = getNome("HorarioVerao")
        end if
    elseif UnidadeID>0 then
        set getNome = db.execute("select FusoHorario, HorarioVerao from sys_financialcompanyunits where id="&session("UnidadeID"))
        if not getNome.eof then
            FusoHorario = getNome("FusoHorario")
            HorarioVerao = getNome("HorarioVerao")
        end if
    end if

    getClientDataHora = dateadd("h",FusoHorario + 3, now())

end function

function rw(txt)
    rw = response.write(txt &"<br>")
end function

function convertSimbolosHexadecimal(Texto)
    Texto = replace(Texto, "►", "&#9658;")
    Texto = replace(Texto, "→", "&#x279e;")
    Texto = replace(Texto, "⇒", "&#8658;")
    Texto = replace(Texto, "⇔", "&#8660;")
    Texto = replace(Texto, "♦", "&#x2b27;")
    Texto = replace(Texto, "≈", "&#8776;")

    convertSimbolosHexadecimal = Texto

end function

function arredonda(InvoiceID)
    if getConfig("ArredondarValorTotalReceber") then
        'somente arredonda se:
        '1. Não há pagamento lançado
        set vcaPagto = db.execute("select id from sys_financialdiscountpayments where InstallmentID IN (select id from sys_financialmovement where InvoiceID="& InvoiceID &")")
        if vcaPagto.eof then
            set valTot = db.execute("select ifnull(sum( Quantidade* (ValorUnitario-Desconto+Acrescimo) ),0) TotalItens from itensinvoice where InvoiceID="& InvoiceID)
            TotalItens = ccur(valTot("TotalItens"))
            TotalItensRedondo = cint(TotalItens)
            if TotalItens<TotalItensRedondo then
                AcrescimoAdic = TotalItensRedondo-TotalItens
                DescontoAdic = 0
            elseif TotalItens>TotalItensRedondo then
                AcrescimoAdic = 0
                DescontoAdic = TotalItens-TotalItensRedondo
            end if
            DescontoFinal = DescontoAdic-AcrescimoAdic
            if (AcrescimoAdic>0 or DescontoAdic>0) then
                set maxDesc = db.execute("select id, Desconto from itensinvoice where InvoiceID="& InvoiceID &" and Quantidade=1 and Tipo='S' ORDER BY Desconto DESC LIMIT 1")
                if not maxDesc.eof then
                    if ccur(maxDesc("Desconto"))-AcrescimoAdic+DescontoAdic>0 then
                        db.execute("update itensinvoice set Desconto=Desconto+"& treatvalzero(DescontoAdic-AcrescimoAdic) &" where id="& maxDesc("id") )
                        db.execute("update sys_financialmovement SET Value=Value+"& treatvalzero(AcrescimoAdic-DescontoAdic) &" where Type='Bill' AND InvoiceID="&InvoiceID &" LIMIT 1")
                        upInv = "update sys_financialinvoices set VALUE=(select ifnull(sum( Quantidade*(ValorUnitario-Desconto+Acrescimo)),0) FROM itensinvoice where InvoiceID="& InvoiceID &" ) WHERE id="& InvoiceID
                        'response.write( upInv )
                        db.execute( upInv )
                    end if
                end if
            end if
        end if
    end if
end function

function lenu(val, convertTo)
    'convertTo deve ser L ou N
    numero = 0
    letras = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"
    splLetras = split(letras, ",")
    val = lcase(val&"")
    lenu = val
    for il=0 to ubound(splLetras)
        numero = numero+1
        letra = splLetras(il)
        if IsNumeric(val) and convertTo="L" and numero&""=val&"" then
            lenu = ucase(letra&"")
        end if
        if not isnumeric(val) and convertTo="N" and letra=val&"" then
            lenu = numero
        end if
    next
end function

'Verifica se tem permissão pelo Care Team do Paciente.
'O usuário logado e o usuário especificado nos parâmetros
'devem pertencer ao CareTeam do paciente.
'   Parâmetros:
'      SysUserID  - Id do profissional na tabela sys_user
'      PacienteID - Id do paciente
function autCareTeam(SysUserID, PacienteID)
    autCareTeam = false

    if lcase(session("table"))="profissionais"  then

        set rsUser = db.execute("SELECT idInTable FROM sys_users WHERE id = '" & SysUserID & "' AND `Table` = 'profissionais' LIMIT 1")
        if not rsUser.eof then

            sqlCareTeam = "SELECT COUNT(*) AS cnt FROM pacientesprofissionais " &_
                          "WHERE ProfissionalID IN ('" & session("idInTable")  & "', '" & rsUser("idInTable") & "') " &_
                          "AND PacienteID = '" & PacienteID & "' AND sysActive = 1"

            set rsCareTeam = db.execute(sqlCareTeam)
            if not rsCareTeam.eof then
                if cint(rsCareTeam("cnt")) = 2 then
                    autCareTeam = true
                end if
            end if

            rsCareTeam.close
            set rsCareTeam=nothing
        end if
        rsUser.close
        set rsUser=nothing

    end if

end function
%>