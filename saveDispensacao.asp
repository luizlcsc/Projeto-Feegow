<!--#include file="connect.asp"-->
<%
CicloID             = ref("cicloId")
PacienteProtocoloID = ref("pacienteProtocoloId")
Dispensar           = ref("dispensar")

if CicloID = "" or PacienteProtocoloID = "" or Dispensar = "" then
    response.write("Parametros obrigatorios nao fornecidos.")
    response.status = 422
    response.end
end if


'valida os itens enviados
ArrDispensar = Split(Dispensar, ",")
for i=0 to UBound(ArrDispensar)
    ArrItem = Split(ArrDispensar(i), "|")

    if UBound(ArrItem) <> 2 then
        response.write("Item " & i & " invalido ")
        response.status = 500
        response.end
    end if

    TipoItem = ArrItem(1)
    if TipoItem <> "1-Medicamento" and TipoItem <> "2-Diluente" and TipoItem <> "3-Reconstituinte" and TipoItem <> "4-Kit" then
        response.write("Tipo do Item " & i & " invalido ")
        response.status = 500
        response.end
    end if
next

'recupera o ciclo
set resProtocoloCiclo = db.execute("SELECT * FROM pacientesprotocolosciclos WHERE id = '" & CicloID & "' AND StatusDispensacaoID != 11 AND StatusDispensacaoID != 10")
if resProtocoloCiclo.eof then
    response.write("Ciclo inválido ou não encontrado")
    response.status = 500
    response.end
end if


'processa os itens
dispensado = false
for i=0 to UBound(ArrDispensar)
    ArrItem = Split(ArrDispensar(i), "|")

    ' Variaveis do Item
    CicloItemID = ArrItem(0)
    TipoItem    = ArrItem(1)
    ProdutoID   = ArrItem(2)

    'response.write("<pre>Item " & i & " - CicloItemID: " & CicloItemID & "</pre>")
    'response.write("<pre>Item " & i & " - TipoItem: " & TipoItem & "</pre>")
    'response.write("<pre>Item " & i & " - ProdutoID: " & ProdutoID & "</pre>")

    'medicamentos, diluentes e reconstituintes
    if TipoItem <> "4-Kit" then

        'recupera a prescrição
        if TipoItem = "2-Diluente" then
            sqlSelectDose   = "CEIL(protmed.QtdDiluente) AS Dose"
            sqlJoinProduto  = "prod.id = protmed.DiluenteID"
            campoDispensado = "DiluenteDispensado"
        elseif TipoItem = "3-Reconstituinte" then
            sqlSelectDose   = "CEIL(protmed.QtdReconstituinte) AS Dose"
            sqlJoinProduto  = "prod.id = protmed.ReconstituinteID"
            campoDispensado = "ReconstituinteDispensado"
        else
            sqlSelectDose   = "CEIL(IF(ppm.MedicamentoPrescritoID IS NOT NULL, ppm.DoseMedicamento, protmed.Dose)) AS Dose"
            sqlJoinProduto  = "prod.id = COALESCE(ppm.MedicamentoPrescritoID, protmed.Medicamento)"
            campoDispensado = "MedicamentoDispensado"
        end if

        sqlMedicamentoPrescrito = "SELECT " &_
                                "ppcm.id, " &_
                                "protmed.id AS ProtocoloMedicamentoID, " &_
                                "prod.id AS ProdutoID, prod.NomeProduto,  " &_
                                sqlSelectDose & " " &_
                                "FROM pacientesprotocolosciclos_medicamentos ppcm " &_
                                "INNER JOIN pacientesprotocolosmedicamentos ppm ON ppm.id = ppcm.PacienteProtocolosMedicamentosID " &_
                                "INNER JOIN protocolosmedicamentos protmed ON protmed.id = ppm.ProtocoloMedicamentoID AND protmed.ProtocoloID = ppm.ProtocoloID " &_
                                "INNER JOIN produtos prod ON " & sqlJoinProduto & " " &_
                                "LEFT JOIN cliniccentral.unidademedida uMed ON uMed.id = prod.UnidadePrescricao " &_
                                "WHERE ppcm.id = '" & CicloItemID & "' AND ppcm.PacienteProtocolosCicloID = " & CicloID & " and ppcm." & campoDispensado & "ID IS NULL"
        set resMedicamentoPrescrito = db.execute(sqlMedicamentoPrescrito)
        if not resMedicamentoPrescrito.eof then
            quantPrescrita = resMedicamentoPrescrito("Dose")

            'lanca a dispensacao do produto
            if LancaDispensacao(ProdutoID, session("UnidadeID"), quantPrescrita, CicloID) then
                'atualiza o ciclo medicamento
                db.execute("UPDATE pacientesprotocolosciclos_medicamentos SET " & campoDispensado & "ID = '" & ProdutoID & "', " & campoDispensado & "Em = NOW(), " & campoDispensado & "Por = '" & session("User") & "' WHERE id = '" & CicloItemID & "'")
                dispensado = true
            end if

        end if
    'kits
    else

        'recupera os produtos do kit
        sqlProdutosKit = "SELECT pkits.KitID, kits.NomeKit, prodkit.ProdutoID, prod.NomeProduto, " &_
            "IFNULL(prodkit.Quantidade, 0) AS Quantidade " &_
            "FROM pacientesprotocolosciclos_kits pkits " &_
            "INNER JOIN produtoskits kits ON kits.id = pkits.KitID " &_
            "INNER JOIN produtosdokit prodkit ON prodkit.KitID = kits.id " &_
            "INNER JOIN produtos prod ON prod.id = prodkit.ProdutoID " &_
            "WHERE pkits.id = '" & CicloItemID & "' AND kits.sysActive = 1 AND prodkit.sysActive = 1 AND prodkit.Quantidade > 0 " &_
            "GROUP BY pkits.id, prodkit.id"
        set resProdutosKit = db.execute(sqlProdutosKit)

        'dispensa os produtos do kit
        countProdutos    = 0
        countDispensados = 0
        while not resProdutosKit.eof
            countProdutos  = countProdutos + 1
            quantPrescrita = resProdutosKit("Quantidade")
            kitProdutoID   = resProdutosKit("ProdutoID")

            if LancaDispensacao(kitProdutoID, session("UnidadeID"), quantPrescrita, CicloID) then
                countDispensados = countDispensados + 1
            end if

            resProdutosKit.movenext
        wend
        if countProdutos = countDispensados then
            dispensado = true
            'atualiza o ciclo kit
            db.execute("UPDATE pacientesprotocolosciclos_kits SET Dispensado = 1, DispensadoEm = NOW(), DispensadoPor = '" & session("User") & "' WHERE id = '" & CicloItemID & "'")
        end if

    end if
