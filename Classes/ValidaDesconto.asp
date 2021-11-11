<!--#include file="StringFormat.asp"-->

<%
' Valida um Desconto de acordo com as Regras para Aplicação de Descontos do Usuário
'
' Parâmetros:
'  TipoRecurso: string          - Nome do Recurso (ContasAReceber, Checkin, etc)
'  Procedimentos: string               - Lista de Procedimentos no formato: ID_VALOR|ID_VALOR, onde ID é o ID do procedimento e Valor é o valor do Procedimento
'  UserID: number                      - Id do usuário
'  UnidadeID: number                   - Id da unidade
'  PercDesconto: number|numeric string - Percentual de Desconto que deseja validar
' 
' Retorno:
'    Retorna um dicionario com os itens abaixo:

'    temRegraCadastrada             : boolean
'    temRegraCadastradaProUsuario   : boolean
'    temDescontoParaOGrupoDoUsuario : boolean
'    temRegraSuperior               : boolean
'    regrasSuperiores               : string
'    totalProcedimentos             : number
'    percMaximoDesconto             : number
'    valido                         : boolean
' 
function ValidaDesconto(TipoRecurso, Procedimentos, UserID, UnidadeID, PercDesconto)


    ' variáveis de respostas do método
    temRegraCadastrada             = false
    temRegraCadastradaProUsuario   = false
    temDescontoParaOGrupoDoUsuario = false
    temRegraSuperior               = false
    regrasSuperiores               = ""
    totalProcedimentos             = 0
    percMaximoDesconto             = 100
    valido                         = false

    ' valida os os procedimentos informados
    Set dicProcedimentosValores = Server.CreateObject("Scripting.Dictionary")

    arrProcedimentos = split(Procedimentos, "|")
    for i=0 to ubound(arrProcedimentos)

        arrProcedimento = split(arrProcedimentos(i), "_")
        ProcedimentoID  = arrProcedimento(0)

        if not isnumeric(ProcedimentoID) then
            Err.Raise 1, "ValidaDesconto.asp", "Procedimento " & ProcedimentoID & " inválido"
        end if

        if ubound(arrProcedimento) < 1 then
            Err.Raise 2, "ValidaDesconto.asp", "Valor do procedimento " & ProcedimentoID & " nao informado"
        end if 
        
        ProcedimentoValor = arrProcedimento(1)
        if not isnumeric(ProcedimentoValor) then
            Err.Raise 3, "ValidaDesconto.asp", "Valor do procedimento " & ProcedimentoID & " invalido"
        end if

        ProcedimentoValor  = FormatNumber(Replace(arrProcedimento(1), ".", ","), 2)
        totalProcedimentos = totalProcedimentos + ProcedimentoValor

        dicProcedimentosValores.Add ProcedimentoID&"_"&i, ProcedimentoValor
    next


    ' verifica se existem regras cadastradas com o tipo informado
    sqlTemRegraDesconto = "SELECT rd.id, rd.Recursos, rd.DescontoMaximo, rd.RegraID " &_
                          " FROM regrasdescontos rd " &_
                          " INNER JOIN regraspermissoes rp ON rp.id = rd.RegraID " &_
                          " WHERE (rd.Recursos LIKE '%|"&TipoRecurso&"|%' OR rd.Recursos='' OR rd.Recursos IS NULL) " &_
                          " AND rd.DescontoMaximo > 0 ORDER BY rd.DescontoMaximo ASC"
    set resTemRegrasDesconto = db.execute(sqlTemRegraDesconto)

    if not resTemRegrasDesconto.eof then
        temRegraCadastrada = true

        RegraDescontosID = "0"
        while not resTemRegrasDesconto.eof      
                RegraDescontosID = RegraDescontosID &  ", " &  resTemRegrasDesconto("RegraID")
                resTemRegrasDesconto.movenext
        wend
        resTemRegrasDesconto.close
        set resTemRegrasDesconto = nothing

        ' verifica quais dessas regras estão associadas ao usuário
        sqlRegraUsuario = "SELECT rp.id RegraID FROM sys_users u " &_
                          "INNER JOIN regraspermissoes rp ON u.RegraID = rp.id " &_
                          "WHERE u.id=" & UserID & " AND rp.id IN (" & RegraDescontosID & ")"
        set resRegraUsuario = db.execute(sqlRegraUsuario)

        if not resRegraUsuario.eof then
            temRegraCadastradaProUsuario = true
            RegraID = resRegraUsuario("RegraID")

            resRegraUsuario.close
            set resRegraUsuario = nothing

            ' verifica o desconto dos procedimentos informados e associados a regra do usuário
            countRegras = 0
            For Each ProcedimentoID in dicProcedimentosValores.Keys
                ProcedimentoID = split(ProcedimentoID, "_")
                Procedimento = ProcedimentoID(0)

                sqlMaximo = "SELECT id, DescontoMaximo, TipoDesconto FROM regrasdescontos WHERE RegraID="&RegraID&" AND "&_
                            "(Procedimentos IS NULL OR Procedimentos ='' OR Procedimentos LIKE '%|"&Procedimento&"%|') AND "&_
                            "(Unidades IS NULL OR Unidades ='' OR Unidades LIKE '%|"&UnidadeID&"|%' OR Unidades = '"&UnidadeID&"') AND "&_
                            "(Recursos LIKE '%|"&TipoRecurso&"|%' OR Recursos='' OR Recursos IS NULL) " &_
                            "ORDER BY DescontoMaximo DESC"
                set resMaximoDescontoRegra = db.execute(sqlMaximo)

                if not resMaximoDescontoRegra.eof then
                    TemDescontoParaOGrupoDoUsuario = true
                    countRegras = countRegras + 1

                    ' se o tipo de desconto for Valor, transforma em percentual do valor do procedimento
                    if resMaximoDescontoRegra("TipoDesconto") = "V" then
                        percMaximoDescontoRegra = resMaximoDescontoRegra("DescontoMaximo") / ProcedimentoValor * 100
                    else
                        percMaximoDescontoRegra = resMaximoDescontoRegra("DescontoMaximo")
                    end if

                    ' @TODO:
                    ' No caso de mais de um procedimento na conta onde apenas um tem regra de desconto, 
                    ' é necessário fazer o cálculo parcial de desconto. Exemplo:
                    ' Se um procedimento é 40% do valor total do pagamento, o desconto em cima desse procedimento individual 
                    ' deverá ser no máximo 40% do desconto total.
                    if totalProcedimentos > 0 then
                        percDoTotal = ProcedimentoValor / totalProcedimentos * 100
                        if percMaximoDescontoRegra > percDoTotal then
                            percMaximoDescontoRegra = percDoTotal
                        end if
                    end if

                    if percMaximoDescontoRegra < percMaximoDesconto then
                        percMaximoDesconto = percMaximoDescontoRegra
                    end if

                    resMaximoDescontoRegra.close
                    set resMaximoDescontoRegra=nothing
                end if

            next

        end if

    end if


    ' valida o desconto
    if PercDesconto > 0 then
        PercDesconto = cCur(FormatNumber(Replace(PercDesconto, ".", ","), 6))

        if temDescontoParaOGrupoDoUsuario and PercDesconto <= percMaximoDesconto then
            valido = true
        else

            ' se o desconto não é permitido ao usuário, verifica se tem regras superiores
            ValorPercDesconto = PercDesconto / 100 * totalProcedimentos

            RegraIdListString = ""
            For Each ProcedimentoID in dicProcedimentosValores.Keys
                ProcedimentoID = split(ProcedimentoID, "_")

                Procedimento = ProcedimentoID(0)

                sqlRegraSuperior = "SELECT IFNULL(group_concat(RegraID), '') regras FROM regrasdescontos WHERE " &_
                                   "(" &_
                                   "   (TipoDesconto = 'P' AND DescontoMaximo >= " & treatVal(PercDesconto) &") OR " &_
                                   "   (TipoDesconto = 'V' AND DescontoMaximo >= " & treatVal(ValorPercDesconto) &") " &_
                                   ") AND " &_
                                   "(Procedimentos IS NULL OR Procedimentos ='' OR Procedimentos LIKE '%|"&Procedimento&"|%') AND "&_
                                   "(Unidades IS NULL OR Unidades ='' OR Unidades LIKE '%|"&UnidadeID&"|%' OR Unidades = '"&UnidadeID&"') AND "&_
                                   "(Recursos LIKE '%|"&TipoRecurso&"|%' OR Recursos='' OR Recursos IS NULL) AND RegraID IS NOT NULL"
                set resRegraSuperior = db.execute(sqlRegraSuperior)
                if not resRegraSuperior.eof then
                    regras = resRegraSuperior("regras") 
                    if regras <> "" then
                        temRegraSuperior = true
                        if RegraIdListString = "" then
                            RegraIdListString = regras
                        else
                            RegraIdListString = RegraIdListString & "," & regras
                        end if
                    end if
                end if
                resRegraSuperior.close
                set resRegraSuperior=nothing
            next
            regrasSuperiores = removeDuplicatas(RegraIdListString, ",")

        end if
    else 
        valido = true
    end if

    Set dicResposta = CreateObject("Scripting.Dictionary")
    dicResposta.Add "temRegraCadastrada", temRegraCadastrada
    dicResposta.Add "temRegraCadastradaProUsuario", temRegraCadastradaProUsuario
    dicResposta.Add "temDescontoParaOGrupoDoUsuario", temDescontoParaOGrupoDoUsuario
    dicResposta.Add "temRegraSuperior", temRegraSuperior
    dicResposta.Add "regrasSuperiores", regrasSuperiores
    dicResposta.Add "totalProcedimentos", totalProcedimentos
    dicResposta.Add "percMaximoDesconto", percMaximoDesconto
    dicResposta.Add "valido", valido

    Set ValidaDesconto = dicResposta
