<!--#include file="connect.asp"-->
<!--#include file="validar.asp"-->
<!--#include file="webhookFuncoes.asp"-->
<%
tableName = ref("P")
id = ref("I")
spl = split(ref(), "&")
Novo=False

set ActiveSQL = db.execute("SELECT sysActive FROM "&tableName&" WHERE id="&id&" LIMIT 1")
if not ActiveSQL.eof then
    if ActiveSQL("sysActive")=0 then
        Novo=True
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
			sqlValue = "'"&ref(getFields("columnName"))&"'"
	    END IF

		if getFields("fieldTypeID")<>17 then
			sqlFields = sqlFields&", `"&getFields("columnName")&"`="&sqlValue
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

	sql = "update "&tableName&" set "&sqlFields&" where id="&id
'	response.Write(sql)
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
        db_execute(sql)
        %>
        new PNotify({
            title: 'Dados gravados com sucesso.',
            text: '',
            type: 'success',
            delay:500
        });
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
            db_execute("insert into log (I, Operacao, recurso, colunas, valorAnterior, valorAtual, sysUser) values ("&id&", 'E', '"& tableName &"', '"& logColunas &"', '"& rep(logValorAnterior) &"', '"& logValorNovo &"', "&session("User")&")")
        else
            'aqui coloca a data correta de cadastro, mas depois de verificar se por padrão vem tudo com sysDate
            db_execute("insert into log (I, Operacao, recurso, colunas, valorAnterior, valorAtual, sysUser) values ("&id&", 'I', '"& tableName &"', '"& logColunas &"', '"& rep(logValorAnterior) &"', '"& logValorNovo &"', "&session("User")&")")
        end if
    end if

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
		    mainFormColumn=getSubForms("mainFormColumn")
		    if isnull(mainFormColumn) then
		        mainFormColumn="id"
		    end if
			set regs = db.execute("select * from "&getSubforms("tableName")&" where sysActive=1 and "&mainFormColumn&"="&id)
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
				codeUp = "update "&getSubforms("tableName")&" set sysActive=1"&codeUp& " where id="&regs("id")
				'response.Write( codeUp&chr(10) )
				db_execute(codeUp)

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

'on error resume next
	db_execute("insert into cliniccentral.logprofissionais (dados) values ('"&replace(ref(), "'", "''")& "  ---   Usuario: "& session("User") &" --- IP: "& request.ServerVariables("REMOTE_ADDR") &"')")
%>
