<%
function agendaUnificada(tipoAgendamento, agendamentoId, profissionalId)
    
    licencaOrigem = replace(session("Banco"), "clinic", "")

    if agendamentoId <> "0" then

        ' PESQUISANDO AGENDAMENTOS
        agendamentoUnificadoSQL = "SELECT a.id, a.StaID, a.`Data`, a.Tempo, TIME_FORMAT(a.Hora, '%H:%i') AS HoraDe, TIME_FORMAT(a.HoraFinal, '%H:%i:%s') AS HoraA, a.ProfissionalID, a.NomePaciente, a.sysUser, p.NomeProfissional FROM agendamentos a "&_
        " LEFT JOIN profissionais p ON p.id = a.ProfissionalID "&_
        " WHERE a.id IN ("&agendamentoId&")"

        set agendamentoUnificado = db.execute(agendamentoUnificadoSQL)

        profissionalAgendamento = agendamentoUnificado("ProfissionalID")

        if not agendamentoUnificado.EOF then

            ' VALIDANDO PROFISSIONAL
            if profissionalId = 0 then
                profissionalId = profissionalAgendamento
            end if

            ' PESQUISANDO LICENÇAS VINCULADAS MESMO PROFISSIONAL AGENDAMENTO
            licencasVinculadasSql = "SELECT * FROM cliniccentral.licencasprofissionaisvinculados "&_
                                    " WHERE sysActive = 1 AND profissionalIDMae IN "&_
                                    " (SELECT profissionalIDMae FROM cliniccentral.licencasprofissionaisvinculados "&_
                                    " WHERE sysActive = 1 AND profissionalIDMae = "&profissionalAgendamento&" OR profissionalIDFilho = "&profissionalAgendamento&")"

            set licencasVinculadas = db.execute(licencasVinculadasSql)

            if not licencasVinculadas.EOF then
                profissionalAgendamentoMae = licencasVinculadas("profissionalIDMae")
                profissionalAgendamentoFilho = licencasVinculadas("profissionalIDFilho")
                vinculoProfissionalAgendamento = 1
            else
                vinculoProfissionalAgendamento = 0
            end if

        end if
    end if

    ' PESQUISANDO LICENÇAS VINCULADAS DIFERENTE PROFISSIONAL DO AGENDAMENTO
    profissionalIdSql = "SELECT * FROM cliniccentral.licencasprofissionaisvinculados "&_
                            " WHERE sysActive = 1 AND profissionalIDMae IN "&_
                            " (SELECT profissionalIDMae FROM cliniccentral.licencasprofissionaisvinculados "&_
                            " WHERE sysActive = 1 AND profissionalIDMae = "&profissionalId&" OR profissionalIDFilho = "&profissionalId&")"

    set profissionalIdDiferente = db.execute(profissionalIdSql)

    if not profissionalIdDiferente.EOF then
        profissionalAtualMae = profissionalIdDiferente("profissionalIDMae")
        profissionalAtualFilho = profissionalIdDiferente("profissionalIDFilho")
        vinculoProfissionalEnviado = 1
    else
        vinculoProfissionalEnviado = 0
    end if

    select case tipoAgendamento

        case "vincular" ' TRATAMENTO DE VINCULO DA LICENÇA

            ' PESQUISANDO LICENÇA QUE ESTÁ SENDO VINCULADA
            licencaVinculadaSql = "SELECT * FROM cliniccentral.licencasprofissionaisvinculados "&_
                                    " WHERE sysActive = 1 AND profissionalIDMae IN "&_
                                    " (SELECT profissionalIDMae FROM cliniccentral.licencasprofissionaisvinculados "&_
                                    " WHERE sysActive = 1 AND profissionalIDMae = "&profissionalId&" OR profissionalIDFilho = "&profissionalId&")"

            set licencaVinculada = db.execute(licencaVinculadaSql)

            while not licencaVinculada.EOF

                if CInt(profissionalId) = CInt(licencaVinculada("profissionalIdFilho")) then

                    licencaIdFilho = licencaVinculada("licencaIdFilho")
                    licencaIdMae = licencaVinculada("licencaIdMae")
                    profissionalIdMae = licencaVinculada("profissionalIdMae")

                    ' PESQUISANDO AGENDAMENTOS QUE ESTÁ SENDO VINCULADA PARA BLOQUEAR NAS LICENÇA MÃE E FILHO JÁ EXISTENTES COM VINCULO
                    queryAgendamentoSQL = "SELECT a.id, a.StaID, a.`Data`, a.Tempo, TIME_FORMAT(a.Hora, '%H:%i') AS HoraDe, TIME_FORMAT(a.HoraFinal, '%H:%i:%s') AS HoraA, a.ProfissionalID, a.NomePaciente, a.sysUser, p.NomeProfissional FROM clinic"&licencaIdFilho&".agendamentos a "&_
                    " LEFT JOIN profissionais p ON p.id = a.ProfissionalID "&_
                    " WHERE a.ProfissionalID = "&profissionalId&" AND Data>=CURDATE()"
                
                end if

                licencaVinculada.movenext
            wend
            licencaVinculada.close
            set licencaVinculada=nothing

            set queryAgendamento = db.execute(queryAgendamentoSQL)

            if not queryAgendamento.EOF then
                call insertAgendaUnificada(tipoAgendamento, licencaIdFilho, profissionalIdDiferente, queryAgendamento)
            end if

        case "desvincular" ' TRATAMENTO DE DESVINCULO DA LICENÇA

            ' PESQUISANDO LICENÇAS VINCULADAS DIFERENTE PROFISSIONAL DO AGENDAMENTO
            licencaVinculadaSql = "SELECT * FROM cliniccentral.licencasprofissionaisvinculados "&_
                                    " WHERE sysActive = 1 AND profissionalIDMae IN "&_
                                    " (SELECT profissionalIDMae FROM cliniccentral.licencasprofissionaisvinculados "&_
                                    " WHERE sysActive = 1 AND profissionalIDMae = "&profissionalId&" OR profissionalIDFilho = "&profissionalId&")"
            
            set licencaVinculada = db.execute(licencaVinculadaSql)
            if not licencaVinculada.eof then
                'DESVINCULA O PROFISSIONAL DA LICENÇA
                qProfissionalVinculadoUpdateSQL = "UPDATE `cliniccentral`.`licencasprofissionaisvinculados` SET `sysActive`=-1 "&chr(13)&_
                             "WHERE LicencaIDMae="&replace(session("Banco"),"clinic","")&" AND profissionalIDFilho="&profissionalId
                db.execute(qProfissionalVinculadoUpdateSQL)

                while not licencaVinculada.EOF
                

                    if CInt(profissionalId) = CInt(licencaVinculada("profissionalIdFilho")) then

                        licencaIdFilho = licencaVinculada("licencaIdFilho")
                        licencaIdMae = licencaVinculada("licencaIdMae")
                        profissionalIdMae = licencaVinculada("profissionalIdMae")

                        ' PESQUISANDO AGENDAMENTOS DA LICENÇA FILHO
                        agendamentoUnificadoSQL = "SELECT GROUP_CONCAT(a.id) AS id FROM clinic"&licencaIdFilho&".agendamentos a "&_
                        " LEFT JOIN profissionais p ON p.id = a.ProfissionalID "&_
                        " WHERE a.ProfissionalID = "&profissionalId&" AND Data>=CURDATE()"
                    
                    end if

                    licencaVinculada.movenext
                wend
                licencaVinculada.close
                set licencaVinculada=nothing
            end if
            set agendamentoUnificado = db.execute(agendamentoUnificadoSQL)

            agendamentoId = agendamentoUnificado("id")

        
            if agendamentoId&"" <> "" then
                call deleteAgendaUnificada(tipoAgendamento, licencaIdFilho, profissionalIdDiferente, agendamentoId)
            end if

            acaoErro = false
            desvinculoSucesso = true
 
        case "insert" ' TRATAMENTO DE INSERT NOVO AGENDAMENTO, REPETIÇÃO, FILA DE ESPERA
            if not licencasVinculadas.EOF then
                if vinculoProfissionalAgendamento = 1 and vinculoProfissionalEnviado = 1 then

                    if CInt(profissionalAgendamento) = CInt(profissionalId) then
                        call insertAgendaUnificada(tipoAgendamento, licencaOrigem, licencasVinculadas, agendamentoUnificado)
                    else
                        call insertAgendaUnificada(tipoAgendamento, licencaOrigem, profissionalIdDiferente, agendamentoUnificado)
                    end if

                elseif vinculoProfissionalAgendamento = 1 and vinculoProfissionalEnviado = 0 then
                    call insertAgendaUnificada(tipoAgendamento, licencaOrigem, licencasVinculadas, agendamentoUnificado)
                end if

            elseif vinculoProfissionalAgendamento = 0 and vinculoProfissionalEnviado = 1 then
                call insertAgendaUnificada(tipoAgendamento, licencaOrigem, profissionalIdDiferente, agendamentoUnificado)
            end if

        case "update" ' TRATAMENTO DE UPDATE DE BLOQUEIO

            if not licencasVinculadas.EOF then

                if CInt(agendamentoUnificado("StaID")) = 11 or CInt(agendamentoUnificado("StaID")) = 22 then
                    call insertAgendaUnificada("insert", licencaOrigem, licencasVinculadas, agendamentoUnificado)
                else
                    if vinculoProfissionalAgendamento = 1 and vinculoProfissionalEnviado = 1 then

                        if CInt(profissionalAgendamento) = CInt(profissionalId) then
                            call updateAgendaUnificada(licencaOrigem, licencasVinculadas, agendamentoUnificado)
                        else
                            call deleteAgendaUnificada("delete", licencaOrigem, profissionalIdDiferente, agendamentoId)
                            call insertAgendaUnificada("insert", licencaOrigem, licencasVinculadas, agendamentoUnificado)
                        end if
                    
                    elseif vinculoProfissionalAgendamento = 1 and vinculoProfissionalEnviado = 0 then
                        call insertAgendaUnificada("insert", licencaOrigem, licencasVinculadas, agendamentoUnificado)
                    end if
                end if

            else
                if vinculoProfissionalAgendamento = 0 and vinculoProfissionalEnviado = 1 then
                    call deleteAgendaUnificada("delete", licencaOrigem, profissionalIdDiferente, agendamentoId)
                end if
            end if

        case "delete" ' TRATAMENTO DE DELEÇÃO DO BLOQUEIO
            if not licencasVinculadas.EOF then
                call deleteAgendaUnificada(tipoAgendamento, licencaOrigem, licencasVinculadas, agendamentoId)
            end if
    end select
