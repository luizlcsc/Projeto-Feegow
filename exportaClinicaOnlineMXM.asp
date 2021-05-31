<!--#include file="connect.asp"-->
<%
'on error resume next

server.ScriptTimeout = 100000

Set origem = Server.CreateObject("ADODB.Connection")
origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&req("Origem")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
'origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellos;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"

Set destino = Server.CreateObject("ADODB.Connection")
destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&req("Destino")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
'destino.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=danielvasconcellosimportado;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"


'set p = origem.execute("select * from sch_contact")
'while not p.eof
'	response.Write(limpaMemo(p("Fld3"))&"<hr />")
'p.movenext
'wend
'p.close
'set p=nothing

function sexo(val)
	if val="Feminino" then
		sexo = 2
	elseif val="Masculino" then
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



function tel(val, num)
	spl = split(val&" ", ", ")
	if ubound(spl)>=num then
		tel = trim(spl(num))
		if len(tel)=10 then
			tel = "("&left(tel, 2)&") "&mid(tel,3,4)&"-"&right(tel,4)
		elseif len(tel)=11 then
			tel = "("&left(tel, 2)&") "&mid(tel,3,4)&"-"&right(tel,5)
		end if
	else
		tel = ""
	end if
end function

set p = origem.execute("select * from pacientes")
while not p.eof
	destino.execute("INSERT INTO `pacientes` (`id`, `NomePaciente`, `CPF`, `Documento`, `Nascimento`, `Sexo`, `Endereco`, `Profissao`, `Email1`, `Email2`, `EstadoCivil`, `sysActive`, `sysUser`, sysDate, Tel1, Cel1, Tel2, Cel2) VALUES ("&rep(p("ROWNUM"))+10&", '"&rep(p("NOME"))&"', '"&rep(p("CPF"))&"', '"&rep(p("RG"))&"', "&myDateNULL(p("DataNascimento"))&", '"&sexo(p("SEXO"))&"', '"&rep(p("ENDERECO"))&"', '"&rep(p("PROFISSAO"))&"', '"&rep(p("EMAIL"))&"', '"&rep(p("OUTROSEMAILS"))&"', '"&estadocivil(p("EstadoCivil"))&"', 1, 1, "&mydatenull(p("DATACADASTRO"))&", '"&tel(p("CONTATOS"), 0)&"', '"&tel(p("CONTATOS"), 1)&"', '"&tel(p("CONTATOS"), 2)&"', '"&tel(p("CONTATOS"), 3)&"')")
p.movenext
wend
p.close
set p=nothing
%>