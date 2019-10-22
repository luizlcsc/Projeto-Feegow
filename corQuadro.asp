<%
corProf="#FFFFFF"
nomeProf=""
idProf="0"
sigla = ""

set pCorEx=db.execute("select * from assperiodolocalxprofissional where LocalID="&LocalID&" and DataDe <= "&mydatenull(Data)&" and DataA >= "&mydatenull(Data)&" and HoraDe<=time('"&formatdatetime(pTemp("Hora"),3)&"') and HoraA>=time('"&formatdatetime(pTemp("Hora"),3)&"')")

if pCorEx.EOF then
	set pCor=db.execute("select * from assfixalocalxprofissional where LocalID="&LocalID&" and diaSemana="&diaSemana&" and HoraDe<=time('"&formatdatetime(pTemp("Hora"),3)&"') and HoraA>=time('"&formatdatetime(pTemp("Hora"),3)&"')")
	if pCor.EOF then
		corProf="#FFFFFF"
		nomeProf=""
		idProf="0"
	else
		set pdesp=db.execute("select id, NomeProfissional, cor from profissionais where id = '"&pCor("ProfissionalID")&"'")
		if pdesp.eof then
			nomeProf=""
			corProf="#FFFFFF"
			idProf="0"
		else
			nomeProf="Profissional associado: "&pdesp("NomeProfissional")
			corProf=pdesp("cor")
			idProf=pdesp("id")
			sigla = left(pdesp("NomeProfissional"),1)
		end if
	end if
else
	set pdesp=db.execute("select id, NomeProfissional, cor from profissionais where id = '"&pCorEx("ProfissionalID")&"'")
	if pdesp.eof then
		nomeProf=""
		corProf="#FFFFFF"
		idProf="0"
	else
		nomeProf="Profissional associado: "&pdesp("NomeProfissional")
		corProf=pdesp("cor")
		idProf=pdesp("id")
		sigla = left(pdesp("NomeProfissional"),1)
	end if
end if

%>