end function

function updateAgendaUnificada(licencaOrigem, queryLicencas, queryAgendamento)

        updateMae = 0
        
        ' ALTERANDO BLOQUEIO
        while not queryLicencas.EOF
        
            bloqueioLicencaMae = 0
            
            licencaMae = queryLicencas("licencaIdMae")
            profissionalIdMae = queryLicencas("profissionalIDMae")
            profissionalIdFilho = queryLicencas("profissionalIDFilho")

            ' DADOS DE AGENDAMENTOS
            while not queryAgendamento.EOF

                if queryAgendamento("Tempo") = "" then
                    calcTempo = 1
                    horaAte = DateAdd("n",calcTempo,queryAgendamento("HoraDe"))
                else
                    horaAte = DateAdd("n",queryAgendamento("Tempo"),queryAgendamento("HoraDe"))
                end if

                'ALTERANDO BLOQUEIO LICENÇA MAE
                if CInt(licencaMae) <> CInt(licencaOrigem) and updateMae = 0 then

                    updateSql = "UPDATE clinic"&licencaMae&".compromissos SET "&_
                                " ProfissionalID = "&profissionalIdMae&", DataDe = '"&mydate(queryAgendamento("Data"))&"', DataA = '"&mydate(queryAgendamento("Data"))&"', diasSemana = "&weekday(mydate(queryAgendamento("Data")))&", HoraDe = '"&queryAgendamento("HoraDe")&"', HoraA = '"&horaAte&"'"&_
                                " WHERE AgendamentoIDMae = "&queryAgendamento("id")

                    db.execute(updateSql)

                    bloqueioLicencaMae = 1
                end if

                ' ALTERANDO BLOQUEIO EM TODAS AS LICENÇAS FILHO QUANDO AGENDAMENTO É REALIZADO NA MAE
                if CInt(licencaMae) = CInt(licencaOrigem) then

                    ' ALTERANDO BLOQUEIO LICENCA FILHO
                    updateSql = "UPDATE clinic"&queryLicencas("licencaIdFilho")&".compromissos SET "&_
                                " ProfissionalID = "&profissionalIdFilho&", DataDe = '"&mydate(queryAgendamento("Data"))&"', DataA = '"&mydate(queryAgendamento("Data"))&"', diasSemana = "&weekday(mydate(queryAgendamento("Data")))&", HoraDe = '"&queryAgendamento("HoraDe")&"', HoraA = '"&horaAte&"'"&_
                                " WHERE AgendamentoIDMae = "&queryAgendamento("id")

                    db.execute(updateSql)
                
                else

                    ' ALTERANDO BLOQUEIO EM TODAS AS LICENÇAS FILHO
                    if CInt(queryLicencas("licencaIdFilho")) <> CInt(licencaOrigem) then

                        ' ALTERANDO BLOQUEIO LICENCA FILHO
                        updateSql = "UPDATE clinic"&queryLicencas("licencaIdFilho")&".compromissos SET "&_
                                    " ProfissionalID = "&profissionalIdFilho&", DataDe = '"&mydate(queryAgendamento("Data"))&"', DataA = '"&mydate(queryAgendamento("Data"))&"', diasSemana = "&weekday(mydate(queryAgendamento("Data")))&", HoraDe = '"&queryAgendamento("HoraDe")&"', HoraA = '"&horaAte&"'"&_
                                    " WHERE AgendamentoIDMae = "&queryAgendamento("id")

                        db.execute(updateSql)
                    end if
                end if
                queryAgendamento.movenext
            wend
            queryAgendamento.movefirst

            if bloqueioLicencaMae = 1 then
                updateMae = 1
            end if

            queryLicencas.movenext
        wend
        queryLicencas.close
        queryAgendamento.close
        set queryAgendamento=nothing
        set queryLicencas=nothing

