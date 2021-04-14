<!--#include file="connect.asp"-->
<%
'on error resume next

'server.ScriptTimeout = 100000

Set origem = Server.CreateObject("ADODB.Connection")
origem.Open "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database="&request.QueryString("Origem")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
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
		val="34"&val
	end if
	telefone = val
end function

'set p = origem.execute("select * from fcfo where TIPO='C'")
'while not p.eof
'	CODCFO - id
'	NOME - NomePaciente
'	CGCCFO - CPF
'	INSCRESTADUAL - Documento
'	RUA - Endereco
'	NUMERO - Numero
'	COMPLEMENTO - Complemento
'	BAIRRO - Bairro
'	CIDADE - Cidade
'	CODETD - Estado
'	CEP - Cep
'	TELEFONE - Tel1
'	TELEFONE2 - Cel1
'	FAX - Cel2
'	EMAIL - Email1
'	DATACRIACAO - sysDate
'	DATANASC - Nascimento
'	sql = "INSERT INTO `pacientes` (`id`, `NomePaciente`, `CPF`, `Documento`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Cep`, `Tel1`, `Cel1`, `Cel2`, `Email1`, `sysDate`, `Nascimento`, `sysActive`, `sysUser`) VALUES "&_ 
'	"("&replace(p("CODCFO"), "C", "")&", '"&rep(p("NOME"))&"', '"&p("CGCCFO")&"', '"&p("INSCRESTADUAL")&"', '"&rep(p("RUA"))&"', '"&rep(p("NUMERO"))&"', '"&rep(p("COMPLEMENTO"))&"', '"&rep(p("BAIRRO"))&"', '"&rep(p("CIDADE"))&"', '"&rep(p("CODETD"))&"', '"&p("CEP")&"', '"&telefone(p("TELEFONE"))&"', '"&telefone(p("TELEFONE2"))&"', '"&telefone(p("FAX"))&"', '"&rep(p("EMAIL"))&"', "&mydatetime(p("DATACRIACAO"))&", "&mydatenull(p("DATANASC"))&", 1, 1)"
'	response.Write(sql)
'	destino.execute(sql)
'p.movenext
'wend
'p.close
'set p=nothing

set p = origem.execute("select * from fcfo where TIPO='F'")
while not p.eof
'	CODCFO - id
'	NOME - NomePaciente
'	CGCCFO - CPF
'	INSCRESTADUAL - Documento
'	RUA - Endereco
'	NUMERO - Numero
'	COMPLEMENTO - Complemento
'	BAIRRO - Bairro
'	CIDADE - Cidade
'	CODETD - Estado
'	CEP - Cep
'	TELEFONE - Tel1
'	TELEFONE2 - Cel1
'	FAX - Cel2
'	EMAIL - Email1
'	DATACRIACAO - sysDate
'	DATANASC - Nascimento
	sql = "INSERT INTO `fornecedores` (`id`, `NomeFornecedor`, `CPF`, `RG`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Cep`, `Tel1`, `Cel1`, `Cel2`, `Email1`, `sysActive`, `sysUser`) VALUES "&_ 
	"("&replace(p("CODCFO"), "C", "")&", '"&rep(p("NOME"))&"', '"&p("CGCCFO")&"', '"&p("INSCRESTADUAL")&"', '"&rep(p("RUA"))&"', '"&rep(p("NUMERO"))&"', '"&rep(p("COMPLEMENTO"))&"', '"&rep(p("BAIRRO"))&"', '"&rep(p("CIDADE"))&"', '"&rep(p("CODETD"))&"', '"&p("CEP")&"', '"&telefone(p("TELEFONE"))&"', '"&telefone(p("TELEFONE2"))&"', '"&telefone(p("FAX"))&"', '"&rep(p("EMAIL"))&"', 1, 1)"
	response.Write(sql)
	destino.execute(sql)
p.movenext
wend
p.close
set p=nothing


'set pro = origem.execute("select * from tproduto")
'while not pro.eof
'	destino.execute("insert into procedimentos (id, NomeProcedimento, Valor, sysActive, sysUser) values "&_ 
'	"("&pro("CODPRD")&", '"&rep(pro("NOMEFANTASIA"))&"', "&treatvalnull(pro("PRECO1"))&", 1, 1)")
'pro.movenext
'wend
'pro.close
'set pro=nothing

'set a = origem.execute("select c.IDCOMPROMISSO id, replace(c.CODCFO, 'C', '') PacienteID, 1 StaID, c.CODVEN ProfissionalID, a.DATA Data, a.HORA Hora, cp.CODPRD TipoCompromissoID, p.PRECO1 ValorPlano, 'V' rdValorPlano, concat(c.DESCRICAO, ' - ', c.DETALHE) Notas from gagendacompromisso a left join gcompromisso c on c.IDCOMPROMISSO=a.IDCOMPROMISSO left join gcompromissoproduto cp on cp.IDCOMPROMISSO=c.IDCOMPROMISSO left join tproduto p on p.CODPRD=cp.CODPRD where not isnull(replace(c.CODCFO, 'C', '')) and not isnull(c.CODVEN)")
'while not a.eof
'	destino.execute("insert into agendamentos (id, PacienteID, StaID, ProfissionalID, Data, Hora, TipoCompromissoID, ValorPlano, rdValorPlano, Notas) values ("&rep(a("id"))&", "&treatvalnull(a("PacienteID"))&", "&rep(a("StaID"))&", "&treatvalnull(a("ProfissionalID"))&", "&mydatenull(a("Data"))&", "&mytime(a("Hora"))&", "&treatvalnull(a("TipoCompromissoID"))&", "&treatvalzero(a("ValorPlano"))&", '"&rep(a("rdValorPlano"))&"', '"&rep(a("Notas"))&"')")
'a.movenext
'wend
'a.close
'set a=nothing
%>