<!--#include file="connect.asp"-->
<!--#include file="limpaMemo.asp"-->
<%
on error resume next

server.ScriptTimeout = 100000

Set origem = Server.CreateObject("ADODB.Connection")
'origem.Open "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=recreio_contatos;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
origem.Open "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=uroclin;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"

Set destino = Server.CreateObject("ADODB.Connection")
'destino.Open "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=clinic1739;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
destino.Open "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=clinic1739;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"


'set p = origem.execute("select * from sch_contact")
'while not p.eof
'	response.Write(limpaMemo(p("Fld3"))&"<hr />")
'p.movenext
'wend
'p.close
'set p=nothing
function tratamento(val)
	if val="Dr." then
		tratamento = 2
	elseif val="Dra." then
		tratamento = 3
	else
		tratamento = 0
	end if
end function

function sexo(val)
	if val=1 then
		sexo = 2
	elseif val=0 then
		sexo = 1
	else
		sexo="NULL"
	end if
end function

function estadocivil(val)
	select case val
		case 1, 4
			estadocivil = 1
		case 0
			estadocivil = 2
		case 2
			estadocivil = 3
		case 3
			estadocivil = 4
		case else
			estadocivil = 0
	end select
end function

function corpele(val)
	select case val
		case 0, 3
			corpele = 1
		case 1
			corpele = 2
		case 2
			corpele = 3
		case else
			corpele = 0
	end select
end function

function grauinstrucao(val)
	select case val
		case 0'sem instrucao
			grauinstrucao = 0
		case 1'prim grau
			grauinstrucao = 2
		case 2'seg grau
			grauinstrucao = 3
		case 3'superior
			grauinstrucao = 5
		case 4'pos
			grauinstrucao = 5
		case 5'mest
			grauinstrucao = 7
		case 6'dout
			grauinstrucao = 8
		case 7'pos dout
			grauinstrucao = 9
		case else
			grauinstrucao = 0
	end select
end function


'set p = origem.execute("select p.*, c.nome as cidade, uf.nome as estado, prof.nome as nomeprofissao from t_pacientes p "&_
'"left join ibge_cidades c on c.codigo=p.r_cidade "&_ 
'"left join ibge_estados uf on uf.codigo=p.r_uf "&_ 
'"left join t_profissoes prof on prof.codigo=p.profissao "&_
'"order by p.codigo")
'while not p.eof
'	observacoes = p("observacoes")
'	pendencias = p("pendencias")
'	destino.execute("INSERT INTO `pacientes` (`id`, `NomePaciente`, `Nascimento`, `Sexo`, `Cep`, `Cidade`, `Estado`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `EstadoCivil`, `CorPele`, `GrauInstrucao`, `Profissao`, `Naturalidade`, `Documento`, `Origem`, `Email1`, `CPF`, `Tabela`, `Peso`, `Altura`, `IMC`, `Observacoes`, `Pendencias`, `Foto`, `Religiao`, `Tel1`, `Tel2`, `Cel1`, `Cel2`, `Email2`, `Pais`, `IndicadoPor`, `sysActive`, `sysDate`, `sysUser`, ConvenioID1, Matricula1, Validade1, Titular1, ConvenioID2, Matricula2, Validade2, Titular2) VALUES ("&p("codigo")&", '"&rep(p("nome"))&"', "&myDateNULL(p("datanascimento"))&", "&sexo(p("sexo"))&", '"&p("r_cep")&"', '"&rep(p("cidade"))&"', '"&rep(p("estado"))&"', '"&rep(p("r_logradouro"))&"', '"&p("r_numero")&"', '"&rep(p("r_complemento"))&"', '"&rep(p("r_bairro"))&"', "&estadocivil(p("estadocivil"))&", "&corpele(p("cor"))&", "&grauinstrucao(p("escolaridade"))&", '"&rep(p("nomeprofissao"))&"', '"&rep(p("naturalidade"))&"', '"&rep(p("identidade"))&"', NULL, '"&rep(p("correioeletronico"))&"', '"&rep(p("cpf"))&"', NULL, NULL, NULL, NULL, '"&rep(observacoes)&"', '"&rep(pendencias)&"', NULL, NULL, '"&rep(p("telefone_1"))&"', '"&rep(p("telefone_2"))&"', '"&rep(p("telefone_3"))&"', '"&rep(p("telefone_4"))&"', '', 1, '"&rep(p("indicadopor"))&"', 1, "&mydatetime(p("datacadastro"))&", 1, "&treatvalnull(p("CONVENIO_1"))&", '"&rep(p("NUMEROMATRICULA_1"))&"', "&mydatenull(p("VALIDADE_1"))&", '"&rep(p("TITULAR_1"))&"', "&treatvalnull(p("CONVENIO_2"))&", '"&rep(p("NUMEROMATRICULA_2"))&"', "&mydatenull(p("VALIDADE_2"))&", '"&rep(p("TITULAR_2"))&"')")
'p.movenext
'wend
'p.close
'set p=nothing

Acrescenta = 0'pois no hidoctor cada agenda tem seus compromissos
'set proc = origem.execute("select * from t_conveniosprocedimentos group by codigo")
'while not proc.eof
'	destino.execute("insert into procedimentos (NomeProcedimento, sysActive, sysUser) values ('"&rep(proc("nome"))&"', 1, 1)")
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

