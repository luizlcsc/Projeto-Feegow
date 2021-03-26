<!--#include file="connect.asp"-->
<%
'Gera os Ciclos de Dias de dispensação de Medicamentos do Protocolo
function geraPacientesProtocolosCiclos(PacienteProtocoloID)

    set pacientesProtocolos = db.execute("SELECT * FROM pacientesprotocolos WHERE id = '" & PacienteProtocoloID & "'")
    if not pacientesProtocolos.eof then
        
        ' seleciona os protocolos do paciente
        set protocolos = db.execute("SELECT p.id, p.NCiclos, p.Periodicidade, p.Marcacao " & _
            "FROM pacientesprotocolosmedicamentos ppm " & _
            "INNER JOIN protocolos p ON ppm.ProtocoloID = p.id " & _
            "WHERE ppm.PacienteProtocoloID = '" & PacienteProtocoloID & "'" & _
            "GROUP BY p.id")

        while not protocolos.eof

            ProtocoloID   = protocolos("id")
            Periodicidade = protocolos("Periodicidade")
            DataInicial   = DateAdd("d", 10, CDate(pacientesProtocolos("Data")))

            ' trata o ciclo de cada protocolo
            set protocolosMedicamentos = db.execute("SELECT ppm.id, pm.Ciclos, pm.Dias " & _
                "FROM pacientesprotocolosmedicamentos ppm " & _
                "INNER JOIN protocolosmedicamentos pm ON pm.id = ppm.ProtocoloMedicamentoID " & _
                "WHERE ppm.PacienteProtocoloID = '" & PacienteProtocoloID & "' AND ppm.ProtocoloID = '" & ProtocoloID & "' " & _
                "AND ppm.sysActive = 1 AND pm.sysActive = 1")

            if not protocolosMedicamentos.eof then
                while not protocolosMedicamentos.eof

                    pacienteProcoloMedicamentoId = protocolosMedicamentos("id")
                    arrCiclos                    = split(protocolosMedicamentos("Ciclos"), ",")
                    arrDias                      = split(protocolosMedicamentos("Dias"), ",")

                    ' calcula o dia dos ciclos
                    for c = 0 to ubound(arrCiclos)
                        ciclo = CInt(replace(arrCiclos(c), "|", ""))
                        for d = 0 to ubound(arrDias)
                            dia = CInt(replace(arrDias(d), "|", ""))

                            DataSugerida = DateAdd("d", ((ciclo - 1) * Periodicidade) + (dia - 1), DataInicial)

                            ' verifica se já existe o dia do ciclo
                            set protocoloCicloDia = db.execute("SELECT id FROM pacientesprotocolosciclos " & _
                                "WHERE PacienteProtocoloID = '" & PacienteProtocoloID & "' AND ProtocoloID = '" & ProtocoloID & "' " &_
                                "AND ciclo = '" & ciclo & "' AND dia = '" & dia & "'")

                            '  se não existir, insere o registro do dia do ciclo e o medicamento do dia
                            if protocoloCicloDia.eof then
                                db.execute("INSERT INTO pacientesprotocolosciclos (PacienteProtocoloID, ProtocoloID, Ciclo, Dia, DataSugerida, StatusAutorizacaoID, StatusProtocoloID, StatusDispensacaoID, sysUser) " & _
                                    "VALUES ('" & PacienteProtocoloID & "', '" & ProtocoloID & "', '" & ciclo & "', '" & dia & "', '" & myDate(DataSugerida) & "', 1, 6, 8, '" & session("User") & "')")

                                db.execute("SET @lastid = LAST_INSERT_ID();")

                                db.execute("INSERT INTO pacientesprotocolosciclos_medicamentos (PacienteProtocoloID, PacienteProtocolosCicloID, PacienteProtocolosMedicamentosID) " & _
                                    "VALUES ('" & PacienteProtocoloID & "', @lastid, '" & pacienteProcoloMedicamentoId & "')")

                            ' se já existi o registro do dia, insere o registro do medicamento do dia 
                            else
                                cicloId = protocoloCicloDia("id")
                                set protocoloCicloDiaMed = db.execute("SELECT id FROM pacientesprotocolosciclos_medicamentos " & _
                                    "WHERE PacienteProtocolosCicloID = '" & cicloId & "' AND PacienteProtocolosMedicamentosID = '" & pacienteProcoloMedicamentoId & "'")

                                if protocoloCicloDiaMed.eof then
                                        db.execute("INSERT INTO pacientesprotocolosciclos_medicamentos (PacienteProtocoloID, PacienteProtocolosCicloID, PacienteProtocolosMedicamentosID) " & _
                                                    "VALUES ('" & PacienteProtocoloID & "', '" & cicloId & "', '" & pacienteProcoloMedicamentoId & "')")
                                end if

                                protocoloCicloDiaMed.close
                                set protocoloCicloDiaMed = nothing
                            end if

                            protocoloCicloDia.close
                            set protocoloCicloDia = nothing
                        next
                    next

                    protocolosMedicamentos.movenext
                wend
            end if

            protocolosMedicamentos.close
            set protocolosMedicamentos = nothing

            protocolos.movenext
        wend

    end if

    pacientesProtocolos.close
    set pacientesProtocolos = nothing

    geraPacientesProtocolosCiclos = true

end function

'Atualiza o Status do Protocolo nos Ciclos de Dias de dispensação de Medicamentos
function updatePacientesProtocolosCiclosStatus(pacienteProtocoloId, newStatusId, motivoStatus)

    'recupera todos os dias que ainda não foram dispensados nem cancelados
    selecaoCiclos = "SELECT ppc.id, ppc.StatusProtocoloID FROM pacientesprotocolosciclos ppc " &_
                    "WHERE ppc.PacienteProtocoloID = '" & pacienteProtocoloId & "' AND ppc.StatusDispensacaoID = 8 " &_
                    "AND ppc.StatusProtocoloID != 7 ORDER BY Ciclo, Dia, id"
    
    set rsCiclos = db.execute(selecaoCiclos)

    firstCiclo = null
    if not rsCiclos.eof then
        firstCiclo  = rsCiclos("id")
        oldStatusId = rsCiclos("StatusProtocoloID")
    end if

    userId = session("User")

    while not rsCiclos.eof

        cicloId = rsCiclos("id")
        
        sqlUpdateCicloSta = "UPDATE pacientesprotocolosciclos ppc " &_
                            "SET ppc.StatusProtocoloID = " & newStatusId & ", ppc.StatusProtocoloUser = " & userId &  ", " &_
                            "ppc.StatusProtocoloDate = CURRENT_TIMESTAMP(), ppc.StatusProtocoloMotivo = '" & motivoStatus & "'" &_
                            "WHERE ppc.id = " & cicloId
        db.execute(sqlUpdateCicloSta)

        rsCiclos.movenext
    wend

    if firstCiclo then 'so precisa logar no primeiro dia alterado pois a tela de log já exibe todo o protocolo unificado
        sqlInsertCicloStaLog = "INSERT INTO pacientesprotocolosciclos_status_log (PacienteProtocoloID, PacienteProtocolosCiclosID, " &_
                               "TipoStatus, OldStatusID, NewStatusID, Motivo, sysUser) VALUES (" & pacienteProtocoloId & ", " &_
                               firstCiclo & ", " & "'Protocolo', " & oldStatusId & ", " & newStatusId & ", '" & motivoStatus & "', " & userId & ")"

        db.execute(sqlInsertCicloStaLog)
    end if

    rsCiclos.close
    set selecaoCiclos = nothing

    updatePacientesProtocolosCiclosStatus = true

end function
%>