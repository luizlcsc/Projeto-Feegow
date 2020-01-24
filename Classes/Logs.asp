<%
function createLog(operacao, ID, recurso, colunas, valorAnterior, valorNovo)
    if ID <> "" and recurso <> "" then
        db.execute("INSERT INTO log(Operacao, I, recurso, colunas, valorAnterior, valorAtual, sysUser) VALUES('"&operacao&"', "&ID&", '"&recurso&"', '"&colunas&"', '"&valorAnterior&"', '"&valorNovo&"',"&Session("User")&")")
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

function getLogs(logTable, logId)
    set getLogs = db.execute("SELECT * FROM log WHERE recurso='"&logTable&"' AND I="&treatvalzero(logId))
end function

function renderLogsTable(logTable, logId)
    set LogsSQL = getLogs(logTable, logId)

    if not LogsSQL.eof then
    %>
<button type="button" data-toggle="collapse" data-target="#<%=logTable&logId%>" class="btn btn-default btn-sm"><i class="fa fa-history"></i> Ver logs</button>

<div id="<%=logTable&logId%>" class="collapse">

<table class="table table-striped mt5">
        <tr class="primary">
            <th>Data e hora</th>
            <th>Usuário</th>
            <th>Obs.</th>
            <th>Campo</th>
            <th>Valor Anterior</th>
            <th>Valor Alterado</th>
        </tr>
            <%

            while not LogsSQL.eof

                colunas = LogsSQL("colunas")
                spltCampos = split(colunas, "|")
                spltValorAnterior = split(LogsSQL("valorAnterior"), "|^")
                spltValorAtual = split(LogsSQL("valorAtual"), "|^")

                for i=1 to ubound(spltCampos) - 1

                    campo = spltCampos(i)
%>

        <tr>
            <%
            if i = 1 then
            %>
            <th><%=LogsSQL("DataHora")%></th>
            <th><%=nameInTable(LogsSQL("sysUser"))%></th>
            <th><%=LogsSQL("Obs")%></th>
            <%
            else
            %>
            <td colspan="3"></td>
            <%
            end if
            %>
            <td><%=campo%></td>
            <td><%=spltValorAnterior(i)%></td>
            <td><%=spltValorAtual(i)%></td>
        </tr>
<%
                next
            LogsSQL.movenext
            wend
            LogsSQL.close
            set LogsSQL=nothing
%>
    </table>
</div>
    <%
    end if
end function

