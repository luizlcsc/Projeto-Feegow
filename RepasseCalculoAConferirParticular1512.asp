﻿<!--#include file="connect.asp"-->
<%
dividirCompensacao = req("dividirCompensacao")

totalRepasses = 0
totalMateriais = 0
totalProcedimentos = 0

private function tituloTabelaRepasse(Classe, Titulo, ItemInvoiceID, PagtoID, FormaPagto, NumeroParcela, Parcelas, ValorRecebido, ParcelaID, Extras)
    %>
    <tr class="<%= Classe %>">
        <td colspan="6">
            <div class="row">
                <div class="col-md-3">
                <%if Classe<>"dark" then %>
                    <span class="checkbox-custom checkbox-<%= Classe %> ptn mtn" style="position:relative; bottom:10px">
                        <input type="checkbox" name="linhaRepasse" value="<%= ItemInvoiceID &"_"& PagtoID  &"_"& ParcelaID %>" id="<%= ItemInvoiceID &"_"& PagtoID  &"_"& ParcelaID %>"><label for="<%= ItemInvoiceID &"_"& PagtoID  &"_"& ParcelaID %>"></label>
                    </span>
                <% end if %>

                    <%= Titulo %>: <%= FormaPagto %> - <%= NumeroParcela &"/"& Parcelas %></div>
                <div class="col-md-3">Recebido: <%= fn(ValorRecebido) %></div>
                <div class="col-md-3">Compensado: <%= ValorCompensado %></div>
                <div class="col-md-3"><%= Extras %></div>
            </div>
        </td>
    </tr>
    <%

end function

private function calcCreditado(ContaCredito, ProfissionalExecutante)
    if ContaCredito="PRO" then
        calcCreditado = ProfissionalExecutante
    else
        calcCreditado = ContaCredito
    end if
end function

private function calcValor(Valor, TipoValor, ValorBase, modo)
    if modo="calc" then
        if TipoValor="P" then
            calcValor = Valor/100 * ValorBase
        else
            calcValor = Valor
        end if
    else
        if TipoValor="P" then
            calcValor = fn(Valor) &"%"
        else
            calcValor = "R$ "& fn(Valor)
        end if
    end if
end function



private function listaRR( rDataExecucao, rInvoiceID, rItemInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, rValorProcedimento, rValorRecebido, ItemDescontadoID)
    set rr = db.execute("select * from rateiorateios where ItemInvoiceID="& rItemInvoiceID &" and ItemDescontadoID="& ItemDescontadoID)
    nLinha = 0
    while not rr.eof
        nLinha = nLinha+1
        call lrResult( "RateioRateios", rDataExecucao, rr("Funcao"), rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, rr("ContaCredito"), rValorProcedimento, rValorRecebido, rr("Valor"), nLinha, rr("FM"), rr("Sobre") )
    rr.movenext
    wend
    rr.close
    set rr=nothing
end function


private function repasse( rDataExecucao, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, rValorProcedimento, rValorRecebido, rPercentual, ParcelaID, rContaPagtoID )

    coefPerc = rPercentual / 100
    'conferir -> FormaID pode ser |P| para todos particulares, |C| para todos convênios, |00_0| para forma predefinida de recto e > |0| para qualquer id de convênio
    set fd = db.execute("select * from rateiofuncoes where DominioID="&DominioID&" order by Sobre")
    nLinha = 0

