<!--#include file="connect.asp"-->
<!--#include file="limpaMemo.asp"-->
<%
'on error resume next

server.ScriptTimeout = 100000

Set origem = Server.CreateObject("ADODB.Connection")
origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&request.QueryString("Origem")&";uid=root;pwd=pipoca453;"
'origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellos;uid=root;pwd=pipoca453;"

Set destino = Server.CreateObject("ADODB.Connection")
destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&request.QueryString("Destino")&";uid=root;pwd=pipoca453;"
'destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellosimportado;uid=root;pwd=pipoca453;"


'set p = origem.execute("select * from sch_contact")
'while not p.eof
'	response.Write(limpaMemo(p("Fld3"))&"<hr />")
'p.movenext
'wend
'p.close
'set p=nothing

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

function staID(val)
	select case val
		case 1
			staID = 3
		case 2
			staID = 4
		case 3
			staID = 6
		case 4
			staID = 3
		case 5
			staID = 7
		case 6
			staID = 3
		case 7
			staID = 1
		case 8
			staID = 1
		case 9
			staID = 1
		case 10
			staID = 1
		case 11
			staID = 1
		case 12
			staID = 3
		case 13
			staID = 1
		case 14
			staID = 3
		case 16
			staID = 6
		case else
			staID = 1
	end select
end function

'set p = origem.execute("select * from pacientes order by Paci_ln_Counter")
'while not p.eof
'	destino.execute("INSERT INTO `pacientes` (`id`, `NomePaciente`, `Nascimento`, `Sexo`, `Cep`, `Cidade`, `Estado`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `EstadoCivil`, `CorPele`, `GrauInstrucao`, `Profissao`, `Naturalidade`, `Tel1`, `Documento`, `Origem`, `Email1`, `CPF`, `Tabela`, `Peso`, `Altura`, `IMC`, `Observacoes`, `Pendencias`, `Foto`, `Religiao`, `Tel2`, `Cel1`, `Cel2`, `Email2`, `Pais`, `IndicadoPor`, `sysActive`, `sysUser`) VALUES ("&p("Paci_ln_Counter")&", '"&rep(p("Paci_tx_NomePaciente"))&"', "&myDateNULL(p("Paci_dt_DataNascimentoPaciente"))&", "&sexo(p("Paci_tx_SexoPaciente"))&", '"&left(rep(p("Paci_tx_CEPPaciente")), 9)&"', '"&rep(p("Paci_tx_CidadePaciente"))&"', '"&rep(p("Paci_tx_UFPaciente"))&"', '"&rep(p("Paci_tx_LogradouroPaciente"))&"', '', '"&rep(p("Paci_tx_ComplementoPaciente"))&"', '"&rep(p("Paci_tx_BairroPaciente"))&"', "&estadocivil(p("Paci_tx_EstadoCivilPaciente"))&", "&corpele(p("Paci_tx_CorPaciente"))&", "&grauinstrucao(p("Paci_tx_GraudeInstrucaoPaciente"))&", '"&rep(p("Paci_tx_ProfissaoPaciente"))&"', '"&rep(p("Paci_tx_NaturalidadePaciente"))&"', '', '', '', '"&rep(p("Paci_tx_EMail"))&"', '"&rep(p("Paci_tx_CPFPaciente"))&"', NULL, NULL, NULL, NULL, '"&rep(limpaMemo(p("Paci_me_ObservacoesPaciente")))&"', '"&rep(p("Paci_tx_TelefonesPaciente"))&"', '', '', '', '', '', '"&rep(p("Paci_tx_EMailMed"))&"', NULL, '"&rep(p("Paci_tx_IndicadoPorPaciente"))&"', 1, 1)")

'p.movenext
'wend
'p.close
'set p=nothing

