<!--#include file="connect.asp"-->
<%
Dispensar = ref("dispensar")
if Dispensar = "" then
    response.write("Parametros obrigatorios nao fornecidos.")
    response.status = 422
    response.end
end if

UnidadeID = ref("UnidadeID")

' valida os itens enviados
ArrDispensar = Split(Dispensar, ",")
for i=0 to UBound(ArrDispensar)
    ArrItem = Split(ArrDispensar(i), "|")
    
    if UBound(ArrItem) <> 1 then
        response.write("Item " & i & " invalido ")
        response.status = 500
        response.end
    end if
next

'processa os itens
for i=0 to UBound(ArrDispensar)
    ArrItem = Split(ArrDispensar(i), "|")

    ' Variaveis
    CicloMedicamentoID = ArrItem(0)
    ProdutoID          = ArrItem(1)

    'response.write("<pre>Item " & i & " - CicloMedicamentoID: " & CicloMedicamentoID & "</pre>")
    'response.write("<pre>Item " & i & " - ProdutoID: " & ProdutoID & "</pre>")

    'recupera a prescrição
    sqlMedicamentoPrescrito = "SELECT " &_
                              "ppcm.id, " &_
                              "ppcm.PacienteProtocolosCicloID, " &_
                              "protmed.id AS ProtocoloMedicamentoID, " &_
                              "prod.id AS ProdutoID, prod.NomeProduto,  " &_
                              "IF(ppm.MedicamentoPrescritoID IS NOT NULL, ppm.DoseMedicamento, protmed.Dose) AS Dose,  " &_
                              "uMed.Sigla " &_
                              "FROM pacientesprotocolosciclos_medicamentos ppcm " &_
                              "INNER JOIN pacientesprotocolosmedicamentos ppm ON ppm.id = ppcm.PacienteProtocolosMedicamentosID " &_
                              "INNER JOIN protocolosmedicamentos protmed ON protmed.id = ppm.ProtocoloMedicamentoID AND protmed.ProtocoloID = ppm.ProtocoloID " &_
                              "INNER JOIN produtos prod ON prod.id = COALESCE(ppm.MedicamentoPrescritoID, protmed.Medicamento) " &_
                              "LEFT JOIN cliniccentral.unidademedida uMed ON uMed.id = prod.UnidadePrescricao " &_
                              "WHERE ppcm.id = '" & CicloMedicamentoID & "'"
    set resMedicamentoPrescrito = db.execute(sqlMedicamentoPrescrito)
    if not resMedicamentoPrescrito.eof then

        cicloId        = resMedicamentoPrescrito("PacienteProtocolosCicloID")
        quantPrescrita = resMedicamentoPrescrito("Dose")

        'recupera as posições em estoque
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
            produtoId              = resPosicoes("ProdutoID")
            lote                   = resPosicoes("Lote")
            tipoUnidadeOriginal    = resPosicoes("TipoUnidade")
            validade               = resPosicoes("Validade")
            responsavelOriginal    = resPosicoes("Responsavel")
            localizacaoIdOriginal  = resPosicoes("LocalizacaoID")
            cbid                   = resPosicoes("CBID")
            apresentacaoQuantidade = resPosicoes("ApresentacaoQuantidade")

            'calcula a quantidade a ser baixada da posição, de forma pró-rata
            percProRata  = quantPosicao / quantTotalEmEstoque
            quantABaixar = quantPrescrita * percProRata
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
                call LanctoEstoque(0, posicaoId, produtoId, "S", tipoUnidadeOriginal, "C", quantConjuntoABaixar, date() , "", lote, validade, "", "", "", "Dispensação " & cicloId & " > Saída", "", "", "", localizacaoIdOriginal, "", "", "dispensacao", cbid, "", responsavelOriginal, localizacaoIdOriginal, "", "", "", "")
            end if
            if quantUnitariaABaixar > 0 then
                call LanctoEstoque(0, posicaoId, produtoId, "S", tipoUnidadeOriginal, "U", quantUnitariaABaixar, date() , "", lote, validade, "", "", "", "Dispensação " & cicloId & " > Saída", "", "", "", localizacaoIdOriginal, "", "", "dispensacao", cbid, "", responsavelOriginal, localizacaoIdOriginal, "", "", "", "")
            end if

            pos = pos + 1
            resPosicoes.movenext
        wend

    end if
next

response.write("OK")

%>