'    DescontoCartao = 0.05*(rValorProcedimento * coefPerc)
'    ValorBase = ValorBase - DescontoCartao
'        response.write(";;;;;;;;;;;;"& rContaPagtoID &";;;;;;;;;;;;;;")
    if rContaPagtoID<>"" and isnumeric(rContaPagtoID) and 0 then
        set vcaTaxa = db.execute("select * from repassesdescontos where Contas LIKE '%"& rContaPagtoID &"%'")
        if not vcaTaxa.eof then
            'TEM QUE COLOCAR O COEFPERC INDIVIDUAL BASEADO NO VALOR DO PROCEDIMENTO x VALOR DO PAGTO
            call lrResult( "Calculo", rDataExecucao, Funcao, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, 0, rValorProcedimento, rValorRecebido, rTaxa, nLinha, "F", 0 )
        end if
    end if

    while not fd.eof
        '-> Começa a coletar os dados pra temprepasses (antiga rateiorateios)
        Funcao = fd("Funcao")
        TipoValor = fd("TipoValor")
        Valor = fd("Valor")
        ContaPadrao = fd("ContaPadrao")
        ContaCredito = fd("ContaPadrao")
        Sobre = fd("Sobre")
        FormaID = 0 'Resolver
        FM = fd("FM")
        ProdutoID = fd("ProdutoID")
        ValorUnitario = fd("ValorUnitario")
        Quantidade = fd("Quantidade")
        sysUser = session("User")
        FuncaoID = fd("id")
        gravaTemp = 0
        if ultimoSobre<>Sobre then
            ValorBase = ValorBase - somaDesteSobre
            somaDesteSobre = 0
        end if
        '<-
        'Funcao da arvore para conta crédito (F ou M)
        if fd("FM")="F" or fd("FM")="M" then
            if fd("ContaPadrao")="" or (fd("FM")="M" and (fd("ProdutoID")=0 or fd("Variavel")="S" or fd("ValorVariavel")="S")) then
                set iio = db.execute("select * from itensinvoiceoutros where ItemInvoiceID="& ItemInvoiceID &" AND FuncaoID="& FuncaoID)
            end if
            if ContaPadrao="PRO" then
                ContaCredito = ii("Associacao")&"_"&ii("ProfissionalID")
            elseif ContaPadrao="" then
                if not iio.eof then
                    ContaCredito = iio("Conta")
                end if
            end if
         
            gravaTemp = 1
        end if

        'Funções estampadas
        'linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& Valor &"|"& ContaCredito &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual
        if fd("FM")="F" then
            Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
            ShowValor = calcValor(Valor, TipoValor, ValorBase, "show")
            ValorItem = calcValor(Valor, TipoValor, ValorBase, "calc")
                                
            if Creditado<>"" then
                somaDesteSobre = somaDesteSobre+ValorItem
                if Creditado<>"0" then
                    Despesas = Despesas + ValorItem
                end if

                linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem*coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID

                %>
                <input type="hidden" name="linhaRepasse<%= ItemInvoiceID &"_"& ItemDescontadoID  &"_"& ParcelaID %>" value="<%= linhaRepasse %>" />
                <%
                nLinha = nLinha+1
                'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                call lrResult( "Calculo", rDataExecucao, fd("Funcao"), rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, (ValorItem * coefPerc), nLinha, fd("FM"), fd("Sobre") )
            end if
        end if

        'Materiais da árvore (M)
        if fd("FM")="M" then
            Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
            ShowValor = calcValor(Valor, TipoValor, ValorBase, "show")
            ValorItem = calcValor(Valor, TipoValor, ValorBase, "calc")
            if fd("Variavel")="S" then
                set vcaLancto = db.execute("select * from estoquelancamentos where ItemInvoiceID="& ItemInvoiceID &" AND ProdutoID="& ProdutoID &" AND EntSai='S'")
                if not vcaLancto.EOF then
                    QuantidadeUnitariaUsada = 0
                    while not vcaLancto.EOF
                        QuantidadeUnitariaUsada = QuantidadeUnitariaUsada + vcaLancto("QuantidadeTotal")
                    vcaLancto.movenext
                    wend
                    vcaLancto.close
                    set vcaLancto=nothing

                    Quantidade = QuantidadeUnitariaUsada

                    set prod = db.execute("select NomeProduto from produtos where id="& ProdutoID)
                    if prod.eof then NomeProduto="" else NomeProduto=prod("NomeProduto") end if
                    if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                        somaDesteSobre = somaDesteSobre+ (Quantidade*ValorItem)
                        'if Creditado<>"0" then
                            Despesas = Despesas + (Quantidade*ValorItem)
                        'end if
                        linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID

                        nLinha = nLinha+1
                        'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                        call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ((Quantidade*ValorItem) * coefPerc), nLinha, fd("FM"), fd("Sobre") )
                    end if
                end if
            else
                set prod = db.execute("select NomeProduto from produtos where id="& ProdutoID)
                if prod.eof then NomeProduto="" else NomeProduto=prod("NomeProduto") end if
                if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                    somaDesteSobre = somaDesteSobre+ (Quantidade*ValorItem)
                    'if Creditado<>"0" then
                        Despesas = Despesas + (Quantidade*ValorItem)
                    'end if
                    linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID

                    nLinha = nLinha+1
                    'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                    call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ((Quantidade*ValorItem) * coefPerc), nLinha, fd("FM"), fd("Sobre") )
                end if
            end if
        end if
        'Equipe do procedimento (E)
        if fd("FM")="E" then
            set eq = db.execute("select * from procedimentosequipeparticular where ProcedimentoID="& ii("ItemID"))
            while not eq.eof
                Funcao = eq("Funcao")
                Valor = eq("Valor")
                TipoValor = eq("TipoValor")
                ShowValor = calcValor(Valor, TipoValor, ValorBase, "show")
                ValorItem = calcValor(Valor, TipoValor, ValorBase, "calc")
                ContaCredito = eq("ContaPadrao")
                if eq("ContaPadrao")="PRO" then
                    ContaCredito = ii("Associacao")&"_"&ii("ProfissionalID")
                elseif ContaPadrao="" then
                    'sqliio = "select * from itensinvoiceoutros where ItemInvoiceID="& ItemInvoiceID &" AND FuncaoID="& FuncaoID &" AND FuncaoEquipeID="& eq("id") - ESSE DEU RUIM PQ TINHA FUNCAOID Q NAO TAVA BATENDO
                    sqliio = "select * from itensinvoiceoutros where ItemInvoiceID="& ItemInvoiceID &" AND FuncaoEquipeID="& eq("id")
                    'response.write(sqliio)
                    set iio = db.execute( sqliio )
                    if not iio.eof then
                        ContaCredito = iio("Conta")
                    end if
                end if
                Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
                if Creditado<>"" then
                    somaDesteSobre = somaDesteSobre + ValorItem
                    if Creditado<>"0" then
                        Despesas = Despesas + ValorItem
                    end if
                    linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID

                    call lrResult( "Calculo", rDataExecucao, Funcao, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ValorItem * coefPerc, lrLinha, lrFM, fd("Sobre") )

                end if
                'db_execute("insert into temprepasse (ItemInvoiceID, ItemGuiaID, Funcao, TipoValor, Valor, ContaCredito, FormaID, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysUser, FuncaoID) VALUES ("& ItemInvoiceID &", "& ItemGuiaID &", '"& Funcao &"', '"& TipoValor &"', "& treatvalzero(Valor) &", '"& ContaCredito &"', "& FormaID &", "& Sobre &", '"& FM &"', "& treatvalzero(ProdutoID) &", "& treatvalzero(ValorUnitario) &", "& treatvalzero(Quantidade) &", "& sysUser &", "& FuncaoID &")")
                

            eq.movenext
            wend
            eq.close
            set eq=nothing
        end if
        'Materiais de Kit do Procedimento (K)
        if fd("FM")="K" then
            'primeiro puxa só os produtos que não possuem variação (ver se quando nao muda ele grava)
            'depois sai listando as variações
            set kit = db.execute("select pdk.id ProdutoDoKitID, pdk.Valor, pdk.ContaPadrao, pdk.Quantidade, pdk.ProdutoID, pdk.Variavel from procedimentoskits pk LEFT JOIN produtosdokit pdk ON pk.KitID=pdk.KitID WHERE pk.Casos LIKE '%|P|%' AND pk.ProcedimentoID="& ProcedimentoID)
            while not kit.eof
                NomeProduto = ""
                Quantidade = kit("Quantidade")
                ValorUnitario = kit("Valor")
                ContaPadrao = kit("ContaPadrao")
                ContaCredito = ContaPadrao
                ProdutoID = kit("ProdutoID")
                TipoValor = "V"
                if not isnull(ProdutoID) then
                    set prod = db.execute("select NomeProduto from produtos where id="& ProdutoID)
                    if not prod.eof then
                        NomeProduto = prod("NomeProduto")
                    end if
                end if
                Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
                if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                    'somaDesteSobre = somaDesteSobre + (Quantidade * ValorUnitario)
                    'if Creditado<>"0" then
                    '    Despesas = Despesas + (Quantidade*ValorUnitario)
                    'end if







                    ValorItem = ValorUnitario


                    if kit("Variavel")="S" then

                        set vcaLancto = db.execute("select * from estoquelancamentos where ItemInvoiceID="& ItemInvoiceID &" AND ProdutoID="& ProdutoID &" AND EntSai='S'")
                        if not vcaLancto.EOF then
                            QuantidadeUnitariaUsada = 0
                            while not vcaLancto.EOF
                                QuantidadeUnitariaUsada = QuantidadeUnitariaUsada + vcaLancto("QuantidadeTotal")
                            vcaLancto.movenext
                            wend
                            vcaLancto.close
                            set vcaLancto=nothing

                            Quantidade = QuantidadeUnitariaUsada

                            set prod = db.execute("select NomeProduto from produtos where id="& ProdutoID)
                            if prod.eof then NomeProduto="" else NomeProduto=prod("NomeProduto") end if
                            if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                                somaDesteSobre = somaDesteSobre+ (Quantidade*ValorItem)
                                'if Creditado<>"0" then
                                    Despesas = Despesas + (Quantidade*ValorItem)
                                'end if
                                linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID

                                nLinha = nLinha+1
                                'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                                call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ((Quantidade*ValorItem) * coefPerc), nLinha, fd("FM"), fd("Sobre") )
                            end if
                        end if


                    else
                        set prod = db.execute("select NomeProduto from produtos where id="& ProdutoID)
                        if prod.eof then NomeProduto="" else NomeProduto=prod("NomeProduto") end if
                        if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                            somaDesteSobre = somaDesteSobre+ (Quantidade*ValorItem)
                            'if Creditado<>"0" then
                                Despesas = Despesas + (Quantidade*ValorItem)
                            'end if
                            linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID

                            nLinha = nLinha+1
                            'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                            call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ((Quantidade*ValorItem) * coefPerc), nLinha, fd("FM"), fd("Sobre") )
                        end if
                    end if















  '                  linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade * ValorUnitario) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual

                end if
            kit.movenext
            wend
            kit.close
            set kit = nothing
        end if


        'Materiais baixados no estoque não predefinidos (Q)
        if fd("FM")="Q" then

            set prodsEnv = db.execute("select concat(' AND ProdutoID NOT IN (', group_concat(t.ProdutoID), ')') ProdutosEnvolvidos from (select rf.ProdutoID from rateiofuncoes rf where rf.FM='M' and rf.dominioID="& DominioID &" union all select pdk.ProdutoID from produtosdokit pdk left join procedimentoskits pk on pk.KitID=pdk.KitID where pk.ProcedimentoID="& ProcedimentoID &") t")
            sqlProdutosEnvolvidos = prodsEnv("ProdutosEnvolvidos")

            Creditado = 0
            ValorItem = calcValor(Valor, TipoValor, ValorBase, "calc")
            set vcaLancto = db.execute("select * from estoquelancamentos where ItemInvoiceID="& ItemInvoiceID & sqlProdutosEnvolvidos &"  AND EntSai='S'")
            while not vcaLancto.EOF
                ProdutoID = vcaLancto("ProdutoID")

                if vcaLancto("TipoUnidade")="C" then
                    Quantidade = vcaLancto("QuantidadeTotal")
                else
                    Quantidade = vcaLancto("Quantidade")
                end if

                set prod = db.execute("select NomeProduto from produtos where id="& ProdutoID)
                if prod.eof then NomeProduto="" else NomeProduto=prod("NomeProduto") end if
                if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                    somaDesteSobre = somaDesteSobre + (Quantidade*vcaLancto("Valor"))

                    'if Creditado<>"0" then
                        Despesas = Despesas + (Quantidade*vcaLancto("Valor"))
                    'end if
                    linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID

                    nLinha = nLinha+1
                    'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                    call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, Quantidade*(vcaLancto("Valor") * coefPerc), nLinha, fd("FM"), fd("Sobre") )
                end if
            vcaLancto.movenext
            wend
            vcaLancto.close
            set vcaLancto=nothing
        end if



        'Grava (F) e (M)
        if gravaTemp=1 then
            'db_execute("insert into temprepasse (ItemInvoiceID, ItemGuiaID, Funcao, TipoValor, Valor, ContaCredito, FormaID, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysUser, FuncaoID) VALUES ("& ItemInvoiceID &", "& ItemGuiaID &", '"& Funcao &"', '"& TipoValor &"', "& treatvalzero(Valor) &", '"& ContaCredito &"', "& FormaID &", "& Sobre &", '"& FM &"', "& treatvalzero(ProdutoID) &", "& treatvalzero(ValorUnitario) &", "& treatvalzero(Quantidade) &", "& sysUser &", "& FuncaoID &")")
        end if
        ultimoSobre = Sobre
    fd.movenext
    wend
    fd.close
    set fd=nothing
