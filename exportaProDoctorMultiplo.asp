<!--#include file="connect.asp"-->
<!--#include file="limpaMemo.asp"-->
<%
idInicial = request.QueryString("idInicial")
if idInicial="" then
	idInicial=0
end if
idInicial = ccur(idInicial)
idFinal = idInicial+1000

'on error resume next

response.Charset="utf-8"

'server.ScriptTimeout = 100000

dbOrigem = request.QueryString("Origem")

Set origem = Server.CreateObject("ADODB.Connection")
origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&dbOrigem&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
'origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellos;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"

Set destino = Server.CreateObject("ADODB.Connection")
destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&request.QueryString("Destino")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
'destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellosimportado;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"


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

Private Function removeCaracteres(byVal string, byVal remove)
	remove = "qwertyuiopasdfghjklçzxcvbnmQWERTYUIOPASDFGHJKLÇZXCVBNMáéíóúàèìòùÁÉÍÓÚÀÈÌÒÙÃÕÂÊÎÔÛãõâêîôû´`[~^],<.>;:/?''!@#$%¨&*()_+=-\|Ã© " 'fixando a sanitização
	Dim i, j, tmp, strOutput
	strOutput = ""
	for j = 1 to len(string)
		tmp = Mid(string, j, 1)
		for i = 1 to len(remove)
			tmp = replace( tmp, Mid(remove, i, 1), "")
			if len(tmp) = 0 then exit for
		next
		strOutput = strOutput & tmp
	next
	RmChr = strOutput
End Function

Function SoNumeros(Valor)
	Temp = ""
	if not isnull(Valor) then
		For I = 1 To Len(Valor)
			  If IsNumeric(Mid(Valor, I, 1)) Then
				 Temp = Temp & Mid(Valor, I, 1)
			  End If
		Next
	end if
	SoNumeros= Temp
End Function

select case dbOrigem
	case "dermobarra_barra"
		coluna = "idBarra"
	case "dermobarra_bangu"
		coluna = "idBangu"
	case "dermobarra_recreio"
		coluna = "idRecreio"
	case "dermobarra_leblon"
		coluna = "idLeblon"
end select

function novoID(idAntigo, tabela)
	set reg = destino.execute("select id from "&tabela&" where "&coluna&"="&idAntigo&" limit 1")
	if reg.eof then
		novoID = "NULL"
	else
		novoID = reg("id")
	end if
end function

function novoIDHist(idAntigo, tabela, coluna)
	set reg = destino.execute("select id from "&tabela&" where "&coluna&"="&idAntigo&" limit 1")
	if reg.eof then
		novoIDHist = "0"
	else
		novoIDHist = reg("id")
	end if
end function

function novoIDbarrinhas(idAntigo, tabela)
	set reg = destino.execute("select id from "&tabela&" where "&coluna&" like '%|"&idAntigo&"|%' limit 1")
	if reg.eof then
		novoIDbarrinhas = "NULL"
	else
		novoIDbarrinhas = reg("id")
	end if
end function

'--> PACIENTES

