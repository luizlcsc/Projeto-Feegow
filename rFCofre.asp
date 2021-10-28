<!--#include file="connect.asp"-->
<style>
body{font-size:14px;}
th{vertical-align: top !important;}

@media print {
    body{font-size:11px;}
}
</style>


<%
Unidades = req("Unidades")
De = req("De")
Ate = req("Ate")
TipoData = req("TipoData")
%>
<h2 class="text-center">Fechamento de Cofre<br />
    <small> Período: <%=De%> a <%=Ate%></small>
</h2>
<%

if TipoData="P" then
    sqlData = " AND (movpay.Date >= "&mydatenull(De)&" AND movpay.Date<= "&mydatenull(Ate)&") "
elseif TipoData="V" then
    sqlData = " AND (mov.Date >= "&mydatenull(De)&" AND mov.Date<= "&mydatenull(Ate)&") "
else
    sqlData = " AND (fi.sysDate >= "&mydatenull(De)&" AND fi.sysDate<= "&mydatenull(Ate)&") "
end if


set unidade = db.execute("select id, NomeFantasia, Sigla from (select '0' id, NomeFantasia, Sigla from empresa UNION ALL select id, NomeFantasia, Sigla from sys_financialcompanyunits) t where t.id IN ("&Unidades&") ")
while not unidade.eof
    NomeFantasia = unidade("NomeFantasia")
    UnidadeID = unidade("id")
    Sigla = unidade("Sigla")
    MovementID = 0

    set invDados = db.execute("SELECT fi.id, GROUP_CONCAT(mov.id) MovementID, mov.`Value` Valor, pac.NomePaciente, rec.NumeroSequencial, rec.UnidadeID, tab.NomeTabela, IFNULL(nfe.numeronfse, fi.nroNFE) NumeroNFe, IF(rec.UnidadeID = 0, (SELECT Sigla from empresa where id=1), (SELECT Sigla from sys_financialcompanyunits where id = rec.UnidadeID)) SiglaUnidade "&_
                              "FROM sys_financialinvoices fi "&_
                              "INNER JOIN sys_financialmovement mov ON mov.InvoiceID=fi.id "&_
                              "INNER JOIN pacientes pac ON pac.id=fi.AccountID AND fi.AssociationAccountID=3 "&_
                              "LEFT JOIN recibos rec ON rec.InvoiceID=fi.id AND rec.sysActive=1 "&_
                              "LEFT JOIN nfe_notasemitidas nfe ON nfe.InvoiceID=fi.id AND nfe.situacao=1 "&_
                              "LEFT JOIN tabelaparticular tab ON tab.id=fi.TabelaID "&_
                              "LEFT JOIN sys_financialdiscountpayments fdp ON fdp.InstallmentID=mov.id "&_
                              "LEFT JOIN sys_financialmovement movpay ON fdp.MovementID=movpay.id "&_
                              "WHERE mov.`Type`='Bill' AND mov.CD='C' AND fi.CompanyUnitID="&UnidadeID & sqlData&" "&_
                              "GROUP BY fi.id ORDER BY rec.NumeroSequencial")
    if not invDados.eof then
    %>
    <h3 class="text-left"><%=NomeFantasia%></h3>
    <%
    end if

    while not invDados.eof
        MovementID = MovementID&", "&invDados("MovementID")

        ValorPago = 0

        NumeroSequencial = invDados("NumeroSequencial")
        classeLinha = "info"

        if isnull(NumeroSequencial) then
            classeLinha="danger"
            NumeroSequencial= "<strong>Não emitido</strong>"
        end if

    %>
    <table width="100%" class="table " id="tabelaFechamentoCofre">
        <thead >
            <th style="width:1%" class="<%=classeLinha%> hidden-print"><a class="btn btn-primary btn-xs" href="./?P=invoice&I=<%=invDados("id")%>&A=&Pers=1&T=C" target="_blank" title="Ir para conta"><i class="far fa-external-link"></i></a></th>
            <th style="width:10%" class="<%=classeLinha%>">Recibo<br><%=invDados("SiglaUnidade")&NumeroSequencial%></th>
            <th style="width:50%" class="<%=classeLinha%>">Paciente<br><%=invDados("NomePaciente")%></th>
            <th style="width:20%" class="<%=classeLinha%>">Tabela<br><%=invDados("NomeTabela")%></th>
            <th style="width:10%" class="<%=classeLinha%>">Nota Fiscal<br><%=invDados("NumeroNFe")%></th>
            <th style="width:10%" class="<%=classeLinha%>">Valor da Conta<br>R$ <%=fn(invDados("Valor"))%></th>
        </thead>
        <tbody>
            <%
            set procDados = db.execute("SELECT ii.Quantidade, ii.Tipo, (CASE ii.Tipo WHEN 'O' THEN ii.Descricao WHEN 'M' THEN prod.NomeProduto ELSE proc.NomeProcedimento END) NomeProcedimento, ii.PacoteID "&_
                                       "FROM itensinvoice ii "&_
                                       "LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                                       "LEFT JOIN produtos prod ON prod.id=ii.ItemID "&_
                                       "WHERE ii.Tipo<>'K' AND ii.InvoiceID="&invDados("id")&" ORDER BY ii.id")
            while not procDados.eof
                Pacote = procDados("PacoteID")
                if Pacote&""<>"" then
                    Pacote = "(Pacote)"
                end if
                if procDados("Tipo")="O" then
                    Tipo="Outro"
                elseif procDados("Tipo")="M" then
                    Tipo="Produto"
                else
                    Tipo="Serviço"
                end if
            %>
            <tr>
                <td class="hidden-print"></td>
                <td></td>
                <td colspan="4" style="padding:10px 0px 0px 15px"><b><%=Tipo%>:</b> <%=procDados("Quantidade")&"x "&procDados("NomeProcedimento")&" "&Pacote%></td>
            </tr>
            <%
            procDados.movenext
            wend
            procDados.close
            set procDados=nothing
            %>
        </tbody>
        <tfoot>
            <tr>
                <td class="hidden-print"></td>
                <td></td>
                <td colspan="4" style="padding:10px 0px 0px 25px">
                    <table width="100%" class="table ">
                        <tbody>
                            <%
                            set BoletoaDados = db.execute("SELECT mov.id, 'Boleto' PaymentMethod, '1' Parcelas, mov.value valor, mov.Date, '' Bandeira, '' NumeroCheque, '' DataCheque, bs.NomeStatus StatusBoleto "&_
                                                           "FROM sys_financialmovement mov  "&_
                                                           "INNER JOIN boletos_emitidos bm ON bm.MovementID=mov.id "&_
                                                           "LEFT JOIN cliniccentral.boletos_status bs ON bs.id=bm.StatusID "&_
                                                           "WHERE mov.id IN ("&invDados("MovementID")&") AND bs.id NOT IN (3, 4) AND mov.`Type`='Bill'  ")


                            set formaDados = db.execute("SELECT fdp.InstallmentID, fpm.PaymentMethod, fct.Parcelas, fdp.DiscountedValue valor, mov.Date, band.Bandeira, frc.CheckNumber NumeroCheque, frc.CheckDate DataCheque "&_
                                                        "FROM sys_financialdiscountpayments fdp "&_
                                                        "INNER JOIN sys_financialmovement mov  ON fdp.MovementID=mov.id "&_
                                                        "INNER JOIN sys_financialpaymentmethod fpm ON fpm.id=mov.PaymentMethodID "&_
                                                        "LEFT JOIN sys_financialcreditcardtransaction fct ON fct.MovementID=mov.id "&_
                                                        "LEFT JOIN cliniccentral.bandeiras_cartao band ON band.id=fct.BandeiraCartaoID "&_
                                                        "LEFT JOIN sys_financialreceivedchecks frc ON frc.MovementID=mov.id "&_
                                                        "WHERE fdp.InstallmentID IN ("&invDados("MovementID")&") ")

                            if formaDados.eof AND BoletoaDados.eof then
                            %>
                            <tr>
                                <td style="width:10%;font-weight:bold;"></td>
                                <td style="width:50%;" class="default"><i>Nenhum Recebimento</i></td>
                                <td></td>
                            </tr>
                            <%
                            end if


                            while not BoletoaDados.eof
                                'ValorPago = ValorPago+BoletoaDados("valor")
                                Parcelas = BoletoaDados("Parcelas")
                                StatusBoleto = BoletoaDados("StatusBoleto")
                                FormaPagammento = BoletoaDados("PaymentMethod")
                                if Parcelas&""="" then
                                    Parcelas=1
                                end if
                                if StatusBoleto&""<>"" then
                                    StatusBoleto = " ("&StatusBoleto&") "
                                end if
                                ValorParcela = BoletoaDados("valor") / Parcelas
                            %>
                            <tr>
                                <td style="width:10%;font-weight:bold;"><%=formatdatetime(BoletoaDados("Date"),2)%></td>
                                <td style="width:50%;"><%=Parcelas&"x "&FormaPagammento& StatusBoleto%></td>
                                <td>R$ <%=fn(ValorParcela)%></td>
                            </tr>
                            <%

                            BoletoaDados.movenext
                            wend
                            BoletoaDados.close
                            set BoletoaDados=nothing


                            while not formaDados.eof
                                ValorPago = ValorPago+formaDados("valor")
                                Parcelas = formaDados("Parcelas")
                                Bandeira = formaDados("Bandeira")
                                NumeroCheque = formaDados("NumeroCheque")
                                DataCheque = formaDados("DataCheque")
                                FormaPagammento = formaDados("PaymentMethod")
                                if Parcelas&""="" then
                                    Parcelas=1
                                end if
                                if Bandeira&""<>"" then
                                    Bandeira = " ("&Bandeira&") "
                                end if
                                if DataCheque&""<>"" then
                                    DataCheque = " ("&formatdatetime(DataCheque,2)&") "
                                end if
                                if NumeroCheque&""<>""then
                                    NumeroCheque = " - Número: "&NumeroCheque
                                end if
                                ValorParcela = formaDados("valor") / Parcelas
                            %>
                            <tr>
                                <td style="width:10%;font-weight:bold;"><%=formatdatetime(formaDados("Date"),2)%></td>
                                <td style="width:50%;"><%=Parcelas&"x "&FormaPagammento& Bandeira & DataCheque & NumeroCheque%></td>
                                <td>R$ <%=fn(ValorParcela)%></td>
                            </tr>
                            <%
                            formaDados.movenext
                            wend
                            formaDados.close
                            set formaDados=nothing
                            %>
                        </tbody>
                        <tfoot>
                            <tr>
                                <td style="width:10%"></td>
                                <td style="width:50%;font-weight:bold;text-align:right">Total das parcelas pagas:</td>
                                <td>R$ <%=fn(ValorPago)%></td>
                            </tr>
                        </tfoot>
                    </table>
                </td>
            </tr>
        </tfoot>
    </table>
    <br>
    <%
    invDados.movenext
    wend
    invDados.close
    set invDados=nothing

    set recExcDados = db.execute("SELECT rec.*, pac.NomePaciente, clu.Nome Usuario "&_
                                 "FROM recibos rec "&_
                                 "LEFT JOIN  sys_financialinvoices inv ON inv.id=rec.InvoiceID "&_
                                 "LEFT JOIN pacientes pac ON pac.id=rec.PacienteID "&_
                                 "LEFT JOIN cliniccentral.licencasusuarios clu ON clu.id=rec.sysUser "&_
                                 "WHERE inv.id IS NULL AND rec.sysActive=1 AND rec.InvoiceID IS NOT NULL AND date(rec.sysDate)>="&mydatenull(De)&" AND date(rec.sysDate)<="&mydatenull(Ate)&" AND rec.UnidadeID="&UnidadeID)
    if not recExcDados.eof then
    %>
    <h4 class="text-left">Recibos Cancelados - <%=NomeFantasia%></h4>
    <table width="100%" class="table " id="tabelaRecibosCancelados">
        <thead>
            <th style="width:1%" class="danger hidden-print"><a class="btn-danger btn-xs"><i class="far fa-exclamation-circle"></i></a></th>
            <th style="width:10%" class="danger">Recibo</th>
            <th style="width:30%" class="danger">Paciente</th>
            <th style="width:30%" class="danger">Serviços</th>
            <th style="width:10%" class="danger">Valor</th>
            <th style="width:10%" class="danger">Data Gerada</th>
            <th style="width:10%" class="danger">Usuário</th>
        </thead>
        <tbody>
        <%
        while not recExcDados.eof
        %>
            <tr>
                <td></td>
                <td><%=Sigla&recExcDados("NumeroSequencial")%></td>
                <td><%=recExcDados("NomePaciente")%></td>
                <td><%=recExcDados("Servicos")%></td>
                <td>R$ <%=fn(recExcDados("Valor"))%></td>
                <td><%=formatdatetime(recExcDados("sysDate"),2)%></td>
                <td><%=recExcDados("Usuario")%></td>
            </tr>
        <%
        recExcDados.movenext
        wend
        recExcDados.close
        set recExcDados=nothing
        %>
        </tbody>
    </table>
    <%
    end if

    ValorTotalPag = 0

    set PagTotalBoleto = db.execute("SELECT mov.id, 'Boleto' PaymentMethod, COUNT(*) Quantidade, '1' Parcelas, SUM(mov.value) valor, mov.Date, '' Bandeira, '' NumeroCheque, '' DataCheque, bs.NomeStatus StatusBoleto "&_
                                                               "FROM sys_financialmovement mov  "&_
                                                               "INNER JOIN boletos_emitidos bm ON bm.MovementID=mov.id "&_
                                                               "LEFT JOIN cliniccentral.boletos_status bs ON bs.id=bm.StatusID "&_
                                                               "WHERE mov.id IN ("&MovementID&") AND bs.id NOT IN (3, 4) AND mov.`Type`='Bill'  ")

    set PagTotal = db.execute("SELECT fdp.InstallmentID, COUNT(*) Quantidade, fpm.PaymentMethod, IFNULL(fct.Parcelas,1) ParcelasPay,  "&_
                              "SUM(fdp.DiscountedValue) valor, mov.Date, band.Bandeira "&_
                              "FROM sys_financialdiscountpayments fdp "&_
                              "INNER JOIN sys_financialmovement mov  ON fdp.MovementID=mov.id "&_
                              "INNER JOIN sys_financialpaymentmethod fpm ON fpm.id=mov.PaymentMethodID "&_
                              "LEFT JOIN sys_financialcreditcardtransaction fct ON fct.MovementID=mov.id "&_
                              "LEFT JOIN cliniccentral.bandeiras_cartao band ON band.id=fct.BandeiraCartaoID "&_
                              "WHERE fdp.InstallmentID IN ("&MovementID&")  "&_
                              "GROUP BY fpm.PaymentMethod, ParcelasPay ")

    if not PagTotal.eof then
    %>
    <h4 class="text-left">Total Pagamento - <%=NomeFantasia%></h4>
    <table width="100%" class="table " id="tabelaRecibosCancelados">
        <thead>
            <th style="width:1%" class="success hidden-print"><a class="btn-success btn-xs"><i class="far fa-check-circle"></i></a></th>
            <th style="width:10%" class="success">Quantidade</th>
            <th style="width:50%" class="success">Forma de pagamento</th>
            <th style="width:10%" class="success">Valor</th>
        </thead>
        <tbody>
        <%
        if not PagTotalBoleto.eof then
            if PagTotalBoleto("valor")&""="" then
                ValorBoleto = 0
            else
                ValorBoleto = PagTotalBoleto("valor")
            end if
            ValorTotalPag = ValorTotalPag + ValorBoleto
            FormaPagamento = PagTotalBoleto("PaymentMethod")&" (Pendente)"
            if PagTotalBoleto("Quantidade")<>"0" then
            %>
            <tr>
                <td></td>
                <td><%=PagTotalBoleto("Quantidade")%></td>
                <td><%=FormaPagamento%></td>
                <td>R$ <%=fn(PagTotalBoleto("valor"))%></td>
            </tr>
            <%
            end if
        end if


        while not PagTotal.eof
            if PagTotal("valor")&""="" then
                ValorForma = 0
            else
                ValorForma = PagTotal("valor")
            end if
            ValorTotalPag = ValorTotalPag + ValorForma
            FormaPagamento = PagTotal("PaymentMethod")
            if PagTotal("ParcelasPay")>"1" then
                FormaPagamento = FormaPagamento & " - Parcelado " & PagTotal("ParcelasPay") & "x"
            end if
            %>
            <tr>
                <td></td>
                <td><%=PagTotal("Quantidade")%></td>
                <td><%=FormaPagamento%></td>
                <td>R$ <%=fn(PagTotal("valor"))%></td>
            </tr>
            <%
        PagTotal.movenext
        wend
        PagTotal.close
        set PagTotal=nothing
        %>
        </tbody>
        <tfoot>
            <tr>
                <td></td>
                <td></td>
                <td style="text-align: right"><b>Total</b></td>
                <td><b>R$ <%=fn(ValorTotalPag)%></b></td>
            </tr>
        </tfoot>
    </table>
    <%
    end if

unidade.movenext
wend
unidade.close
set unidade=nothing
%>