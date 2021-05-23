<!--#include file="connect.asp"-->
<%
'587 para clinic676 (castro multiclinicas)
'on error resume next

'server.ScriptTimeout = 100000

dbOrigem = "418"
dbDestino = "clinic1635"

Set origem = Server.CreateObject("ADODB.Connection")
origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&dbOrigem&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
'origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellos;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"

Set destino = Server.CreateObject("ADODB.Connection")
destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&dbDestino&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
'destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellosimportado;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"


'set p = origem.execute("select * from sch_contact")
'while not p.eof
'	response.Write(limpaMemo(p("Fld3"))&"<hr />")
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
'set p = origem.execute("select * from paciente order by id")
'while not p.eof
'	sql = "INSERT INTO `pacientes` (`id`, `NomePaciente`, `Nascimento`, `Sexo`, `Cep`, `Cidade`, `Estado`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `EstadoCivil`, `CorPele`, `GrauInstrucao`, `Profissao`, `Naturalidade`, `Tel1`, `Documento`, `Origem`, `Email1`, `CPF`, `Tabela`, `Peso`, `Altura`, `IMC`, `Observacoes`, `Pendencias`, `Foto`, `Religiao`, `Tel2`, `Cel1`, `Cel2`, `Email2`, `Pais`, `IndicadoPor`, `sysActive`, `sysUser`) VALUES ("&p("id")&", '"&rep(p("Nome"))&"', "&nascimento(p("Nascimento"))&", '"&sexo(p("Sexo"))&"', '"&p("Cep")&"', '"&p("Cidade")&"', '"&p("Estado")&"', '"&p("Endereco")&"', '"&p("Numero")&"', '"&p("Complemento")&"', '"&p("Bairro")&"', "&treatvalzero(p("EstadoCivil"))&", "&treatvalzero(p("CorPele"))&", "&treatvalzero(p("Escolaridade"))&", '"&p("Profissao")&"', '"&p("Naturalidade")&"', '"&phone(p("DDDRes"), p("TelRes1"))&"', '"&p("Documento")&"', '"&p("Origem")&"', '"&p("Email1")&"', '"&p("CPF")&"', 0, "&treatvalzero(p("Peso"))&", "&treatvalzero(p("Altura"))&", "&treatvalzero(p("IMC"))&", '"&p("Obs")&"', '"&p("Pendencias")&"', '"&p("Imagem")&"', '"&p("Religiao")&"', '"&phone(p("DDDRes"), p("TelRes2"))&"', '"&phone(p("DDDCel"), p("TelCel1"))&"', '"&phone(p("DDDCel"), p("TelCel2"))&"', '"&p("Email2")&"', NULL, '"&p("IndicadoPor")&"', 1, 1)"
'	destino.execute(sql)
'p.movenext
'wend
'p.close
'set p=nothing

'CONVENIOS
'destino.execute("delete from convenios")
'set conv = origem.execute("select * from sconvenios where not isnull(razaoSocial)")
'while not conv.eof
'	destino.execute("insert into convenios (id, NomeConvenio, RazaoSocial, TelAut, Contato, RegistroANS, CNPJ, Endereco, Numero, Complemento, Bairro, Cidade, Estado, Cep, Telefone, Fax, Email, NumeroContrato, Obs, ContaRecebimento, RetornoConsulta, FaturaAtual, sysActive, sysUser) values ("&conv("id")&", '"&rep(conv("PlanoSaude"))&"', '"&rep(conv("razaoSocial"))&"', '"&replace(replace(conv("TelAut")," ",""),"-","")&"', '"&conv("Contato")&"', '"&conv("registroANS")&"', '"&conv("cnpj")&"', '"&rep(conv("logradouro"))&"', '"&conv("numero")&"', '"&conv("complemento")&"', '"&rep(conv("bairro"))&"', '"&rep(conv("cidade"))&"', '"&conv("codigoUF")&"', '"&conv("Cep")&"', '"&conv("telefone")&"', '"&conv("fax")&"', '', '"&conv("NoContrato")&"', '"&conv("Obs")&"', 0, '"&conv("RetornoConsulta")&"', '"&conv("FaturaAtual")&"', 1, 1)")
'conv.movenext
'wend
'conv.close
'set conv=nothing