end function


' Notifica um Desconto Aguardando Autorização
'
' Parâmetros:
'  ItensInvoiceID: integer     - Id da tabela itensinvoice
'  ValorDesconto: number       - Valor do Desconto aplicado no item
'  UserID: integer             - Id do usuário logado
'  UnidadeID: integer          - Id da unidade
'  idUsuariosDesconto: string  - Id dos usuários que serão notificados, separados por vírgula
'  IdsRegrasSuperiores: string - Id da tabela regraspermissoes separados por vírgula
'
' Retorno:
'    Retorna um dicionario com os itens abaixo:
function notificaDescontoPendente(ItensInvoiceID, ValorDesconto, UserID, UnidadeID, IdsRegrasSuperiores)

    ' Grava o desconto pendente
    set DescontosSQL = db.execute("select * from descontos_pendentes where ItensInvoiceID = " & ItensInvoiceID)
    if not DescontosSQL.eof then
        sqlUpdatependente = "update descontos_pendentes set DataHora=NOW(), Desconto = " & treatvalzero(ValorDesconto) & ", sysUserAutorizado=null,DataHoraAutorizado=null,  Status = 0, SysUser = " & UserID & " where id = " & DescontosSQL("id")
        db.execute(sqlUpdatependente)
    else
        sqlInsertpendente = "insert into descontos_pendentes values (null, " & ItensInvoiceID & ", " & treatvalzero(ValorDesconto) & ", 0, " & UserID & ", now(), null, null, now())"
        db.execute(sqlInsertpendente)

        set DescontosSQL = db.execute("select * from descontos_pendentes where ItensInvoiceID = " & ItensInvoiceID &" order by id desc limit 1")
    end if

    descontoPendenteID = DescontosSQL("id")
    DescontosSQL.close
    set DescontosSQL=nothing


    'Gera a nova notificação
    sqlUsuarios = "SELECT suser.id " &_
                  "FROM regrasdescontos rd " &_
                  "INNER JOIN regraspermissoes rp ON rp.id = rd.RegraID " &_
                  "INNER JOIN sys_users suser ON suser.Permissoes LIKE CONCAT('%[', rd.RegraID, ']%') " &_
                  "WHERE " &_
                  "(rd.Unidades LIKE '%|" & UnidadeID & "|%' OR rd.Unidades = '' OR rd.Unidades IS NULL OR rd.Unidades = '0' ) " &_
                  "AND rd.RegraID IN (" & IdsRegrasSuperiores & ")"
    set rsUsuarios = db.execute(sqlUsuarios)

    while not rsUsuarios.eof

        sqlNotificacao = "insert into notificacoes(TipoNotificacaoID, UsuarioID, NotificacaoIDRelativo, CriadoPorID, Prioridade, StatusID) " &_ 
            " values(4, " & rsUsuarios("id") &", " & descontoPendenteID & ", " & UserID & ", 1, 1)" 

        db.execute(sqlNotificacao)

        rsUsuarios.movenext
    wend
    rsUsuarios.close
    set rsUsuarios=nothing

    notificaDescontoPendente =  descontoPendenteID

end function


%>