Acrescenta = 50'pois no hidoctor cada agenda tem seus compromissos
'set proc = origem.execute("select * from classificacoes")
'while not proc.eof
'	destino.execute("insert into procedimentos (id, NomeProcedimento, sysActive, sysUser) values ("&proc("Clas_ln_Counter")+Acrescenta&", '"&rep(proc("Clas_tx_Descricao"))&"', 1, 1)")
'proc.movenext
'wend
'proc.close
'set proc=nothing

'Fotos vindas depois...
'set p = origem.execute("select Paci_ln_Counter as id from pacientes where length(Paci_me_Foto)>10")
'while not p.eof
	'response.Write(p("id")&"<br />")
'	set pd = destino.execute("select Foto from pacientes where id="&p("id")&" and Foto like ''")
'	if not pd.eof then
'		destino.execute("update pacientes set Foto='dermagrupo"&p("id")&".jpg' where id="&p("id"))
'	end if
'p.movenext
'wend
'p.close
'set p = nothing

ProfissionalID = 1'@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'TEM QUE LIMPAR O P P P P P P P P P P P P P P ANTES NO COMPROMISSOSSSSSSSS LINK!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'38000 consultorio
'63000 fisioterapia

'limitar = " order by Comp_ln_Counter desc limit 100"
'set a = origem.execute("select c.*, p.* from compromissos as c left join pacientes as p on c.Comp_tx_Descricao=p.Paci_tx_NomePaciente where not isnull(p.Paci_ln_Counter)")
'set a = origem.execute("select c.*, p.Paci_tx_NomePaciente, p.Paci_ln_Counter, clas.*, concat( clas.Clas_tx_Descricao, '\n', replace(c.Comp_tx_Descricao, p.Paci_tx_NomePaciente, ''), '\n', c.Comp_me_Notas ) as Descricao from compromissos as c join pacientes as p on c.Comp_tx_Link=p.Paci_ln_Counter join classificacoes as clas on c.Comp_ln_Classificacao=clas.Clas_ln_Counter where c.Comp_tx_Link<>''"&limitar)
'while not a.eof
'	destino.execute("INSERT INTO `agendamentos` (`id`, `PacienteID`, `ProfissionalID`, `Data`, `Hora`, `TipoCompromissoID`, `StaID`, `ValorPlano`, `rdValorPlano`, `Notas`, `Falado`, `FormaPagto`, `LocalID`, `Tempo`, `HoraFinal`, `SubtipoProcedimentoID`) "&_
'''''''''''''''	"VALUES ("&a("Comp_ln_Counter")&", "&a("Paci_ln_Counter")&", "&ProfissionalID&", '"&year(a("Comp_dt_DataHora"))&"-"&month(a("Comp_dt_DataHora"))&"-"&day(a("Comp_dt_DataHora"))&"', '"&hour(a("Comp_dt_DataHora"))&":"&minute(a("Comp_dt_DataHora"))&":"&second(a("Comp_dt_DataHora"))&"', "&a("Comp_ln_Classificacao")+Acrescenta&", "&StaID(a("Comp_ln_Status"))&", 0, 'V', '"&rep(a("Descricao"))&"', NULL, 0, 0, '30', '"&dateadd("n", 30, hour(a("Comp_dt_DataHora"))&":"&minute(a("Comp_dt_DataHora")))&"', 0)")
'	destino.execute("INSERT INTO `agendamentos` (`id`, `PacienteID`, `ProfissionalID`, `Data`, `Hora`, `TipoCompromissoID`, `StaID`, `ValorPlano`, `rdValorPlano`, `Notas`, `Falado`, `FormaPagto`, `LocalID`, `Tempo`, `HoraFinal`, `SubtipoProcedimentoID`) VALUES ("&a("Comp_ln_Counter")+10000&", "&a("Comp_tx_Link")&", "&ProfissionalID&", '"&year(a("Comp_dt_DataHora"))&"-"&month(a("Comp_dt_DataHora"))&"-"&day(a("Comp_dt_DataHora"))&"', '"&hour(a("Comp_dt_DataHora"))&":"&minute(a("Comp_dt_DataHora"))&":"&second(a("Comp_dt_DataHora"))&"', "&a("Comp_ln_Classificacao")+Acrescenta&", "&StaID(a("Comp_ln_Status"))&", "&treatvalzero(a("Comp_cu_Valor"))&", 'V', '"&a("Descricao")&"', NULL, 0, 0, '30', '"&dateadd("n", 30, hour(a("Comp_dt_DataHora"))&":"&minute(a("Comp_dt_DataHora")))&"', 0)")
'a.movenext
'wend
'a.close
'set a=nothing


'convenios do paciente


'set conv = origem.execute("select * from convenios")
'while not conv.eof
'	destino.execute("insert into convenios (id, NomeConvenio, sysActive, sysUser) values ('"&rep(conv("Conv_ln_Counter"))&"', '"&rep(conv("Conv_tx_NomeConvenio"))&"', 1, 0)")
'conv.movenext
'wend
'conv.close
'set conv=nothing

'set convpac = origem.execute("select * from pacientes where not isnull(Paci_ln_ConvenioPaciente) and Paci_ln_ConvenioPaciente>1")
'while not convpac.eof
'	destino.execute("insert into pacientesconvenios (ConvenioID, Matricula, PacienteID, sysActive, sysUser) values ("&convpac("Paci_ln_ConvenioPaciente")&", '"&rep(convpac("Paci_tx_MatriculaPaciente"))&"', "&convpac("Paci_ln_Counter")&", 1, 0)")
'convpac.movenext
'wend
'convpac.close
'set convpac=nothing

'csv procedimentos renata roxo
'set p = origem.execute("select * from procedimentosexcel")
'while not p.eof
'	set vca = destino.execute("select * from procedimentos where NomeProcedimento like '"&p("Nome")&"'")
'	if vca.eof then
'		destino.execute("insert into procedimentos (NomeProcedimento, TempoProcedimento, Valor, TipoProcedimentoID, sysActive, sysUser) values ('"&p("Nome")&"', '"&p("Tempo")&"', "&treatvalzero(p("Valor"))&", 4, 1, 0)")
'	end if
'p.movenext
'wend
'p.close
'set p=nothing

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
'	set vca = destino.execute("select * from buiforms order by id desc LIMIT 1")
'	FormID = vca("id")
'	destino.execute("insert into buicamposforms (TipoCampoID, NomeCampo, RotuloCampo, FormID, Ordem, ValorPadrao, Tamanho, Largura, MaxCarac, Checado, Obrigatorio, Texto, pTop, pLeft, Colunas, Linhas) values "&_
'		"(8, 'anamnese', 'Anamnese', "&FormID&", 0, '', 1, '', '20', 'S', '', '', 4, 3, 0, 0), "&_
'		"(1, 'diagnóstico_1', 'Diagnóstico 1', "&FormID&", 0, '', 2, '20', '70', '', '', '', 485, 1, 0, 0), "&_
'		"(1, 'diagnóstico_2', 'Diagnóstico 2', "&FormID&", 0, '', 2, '20', '70', '', '', '', 485, 382, 0, 0)")
'end if
'FormID = vca("id")
'set pult = destino.execute("select * from buicamposforms where FormID="&FormID&" order by id desc LIMIT 1")
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
'	set vca = destino.execute("select * from buiforms order by id desc LIMIT 1")
'	FormID = vca("id")
'	destino.execute("insert into buicamposforms (TipoCampoID, NomeCampo, RotuloCampo, FormID, Ordem, ValorPadrao, Tamanho, Largura, MaxCarac, Checado, Obrigatorio, Texto, pTop, pLeft, Colunas, Linhas) values "&_
'		"(8, 'texto_da_consulta', 'Texto da Consulta', "&FormID&", 0, '', 1, '', '20', 'S', '', '', 4, 3, 0, 0)")
'end if
'FormID = vca("id")
'set pult = destino.execute("select * from buicamposforms where FormID="&FormID&" order by id desc LIMIT 1")
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
'IniciarEm = 519
'while not t.eof
'	id = t("Text_ln_Counter")+IniciarEm
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