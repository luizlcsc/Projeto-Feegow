<!--#include file="connect.asp"-->
<!--#include file="limpaMemo.asp"-->
<%
'on error resume next

'server.ScriptTimeout = 100000

Set origem = Server.CreateObject("ADODB.Connection")
'origem.Open "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=recreio_contatos;uid=root;pwd=pipoca453;"
'origem.Open "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=uroclin;uid=root;pwd=pipoca453;"
origem.Open "DRIVER={SQL Server};SERVER=SILVIOPADRÃO\SQLEXPRESS;UID=sa;PWD=pipoca453;DATABASE=vertu"




Set destino = Server.CreateObject("ADODB.Connection")
destino.Open "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=vertu;uid=root;pwd=pipoca453;"


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
	if val="F" then
		sexo = 2
	elseif val="M" then
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

destino.execute("delete from pacientes")



'set p = origem.execute("select TOP 100 *, cast(OBSERVACOES as varchar(max)) obs from [vertu].[dbo].[CL_PACIENTES]")
set p = origem.execute("select TOP 100 HANDLE, NOME, EMAIL, CEP, MUNICIPIO, ESTADO, LOGRADOURO, COMPLEMENTO, BAIRRO, PROFISSAO, NATURALIDADE, DATANASCIMENTO, ESTADOCIVIL, SEXO, CUTIS, RG, CPF, ASSOCIADO, DATACADASTRO, MATRICULA from [vertu].[dbo].[CL_PACIENTES]")
while not p.eof
	'CIDADE (MUNICIPIO), ESTADO, ESTADOCIVIL, CUTIS (CORPELE), PROFISSAO, TELEFONES*, 
'	observacoes = p("obs")
	nascimento = "'"&left(p("DATANASCIMENTO"), 10)&"'"
	if len(nascimento)<12 then
		nascimento = "NULL"
	end if
	HANDLE = p("HANDLE")
	NOME = p("NOME")
	Email = p("EMAIL")
	Cep = p("CEP")
	Municipio = p("MUNICIPIO")
	Estado = p("ESTADO")
	Logradouro = p("LOGRADOURO")
	Complemento = p("COMPLEMENTO")
	Bairro = p("BAIRRO")
	Profissao = p("PROFISSAO")
	Naturalidade = p("NATURALIDADE")
	%>
	<%=HANDLE%> - <%=NOME%> - <%=Email%> - <%=Cep%> - <%=nascimento%> - <%=Municipio%> - <%=Estado%> - <%=Logradouro%> - <%=Complemento%> - <%=Bairro%> - <%=Profissao%> - <%=Naturalidade%><br><br>
	<%

	pendencias = ""
	sql = "INSERT INTO `pacientes` (`id`, `NomePaciente`, `Nascimento`, `Sexo`, `Cep`, `Cidade`, `Estado`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `EstadoCivil`, `CorPele`, `GrauInstrucao`, `Profissao`, `Naturalidade`, `Documento`, `Origem`, `Email1`, `CPF`, `Tabela`, `Peso`, `Altura`, `IMC`, `Observacoes`, `Pendencias`, `Foto`, `Religiao`, `Tel1`, `Tel2`, `Cel1`, `Cel2`, `Email2`, `Pais`, `IndicadoPor`, `sysActive`, `sysDate`, `sysUser`, ConvenioID1, Matricula1, Validade1, Titular1, ConvenioID2, Matricula2, Validade2, Titular2) VALUES ("& HANDLE &", '"&rep(NOME)&"', "&nascimento&", "&sexo(p("SEXO"))&", '"&CEP&"', '"&rep(Municipio)&"', '"&rep(Estado)&"', '"&rep(Logradouro)&"', '', '"&rep(Complemento)&"', '"&rep(Bairro)&"', "&estadocivil(p("ESTADOCIVIL"))&", "&corpele(p("CUTIS"))&", 0, '"&rep(Profissao)&"', '"&rep(Naturalidade)&"', '"&rep(p("RG"))&"', 0, '"&Email&"', '"&rep(p("CPF"))&"', NULL, NULL, NULL, NULL, '"&rep(observacoes)&"', '"&rep(pendencias)&"', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '"&rep(p("ASSOCIADO"))&"', 1, "&mydatetime(p("DATACADASTRO"))&", 1, NULL, '"&rep(p("MATRICULA"))&"', NULL, NULL, NULL, NULL, NULL, NULL)"


	destino.execute( sql )
p.movenext
wend
p.close
set p=nothing

%>