'set p = origem.execute("select p.*, c.nome as cidade, uf.nome as estado, prof.nome as nomeprofissao from t_pacientes p "&_
'"left join ibge_cidades c on c.codigo=p.r_cidade "&_ 
'"left join ibge_estados uf on uf.codigo=p.r_uf "&_ 
'"left join t_profissoes prof on prof.codigo=p.profissao "&_
'" where p.codigo>="&idInicial&" and p.codigo<"&idFinal&" "&_ 
'"order by p.codigo")
'while not p.eof
'	achou = "S"
'	observacoes = p("observacoes")
'	pendencias = p("pendencias")
'	InstCPF = ""
'	if not isnull(p("cpf")) then
'		if len(SoNumeros(p("cpf")))=11 then
'			InstCPF = "cpf='"&SoNumeros(p("cpf"))&"' or "
'		end if
'	end if
'	set vcaInserido = destino.execute("select id, idBarra, idRecreio, idBangu, idLeblon from pacientes where nascimento="&mydatenull(p("datanascimento"))&" and ("&InstCPF&" NomePaciente like '"&rep(p("nome"))&"')")
'	if vcaInserido.eof then
'		destino.execute("INSERT INTO `pacientes` (`NomePaciente`, `Nascimento`, `Sexo`, `Cep`, `Cidade`, `Estado`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `EstadoCivil`, `CorPele`, `GrauInstrucao`, `Profissao`, `Naturalidade`, `Documento`, `Origem`, `Email1`, `CPF`, `Tabela`, `Peso`, `Altura`, `IMC`, `Observacoes`, `Pendencias`, `Foto`, `Religiao`, `Tel1`, `Tel2`, `Cel1`, `Cel2`, `Email2`, `Pais`, `IndicadoPor`, `sysActive`, `sysDate`, `sysUser`, "&coluna&") VALUES ('"&rep(p("nome"))&"', "&myDateNULL(p("datanascimento"))&", "&sexo(p("sexo"))&", '"&p("r_cep")&"', '"&rep(p("cidade"))&"', '"&rep(p("estado"))&"', '"&rep(p("r_logradouro"))&"', '"&p("r_numero")&"', '"&rep(p("r_complemento"))&"', '"&rep(p("r_bairro"))&"', "&estadocivil(p("estadocivil"))&", "&corpele(p("cor"))&", "&grauinstrucao(p("escolaridade"))&", '"&rep(p("nomeprofissao"))&"', '"&rep(p("naturalidade"))&"', '"&rep(p("identidade"))&"', NULL, '"&rep(p("correioeletronico"))&"', '"&SoNumeros(p("cpf"))&"', NULL, NULL, NULL, NULL, '"&rep(observacoes)&"', '"&rep(pendencias)&"', NULL, NULL, '"&rep(p("telefone_1"))&"', '"&rep(p("telefone_2"))&"', '"&rep(p("telefone_3"))&"', '"&rep(p("telefone_4"))&"', '', 1, '"&rep(p("indicadopor"))&"', 1, "&mydatetime(p("datacadastro"))&", 1, "&p("codigo")&")")
'	else
'		if isnull(vcaInserido(""&coluna&"")) then
'			destino.execute("update pacientes set "&coluna&"="&p("codigo")&" where id="&vcaInserido("id"))
'		end if
'	end if
'p.movenext
'wend
'p.close
'set p=nothing

'<- PACIENTES

'set conv = origem.execute("select * from t_convenios")
'while not conv.eof
'	destino.execute("insert into convenios (id, NomeConvenio, RetornoConsulta, sysActive, sysUser) values ('"&rep(conv("codigo"))&"', '"&rep(conv("nome"))&"', '"&rep(conv("retornoconsulta"))&"', 1, 0)")
'conv.movenext
'wend
'conv.close
'set conv=nothing

'-> CONVENIOS DOS PACIENTES

'set convpac = origem.execute("select codigo, convenio_1, plano_1 empresa, numeromatricula_1, validade_1, titular_1 from t_pacientes where not isnull(convenio_1)")
'while not convpac.eof
'	destino.execute("insert into pacientesconvenios (ConvenioID, Matricula, PacienteID, Validade, Titular, sysActive, sysUser, Empresa) values ("&novoIDbarrinhas(convpac("convenio_1"), "convenios")&", '"&rep(convpac("numeromatricula_1"))&"', "&novoID(convpac("codigo"), "pacientes")&", "&mydatenull(convpac("validade_1"))&", '"&rep(convpac("titular_1"))&"', 1, 0, '"&rep(convpac("empresa"))&"')")
'convpac.movenext
'wend
'convpac.close
'set convpac=nothing

'<- CONVENIOS DOS PACIENTES

