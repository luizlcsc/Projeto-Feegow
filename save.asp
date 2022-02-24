<!--#include file="connect.asp"-->
<!--#include file="validar.asp"-->
<!--#include file="webhookFuncoes.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="Classes/queryActionsLogs.asp"-->
<%
tableName = ref("P")
id = ref("I")


' vuneravilidade
spl = split(request.Form(), "&")

Novo=False
sysActive=0

set ActiveSQL = db.execute("SELECT sysActive FROM "&tableName&" WHERE id="&id&" LIMIT 1")
if not ActiveSQL.eof then
    sysActive=ActiveSQL("sysActive")
    if sysActive=0 then
        Novo=True
    end if
end if

if session("Banco")="clinic5760" or session("Banco")="clinic100002" or session("Banco")="clinic100000" or session("Banco")="clinic105" or session("Banco")="clinic5355" or True then
    '---> ADICIONANDO FUNCOES V7.5
    set Config = db.execute("SELECT ValidarCPFCNPJ, BloquearCPFCNPJDuplicado FROM sys_config WHERE id=1")
    if not Config.eof then
        ValidarCPFCNPJ = Config("ValidarCPFCNPJ")
        BloquearCPFCNPJDuplicado = Config("BloquearCPFCNPJDuplicado")
    end if

    IF (NOT (getConfig("ExibirMascaraCPFPaciente") = 1)) and lcase(tableName)="pacientes" THEN
        ValidarCPFCNPJ="N"
    END IF

    if ValidarCPFCNPJ="S" then
        if ref("CPF")<>"" and lcase(tableName)<>"fornecedores" then
            if CalculaCPF(ref("CPF"))=0 then
                erro = "CPF inválido."
            end if
        end if

        if ref("CNPJ")<>"" and lcase(tableName)="empresa" or lcase(tableName)="sys_financialcompanyunits" then
            if CalculaCNPJ(ref("CNPJ"))=0 then
                erro = "CNPJ inválido."
            end if
        end if

        if ref("CPF")<>"" and lcase(tableName)="fornecedores" then
            cnpj = ref("CPF")
            cnpj = replace(replace(replace(cnpj,"-",""),".",""),"/","")
            result = 0
            if len(cnpj)=11 then
                result = CalculaCPF(ref("CPF"))
            end if
            if len(cnpj)=14 then
                result = CalculaCNPJ(ref("CPF"))
            end if
            if result=0 then
                erro = "CPF/CNPJ inválido."
            end if
        end if
    end if


    if lcase(tableName)="pacientes" then

        id2 = id

        if Novo then
            call addToQueue(116, id2, "")
        else
            call addToQueue(117, id2, "")
        end if

        '--->Verificar CPF duplicado
        if BloquearCPFCNPJDuplicado="S" and req("ForceDuplicado")<>"S" then
            set PacienteDuplicadoSQL = db.execute("SELECT cpf,id, NomePaciente FROM pacientes WHERE (cpf='"&ref("CPF")&"' and sysActive=1 and '"&ref("CPF")&"'!='' and id!="&ref("I")&") ")
            if not PacienteDuplicadoSQL.eof then
                motivoDupli = "CPF"
                DuplicacaoID = PacienteDuplicadoSQL("id")

                NaoPermitirCPFduplicado = getConfig("NaoPermitirCPFduplicado")
                ButtonSalvarAssimMesmo = "<button href=\'#\' class=\'btn btn-sm btn-success center\' type=\'button\' onclick=""javascript:$.post(\'save.asp?ForceDuplicado=S\',\'"&request.Form()&"\' , function(data){eval(data);})""> Salvar mesmo assim.</button>"
                if NaoPermitirCPFduplicado = 1 then
                    ButtonSalvarAssimMesmo = ""
                end if
                erro = "Paciente duplicado ("&motivoDupli&")"
                if motivoDupli="CPF" then
                    'erro = erro&"  <br><a style=""color:white"" href=""?P=Pacientes&Pers=1&I="&DuplicacaoID&""">"&PacienteDuplicadoSQL("NomePaciente")&"</a><br> <button href=\'#\' class=\'btn btn-sm btn-success center\' type=\'button\' onclick=""javascript:$.get(\'SalvaPacienteCPFDuplicado.asp?PacienteID="&id&"&Tipo=CPF&CPF="&ref("CPF")&"\', function(data){eval(data);})"">Salvar mesmo assim.</a>"
                    erro = erro&"  <br><a style=""color:white"" href=""?P=Pacientes&Pers=1&I="&DuplicacaoID&""">"&PacienteDuplicadoSQL("NomePaciente")&"</a><br>"&ButtonSalvarAssimMesmo
                end if

            end if
        end if
        '--->Verificar EMAIL duplicado

        if session("Banco")="clinic6118" and 1=2 then
            if instr(ref("Email1"), "@")>0 then
                set PacienteDuplicadoEmailSQL = db.execute("SELECT id, NomePaciente FROM pacientes WHERE (((Email1='"&ref("Email1")&"' and Email1<>'') or (Email1='"&ref("Email2")&"' and Email1<>'') or (Email2='"&ref("Email1")&"' and Email2<>'') or (Email2='"&ref("Email2")&"' and Email2<>'')) and id!="&ref("I")&") ")
                if not PacienteDuplicadoEmailSQL.eof then
                    motivoDupli = "EMAIL"
                    DuplicacaoID = PacienteDuplicadoEmailSQL("id")


                    erro = "Paciente com E-mail duplicado"
                    if motivoDupli="EMAIL" then
                        erro = erro&"  <br><a style=""color:white"" href=""?P=Pacientes&Pers=1&I="&DuplicacaoID&""">"&PacienteDuplicadoEmailSQL("NomePaciente")&"</a><br> <button href=\'#\' class=\'btn btn-sm btn-success center\' type=\'button\' onclick=""javascript:$.get(\'SalvaPacienteCPFDuplicado.asp?PacienteID="&id&"&Tipo=EMAIL&Email1="&ref("Email1")&"&Email2="&ref("Email2")&"\', function(data){eval(data);})"">Salvar mesmo assim.</a>"
                    end if

                end if
            end if
        end if

        '--->Verificar TEL duplicado

        if session("Banco")="clinic6118" and 1=2 then
            set PacienteDuplicadoTelSQL = db.execute("SELECT id, NomePaciente FROM pacientes WHERE "&_
            "( (((Tel1='"&ref("Tel1")&"' and Tel1<>'') or (Tel1='"&ref("Cel1")&"' and Tel1<>'') or (Tel1='"&ref("Cel2")&"' and Tel1<>'') or (Tel1='"&ref("Tel2")&"'  and Tel1<>''))) or "&_
            "(((Tel2='"&ref("Tel1")&"' and Tel2<>'') or (Tel2='"&ref("Cel1")&"' and Tel2<>'') or (Tel2='"&ref("Cel2")&"' and Tel2<>'') or (Tel2='"&ref("Tel2")&"' and Tel2<>''))) or "&_
            "(((Cel1='"&ref("Tel1")&"' and Cel1<>'') or (Cel1='"&ref("Cel1")&"' and Cel1<>'') or (Cel1='"&ref("Cel2")&"' and Cel1<>'') or (Cel1='"&ref("Tel2")&"' and Cel1<>''))) or "&_
            "(((Cel2='"&ref("Tel1")&"' and Cel2<>'') or (Cel2='"&ref("Cel1")&"' and Cel2<>'') or (Cel2='"&ref("Cel2")&"' and Cel2<>'') or (Cel2='"&ref("Tel2")&"' and Cel2<>''))) or "&_
            "(LENGTH(Tel1)>8 and LENGTH(Tel2)>8 and LENGTH(Cel1)>8 and LENGTH(Cel2)>8)) "&_
            "and id!="&ref("I")&" ")

            if not PacienteDuplicadoTelSQL.eof then
                motivoDupli = "Telefone"
                DuplicacaoID = PacienteDuplicadoTelSQL("id")


                erro = "Paciente com Telefone duplicado"
                if motivoDupli="Telefone" then
                    erro = erro&"  <br><a style=""color:white"" href=""?P=Pacientes&Pers=1&I="&DuplicacaoID&""">"&PacienteDuplicadoTelSQL("NomePaciente")&"</a><br> <button href=\'#\' class=\'btn btn-sm btn-success center\' type=\'button\' onclick=""javascript:$.get(\'SalvaPacienteCPFDuplicado.asp?PacienteID="&id&"&Tipo=TEL&Tel1="&ref("Tel1")&"&Tel2="&ref("Tel2")&"&Cel1="&ref("Cel1")&"&Cel2="&ref("Cel2")&"\', function(data){eval(data);})"">Salvar mesmo assim.</a>"
                end if

            end if
        end if

        '<Aciona webhook de sincronização com SalesForce>
        if recursoAdicional(45) = 4 then
            'ID padrão no cliniccentral / webhook_eventos / id
            call webhook(118, true, "[PacienteID]", ref("I"))
        end if
        '</Aciona webhook de sincronização com SalesForce>
    end if

    if lcase(tableName)="empresa" or lcase(tableName)="sys_financialcompanyunits" then
        idUnit=id
        if tableName="empresa" then
            idUnit=0
        end if
        'if ref("TipoPessoa")="PJ" then

            '--->Verificar CNPJ duplicado
            if BloquearCPFCNPJDuplicado="S" then

                'if ref("cnpj")="" or len(ref("cnpj"))<>18 then
                '    erro = "CNPJ inválido."
                'end if
                cnpj = ref("CNPJ")
                cnpj = replace(replace(replace(cnpj,"-",""),".",""),"/","")

                sqlCNPJ = "select replace(replace(replace(CNPJ,'.',''),'-',''),'/','') cnpj, id, sysActive FROM ((SELECT replace(replace(replace(f.CNPJ,'.',''),'-',''),'/','') cnpj, f.id, f.sysActive FROM sys_financialcompanyunits f)UNION(SELECT replace(replace(replace(e.CNPJ,'.',''),'-',''),'/','') cnpj, 0, e.sysActive as id FROM empresa e) )t WHERE sysActive=1 AND id != "&idUnit&" AND t.CNPJ = '"&cnpj&"' "

                set sqlCPFSQL = db.execute(sqlCNPJ)
                if not sqlCPFSQL.eof then
                    if sqlCPFSQL("cnpj")=cnpj then
                        erro = "CNPJ já cadastrado."
                    end if
                end if

            end if

        'elseif ref("TipoPessoa")="PF" then
        '    if ref("cpf")="" or len(ref("cpf"))<>14 then
        '        erro = "CPF inválido."
        '    end if
        'else
        '    erro = "Preencha o tipo de pessoa."
        'end if

        if erro<>"" then
        %>

        new PNotify({
            title: 'ERRO!',
            text: '<%=erro%>',
            type: 'danger',
            delay:3000
        });
        <%
        Response.End
        end if
    end if

    if lcase(tableName)="fornecedores" then
        '--->Verificar CNPJ duplicado
        if BloquearCPFCNPJDuplicado="S" then


            cnpj = ref("CPF")
            cnpj = replace(replace(replace(cnpj,"-",""),".",""),"/","")

            sqlCNPJ = "SELECT replace(replace(replace(CPF,'.',''),'-',''),'/','') CPF,id FROM fornecedores WHERE (replace(replace(replace(cpf,'.',''),'-',''),'/','')='"&cnpj&"' and sysActive=1 and '"&ref("CPF")&"'!='' and id!="&ref("I")&")  "

            set sqlCPFSQL = db.execute(sqlCNPJ)
            if not sqlCPFSQL.eof then
                if sqlCPFSQL("CPF")=cnpj then
                    erro = "CPF/CNPJ já cadastrado."
                end if
            end if

        end if

        if erro<>"" then
        %>
        new PNotify({
            title: 'ERRO!',
            text: '<%=erro%>',
            type: 'danger',
            delay:3000
        });
        <%
        Response.End
        end if
    end if
'<--- FINALIZANDO FUNCOES V7.5
end if

if lcase(ref("P")) = "estoque_requisicao" then
    autorizadorId = ref("AutorizadorID")
    filaTransferenciaId = ref("I")
    prioridadeId = ref("PrioridadeID")
    Metadata = ref("obsEstoque")

    if ref("StatusID")="1" then
        call addNotificacao(2, autorizadorId, filaTransferenciaId, prioridadeId, 1, Metadata)
    else
        %><!--#include file="Classes/Notificacoes.asp"--><%
        call clearNotificacoes(2, filaTransferenciaId, 4)
    end if
end if


if lcase(ref("P"))="profissionais" or lcase(ref("P"))="funcionarios" then
	tipo = lcase(ref("P"))
	if tipo="profissionais" then Nome = "NomeProfissional" end if
	if tipo="funcionarios" then Nome = "NomeFuncionario" end if
	set vcIns = db.execute("select sysActive,Ativo from "&tableName&" where id="&id)
	if not vcIns.EOF then
	    UsuarioAtivo = "0"
	    IF ref("Ativo") = "on" THEN
	        UsuarioAtivo = "1"
	    END IF

		if vcIns("sysActive")=0 then
			db_execute("insert into cliniccentral.licencaslogs (LicencaID, tipo, Nome, idTabela, acao, sysUser) values ("&replace(session("banco"), "clinic", "")&", '"&tipo&"', '"&ref(""&Nome&"")&"', '"&id&"', 'I', "&session("User")&")")
        'else
        '    if vcIns("Ativo")="on" then
        '        if ref("Ativo")="" then
        '            db_execute("insert into cliniccentral.licencaslogs (LicencaID, tipo, Nome, idTabela, acao, sysUser) values ("&replace(session("banco"), "clinic", "")&", '"&tipo&"', '"&ref(""&Nome&"")&"', '"&id&"', 'X', "&session("User")&")")
        '        end if
        '    end if
		end if
	end if

    '--->Verificar CPF duplicado
    if BloquearCPFCNPJDuplicado="S" then

        cpf = ref("CPF")
        cpf = replace(replace(replace(cpf,"-",""),".",""),"/","")


        if cpf<>"00000000000" then
            sqlCPF = "select cpf,DocumentoConselho,id FROM ((SELECT f.CPF,''DocumentoConselho,f.id, f.Ativo, f.sysActive FROM funcionarios f WHERE f.CPF = '"&ref("CPF")&"')UNION(SELECT p.CPF,p.DocumentoConselho,p.id, p.Ativo, p.sysActive FROM profissionais p WHERE p.cpf='"&ref("CPF")&"'  OR (p.DocumentoConselho = '"&ref("DocumentoConselho")&"' and p.UFConselho='"&ref("UFConselho")&"' and p.Conselho='"&ref("Conselho")&"' and p.DocumentoConselho!='')) )t WHERE t.sysActive=1 AND t.Ativo='on' AND id != "&id&""
            'response.write(sqlCPF)
            set cpfs = db.execute(sqlCPF)
            if not cpfs.eof then
                motivoErro = "CPF"
                if cpfs("CPF")<>ref("CPF") then
                    motivoErro = "CRM"
                end if
                %>
                new PNotify({
                    title: 'ERRO!',
                    text: 'Já há um usuário com este <%=motivoErro%>.',
                    type: 'danger'
                });
                <%
                Response.End
            end if
        end if
    end if

	set vcaUser = db.execute("select id from sys_users where `Table`='"&tableName&"' AND idInTable="&id)
	if NOT vcaUser.EOF then
		db_execute("UPDATE cliniccentral.licencasusuarios SET Nome='"&ref(""&Nome&"")&"',Ativo="&UsuarioAtivo&" WHERE id="&vcaUser("id"))
	end if
end if


for spl_i=0 to ubound(spl)
	spl2 = split(spl(spl_i), "=")
	inputsCompare = inputsCompare&"|"&spl2(0)&"|"
next
'response.Write("select * from cliniccentral.sys_resources where tableName='"&tableName&"'")
set getResource = db.execute("select * from cliniccentral.sys_resources where tableName='"&tableName&"'")
set configuracao = db.execute("select * from sys_config")

if not getResource.EOF then
    '-> GRAVANDO O NOVO LOG

    set valorAntigo = db.execute("select * from `"& tableName &"` where id="& id)
    '<- GRAVANDO O NOVO LOG
	set getFields = db.execute("select * from cliniccentral.sys_resourcesFields where resourceID="&getResource("id"))
	sqlFields = "sysActive=1"
	while not getFields.EOF
		if getFields("fieldTypeID")=6 or getFields("fieldTypeID")=5 or getFields("fieldTypeID")=29 then
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

        elseif getFields("fieldTypeID")=7 then
            if getFields("columnName") = "DiasAvisoValidade" then
                sqlValue = treatvalnull(refhtml(getFields("columnName")))
            else
                sqlValue = valnullToZero(ref(getFields("columnName")))
            end if
        else
            sqlValue = "'"&refhtml(getFields("columnName"))&"'"
        end if

        IF getFields("id") = 1 or getFields("id") = 138 or getFields("id") = 250 then

            valor = ref(getFields("columnName"))

            if instr(getFields("columnName"), "Nome")>0 then
                valor = NomeNoPadrao(valor)
            end if
			sqlValue = "'"&valor&"'"
	    END IF


	    if getFields("columnName")="ProjetoID" AND tableName="tarefas" AND ref(getFields("columnName")) = "0" then
	        sqlValue = "NULL"
	    end if

		if getFields("fieldTypeID")<>17 then
            'TRATA UPDATE NO CPF
            if getFields("columnName")="CPF" or getFields("columnName")="CNPJ" or getFields("columnName")="Cel1" or getFields("columnName")="Tel1" or getFields("columnName")="Cel2" or getFields("columnName")="Cel1" then
                sqlFields = sqlFields&", `"&getFields("columnName")&"`="&RemoveCaracters(sqlValue,".-/() ")
            else
                sqlFields = sqlFields&", `"&getFields("columnName")&"`="&sqlValue
            end if
			columnsCompare = columnsCompare&"|"&getFields("columnName")&"|"
		end if

		if instr(inputsCompare, "|"&getFields("columnName")&"|")=0 then
			falta = falta&"|"&getFields("columnName")&"|"
		end if

        '-> GRAVANDO NOVO LOG 2
        if not valorAntigo.eof then
            txtValorAntigo = valorAntigo(""&getFields("columnName")&"")&""
            txtValorAtual = ref(getFields("columnName"))&""
            if txtValorAntigo<>txtValorAtual and not (txtValorAntigo="" and txtValorAtual="0") and not (txtValorAtual="" and txtValorAntigo="0") then
                logColunas = logColunas & "|" & getFields("columnName")
                logValorAnterior = logValorAnterior & "|^" & txtValorAntigo
                logValorNovo = logValorNovo & "|^" & txtValorAtual
            end if
        end if
        '<- GRAVANDO NOVO LOG 2
	getFields.movenext
	wend
	getFields.close
	set getFields=nothing

	if sysActive=0 and lcase(tableName)="pacientes" then
	    'atualiza a hora do cadastro
	    sqlFields = sqlFields & ", sysDate=NOW()"
	end if
	sql = "update "&tableName&" set "&sqlFields&" where id="&id
	if erro<>"" then
        %>
        new PNotify({
            title: 'ERRO!',
            text: '<%= erro %>',
            type: 'danger',
            delay:2000
        });
        <%
        Response.End
    else
        if TypeName(valorAntigo)<>"Empty" then
            if not valorAntigo.eof then
                if valorAntigo("sysActive")=0 then
                    op="I"
                else
                    op = "E"
                end if
            end if


            logsJsonActive = True
  
            if tableName<>"sys_smsemail" and logsJsonActive=true then 'NOVA VERSÃO DE LOGS EM JSON SOMENTE NESTE(S) ARQUIVO(S)
                call gravaLogs(sql, op, "", "")
            end if     

        end if
        
        if req("Helpdesk") <> "" then
            set dblicense = newConnection("clinic5459", "")
            dblicense.execute(sql)
        else
            if tableName="sys_smsemail" and logsJsonActive=true then 'NOVA VERSÃO DE LOGS EM JSON SOMENTE NESTE(S) ARQUIVO(S)
                call logsJson("SMS Email",sql,"Update","id="&id)
            else
                db.execute(sql)
            end if            
        end if
        
        %>
        gtag('event', '<% if Novo then response.write("new_"&tableName) else response.write("edit_"&tableName) end if %>', {
            'event_category': 'cadastros',
            'event_label': "Botão 'Salvar' clicado.",
        });

        new PNotify({
            title: 'Dados gravados com sucesso.',
            text: '',
            type: 'success',
            delay:500
        });
        <%
        if tableName="pacientes" and sysActive=0 then
        %>
        $('#lMenu .checkStatus > a').css('pointer-events','all');
        $('li.checkStatus').css('cursor','pointer');
        <%    
        end if


        IF session("Franqueador") <> "" and tableName = "sys_financialcompanyunits" and Novo THEN %>
            gerarLicenca(<%=id%>)
        <% END IF %>
        <%

        if ref("cmd")="ReabrirSenha" then
            %>
            callTicket('<%=id%>');
            <%
        end if

    end if

	logColunas = logColunas & "|"
    logValorAnterior = logValorAnterior & "|^"
    logValorNovo = logValorNovo & "|^"
    if logColunas<>"|"then
        if valorAntigo("sysActive")=1 then
            'db_execute("insert into log (I, Operacao, recurso, colunas, valorAnterior, valorAtual, sysUser) values ("&id&", 'E', '"& tableName &"', '"& logColunas &"', '"& rep(logValorAnterior) &"', '"& logValorNovo &"', "&session("User")&")")
        else
            'aqui coloca a data correta de cadastro, mas depois de verificar se por padrão vem tudo com sysDate
          '  db_execute("insert into log (I, Operacao, recurso, colunas, valorAnterior, valorAtual, sysUser) values ("&id&", 'I', '"& tableName &"', '"& logColunas &"', '"& rep(logValorAnterior) &"', '"& logValorNovo &"', "&session("User")&")")
        end if
    end if


    getSubformsSQL = "select * from cliniccentral.sys_resources where mainForm="&getResource("id")
	set getSubforms = db.execute(getSubformsSQL)
	while not getSubforms.EOF
		strSubTipos = ""
		strSubNomes = ""
        getSubFieldsSQL = "select * from cliniccentral.sys_resourcesFields where resourceID="&getSubForms("id")&" and not columnName='"&getSubForms("mainFormColumn")&"'"
        ' response.write(getSubFieldsSQL)
		set getSubFields = db.execute(getSubFieldsSQL)
		while not getSubFields.EOF
			strSubTipos = strSubTipos&"|"&getSubFields("fieldTypeID")
			strSubNomes = strSubNomes&"|"&getSubFields("columnName")
		getSubFields.movenext
		wend
		getSubFields.close
		set getSubFields=nothing

		splSubTipos = split(strSubTipos, "|")
		splSubNomes = split(strSubNomes, "|")

		if lcase(getSubforms("tableName"))<>"pacientesconvenios" then
		    mainFormColumn=getSubForms("mainFormColumn")
		    if isnull(mainFormColumn) then
		        mainFormColumn="id"
		    end if
            'A vacina_serie_dosagem não retorna naturalmente por ser subform de um subform  - Walder Silva
            if getSubforms("tableName") = "vacina_serie_dosagem" and (tableName = "Procedimentos" or tableName = "procedimentos") then
                set regs = db.execute("select * from vacina_serie_dosagem where sysActive=1 and SerieID in (select vs.id from vacina_serie vs join vacina v on v.id = vs.VacinaID where v.ProcedimentoID ="&id&")")
            elseif getSubforms("tableName") = "vacina_serie" and (tableName = "Procedimentos" or tableName = "procedimentos") then
                set regs = db.execute("select * from vacina_serie vs join vacina v on v.id = vs.VacinaID where v.ProcedimentoID ="&id)
            else 
                set regs = db.execute("select * from "&getSubforms("tableName")&" where sysActive=1 and "&mainFormColumn&"="&id)
            end if

			while not regs.EOF
				codeUp = ""
				for j=0 to ubound(splSubTipos)
					if splSubTipos(j)<>"" then
						Valor = ref(splSubNomes(j)&"-"&getSubForms("tableName")&"-"&regs("id"))
						if splSubTipos(j)="6" or splSubTipos(j)="7" or  splSubTipos(j)="25" then
							Valor = treatvalnull(Valor)
						elseif splSubTipos(j)="29"then
						    Valor = treatValNULLFormat(Valor,4)
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
						elseif splSubTipos(j)="8" then
						    CPFCNPJ = replace(replace(replace(Valor,"-",""),".",""),"/","")

						    if len(CPFCNPJ) = 11 then
                                if CalculaCPF(CPFCNPJ)=0 then
                                    %>
                                    new PNotify({
                                        title: 'ERRO AO SALVAR <%=getSubForms("name")%>!',
                                        text: 'CPF "<%=Valor%>" não é válido',
                                        type: 'danger',
                                        delay:2000
                                    });
                                    <%
                                    Response.End
                                end if
						    end if

						    Valor = "'"&Valor&"'"
						else
							Valor = "'"&Valor&"'"
						end if
						if splSubTipos(j)<>"17" then
							codeUp = codeUp&", "& splSubNomes(j)&"="&Valor
                            if splSubTipos(j)="26" then
                                ValorID = ref(splSubNomes(j)&"-"&getSubForms("tableName")&"-"&regs("id") &"-ID")
                                codeUp = codeUp&", "& splSubNomes(j)&"ID = "& treatvalnull( ValorID )
                            end if
						end if
                        if lcase(getSubforms("tableName"))="contratosconvenio" then
                            codeUp = codeUp&", SomenteUnidades='"& ref("SomenteUnidades-"&regs("id")) &"'"
                        end if
					end if
				next

                'Salva vacina_serie_dosagem com parâmetros pré-estabelecidos = Walder Silva
                if lcase(getSubforms("tableName"))="vacina_serie_dosagem" and (tableName = "Procedimentos" or tableName = "procedimentos") then

                    if ref("id-vacina_serie_dosagem")&"" <> "" then
                        if inStr(ref("id-vacina_serie_dosagem"), ", ") > 0 then
                            seriedosagem = split(ref("id-vacina_serie_dosagem"), ", ")

                            for contserie=0 to ubound(seriedosagem)

                                m = seriedosagem(contserie)

                                if ref("PeriodoDias-vacina_serie_dosagem-"&m) = "" then
                                    PeriodoDias = "null"
                                else
                                    PeriodoDias = ref("PeriodoDias-vacina_serie_dosagem-"&m)
                                end if
                                db.execute("update vacina_serie_dosagem set ProdutoID="&ref("ProdutoID-vacina_serie_dosagem-"&m)&", Descricao='"&ref("Descricao-vacina_serie_dosagem-"&m)&"', PeriodoDias="&PeriodoDias&", Ordem='"&ref("Ordem-vacina_serie_dosagem-"&m)&"' where id="&m)
                            next
                        else
                            m = ref("id-vacina_serie_dosagem")

                            if ref("PeriodoDias-vacina_serie_dosagem-"&m) = "" then
                                PeriodoDias = "null"
                            else
                                PeriodoDias = ref("PeriodoDias-vacina_serie_dosagem-"&m)
                            end if

                            db.execute("update vacina_serie_dosagem set ProdutoID="&ref("ProdutoID-vacina_serie_dosagem-"&m)&", Descricao='"&ref("Descricao-vacina_serie_dosagem-"&m)&"', PeriodoDias='"&PeriodoDias&"', Ordem='"&ref("Ordem-vacina_serie_dosagem-"&m)&"' where id="&m)
                        end if
                    end if
                elseif getSubforms("tableName") = "vacina_serie" and (tableName = "Procedimentos" or tableName = "procedimentos") then

                    if ref("id-vacina_serie")&"" <> "" then
                        if inStr(ref("id-vacina_serie"), ", ") > 0 then
                          serie = split(ref("id-vacina_serie"), ", ")

                    for cont=0 to ubound(serie)
                        n = serie(cont)
                        
                                db.execute("update vacina_serie set Titulo='"&ref("Titulo-vacina_serie-"&n)&"', Descricao='"&ref("Descricao-vacina_serie-"&n)&"' where id="&n)
                            next
                        else
                            n = ref("id-vacina_serie")
                            db.execute("update vacina_serie set Titulo='"&ref("Titulo-vacina_serie-"&n)&"', Descricao='"&ref("Descricao-vacina_serie-"&n)&"' where id="&n)
                        end if
                    end if
                else
                    codeUp = "update "&getSubforms("tableName")&" set sysActive=1"&codeUp& " where id="&regs("id")
                    db_execute(codeUp)
                    
                end if

                if lcase(tableName)="produtoskits" and ref("TabelaID")<>"" then
                    ProdutoID = ref("ProdutoID-produtosdokit-"&regs("id"))
                    Codigo = ref("Codigo-produtosdokit-"&regs("id"))
                    TabelaID = ref("TabelaID")
                    if Codigo<>"" and ProdutoID<>"" and ProdutoID<>"0" and TabelaID<>"" then
                        Valor = treatvalzero(ref("Valor-produtosdokit-"&regs("id")))
                        set vca = db.execute("select id from tissprodutostabela tpt where ProdutoID="&ProdutoID&" AND TabelaID="&TabelaID)
                        if vca.eof then
                            db_execute("insert into tissprodutostabela (Codigo, ProdutoID, TabelaID, Valor, sysActive, sysUser) values ('"&Codigo&"', "&ProdutoID&", "&TabelaID&", "&Valor&", 1, "&session("User")&")")
                        else
                            if Valor<>"'0'" then
                                db_execute("update tissprodutostabela set Codigo='"&Codigo&"', Valor="&Valor&", sysUser="&session("User")&" WHERE id="&vca("id"))
                            end if
                        end if
                    end if
                end if

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
                if ref("InputAtualiza")&""<>"" then
                    InputAtualizaArray = split(ref("InputAtualiza"), "_")
                    buiTabelasModelos_id = InputAtualizaArray(0)
                    buiTabelasModelos_c = InputAtualizaArray(1)
                    InputAtualizaSQL = "update buitabelasmodelos set "&buiTabelasModelos_c&"='"&ref(buiTabelasModelos_id&"_"&buiTabelasModelos_c)&"' where id="&buiTabelasModelos_id
                    'response.write(InputAtualizaSQL)
                    db_execute(InputAtualizaSQL)
                else
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
                end if
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
	'if session("banco")="clinic1612" or session("banco")="clinic5868" or session("banco")="clinic3610" or session("banco")="clinic3859" or session("banco")="clinic105" or session("banco")="clinic5491" then
    if getConfig("AlterarNumeroProntuario") = 1 then
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
    new PNotify({
        title: 'ERRO!',
        text: '<%=erro%>',
        type: 'danger'
    });
			<%
		else
			db_execute("update pacientes set idImportado="&ref("Prontuario")&" where id="&id)
		end if
	end if
end if

if lcase(tableName)="procedimentosgrupos" then
    db_execute("update procedimentos set GrupoID=0 where GrupoID="&id)
    if ref("Procedimentos")<>"" then
        splPG = split(ref("Procedimentos"), ", ")
        for ipg=0 to ubound(splPG)
           db_execute("update procedimentos set GrupoID="&id&" where id = '"&replace(splPG(ipg), "|", "")&"'")
'           db_execute("update procedimentos set GrupoID="&id&" where id IN("&replace(ref("Procedimentos"), "|", "")&")")
        next
    end if
end if

if lcase(ref("P"))="tarefas" and req("Helpdesk")=""  then
    call statusTarefas(session("User"), ref("Para"))
end if

if lcase(ref("P"))="profissionais" then
    if ref("Especialidades")<>"" then
        if inStr(ref("Especialidades"), ", ") > 0 then
            spl = split(ref("Especialidades"), ", ")

            for iEspecialidades=0 to ubound(spl)
                n = spl(iEspecialidades)
                db.execute("update profissionaisespecialidades set RQE='"&ref("RQE"&n)&"',EspecialidadeID="&treatvalnull(ref("EspecialidadeID"&n))&", Conselho='"&ref("Conselho"&n)&"', UFConselho='"&ref("UFConselho"&n)&"', DocumentoConselho='"&ref("DocumentoConselho"&n)&"' where id="&n)
            next
        else
            n = ref("Especialidades")
            db.execute("update profissionaisespecialidades set RQE='"&ref("RQE"&n)&"',EspecialidadeID="&treatvalnull(ref("EspecialidadeID"&n))&", Conselho='"&ref("Conselho"&n)&"', UFConselho='"&ref("UFConselho"&n)&"', DocumentoConselho='"&ref("DocumentoConselho"&n)&"' where id="&n)
        end if
    end if
    call odonto()
end if



'on error resume next

    ' vunerabilidade pior ainda
	db_execute("insert into cliniccentral.logprofissionais (dados) values ('"&replace(request.Form(), "'", "''")& "  ---   Usuario: "& session("User") &" --- IP: "& request.ServerVariables("REMOTE_ADDR") &"')")

if sqlAtivoNome<>"" then
%><!--#include file="connectCentral.asp"--><%
    dbc.execute( sqlAtivoNome )
end if
%>
