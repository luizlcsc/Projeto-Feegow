<!--#include file="connect.asp"-->
<!--#include file="limpaMemo.asp"-->
<%
'on error resume next

'server.ScriptTimeout = 100000

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

db_execute("delete from buiformspreenchidos")
db_execute("delete from `_6`")
set hist = origem.execute("select h.*, p.id PacienteID, med.C_MED NomeMedico, l.RS0 NomeLocal from historia h left join pacientes p on p.NomePaciente=h.NOME left join cva4a med on med.CODMED=h.MEDICO left join cva0 l on l.COD0=h.`LOCAL` where h.id>0 order by h.id limit 1000")
while not hist.eof
	destino.execute("insert into buiformspreenchidos (id, ModeloID, PacienteID, DataHora, sysUser) values("&hist("id")&", 6, "&hist("PacienteID")&", "&mydatenull(hist("DATA"))&", 1)")
	destino.execute("insert into `_6` (id, PacienteID, DataHora, sysUser, `24`, `25`, `26`, `27`) values ("&hist("id")&", "&hist("PacienteID")&", "&mydatenull(hist("DATA"))&", 1, '"&hist("NASC")&"', '"&hist("NomeMedico")&"', '"&hist("NomeLocal")&"', '"&replace(hist("HIST"), "'", "''")&"')")
hist.movenext
wend
hist.close
set hist = nothing
%>