'faz na mao copiando a tabela do banco de dados
'set hist = origem.execute("select h.id, h.texto_limpo, h.data, h.paciente from t_pacientesevolucoes h")
'while not hist.eof
'	db_execute("insert into buiformspreenchidos (ModeloID, PacienteID, DataHora, sysUser) values(2, "&hist("PacienteID")&", "&mydatenull(hist("DATA"))&", 1)")
'	db_execute("insert into `_2` (PacienteID, DataHora, sysUser, `24`, `25`, `26`, `27`) values ("&hist("PacienteID")&", "&mydatenull(hist("DATA"))&", 1, "&mydatenull(hist("NASC"))&", '"&hist("NomeMedico")&"', '"&hist("NomeLocal")&"', '"&hist("HIST")&"')")
'hist.movenext
'wend
'hist.close
'set hist = nothing

'-> EVOLUCOES DOS PACIENTES
'	1. ANTES DE TUDO, CRIAR UMA CÓPIA DA TABELA DE EVOLUCOES EM CADA BANCO COMO BACKUP
'	2. MUDAR NOS BANCOS O ID PARA ID_LOCAL
'	3. MUDAR NOS BANCOS O PROFISSIONAL PARA PROFISSIONAL_LOCAL
'	4. MUDAR NOS BANCOS O PACIENTE PARA PACIENTE_LOCAL
'	CRIAR UMA TABELA NOS MESMOS MOLDES DA T_PACIENTESEVOLUCOES NO BANCO CLINIC, COM OS IDLOCAL, PROFISSIONALLOCAL, PACIENTELOCAL, E EXPORTAR DE TODAS AS DOS BANCOS PRA ELA
'	'RODAR ROTINA COM REFRESH DE UM EM UM QUE ATUALIZA O ID DE CADA UM (JÁ CRIEI FUNCAO PRA ISSO)
'	4. RODAR O ALTER TABLE QUE COLOCA A TABELA T_PACIENTESEVOLUCOES IGUAL A DO FORM QUE RECEBERÁ NA LICENCA DO CLINIC (_2)
'	5. DUPLICAR A TABELA _2 PARA buiformspreenchidos_TEMP E DEPOIS jogar insert da temp para a definitiva, mesclando os ids
'	6. RODAR DE 1 EM 1 SANITIZANDO O QUE CONTIVER rtf1
'novoIDHist(idAntigo, tabela, coluna)
'set reg = destino.execute("select * from t_pacientesevolucoes where isnull(paciente) limit 1")
if not isnull(reg("paciente_barra")) then
	unid = "barra"
elseif not isnull(reg("paciente_bangu")) then
	unid = "bangu"
elseif not isnull(reg("paciente_leblon")) then
	unid = "leblon"
elseif not isnull(reg("paciente_barra")) then
	unid = "recreio"
end if

'destino.execute("update t_pacientesevolucoes set paciente="&novoIDHist(reg("paciente_"&unid), "pacientes", "id"&unid)&" where id="&reg("id"))



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
'set a = origem.execute("select * from t_pacientesevolucoes")
'while not a.eof
'	Data = cdate( day(a("Anam_dt_DataAnamnese"))&"/"&month(a("Anam_dt_DataAnamnese"))&"/"&year(a("Anam_dt_DataAnamnese")) )
'	destino.execute("insert into buiformspreenchidos (id, ModeloID, PacienteID, DataHora, sysUser) values ("&a("id")&", 1, "&a("paciente")&", "&mydatenull(a("data"))&", "&a("usuario")&")")
'	destino.execute("insert into `_1` (id, PacienteID, DataHora, sysUser, `17`) values ("&a("id")&", "&a("paciente")&", "&mydatenull(a("Data"))&", "&a("usuario")&", '"&a("textolimpo")&"')")
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


if achou="S" then
%>
<script>
location.href='exportaprodoctorMultiplo.asp?Origem=<%=request.QueryString("Origem")%>&Destino=<%=request.QueryString("Destino")%>&idInicial=<%=idFinal%>';
</script>
<%
end if
%>