end function

'Item particular onde ele é o profissional executante
'Item da SADT onde ele é o profissional executante
'Item da Guia de Consulta onde ele é o profissional executante
'Item da Guia de Honorário onde ele é o profissional executante
'Todas as regras onde esse profissional seja mencionado
'Todas as regras onde esse profissional seja mencionado na equipe
'Todas as invoiceoutros onde ele esteja mencionado

De = req("De")
Ate = req("Ate")
StatusBusca = req("Status")
%>


<form method="post" id="frmRepasses" name="frmRepasses">

            <%
            ContaProfissional = ""
            if req("AccountID")<>"" and req("AccountID")<>"0" then
                ContaProfissionalSplt =split(req("AccountID"),"_")
                ContaProfissional = " AND ii.Associacao="&ContaProfissionalSplt(0)&" AND ii.ProfissionalID="&ContaProfissionalSplt(1)
            end if
            'db_execute("delete from temprepasse where sysUser="&session("User"))
            set ii = db.execute("select ii.*, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento, pac.NomePaciente from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN pacientes pac ON pac.id=i.AccountID WHERE ii.DataExecucao BETWEEN "& mydatenull(De) &" and "& mydatenull(Ate)&" AND ii.Executado='S' AND ii.Tipo='S' and i.AssociationAccountID=3 "&ContaProfissional&" ORDER BY ii.DataExecucao")
                'se ii("Repassado")=0 joga pra temprepasse, else exibe o q ja foi pra rateiorateios
            while not ii.eof

                ProfissionalExecutante = ii("Associacao") &"_"& ii("ProfissionalID")
                ItemInvoiceID = ii("id")
                InvoiceID = ii("InvoiceID")
                ProcedimentoID = ii("ItemID")
                DataExecucao = ii("DataExecucao")
                NomeProcedimento = ii("NomeProcedimento")
                ValorProcedimento = ii("Quantidade") * ( ii("ValorUnitario") - ii("Desconto") + ii("Acrescimo") )
                NomePaciente = ii("NomePaciente")

                PercentualPago = 0
                TotalPago = 0
                TotalRepassado = 0
                PercentualRepassado = 0


                contaLR = 0

                'ValorNaoPago = 0

                idPanel = ii("id")
                %>
                <div class="panel mn mt10" id="panel<%= idPanel %>">
                    <div class="panel-heading mn pn">
                        <div class="row panel-title pn mn">
                            <small class="col-xs-2">
                                Execução: <%= DataExecucao %>
                            </small>
                            <small class="col-xs-3">
                                 Procedimento: <a target="_blank" href="./?P=Invoice&Pers=1&CD=C&I=<%= InvoiceID %>"><%= NomeProcedimento %></a>
                            </small>
                            <small class="col-xs-3">
                                Paciente: <%= NomePaciente %>
                            </small>
                            <small class="col-xs-2">
                                Valor: <%= fn(ValorProcedimento) %>
                            </small>
                        </div>
                    </div>
                    <div class="panel-body">
                        <table class="table table-hover table-condensed">
                            <thead>
                                <tr class="dark">
                                    <th width="1%"></th>
                                    <th width="35%">Função / Item</th>
                                    <th width="35%">Creditado</th>
                                    <th>$ Repasse</th>
                                </tr>
                <%
