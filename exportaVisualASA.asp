<!--#include file="connect.asp"-->
<!--#include file="limpaMemo.asp"-->
<%
'on error resume next

server.ScriptTimeout = 100000

'response.Charset="utf-8"

Set origem = Server.CreateObject("ADODB.Connection")
origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&req("Origem")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
'origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellos;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"

Set destino = Server.CreateObject("ADODB.Connection")
destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&req("Destino")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
'destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellosimportado;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"

'set p = origem.execute("SELECT Campo2 CONVERT(Campo2 USING utf8) FROM pro_infoclinicas where not isnull(Campo2) limit 1")
'while not p.eof
'	blob = p("Campo2")
'	response.Write(blob)
'p.movenext
'wend
'p.close
'set p=nothing

function nascimento(val)
	if len(val)=8 then
		nascimento = "'"&left(val,4)&"-"&mid(val,5,2)&"-"&right(val,2)&"'"
	else
		nascimento = "NULL"
	end if
end function

function phone(ddd, tel)
	if len(ddd)<>2 then
		ddd = 61
	end if
	if not isnull(tel) then
		tel = replace(replace(tel, "-",""), " ","")
	end if
'	if len(tel)=8 then
'		finalTel = right(tel, 
	phone = ddd&tel
end function

function sexo(val)
	if val="F" then
		sexo = 2
	elseif val="M" then
		sexo = 1
	else
		sexo=0
	end if
end function

function estadocivil(val)
	select case val
		case "C"
			estadocivil = 1
		case "S"
			estadocivil = 2
		case "D"
			estadocivil = 3
		case "V"
			estadocivil = 4
		case else
			estadocivil = 0
	end select
end function

function corpele(val)
	select case val
		case "BRANCA"
			corpele = 1
		case "NEGRA"
			corpele = 2
		case "MORENA"
			corpele = 3
		case "BRANCO"
			corpele = 1
		case "MORENO"
			corpele = 3
		case "NEGRO"
			corpele = 2
		case else
			corpele = 0
	end select
end function

function grauinstrucao(val)
	select case val
		case "SUPERIOR"
			grauinstrucao = 5
		case "SUPERIOR CURSANDO"
			grauinstrucao = 6
		case "SUPERIOR INCOMPLETO"
			grauinstrucao = 6
		case else
			grauinstrucao = 0
	end select
end function

'PACIENTES => apaga tudo antes
'destino.execute("delete from pacientes")
'set p = origem.execute("select p.*, prf.Profissao, c.Cidade, e.Estado, b.Bairro, pac.* from sis_pessoa as p left join sis_cidade as c on c.IDCidade=p.IDCidade left join sis_bairro as b on b.IDBairro=p.IDBairro left join sis_estado as e on e.IDEstado=p.IDEstado left join sis_profissao as prf on prf.IDProfissao=p.IDProfissao left join sis_paciente as pac on p.IDPessoa=pac.IDPaciente where p.IDPessoaTipo=6 order by IDPessoa")
'while not p.eof
'	Tel1=""
'	Tel2=""
'	Cel1=""
'	Cel2=""
'	Email1=""
'	Email2=""
'	set tels = origem.execute("select * from sis_pessoatelefone where IDPessoa="&p("IDPessoa")&" and not isnull(Telefone)")
'	memoTel = ""
'	c=0
'	while not tels.eof
'		c=c+1
'		memoTel = memoTel&tels("Telefone")&chr(13)
'		if c=1 then
'			Tel1=tels("Telefone")
'		end if
'		if c=2 then
'			Tel2=tels("Telefone")
'		end if
'		if c=3 then
'			Cel1=tels("Telefone")
'		end if
'		if c=4 then
'			Cel2=tels("Telefone")
'		end if
'	tels.movenext
'	wend
'	tels.close
'	set tels=nothing
'	set emails = origem.execute("select * from sis_pessoaemail where not isnull(Email) and IDPessoa="&p("IDPessoa"))
'	c = 0
'	while not emails.eof
'		c = c+1
'		if c=1 then
'			Email1 = emails("Email")
'		end if
'		if c=2 then
'			Email2 = emails("Email")
'		end if
'	emails.movenext
'	wend
'	emails.close
'	set emails=nothing