'PROFISSIONAIS
'set p = origem.execute("select * from t_usuarios where inativo=0")
'while not p.eof
'	destino.execute("insert into profissionais (Ativo, NomeProfissional, TratamentoID, EspecialidadeID, CPF, Conselho, DocumentoConselho, UFConselho, sysActive, sysUser) values ('on', '"&rep(p("nome"))&"', '"&tratamento(p("titulo"))&"', 98, '"&rep(p("cnpjcpf"))&"', '1', '"&rep(p("conselhonumero"))&"', 'RJ', 1, 1)")
'p.movenext
'wend
'p.close
'set p = nothing


ProfissionalID = 1'@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

'TEM QUE LIMPAR O P P P P P P P P P P P P P P ANTES NO COMPROMISSOSSSSSSSS LINK!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'38000 consultorio
'63000 fisioterapia

'limitar = " order by Comp_ln_Counter desc limit 100"
set a = origem.execute("select * from t_agendaconsultas")
while not a.eof
	if a("RETORNO")=1 then
		TipoCompromissoID = 2
	else
		TipoCompromissoID = 1
	end if
	if a("ATENDIDO")=1 then
		StaID = 3
	elseif a("COMPARECEU")=0 and cdate(a("DATA"))<date() then
		StaID = 6
	else
		StaID = 1
	end if
	if not isnull(a("CONVENIO")) then
		rdValorPlano = "P"
		ValorPlano = a("CONVENIO")
	else
		rdValorPlano = "V"
		ValorPlano = 0
	end if
	notas = a("ANOTACOES")
	destino.execute("INSERT INTO `agendamentos` (`PacienteID`, `ProfissionalID`, `Data`, `Hora`, `TipoCompromissoID`, `StaID`, `ValorPlano`, `rdValorPlano`, `Notas`, `Falado`, `FormaPagto`, `LocalID`, `Tempo`, `HoraFinal`, NomePaciente, Tel1) "&_
	"VALUES ("&treatvalnull(a("NUMEROPRONTUARIO"))&", "&a("USUARIO")&", "&mydateNULL(a("DATA"))&", "&mytime(a("HORA"))&", "&TipoCompromissoID&", "&StaID&", "&ValorPlano&", '"&rdValorPlano&"', '"&rep(notas)&"', NULL, 0, 0, 0, "&mytime(a("HORA"))&", '"&rep(a("NOMEPACIENTE"))&"', '"&a("TELEFONE")&"')")
a.movenext
wend
a.close
set a=nothing


'convenios do paciente


'set conv = origem.execute("select * from t_convenios")
'while not conv.eof
'	destino.execute("insert into convenios (id, NomeConvenio, RetornoConsulta, sysActive, sysUser) values ('"&rep(conv("codigo"))&"', '"&rep(conv("nome"))&"', '"&rep(conv("retornoconsulta"))&"', 1, 0)")
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
'set a = origem.execute("select * from t_pacientesevolucoes")
'while not a.eof
'	texto = a("texto")
'	texto = replace(replace(texto, "'", "''"), "\", "\\")
'	Data = cdate( day(a("Anam_dt_DataAnamnese"))&"/"&month(a("Anam_dt_DataAnamnese"))&"/"&year(a("Anam_dt_DataAnamnese")) )
'	destino.execute("insert into buiformspreenchidos (id, ModeloID, PacienteID, DataHora, sysUser) values ("&a("id")&", 1, "&a("paciente")&", "&mydatenull(a("data"))&", "&a("usuario")&")")
'	response.Write("insert into `_"&FormID&"` (id, PacienteID, DataHora, sysUser, `50`) values ("&a("id")&", "&a("paciente")&", "&mydatenull(a("Data"))&", "&a("usuario")&", '"&a("textolimpo")&"')")
'	destino.execute("insert into `_"&FormID&"` (id, PacienteID, DataHora, sysUser, `50`) values ("&a("id")&", "&a("paciente")&", "&mydatenull(a("Data"))&", "&a("usuario")&", '"&texto&"')")
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
UnidadeID = 1 'Barra=5, Bangu=3, Recreio=1
'set con = origem.execute("select a.*, c.nome as cidade, uf.nome as estado from t_agendatelefonica a "&_ 
'"left join bangu_1508.ibge_cidades c on c.codigo=a.cidade "&_ 
'"left join bangu_1508.ibge_estados uf on uf.codigo=a.uf")
'while not con.eof
'	IniciarEm = 100
'	id = con("id")+IniciarEm
'	NomeContato = rep(con("Tele_tx_Nome"))
'	Observacoes = rep(con("Tele_tx_Telefones"))&chr(10)&replace(con("Tele_me_Notas"), "'", "''")
'	Email1 = con("Tele_tx_Email")
'	Obs = con("anotacoes")
'	Obs = rep(Obs)
'	destino.execute("insert into contatos (NomeContato, Sexo, Cep, Cidade, Estado, Endereco, Numero, Complemento, Bairro, Tel1, Email1, Observacoes, Tel2, Cel1, Cel2, Email2, sysActive, sysUser, UnidadeID) values ('"&rep(con("nome"))&"', 0, '"&rep(con("cep"))&"', '"&rep(con("cidade"))&"', '"&rep(con("estado"))&"', '"&rep(con("logradouro"))&"', '"&rep(con("numero"))&"', '"&rep(con("complemento"))&"', '"&rep(con("bairro"))&"', '"&rep(con("telefone_1"))&"', '"&rep(con("correioeletronico"))&"', '"&Obs&"', '"&rep(con("telefone_2"))&"', '"&rep(con("telefone_3"))&"', '"&rep(con("telefone_4"))&"', '"&rep(con("paginaweb"))&"', 1, 0, "&UnidadeID&")")
'con.movenext
'wend
'con.close
'set con=nothing
'<------ Contatos
%>