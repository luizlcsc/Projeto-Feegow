<!--#include file="connect.asp"-->
<%
tableName = ref("P")
id = ref("I")
spl = split(request.form(), "&")

if lcase(ref("P"))="profissionais" or lcase(ref("P"))="funcionarios" then
	set vcIns = db.execute("select sysActive from "&tableName&" where id="&id)
	if not vcIns.EOF then
		if vcIns("sysActive")=0 then
			tipo = lcase(ref("P"))
			if tipo="profissionais" then Nome = "NomeProfissional" end if
			if tipo="funcionarios" then Nome = "NomeFuncionario" end if
			db_execute("insert into cliniccentral.licencaslogs (LicencaID, tipo, Nome, idTabela, acao, sysUser) values ("&replace(session("banco"), "clinic", "")&", '"&tipo&"', '"&ref(""&Nome&"")&"', '"&id&"', 'I', "&session("User")&")")
		end if
	end if
end if


for i=0 to ubound(spl)
	spl2 = split(spl(i), "=")
	inputsCompare = inputsCompare&"|"&spl2(0)&"|"
next
'response.Write("select * from cliniccentral.sys_resources where tableName='"&tableName&"'")
set getResource = db.execute("select * from cliniccentral.sys_resources where tableName='"&tableName&"'")
if not getResource.EOF then
	set getFields = db.execute("select * from cliniccentral.sys_resourcesFields where resourceID="&getResource("id"))
	sqlFields = "sysActive=1"
	while not getFields.EOF
		if getFields("fieldTypeID")=6 then
			if ref(getFields("columnName"))="" or not isnumeric(ref(getFields("columnName"))) then
				sqlValue = "NULL"
			else
				sqlValue = "'"&treatVal(ref(getFields("columnName")))&"'"
			end if
		elseif getFields("fieldTypeID")=3 then
			if ref(getFields("columnName"))<>"" and isnumeric(ref(getFields("columnName"))) then
				sqlValue = ccur(ref(getFields("columnName")))
			else
				sqlValue = 0
			end if
		elseif getFields("fieldTypeID")=13 or getFields("fieldTypeID")=10 then
			if ref(getFields("columnName"))="" then
				sqlValue = "NULL"
			else
				if not isDate(ref(getFields("columnName"))) then
					sqlValue = "NULL"
				else
					sqlValue = "'"&year(ref(getFields("columnName")))&"-"&month(ref(getFields("columnName")))&"-"&day(ref(getFields("columnName")))&"'"
				end if
			end if
		else
			sqlValue = "'"&ref(getFields("columnName"))&"'"
		end if
		if getFields("fieldTypeID")<>17 then
			sqlFields = sqlFields&", "&getFields("columnName")&"="&sqlValue
			columnsCompare = columnsCompare&"|"&getFields("columnName")&"|"
		end if
		if instr(inputsCompare, "|"&getFields("columnName")&"|")=0 then
			falta = falta&"|"&getFields("columnName")&"|"
		end if
	getFields.movenext
	wend
	getFields.close
	set getFields=nothing
	
	sql = "update "&tableName&" set "&sqlFields&" where id="&id
'	response.Write(sql)
	dbx(sql)
	%>
        $.gritter.add({
            title: '<i class="far fa-save"></i> Dados gravados com sucesso.',
            text: '',
            class_name: 'gritter-success gritter-light'
        });
	<%


	set getSubforms = db.execute("select * from cliniccentral.sys_resources where mainForm="&getResource("id"))
	while not getSubforms.EOF
		strSubTipos = ""
		strSubNomes = ""
		set getSubFields = db.execute("select * from cliniccentral.sys_resourcesFields where resourceID="&getSubForms("id")&" and not columnName='"&getSubForms("mainFormColumn")&"'")
		while not getSubFields.EOF
			strSubTipos = strSubTipos&"|"&getSubFields("fieldTypeID")
			strSubNomes = strSubNomes&"|"&getSubFields("columnName")
		getSubFields.movenext
		wend
		getSubFields.close
		set getSubFields=nothing

''		response.Write(strSubTipos&chr(10)) => para fazer conferencia de campos faltando
''		response.Write(strSubNomes&chr(10))
		splSubTipos = split(strSubTipos, "|")
		splSubNomes = split(strSubNomes, "|")

		if lcase(getSubforms("tableName"))<>"pacientesconvenios" then
			set regs = db.execute("select * from "&getSubforms("tableName")&" where sysActive=1 and "&getSubForms("mainFormColumn")&"="&id)
			while not regs.EOF
				codeUp = ""
				for j=0 to ubound(splSubTipos)
					if splSubTipos(j)<>"" then
						Valor = ref(splSubNomes(j)&"-"&getSubForms("tableName")&"-"&regs("id"))
						if splSubTipos(j)="6" then
							Valor = "'"&treatval(Valor)&"'"
						elseif splSubTipos(j)="13" or splSubTipos(j)="10" then
							if Valor="" then
								Valor = "NULL"
							else
								if not isDate(Valor) then
									Valor = "NULL"
								else
									Valor = "'"&year(Valor)&"-"&month(Valor)&"-"&day(Valor)&"'"
								end if
							end if
						else
							Valor = "'"&Valor&"'"
						end if
						if splSubTipos(j)<>"17" then
							codeUp = codeUp&", "&splSubNomes(j)&"="&Valor
						end if
					end if
				next
				codeUp = "update "&getSubforms("tableName")&" set sysActive=1"&codeUp& " where id="&regs("id")
				'=response.Write( codeUp&chr(10) )
				db_execute(codeUp)
			regs.movenext
			wend
			regs.close
			set regs=nothing
		end if


	getSubforms.movenext
	wend
	getSubforms.close
	set getSubforms = nothing
	'response.Write("Falta: "&falta)