'	sql = "INSERT INTO `pacientes` (`id`, `NomePaciente`, `Nascimento`, `Sexo`, `Cep`, `Cidade`, `Estado`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `EstadoCivil`, `CorPele`, `GrauInstrucao`, `Profissao`, `Naturalidade`, `Tel1`, `Documento`, `Origem`, `Email1`, `CPF`, `Tabela`, `Peso`, `Altura`, `IMC`, `Observacoes`, `Pendencias`, `Foto`, `Religiao`, `Tel2`, `Cel1`, `Cel2`, `Email2`, `Pais`, `IndicadoPor`, `sysActive`, `sysUser`) VALUES ("&p("IDPessoa")&", '"&rep(p("Pessoa"))&"', "&mydatenull(p("Nascimento"))&", '"&sexo(p("Sexo"))&"', '"&p("Cep")&"', '"&p("Cidade")&"', '"&p("Estado")&"', '"&p("Endereco")&"', '"&p("Numero")&"', '"&p("Complemento")&"', '"&p("Bairro")&"', "&estadocivil(p("EstadoCivil"))&", 0, 0, '"&p("Profissao")&"', '', '"&Tel1&"', '"&p("Identidade")&" "&p("OrgaoEmissor")&"', '', '"&Email1&"', '"&p("CPF")&"', 0, 0, 0, 0, '"&p("Observacao")&"', '"&memoTel&"', '', '', '"&Tel2&"', '"&Cel1&"', '"&Cel2&"', '"&Email2&"', NULL, '', 1, 1)"
'	destino.execute(sql)
'p.movenext
'wend
'p.close
'set p=nothing

'PROFISSIONAIS
'destino.execute("delete from profissionais")
'set pro = origem.execute("select distinct IDMedico, p.* from age_marcacao as a left join sis_pessoa as p on p.IDPessoa=a.IDMedico")
'while not pro.eof
'	destino.execute("insert into profissionais (id, TratamentoID, NomeProfissional, Ativo, sysActive, sysUser) values ('"&pro("IDMedico")&"', 2, '"&pro("Pessoa")&"', 'on', 1, 1)")
'pro.movenext
'wend
'pro.close
'set pro=nothing


'CONVENIOS
'destino.execute("delete from convenios")
'set conv = origem.execute("select p.*, c.Cidade, e.Estado, b.Bairro from sis_pessoa as p left join sis_cidade as c on c.IDCidade=p.IDCidade left join sis_bairro as b on b.IDBairro=p.IDBairro left join sis_estado as e on e.IDEstado=p.IDEstado where p.IDPessoaTipo=2")
'while not conv.eof
'	destino.execute("insert into convenios (id, NomeConvenio, RazaoSocial, TelAut, Contato, RegistroANS, CNPJ, Endereco, Numero, Complemento, Bairro, Cidade, Estado, Cep, Telefone, Fax, Email, NumeroContrato, Obs, ContaRecebimento, RetornoConsulta, FaturaAtual, sysActive, sysUser) values ("&conv("IDPessoa")&", '"&rep(conv("Pessoa"))&"', '"&rep(conv("RazaoSocial"))&"', '', '', '', '"&conv("CGC")&"', '"&rep(conv("Endereco"))&"', '"&conv("Numero")&"', '"&conv("Complemento")&"', '"&rep(conv("Bairro"))&"', '"&rep(conv("Cidade"))&"', '"&conv("Estado")&"', '"&conv("Cep")&"', '', '', '', '', '', 0, '', '', 1, 1)")
'conv.movenext
'wend
'conv.close
'set conv=nothing

