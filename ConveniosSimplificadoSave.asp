<!--#include file="connect.asp"-->
<!--#include file="validar.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
tableName = "convenios"
id = ref("I")
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
end if

for i=0 to ubound(spl)
	spl2 = split(spl(i), "=")
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
		else
			sqlValue = "'"&ref(getFields("columnName"))&"'"
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
            if getFields("columnName")="CPF" or getFields("columnName")="CNPJ" then
                sqlFields = sqlFields&", `"&getFields("columnName")&"`="&RemoveCaracters(sqlValue,".-/ ")
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
	'response.Write(sql)
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
            call gravaLogs(sql, op, "", "")
        end if

        if req("Helpdesk") <> "" then
            set dblicense = newConnection("clinic5459", "")
            dblicense.execute(sql)
        else
            db.execute(sql)
        end if

        %>
        new PNotify({
            title: 'Dados gravados com sucesso.',
            text: '',
            type: 'success',
            delay:500
        });
        <% IF FALSE AND session("Franqueador") <> "" and tableName = "sys_financialcompanyunits" and Novo THEN %>
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
		splSubTipos = split(strSubTipos, "|")
		splSubNomes = split(strSubNomes, "|")
	    getSubforms.movenext
	wend
	getSubforms.close
	set getSubforms = nothing
	'response.Write("Falta: "&falta)
end if


if lcase(tableName)="procedimentosgrupos" then
    db_execute("update procedimentos set GrupoID=0 where GrupoID="&id)
    if ref("Procedimentos")<>"" then
        splPG = split(ref("Procedimentos"), ", ")
        for ipg=0 to ubound(splPG)
           db_execute("update procedimentos set GrupoID="&id&" where id = '"&replace(splPG(ipg), "|", "")&"'")
        next
    end if
end if

if sqlAtivoNome<>"" then
%><!--#include file="connectCentral.asp"--><%
    dbc.execute( sqlAtivoNome )
end if
%>