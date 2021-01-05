<!--#include file="connect.asp"-->
<%
CicloMedicamentoID = ref("CicloMedicamentoID")
ProdutoID          = ref("ProdutoID")
UnidadeID          = ref("UnidadeID")
Tipo               = ref("Tipo")

if CicloMedicamentoID = "" or ProdutoID = "" or UnidadeID = ""  then
    response.write("Parametros obrigatorios nao fornecidos.")
    response.status = 422
    response.end
end if

if Tipo = "2-Diluente" then
    sqlSelectDose  = "protmed.QtdDiluente AS Dose"
    sqlJoinProduto = "prod.id = protmed.DiluenteID"
elseif Tipo = "3-Reconstituinte" then
    sqlSelectDose  = "protmed.QtdReconstituinte AS Dose"
    sqlJoinProduto = "prod.id = protmed.ReconstituinteID"
else
    sqlSelectDose  = "IF(ppm.MedicamentoPrescritoID IS NOT NULL, ppm.DoseMedicamento, protmed.Dose) AS Dose"
    sqlJoinProduto = "prod.id = COALESCE(ppm.MedicamentoPrescritoID, protmed.Medicamento)"
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
    "WHERE ppcm.id = '" & CicloMedicamentoID & "'"
set resProdutoPrescrito = db.execute(sqlProdutoPrescrito)

if not resProdutoPrescrito.eof then

    cicloId        = resProdutoPrescrito("PacienteProtocolosCicloID")
    quantPrescrita = resProdutoPrescrito("Dose")

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
        pos = 0
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

            'calcula a quantidade a ser transferida da posição, de forma pró-rata
            percProRata      = quantPosicao / quantTotalOutraUnidade
            quantATransferir = quantTotalATransferir * percProRata
            if pos < (countPosicoes - 1) then
                ceil = Int(quantATransferir)
                if ceil <> quantATransferir then
                    ceil = ceil + 1
                end if
                quantATransferir = ceil
            else
                quantATransferir = Int(quantATransferir)
            end if

            quantConjuntoATransferir = Int(quantATransferir / apresentacaoQuantidade)
            quantUnitariaATransferir = quantATransferir mod apresentacaoQuantidade

            'response.write("<pre>quantATransferir da pos "&posicaoId&": "&quantATransferir&"</pre>")
            'response.write("<pre>quantConjuntoATransferir da pos "&posicaoId&": "&quantConjuntoATransferir&"</pre>")
            'response.write("<pre>quantUnitariaATransferir da pos "&posicaoId&": "&quantUnitariaATransferir&"</pre>")
            if quantConjuntoATransferir > 0 then
                call LanctoEstoque(0, posicaoId, produtoId, "M", tipoUnidadeOriginal, "C", quantConjuntoATransferir, date() , "", lote, validade, "", "", "", "Dispensação " & cicloId & " > Transferência", "", "", "", localizacaoIdUnidade, "", "", "dispensacao", cbid, "", responsavelOriginal, localizacaoIdOriginal, "", "", "", "")
            end if
            if quantUnitariaATransferir > 0 then
                call LanctoEstoque(0, posicaoId, produtoId, "M", tipoUnidadeOriginal, "U", quantUnitariaATransferir, date() , "", lote, validade, "", "", "", "Dispensação " & cicloId & " > Transferência", "", "", "", localizacaoIdUnidade, "", "", "dispensacao", cbid, "", responsavelOriginal, localizacaoIdOriginal, "", "", "", "")
            end if

            pos = pos + 1
            resPosicoes.movenext
        wend

        response.write("OK")

    end if
end if
%>
