<!--#include file="connect.asp"-->
<%
CicloID     = ref("CicloID")
CicloItemID = ref("CicloItemID")
ProdutoID   = ref("ProdutoID")
UnidadeID   = ref("UnidadeID")
Tipo        = ref("Tipo")

if CicloID = "" or CicloItemID = "" or ProdutoID = "" or UnidadeID = ""  then
    response.write("Parametros obrigatorios nao fornecidos.")
    response.status = 422
    response.end
end if

'recupera o ciclo
sqlProtocoloCiclo = "SELECT ppc.*, pp.PacienteID FROM pacientesprotocolosciclos ppc " &_
                    "INNER JOIN pacientesprotocolos pp ON pp.id = ppc.PacienteProtocoloID " &_
                    "WHERE ppc.id = '" & CicloID & "'"
set resProtocoloCiclo = db.execute(sqlProtocoloCiclo)
if resProtocoloCiclo.eof then
    response.write("Ciclo inválido ou não encontrado")
    response.status = 500
    response.end
end if
PacienteID = resProtocoloCiclo("PacienteID")


'medicamentos, diluentes e reconstituintes
if Tipo <> "4-Kit" then
    if Tipo = "1-Medicamento" then
        sqlSelectDose  = "CEIL(IF(ppm.MedicamentoPrescritoID IS NOT NULL, ppm.DoseMedicamento, protmed.Dose)) AS Dose"
        sqlJoinProduto = "prod.id = COALESCE(ppm.MedicamentoPrescritoID, protmed.Medicamento)"
    elseif Tipo = "2-Diluente" then
        sqlSelectDose  = "CEIL(protmed.QtdDiluente) AS Dose"
        sqlJoinProduto = "prod.id = protmed.DiluenteID"
    elseif Tipo = "3-Reconstituinte" then
        sqlSelectDose  = "CEIL(protmed.QtdReconstituinte) AS Dose"
        sqlJoinProduto = "prod.id = protmed.ReconstituinteID"
    else
        response.write("Tipo inválido.")
        response.status = 422
        response.end
    end if

    sqlProdutoPrescrito = "SELECT " &_
        "ppcm.id, " &_
        "ppcm.PacienteProtocolosCicloID, " &_
        "protmed.id AS ProtocoloMedicamentoID, " &_
        "prod.id AS ProdutoID, prod.NomeProduto,  " &_
        sqlSelectDose & " " &_
        "FROM pacientesprotocolosciclos_medicamentos ppcm " &_
        "INNER JOIN pacientesprotocolosmedicamentos ppm ON ppm.id = ppcm.PacienteProtocolosMedicamentosID " &_
        "INNER JOIN protocolosmedicamentos protmed ON protmed.id = ppm.ProtocoloMedicamentoID AND protmed.ProtocoloID = ppm.ProtocoloID " &_
        "INNER JOIN produtos prod ON " & sqlJoinProduto & " " &_
        "LEFT JOIN cliniccentral.unidademedida uMed ON uMed.id = prod.UnidadePrescricao " &_
        "WHERE ppcm.id = '" & CicloItemID & "' AND ppcm.PacienteProtocolosCicloID = '" & CicloID & "'"
    set resProdutoPrescrito = db.execute(sqlProdutoPrescrito)

    if not resProdutoPrescrito.eof then
        quantPrescrita = resProdutoPrescrito("Dose")
    end if
'kit
else

    sqlProdutoKit = "SELECT SUM(prodkit.Quantidade) AS Quantidade " &_
        "FROM pacientesprotocolosciclos ppc " &_
        "INNER JOIN protocoloskits pkit ON pkit.ProtocoloID = ppc.ProtocoloID " &_
        "INNER JOIN produtosdokit prodkit ON prodkit.KitID = pkit.KitID " &_
        "INNER JOIN produtos prod ON prod.id = prodkit.ProdutoID " &_
        "WHERE ppc.id = '" & CicloID & "' AND prod.id = '" & ProdutoID & "' " &_
        "AND pkit.sysActive = 1 AND prodkit.sysActive = 1 AND prodkit.Quantidade > 0 AND prod.sysActive = 1"
    set resProdutoKit = db.execute(sqlProdutoKit)
    if not resProdutoKit.eof then
        quantPrescrita = resProdutoKit("Quantidade")
    end if

end if


