<%
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



private function repasse()
    coefPerc = Percentual / 100
    %>
    <table class="table table-condensed">
        <tbody>
            <tr class="alert">
                <th>Data</th>
                <th>Forma de Pagamento</th>
                <th>Valor Pago</th>
                <th>Percentual</th>
            </tr>
            <tr>
                <td colspan="5">
                <%
                '------------------->
                    %>
                    <table class="table table-condensed table-bordered table-striped table-hover">
                        <thead>
                            <tr class="info">
                                <th width="1%">
                                    <input type="checkbox" name="linhaRepasse" value="<%= ItemInvoiceID &"_"& ItemDescontadoID %>">
                                </th>
                                <th width="1%">FM</th>
                                <th width="1%">Sobre</th>
                                <th width="15%">Descrição</th>
                                <th width="20%">Creditado</th>
                                <th width="5%">Qtd.</th>
                                <th width="15%" colspan="2">Valor</th>
                                <th width="10%">Valor Base</th>
                                <th width="15%">Soma deste Sobre</th>
                                <th width="10%">Despesas</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        'conferir -> FormaID pode ser |P| para todos particulares, |C| para todos convênios, |00_0| para forma predefinida de recto e > |0| para qualquer id de convênio
                        set fd = db.execute("select * from rateiofuncoes where DominioID="&DominioID&" order by Sobre")
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

                                if fd("FM")="M" then
                                    'Produto variável
                                    if fd("ProdutoID")=0 then
                                        if not iio.eof then
                                            ProdutoID = iio("ProdutoID")
                                        end if
                                    end if
                                    'Quantidade variável
                                    if fd("Variavel")="S" then
                                        if not iio.eof then
                                            Quantidade = iio("Quantidade")
                                        end if
                                    end if
                                    'Valor variável
                                    if fd("ValorVariavel")="S" then
                                        if not iio.eof then
                                            ValorUnitario = iio("ValorUnitario")
                                        end if
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

                                    linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem*coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual
                                    %>
                                    <tr>
                                        <td>
                                            <input type="hidden" name="linhaRepasse<%= ItemInvoiceID &"_"& ItemDescontadoID %>" value="<%= linhaRepasse %>" />
                                        </td>
                                        <td>F</td>
                                        <td><%= Sobre %></td>
                                        <td><%= fd("Funcao") %></td>
                                        <td><%= accountName(NULL, Creditado) %></td>
                                        <td class="text-right">1</td>
                                        <td class="text-right"><%= ShowValor %></td>
                                        <td class="text-right">R$ <%= fn(ValorItem * coefPerc) %> [ <%=  coefPerc %> ]</td>
                                        <td class="text-right"><%= fn(ValorBase) %></td>
                                        <td class="text-right"><%= somaDesteSobre %></td>
                                        <td class="text-right"><%= Despesas %></td>
                                    </tr>
                                    <%
                                end if
                            end if

                            'Materiais da árvore (M)
                            if fd("FM")="M" then
                                Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
                                ShowValor = calcValor(Valor, TipoValor, ValorBase, "show")
                                ValorItem = calcValor(Valor, TipoValor, ValorBase, "calc")
                                set prod = db.execute("select NomeProduto from produtos where id="& ProdutoID)
                                if prod.eof then NomeProduto="" else NomeProduto=prod("NomeProduto") end if
                                if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                                    somaDesteSobre = somaDesteSobre+ (Quantidade*ValorItem)
                                    'if Creditado<>"0" then
                                        Despesas = Despesas + (Quantidade*ValorItem)
                                    'end if
                                    linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade*ValorItem) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual
                                    %>
                                    <tr>
                                        <td>
                                            <input type="hidden" name="linhaRepasse<%= ItemInvoiceID &"_"& ItemDescontadoID %>" value="<%= linhaRepasse %>" />
                                        </td>
                                        <td>M</td>
                                        <td><%= Sobre %></td>
                                        <td><%= NomeProduto %></td>
                                        <td><%= accountName(NULL, Creditado) %></td>
                                        <td class="text-right"><%= Quantidade %></td>
                                        <td class="text-right"><%= ShowValor %></td>
                                        <td class="text-right">R$ <%= fn((Quantidade*ValorItem) * coefPerc) %></td>
                                        <td class="text-right"><%= fn(ValorBase) %></td>
                                        <td class="text-right"><%= somaDesteSobre %></td>
                                        <td class="text-right"><%= Despesas %></td>
                                    </tr>
                                    <%
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
                                        linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual
                                        %>
                                        <tr>
                                            <td>
                                                <input type="hidden" name="linhaRepasse<%= ItemInvoiceID &"_"& ItemDescontadoID %>" value="<%= linhaRepasse %>" />
                                            </td>
                                            <td>Ei</td>
                                            <td><%= Sobre %></td>
                                            <td><%= eq("Funcao") %></td>
                                            <td><%= accountName(NULL, Creditado) %></td>
                                            <td class="text-right">1</td>
                                            <td class="text-right"><%= ShowValor %></td>
                                            <td class="text-right">R$ <%= fn(ValorItem * coefPerc) %></td>
                                            <td class="text-right"><%= fn(ValorBase) %></td>
                                            <td class="text-right"><%= somaDesteSobre %></td>
                                            <td class="text-right"><%= Despesas %></td>
                                        </tr>
                                        <%
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
                                set kit = db.execute("select pdk.id ProdutoDoKitID, pdk.Valor, pdk.ContaPadrao, pdk.Quantidade, pdk.ProdutoID from procedimentoskits pk LEFT JOIN produtosdokit pdk ON pk.KitID=pdk.KitID WHERE pk.Casos LIKE '%|P|%' AND pk.ProcedimentoID="& ProcedimentoID)
                                while not kit.eof
                                    NomeProduto = ""
                                    Quantidade = kit("Quantidade")
                                    ValorUnitario = kit("Valor")
                                    ContaPadrao = kit("ContaPadrao")
                                    ContaCredito = ContaPadrao
                                    ProdutoID = kit("ProdutoID")
                                    TipoValor = "V"
                                    'ver se a qtd é variavel e colocar a qtd usada
                                    sqliio = "select * from itensinvoiceoutros where ProdutoKitID="& kit("ProdutoDoKitID") &" and ItemInvoiceID="& ItemInvoiceID
                                    set iio = db.execute( sqliio )
                                    if not iio.eof then
                                        Quantidade = iio("Quantidade")
                                        ContaCredito = iio("Conta")
                                        ProdutoID = iio("ProdutoID")
                                        ValorUnitario = iio("ValorUnitario")
                                    end if
                                    if not isnull(ProdutoID) then
                                        set prod = db.execute("select NomeProduto from produtos where id="& ProdutoID)
                                        if not prod.eof then
                                            NomeProduto = prod("NomeProduto")
                                        end if
                                    end if
                                    Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
                                    if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                                        somaDesteSobre = somaDesteSobre + (Quantidade * ValorUnitario)
                                        'if Creditado<>"0" then
                                            Despesas = Despesas + (Quantidade*ValorUnitario)
                                        'end if

                                        linhaRepasse = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& (Quantidade * ValorUnitario) * coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual

                                        %>
                                        <tr>
                                            <td>
                                                <input type="hidden" name="linhaRepasse<%= ItemInvoiceID &"_"& ItemDescontadoID %>" value="<%= linhaRepasse %>" />
                                            </td>
                                            <td>Ki</td>
                                            <td><%= Sobre %></td>
                                            <td><%= NomeProduto %></td>
                                            <td><%= accountName(NULL, Creditado) %></td>
                                            <td class="text-right"><%= Quantidade %></td>
                                            <td class="text-right">R$ <%= fn(ValorUnitario) %></td>
                                            <td class="text-right">R$ <%= fn((Quantidade * ValorUnitario) * coefPerc)  %></td>
                                            <td class="text-right"><%= fn(ValorBase) %></td>
                                            <td class="text-right"><%= somaDesteSobre %></td>
                                            <td class="text-right"><%= Despesas %></td>
                                        </tr>
                                        <%
                                    end if
                                kit.movenext
                                wend
                                kit.close
                                set kit = nothing
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
                        %>
                        </tbody>
                    </table>
                                    
                    <%
                '<-------------------
                %>
                </td>
            </tr>
        </tbody>
    </table>
    <%
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