end if


if ref("NewForm")="1" then
	set pCampos = db.execute("select * from buicamposforms where FormID="&id)
	while not pCampos.EOF
		TipoCampoID = pCampos("TipoCampoID")
		CampoID = pCampos("id")
		select case TipoCampoID
			case 1, 2' texto, data e memo
				db_execute("update buicamposforms set ValorPadrao='"&ref("input_"&CampoID)&"' where id="&CampoID)
			case 4'checkbox
				set opt = db.execute("select * from buiopcoescampos where CampoID="&CampoID)
				while not opt.eof
					db_execute("update buiopcoescampos set Selecionado='"&ref("input_"&CampoID&"_"&opt("id"))&"' where id="&opt("id"))
				opt.movenext
				wend
				opt.close
				set opt=nothing
			case 5, 6'radio e select
				db_execute("update buiopcoescampos set Selecionado='S' where id = '"&ref("input_"&CampoID)&"'")
			case 9'tabela
				'atualizando o título da tabela
				c = 0
				strUpTit = "update buitabelastitulos set "
				while c<20
					c=c+1
					strUpTit = strUpTit&"c"&c&"='"& ref(CampoID&"_t"&c) &"', "
				wend
				strUpTit = left(strUpTit, len(strUpTit)-2)
				strUpTit = strUpTit&" where CampoID="&CampoID
				db_execute(strUpTit)
				
				'atualizando os valores padrão da tabela
				set linhas = db.execute("select * from buitabelasmodelos where CampoID="&CampoID)
				while not linhas.eof
					c = 0
					strUpLin = "update buitabelasmodelos set "
					while c<20
						c=c+1
						strUpLin = strUpLin&"c"&c&"='"& ref(linhas("id")&"_c"&c) &"', "
					wend
					strUpLin = left(strUpLin, len(strUpLin)-2)
					strUpLin = strUpLin&" where id="&linhas("id")
					db_execute(strUpLin)
				linhas.movenext
				wend
				linhas.close
				set linhas = nothing
		end select
	pCampos.movenext
	wend
	pCampos.close
	set pCampos = nothing
end if

if lcase(tableName)="pacientes" then
	'dá update nos agendamentos do dia que são convenio diferente de um dos tres convenios para o primeiro convenio, se ele existe
	if ref("ConvenioID1")<>"" or ref("ConvenioID2")<>"" or ref("ConvenioID3")<>"" then
		if ref("ConvenioID3")<>"" then
			Convenio = ref("ConvenioID3")
		end if
		if ref("ConvenioID2")<>"" then
			Convenio = ref("ConvenioID2")
		end if
		if ref("ConvenioID1")<>"" then
			Convenio = ref("ConvenioID1")
		end if
		set vcMuda = db.execute("select id from agendamentos where rdValorPlano='P' and ValorPlano not in("&treatvalzero(ref("ConvenioID1"))&", "&treatvalzero(ref("ConvenioID2"))&", "&treatvalzero(ref("ConvenioID3"))&") and Data=date(now()) and PacienteID="&id)
		if not vcMuda.EOF then
			set nomeConv = db.execute("select NomeConvenio from convenios where id="&Convenio)
			if not nomeConv.EOF then
				%>
				$("#searchConvenioID").val("<%=nomeConv("NomeConvenio")%>");
				$("#ConvenioID").val("<%=Convenio%>");
				<%
				db_execute("update agendamentos set ValorPlano="&Convenio&" where id="&vcMuda("id"))
			end if
		end if
	end if

	if getConfig("AlterarNumeroProntuario") = 1 then
	'if session("banco")="clinic1612" or session("banco")="clinic5868" or session("banco")="clinic3859" then
		if isnumeric(ref("Prontuario")) and ref("Prontuario")<>"" then
			set vca = db.execute("select id, idImportado, NomePaciente from pacientes where idImportado="&ref("Prontuario")&" and id<>"&id)
			if not vca.eof then
				erro = "Este número de prontuário já está sendo usado para o paciente:<br> <a class=""white"" href=""./?P=Pacientes&I="&vca("id")&"&Pers=1""><strong>"&vca("NomePaciente")&"</strong></a>"
			end if
		else
			erro = "Preencha corretamente o número do prontuário."
		end if
		if erro<>"" then
			%>
			$.gritter.add({
				title: '<i class="far fa-error"></i> Erro!',
				text: '<%=erro%>',
				class_name: 'gritter-error'
			});
			<%
		else
			db_execute("update pacientes set idImportado="&ref("Prontuario")&" where id="&id)
		end if
	end if
end if

'on error resume next
	db_execute("insert into cliniccentral.logprofissionais (dados) values ('"&replace(request.form(), "'", "''")& "  ---   Usuario: "& session("User") &" --- IP: "& request.ServerVariables("REMOTE_ADDR") &"')")
%>