function gravaLogs(query, operacaoForce, obs, ColunaPai)
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

        if InStr(tabelas,"|"&recurso&"|") then
            idLog = getLastAdded(recurso)
            aux = split(query, "(")(1)
            colunas = split(aux, ") ")(0)
            colunas = replace(colunas, " ", "")
            colunasQuery = colunas
            colunas = replace(colunas, ",", "|")
            colunas = "|"&colunas&"|"
            record = db.execute("SELECT "&colunasQuery&" FROM "&recurso&" WHERE id = "&idLog)

            valorAtual = "|^"
            valorAnterior = "|^"
            for each x in record
                valorAtual = valorAtual&x&"|^"
                valorAnterior = valorAnterior&"|^"
            next

             db.execute("insert into log (Operacao, I, recurso, colunas, valorAnterior, valorAtual, sysUser, Obs) values ('"&operacao&"', "&idLog&", '"&recurso&"', '"&colunas&"', '"&valorAnterior&"', '"&valorAtual&"', "&session("User")&", '"&obs&"')")
             if(operacaoForce <> "AUTO") then
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

        if InStr(tabelas,"|"&recurso&"|") then
            valores = split(query, " set ")(1)
            valores = split(valores, " where ")(0)
            valores = replace(valores, "|,", "|¬")
            valores = split(valores, ",")
            colunas = "|"
            colunasQuery = ""
            'valorAtual = "|^"
            for each x in valores
                if InStr(x,"=") then
                    colunas = colunas&split(x, "=")(0)&"|"
                    colunasQuery = colunasQuery&split(x, "=")(0)&","
                    'valorAtual = valorAtual&trim(replace(replace(split(x, "=")(1), "'", ""), "NULL", ""))&"|^"
                end if
            next
            colunas = replace(colunas, " ", "")
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
            qtdColunas = db.execute(auxQuery)
            auxQuery = replace(auxQuery, " from", ", id from")
            set record = db.execute(auxQuery)

            contadorDeValores = 0
            For each chave in valores
                contadorDeValores = contadorDeValores + 1
            Next
            'Response.Write("// "&contadorDeValores & "<br>")

            while not record.eof
                valoresAnteriores = "'|^"
                valoresAtuais = "'|^"
                colunas = "|"
                For iLog = 0 To qtdColunas.count-1
                    if InStr(valores(iLog),"=") then
                          txtValorAntigo = record(iLog)&""
                          txtValorAtual = replace(replace(split(valores(iLog), "=")(1), "'", ""), "|¬", "|,")&""

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

                              if(txtValorAntigo <> txtValorAtual and not (txtValorAntigo="" and txtValorAtual="0") and not (txtValorAtual="" and txtValorAntigo="0")) then
                                valoresAnteriores = valoresAnteriores&txtValorAntigo&"|^"
                                colunas = colunas&trim(split(valores(iLog), "=")(0))&"|"
                                valoresAtuais = valoresAtuais&trim(replace(replace(replace(split(valores(iLog), "=")(1), "'", ""), "NULL", ""), "|¬", "|,"))&"|^"
                              end if
                          elseif (isDate(txtValorAntigo) and isDate(txtValorAtual)) then
                              if(FormatDateTime(txtValorAntigo,3) <> FormatDateTime(txtValorAtual,3)) then
                                  valoresAnteriores = valoresAnteriores&txtValorAntigo&"|^"
                                  colunas = colunas&trim(split(valores(iLog), "=")(0))&"|"
                                  valoresAtuais = valoresAtuais&trim(replace(replace(replace(split(valores(iLog), "=")(1), "'", ""), "NULL", ""), "|¬", "|,"))&"|^"
                              end if
                          else
                              if(txtValorAntigo <> txtValorAtual and not (txtValorAntigo="" and txtValorAtual="0") and not (txtValorAtual="" and txtValorAntigo="0")) then
                                valoresAnteriores = valoresAnteriores&txtValorAntigo&"|^"
                                colunas = colunas&trim(split(valores(iLog), "=")(0))&"|"
                                valoresAtuais = valoresAtuais&trim(replace(replace(replace(split(valores(iLog), "=")(1), "'", ""), "NULL", ""), "|¬", "|,"))&"|^"
                              end if
                          end if
                    end if

                Next

                if(colunas <> "|") then
                    if valoresAnteriores = "'|^" then
                        valoresAnteriores = "NULL"
                    else
                        valoresAnteriores = valoresAnteriores&"'"
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
                    db.execute("insert into log (Operacao, I, recurso, colunas, valorAnterior, valorAtual, sysUser, Obs) values ('"&operacao&"', "&record("id")&", '"&recurso&"', '"&colunas&"', "&valoresAnteriores&", "&valoresAtuais&", "&session("User")&", '"&obs&"')")
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
            auxQuery = "select "&colunasQuery&" from "&recurso&" where "&onde
        else
            onde = "true"
            auxQuery = "select "&colunasQuery&" from "&recurso&" where "&onde
        end if

        recurso = split(query, " from ")(1)
        recurso = split(recurso, " where ")(0)
        recurso = LCase(recurso)

        if InStr(tabelas,"|"&recurso&"|") then
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
                db.execute("insert into log (Operacao, I, recurso, colunas, valorAnterior, valorAtual, sysUser, Obs) values ('"&operacao&"', "&res("id")&", '"&recursoTabela&"', '"&colunas&"', '"&valoresAnteriores&"', NULL, "&session("User")&",'"&Obs&"')")
                res.movenext
            wend
        end if
    end if
End function
%>