<!--#include file="connect.asp"-->
<%
'on error resume next

server.ScriptTimeout = 100000

function mes(nomemes)
	select case nomemes
		case "janeiro"
			mes =1
		case "fevereiro"
			mes = 2
		case "março"
			mes = 3
		case "abril"
			mes = 4
		case "maio"
			mes = 5
		case "junho"
			mes = 6
		case "julho"
			mes = 7
		case "agosto"
			mes = 8
		case "setembro"
			mes = 9
		case "outubro"
			mes = 10
		case "novembro"
			mes = 11
		case "dezembro"
			mes = 12
	end select
end function

Set origem = Server.CreateObject("ADODB.Connection")
origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=heitordarros;uid=root;pwd=pipoca453;"

Set destino = Server.CreateObject("ADODB.Connection")
destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=clinic303;uid=root;pwd=pipoca453;"
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

'set p = origem.execute("select * from pacientes order by Codigo")
'while not p.eof
'	destino.execute("INSERT INTO `pacientes` (`id`, `NomePaciente`, `Nascimento`, `Sexo`, `Cep`, `Cidade`, `Estado`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `EstadoCivil`, `CorPele`, `GrauInstrucao`, `Profissao`, `Naturalidade`, `Tel1`, `Documento`, `Origem`, `Email1`, `CPF`, `Tabela`, `Peso`, `Altura`, `IMC`, `Observacoes`, `Pendencias`, `Foto`, `Religiao`, `Tel2`, `Cel1`, `Cel2`, `Email2`, `Pais`, `IndicadoPor`, `sysActive`, `sysUser`) VALUES ("&p("Codigo")&", '"&rep(p("Nome"))&"', "&myDateNULL( p("Datanasc")&"/"&mes(p("Mes"))&"/"&p("Ano") )&", "&sexo(p("Sexo"))&", '"&left( replace(p("Cep2"),".",""), 9)&"', '"&rep(p("Cidade"))&"', '"&rep(p("Estado"))&"', '"&rep(p("Endereco"))&"', '', '', '"&rep(p("Bairro"))&"', "&estadocivil(p("Est_civ"))&", 0, 0, '"&rep(p("Prof"))&"', '', '', '', '', '', '', NULL, NULL, NULL, NULL, '"&p("Diag2")&"', '"&rep(p("Telefone2"))&"', '', '', '', '', '', '', NULL, '', 1, 1)")

'p.movenext
'wend
'p.close
'set p=nothing

'set proc = origem.execute("select * from classificacoes")
'while not proc.eof
'	destino.execute("insert into procedimentos (id, NomeProcedimento, sysActive, sysUser) values ("&proc("Clas_ln_Counter")&", '"&rep(proc("Clas_tx_Descricao"))&"', 1, 1)")
'proc.movenext
'wend
'proc.close
'set proc=nothing

ProfissionalID = 1'@!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

set at = origem.execute("select * from receitas")
while not at.eof
	destino.execute("insert into pacientesatestadostextos (id, NomeAtestado, TituloAtestado, TextoAtestado, sysActive, sysUser) values ('"&at("COD_REC")&"', '"&rep(at("RECEITA"))&"', '', '"&replace(at("DESCRICAO"), "'", "''")&"', 1, 1)")
at.movenext
wend
at.close
set at=nothing
%>