%>


<form method="post" id="frmRepasses" name="frmRepasses">
    <div class="panel">
        <div class="panel-body">
            <h3>Repasses Particulares</h3>

            <%
            'db_execute("delete from temprepasse where sysUser="&session("User"))
            set ii = db.execute("select ii.*, i.CompanyUnitID, i.AccountID, i.AssociationAccountID, proc.NomeProcedimento from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ii.DataExecucao BETWEEN "& mydatenull(De) &" and "& mydatenull(Ate)&" AND ii.Executado='S' AND ii.Tipo='S'")
                'se ii("Repassado")=0 joga pra temprepasse, else exibe o q ja foi pra rateiorateios
            while not ii.eof

                ProfissionalExecutante = ii("Associacao") &"_"& ii("ProfissionalID")
                ItemInvoiceID = ii("id")
                ProcedimentoID = ii("ItemID")
                ValorProcedimento = ii("Quantidade") * ( ii("ValorUnitario") - ii("Desconto") + ii("Acrescimo") )




                %>
                <div class="panel">
                    <div class="panel-body">
                    ii: <%=ii("id") %> - 
                    i: <a class="btn" target="_blank" href="./?P=invoice&T=C&Pers=1&I=<%=ii("InvoiceID") %>"><%=ii("InvoiceID") %></a> - 
                    Domínio: <%= DominioID %> - 
                    Data: <%= ii("DataExecucao") %> - 
                    Proc.: <%=ii("NomeProcedimento") %> - 
                    Prof.:  <%=ProfissionalExecutante %> - 
                    Valor do procedimento: <%= fn(ValorProcedimento) %> - 
                    Valor Base: <%= fn(ValorBase) %> 
                    <br />

                <%
                PercentualPago = 0
                TotalPago = 0
                
                TotalRepassado = 0
                PercentualRepassado = 0



                '1a. situação: lista todos os descontos que foram repassados
                set pagtos = db.execute("select idesc.*, m.PaymentMethodID, pm.PaymentMethod, idesc.Valor, m.Date FROM itensdescontados idesc LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE idesc.ItemID="& ii("id")&" AND idesc.Repassado=1")
                while not pagtos.eof
                    'nos pagamentos separar antes em pagtos repassados e depois os pagtos a repassar
                    ValorBase = ValorProcedimento
                    ValorPago = pagtos("Valor")
                    if ValorProcedimento>0 then
                        Fator = ValorPago / ValorProcedimento
                    else
                        Fator = 0
                    end if
                    Percentual = Fator * 100
                    PercentualPago = PercentualPago+Percentual
                    TotalPago = TotalPago + ValorPago
                    PercentualRepassado = PercentualPago
                    %>
                    <br />
                        Pagamento: <%= ValorPago %> ( <%= Percentual %>% ) - <%= pagtos("Date") %> - <%= pagtos("PaymentMethod") %> - <%= fn(ValorPago) %> - <%= fn(Percentual) %>% 
                        <br />
                        LISTA AQUI OS RR DESTE ITEMDESCONTADOID <br />
                    <%
                    'listaRR()
                pagtos.movenext
                wend
                pagtos.close
                set pagtos = nothing

                '2a. verifica se foi repassado sem pagamento e finaliza aqui, nem prossegue pros próximos
                set rr = db.execute("select GrupoConsolidacao, Percentual from rateiorateios where ItemInvoiceID="& ItemInvoiceID &" and itemDescontadoID=0 GROUP BY GrupoConsolidacao")
                if not  rr.eof then
                    Percentual = rr("Percentual")
                    PercentualRepassado = PercentualRepassado + Percentual
                    %>
                        
                    <br /> ITENS NAO PAGOS (<%= Percentual %>%) lista mais rr deste procedimento
                    <%
                    'listaRR()
                end if


                '3a. situação: verifica repasses que foram recebidos do pacte mas ainda nao foram lancados
                if PercentualRepassado<100 then
                    set pagtos = db.execute("select idesc.*, m.PaymentMethodID, pm.PaymentMethod, idesc.Valor, m.Date FROM itensdescontados idesc LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE idesc.ItemID="& ii("id")&" AND idesc.Repassado=0")
                    while not pagtos.eof
                        'nos pagamentos separar antes em pagtos repassados e depois os pagtos a repassar
                        ultimoSobre = ""
                        somaDesteSobre = 0
                        ValorBase = ValorProcedimento
                        DominioID = dominioRepasse("|P|", ii("ProfissionalID"), ProcedimentoID, ii("CompanyUnitID"),'')
                        Despesas = 0




                        ValorPago = pagtos("Valor")
                        Fator = ValorPago / ValorBase
                        Percentual = Fator * 100
                        PercentualPago = PercentualPago+Percentual
                        TotalPago = TotalPago + ValorPago
                        ItemDescontadoID = pagtos("id")
                        %>
                        <br />
                            Pagamento: <%= ValorPago %> ( <%= Percentual %>% )
                        <%


                        call repasse()

                    pagtos.movenext
                    wend
                    pagtos.close
                    set pagtos = nothing

                    PercentualNaoPago = 100 - PercentualPago
                    ValorNaoPago = ValorProcedimento - TotalPago
                end if


                '4a. situacao: repasses nem recebidos do pacte nem lancados
                if PercentualRepassado<100 then
                    if PercentualNaoPago>0 then
                        ultimoSobre = ""
                        somaDesteSobre = 0
                        ValorBase = ValorProcedimento
                        DominioID = dominioRepasse("|P|", ii("ProfissionalID"), ProcedimentoID, ii("CompanyUnitID"),'')
                        Despesas = 0
                        ItemDescontadoID = 0

                        Percentual = PercentualNaoPago
                        %>
                        <br />
                        Não Pago: <%= ValorNaoPago %> ( <%= PercentualNaoPago %>% )
                        <%
                        call repasse()
                    end if
                end if

                %>

                        <h3 class="text-right">Resultado: <%= ValorProcedimento - Despesas %></h3>
                    </div>
                </div>
                <%
            ii.movenext
            wend
            ii.close
            set ii = nothing

            %>
        </div>
    </div>
</form>
