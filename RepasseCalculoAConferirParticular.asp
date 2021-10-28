<!--#include file="connect.asp"-->
<%

if reqf("InvoiceID")<>"" and 0 then
    db_execute("delete from temp_nfsplit where sysUser="& session("User"))
end if

dividirCompensacao = reqf("dividirCompensacao")

totalRepasses = 0
totalMateriais = 0
ultimoSobre = 0
totalProcedimentos = 0
totalTaxas = 0
response.Buffer

function buttonDetalharDominio(itemId)
    buttonDetalharDominio="<div class='pb5 ' style='float: right'>" &_
                          "<button title='Detalhar regras de repasse' data-toggle='tooltip' onclick='detalhaDominio(""itensinvoice"","""&itemId&""")' type='button' class='btn btn-default btn-xs'><i class='far fa-question-circle'></i></button>" &_
                          "</div>"
end function

private function tituloTabelaRepasse(Classe, Titulo, ItemInvoiceID, PagtoID, FormaPagto, NumeroParcela, Parcelas, ValorRecebido, ParcelaID, Extras)

    %>
        <td width="50%" style="vertical-align:top">
            <%if Classe<>"dark" then %>
                <div class="checkbox-custom checkbox-<%= Classe %> ptn mtn">
                    <input type="checkbox" name="linhaRepasse" value="<%= ItemInvoiceID &"_"& PagtoID  &"_"& ParcelaID %>" id="<%= ItemInvoiceID &"_"& PagtoID  &"_"& ParcelaID %>"><label for="<%= ItemInvoiceID &"_"& PagtoID  &"_"& ParcelaID %>"> <%= Titulo %>: <%= FormaPagto %> - <%= NumeroParcela &"/"& Parcelas %> </label>
                </div>
            <% else %>
            <div><strong><%= Titulo %></strong></div>
            <% end if
            if ValorRecebido>0 then
                %>
                <div>Recebido: <%= fn(ValorRecebido) %></div>
                <%
            end if
            %>
            <div><%= Extras %></div>
        </td>
    <%

end function

private function calcCreditado(ContaCredito, ProfissionalExecutante)
    if ContaCredito="PRO" then
        calcCreditado = ProfissionalExecutante
    elseif ContaCredito="LAU" then
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
    set rr = db.execute("select rr.*, rf.DominioID from rateiorateios rr LEFT JOIN rateiofuncoes rf ON rr.FuncaoID=rf.id where rr.ItemInvoiceID="& rItemInvoiceID &" and rr.ItemDescontadoID="& ItemDescontadoID)
    nLinha = 0
    while not rr.eof
        nLinha = nLinha+1

        call lrResult( "RateioRateios", rDataExecucao, rr("DominioID") &": "& replace(rr("Funcao")&"","|","_"), rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, rr("ContaCredito"), rValorProcedimento, rValorRecebido, rr("Valor"), nLinha, rr("FM"), rr("Sobre"), rr("modoCalculo") )
    rr.movenext
    wend
    rr.close
    set rr=nothing
end function


private function repasse( rDataExecucao, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, rValorProcedimento, rValorRecebido, rPercentual, ParcelaID, rContaPagtoID, rEspecialidadeID, rQuantidade, Parcelas)
    sqlUnion = ""
    coefPerc = rPercentual / 100
    'conferir -> FormaID pode ser |P| para todos particulares, |C| para todos convênios, |00_0| para forma predefinida de recto e > |0| para qualquer id de convênio
'    DescontoCartao = 0.05*(rValorProcedimento * coefPerc)
'    ValorBase = ValorBase - DescontoCartao
'        response.write(";;;;;;;;;;;;"& rContaPagtoID &";;;;;;;;;;;;;;")


    if rContaPagtoID<>"" and isnumeric(rContaPagtoID) and (rFormaPagto="Cartão de Crédito" or rFormaPagto="Cartão de Débito") then
        set vcaTaxa = db.execute("select * from repassesdescontos where Contas LIKE '%"& rContaPagtoID &"%' AND "&treatvalzero(Parcelas)&" BETWEEN De AND Ate")
    else
        set vcaTaxa = db.execute("select * from repassesdescontos where Contas ='' AND "&treatvalzero(Parcelas)&" BETWEEN De AND Ate")
    end if

    if not vcaTaxa.eof then
        if vcaTaxa("MetodoID") = 1 then
            tipo = "dinheiro"
        else
            tipo = "cartão"
        end if

        textoDeconto = "Desconto "&tipo
        sqlUnion = " UNION ALL SELECT '0', '"&textoDeconto&"', "& DominioID &", '"& vcaTaxa("tipoValor") &"', "& treatval(vcaTaxa("Desconto")) &", 0, 0, '-1', 'F', '0', '0', '0', '0', '', '', 'N' "
    end if

    sqlFD = "select * from (select id, Funcao, DominioID, tipoValor, Valor, ContaPadrao, sysUser, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysActive, Variavel, ValorVariavel, modoCalculo from rateiofuncoes where DominioID="& DominioID & sqlunion &") t order by t.Sobre, t.Valor"
    ' response.write( sqlFD )
    set fd = db.execute( sqlFD )
    nLinha = 0

    response.write(buttonDetalharDominio(ItemInvoiceID))
    seTemConfigAntesDasRegras = getConfig("antesDasRegras")

    while not fd.eof
        '-> Começa a coletar os dados pra temprepasses (antiga rateiorateios)
        Funcao = replace(fd("Funcao")&"","|","_")
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
        modoCalculo = fd("modoCalculo")
        if ultimoSobre&""="" then
            ultimoSobre="0"
        end if

        if seTemConfigAntesDasRegras <> 1 and Sobre = "-1" then
            Sobre = 0
        end if

        gravaTemp = 0
        if ultimoSobre&""<>Sobre&"" then
            ValorBase = ValorBase - somaDesteSobre
            somaDesteSobre = 0
        end if
        '<-
        'Funcao da arvore para conta crédito (F ou M)
        if fd("FM")="F" or fd("FM")="M" then
            if fd("ContaPadrao")="" or (fd("FM")="M" and (fd("ProdutoID")=0 or fd("Variavel")="S" or fd("ValorVariavel")="S")) then
                set iio = db.execute("select * from itensinvoiceoutros where ItemInvoiceID="& ItemInvoiceID &" AND FuncaoID="& FuncaoID)
            end if
            if fd("ValorVariavel")="S" then
                set iio = db.execute("select * from itensinvoiceoutros where ItemInvoiceID="& ItemInvoiceID &" AND FuncaoID="& FuncaoID)
                if not iio.eof then
                    Valor = iio("ValorUnitario")
                end if
            end if
            if ContaPadrao="PRO" then
                ContaCredito = ii("Associacao")&"_"&ii("ProfissionalID")
            elseif ContaPadrao="LAU" then

                set LauProf = db.execute("SELECT ProfissionalID FROM laudos WHERE Tabela='itensinvoice' AND ProfissionalID is not null AND ProfissionalID<>0 AND IDTabela="&ItemInvoiceID&" LIMIT 1")
                if not LauProf.eof then
                    ContaCredito = "5_"&LauProf("ProfissionalID")
                else
                'Caso não tenha profissional no laudo não está pegando o executante.
                    ContaCredito = "0"
                end if

                'ContaCredito = ii("Associacao")&"_"&ii("ProfissionalID")


            elseif ContaPadrao="SOL" then
                ContaCredito = ii("ProfissionalSolicitanteID")
                if ii("ProfissionalSolicitanteID")="0_1" then
                    ContaCredito = "0"
                end if
            elseif ContaPadrao="" then
                if not iio.eof then
                    ContaCredito = iio("Conta")
                end if
            end if
         
            gravaTemp = 1
        end if

        Quantidade = 1

        if rQuantidade<>"" then
            if isnumeric(rQuantidade) then
                Quantidade =rQuantidade
            end if
        end if

        if TipoValor="V" then
            Valor  = Valor * Quantidade
        end if

        'Funções estampadas
        'linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& Valor &"|"& ContaCredito &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& modoCalculo
        if fd("FM")="F" then

            if TipoValor="E" OR TipoValor="S" then
                if TipoValor="E" then
                    CV = "C"
                elseif TipoValor="S" then
                    CV = "V"
                end if

                if rInvoiceID<>"" then
                    set InvoiceSQL = db.execute("SELECT CompanyUnitID, TabelaID FROM sys_financialinvoices WHERE id="&treatvalzero(rInvoiceID))

                    if not InvoiceSQL.eof then
                        UnidadeID=InvoiceSQL("CompanyUnitID")
                        TabelaID=InvoiceSQL("TabelaID")
                    end if
                end if
                ProfissionalID = replace(ProfissionalExecutante, "5_", "")


                sqlProcedimentoTabela = "SELECT ptv.Valor, Profissionais, TabelasParticulares, Especialidades, Unidades FROM procedimentostabelasvalores ptv INNER JOIN procedimentostabelas pt ON pt.id=ptv.TabelaID WHERE ProcedimentoID="&ProcedimentoID&" AND "&_
                "(Especialidades='' OR Especialidades IS NULL OR Especialidades LIKE '%|"& rEspecialidadeID &"|%' ) AND "&_
                "(Profissionais='' OR Profissionais IS NULL OR Profissionais LIKE '%|"& ProfissionalID &"|%' ) AND "&_
                "(TabelasParticulares='' OR TabelasParticulares IS NULL OR TabelasParticulares LIKE '%|"& TabelaID &"|%' ) AND "&_
                "(Unidades='' OR Unidades IS NULL OR Unidades LIKE '%|"& UnidadeID &"|%' ) AND "&_
                "pt.Fim>=CURDATE() AND pt.Inicio<=CURDATE() AND pt.sysActive=1 AND pt.Tipo='"& CV &"' "
'                response.write(sqlProcedimentoTabela)

                set ProcedimentoVigenciaSQL = db.execute(sqlProcedimentoTabela)
                ValorTabela=0

                if not ProcedimentoVigenciaSQL.eof then
                    ultimoPonto=0

                    while not ProcedimentoVigenciaSQL.eof
                        estePonto=0


                        if instr(ProcedimentoVigenciaSQL("Profissionais")&"", "|"&ProfissionalID&"|")>0 then
                            estePonto = estePonto + 1
                        end if

                        if instr(ProcedimentoVigenciaSQL("TabelasParticulares")&"", "|"&TabelaID&"|")>0 then
                            estePonto = estePonto + 1
                        end if

                        if instr(ProcedimentoVigenciaSQL("Especialidades")&"", "|"&rEspecialidadeID&"|")>0 then
                            estePonto = estePonto + 1
                        end if
                        if instr(ProcedimentoVigenciaSQL("Unidades")&"", "|"&UnidadeID&"|")>0 then
                            estePonto = estePonto + 1
                        end if

                        if estePonto>=ultimoPonto then

							ultimoPonto=estePonto
                            ValorTabela = fn(ProcedimentoVigenciaSQL("Valor")) * (Valor / 100)
                        end if


                    ProcedimentoVigenciaSQL.movenext
                    wend
                    ProcedimentoVigenciaSQL.close
                    set ProcedimentoVigenciaSQL=nothing

                    if ValorTabela>0 then

                        ValorTabela = ValorTabela *  Quantidade
                        Valor = ValorTabela
                        'O valor base abaixo estava sendo substituida pelo valor do procedimento
                        'ValorBase = Valor
                    end if


                else
                    'Valor = 0
                    set valBase = db.execute("select Valor from procedimentos where id="& ProcedimentoID)
                    if not valBase.eof then
                        ValorBase = valBase("Valor")
                        ValorBase = ValorBase *  Quantidade
                    end if
                    TipoValor = "P"

                end if

                'response.write sqlProcedimentoTabela 
                
                
            end if

            Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
            ShowValor = calcValor(Valor, TipoValor, ValorBase, "show")
            ValorItem = calcValor(Valor, TipoValor, ValorBase, "calc")

            if Creditado<>"" then
                somaDesteSobre = somaDesteSobre+ValorItem
                if Creditado<>"0" then
                    Despesas = Despesas + ValorItem
                    if instr( Creditado, "_")=0 then
                        Creditado = "5_"& Creditado
                    end if
                end if

                linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem*coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID &"|"& modoCalculo

                %>
                <input type="hidden" name="linhaRepasse<%= ItemInvoiceID &"_"& ItemDescontadoID  &"_"& ParcelaID %>" value="<%= linhaRepasse %>" />
                <%
                nLinha = nLinha+1
                'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )

                ExibeLinha=True

                if reqf("TipoRecebedor")<>"" then
                    contaSplt = split(Creditado,"_")
                    if instr(reqf("TipoRecebedor"), "|"&contaSplt(0)&"|")=0 and Creditado&"" <> "0" then
                        ExibeLinha=False
                    end if
                end if

                if ExibeLinha then
                    descricaoRegraRepasse="AAAAAAA"

                    'CONSOLIDADO LINHA

                    call lrResult( "Calculo", rDataExecucao, DominioID & ": "& Funcao, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, (ValorItem * coefPerc), nLinha, fd("FM"), fd("Sobre"), fd("modoCalculo") )
                end if
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
                        linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID &"|"& modoCalculo

                        nLinha = nLinha+1
                        'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                        call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ((Quantidade*ValorItem) * coefPerc), nLinha, fd("FM"), fd("Sobre"), fd("modoCalculo") )
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
                    linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID &"|"& modoCalculo

                    nLinha = nLinha+1
                    'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                    call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ((Quantidade*ValorItem) * coefPerc), nLinha, fd("FM"), fd("Sobre"), fd("modoCalculo") )
                end if
            end if
        end if
        'Equipe do procedimento (E)
        if fd("FM")="E" then
            set eq = db.execute("select * from procedimentosequipeparticular where ProcedimentoID="& ii("ItemID"))
            while not eq.eof
                Funcao = replace(eq("Funcao")&"","|","_")
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
                    linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID &"|"& modoCalculo

                    call lrResult( "Calculo", rDataExecucao, Funcao, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ValorItem * coefPerc, lrLinha, lrFM, fd("Sobre"), fd("modoCalculo") )

                end if
                'db_execute("insert into temprepasse (ItemInvoiceID, ItemGuiaID, Funcao, TipoValor, Valor, ContaCredito, FormaID, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysUser, FuncaoID) VALUES ("& ItemInvoiceID &", "& ItemGuiaID &", '"& Funcao &"', '"& TipoValor &"', "& treatvalzero(Valor) &", '"& ContaCredito &"', "& FormaID &", "& Sobre &", '"& FM &"', "& treatvalzero(ProdutoID) &", "& treatvalzero(ValorUnitario) &", "& treatvalzero(Quantidade) &", "& sysUser &", "& FuncaoID &")")
                
                Response.Flush()
            eq.movenext
            wend
            eq.close
            set eq=nothing
        end if
        'Materiais de Kit do Procedimento (K)
        if fd("FM")="K" then
            'primeiro puxa só os produtos que não possuem variação (ver se quando nao muda ele grava)
            'depois sai listando as variações
            set kit = db.execute("select pdk.id ProdutoDoKitID, pdk.Valor, if(pdk.ContaPadrao='' or pdk.ContaPadrao is null, 0 , pdk.ContaPadrao) ContaPadrao, pdk.Quantidade, pdk.ProdutoID, pdk.Variavel from procedimentoskits pk LEFT JOIN produtosdokit pdk ON pk.KitID=pdk.KitID WHERE pk.Casos LIKE '%|P|%' AND pk.ProcedimentoID="& ProcedimentoID)
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

                            if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                                somaDesteSobre = somaDesteSobre+ (Quantidade*ValorItem)
                                'if Creditado<>"0" then
                                    Despesas = Despesas + (Quantidade*ValorItem)
                                'end if
                                linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID &"|"& modoCalculo

                                nLinha = nLinha+1
                                'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )

                                call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ((Quantidade*ValorItem) * coefPerc), nLinha, fd("FM"), fd("Sobre"), fd("modoCalculo") )
                            end if
                        end if


                    else
                        if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                            somaDesteSobre = somaDesteSobre+ (Quantidade*ValorItem)
                            'if Creditado<>"0" then
                                Despesas = Despesas + (Quantidade*ValorItem)
                            'end if
                            linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID &"|"& modoCalculo

                            nLinha = nLinha+1
                            'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )

                            call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, ((Quantidade*ValorItem) * coefPerc), nLinha, fd("FM"), fd("Sobre"), fd("modoCalculo") )
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
                    linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID &"|"& modoCalculo

                    nLinha = nLinha+1
                    'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                    call lrResult( "Calculo", rDataExecucao, NomeProduto, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, Quantidade*(vcaLancto("Valor") * coefPerc), nLinha, fd("FM"), fd("Sobre"), fd("modoCalculo") )
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

De = reqf("De")
Ate = reqf("Ate")
StatusBusca = reqf("Status")
if reqf("Unidades")="" then
    Unidades = session("Unidades")&""
else
    Unidades = reqf("Unidades")
end if
%>


<form method="post" id="frmRepasses" name="frmRepasses">
    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title">Repasses Particulares</span>
        </div>
        <div class="panel-body">
                <table class="table table-condensed table-bordered table-hover">
                    <thead>
                        <th width="2%"></th>
                        <th>Execução</th>
                        <th>Paciente</th>
                        <th>Unidade</th>
                        <th>Data da Conta</th>
                        <th>Solicitante</th>
                        <th>Especialidade</th>
                        <th>Procedimento</th>
                        <th>Valor</th>
                    </thead>
                    <tbody>

            <%


            AccountID = reqf("AccountID")
            ContaProfissional = ""

            if AccountID<>"" and AccountID<>"0" then
                ContaProfissionalSplt =split(reqf("AccountID"),"_")
                ContaProfissional = " AND ii.Associacao="&ContaProfissionalSplt(0)&" AND ii.ProfissionalID="&ContaProfissionalSplt(1) &" "
            end if
            if Unidades<>"" then
                sqlUnidades = " AND i.CompanyUnitID IN ("& replace(Unidades, "|", "") &") "
            end if
            'db_execute("delete from temprepasse where sysUser="&session("User"))

            ExibirNaoExecutado = reqf("ExibirNaoExecutado")
            ExecutadoStatus="S"

            if ExibirNaoExecutado="S" then
                ExecutadoStatus=""
            end if


            if reqf("ProcedimentoID")<>"0" then
                if instr(reqf("ProcedimentoID"), "G")>0 then
                    set procsGP = db.execute("select group_concat(id) procs from procedimentos where GrupoID="& replace(reqf("ProcedimentoID"), "G", ""))
                    procs=procsGP("procs")

                    if isnull(procs) then
                        sqlProcedimento = " AND ii.ItemID IN (-1) "
                    else
                        sqlProcedimento = " AND ii.ItemID IN ("& procs &") "
                    end if
                else
                    sqlProcedimento = " AND ii.ItemID="& reqf("ProcedimentoID") &" "
                end if
            end if

            if reqf("InvoiceID")<>"" and 0 then
                'sqlII = "select ii.*,i.ProfissionalSolicitante, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, i.TabelaID, proc.NomeProcedimento, pac.NomePaciente from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN pacientes pac ON pac.id=i.AccountID WHERE i.id="& reqf("InvoiceID") &" AND ii.Executado='"&ExecutadoStatus&"' AND ii.Tipo='S' and i.AssociationAccountID=3 "&ContaProfissional & sqlUnidades &" ORDER BY ii.DataExecucao"&_
                sqlII = "select r.*, t.Nomelocal CompanyUnit, esp.especialidade,s.NomeProfissional ProfissionalSolicitante, r.ProfissionalSolicitante ProfissionalSolicitanteID from ( "&_
                        "select ii.*,i.ProfissionalSolicitante, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, i.TabelaID, proc.NomeProcedimento, pac.NomePaciente from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN pacientes pac ON pac.id=i.AccountID WHERE i.id="& reqf("InvoiceID") &" AND ii.Executado='"&ExecutadoStatus&"' AND ii.Tipo='S' and i.AssociationAccountID=3 "&ContaProfissional & sqlUnidades &" ORDER BY ii.DataExecucao"&_
                        ") r"&_
                        " LEFT JOIN especialidades esp ON esp.id = r.EspecialidadeID"&_
                        " LEFT JOIN (( SELECT 0 AS 'id', NomeFantasia NomeLocal FROM empresa WHERE id=1) UNION ALL ( SELECT id, NomeFantasia FROM sys_financialcompanyunits)) t ON t.id = r.CompanyUnitID"&_
                        " LEFT JOIN ("&_
                        " SELECT s.id, s.NomeProfissional"&_
                        " FROM ("&_
                        " SELECT CONCAT('0_', id) id, NomeEmpresa NomeProfissional"&_
                        " FROM empresa UNION ALL"&_
                        " SELECT CONCAT('5_', id) id, NomeProfissional"&_
                        " FROM profissionais UNION ALL"&_
                        " SELECT CONCAT('8_', id) id, NomeProfissional"&_
                        " FROM profissionalexterno) s) s ON s.id = r.ProfissionalSolicitante "
            elseif reqf("AC")="1" then
                'sqlII = "select r.id ReconsolidacaoID, ii.*, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, i.TabelaID, proc.NomeProcedimento, pac.NomePaciente FROM reconsolidar r LEFT JOIN itensinvoice ii ON (ii.InvoiceID=r.ItemID and r.tipo='invoice') LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN pacientes pac ON pac.id=i.AccountID WHERE NOT ISNULL(ii.InvoiceID)" & sqlUnidades
                sqlII = "select rs.*, t.Nomelocal CompanyUnit, esp.especialidade,s.NomeProfissional ProfissionalSolicitante, rs.ProfissionalSolicitante ProfissionalSolicitanteID from ("&_
                        "select r.id ReconsolidacaoID, ii.*, i.ProfissionalSolicitante, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, i.TabelaID, proc.NomeProcedimento, pac.NomePaciente FROM reconsolidar r LEFT JOIN itensinvoice ii ON (ii.InvoiceID=r.ItemID and r.tipo='invoice') LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN pacientes pac ON pac.id=i.AccountID WHERE ii.Executado='S' AND ii.Associacao>0 AND NOT ISNULL(ii.InvoiceID)" & sqlUnidades &") rs"&_
                        " LEFT JOIN especialidades esp ON esp.id = rs.EspecialidadeID"&_
                        " LEFT JOIN (( SELECT 0 AS 'id', NomeFantasia NomeLocal FROM empresa WHERE id=1) UNION ALL ( SELECT id, NomeFantasia FROM sys_financialcompanyunits)) t ON t.id = rs.CompanyUnitID"&_
                        " LEFT JOIN ("&_
                        " SELECT s.id, s.NomeProfissional"&_
                        " FROM ("&_
                        " SELECT CONCAT('0_', id) id, NomeEmpresa NomeProfissional"&_
                        " FROM empresa UNION ALL"&_
                        " SELECT CONCAT('5_', id) id, NomeProfissional"&_
                        " FROM profissionais UNION ALL"&_
                        " SELECT CONCAT('8_', id) id, NomeProfissional"&_
                        " FROM profissionalexterno) s) s ON s.id = rs.ProfissionalSolicitante "
            
            elseif reqf("TipoData")="Comp" then
                'sqlII = "select ii.*, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, i.TabelaID, proc.NomeProcedimento, pac.NomePaciente from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN pacientes pac ON pac.id=i.AccountID WHERE ii.DataExecucao BETWEEN "& mydatenull(De) &" and "& mydatenull(Ate)&" AND ii.Executado='"&ExecutadoStatus&"' AND ii.Tipo='S' and i.AssociationAccountID=3 "&ContaProfissional & sqlProcedimento & " ORDER BY ii.DataExecucao"
                'sqlII = "select r.id ReconsolidacaoID, ii.*, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, i.TabelaID, proc.NomeProcedimento, pac.NomePaciente FROM reconsolidar r LEFT JOIN itensinvoice ii ON (ii.InvoiceID=r.ItemID and r.tipo='invoice') LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN pacientes pac ON pac.id=i.AccountID WHERE NOT ISNULL(ii.InvoiceID)"& sqlUnidades
                sqlII = "select r.*, t.Nomelocal CompanyUnit, esp.especialidade,s.NomeProfissional ProfissionalSolicitante, r.ProfissionalSolicitante ProfissionalSolicitanteID from (SELECT "&_
"ii.*, i.FormaID, i.ContaRectoID, i.ProfissionalSolicitante, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, i.TabelaID, proc.NomeProcedimento, pac.NomePaciente "&_
"FROM sys_financialmovement m "&_
"LEFT JOIN sys_financialcreditcardreceiptinstallments ccr ON ccr.InvoiceReceiptID=m.id "&_
"LEFT JOIN sys_financialcreditcardtransaction t ON t.id=ccr.TransactionID "&_
"LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=t.MovementID "&_
"LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID "&_
"LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
"LEFT JOIN pacientes pac ON (pac.id=i.AccountID AND i.AssociationAccountID=3) "&_
"LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
"WHERE m.Date BETWEEN "&_
" "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND NOT ISNULL(t.id) AND ii.Executado='"&ExecutadoStatus&"' AND ii.Associacao>0 AND ii.Tipo='S' and i.AssociationAccountID=3 "& ContaProfissional & sqlProcedimento &_
                " UNION ALL "&_
"SELECT ii.*, i2.FormaID, i2.ContaRectoID, i2.ProfissionalSolicitante, i2.CompanyUnitID, i2.AccountID, i2.AssociationAccountID, i2.TabelaID, proc2.NomeProcedimento, pac2.NomePaciente "&_
"FROM sys_financialmovement m2 "&_
"LEFT JOIN itensdescontados idesc2 ON idesc2.PagamentoID=m2.id "&_
"LEFT JOIN itensinvoice ii ON ii.id=idesc2.ItemID "&_
"LEFT JOIN sys_financialinvoices i2 ON i2.id=ii.InvoiceID "&_
"LEFT JOIN pacientes pac2 ON (pac2.id=i2.AccountID AND i2.AssociationAccountID=3) "&_
"LEFT JOIN procedimentos proc2 ON proc2.id=ii.ItemID "&_
"WHERE m2.PaymentMethodID NOT IN(8,9) AND m2.Date BETWEEN "&_
" "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND ii.Executado='"&ExecutadoStatus&"' AND ii.Tipo='S' and i2.AssociationAccountID=3 "& ContaProfissional & sqlProcedimento &") r"&_
" LEFT JOIN especialidades esp ON esp.id = r.EspecialidadeID"&_
" LEFT JOIN (( SELECT 0 AS 'id', NomeFantasia NomeLocal FROM empresa WHERE id=1) UNION ALL ( SELECT id, NomeFantasia FROM sys_financialcompanyunits)) t ON t.id = r.CompanyUnitID"&_
" LEFT JOIN ("&_
" SELECT s.id, s.NomeProfissional"&_
" FROM ("&_
" SELECT CONCAT('0_', id) id, NomeEmpresa NomeProfissional"&_
" FROM empresa UNION ALL"&_
" SELECT CONCAT('5_', id) id, NomeProfissional"&_
" FROM profissionais UNION ALL"&_
" SELECT CONCAT('8_', id) id, NomeProfissional"&_
" FROM profissionalexterno) s) s ON s.id = r.ProfissionalSolicitante "
            else

                sqlII = "select ii.*, s.NomeProfissional ProfissionalSolicitante, i.ProfissionalSolicitante ProfissionalSolicitanteID, t.NomeLocal CompanyUnit, esp.especialidade, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, i.TabelaID, proc.NomeProcedimento, pac.NomePaciente from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN pacientes pac ON pac.id=i.AccountID "&_
                        "left join especialidades esp on esp.id = ii.EspecialidadeID "&_
                        "left join ((select 0 as 'id',  NomeFantasia NomeLocal FROM empresa WHERE id=1) UNION ALL (select id,  NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1 order by NomeFantasia)) t on t.id = i.CompanyUnitID "&_
                        "left join (SELECT s.id, s.NomeProfissional FROM (SELECT CONCAT('0_', id) id, NomeEmpresa NomeProfissional FROM empresa "&_
                        "UNION ALL SELECT CONCAT('5_', id) id, NomeProfissional FROM profissionais "&_
                        "UNION ALL SELECT CONCAT('8_', id) id, NomeProfissional FROM profissionalexterno ) s) s on s.id = i.ProfissionalSolicitante "&_
                        "WHERE ii.DataExecucao BETWEEN "& mydatenull(De) &" and "& mydatenull(Ate)&" AND ii.Executado='"&ExecutadoStatus&"' AND ii.Associacao>0 AND ii.Tipo='S' and i.AssociationAccountID=3 "&ContaProfissional & sqlProcedimento & sqlUnidades & " ORDER BY ii.DataExecucao"
            end if

            if reqf("DEBUG")="1" then
                response.write( sqlII )
            end if
            set ii = db.execute( sqlII )
                'se ii("Repassado")=0 joga pra temprepasse, else exibe o q ja foi pra rateiorateios
                ' dd(sqlII)
            while not ii.eof
 
                ProfissionalExecutante = ii("Associacao") &"_"& ii("ProfissionalID")
                ItemInvoiceID = ii("id")
                InvoiceID = ii("InvoiceID")
                ProcedimentoID = ii("ItemID")
                DataExecucao = ii("DataExecucao")
                NomeProcedimento = ii("NomeProcedimento")
                ValorProcedimento = ii("Quantidade") * ( ii("ValorUnitario") - ii("Desconto") + ii("Acrescimo") )
                NomePaciente = ii("NomePaciente")
                EspecialidadeID = ii("EspecialidadeID")
                TabelaID = ii("TabelaID")
                UnidadeID = ii("CompanyUnitID")
                
                'modificação 29102019
                UnidadeName = ii("CompanyUnit")
                Solicitante = ii("ProfissionalSolicitante")
                DataDaConta = FormatDateTime(ii("sysDate"),2)
                Especialidade = ii("especialidade")

                PercentualPago = 0
                TotalPago = 0
                TotalRepassado = 0
                PercentualRepassado = 0


                contaLR = 0

                'ValorNaoPago = 0

                idPanel = ii("id")
                %>
            <tr class="panel<%= idPanel %>">
                <td rowspan="2" valign="top" style="vertical-align:top">
                    <input id="invoiceID" name="invoiceID" type="hidden" value="<%= InvoiceID %>">
                    <a target="_blank" class="btn btn-xs text-dark mn" href="./?P=Invoice&Pers=1&CD=C&I=<%= InvoiceID %>">
                        <i class="far fa-chevron-right"></i>
                    </a>
                </td>
                <td> <%= DataExecucao %></td>
                <td><%= NomePaciente %></td>
                <td><%= UnidadeName %></td>
                <td><%= DataDaConta %></td>
                <td><%= Solicitante %></td>
                <td><%= Especialidade %></td>
                <td><%= NomeProcedimento %></td>
                <td><%= fn(ValorProcedimento) %></td>
            </tr>
            <tr class="panel<%= idPanel %>">
                <td colspan="8">
                    <table class="table table-hover table-condensed">

                <%
ItensDescontadosConsolidados = ""
ParcelasCartaoConsolidadas = ""
FechaLinha1 = 0
PrimeiraRR1 = 0
desfazBtnCons = ""

'1a. situação: lista todos os descontos que foram repassados
                GrupoConsolidacao = 0
                set rr = db_execute("select rr.*, rf.DominioID, pm.PaymentMethod, m.id MovementID, (SELECT split.SplitStatus FROM stone_splits split WHERE split.MovementID = m.id AND split.SplitStatus !='undone' LIMIT 1) split from rateiorateios rr LEFT JOIN rateiofuncoes rf ON rf.id=rr.FuncaoID LEFT JOIN itensdescontados idesc ON idesc.id=rr.ItemDescontadoID LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN cliniccentral.sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID where rr.ItemInvoiceID="& ii("id") &" and rr.ItemDescontadoID!=0 order by GrupoConsolidacao")

                while not rr.eof

                    numeroParcela = ""
                    numeroParcelas = ""
                    ParcelasCartaoConsolidadas = ParcelasCartaoConsolidadas & "|"& rr("ParcelaID") &"|"
                    ItensDescontadosConsolidados = ItensDescontadosConsolidados & "|"& rr("ItemDescontadoID") &"|"

                    set NotasAutorizadasSQL = db_execute("SELECT Status FROM nfse_emitidas WHERE InvoiceID="&InvoiceID&" ORDER BY id DESC")
                    StatusNotaID = ""
                    if not NotasAutorizadasSQL.eof then
                        StatusNotaID = NotasAutorizadasSQL("Status")
                    end if

                    existeSplitRealizado = "  "
                    if rr("split")&"" = "processed" or StatusNotaID = "2" or StatusNotaID = "3" then
                        existeSplitRealizado = " disabled "
                    end if

                    if GrupoConsolidacao<>rr("GrupoConsolidacao") then

                        if rr("ParcelaID")>0 then
                            set nParc = db.execute("select (select count(id) from sys_financialcreditcardreceiptinstallments where TransactionID=cc.TransactionID) nParcelas, cc.Parcela from sys_financialcreditcardreceiptinstallments cc where cc.id="& rr("ParcelaID"))
                            if not nParc.EOF then
                                numeroParcela = nParc("Parcela")
                                numeroParcelas = nParc("nParcelas")
                            end if
                        end if

                        valBtnDesc = "P|"& rr("ItemInvoiceID") &"|"& rr("ItemDescontadoID") &"|"& rr("GrupoConsolidacao")
                        idBtnDesc = replace(valBtnDesc, "|", "_")
                        btnExtra = "<div class='checkbox-custom pull-right ptn mtn'><input type='checkbox' name='desconsAll' value='"& valBtnDesc &"' id='"& idBtnDesc &"'><label for='"& idBtnDesc &"'></label></div>"&_


                    "<button type='button' onclick=""desconsolida('P', "& rr("ItemInvoiceID") &", "& rr("ItemDescontadoID") &", "& rr("GrupoConsolidacao") &")"" id='desconsolidar"& rr("ItemInvoiceID") &"_"& rr("ItemDescontadoID") &"_"& rr("GrupoConsolidacao") &"' class='btn mt10 btn-xs btn-danger pull-right hidden-print'"& existeSplitRealizado &">Desconsolidar</button>"

                        if StatusBusca="" or StatusBusca="C" then
                            Classe = "dark"
                            FechaLinha1 = 1

                            if PrimeiraRR1>0 then
                                        %>
                                    </table>
                                </td>
                            </tr>
                            <%
                            end if

                            PrimeiraRR1 = PrimeiraRR1 + 1
                            %>
                            <tr class="<%= Classe %>">
                                <%= tituloTabelaRepasse(Classe, "Consolidado", rr("ItemInvoiceID"), rr("ItemDescontadoID"), rr("PaymentMethod"), numeroParcela, numeroParcelas, ValorRecebido, rr("ParcelaID"), btnExtra) %>
                                <td width="50%" class="<%= Classe %>">
                                    <table class="table table-condensed">
                                        <%
                        end if
                        Percentual = rr("Percentual")
                        PercentualPago = PercentualPago+Percentual
                        PercentualRepassado = PercentualRepassado + Percentual
                    end if
                    GrupoConsolidacao = rr("GrupoConsolidacao")

                    if StatusBusca="" or StatusBusca="C" then
                    'CONSOLIDADO LINHA
                        response.write(buttonDetalharDominio(ItemInvoiceID))

                        call lrResult( "RateioRateios", rDataExecucao, rr("DominioID") &": "& replace(rr("Funcao")&"","|","_"), rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, rr("ContaCredito"), rValorProcedimento, rValorRecebido, rr("Valor"), nLinha, rr("FM"), rr("Sobre"), rr("modoCalculo") )
                        if not isnull(rr("ItemContaAPagar")) or not isnull(rr("ItemContaAReceber")) or not isnull(rr("CreditoID")) then
                            desfazBtnCons = desfazBtnCons & "$('#desconsolidar"& rr("ItemInvoiceID") &"_"& rr("ItemDescontadoID") &"_"& rr("GrupoConsolidacao") &", #"& idBtnDesc &"').prop('disabled', true);"
                        end if
                    end if
                rr.movenext
                wend
                rr.close
                set rr=nothing
                if FechaLinha1=1 then
                                %>
                            </table>
                        </td>
                    </tr>
                    <%
                end if

'2a. verifica se foi repassado sem pagamento e finaliza aqui, nem prossegue pros próximos
                set rr = db.execute("select GrupoConsolidacao, Percentual, ItemInvoiceID, ItemDescontadoID, GrupoConsolidacao, ItemContaAPagar, ItemContaAReceber, CreditoID, modoCalculo from rateiorateios where ItemInvoiceID="& ItemInvoiceID &" and itemDescontadoID=0 GROUP BY GrupoConsolidacao")
                if not  rr.eof then
                    Percentual = rr("Percentual")
                    PercentualRepassado = PercentualRepassado + Percentual

                    if StatusBusca="" or StatusBusca="C" then
                        'call tituloTabelaRepasse("dark", "Consolidado sem recebimento", -1, 0, "", "", 0, "")
                        Classe = "dark"

                        valBtnDesc = "P|"& rr("ItemInvoiceID") &"|"& rr("ItemDescontadoID") &"|"& rr("GrupoConsolidacao")
                        idBtnDesc = replace(valBtnDesc, "|", "_")
                        btnExtra = "<div class='checkbox-custom pull-right ptn mtn'><input type='checkbox' name='desconsAll' value='"& valBtnDesc &"' id='"& idBtnDesc &"'><label for='"& idBtnDesc &"'></label></div>"&_


                    "<button type='button' onclick=""desconsolida('P', "& rr("ItemInvoiceID") &", "& rr("ItemDescontadoID") &", "& rr("GrupoConsolidacao") &")"" id='desconsolidar"& rr("ItemInvoiceID") &"_"& rr("ItemDescontadoID") &"_"& rr("GrupoConsolidacao") &"' class='btn btn-xs mt10 btn-danger pull-right hidden-print'>Desconsolidar</button>"
                        if not isnull(rr("ItemContaAPagar")) or not isnull(rr("ItemContaAReceber")) or not isnull(rr("CreditoID")) then
                            desfazBtnCons = desfazBtnCons & "$('#desconsolidar"& rr("ItemInvoiceID") &"_"& rr("ItemDescontadoID") &"_"& rr("GrupoConsolidacao") &", #"& idBtnDesc &"').prop('disabled', true);"
                        end if
                        %>
                        <tr class="<%= Classe %>">
                            <%= tituloTabelaRepasse(Classe, "Consolidado sem recebimento", ItemInvoiceID, 0, "", "", "", 0, 0, btnExtra) %>
                            <td width="50%" class="<%= Classe %>">
                                <table class="table table-condensed">
                                    <%= listaRR( DataExecucao, InvoiceID, ItemInvoiceID, NomeProcedimento, NomePaciente, "Não recebido", ValorProcedimento, ValorRecebido, 0 ) %>
                                </table>
                            </td>
                        </tr>
                        <%
                    'response.write("<br /> ITENS NAO PAGOS ("& Percentual &"%) lista mais rr deste procedimento")
                    end if
                end if

                if desfazBtnCons<>"" then
                    %>
                    <script><%=desfazBtnCons %></script>
                    <%
                end if


'3a. situação: verifica repasses que foram recebidos do pacte mas ainda nao foram consolidados
                if PercentualRepassado<100 then
                    sqlPagtos = "select idesc.*, m.PaymentMethodID, pm.PaymentMethod, m.id MovementPayID, idesc.Valor, m.Date, m.AccountIDDebit FROM itensdescontados idesc LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE idesc.ItemID="& ii("id")&" GROUP BY idesc.ItemID, idesc.PagamentoID, idesc.Valor"

                    
                    set pagtos = db.execute(sqlPagtos)
                    while not pagtos.eof

                        sqlDiscount = "SELECT i.FormaID, i.id InvoiceID, count(trans.id) ParcelasCartao FROM sys_financialinvoices i  "&_
                                      "INNER JOIN sys_financialmovement mov ON mov.InvoiceID=i.id  "&_
                                      "INNER JOIN sys_financialdiscountpayments disc ON disc.InstallmentID=mov.id "&_
                                      "LEFT JOIN sys_financialcreditcardtransaction trans ON trans.MovementID=disc.MovementID "&_
                                      "WHERE disc.MovementID="&pagtos("PagamentoID")&" AND (disc.DiscountedValue IS NULL OR disc.DiscountedValue > 0.1)"
                        
                        
                        set DadosInvoiceSQL = db.execute(sqlDiscount)
                        GrupoFormaPagamentoID=False
                        if not DadosInvoiceSQL.eof then
                            GrupoFormaPagamentoID = DadosInvoiceSQL("FormaID")

                            Parcelas = 1

                            if GrupoFormaPagamentoID=0 then
                                set ParcelasSQL = db.execute("SELECT count(id) Parcelas FROM sys_financialmovement WHERE type='Bill' and CD='C' AND InvoiceID="&DadosInvoiceSQL("InvoiceID"))
                                if not ParcelasSQL.eof then
                                    Parcelas = ParcelasSQL("Parcelas")
                                end if

                                sqlGrupoForma = "SELECT id FROM sys_formasrecto WHERE MetodoID="&treatvalzero(pagtos("PaymentMethodID"))&" AND (Contas LIKE '%|ALL|%' OR Contas LIKE '%|"&pagtos("AccountIDDebit")&"|%') AND "&Parcelas&" BETWEEN ParcelasDe AND ParcelasAte"


                                set GrupoFormaPagamentoSQL = db.execute(sqlGrupoForma)
                                if not GrupoFormaPagamentoSQL.eof then
                                    GrupoFormaPagamentoID = GrupoFormaPagamentoSQL("id")
                                end if
                            end if

                        end if

                        FormaRecebimentoDominio = "|P|"

                        if GrupoFormaPagamentoID>0 then
                            if pagtos("PaymentMethodID")=8 or pagtos("PaymentMethodID")=9 or pagtos("PaymentMethodID")=4 then
                                ContaPagamento = pagtos("AccountIDDebit")
                            else
                                ContaPagamento = 0
                            end if
                            FormaRecebimentoDominio = "P"&GrupoFormaPagamentoID&"_"&ContaPagamento
                        end if


                        NomeMetodo = pagtos("PaymentMethod")
                        FormaPagamentoID=pagtos("PaymentMethodID")

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


                                slqParcs = "select parc.id, parc.Value BrutoParcela, parc.Fee, parc.InvoiceReceiptID, parc.Parcela, t.Parcelas FROM sys_financialcreditcardreceiptinstallments parc LEFT JOIN sys_financialcreditcardtransaction t ON t.id=parc.TransactionID WHERE t.MovementID="& pagtos("PagamentoID") &" ORDER BY DateToReceive"


                                set parcs = db.execute(slqParcs)

                                while not parcs.eof

                                    if instr(ParcelasCartaoConsolidadas, "|"& parcs("id") &"|")=0 then

                                    'REAJUSTAR PROPORCOES
                                    'era individual ->
                                    'nos pagamentos separar antes em pagtos repassados e depois os pagtos a repassar
                                    ultimoSobre = ""
                                    somaDesteSobre = 0
                                    ValorBase = ValorProcedimento

                                    DominioID = dominioRepasse(FormaRecebimentoDominio, ii("ProfissionalID")&"", ProcedimentoID, ii("CompanyUnitID"), ii("TabelaID"), ii("EspecialidadeID")&"", ii("DataExecucao"), ii("HoraExecucao"))
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
                                            %>
                                            <tr class="<%= Classe %>">
                                                <%= tituloTabelaRepasse(Classe, "Não consolidado", pagtos("ItemID"), pagtos("id"), NomeMetodo, parcs("Parcela"), parcs("Parcelas"), ValorParcela, parcs("id"), "") %>
                                                <td width="50%" class="<%= Classe %>">
                                                    <table class="table table-condensed">
                                                        <%= repasse( DataExecucao, InvoiceID, NomeProcedimento, NomePaciente, pagtos("PaymentMethod"), ValorProcedimento, pagtos("Valor"), Percentual, parcs("id"), pagtos("AccountIDDebit"), ii("EspecialidadeID"), ii("Quantidade") , parcs("Parcelas")) %>
                                                    </table>
                                                </td>
                                            </tr>
                                            <%
                                        end if

                                        'response.write( Percentual & " - " & PercentualPago & ", " )



                                    end if
                                parcs.movenext
                                wend
                                parcs.close
                                set parcs=nothing
                            else
'TRABALHAR A FORMATACAO DESTE PRIMEIRO
                                if instr(ItensDescontadosConsolidados, "|"& pagtos("id") &"|")=0 then
                                    'era individual ->
                                    'nos pagamentos separar antes em pagtos repassados e depois os pagtos a repassar
                                    ultimoSobre = ""
                                    somaDesteSobre = 0
                                    ValorBase = ValorProcedimento


                                    DominioID = dominioRepasse(FormaRecebimentoDominio, ii("ProfissionalID")&"", ProcedimentoID, ii("CompanyUnitID"), ii("TabelaID"), ii("EspecialidadeID")&"", ii("DataExecucao"), ii("HoraExecucao"))
                                    Despesas = 0




                                    ValorPago = pagtos("Valor")

                                    if ValorPago <= 0 or ValorBase<=0 then
                                        Fator = 0
                                    else
                                        Fator = ValorPago / ValorBase
                                    end if

                                    Percentual = Fator * 100
                                    PercentualPago = PercentualPago+Percentual
                                    PercentualRepassado = PercentualRepassado + Percentual
                                    TotalPago = TotalPago + ValorPago
                                    ItemDescontadoID = pagtos("id")
                                    '<- era individual
                                    'response.write("<br /> Pagamento: "& ValorPago &" ( "& Percentual &"% )")
                           ' function tituloTabelaRepasse(Classe, Titulo, ItemInvoiceID, PagtoID, FormaPagto, NumeroParcela, Parcelas, ValorRecebido, ParcelaID)
                                    if StatusBusca="" or StatusBusca="S" then
                                        Classe = "success"

                                        ParcelaAtual=1
                                        Parcelas=1

                                        if pagtos("PaymentMethodID")=8 then
                                            set CreditCardSQL = db.execute("SELECT Parcelas FROM sys_financialcreditcardtransaction WHERE MovementID="&pagtos("MovementPayID"))
                                            if not CreditCardSQL.eof then
                                                Parcelas=CreditCardSQL("Parcelas")
                                                ParcelaAtual=""
                                            end if
                                        end if

                                        %>
                                        <tr class="<%= Classe %>">
                                            <%= tituloTabelaRepasse(Classe, "Não consolidado", pagtos("ItemID"), pagtos("id"), NomeMetodo, ParcelaAtual, Parcelas, pagtos("Valor"), 0, "") %>
                                            <td width="50%" class="success">
                                                <table class="table table-condensed">
                                                    <%= repasse( DataExecucao, InvoiceID, NomeProcedimento, NomePaciente, pagtos("PaymentMethod"), ValorProcedimento, pagtos("Valor"), Percentual, 0, pagtos("AccountIDDebit"), ii("EspecialidadeID"), ii("Quantidade"), Parcelas ) %>
                                                </table>
                                            </td>
                                        </tr>
                                        <%

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
                        if not isNull(formaToDominio) and not isnull(contaToDominio) then
                         inicial = "|P"&formaToDominio&"_"&contaToDominio&"|"
                        else
                            inicial = "|P|"
                        end if

                        DominioID = dominioRepasse(inicial, ii("ProfissionalID")&"", ProcedimentoID, ii("CompanyUnitID"), ii("TabelaID"), ii("EspecialidadeID")&"", ii("DataExecucao"), ii("HoraExecucao"))
                        
                        Despesas = 0
                        ItemDescontadoID = 0
                        ValorNaoRecebido = ValorBase * fn((PercentualNaoPago/100))

                        Percentual = PercentualNaoPago

                        if StatusBusca="" or StatusBusca="N" then
                            Classe = "danger"
                            %>
                            <tr class="<%= Classe %>">
                                

                                <%= tituloTabelaRepasse(Classe, "Não recebido: "& fn(ValorNaoRecebido), ItemInvoiceID, 0, "", "", "", 0, 0, "") %>
                                <td width="50%" class="<%= Classe %>">
                                    <table class="table table-condensed">
                                        <%'= "{ |P|, " & ii("ProfissionalID") &", "& ProcedimentoID &", "& ii("CompanyUnitID") &", "& ii("TabelaID") &", "& ii("EspecialidadeID") &" }" %>
                                        <%= repasse( DataExecucao, InvoiceID, NomeProcedimento, NomePaciente, "Pendente", ValorProcedimento, 0, Percentual, 0, "", ii("EspecialidadeID"), ii("Quantidade") , 1) %>
                                    </table>
                                </td>
                            </tr>
                            <%
                        end if
                    end if
                end if

  '              response.write("Resultado: "& ValorProcedimento &" - "& Despesas)

                    %>
                        </table>
                    <%
                    if contaLR=0 then
                        %>
                        <script type="text/javascript">$(".panel<%=idPanel %>").css("display", "none");</script>
                        <%
                    else
                        totalProcedimentos = totalProcedimentos + ValorProcedimento
                    end if
                %>
                    </td>
                </tr>
                <%
                if reqf("AC")="1" then
                    ReconsApagar = ReconsApagar &"|"& ii("ReconsolidacaoID") &"|"
                end if

                 Response.Flush()
            ii.movenext
            wend
            ii.close
            set ii = nothing

            if ReconsApagar<>"" then
                ReconsApagar = replace( ReconsApagar, "||", ", ")
                ReconsApagar = replace( ReconsApagar, "|", "")

                db.execute("delete from reconsolidar where id in("& ReconsApagar &")")
            end if

            %>
                </tbody>
            </table>
            <hr class="short alt" />
            <table class="table table-condensed table-bordered">
                <thead>
                    <tr>
                        <th width="20%" class="text-center">Total Serviços</th>
                        <th width="20%" class="text-center">Total Repasses</th>
                        <th width="20%" class="text-center">Total Materiais</th>
                        <th width="20%" class="text-center">Taxas Cartão</th>
                        <th width="20%" class="text-center">Total Resultado</th>
                    </tr>
                </thead>
                <tbody>
                        <th width="20%" class="text-right"><%= fn(totalProcedimentos) %></th>
                        <th width="20%" class="text-right"><%= fn(totalRepasses) %></th>
                        <th width="20%" class="text-right"><%= fn(totalMateriais) %></th>
                        <th width="20%" class="text-right"><%= fn(totalTaxas) %></th>
                        <th width="20%" class="text-right"><%= fn( totalProcedimentos - totalRepasses - totalMateriais - totalTaxas ) %></th>
                </tbody>
            </table>
        </div>
    </div>
</form>