ItensDescontadosConsolidados = ""
ParcelasCartaoConsolidadas = ""

'1a. situação: lista todos os descontos que foram repassados
                GrupoConsolidacao = 0
                set rr = db.execute("select rr.*, pm.PaymentMethod from rateiorateios rr LEFT JOIN itensdescontados idesc ON idesc.id=rr.ItemDescontadoID LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN cliniccentral.sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID where rr.ItemInvoiceID="& ii("id") &" and rr.ItemDescontadoID!=0 order by GrupoConsolidacao")
                while not rr.eof

                    numeroParcela = ""
                    numeroParcelas = ""
                    ParcelasCartaoConsolidadas = ParcelasCartaoConsolidadas & "|"& rr("ParcelaID") &"|"
                    ItensDescontadosConsolidados = ItensDescontadosConsolidados & "|"& rr("ItemDescontadoID") &"|"

                    if GrupoConsolidacao<>rr("GrupoConsolidacao") then

                        if rr("ParcelaID")>0 then
                            set nParc = db.execute("select (select count(id) from sys_financialcreditcardreceiptinstallments where TransactionID=cc.TransactionID) nParcelas, cc.Parcela from sys_financialcreditcardreceiptinstallments cc where cc.id="& rr("ParcelaID"))
                            if not nParc.EOF then
                                numeroParcela = nParc("Parcela")
                                numeroParcelas = nParc("nParcelas")
                            end if
                        end if

                        'btnExtra = "<button type='button' id='desconsolidar"&&"' class='btn btn-xs btn-danger pull-right'>Desconsolidar</button>"
                        
                        if StatusBusca="" or StatusBusca="C" then
                            call tituloTabelaRepasse("dark", "Consolidado", rr("ItemInvoiceID"), rr("ItemDescontadoID"), rr("PaymentMethod"), numeroParcela, numeroParcelas, ValorRecebido, rr("ParcelaID"), btnExtra)
                        end if
                        Percentual = rr("Percentual")
                        PercentualPago = PercentualPago+Percentual
                        PercentualRepassado = PercentualRepassado + Percentual
                    end if
                    GrupoConsolidacao = rr("GrupoConsolidacao")

                    if StatusBusca="" or StatusBusca="C" then
                        call lrResult( "RateioRateios", rDataExecucao, rr("Funcao"), rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, rr("ContaCredito"), rValorProcedimento, rValorRecebido, rr("Valor"), nLinha, rr("FM"), rr("Sobre") )
                    end if
                rr.movenext
                wend
                rr.close
                set rr=nothing


