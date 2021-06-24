<!--#include file="connect.asp"-->
<%
on error resume next

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

function telefone(val)
	val = SoNumeros(val)
	if len(val)=8 or len(val)=9 then
		val="21"&val
	end if
	telefone = val
end function

'set p = origem.execute("select * from `pacientesbanco` order by id")
'while not p.eof
	
'	destino.execute("INSERT INTO `pacientes` (id, CPF, NomePaciente, Endereco, Numero, Complemento, Bairro, Cidade, Estado, CEP, Tel1, Cel1, Tel2, Email1, Nascimento, Profissao, Observacoes, sysActive) VALUES "&_ 
'	"("&rep(p("id"))&", '"&rep(p("CPF"))&"', '"&rep(p("NomePaciente"))&"', '"&rep(p("Endereco"))&"', '"&rep(p("Numero"))&"', '"&rep(p("Complemento"))&"', '"&rep(p("Bairro"))&"', '"&rep(p("Cidade"))&"', '"&rep(p("Estado"))&"', '"&rep(p("CEP"))&"', '"&'telefone(p("Tel1"))&"', '"&telefone(p("Cel1"))&"', '"&telefone(p("Tel2"))&"', '"&rep(p("Email1"))&"', "&mydatenull(p("Nascimento"))&", '"&rep(p("Profissao"))&"', '"&replace(trim(p("Obs")&" "), "'", "''")&"', 1)")
'p.movenext
'wend
'p.close
'set p=nothing

'set cons = db.execute("select c.* from marioluiz.consultas c order by id limit 5000")
'while not cons.eof
'	if not isnull(cons("PacienteID")) then
'		PacienteID = cons("PacienteID")
'		Anamenese = cons("Anamenese")
'		Anotacoes = cons("Anotacoes")
'	else
'		db_execute("update marioluiz.consultas_concat set Anamenese=concat(Anamenese, '\n', '"&cons("Anamenese")&"'), Anotacoes=concat(Anotacoes, '\n', '"&cons("Anotacoes")&"') where PacienteID="&PacienteID)
'		'Anotacoes = Anotacoes&chr(10)&cons("Anotacoes")
'	end if
'cons.movenext
'wend
'cons.close
'set cons=nothing


%>