end function

function deleteAgendaUnificada(tipoAgendamento, licencaOrigem, queryLicencas, agendamentoId)

    ' DELETANDO BLOQUEIO
    while not queryLicencas.EOF

        licencaMae = queryLicencas("licencaIdMae")

        ' DELETANDO O BLOQUEIO LICENÇA MAE
        if (CInt(licencaMae) <> CInt(licencaOrigem) or tipoAgendamento = "desvincular") then

            if agendamentoId&"" <> "" then
                delSql = "DELETE FROM clinic"&licencaMae&".compromissos "&_
                            " WHERE AgendamentoIDMae IN("&agendamentoId&")"

                db.execute(delSql)
            end if
        end if

        if agendamentoId&"" <> "" then
            ' DELETANDO BLOQUEIO OUTRAS LICENCAS FILHO VINCULADASS
            delSql = "DELETE FROM clinic"&queryLicencas("licencaIdFilho")&".compromissos "&_
                        " WHERE AgendamentoIDMae IN("&agendamentoId&")"

            db.execute(delSql)
        end if

        queryLicencas.movenext
    wend

    ' RETIRANDO OS BLOQUEIOS DA LICENCA MAE NO MOMENTO QUE DESVINCULA O PROFISSIONAL
    if tipoAgendamento = "desvincular" then

        queryLicencas.movefirst
        while not queryLicencas.EOF

            ' PESQUISANDO AGENDAMENTOS DA LICENÇA MAE
            agendamentoUnificadoSQL = "SELECT GROUP_CONCAT(a.id) AS id FROM clinic"&licencaIdMae&".agendamentos a "&_
            " LEFT JOIN profissionais p ON p.id = a.ProfissionalID "&_
            " WHERE a.ProfissionalID = "&profissionalIdMae&" AND Data>=CURDATE()"

            set agendamentoUnificado = db.execute(agendamentoUnificadoSQL)

            ' VERIFICANDO SE EXISTE AGENDAMENTO
            if not agendamentoUnificado.EOF then

                if agendamentoUnificado("id")&"" <> "" then
                    ' DELETANDO BLOQUEIO LICENCA FILHO
                    delSql = "DELETE FROM clinic"&queryLicencas("licencaIdFilho")&".compromissos "&_
                                " WHERE AgendamentoIDMae IN("&agendamentoUnificado("id")&")"

                    db.execute(delSql)
                end if

            end if
            queryLicencas.movenext
        wend
        queryLicencas.close
        set queryLicencas=nothing
    else
        queryLicencas.close
        set queryLicencas=nothing
    end if

