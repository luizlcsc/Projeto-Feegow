<!--#include file="connect.asp"-->
<%
set zero = db.execute("select NomePaciente, Tel1, Cel1 from agendamentos where (PacienteID=0 or isnull(PacienteID)) and Data>=date(now()) and NomePaciente<>'' group by NomePaciente")
while not zero.EOF
	set vca = db.execute("select id, trim(NomePaciente) from pacientes where (NomePaciente)='"&trim(zero("NomePaciente"))&"'")
	if not vca.EOF then
		PacienteID = vca("id")
	else
		db_execute("insert into pacientes (NomePaciente, Tel1, Cel1, sysUser, sysActive) values ('"&zero("NomePaciente")&"', '"&zero("Tel1")&"', '"&zero("Cel1")&"', 1, 1)")
		set pult = db.execute("select id from pacientes order by id desc")
		PacienteID = pult("id")
	end if
	db_execute("update agendamentos set PacienteID="&PacienteID&" where trim(NomePaciente)='"&trim(zero("NomePaciente"))&"'")
zero.movenext
wend
zero.close
set zero=nothing
%>