'2a. verifica se foi repassado sem pagamento e finaliza aqui, nem prossegue pros próximos
                set rr = db.execute("select GrupoConsolidacao, Percentual from rateiorateios where ItemInvoiceID="& ItemInvoiceID &" and itemDescontadoID=0 GROUP BY GrupoConsolidacao")
                if not  rr.eof then
                    Percentual = rr("Percentual")
                    PercentualRepassado = PercentualRepassado + Percentual

                    if StatusBusca="" or StatusBusca="C" then
                        'call tituloTabelaRepasse("dark", "Consolidado sem recebimento", -1, 0, "", "", 0, "")
                        %>
                        <tr class="dark">
                            <td colspan="6">
                                <div class="row">
                                    <div class="col-md-3">{2} Consolidado sem recebimento</div>
                                    <div class="col-md-3">Valor Recebido: <%=ValorRecebido %></div>
                                    <div class="col-md-3">Valor Compensado: 0,00</div>
                                </div>
                            </td>
                        </tr>
                        <%
                    'response.write("<br /> ITENS NAO PAGOS ("& Percentual &"%) lista mais rr deste procedimento")
                    call listaRR( DataExecucao, InvoiceID, ItemInvoiceID, NomeProcedimento, NomePaciente, "Não recebido", ValorProcedimento, ValorRecebido, 0 )
                    end if
                end if