'CONVENIOS DO PACIENTE
'on error resume next
'destino.execute("delete from pacientesconvenios")
'set convpac = origem.execute("select * from paciente where not isnull(Convenio1) and Convenio1<>0")
'while not convpac.eof
'	response.Write("insert into pacientesconvenios (ConvenioID, PlanoID, Matricula, Validade, Titular, PacienteID, sysActive, sysUser) values ("&convpac("Convenio1")&", 0, '"&rep(convpac("ConMatCar1"))&"', "&nascimento(rep(convpac("ConValidade1")))&", '"&rep(convpac("ConTitular1"))&"', "&convpac("id")&", 1, 0)<br /><br />")
'	destino.execute("insert into pacientesconvenios (ConvenioID, PlanoID, Matricula, Validade, Titular, PacienteID, sysActive, sysUser) values ("&convpac("Convenio1")&", 0, '"&rep(convpac("ConMatCar1"))&"', "&nascimento(rep(convpac("ConValidade1")))&", '"&rep(convpac("ConTitular1"))&"', "&convpac("id")&", 1, 0)")
'convpac.movenext
'wend
'convpac.close
'set convpac=nothing




'PROCEDIMENTOS
'destino.execute("delete from procedimentos")
'set proc = origem.execute("select * from age_item where System=0")
'while not proc.eof
'	destino.execute("insert into procedimentos (id, NomeProcedimento, sysActive, sysUser) values ("&proc("IDItem")&", '"&rep(proc("Item"))&"', 1, 1)")
'proc.movenext
'wend
'proc.close
'set proc=nothing

'AGENDAMENTOS
'on error resume next
'destino.execute("delete from agendamentos")
'set a = origem.execute("select a.* from age_marcacao as a where not isnull(a.IDPaciente) order by IDMarcacao desc")
'while not a.eof
'	destino.execute("INSERT INTO `agendamentos` (`id`, `PacienteID`, `ProfissionalID`, `Data`, `Hora`, `TipoCompromissoID`, `StaID`, `ValorPlano`, `rdValorPlano`, `Notas`, `Falado`, `FormaPagto`, `LocalID`, `Tempo`, `HoraFinal`, `SubtipoProcedimentoID`) VALUES ('"&a("IDMarcacao")&"', '"&a("IDPaciente")&"', '"&a("IDMedico")&"', "&mydatenull(a("DataMarcada"))&", "&mytime(a("DataMarcada"))&", '"&a("IDItem")&"', 7, "&treatvalzero(a("IDConvenio"))&", 'P', '"&a("Observacao")&"', '', 0, 0, '0', NULL, 0)"&chr(13))
'a.movenext
'wend
'a.close
'set a=nothing


'===> ATÉ AQUI ESTÁ OK!





'------> Formulas
'set f = origem.execute("select * from formulas order by Form_ln_Counter")
'while not f.eof
'	destino.execute("insert into pacientesformulas (id, Nome, Uso, Quantidade, Grupo, Prescricao, Observacoes, sysUser, sysActive) values ("&f("Form_ln_Counter")&", '"&rep(f("Form_tx_NomeFormula"))&"', '"&rep(f("Form_tx_UsoFormula"))&"', '"&rep(f("Form_tx_QuantidadeFormula"))&"', '"&rep(f("Form_tx_GrupoFormula"))&"', '"&limpamemo(f("Form_me_DescricaoFormula"))&"<br />"&limpamemo(f("Form_me_PrescricaoFormula"))&"', '"&limpamemo(f("Form_me_ObservacoesFormula"))&"', 0, 1)")
'f.movenext
'wend
'f.close
'set f=nothing
'destino.execute("update pacientesformulas set Observacoes=replace(Observacoes, '<br /', '')")
'<------ Formulas

'------> Medicamentos
'set m = origem.execute("select * from medicamentos")
'while not m.eof
'	destino.execute("insert into pacientesmedicamentos (id, Medicamento, Apresentacao, Grupo, Uso, Quantidade, Prescricao, Observacoes, sysActive, sysUser) values ("&m("Medi_ln_Counter")&", '"&rep(m("Medi_tx_NomeMedicamento"))&"', '"&rep(m("Medi_tx_ApresentacaoMedicamento"))&"', '', '"&rep(m("Medi_tx_UsoMedicamento"))&"', '"&rep(left(m("Medi_tx_QuantidadeMedicamento"),25))&"', '"&limpamemo(m("Medi_me_PrescricaoMedicamento"))&"', '"&limpamemo(m("Medi_me_ObservacoesMedicamento"))&"', 1, 0)")
'm.movenext
'wend
'm.close
'set m=nothing
'<------

