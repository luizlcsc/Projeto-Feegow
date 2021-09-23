<%
function createLog(operacao, ID, recurso, colunas, valorAnterior, valorNovo, obs)
    if ID <> "" and recurso <> "" then
        db.execute("INSERT INTO log(Operacao, I, recurso, colunas, valorAnterior, valorAtual, obs, sysUser) VALUES('"&operacao&"', "&ID&", '"&recurso&"', '"&colunas&"', '"&valorAnterior&"', '"&valorNovo&"','"&obs&"','"&Session("User")&"')")
        createLog = true
    else 
        createLog = false
    end if
End function

function logAgendamento(agendamentoId, obs, arx)
'A: Alteracao
'R: remarcacao
'X: exclusao

set AgendamentoLogSQL = db.execute("SELECT PacienteID, ProfissionalID, TipoCompromissoID, Data, Hora, StaID FROM agendamentos WHERE id="&treatvalzero(agendamentoId))

if not AgendamentoLogSQL.eof then
    sqlLog = "INSERT INTO logsmarcacoes (PacienteID, ProfissionalID, ProcedimentoID, Data, Hora, Sta, Usuario, Obs, ARX, ConsultaID, UnidadeID ) VALUES "&_
                 " ("&AgendamentoLogSQL("PacienteID")&", "&AgendamentoLogSQL("ProfissionalID")&", "&AgendamentoLogSQL("TipoCompromissoID")&", "&mydatenull(AgendamentoLogSQL("Data"))&", "&_
                 " "&mytime(AgendamentoLogSQL("Hora"))&", "&AgendamentoLogSQL("StaID")&", "&session("User")&", '"&obs&"', '"&arx&"', "&agendamentoId&","&session("UnidadeID")&")"
    db_execute(sqlLog)
end if

end function

function getLogs(logTable, logId, paiId)
    sqlLogId=""
    if logId<>"" or paiId<>"" then
        sqlLogId = " AND (I="&treatvalzero(logId)&" OR PaiID="&Treatvalzero(paiId)&")"
    end if
    set getLogs = db.execute("SELECT * FROM log WHERE recurso='"&logTable&"' "&sqlLogId&" ORDER BY DataHora DESC LIMIT 25")
end function

function getLogTableHtml(LogsSQL)
    %>
    <table class="table table-striped mt5">
            <tr class="primary">
                <th>#</th>
                <th width="18%">Tipo</th>
                <th>Data e hora</th>
                <th>Usuário</th>
                <th>Detalhes</th>
                <th>Campo</th>
                <th>Valor Anterior</th>
                <th>Valor Alterado</th>
            </tr>
                <%

                while not LogsSQL.eof

                    operacao = LogsSQL("operacao")
                    operacaoStr = LogsSQL("operacao")
                    colunas = LogsSQL("colunas")
                    spltCampos = split(colunas, "|")
                    spltValorAnterior = split(LogsSQL("valorAnterior")&"", "|^")
                    valorAtual = LogsSQL("valorAtual")
                    spltValorAtual = split(valorAtual&"", "|^")

                    if operacao="X" then
                        operacaoStr = "Exclusão"
                        operacaoIcon = "trash"
                        operacaoClass = "danger"
                    elseif operacao="E" then
                        operacaoStr="Edição"
                        operacaoIcon = "edit"
                        operacaoClass = "primary"
                    elseif operacao="I" then
                        operacaoStr="Inserção"
                        operacaoIcon = "plus"
                        operacaoClass = "success"
                    end if

                    for i=1 to ubound(spltCampos) - 1

                        campo = spltCampos(i)
    %>

            <tr>
                <%
                if i = 1 then
                %>
                <th><code>#<%=LogsSQL("id")%></code></th>
                <th><span class="label label-<%=operacaoClass%>"><i class="far fa-<%=OperacaoIcon%>"></i> <%=operacaoStr%></span></th>
                <th><%=LogsSQL("DataHora")%></th>
                <th><%=nameInTable(LogsSQL("sysUser"))%></th>
                <th><%=LogsSQL("Obs")%></th>
                <%
                else
                %>
                <td colspan="5"></td>
                <%
                end if
                %>
                <td style="background-color: #fff3cf; font-weight: 600; border-color: #efd79d"><%=campo%></td>
                <td style="background-color: #fff3cf; font-weight: 600; border-color: #efd79d"><%=spltValorAnterior(i)%></td>
                <td style="background-color: #fff3cf; font-weight: 600; border-color: #efd79d"><% if not isnull(valorAtual) then response.write(spltValorAtual(i)) end if %></td>
            </tr>
    <%
                    next
                LogsSQL.movenext
                wend
                LogsSQL.close
                set LogsSQL=nothing
    %>
        </table>

    <%