'3a. situação: verifica repasses que foram recebidos do pacte mas ainda nao foram consolidados
                if PercentualRepassado<100 then
                    set pagtos = db.execute("select idesc.*, m.PaymentMethodID, pm.PaymentMethod, idesc.Valor, m.Date, m.AccountIDDebit FROM itensdescontados idesc LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE idesc.ItemID="& ii("id")&"")
                    while not pagtos.eof

                        NomeMetodo = pagtos("PaymentMethod")

                        ExisteParcelaCompensada = 0
                        if PercentualRepassado<100 then

                            if pagtos("PaymentMethodID")=8 or pagtos("PaymentMethodID")=9 then

                                NomeMetodo = accountName(1, pagtos("AccountIDDebit"))

                                set vcaRepParc = db.execute("select rr.id from rateiorateios rr WHERE rr.ItemDescontadoID="& pagtos("id") &" AND rr.ParcelaID>0 LIMIT 1")
                                if not vcaRepParc.eof then
                                    ExisteParcelaCompensada = 1
                                end if
                            end if
                            if (pagtos("PaymentMethodID")=8 or pagtos("PaymentMethodID")=9) and (dividirCompensacao="S" OR ExisteParcelaCompensada=1) then
                                cParc = 0
                                set parcs = db.execute("select parc.id, parc.Value BrutoParcela, parc.Fee, parc.InvoiceReceiptID, parc.Parcela, t.Parcelas FROM sys_financialcreditcardreceiptinstallments parc LEFT JOIN sys_financialcreditcardtransaction t ON t.id=parc.TransactionID WHERE t.MovementID="& pagtos("PagamentoID") &" ORDER BY DateToReceive")
                                while not parcs.eof

                                    if instr(ParcelasCartaoConsolidadas, "|"& parcs("id") &"|")=0 then






                                    'REAJUSTAR PROPORCOES
                                    'era individual ->
                                    'nos pagamentos separar antes em pagtos repassados e depois os pagtos a repassar
                                    ultimoSobre = ""
                                    somaDesteSobre = 0
                                    ValorBase = ValorProcedimento
                                    DominioID = dominioRepasse("|P|", ii("ProfissionalID"), ProcedimentoID, ii("CompanyUnitID"))
                                    Despesas = 0




                                    ValorPago = pagtos("Valor")
                                    Fator = ValorPago / ValorBase
                                    Percentual = (Fator * 100)/ccur(parcs("Parcelas"))
                                    PercentualPago = PercentualPago+Percentual
                                    PercentualRepassado = PercentualRepassado + Percentual
                                    TotalPago = TotalPago + ValorPago
                                    ItemDescontadoID = pagtos("id")
                                    '<- era individual








                                        cParc = cParc+1
                                        ValorParcela = pagtos("Valor")/ccur(parcs("Parcelas"))
                                        Exibir=0
                                        if parcs("InvoiceReceiptID")=0 then
                                            Classe = "danger"
                                            
                                            if StatusBusca="S" then
                                                Exibir=0
                                            end if
                                            if StatusBusca="N" then
                                                Exibir=1
                                            end if
                                        else
                                            Classe = "success"
                            
                                            if StatusBusca="S" then
                                                Exibir=1
                                            end if
                                            if StatusBusca="N" then
                                                Exibir=0
                                            end if
                                        end if
                                        
                                        
                                        ParcelaPaga = "danger"
                                        
                                        if Exibir=1 OR StatusBusca="" then
                                        call tituloTabelaRepasse(Classe, "Não consolidado", pagtos("ItemID"), pagtos("id"), NomeMetodo, parcs("Parcela"), parcs("Parcelas"), ValorParcela, parcs("id"), "")
    
                                        call repasse( DataExecucao, InvoiceID, NomeProcedimento, NomePaciente, pagtos("PaymentMethod"), ValorProcedimento, pagtos("Valor"), Percentual, parcs("id"), pagtos("AccountIDDebit") )
                                        end if

                                        'response.write( Percentual & " - " & PercentualPago & ", " )



                                    end if
                                parcs.movenext
                                wend
                                parcs.close
                                set parcs=nothing
                            else
                                if instr(ItensDescontadosConsolidados, "|"& pagtos("id") &"|")=0 then
                                    'era individual ->
                                    'nos pagamentos separar antes em pagtos repassados e depois os pagtos a repassar
                                    ultimoSobre = ""
                                    somaDesteSobre = 0
                                    ValorBase = ValorProcedimento
                                    DominioID = dominioRepasse("|P|", ii("ProfissionalID"), ProcedimentoID, ii("CompanyUnitID"))
                                    Despesas = 0




                                    ValorPago = pagtos("Valor")
                                    Fator = ValorPago / ValorBase
                                    Percentual = Fator * 100
                                    PercentualPago = PercentualPago+Percentual
                                    PercentualRepassado = PercentualRepassado + Percentual
                                    TotalPago = TotalPago + ValorPago
                                    ItemDescontadoID = pagtos("id")
                                    '<- era individual
                                    'response.write("<br /> Pagamento: "& ValorPago &" ( "& Percentual &"% )")
                           ' function tituloTabelaRepasse(Classe, Titulo, ItemInvoiceID, PagtoID, FormaPagto, NumeroParcela, Parcelas, ValorRecebido, ParcelaID)
                                    if StatusBusca="" or StatusBusca="S" then
                                        call tituloTabelaRepasse("success", "Não consolidado", pagtos("ItemID"), pagtos("id"), NomeMetodo, 1, 1, pagtos("Valor"), 0, "")

                                        call repasse( DataExecucao, InvoiceID, NomeProcedimento, NomePaciente, pagtos("PaymentMethod"), ValorProcedimento, pagtos("Valor"), Percentual, 0, pagtos("AccountIDDebit") )
                                    end if
                                    'response.write( Percentual & " - " & PercentualPago & ", " )


                                end if
                            end if
                        end if
                    pagtos.movenext
                    wend
                    pagtos.close
                    set pagtos = nothing

                    PercentualNaoPago = 100 - PercentualPago
                    ValorNaoPago = ValorProcedimento - TotalPago
                end if