next

'altera o status do ciclo
if dispensado then

    oldStatusId = resProtocoloCiclo("StatusDispensacaoID")
    statusDispensacao = 12 'parcial

    set resVerificaStatusMed = db.execute("SELECT COUNT(*) as count FROM pacientesprotocolosciclos_medicamentos ppcm " &_
                                       "INNER JOIN pacientesprotocolosmedicamentos ppm ON ppm.id = ppcm.PacienteProtocolosMedicamentosID " &_
                                       "INNER JOIN protocolosmedicamentos protmed ON protmed.id = ppm.ProtocoloMedicamentoID AND protmed.ProtocoloID = ppm.ProtocoloID " &_
                                       "WHERE ppcm.PacienteProtocolosCicloID = '" & CicloID & "' " &_
                                       "AND ( " &_
                                       "ppcm.MedicamentoDispensadoID IS NULL " &_
                                       "OR (ppcm.DiluenteDispensadoID IS NULL AND protmed.DiluenteID != 0 AND protmed.DiluenteID != 0 AND protmed.DiluenteID IS NOT NULL) " &_
                                       "OR (ppcm.ReconstituinteDispensadoID IS NULL AND protmed.ReconstituinteID != 0 AND protmed.ReconstituinteID IS NOT NULL) " &_
                                       ")")

    set resVerificaStatusKit = db.execute("SELECT COUNT(*) as count FROM pacientesprotocolosciclos_kits ppck " &_
                                          "WHERE ppck.PacienteProtocolosCicloID = '" & CicloID & "' AND ppck.Dispensado = 0")

    if not resVerificaStatusMed.eof and not resVerificaStatusKit.eof then
        if CInt(resVerificaStatusMed("count")) = 0 and  CInt(resVerificaStatusKit("count")) = 0 then
            statusDispensacao = 10 'dispensado
        end if
    end if

    db.execute("UPDATE pacientesprotocolosciclos SET StatusDispensacaoID = " & statusDispensacao & ", StatusDispensacaoUser = '" & session("User") & "', StatusDispensacaoDate = NOW() WHERE id = '" & CicloID & "'")
    db.execute("INSERT INTO pacientesprotocolosciclos_status_log (PacienteProtocoloID, PacienteProtocolosCiclosID, TipoStatus, OldStatusID, NewStatusID, sysUser) "&_
               "VALUES (" & PacienteProtocoloID & ", " & CicloID & ", 'Dispensacao', " & oldStatusId & ", " & statusDispensacao & ", " & session("User") & ")")

    response.write("OK")