'------> Anamneses
'''---> Criando o formulário
'NomeModelo = "Anamneses Importadas"
'set vca = destino.execute("select * from buiforms where Nome like '"&NomeModelo&"'")
'if vca.eof then
'	destino.execute("insert into buiforms (Nome, Especialidade, Tipo, sysActive, sysUser) values ('"&NomeModelo&"', '', 1, 1, 0)")
'	set vca = destino.execute("select * from buiforms order by id desc")
'	FormID = vca("id")
'	destino.execute("insert into buicamposforms (TipoCampoID, NomeCampo, RotuloCampo, FormID, Ordem, ValorPadrao, Tamanho, Largura, MaxCarac, Checado, Obrigatorio, Texto, pTop, pLeft, Colunas, Linhas) values "&_
'		"(8, 'anamnese', 'Anamnese', "&FormID&", 0, '', 1, '', '20', 'S', '', '', 4, 3, 0, 0), "&_
'		"(1, 'diagnóstico_1', 'Diagnóstico 1', "&FormID&", 0, '', 2, '20', '70', '', '', '', 485, 1, 0, 0), "&_
'		"(1, 'diagnóstico_2', 'Diagnóstico 2', "&FormID&", 0, '', 2, '20', '70', '', '', '', 485, 382, 0, 0)")
'end if
'FormID = vca("id")
'set pult = destino.execute("select * from buicamposforms where FormID="&FormID&" order by id desc")
'diag2 = pult("id")
'diag1 = pult("id")-1
'anamn = pult("id")-2
'destino.execute("CREATE TABLE IF NOT EXISTS `_"&FormID&"` (`id` INT(11) NOT NULL AUTO_INCREMENT,	`PacienteID` INT(11) NULL DEFAULT NULL,	`DataHora` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `sysUser` INT(11) NULL DEFAULT NULL,	`"&anamn&"` TEXT NULL,	`"&diag1&"` VARCHAR(70) NULL DEFAULT NULL,	`"&diag2&"` VARCHAR(70) NULL DEFAULT NULL,	PRIMARY KEY (`id`)) COLLATE='utf8_general_ci' ENGINE=InnoDB ROW_FORMAT=COMPACT")
'''<--- Criando o formulário
'''---> Dados
'ComecarEm = 100
'set a = origem.execute("select * from anamneses")
'while not a.eof
'	Data = cdate( day(a("Anam_dt_DataAnamnese"))&"/"&month(a("Anam_dt_DataAnamnese"))&"/"&year(a("Anam_dt_DataAnamnese")) )
'	destino.execute("insert into buiformspreenchidos (id, ModeloID, PacienteID, DataHora, sysUser) values ("&a("Anam_ln_Counter")+ComecarEm&", "&FormID&", "&a("Anam_ln_Paciente")&", "&mydatenull(Data)&", 0)")
'	destino.execute("insert into `_"&FormID&"` (id, PacienteID, DataHora, sysUser, `"&anamn&"`, `"&diag1&"`, `"&diag2&"`) values ("&a("Anam_ln_Counter")+ComecarEm&", "&a("Anam_ln_Paciente")&", "&mydatenull(Data)&", 0, '"&limpamemo(a("Anam_me_TextoAnamnese"))&"', '"&rep(a("Anam_tx_Diagnostico1"))&"', '"&rep(a("Anam_tx_Diagnostico2"))&"')")
'a.movenext
'wend
'a.close
'set a=nothing
'''<--- Dados
'<------ Anamneses