'CONVENIOS DO PACIENTE
'on error resume next
'destino.execute("delete from pacientesconvenios")
'set convpac = origem.execute("select * from paciente where not isnull(Convenio1) and Convenio1<>0")
'while not convpac.eof
'	destino.execute("insert into pacientesconvenios (ConvenioID, PlanoID, Matricula, Validade, Titular, PacienteID, sysActive, sysUser) values ("&convpac("Convenio1")&", 0, '"&rep(convpac("ConMatCar1"))&"', "&nascimento(rep('convpac("ConValidade1")))&", '"&rep(convpac("ConTitular1"))&"', "&convpac("id")&", 1, 0)")
'convpac.movenext
'wend
'convpac.close
'set convpac=nothing




'PROCEDIMENTOS
destino.execute("delete from procedimentos")
set proc = origem.execute("select * from sprocedimentosexecutadosresumido where Ativo='S'")
while not proc.eof
	sql = "insert into procedimentos (id, NomeProcedimento, TipoProcedimentoID, Valor, Obs, ObrigarTempo, OpcoesAgenda, TempoProcedimento, MaximoAgendamentos, sysActive, sysUser) values ("&proc("id")&", '"&rep(proc("Nome"))&"', "&treatvalzero(proc("Tipo"))&", "&treatvalzero(proc("Valor"))&", '"&proc("Obs")&"', '"&proc("ObrigarTempo")&"', "&treatvalzero(proc("OpcoesAgenda"))&", '"&proc("Tempo")&"', '"&proc("MaximoAgendamentos")&"', 1, 1)"
	response.Write(sql)
	destino.execute(sql)
proc.movenext
wend
proc.close
set proc=nothing

'AGENDAMENTOS
'destino.execute("delete from agendamentos")
'set a = origem.execute("select * from consultas")
'while not a.eof
'	destino.execute("INSERT INTO `agendamentos` (`id`, `PacienteID`, `ProfissionalID`, `Data`, `Hora`, `TipoCompromissoID`, `StaID`, `ValorPlano`, `rdValorPlano`, `Notas`, `Falado`, `FormaPagto`, `LocalID`, `Tempo`, `HoraFinal`, `SubtipoProcedimentoID`) VALUES ('"&a("id")&"', '"&a("PacienteID")&"', '"&a("DrId")&"', "&nascimento(a("Data"))&", "&mytime(a("Hora"))&", '"&a("TipoCompromisso")&"', '"&a("StaConsulta")&"', "&treatvalzero(a("ValorPlano"))&", '"&a("rdValorPlano")&"', '"&a("Notas")&"', '"&a("Falado")&"', "&treatvalzero(a("FormaPagto"))&", "&treatvalzero(a("LocalID"))&", '"&a("Tempo")&"', "&mytime(a("HoraFinal"))&", "&treatvalzero(a("SubtipoProcedimentoID"))&")"&chr(13))
'a.movenext
'wend
'a.close
'set a=nothing


'===> ATÉ AQUI ESTÁ OK!

'TabelaImportadas = 3
'ColunaImportadas = 26
'Adicionar = 100
'set a = origem.execute("select * from pacienteanamneses")
'while not a.eof
'	Data = a("Data")
'	Data = left(Data, 4)&"-"&mid(Data, 5, 2)&"-"&right(Data,2)&" 00:00:00"
'	Anamnese = a("Anamnese")
'	destino.execute("insert into `_"&TabelaImportadas&"` (id, PacienteID, DataHora, sysUser, `"&ColunaImportadas&"`) values ('"&a("id")+Adicionar&"', '"&a("PacienteID")&"', '"&Data&"', 0, '"&rep(Anamnese)&"')")
'	destino.execute("insert into buiformspreenchidos (id, ModeloID, PacienteID, DataHora, sysUser) values ('"&a("id")+Adicionar&"', '"&TabelaImportadas&"', '"&a("PacienteID")&"', '"&Data&"', 0)")
'a.movenext
'wend
'a.close
'set a=nothing
%>