else
    response.write("Não dispensado")
end if

function LancaDispensacao(ProdutoID, UnidadeID, QuantPrescrita, CicloID)
    'recupera as posições em estoque do produto
    sqlPosicoes = "SELECT pos.*, " &_
                "IF(pos.TipoUnidade = 'C', " &_ 
                "IFNULL(pos.Quantidade, 0) * IF(prod.ApresentacaoQuantidade IS NULL or prod.ApresentacaoQuantidade <= 0, 1, prod.ApresentacaoQuantidade), " &_
                "IFNULL(pos.Quantidade, 0)) AS QuantUnit, " &_
                "IF(prod.ApresentacaoQuantidade IS NULL OR prod.ApresentacaoQuantidade <= 0, 1, prod.ApresentacaoQuantidade) AS ApresentacaoQuantidade " &_
                "FROM estoqueposicao pos " &_
                "INNER JOIN produtos prod ON pos.ProdutoID = prod.id " &_
                "LEFT JOIN produtoslocalizacoes loc ON loc.id = pos.LocalizacaoID " &_
                "WHERE pos.Quantidade > 0 AND pos.ProdutoID = '" & ProdutoID & "' AND COALESCE(loc.UnidadeID, 0) = '" & UnidadeID & "'"
    set resPosicoes = db.execute(sqlPosicoes)

    if not resPosicoes.eof then

        'calcula o total das posições
        quantTotalEmEstoque = 0
        countPosicoes       = 0
        while not resPosicoes.eof
            quantTotalEmEstoque = quantTotalEmEstoque + resPosicoes("QuantUnit")
            countPosicoes = countPosicoes + 1
            resPosicoes.movenext
        wend

        'processa cada posição
        resPosicoes.movefirst
        pos = 0
        while not resPosicoes.eof
            posicaoId              = resPosicoes("id")
            quantPosicao           = resPosicoes("QuantUnit")
            lote                   = resPosicoes("Lote")
            tipoUnidadeOriginal    = resPosicoes("TipoUnidade")
            validade               = resPosicoes("Validade")
            responsavelOriginal    = resPosicoes("Responsavel")
            localizacaoIdOriginal  = resPosicoes("LocalizacaoID")
            cbid                   = resPosicoes("CBID")
            apresentacaoQuantidade = resPosicoes("ApresentacaoQuantidade")

            'calcula a quantidade a ser baixada da posição, de forma pró-rata
            percProRata  = quantPosicao / quantTotalEmEstoque
            quantABaixar = QuantPrescrita * percProRata
            if pos < (countPosicoes - 1) then
                ceil = Int(quantABaixar)
                if ceil <> quantABaixar then
                    ceil = ceil + 1
                end if
                quantABaixar = ceil
            else
                quantABaixar = Int(quantABaixar)
            end if

            quantConjuntoABaixar = Int(quantABaixar / apresentacaoQuantidade)
            quantUnitariaABaixar = quantABaixar mod apresentacaoQuantidade

            'response.write("<pre>quantABaixar da pos "&posicaoId&": "&quantABaixar&"</pre>")
            'response.write("<pre>quantConjuntoABaixar da pos "&posicaoId&": "&quantConjuntoABaixar&"</pre>")
            'response.write("<pre>quantUnitariaABaixar da pos "&posicaoId&": "&quantUnitariaABaixar&"</pre>")
            if quantConjuntoABaixar > 0 then
                call LanctoEstoque(0, posicaoId, ProdutoID, "S", tipoUnidadeOriginal, "C", quantConjuntoABaixar, date() , "", lote, validade, "", "", "", "Dispensação " & CicloID & " > Saída", "", "", "", localizacaoIdOriginal, "", "", "dispensacao", cbid, "", responsavelOriginal, localizacaoIdOriginal, "", "", "", "")
            end if
            if quantUnitariaABaixar > 0 then
                call LanctoEstoque(0, posicaoId, ProdutoID, "S", tipoUnidadeOriginal, "U", quantUnitariaABaixar, date() , "", lote, validade, "", "", "", "Dispensação " & CicloID & " > Saída", "", "", "", localizacaoIdOriginal, "", "", "dispensacao", cbid, "", responsavelOriginal, localizacaoIdOriginal, "", "", "", "")
            end if

            pos = pos + 1
            resPosicoes.movenext
        wend
        LancaDispensacao = true
    else
        LancaDispensacao = false
    end if
end function

%>