'4a. situacao: repasses nem recebidos do pacte nem consolidados
                           ' response.write(PercentualNaoPago)
                if PercentualRepassado<98 then
                    if PercentualNaoPago>2 then
                        ultimoSobre = ""
                        somaDesteSobre = 0
                        ValorBase = ValorProcedimento
                        DominioID = dominioRepasse("|P|", ii("ProfissionalID"), ProcedimentoID, ii("CompanyUnitID"))
                        Despesas = 0
                        ItemDescontadoID = 0
                        ValorNaoRecebido = ValorBase * fn((PercentualNaoPago/100))

                        Percentual = PercentualNaoPago

                        'response.write("<br /> Não Pago: "& ValorNaoPago &" ( "& PercentualNaoPago &"% )")
                        if StatusBusca="" or StatusBusca="N" then
                            call tituloTabelaRepasse("danger", "Não recebido: "& ValorNaoRecebido, ItemInvoiceID, 0, "", "", "", 0, 0, "")

                            call repasse( DataExecucao, InvoiceID, NomeProcedimento, NomePaciente, "Pendente", ValorProcedimento, 0, Percentual, 0, "" )
                        end if
                    end if
                end if

  '              response.write("Resultado: "& ValorProcedimento &" - "& Despesas)
                
                    %>
                        </table>
                    </div>
                </div>
                    <%
                    if contaLR=0 then
                        %>
                        <script type="text/javascript">$("#panel<%=idPanel %>").css("display", "none");</script>
                        <%
                    else
                        totalProcedimentos = totalProcedimentos + ValorProcedimento
                    end if
            ii.movenext
            wend
            ii.close
            set ii = nothing

            %>
</form>
<hr class="short alt" />
<div class="panel"><div class="panel-body">
    <table class="table table-condensed table-bordered">
        <thead>
            <tr>
                <th width="25%" class="text-center">Total Serviços</th>
                <th width="25%" class="text-center">Total Repasses</th>
                <th width="25%" class="text-center">Total Materiais</th>
                <th width="25%" class="text-center">Total Resultado</th>
            </tr>
        </thead>
        <tbody>
                <th width="25%" class="text-right"><%= fn(totalProcedimentos) %></th>
                <th width="25%" class="text-right"><%= fn(totalRepasses) %></th>
                <th width="25%" class="text-right"><%= fn(totalMateriais) %></th>
                <th width="25%" class="text-right"><%= fn( totalProcedimentos - totalRepasses - totalMateriais ) %></th>
        </tbody>
    </table>
</div></div>