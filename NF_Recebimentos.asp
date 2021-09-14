<!--#include file="connect.asp"-->
<%
De = req("De")
Ate = req("Ate")
%>
<div class="panel panel-body">
    <table class="table table-striped table-hover table-condensed table-bordered">
        <thead>
            <tr class="success">
                <th>NOTA</th>
                <th>PAGADOR</th>
                <th>EMISSÃO</th>
                <th>VALOR BRUTO</th>
                <th>COFINS</th>
                <th>CSLL</th>
                <th>IRPJ</th>
                <th>PIS</th>
                <th>ISS</th>
                <th>VALOR LÍQUIDO</th>
                <th>DATA DO RECEBIMENTO</th>
                <th>MULTA / JUROS</th>
                <th>TX. DE EMISSÃO DE BOLETO / C.C.</th>
                <th>FORMA PAGTO.</th>
                <th>VLR. DO RECEBIMENTO</th>
            </tr>
        </thead>
        <tbody>
            <%
            UltimaData=""
            SomaValorRectoBoleto=0
            SomaValorRectoMaster=0
            SomaValorRectoElo=0
            SomaValorRectoVisa=0


            sql = "SELECT mPay.AccountAssociationIDCredit, mPay.AccountIDCredit,  i.NroNFe, i.DataNFe, ii.InvoiceID, COALESCE(i.ValorNFe,0) ValorNFe, IFNULL(movCred.Date, mPay.Date) DataRecto, COALESCE(i.Value,0) ValorBruto, "&_
                                  " ifnull((select sum(ifnull(Desconto,0)) from itensinvoice where CategoriaID=198 and InvoiceID=i.id),0) CSLL, "&_
                                  " ifnull((select sum(ifnull(Desconto,0)) from itensinvoice where CategoriaID in (201, 212) and InvoiceID=i.id),0) IRPJ, "&_
                                  " ifnull((select sum(ifnull(Desconto,0)) from itensinvoice where CategoriaID=197 and InvoiceID=i.id),0) Cofins, "&_
                                  " ifnull((select sum(ifnull(Desconto,0)) from itensinvoice where CategoriaID=200 and InvoiceID=i.id),0) PIS, "&_
                                  " ifnull((select sum(ifnull(Acrescimo,0)+ValorUnitario) from itensinvoice where (Descricao LIKE 'Multa - BOLETO' OR Descricao LIKE 'Multa por atraso') and CategoriaID IN(203,101,241) and InvoiceID=ii.InvoiceID),0) Multa, "&_
                                  " ifnull(transi.Fee,0) TaxaCartao, transi.DateToReceive, mPay.PaymentMethodID, transi.TransactionID, movCred.Date DateCartaoCredito, trans.BandeiraCartaoID, paym.PaymentMethod "&_
                                  " FROM sys_financialmovement mPay "&_
                                  " LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=mPay.id "&_
                                  " LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID "&_
                                  " LEFT JOIN sys_financialcreditcardtransaction trans ON trans.MovementID=mPay.id "&_
                                  " LEFT JOIN sys_financialcreditcardreceiptinstallments transi ON transi.TransactionID=trans.id "&_
                                  " LEFT JOIN sys_financialpaymentmethod paym ON paym.id=mPay.PaymentMethodID "&_
                                  " LEFT JOIN sys_financialmovement movCred ON movCred.id=transi.InvoiceReceiptID "&_
                                  " LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                                  " WHERE i.CD='C' AND IFNULL(movCred.Date, mPay.Date) BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &"  GROUP BY i.id ORDER BY IFNULL(movCred.Date, mPay.Date) asc"
            set m = db.execute(sql)
            while not m.eof




                InvoiceID = m("InvoiceID")
                NroNfe = m("NroNFe")
                Emissao = m("DataNFe")
                BandeiraCartaoID = m("BandeiraCartaoID")
                Multa = Cdbl(m("Multa"))
                ValorNFe = Cdbl(m("ValorNFe")) ' !!!!!!!!!!! voltar a salvar o valor e data da nf
                    'ANTES DE TER VALORNFE
                '     ValorNFe = ccur(m("ValorBruto")) - Multa
                ValorBruto = Cdbl (m("ValorBruto"))
                Cofins = Cdbl (m("Cofins"))
                CSLL = Cdbl (m("CSLL"))
                IRPJ = Cdbl (m("IRPJ")) ' !!!! procurar com o nome de IRPJ ou IRRF
                PIS = Cdbl (m("PIS"))
                ISS = ValorNFe*0.05
                ValorLiquido = ValorNFe - Cofins - CSLL - IRPJ - PIS
                DataRecto = m("DataRecto")

                if m("PaymentMethodID")=8 or m("PaymentMethodID")=9 then
                    TxBoleto = m("TaxaCartao") 'eh em %
                    TxBoleto = (TxBoleto / 100) * ValorLiquido

                else
                    TxBoleto = 1.98
                end if

                ValorRecto = ValorLiquido + Multa - TxBoleto

                if isnull(ValorRecto) then
                    ValorRecto=0
                end if

                if UltimaData<>"" and DataRecto<>UltimaData then

                %>
                <tr class="primary">
                    <th class="text-right"><a href="./?P=Invoice&Pers=1&CD=C&I=<%= InvoiceID %>" target="_blank"></a></th>
                    <th class="text-right">Valor total BOLETO</th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"><%=UltimaData%></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"><%= fn(SomaValorRectoBoleto) %></th>
                </tr>
                <%
                %>
                <tr class="primary">
                    <th class="text-right"><a href="./?P=Invoice&Pers=1&CD=C&I=<%= InvoiceID %>" target="_blank"></a></th>
                    <th class="text-right">Valor total VISA</th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"><%=UltimaData%></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"><%= fn(SomaValorRectoVisa) %></th>
                </tr>
                <%
                %>
                <tr class="primary">
                    <th class="text-right"><a href="./?P=Invoice&Pers=1&CD=C&I=<%= InvoiceID %>" target="_blank"></a></th>
                    <th class="text-right">Valor total MASTER</th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"><%=UltimaData%></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"><%= fn(SomaValorRectoMaster) %></th>
                </tr>
                <%
                %>
                <tr class="primary">
                    <th class="text-right"><a href="./?P=Invoice&Pers=1&CD=C&I=<%= InvoiceID %>" target="_blank"></a></th>
                    <th class="text-right">Valor total ELO</th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"><%=UltimaData%></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"></th>
                    <th class="text-right"><%= fn(SomaValorRectoElo) %></th>
                </tr>
                <%

                    SomaValorRectoBoleto=0
                    SomaValorRectoMaster=0
                    SomaValorRectoElo=0
                    SomaValorRectoVisa=0
                end if


                if m("PaymentMethodID")=8 or m("PaymentMethodID")=9 then
                    if BandeiraCartaoID=1 then
                        SomaValorRectoVisa = SomaValorRectoVisa + ValorRecto
                    end if
                    if BandeiraCartaoID=2 then
                        SomaValorRectoMaster = SomaValorRectoMaster + ValorRecto
                    end if
                    if BandeiraCartaoID=4 then
                      SomaValorRectoElo = SomaValorRectoElo + ValorRecto
                    end if
                else
                    SomaValorRectoBoleto = SomaValorRectoBoleto + ValorRecto
                end if


                classRow=""
                if isnull(Emissao) then
                    classRow="danger"
                end if

                %>
                <tr class="<%= classRow %>">
                    <td class="text-right"><a href="./?P=Invoice&Pers=1&CD=C&I=<%= InvoiceID %>" target="_blank"><%= NroNFe %></a></td>
                    <td ><%= accountName(m("AccountAssociationIDCredit"), m("AccountIDCredit")) %></td>
                    <td class="text-right"><%= Emissao %></td>
                    <td class="text-right"><%= fn(ValorNFe) %></td>
                    <td class="text-right"><%= fn(Cofins) %></td>
                    <td class="text-right"><%= fn(CSLL) %></td>
                    <td class="text-right"><%= fn(IRPJ) %></td>
                    <td class="text-right"><%= fn(PIS) %></td>
                    <td class="text-right"><%= fn(ISS) %></td>
                    <td class="text-right"><%= fn(ValorLiquido) %></td>
                    <td class="text-right"><%= DataRecto %></td>
                    <td class="text-right"><%= fn(Multa) %></td>
                    <td class="text-right"><%= fn(TxBoleto) %></td>
                    <td><small><%= m("PaymentMethod") %></small></td>
                    <td class="text-right"><%= fn(ValorRecto) %></td>
                </tr>
                <%

                UltimaData = DataRecto

            m.movenext
            wend
            m.close
            set m = nothing
            %>
        </tbody>
    </table>

</div>