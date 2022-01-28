<%
        response.flush()
        ConciliacaoID = l("id")
        AdquirenteID = l("AdquirenteID")
        Autorizacao = l("Autorizacao")
        Transacao = l("Transacao")
        CredDeb = l("CredDeb")
        Bandeira = l("Bandeira")
        CodigoMaquina = l("CodigoMaquina")
        NumeroCartao = l("NumeroCartao")
        Status = l("Status")
        Categoria = l("Categoria")
        DataVenda = l("DataVenda")
        DataPagto = l("DataPagto")
        ValorBruto = l("ValorBruto")
        ValorLiquido = l("ValorLiquido")
        ValorAntecipacao = l("ValorAntecipacao")
        ValorTaxa = l("ValorTaxa")
        Parcela = l("Parcela")
        Parcelas = l("Parcelas")
        PercentualTaxa = (ValorTaxa / ValorBruto) * 100
        if Parcela=0 then
            Parcela = 1
            Parcelas = 1
        end if
        BandeiraCartaoID = l("BandeiraCartaoID")
        ContaCartao = l("ContaCartao")
        ContaBancaria = ccur(l("ContaBancaria"))
        %>
        <div class="panel">
            <div class="panel-body">
                <div class="col-md-6">
                    Data da Venda: <%= DataVenda %><br>
                    Número do Cartão: <%= NumeroCartao %><br>
                    Natureza: <%= CredDeb &"&nbsp;-&nbsp;"& Bandeira %><br> 
                    Código da Autorização: <%= Autorizacao %><br>
                    Código da Transação: <%= Transacao %><br>
                    Data do Pagamento: <%= DataPagto %>
                    <%
                    if ContaBancaria>0 then
                        %>
                        <a target="_blank" class="btn btn-xs btn-success" href="./?P=Extrato&Pers=1&T=1_<%= ContaBancaria %>&Data=<%= DataPagto %>"><i class="far fa-money"></i></a>
                        <%
                    end if
                    %>
                    <br>
                    Valor Bruto: R$ <%= fn(ValorBruto) %><br>
                    Valor Taxa: R$ <%= fn(ValorTaxa) &" ("& fn(PercentualTaxa) &"%)" %><br>
                    Valor Antecipação: R$ <%= fn(ValorAntecipacao) %><br>
                    Valor Líquido: R$ <%= fn(ValorLiquido) %><br>
                    Parcela: <%= Parcela &" de "& Parcelas %><br>

                    <%
                    Abatimentos = 0

                    set vcaAbat = db.execute("SELECT ValorLiquido Abatimento, Categoria FROM CartaoConciliacao WHERE Pai='"& ConciliacaoID &"'")
                    while not vcaAbat.eof
                        Abatimento = vcaAbat("Abatimento")
                        Abatimentos = Abatimentos + Abatimento
                        %>
                        <span class="text-warning">
                            <%= vcaAbat("Categoria") %>: R$ <%= fn(Abatimento) %><br>
                        </span>
                        <%
                    vcaAbat.movenext
                    wend
                    vcaAbat.Close
                    set vcaAbat = nothing

                    'Abatimentos no Adquirente 1 (Stone) vem negativo
                    Abatimentos = Abatimentos*-1

                    ValorClinica = ValorLiquido - Abatimentos
                    %>
                    <b>
                        Valor clínica: R$ <%= fn(ValorClinica) %>
                    </b>
                </div>

                <div class="col-md-6">
                    <%
                    sql = "select t.*, "&_ 
                        " parc.id ParcelaID, parc.Value ValorParcela, "&_ 
                        " parc.Value - ((100-parc.Fee)/100)*parc.Value TaxaPrevista, "&_ 
                        " ((100-parc.Fee)/100)*parc.Value ValorLiquidoPrevisto, "&_ 
                        " m.AccountAssociationIDCredit, m.AccountIDCredit, "&_ 
                        " parc.DateToReceive PrevisaoPagto "&_ 
                        " from sys_financialcreditcardtransaction t INNER JOIN sys_financialmovement m ON m.id=t.MovementID INNER JOIN sys_financialcreditcardreceiptinstallments parc ON parc.TransactionID=t.id where ( ifnull(AuthorizationNumber,'')='"& Autorizacao &"' OR ifnull(TransactionNumber,'')='"& Transacao &"') AND m.Date="& mydatenull(DataVenda) &" AND Parc.Parcela="& Parcela &" AND ROUND(parc.Value)=ROUND("& treatvalzero(ValorBruto) &") ORDER BY AuthorizationNumber DESC, TransactionNumber DESC"
                    'response.write( sql &"<br>")
                    set tran = db.execute( sql )
                    if not tran.eof then
                        ValorParcela = tran("ValorParcela")
                        ValorLiquidoPrevisto = tran("ValorLiquidoPrevisto")
                        TaxaPrevista = tran("TaxaPrevista")
                        TaxaPercPrevista = (TaxaPrevista / ValorParcela) * 100
                        PacienteID = tran("AccountIDCredit")
                        NomePaciente = AccountName( tran("AccountAssociationIDCredit"), PacienteID )
                        PrevisaoPagto = tran("PrevisaoPagto")
                        if fn(ValorLiquido)=fn(ValorLiquidoPrevisto) then
                            classCompare = "text-success"
                        else
                            classCompare = "text-danger"
                        end if
                        if DataPagto<>PrevisaoPagto then
                            classCompareData = "text-danger"
                        else
                            classCompareData = "text-success"
                        end if
                        %>
                        Paciente: 
                            <a href="./?P=Pacientes&I=<%= PacienteID %>&Pers=1" target="_blank">
                                <i class="far fa-user"></i> <%= NomePaciente %>
                            </a><br>
                        Transação: <%= Transacao %><br>
                        Autorização: <%=  Autorizacao %><br>
                        Previsão de Pagamento: <span class="<%= classCompareData %>"> <%=  PrevisaoPagto %></span><br>
                        Valor Bruto: R$ <%= fn(ValorParcela) %><br>
                        Valor Líquido Previsto: <span class="<%= classCompare %>">R$ <%= fn(ValorLiquidoPrevisto) & " ("& fn(TaxaPercPrevista) &"%)" %></span><br>
                        Valor Taxa Prevista: <span class="<%= classCompare %>">R$ <%= fn(TaxaPrevista) %></span><br>
                        Diferença de Taxa: <span class="<%= classCompare %>">R$ <%= fn( ValorTaxa - TaxaPrevista ) %></span><br>
                        <hr class="short alt">
                        <%
                        if l("Conciliado")=1 then
                            %>
                            <span class="text-success">
                                <i class="far fa-check-circle"></i> Conciliado
                            </span>
                            <script type="text/javascript">
                                contaSel();
                            </script>
                            <%
                        else
                            %>

                            <input type="hidden" name="ValorLiquido<%= ConciliacaoID %>" id="ValorLiquido<%= ConciliacaoID %>" value="<%= fn(ValorLiquido) %>">
                            <input type="hidden" id="PercentualTaxa<%= ConciliacaoID %>" value="<%= fn(PercentualTaxa) %>">
                            <input type="hidden" id="ValorTaxa<%= ConciliacaoID %>" value="<%= fn(ValorTaxa) %>">
                            <input type="hidden" id="ValorAntecipacao<%= ConciliacaoID %>" value="<%= fn(ValorAntecipacao) %>">
                            <input type="hidden" id="DataPagto<%= ConciliacaoID %>" value="<%= DataPagto %>">
                            <input type="hidden" id="ValorSplit<%= ConciliacaoID %>" value="<%= fn(ValorSplit) %>">
                            <input type="hidden" id="ValorClinica<%= ConciliacaoID %>" value="<%= fn(ValorClinica) %>">
                            <input type="hidden" id="ParcelaID<%= ConciliacaoID %>" value="<%= tran("ParcelaID") %>">
                            <input type="hidden" id="Parcela<%= ConciliacaoID %>" value="<%= Parcela %>">
                            <input type="hidden" id="Parcelas<%= ConciliacaoID %>" value="<%= Parcelas %>">

                            <label>
                                <input type="checkbox" name="Concilia" class="chkConc" value="<%= l("id")%>"> Selecione para conciliar
                            </label>
                            <%
                            c = c+1
                        end if

                        db.execute("update cartaoconciliacao set ParcelaID="& tran("ParcelaID") &" WHERE id="& ConciliacaoID )
                    else
                        db.execute("update cartaoconciliacao set Conciliado=2 where id="& ConciliacaoID)
                        %>
                        <i class="far fa-exclamation-triangle text-danger"></i> LANÇAMENTO NÃO ENCONTRADO.
                        <%
                    end if
                    %>
                </div>
            </div>
            


            <img src="assets/img/adq<%= AdquirenteID %>.png" width=90 style="position:absolute; right:10px; bottom:10px">
        </div>