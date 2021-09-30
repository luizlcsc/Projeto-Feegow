<!--#include file="../connect.asp"-->
<%
Class Restricao

    function getRestricoes(ProfissionalID, ProcedimentoID)
        Conta = "5_"&ProfissionalID

        sql = "select sr.*, prf.Restringir, prf.Inicio, prf.Fim from procedimentosrestricaofrase prf LEFT JOIN procedimentosrestricoesexcecao pr ON prf.ExcecaoID=pr.id"&_
                      " INNER JOIN sys_restricoes sr ON sr.id=prf.RestricaoID"&_
                      " WHERE prf.ProcedimentoID="&treatvalzero(ProcedimentoID)&" AND (pr.Conta='"&Conta&"' or pr.Conta IS NULL)"
        set getRestricoes = db.execute(sql)
    end function

    function renderRestricao(Descricao, Tipo, RestricaoID, Restringir, Inicio, Fim, TextoSim, TextoNao)
        input = ""
        required = ""
        if Restringir<>"" and Restringir<>"0" then
            required = " required "
        end if

        onchange = " onchange=""verificaRestricao(this, '"&Restringir&"', '"&Inicio&"', '"&Fim&"', '"&TextoSim&"', '"&TextoNao&"')"" "

        if Tipo=1 then
            input = quickField("text", "Restricao-"&RestricaoID, Descricao, 3, "", "", "", ""&required&onchange)
        elseif Tipo=2 then
            input = quickField("number", "Restricao-"&RestricaoID, Descricao, 3, "", "", "", " min='"&min&"' max='"&max&"' "&required&onchange)
        elseif Tipo=3 then
            input = quickField("selectRadio", "Restricao-"&RestricaoID, Descricao, 3, "", "select 'S'id, 'Sim' Resposta UNION ALL SELECT 'N'id, 'Não'Resposta", "Resposta", ""&required&onchange)
        end if

        renderRestricao=input
    end function

    function possuiRestricao(ProcedimentoID)

        sql = "SELECT COUNT(*) total FROM procedimentosrestricaofrase WHERE ProcedimentoID = "&ProcedimentoID

        set resRestricao = db.execute(sql)

        possuiRestricao = resRestricao("total")
    end function

    function possuiPreparo(ProcedimentoID)

        sql = "SELECT COUNT(*) total FROM procedimentospreparofrase WHERE ProcedimentoID = "&ProcedimentoID

        set resPreparo = db.execute(sql)

        possuiPreparo = resPreparo("total")
    end function

    function restricaoPaciente(PacienteID, ProcedimentoID, ProfissionalID)

        erro = 0

        if ProfissionalID > 0 then

            sql = " SELECT RestricaoID "&_
                "   FROM procedimentosrestricaofrase prf "&_
                "   JOIN sys_restricoes r ON r.id = prf.RestricaoID "&_
                "  WHERE ProcedimentoID = "&ProcedimentoID&" "&_
                "    AND (ExcecaoID IN ((SELECT id FROM procedimentosrestricoesexcecao WHERE SUBSTRING_INDEX(Conta,'_',-1) = "&ProfissionalID&" AND ProcedimentoID = "&ProcedimentoID&")))"

        elseif ProfissionalID = 0 then

            sql = " SELECT RestricaoID "&_
                "   FROM procedimentosrestricaofrase prf "&_
                "   JOIN sys_restricoes r ON r.id = prf.RestricaoID "&_
                "  WHERE ProcedimentoID = "&ProcedimentoID&" "&_
                "    AND ExcecaoID = 0"

        end if 
       
        set restricoes = db.execute(sql)

        while not restricoes.eof
           
            set restrito = verificaRestricao(ProfissionalID, ProcedimentoID, PacienteID, restricoes("RestricaoID"),"")

            if restrito.item("resultado") = "S" then
                erro = erro+1
            end if

            restricoes.movenext
        wend
        
        restricoes.close
        set restricoes = nothing

        set retornoFuncao = CreateObject("Scripting.Dictionary")
        
        retornoFuncao.Add "resultado", erro

        set restricaoPaciente = retornoFuncao

    end function

    function verificaRestricao(ProfissionalID, ProcedimentoID, PacienteID, RestricaoID, Resposta)

        if RestricaoID <> "" then
            RestricaoID = " AND RestricaoID = "&RestricaoID
        end if

        sql = " SELECT distinct RestricaoID, r.Descricao, Tipo, (SELECT prf2.ExcecaoID "&_
            "                                                    FROM procedimentosrestricaofrase prf2 "&_
            "                                                   WHERE prf2.RestricaoID = prf.RestricaoID "&_
            "                                                     AND ProcedimentoID IN ("&ProcedimentoID&") AND (ExcecaoID IN (0,(SELECT id FROM procedimentosrestricoesexcecao WHERE SUBSTRING_INDEX(Conta,'_',-1) = "&ProfissionalID&" AND ProcedimentoID IN ("&ProcedimentoID&"))) OR ExcecaoID = 0) ORDER BY 1 "&_
            "                                              DESC LIMIT 1) ExcecaoID, RestricaoSemExcecao "&_
            "   FROM procedimentosrestricaofrase prf "&_
            "   JOIN sys_restricoes r ON r.id = prf.RestricaoID "&_
            "  WHERE ProcedimentoID IN ("&ProcedimentoID&") "&_
            RestricaoID&_
            "    AND (ExcecaoID IN ((SELECT id FROM procedimentosrestricoesexcecao WHERE SUBSTRING_INDEX(Conta,'_',-1) = "&ProfissionalID&" AND ProcedimentoID IN ("&ProcedimentoID&"))) OR ExcecaoID = 0)"&_
            " ORDER BY 4,2 "

        set restricoes = db.execute(sql)

        totalRestricao = 0
        valor = ""
        cssClass = ""
        semExcecao = ""
        
        if not restricoes.eof then
            while not restricoes.eof 
                if Resposta <> "" then
                    if IsNumeric(Resposta) then
                        sqlResposta = "SELECT "&Resposta&" RespostaMarcada"
                    else 
                        sqlResposta = "SELECT '"&Resposta&"' RespostaMarcada"
                    end if 
                elseif PacienteID <> "" then
                    sqlResposta = "SELECT * FROM restricoes_respostas WHERE PacienteID = "&PacienteID&" AND RestricaoID = "&restricoes("RestricaoID")
                else 
                    sqlResposta = "SELECT * FROM (SELECT 1) AS t  WHERE false"
                end if
                
                set respostas = db.execute(sqlResposta)

                if not respostas.eof then

                    sqlValorRestricao =  " SELECT Horas, Dias, Inicio, Fim, Restringir, MostrarPorPadrao, CaixaSIM, CaixaNAO, TextoSIM, TextoNao "&_ 
                                        " FROM procedimentosrestricaofrase prf JOIN sys_restricoes r ON r.id = prf.RestricaoID "&_ 
                                        " WHERE RestricaoID = "&restricoes("RestricaoID")&_
                                        " AND ProcedimentoID IN ("&ProcedimentoID & ") "&_
                                        " AND ExcecaoID = "&restricoes("ExcecaoID")

                    set valorRestricao = db.execute(sqlValorRestricao)

                    if restricoes("tipo") = 2 then
                        if isnumeric(respostas("RespostaMarcada")) then
                            restricaoVal_RespostaRemarcada = ccur(respostas("RespostaMarcada"))
                        else
                            restricaoVal_RespostaRemarcada = "NULL"
                        end if
                        if isnumeric(valorRestricao("Inicio")) then
                            restricaoVal_Inicio = ccur(valorRestricao("Inicio"))
                        else
                            restricaoVal_RespostaRemarcada = "NULL"
                        end if
                        if isnumeric(valorRestricao("Fim")) then
                            restricaoVal_RespostaRemarcada = ccur(valorRestricao("Fim"))
                        else
                            restricaoVal_RespostaRemarcada = "NULL"
                        end if

                        if valorRestricao("Restringir") = "D" and restricaoVal_RespostaRemarcada >= restricaoVal_Inicio and restricaoVal_RespostaRemarcada <= restricaoVal_RespostaRemarcada then
                            totalRestricao = totalRestricao+1
                            valorMotivo = "dentro"
                            cssClass = "danger"
                        elseif valorRestricao("Restringir") = "F" and restricaoVal_RespostaRemarcada < restricaoVal_Inicio or restricaoVal_RespostaRemarcada > restricaoVal_RespostaRemarcada then
                            totalRestricao = totalRestricao+1
                            valorMotivo = "fora"
                            cssClass = "danger"
                        end if

                        if totalRestricao > 0 then
                            
                            valor = valor&" "&restricoes("Descricao")&" ("&valorMotivo&" da faixa "&valorRestricao("Inicio")&" - "&valorRestricao("Fim")&") "
                            
                            if restricoes("RestricaoSemExcecao") = "S" then
                                semExcecao = "S"
                                valor = valor&" (SEM EXCEÇÃO)"
                            end if

                            valor = valor&"<br>"
                            
                        end if

                    elseif restricoes("tipo") = 3 then

                        if valorRestricao("Restringir") = "S" and respostas("RespostaMarcada") = "S" then
                            totalRestricao = totalRestricao+1
                            cssClass = "danger"
                            valor = valor&" "&restricoes("Descricao")&" Restrito no SIM "
                        elseif valorRestricao("Restringir") = "N" and respostas("RespostaMarcada") = "N" then
                            totalRestricao = totalRestricao+1
                            cssClass = "danger"
                            valor = valor&" Restrito no NÃO "
                        end if

                        if totalRestricao > 0 then
                            if restricoes("RestricaoSemExcecao") = "S" then
                                semExcecao = "S"
                                valor = valor&" "&restricoes("Descricao")&" (SEM EXCEÇÃO)"
                            end if
                        
                            valor = valor&"<br>"

                        end if

                    end if
                end if

                restricoes.movenext
            wend
            restricoes.close
            set restricoes = nothing

        end if

        set retornoFuncao = CreateObject("Scripting.Dictionary")

        if totalRestricao > 0 then
            retornoFuncao.Add "resultado","S"
            retornoFuncao.Add "mensagem", valor
            retornoFuncao.Add "classe", cssClass
            retornoFuncao.Add "semExcecao", semExcecao

        else
            retornoFuncao.Add "resultado","N"
        end if

        set verificaRestricao = retornoFuncao

    end function
End Class
%>