end function

function renderLogsTable(logTable, logId, paiId)
    set LogsSQL = getLogs(logTable, logId, paiId)

    if not LogsSQL.eof then
    %>
<button type="button" data-toggle="collapse" data-target="#<%=logTable&logId%>" class="btn btn-default btn-sm"><i class="far fa-history"></i> Ver logs</button>

<div id="<%=logTable&logId%>" class="collapse">
<%
call getLogTableHtml(LogsSQL)
%>
</div>
    <%
    end if
end function


function gravaLogs(query, operacaoForce, obs, ColunaPai)
        Err.Clear
        On Error Resume Next
        a = gravaLogsResumeNext(query, operacaoForce, obs, ColunaPai)
        On Error GoTo 0
end function


function gravaLogsResumeNext(query, operacaoForce, obs, ColunaPai)
    'tabelas = "|tissguiaconsulta|tissguiasadt|tissguiahonorarios|tissguiainternacao|tisslotes|tissprocedimentossadt|tissprofissionaissadt|tissprocedimentoshonorarios|tissprofissionaishonorarios|tissprocedimentosinternacao|pacientes|profissionais|convenios|contratosconvenio|empresa|sys_financialcompanyunits|tissprocedimentostabela|tissprocedimentosvalores|tissprocedimentosvaloresplanos|contratadoexternoconvenios|tissguiaanexa|rateiorateios|itensinvoice|sys_financialmovement|arquivos|sys_financialinvoices|invoice_rateio|propostas|tissguiasinvoice|agendamentos|chamadasagendamentos|agendamentosrepeticoes|assfixalocalxprofissional|propostas|itensproposta|pacientespropostasformas|pacientespropostasoutros|Contatos|"
    tabelas = "|tarefas|sys_financialcompanyunits|sys_financialinvoices|itensinvoice|sys_financialmovement|sys_financialIssuedChecks|sys_users|regraspermissoes|agendamentos|"
    tabelas = LCase(tabelas)
    tipoLog = split(query, " ")(0)
    tipoLog = LCase(tipoLog)

    query = replace(query, " WHERE ", " where ")
    query = replace(query, " FROM ", " from ")
    query = replace(query, " SET ", " set ")

    if (tipoLog="insert") then
        if(operacaoForce <> "AUTO") then
            operacao = operacaoForce
        else
            operacao = "I"
        end if
        recurso = split(query, " ")(2)
        recurso = trim(LCase(recurso))

        if InStr(tabelas,"|"&recurso&"|") or true then
            idLog = getLastAdded(recurso)
            aux = split(query, "(")(1)
            colunas = split(aux, ") ")(0)
            colunas = replace(colunas, " ", "")
            colunasQuery = colunas
            colunas = replace(colunas, ",", "|")
            colunas = "|"&colunas&"|"

            if ColunaPai&""<>"" then
                colunasQuery = colunasQuery &",`"&ColunaPai&"`"
            end if

            set record = db.execute("SELECT "&colunasQuery&" FROM "&recurso&" WHERE id = "&idLog)

            valorAtual = "|^"
            valorAnterior = "|^"
            if not record.eof then

                if ColunaPai&""<>"" then
                    ValorPai = record(ColunaPai)
                end if
                record = db.execute("SELECT "&colunasQuery&" FROM "&recurso&" WHERE id = "&idLog)

                for each x in record
                    valorAtual = valorAtual&""&x&""&"|^"
                    valorAnterior = valorAnterior&"|^"
                next


             end if
             db.execute("insert into log (Operacao, I, recurso, colunas, valorAnterior, valorAtual, sysUser, Obs, PaiID, ColunaPai) values ('"&operacao&"', "&idLog&", '"&recurso&"', '"&colunas&"', '"&valorAnterior&"', '"&valorAtual&"', "&session("User")&", '"&obs&"', "&treatvalnull(ValorPai)&",'"&ColunaPai&"')")
              if operacaoForce <> "AUTO" then
                 db.execute(query)
              end if

        end if
    elseif (tipoLog="update") then
        if(operacaoForce <> "AUTO") then
            operacao = operacaoForce
        else
            operacao = "E"
        end if
        recurso = split(query, " ")(1)
        recurso = trim(LCase(recurso))

        if InStr(tabelas,"|"&recurso&"|") or true then
            valores = split(query, " set ")(1)
            valores = split(valores, " where ")(0)
            valoresStr = replace(valores, "|,", "|¬")
            if ColunaPai&""<>"" then
                valores = valores &", "&ColunaPai&"='VALOR_PAI'"
            end if

            valores = split(valoresStr, ",")
            colunas = "|"
            colunasQuery = ""
            'valorAtual = "|^"
            for each x in valores
                if InStr(x,"=") then
                    vv = split(x, "=")(0)

                    'if len(vv)<=30 then
                        colunas = colunas&vv&"|"
                        colunasQuery = colunasQuery&vv&","
                        'valorAtual = valorAtual&trim(replace(replace(split(x, "=")(1), "'", ""), "NULL", ""))&"|^"
                    'end if
                end if
            next
            colunas = replace(colunas, " ", "")

            if ColunaPai&""<>"" then
                colunasQuery = colunasQuery &"`"&ColunaPai&"`"
            end if
            colunasQuery = replace(colunasQuery, " ,", "")


            recursoAux = recurso
            if InStr(LCase(query),"left join") then
                recursoAux = split(query, " ")(1)&" "&split(query, " ")(2)
            end if

            if InStr(query,"where") then
                onde = split(query, " where ")
                ondeAux = onde(UBound(onde))
                onde = ondeAux
                auxQuery = "select "&colunasQuery&" from "&recursoAux&" where "&onde
            else
                onde = "true"
                auxQuery = "select "&colunasQuery&" from "&recursoAux&" where "&onde
            end if

            auxQuery = "select "&colunasQuery&" from "&recursoAux&" where "&onde
            auxQuery = replace(auxQuery, ", from", " from")

