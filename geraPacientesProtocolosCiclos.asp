<!--#include file="connect.asp"-->
<%
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

            set protocolosKits = db.execute("SELECT KitID FROM protocoloskits WHERE ProtocoloID = '" & ProtocoloID & "' AND sysActive = 1 ")
            if not protocolosKits.eof then
                temKits = true
            else
                temKits = false
            end if

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
                                    "VALUES ('" & PacienteProtocoloID & "', '" & ProtocoloID & "', '" & ciclo & "', '" & dia & "', '" & myDate(DataSugerida) & "', 1, 4, 8, '" & session("User") & "')")

                                db.execute("SET @lastid = LAST_INSERT_ID();")

                                db.execute("INSERT INTO pacientesprotocolosciclos_medicamentos (PacienteProtocoloID, PacienteProtocolosCicloID, PacienteProtocolosMedicamentosID) " & _
                                    "VALUES ('" & PacienteProtocoloID & "', @lastid, '" & pacienteProcoloMedicamentoId & "')")

                                if temKits then
                                    protocolosKits.movefirst
                                    while not protocolosKits.eof
                                        db.execute("INSERT INTO pacientesprotocolosciclos_kits (PacienteProtocoloID, PacienteProtocolosCicloID, KitID) " & _
                                        "VALUES ('" & PacienteProtocoloID & "', @lastid, '" & protocolosKits("KitID") & "')")
                                        protocolosKits.movenext
                                    wend
                                end if

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

end function
%>