if quantPrescrita then

    'recupara a primeira localização da unidade do usuário, ou seta a localização matriz se nenhuma for encontrada
    sqlLocalizacaoUnidade = "SELECT id, NomeLocalizacao FROM produtoslocalizacoes loc WHERE COALESCE(loc.UnidadeID, 0) = '" & session("UnidadeID") & "' AND loc.sysActive = 1"
    set resLocalizacaoUnidade = db.execute(sqlLocalizacaoUnidade)
    if not resLocalizacaoUnidade.eof then
        localizacaoIdUnidade = resLocalizacaoUnidade("id")
    else
        localizacaoIdUnidade = 0
    end if

    'recupera a quantidade em estoque na unidade do usuário
    sqlEmEstoque = "SELECT IFNULL(SUM( " &_
                "    IF(pos.TipoUnidade = 'C', " &_
                "    IFNULL(pos.Quantidade, 0) * IF(prod.ApresentacaoQuantidade IS NULL or prod.ApresentacaoQuantidade <= 0, 1, prod.ApresentacaoQuantidade), " &_
                "    IFNULL(pos.Quantidade, 0)) " &_
                "), 0) AS QuantUnit " &_
                "FROM estoqueposicao pos " &_
                "INNER JOIN produtos prod ON pos.ProdutoID = prod.id " &_
                "LEFT JOIN produtoslocalizacoes loc ON loc.id = pos.LocalizacaoID " &_
                "WHERE pos.ProdutoID = '" & ProdutoID & "' AND COALESCE(loc.UnidadeID, 0) = '" & session("UnidadeID") & "'"
    set resEmEstoque = db.execute(sqlEmEstoque)

    if not resEmEstoque.eof then

        quantTotalEmEstoque = resEmEstoque("QuantUnit")
        'response.write("<pre>quantTotalEmEstoque: " & quantTotalEmEstoque & "</pre>")

        'recupera as posições da outra unidade
        '1º - Destinado ao paciente
        '2º - Data de Validade
        '3º - Lote
        '4º - id
        sqlPosicoes = "SELECT pos.*, " &_
                    "IF(pos.TipoUnidade = 'C', " &_ 
                    "IFNULL(pos.Quantidade, 0) * IF(prod.ApresentacaoQuantidade IS NULL or prod.ApresentacaoQuantidade <= 0, 1, prod.ApresentacaoQuantidade), " &_
                    "IFNULL(pos.Quantidade, 0)) AS QuantUnit, " &_
                    "IF(prod.ApresentacaoQuantidade IS NULL OR prod.ApresentacaoQuantidade <= 0, 1, prod.ApresentacaoQuantidade) AS ApresentacaoQuantidade " &_
                    "FROM estoqueposicao pos " &_
                    "INNER JOIN produtos prod ON pos.ProdutoID = prod.id " &_
                    "LEFT JOIN produtoslocalizacoes loc ON loc.id = pos.LocalizacaoID " &_
                    "WHERE pos.Quantidade > 0 AND pos.ProdutoID = '" & ProdutoID & "' AND COALESCE(loc.UnidadeID, 0) = '" & UnidadeID & "' " &_
                    "AND COALESCE(pos.PacienteID, 0) IN (0, " & PacienteID & ") " &_
                    "ORDER BY FIELD(pos.PacienteID, '" & PacienteID & "') DESC, pos.Validade, pos.Lote, pos.id"
        set resPosicoes = db.execute(sqlPosicoes)

        quantTotalOutraUnidade = 0
        countPosicoes          = 0
        while not resPosicoes.eof
            quantTotalOutraUnidade = quantTotalOutraUnidade + resPosicoes("QuantUnit")
            countPosicoes = countPosicoes + 1
            resPosicoes.movenext
        wend
        'response.write("<pre>quantTotalOutraUnidade: " & quantTotalOutraUnidade & "</pre>")


        'calcula a quantidade total a transferir
        quantFalta = quantPrescrita - quantTotalEmEstoque
        if quantTotalOutraUnidade <= quantFalta then
            quantTotalATransferir = quantTotalOutraUnidade
        else
            quantTotalATransferir = quantFalta
        end if
        'response.write("<pre>quantTotalATransferir: " & quantTotalATransferir & "</pre>")

        'processa cada posição
        resPosicoes.movefirst
        while not resPosicoes.eof

            posicaoId              = resPosicoes("id")
            quantPosicao           = resPosicoes("QuantUnit")
            produtoId              = resPosicoes("ProdutoID")
            lote                   = resPosicoes("Lote")
            tipoUnidadeOriginal    = resPosicoes("TipoUnidade")
            validade               = resPosicoes("Validade")
            responsavelOriginal    = resPosicoes("Responsavel")
            localizacaoIdOriginal  = resPosicoes("LocalizacaoID")
            cbid                   = resPosicoes("CBID")
            apresentacaoQuantidade = resPosicoes("ApresentacaoQuantidade")
            posPacienteId          = resPosicoes("PacienteID")

            'calcula a quantidade a ser transferida da posição
            quantATransferir = quantTotalATransferir
            if (quantATransferir > quantPosicao) then
                quantATransferir = quantPosicao
            end if

            quantConjuntoATransferir = Int(quantATransferir / apresentacaoQuantidade)
            quantUnitariaATransferir = quantATransferir mod apresentacaoQuantidade

            'response.write("<pre>quantTotalATransferir "&quantTotalATransferir&"</pre>")
            'response.write("<pre>quantATransferir da pos "&posicaoId&": "&quantATransferir&"</pre>")
            'response.write("<pre>quantConjuntoATransferir da pos "&posicaoId&": "&quantConjuntoATransferir&"</pre>")
            'response.write("<pre>quantUnitariaATransferir da pos "&posicaoId&": "&quantUnitariaATransferir&"</pre>")
            if quantConjuntoATransferir > 0 then
                call LanctoEstoque(0, posicaoId, produtoId, "M", tipoUnidadeOriginal, "C", quantConjuntoATransferir, date() , "", lote, validade, "", "", "", "Dispensação " & CicloID & " > Transferência", "", posPacienteId, "", localizacaoIdUnidade, "", "", "dispensacao", cbid, "", responsavelOriginal, localizacaoIdOriginal, "", "", "", "")
            end if
            if quantUnitariaATransferir > 0 then
                call LanctoEstoque(0, posicaoId, produtoId, "M", tipoUnidadeOriginal, "U", quantUnitariaATransferir, date() , "", lote, validade, "", "", "", "Dispensação " & CicloID & " > Transferência", "", posPacienteId, "", localizacaoIdUnidade, "", "", "dispensacao", cbid, "", responsavelOriginal, localizacaoIdOriginal, "", "", "", "")
            end if

            quantTotalATransferir = quantTotalATransferir - quantATransferir
            resPosicoes.movenext
        wend

        response.write("OK")

    end if
end if
%>