'quando edita um html esta dando erro: modelos de atestados; impressos etc
            qtdColunas = db.execute(auxQuery)

            auxQuery = replace(auxQuery, " from", ", id from")
            set record = db.execute(auxQuery)

            contadorDeValores = 0
            For each chave in valores
                contadorDeValores = contadorDeValores + 1
            Next
            'Response.Write("// "&contadorDeValores & "<br>")

            while not record.eof
                if ColunaPai&""<>"" then
                    PaiID = record(ColunaPai)

                    if instr(valoresStr,"VALOR_PAI")>0 then
                        valores = split(replace(valoresStr, "VALOR_PAI", PaiID),",")
                    end if
                end if

                valoresAnteriores = ""
                valoresAtuais = "'|^"
                colunas = "|"
                For iLog = 0 To qtdColunas.count-1

                    if iLog > ubound(valores) then
                        col = ""
                    else

                        col = replace(valores(iLog),"`","")
                    end if
                    if InStr(col,"=") then
                          txtValorAntigo = record(iLog)&""
                          vv = split(col, "=")(0)
                          txtValorAtual = replace(replace(split(col, "=")(1), "'", ""), "|¬", "|,")&""

                          if IsDate(txtValorAtual) and (InStr(txtValorAtual, "-") <> 0) then
                            txtValorAtual = CDate(txtValorAtual)&""
                          end if
                          if txtValorAtual = "NULL" then
                            txtValorAtual = ""
                          end if


                          if (isnumeric(txtValorAntigo) and isnumeric(txtValorAtual)) then
                              txtValorAtual = trim(replace(txtValorAtual, ".", ","))

                              if not(InStr(txtValorAntigo,",")) AND InStr(txtValorAtual,",") then
                                  txtValorAntigo = txtValorAntigo&",00"
                              end if

                              if InStr(txtValorAntigo,",") then
                                decimais = split(txtValorAntigo,",")
                                if len(decimais(1)) = 1 then
                                    txtValorAntigo = txtValorAntigo&"0"
                                end if
                              end if

                              if(trim(txtValorAntigo) <> trim(txtValorAtual) and not (txtValorAntigo="" and txtValorAtual="0") and not (txtValorAtual="" and txtValorAntigo="0")) and (treatvalzero(txtValorAntigo) <> treatvalzero(txtValorAtual)) then

                                valoresAnteriores = valoresAnteriores&txtValorAntigo&"|^"
                                colunas = colunas&trim(vv)&"|"
                                valoresAtuais = valoresAtuais&trim(replace(replace(replace(split(col, "=")(1), "'", ""), "NULL", ""), "|¬", "|,"))&"|^"
                              end if
                          elseif (isDate(txtValorAntigo) and isDate(txtValorAtual)) then
                              if(FormatDateTime(txtValorAntigo,3) <> FormatDateTime(txtValorAtual,3)) then
                                  valoresAnteriores = valoresAnteriores&txtValorAntigo&"|^"
                                  colunas = colunas&trim(vv)&"|"
                                  valoresAtuais = valoresAtuais&trim(replace(replace(replace(split(col, "=")(1), "'", ""), "NULL", ""), "|¬", "|,"))&"|^"
                              end if
                          else
                              if(trim(txtValorAntigo)&"" <> trim(txtValorAtual)&"" and not (txtValorAntigo="" and txtValorAtual="0") and not (txtValorAtual="" and txtValorAntigo="0"))  then
                                valoresAnteriores = valoresAnteriores&txtValorAntigo&"|^"
                                colunas = colunas&trim(vv)&"|"

                                valoresAtuais = valoresAtuais&trim(replace(replace(replace(split(col, "=")(1), "'", ""), "NULL", ""), "|¬", "|,"))&"|^"
                              end if
                          end if

                    end if
                Next


                if(colunas <> "|") then
                    if valoresAnteriores = "" then
                        valoresAnteriores = "NULL"
                    else
                        valoresAnteriores = replace(valoresAnteriores, "'" , "\'")

                        valoresAnteriores = "'|^"&valoresAnteriores&"'"
                        'valoresAnteriores = replace(valoresAnteriores, "||", "|")
                    end if
                    if valoresAtuais = "'|^" then
                        valoresAtuais = "NULL"
                    else
                        valoresAtuais = valoresAtuais&"'"
                        'valoresAtuais = replace(valoresAtuais, "||", "|")
                    end if
                    if(operacaoForce <> "AUTO") then
                        db.execute(query)
                    end if
                    db.execute("insert into log (Operacao, I, recurso, colunas, valorAnterior, valorAtual, sysUser, Obs, PaiID, ColunaPai) values ('"&operacao&"', "&record("id")&", '"&recurso&"', '"&colunas&"', "&valoresAnteriores&", "&valoresAtuais&", "&session("User")&", '"&obs&"', "&treatvalnull(PaiID)&", '"&ColunaPai&"')")
                 end if
                record.movenext
            wend
        end if
    elseif (tipoLog="delete") then
        if(operacaoForce <> "AUTO") then
            operacao = operacaoForce
        else
            operacao = "X"
        end if

        if InStr(query,"where") then
            onde = split(query, " where ")
            ondeAux = onde(UBound(onde))
            onde = ondeAux
        else
            onde = "true"
        end if

        recurso = split(query, " from ")(1)
        recurso = split(recurso, " where ")(0)
        recurso = LCase(recurso)

        if InStr(tabelas,"|"&recurso&"|") or true then
            recursoTabela = split(recurso, " ")(0)

            set colunasRs = db.execute("select column_name from information_schema.columns c where table_name = '"&recursoTabela&"' and c.table_schema = '"&session("Banco")&"' and c.column_name <> 'id'")
            colunas = "|"
            while not colunasRs.eof
                colunas = colunas&colunasRs("column_name")&"|"
                colunasRs.movenext
            wend
            colunasRs.close
            set colunasRs = nothing

            set res = db.execute("select * from "&recurso&" where "&onde)
            'set res = db.execute("select * from "&recurso&" where true")
            while not res.eof

                if ColunaPai&""<>"" then
                    ValorPai = res(ColunaPai)
                end if
                valoresAnteriores = "|^"
                set colunasRs = db.execute("select column_name from information_schema.columns c where table_name = '"&recurso&"' and c.table_schema = '"&session("Banco")&"' and c.column_name <> 'id'")
                while not colunasRs.eof
                    set valoresRs = db.execute("select `"&colunasRs("column_name")&"` from "&recursoTabela&" where id = "&res("id"))
                    valoresAnteriores = valoresAnteriores&valoresRs(0)&"|^"
                    colunasRs.movenext
                wend
                colunasRs.close
                set colunasRs = nothing
                if(operacaoForce <> "AUTO") then
                   db.execute(query)
                end if
                db.execute("insert into log (Operacao, I, recurso, colunas, valorAnterior, valorAtual, sysUser, Obs, PaiID, ColunaPai) values ('"&operacao&"', "&res("id")&", '"&recursoTabela&"', '"&colunas&"', '"&valoresAnteriores&"', NULL, "&session("User")&",'"&Obs&"', "&treatvalnull(ValorPai)&",'"&ColunaPai&"')")
                res.movenext
            wend
        end if
    end if
End function

function dadosCadastro(nomeTabela, idTabela)
    set DadosSQL = db.execute("SELECT sysActive, sysUser from `"&nomeTabela&"` WHERE id="&idTabela)

    mensagemCadastro = "<code>#"&idTabela&"</code>  Cadastrado por "&nameInTable(DadosSQL("sysUser"))

    dadosCadastro = mensagemCadastro
end function
%>