end function

function insertAgendaUnificada(tipoAgendamento, licencaOrigem, queryLicencas, queryAgendamento)

    ' INSERINDO BLOQUEIO
    insertMae = 0

    while not queryLicencas.EOF

        bloqueioLicencaMae = 0

        licencaMae = queryLicencas("licencaIdMae")
        profissionalIdMae = queryLicencas("profissionalIDMae")
        profissionalIdFilho = queryLicencas("profissionalIdFilho")

        ' DADOS DE AGENDAMENTOS
        while not queryAgendamento.EOF

            if queryAgendamento("Tempo") = "" then
                calcTempo = 1
                horaAte = DateAdd("n",calcTempo,queryAgendamento("HoraDe"))
            else
                horaAte = DateAdd("n",queryAgendamento("Tempo"),queryAgendamento("HoraDe"))
            end if
            
            if CInt(licencaMae) <> CInt(licencaOrigem) then
                titulo = "ATENDIMENTO PARTICULAR"
                descricao = "Bloqueio agenda unificada para o paciente "&queryAgendamento("NomePaciente")&" na licença "&licencaOrigem
            else
                titulo = "ATENDIMENTO INTEGRADORA"
                descricao = "Bloqueio agenda unificada para o paciente "&queryAgendamento("NomePaciente")&" na licença "&licencaMae
            end if

            ' INSERINDO BLOQUEIO NA LICENÇA MÃE
            if (CInt(licencaMae) <> CInt(licencaOrigem) or tipoAgendamento = "vincular") and insertMae = 0 then

                insertSql = "INSERT INTO clinic"&licencaMae&".compromissos (AgendamentoIDMae, LicencaIDMae, DataDe, DataA, Data, HoraDe, HoraA, DiasSemana, ProfissionalID, Usuario, Titulo, Descricao) "&_
                        " VALUE "&_
                        "("&queryAgendamento("id")&", "&licencaOrigem&", '"&mydate(queryAgendamento("Data"))&"', '"&mydate(queryAgendamento("Data"))&"', '"&now()&"', '"&queryAgendamento("HoraDe")&"', '"&horaAte&"','"&weekday(mydate(queryAgendamento("Data")))&"', "&profissionalIdMae&", "&queryAgendamento("sysUser")&", '"&titulo&"', '"&descricao&"')"

                db.execute(insertSql)

                bloqueioLicencaMae = 1
            end if

            ' INSERINDO BLOQUEIO NAS LICENÇAS FILHOS QUANDO A ORIGEM É A MAE
            if (CInt(licencaMae) = CInt(licencaOrigem)) then

                insertSql = "INSERT INTO clinic"&queryLicencas("licencaIdFilho")&".compromissos (AgendamentoIDMae, LicencaIDMae, DataDe, DataA, Data, HoraDe, HoraA, DiasSemana, ProfissionalID, Usuario, Titulo, Descricao) "&_
                        " VALUE "&_
                        "("&queryAgendamento("id")&", "&licencaOrigem&", '"&mydate(queryAgendamento("Data"))&"', '"&mydate(queryAgendamento("Data"))&"', '"&now()&"', '"&queryAgendamento("HoraDe")&"', '"&horaAte&"','"&weekday(mydate(queryAgendamento("Data")))&"', "&profissionalIdFilho&", "&queryAgendamento("sysUser")&", '"&titulo&"', '"&descricao&"')"

                db.execute(insertSql)
            
            else

                ' INSERINDO BLOQUEIO EM TODAS AS LICENÇAS FILHO
                if CInt(queryLicencas("licencaIdFilho")) <> CInt(licencaOrigem) then

                    insertSql = "INSERT INTO clinic"&queryLicencas("licencaIdFilho")&".compromissos (AgendamentoIDMae, LicencaIDMae, DataDe, DataA, Data, HoraDe, HoraA, DiasSemana, ProfissionalID, Usuario, Titulo, Descricao) "&_
                            " VALUE "&_
                            "("&queryAgendamento("id")&", "&licencaOrigem&", '"&mydate(queryAgendamento("Data"))&"', '"&mydate(queryAgendamento("Data"))&"', '"&now()&"', '"&queryAgendamento("HoraDe")&"', '"&horaAte&"','"&weekday(mydate(queryAgendamento("Data")))&"', "&profissionalIdFilho&", "&queryAgendamento("sysUser")&", '"&titulo&"', '"&descricao&"')"

                    db.execute(insertSql)
                end if
            end if

            queryAgendamento.movenext
        wend

        if bloqueioLicencaMae = 1 then
            insertMae = 1
        end if
        queryAgendamento.movefirst
        queryLicencas.movenext
    wend
    queryAgendamento.close
    set queryAgendamento=nothing

    ' INSERINDO BLOQUEIO NAS LICENÇAS FILHO NO MOMENTO DO VINCULO DO PROFFISIONAL
    if tipoAgendamento = "vincular" then

        ' PESQUISANDO AGENDAMENTOS DA LICENÇA MÃE PARA BLOQUEAR NAS LICENÇAS FILHO
        queryAgendamentoSQL = "SELECT a.id, a.StaID, a.`Data`, a.Tempo, TIME_FORMAT(a.Hora, '%H:%i') AS HoraDe, TIME_FORMAT(a.HoraFinal, '%H:%i:%s') AS HoraA, a.ProfissionalID, a.NomePaciente, a.sysUser, p.NomeProfissional FROM clinic"&licencaIdMae&".agendamentos a "&_
        " LEFT JOIN profissionais p ON p.id = a.ProfissionalID "&_
        " WHERE a.ProfissionalID = "&profissionalIdMae&" AND Data>=CURDATE()"

        set queryAgendamento = db.execute(queryAgendamentoSQL)

        queryLicencas.movefirst

        while not queryLicencas.EOF

            while not queryAgendamento.EOF

                ' INSERINDO BLOQUEIO LICENÇA FILHO
                titulo = "ATENDIMENTO INTEGRADORA"
                descricao = "Bloqueio agenda unificada para o paciente "&queryAgendamento("NomePaciente")&" na licença "&licencaIdMae
                
                if queryAgendamento("Tempo") = "" then
                    calcTempo = 1
                    horaAte = DateAdd("n",calcTempo,queryAgendamento("HoraDe"))
                else
                    horaAte = DateAdd("n",queryAgendamento("Tempo"),queryAgendamento("HoraDe"))
                end if

                insertSql = "INSERT INTO clinic"&queryLicencas("licencaIdFilho")&".compromissos (AgendamentoIDMae, LicencaIDMae, DataDe, DataA, Data, HoraDe, HoraA, DiasSemana, ProfissionalID, Usuario, Titulo, Descricao) "&_
                        " VALUE "&_
                        "("&queryAgendamento("id")&", "&licencaIdMae&", '"&mydate(queryAgendamento("Data"))&"', '"&mydate(queryAgendamento("Data"))&"', '"&now()&"', '"&queryAgendamento("HoraDe")&"', '"&horaAte&"','"&weekday(mydate(queryAgendamento("Data")))&"', "&queryLicencas("profissionalIdFilho")&", "&queryAgendamento("sysUser")&", '"&titulo&"', '"&descricao&"')"

                db.execute(insertSql)
        
                queryAgendamento.movenext
            wend
            queryLicencas.movenext
        wend
        queryAgendamento.close
        set queryAgendamento=nothing
        queryLicencas.close
        set queryLicencas=nothing
    else
        queryLicencas.close
        set queryLicencas=nothing
    end if
end function
%>