'------> Consultas e Retornos
'''---> Criando o formulário
'NomeModelo = "Consultas e Retornos"
'set vca = destino.execute("select * from buiforms where Nome like '"&NomeModelo&"'")
'if vca.eof then
'	destino.execute("insert into buiforms (Nome, Especialidade, Tipo, sysActive, sysUser) values ('"&NomeModelo&"', '', 1, 1, 0)")
'	set vca = destino.execute("select * from buiforms order by id desc")
'	FormID = vca("id")
'	destino.execute("insert into buicamposforms (TipoCampoID, NomeCampo, RotuloCampo, FormID, Ordem, ValorPadrao, Tamanho, Largura, MaxCarac, Checado, Obrigatorio, Texto, pTop, pLeft, Colunas, Linhas) values "&_
'		"(8, 'texto_da_consulta', 'Texto da Consulta', "&FormID&", 0, '', 1, '', '20', 'S', '', '', 4, 3, 0, 0)")
'end if
'FormID = vca("id")
'set pult = destino.execute("select * from buicamposforms where FormID="&FormID&" order by id desc")
'cr = pult("id")
'destino.execute("CREATE TABLE IF NOT EXISTS `_"&FormID&"` (`id` INT(11) NOT NULL AUTO_INCREMENT,	`PacienteID` INT(11) NULL DEFAULT NULL,	`DataHora` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `sysUser` INT(11) NULL DEFAULT NULL,	`"&cr&"` TEXT NULL, PRIMARY KEY (`id`)) COLLATE='utf8_general_ci' ENGINE=InnoDB ROW_FORMAT=COMPACT")
'''<--- Criando o formulário
'''---> Dados
'ComecarEm = 8000
'set a = origem.execute("select * from consultaseretornos")
'while not a.eof
'	Data = cdate( day(a("Cons_dt_CH2"))&"/"&month(a("Cons_dt_CH2"))&"/"&year(a("Cons_dt_CH2")) )
'	destino.execute("insert into buiformspreenchidos (id, ModeloID, PacienteID, DataHora, sysUser) values ("&a("Cons_ln_Counter")+ComecarEm&", "&FormID&", "&a("Cons_ln_Paciente")&", "&mydatenull(Data)&", 0)")
'	destino.execute("insert into `_"&FormID&"` (id, PacienteID, DataHora, sysUser, `"&cr&"`) values ("&a("Cons_ln_Counter")+ComecarEm&", "&a("Cons_ln_Paciente")&", "&mydatenull(Data)&", 0, '"&limpamemo(a("Cons_me_TextoConsultaRetorno"))&"')")
'a.movenext
'wend
'a.close
'set a=nothing
'''<--- Dados
'<------ Consultas e Retornos

'------> Prescrições
'set t = origem.execute("select * from textos")
'while not t.eof
'	id = t("Text_ln_Counter")
'	PacienteID = t("Text_ln_Paciente")
'	Texto = limpamemo(t("Text_me_Texto"))
'	Data = t("Text_dt_DataTexto")
'	Data = cdate( day(Data)&"/"&month(Data)&"/"&year(Data) )
'	destino.execute("insert into pacientesprescricoes (id, Data, sysUser, PacienteID, Prescricao, ControleEspecial) values ("&id&", "&mydatenull(Data)&", 0, "&PacienteID&", '"&Texto&"', '')")
't.movenext
'wend
't.close
'set t=nothing
'<------ Prescrições

'------> Contatos
'set con = origem.execute("select * from telefones")
'while not con.eof
'	IniciarEm = 100
'	id = con("Tele_ln_Counter")+IniciarEm
'	NomeContato = rep(con("Tele_tx_Nome"))
'	Observacoes = rep(con("Tele_tx_Telefones"))&chr(10)&replace(con("Tele_me_Notas"), "'", "''")
'	Email1 = con("Tele_tx_Email")
'	destino.execute("insert into contatos (id, NomeContato, Sexo, Cep, Cidade, Estado, Endereco, Numero, Complemento, Bairro, Tel1, Email1, Observacoes, Tel2, Cel1, Cel2, Email2, sysActive, sysUser) values ("&id&", '"&NomeContato&"', 0, '', '', '', '', '', '', '', '', '"&Email1&"', '"&Observacoes&"', '', '', '', '', 1, 0)")
'con.movenext
'wend
'con.close
'set con=nothing
'<------ Contatos
%>