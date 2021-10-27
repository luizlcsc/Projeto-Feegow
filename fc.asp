<style>
.duplo {
    border-left:2px solid #CCC!important;
}
</style>

<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%

'ConnString = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow03.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=clinic7730;uid=root;'pwd=pipoca453;"
'Set db = Server.CreateObject("ADODB.Connection")
'db.Open ConnString

dim totCP(100), totCR(100), totDP(100), totDR(100)

'db.execute("delete from tempfc where sysUser="& session("User"))

db.execute("CREATE TABLE IF NOT EXISTS `tempfc` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `Descricao` varchar(155) DEFAULT NULL,  `CD` varchar(1) DEFAULT NULL,  `FormaID` int(11) DEFAULT NULL,  `sysUser` int(11) DEFAULT NULL,  `Compensado` tinyint(4) DEFAULT NULL,  `ParcelaID` int(11) DEFAULT NULL,  `ParcelaData` date DEFAULT NULL,  `ParcelaValor` double DEFAULT NULL,  `PagamentoID` int(11) DEFAULT NULL,  `PagamentoData` date DEFAULT NULL,  `PagamentoValor` double DEFAULT NULL,  `CompensacaoID` int(11) DEFAULT NULL,  `CompensacaoData` date DEFAULT NULL,  `CompensacaoValor` double DEFAULT NULL,  `ValorEfetivo` double DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=17804 DEFAULT CHARSET=utf8")
db.execute("DELETE FROM `tempfc` WHERE sysUser="& session("User"))

De = req("De")
Ate = req("Ate")
if Ate="" and De<>"" and isdate(De) then
    Ate = DiaMes("U", De)
end if

TipoFC = req("TipoFC")
Previsto = req("Previsto")
if Previsto="S" then
    colspan = 2
else
    colspan = 1
end if

if TipoFC="D" then
    nomeTipo = "Diário"
elseif TipoFC="M" then
    nomeTipo = "Mensal"
    De = req("DeM")
    Ate = DiaMes("U", req("AteM"))
elseif TipoFC="S" then
    nomeTipo = "Semanal"
    De = req("DeM")
    Ate = DiaMes("U", req("AteM"))
end if

De = cdate(De)
Ate = cdate(Ate)
Unidades = replace(req("U"), "|", "")
UnidadeID = req("UnidadeID")
mDe = mydatenull(De)
mAte = mydatenull(Ate)

if DateDiff("m", De, Ate)>3 then
    %>
    <div class="alert alert-warning text-center mt25">
        Utilize o período máximo de 3 meses. <br><br>
        <a href="javascript:window.close()" class="btn btn-primary">VOLTAR</a>
    </div>
    <%
    response.end
end if

'PASSO A PASSO ---------->'
'TRANSFERENCIA DE SALDO EH NOT IN 3'
    'INSERTS DE ENTRADAS
        'CHEQUE
            'Grava todos os pagtos recebidos em cheque recebido (2)
            db.execute("insert into tempfc (Descricao, CD, FormaID, Compensado, sysUser, ParcelaID, ParcelaData, ParcelaValor, PagamentoID, PagamentoData, PagamentoValor, CompensacaoID, CompensacaoData, CompensacaoValor, ValorEfetivo) SELECT 'Cheque', par.CD, 2, if(isnull(c.DataCompensacao), 0, 1), "& session("User") &", par.id ParcelaID, par.Date ParcelaData, par.Value ParcelaValor, pg.id PagamentoID, c.CheckDate PagamentoData, pg.Value PagamentoValor, c.id CompensacaoID,  c.DataCompensacao CompensacaoData, c.Valor CompensacaoValor, dp.DiscountedValue ValorEfetivo FROM sys_financialmovement pg LEFT JOIN sys_financialdiscountpayments dp ON dp.MovementID=pg.id LEFT JOIN sys_financialmovement par ON par.id=dp.InstallmentID LEFT JOIN sys_financialreceivedchecks c ON c.id=pg.ChequeID WHERE pg.PaymentMethodID=2 AND (pg.Date BETWEEN "& mDe &" AND "& mAte &" OR c.DataCompensacao  BETWEEN "& mDe &" AND "& mAte &" OR par.Date  BETWEEN "& mDe &" AND "& mAte &") AND par.CD='C' AND pg.UnidadeID="& UnidadeID )
            'AND pg.AccountAssociationIDCredit NOT IN (1,7) AND pg.AccountAssociationIDDebit IN (1, 7) 
        'CRÉDITO E DÉBITO
            'Grava todos os pagtos recebidos em cartão de crédito e débito (8, 9)
            'db.execute("insert into tempfc (Descricao, CD, FormaID, Compensado, sysUser, ParcelaID, ParcelaData, ParcelaValor, PagamentoID, PagamentoData, PagamentoValor, CompensacaoID, CompensacaoData, CompensacaoValor, ValorEfetivo) SELECT 'Crédito/Débito', par.CD, pg.PaymentMethodID FormaID, if(tp.InvoiceReceiptID=0, 0, 1), "& session("User") &", par.id ParcelaID, par.Date ParcelaData, par.Value ParcelaValor, pg.id PagamentoID, pg.Date PagamentoData, pg.Value PagamentoValor, tp.id, tp.DateToReceive, tp.Value-((tp.Fee/100)*tp.Value), tp.Value-((tp.Fee/100)*tp.Value) ValorEfetivo FROM sys_financialmovement pg LEFT JOIN sys_financialdiscountpayments dp ON dp.MovementID=pg.id LEFT JOIN sys_financialmovement par ON par.id=dp.InstallmentID LEFT JOIN sys_financialcreditcardtransaction t ON t.MovementID=pg.id LEFT JOIN sys_financialcreditcardreceiptinstallments tp ON tp.TransactionID=t.id WHERE pg.PaymentMethodID IN(8,9) AND (pg.Date BETWEEN "& mDe &" AND "& mAte &" OR tp.DateToReceive  BETWEEN "& mDe &" AND "& mAte &" OR par.Date  BETWEEN "& mDe &" AND "& mAte &") AND pg.UnidadeID="& UnidadeID )
            db.execute("insert into tempfc (Descricao, CD, FormaID, Compensado, sysUser, ParcelaID, ParcelaData, ParcelaValor, PagamentoID, PagamentoData, PagamentoValor, CompensacaoID, CompensacaoData, CompensacaoValor, ValorEfetivo) SELECT 'Crédito/Débito', par.CD, pg.PaymentMethodID FormaID, if(tp.InvoiceReceiptID=0, 0, 1), "& session("User") &", par.id ParcelaID, par.Date ParcelaData, par.Value ParcelaValor, pg.id PagamentoID, pg.Date PagamentoData, pg.Value PagamentoValor, tp.id, IFNULL( movBaixa.Date, tp.DateToReceive), tp.Value-((tp.Fee/100)*tp.Value), tp.Value-((tp.Fee/100)*tp.Value) ValorEfetivo FROM sys_financialmovement pg LEFT JOIN sys_financialdiscountpayments dp ON dp.MovementID=pg.id LEFT JOIN sys_financialmovement par ON par.id=dp.InstallmentID LEFT JOIN sys_financialcreditcardtransaction t ON t.MovementID=pg.id LEFT JOIN sys_financialcreditcardreceiptinstallments tp ON tp.TransactionID=t.id LEFT JOIN sys_financialmovement movBaixa ON movBaixa.id=tp.InvoiceReceiptID WHERE pg.PaymentMethodID IN(8,9) AND (pg.Date BETWEEN "& mDe &" AND "& mAte &" OR tp.DateToReceive  BETWEEN "& mDe &" AND "& mAte &" OR par.Date  BETWEEN "& mDe &" AND "& mAte &") AND par.CD='C' AND pg.UnidadeID="& UnidadeID )
            'AND pg.AccountAssociationIDCredit NOT IN (1,7) AND pg.AccountAssociationIDDebit IN (1, 7)
        'DINHEIRO E OUTROS
            'Grava todos os pagtos recebidos em dinheiro NOT IN(2, 8, 9)
            db.execute("insert into tempfc (Descricao, CD, FormaID, Compensado, sysUser, ParcelaID, ParcelaData, ParcelaValor, PagamentoID, PagamentoData, PagamentoValor, CompensacaoID, CompensacaoData, CompensacaoValor, ValorEfetivo) SELECT 'Dinheiro e transferências', par.CD, pg.PaymentMethodID FormaID, 1, "& session("User") &", par.id ParcelaID, par.Date ParcelaData, par.Value ParcelaValor, pg.id PagamentoID, pg.Date PagamentoData, pg.Value PagamentoValor, NULL, NULL, NULL, pg.Value ValorEfetivo FROM sys_financialmovement pg LEFT JOIN sys_financialdiscountpayments dp ON dp.MovementID=pg.id LEFT JOIN sys_financialmovement par ON par.id=dp.InstallmentID WHERE pg.PaymentMethodID NOT IN(2, 8, 9) AND (pg.Date BETWEEN "& mDe &" AND "& mAte &" OR par.Date BETWEEN "& mDe &" AND "& mAte &") AND par.CD='C' AND pg.UnidadeID="& UnidadeID )
            ' AND pg.AccountAssociationIDCredit NOT IN (1,7) AND pg.AccountAssociationIDDebit IN (1, 7)
    'INSERTS DE SAÍDAS
        'TODOS - A PRINCÍPIO
            sql = "insert into tempfc (Descricao, CD, FormaID, Compensado, sysUser, ParcelaID, ParcelaData, ParcelaValor, PagamentoID, PagamentoData, PagamentoValor, CompensacaoID, CompensacaoData, CompensacaoValor, ValorEfetivo) SELECT 'Dinheiro e transferências', par.CD, pg.PaymentMethodID FormaID, 1, "& session("User") &", par.id ParcelaID, par.Date ParcelaData, par.Value ParcelaValor, pg.id PagamentoID, pg.Date PagamentoData, pg.Value PagamentoValor, pg.id CompensacaoID, pg.Date CompensacaoData, pg.Value CompensacaoValor, pg.Value ValorEfetivo FROM sys_financialmovement pg LEFT JOIN sys_financialdiscountpayments dp ON dp.MovementID=pg.id LEFT JOIN sys_financialmovement par ON par.id=dp.InstallmentID WHERE (pg.Date BETWEEN "& mDe &" AND "& mAte &" OR par.Date BETWEEN "& mDe &" AND "& mAte &") AND par.CD='D' AND pg.UnidadeID="& UnidadeID
            'response.write( sql )
            db.execute( sql )
'<---------- PASSO A PASSO'









'Não pagos, que a princípio contarão como dinheiro
'db.execute("insert into tempfc (Descricao, CD, FormaID, sysUser, Compensado, ParcelaID, ParcelaData, ParcelaValor, PagamentoID, PagamentoData, PagamentoValor, ValorEfetivo) SELECT 'Dinheiro e transferências' Descricao, m.CD, 1 FormaID, "& session("User") &" sysUser, 0 Compensado, m.id ParcelaID, m.Date ParcelaData, m.Value ParcelaValor, 0 PagamentoID, NULL PagamentoData, 0 PagamentoValor, m.Value-ifnull(sum(dp.DiscountedValue), 0) ValorEfetivo FROM sys_financialmovement m LEFT JOIN sys_financialdiscountpayments dp ON dp.InstallmentID=m.id WHERE m.`Type`='Bill' AND m.UnidadeID="& UnidadeID &" AND m.Date BETWEEN "& mDe &" AND "& mAte &" and m.Value>IFNULL(m.ValorPago,0) GROUP BY m.id")

db.execute("insert into tempfc (Descricao, CD, FormaID, sysUser, Compensado, ParcelaID, ParcelaData, ParcelaValor, PagamentoID, PagamentoData, PagamentoValor, ValorEfetivo) SELECT 'Dinheiro e transferências' Descricao, m.CD, m.PaymentMethodID, "& session("User") &" sysUser, 0 Compensado, m.id ParcelaID, m.Date ParcelaData, m.Value ParcelaValor, 0 PagamentoID, NULL PagamentoData, 0 PagamentoValor, m.Value-ifnull(sum(dp.DiscountedValue), 0) ValorEfetivo FROM sys_financialmovement m LEFT JOIN sys_financialinvoices i ON i.id=m.InvoiceID LEFT JOIN sys_financialdiscountpayments dp ON dp.InstallmentID=m.id WHERE m.`Type`='Bill' AND i.CompanyUnitID="& UnidadeID &" AND m.Date BETWEEN "& mDe &" AND "& mAte &" and m.Value>IFNULL(m.ValorPago,0) GROUP BY m.id")

'Loop em todos os pagtos recebidos no período vendo o que não associou a um discountpayment

'Loop em todas as parcelas vencendo no período que não foram incorporadas


'CONTAS FIXAS >'
set fixa = db.execute("SELECT i.id, concat(i.AssociationAccountID, '_', AccountID) Conta, i.PrimeiroVencto, i.RepetirAte, i.CompanyUnitID, i.Intervalo, i.TipoIntervalo, i.CD, i.Geradas, (ii.Quantidade * (ii.ValorUnitario+ii.Acrescimo)) Valor, i.FormaID, ii.id*-1 ParcelaID FROM itensinvoicefixa ii LEFT JOIN invoicesfixas i ON i.id=ii.InvoiceID WHERE i.sysActive=1 AND year(i.PrimeiroVencto)<="& mAte &" AND CompanyUnitID="& UnidadeID )
while not fixa.eof

    CD = fixa("CD")
    FormaID = fixa("FormaID")
    Valor = fixa("Valor")
    if FormaID=0 then
        FormaID=1
    end if

    Parcela = 0
    ParcelaID = fixa("ParcelaID")
    PrimeiroVencto = fixa("PrimeiroVencto")
    Geradas = fixa("Geradas")
    Intervalo = fixa("Intervalo")
    TipoIntervalo = fixa("TipoIntervalo")
    RepetirAte = fixa("RepetirAte")
    if isnull(RepetirAte) then
        UltimaData = Ate
    else
        if Ate<RepetirAte then
            UltimaData = Ate
        else
            UltimaData = RepetirAte
        end if
    end if
    Data = PrimeiroVencto
    while Data<UltimaData
        Parcela = Parcela+1
        if Data>=De and Data<=Ate and instr(Geradas, "|"& Parcela &"|")=0 then
            db.execute("insert into tempfc (Descricao, CD, FormaID, sysUser, Compensado, ParcelaID, ParcelaData, ParcelaValor, PagamentoID, PagamentoValor, ValorEfetivo) values ('Desp fixa', '"& CD &"', "& FormaID &", "& session("User") &", 0, "& ParcelaID &", "& mydatenull(Data) &", "& treatvalnull(Valor) &", 0, 0, "& treatvalnull(Valor) &")")
        end if
        Data = dateAdd(TipoIntervalo, Intervalo, Data)
    wend
fixa.movenext
wend
fixa.close
set fixa = nothing
'< CONTAS FIXAS'





function classVV(Val)
    if Val<0 then
        classVV = "danger"
    elseif Val>0 then
        classVV = "success"
    else
        classVV = ""
    end if
end function


function accountBalanceData(AccountID, Data)
	splAccountInQuestion = split(AccountID, "_")
	AccountAssociationID = splAccountInQuestion(0)
	AccountID = splAccountInQuestion(1)

	accountBalanceData = 0
	set getMovement = db.execute("select * from sys_financialMovement where ((AccountAssociationIDCredit="&AccountAssociationID&" and AccountIDCredit="&AccountID&") or (AccountAssociationIDDebit="&AccountAssociationID&" and AccountIDDebit="&AccountID&")) and Date<='"&myDate(Data)&"' order by Date")

	if not getMovement.eof then
        while not getMovement.eof
            Value = getMovement("Value")
            AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
            AccountIDCredit = getMovement("AccountIDCredit")
            AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
            AccountIDDebit = getMovement("AccountIDDebit")
            PaymentMethodID = getMovement("PaymentMethodID")
            Rate = getMovement("Rate")
            'defining who is the C and who is the D
            'if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
            if AccountAssociationIDCredit&""=AccountAssociationID&"" and AccountIDCredit&""=AccountID&"" then
                CD = "C"
                'if getMovement("Currency")<>session("DefaultCurrency") then
                '	Value = Value / Rate
                'end if
                accountBalanceData = accountBalanceData+Value
            else
                'if getMovement("Currency")<>session("DefaultCurrency") then
                '	Value = Value / Rate
                'end if
                CD = "D"
                accountBalanceData = accountBalanceData-Value
            end if
            '-
            cType = getMovement("Type")
        getMovement.movenext
        wend
        getMovement.close
        set getMovement = nothing

    end if

	if AccountAssociationID=1 or AccountAssociationID=7 then
		accountBalanceData = accountBalanceData*(-1)
	end if

end function




SaldoInicial = 0

'Nível 1 real contas da unidade
set cc = db.execute("select id from sys_financialcurrentaccounts where AccountType IN (1, 2) AND Empresa="& UnidadeID)
while not cc.eof
    SaldoInicial = SaldoInicial + accountBalanceData("1_"& cc("id"), De-1)
cc.movenext
wend
cc.close
set cc = nothing

sqlPNomeU = "select group_concat(NomeFantasia) NomeUnidade FROM vw_unidades where id in ("& UnidadeID &")"
'response.write(sqlPNomeU)
set pNomeU = db.execute( sqlPNomeU)
NomeUnidade = pNomeU("NomeUnidade")


%>

<head>
    <h2 class="text-center">FLUXO DE CAIXA - <%= ucase(NomeUnidade&"") %>  <br> <small><%= nomeTipo %> -  <%= De %> a <%= Ate %></small> </h2>
<head>



<%'= "Saldo inicial: "& fn(SaldoInicial) %>
<br><br>

<%
'FLUXO DE CAIXA MENSAL
PrevCTG = 0
PrevDTG = 0
ARecTG = 0
APagTG = 0
if TipoFC="D" then %>
    <table class="table table-condensed table-bordered table-hover">
        <thead>
            <tr class="info">
                <th rowspan="2" colspan="2">Data</th>
                <th colspan="<%= colspan %>">Entradas</th>
                <th colspan="<%= colspan %>">Saídas</th>
                <th colspan="<%= colspan %>">Saldo</th>
            </tr>
            <tr class="info">
                <% if Previsto="S" then %>
                    <th>Prev.</th>
                <% end if %>
                <th>Real.</th>
                <% if Previsto="S" then %>
                    <th>Prev.</th>
                <% end if %>
                <th>Real.</th>
                <% if Previsto="S" then %>
                    <th>Prev.</th>
                <% end if %>
                <th>Real.</th>
            </tr>
        </thead>
        <tbody>
                <%
                Data = cdate(De)
                while Data<=Ate
                    response.flush()

                    SaldoPrev = 0
                    SaldoReal = 0

                    mData = mydatenull(Data)
                    'ENTRADAS PREVISTAS
                    set nParc = db.execute("select ifnull(sum(ValorEfetivo),0) Total from tempfc where sysUser="& session("User") &" AND CD='C' and (ParcelaData="& mData &" and FormaID NOT IN(2, 8, 9) OR CompensacaoData="& mData &" and FormaID IN(8,9) or PagamentoData="& mData &" and FormaID=2)")
                    PrevC = nParc("Total")

                    'SAÍDAS PREVISTAS
                    set nParc = db.execute("select ifnull(sum(ValorEfetivo),0) Total from tempfc where sysUser="& session("User") &" AND CD='D' and (ParcelaData="& mData &" and FormaID NOT IN(2, 8, 9) OR CompensacaoData="& mData &" and FormaID IN(8,9) or PagamentoData="& mData &" and FormaID=2)")
                    PrevD = nParc("Total")

                    'ENTRADAS REALIZADAS
                    set nParc = db.execute("select ifnull(sum(ValorEfetivo),0) Total from tempfc where sysUser="& session("User") &" AND CD='C' and (ParcelaData="& mData &" and FormaID NOT IN(2, 8, 9) OR CompensacaoData="& mData &" and FormaID IN(8,9) or CompensacaoData="& mData &" and FormaID=2) AND Compensado=1")
                    RealC = nParc("Total")

                    'SAÍDAS REALIZADAS
                    set nParc = db.execute("select ifnull(sum(ValorEfetivo),0) Total from tempfc where sysUser="& session("User") &" AND CD='D' and (ParcelaData="& mData &" and FormaID NOT IN(2, 8, 9) OR CompensacaoData="& mData &" and FormaID IN(8,9) or PagamentoData="& mData &" and FormaID=2) AND Compensado=1")
                    RealD = nParc("Total")


                    SaldoPrev = SaldoPrev+PrevC-PrevD
                    SaldoReal = SaldoReal+RealC-RealD

                    if weekday(Data)=1 then
                        fdia = "dark"
                    else
                        fdia = ""
                    end if
                    %>
                    <tr>
                        <td width="1%" class="<%= fdia %>"><%= ucase(left(weekdayname(weekday(Data)), 1)) %></td>
                        <td><%= Data %></td>
                        <% if Previsto="S" then %>
                            <td class="text-right" onclick="am('<%= Data %>', '<%= Data %>', 'C', '', 'Prev')">
                                <%= fn(PrevC) %>
                            </td>
                        <% end if %>
                        <td class="text-right" onclick="am('<%= Data %>', '<%= Data %>', 'C', '', 'Real')">
                            <%= fn(RealC) %>
                        </td>
                        <% if Previsto="S" then %>
                            <td class="text-right" onclick="am('<%= Data %>', '<%= Data %>', 'D', '', 'Prev')">
                                <%= fn(PrevD) %>
                            </td>
                        <% end if %>
                        <td class="text-right" onclick="am('<%= Data %>', '<%= Data %>', 'D', '', 'Real')">
                            <%= fn(RealD) %>
                        </td>
                        <% if Previsto="S" then %>
                            <td class="text-right">
                                <%= fn(SaldoPrev) %>
                            </td>
                        <% end if %>
                        <td class="text-right">
                            <%= fn(SaldoReal) %>
                        </td>
                    </tr>
                    <%
                    Data = dateAdd("d", 1, Data)
                wend
                %>
            </tr>
        </tbody>
    </table>




<%
'FLUXO DE CAIXA MENSAL
elseif TipoFC="M" then

    Saldo = SaldoInicial
    %>

    <table class="table table-condensed table-bordered">
        <thead>
            <tr class="info">
                <th>Descrição</th>
                <%
                Data = De
                while Data<=Ate
                    %>
                    <th colspan="<%= colspan %>"><%= ucase(monthName(month(Data))) &"/"& year(data) %></th>
                    <%
                    Data = dateAdd("m", 1, Data)
                wend
                %>
            </tr>
            <tr class="success">
                <th>Entradas</th>
                <%
                Data = De
                while Data<=Ate
                    if Previsto="S" then
                        %>
                        <th>Prev.</th>
                        <%
                    end if
                    %>
                    <th>Real.</th>
                    <%
                    Data = dateAdd("m", 1, Data)
                wend
                %>
            </tr>
        </thead>
        <tbody>
            <%
            CD = "C"
            set dist = db.execute("select * from cliniccentral.fc WHERE CD='C'")
            while not dist.eof
                Descricao = dist("description")
                mainSQL = dist("mainSQL")
            %>
            <tr>
                <td><%= Descricao %></td>
                <%
                Data = De
                numeroCol = 0
                while Data<=Ate
                    response.flush()

                    numeroCol = numeroCol+1

                    Mes = month(Data)
                    Ano = year(Data)

                    sql = replace(replace(replace(replace(mainSQL, "[Ano]", Ano), "[Mes]", Mes), "[sysUser]", session("User")), "[CD]", CD)
                    
                    set reg = db.execute( sql )
                    PrevC = reg("PrevC")
                    RealC = reg("RealC")

                    totCP(numeroCol) = totCP(numeroCol) + ccur(PrevC)
                    totCR(numeroCol) = totCR(numeroCol) + ccur(RealC)

                    PrevCTG = PrevCTG + PrevC
                    if Previsto="S" then
                        %>
                        <td class="text-right duplo" onclick="am('<%= 1 &"/"& Mes &"/"& Ano %>', '<%= diames("U", 1 &"/"& Mes &"/"& Ano) %>', '<%= CD %>', '<%= Descricao %>', 'Prev')">
                            <%= fn(PrevC) %>
                        </td>
                        <%
                    end if
                    %>
                    <td class="text-right" onclick="am('<%= 1 &"/"& Mes &"/"& Ano %>', '<%= diames("U", 1 &"/"& Mes &"/"& Ano) %>', '<%= CD %>', '<%= Descricao %>', 'Real')">
                        <%= fn(RealC) %>
                    </td>
                    <%
                    Data = dateAdd("m", 1, Data)
                wend
                %>
            </tr>
            <%
            dist.movenext
            wend
            dist.close
            set dist = nothing

            %>


            <tr>
                <th>Total de Entradas</th>
                <%
                Data = De
                numeroCol = 0
                while Data<=Ate
                    response.flush()

                    numeroCol = numeroCol + 1

                    Mes = month(Data)
                    Ano = year(Data)
                    
                    if Previsto="S" then
                        %>
                        <th class="text-right duplo">
                            <%= fn( totCP( numeroCol ) ) %>
                        </th>
                        <%
                    end if
                    %>
                    <th class="text-right">
                        <%= fn( totCR( numeroCol ) ) %>
                    </th
                    >
                    <%
                    Data = dateAdd("m", 1, Data)
                wend
                %>
            </tr>




            <tr class="danger">
                <th>Saídas</th>
                <%
                Data = De
                while Data<=Ate
                    if Previsto="S" then
                        %>
                        <th class="duplo">Prev.</th>
                        <%
                    end if
                    %>
                    <th>Real.</th>
                    <%
                    Data = dateAdd("m", 1, Data)
                wend
                %>
            </tr>
            <%
            CD = "D"
            set dist = db.execute("select * from cliniccentral.fc WHERE CD='D'")
            while not dist.eof
                'response.write(dist("id") &" - "& dist("PrevSQL") &"<br>")
                Descricao = dist("description")
                mainSQL = dist("mainSQL")
            %>
            <tr>
                <td><%= Descricao %></td>
                <%
                Data = De
                numeroCol = 0
                while Data<=Ate
                    response.flush()

                    numeroCol = numeroCol+1

                    Mes = month(Data)
                    Ano = year(Data)

                    sql = replace(replace(replace(replace(mainSQL, "[Ano]", Ano), "[Mes]", Mes), "[sysUser]", session("User")), "[CD]", CD)

                    'response.write( sql &"<br>")
                    set reg = db.execute( sql )
                    PrevD = reg("PrevC")
                    RealD = reg("RealC")

                    totDP(numeroCol) = totDP(numeroCol) + ccur(PrevD)
                    totDR(numeroCol) = totDR(numeroCol) + ccur(RealD)

                    PrevDTG = PrevDTG + PrevD
                    if Previsto="S" then
                        %>
                        <td class="text-right duplo" onclick="am('<%= 1 &"/"& Mes &"/"& Ano %>', '<%= diames("U", 1 &"/"& Mes &"/"& Ano) %>', '<%= CD %>', '<%= Descricao %>', 'Prev')">
                            <%= fn(PrevD) %>
                        </td>
                        <%
                    end if
                    %>
                    <td class="text-right" onclick="am('<%= 1 &"/"& Mes &"/"& Ano %>', '<%= diames("U", 1 &"/"& Mes &"/"& Ano) %>', '<%= CD %>', '<%= Descricao %>', 'Real')">
                        <%= fn(RealD) %>
                    </td>
                    <%
                    Data = dateAdd("m", 1, Data)
                wend
                %>
            </tr>
            <%
            dist.movenext
            wend
            dist.close
            set dist = nothing


            %>
            




            <tr>
                <th>Total de Saídas</th>
                <%
                Data = De
                numeroCol = 0
                while Data<=Ate
                    response.flush()

                    numeroCol = numeroCol + 1

                    Mes = month(Data)
                    Ano = year(Data)
                    
                    if Previsto="S" then
                        %>
                        <th class="text-right duplo">
                            <%= fn( totDP( numeroCol ) ) %>
                        </th>
                        <%
                    end if
                    %>
                    <th class="text-right">
                        <%= fn( totDR( numeroCol ) ) %>
                    </th>
                    <%
                    Data = dateAdd("m", 1, Data)
                wend
                %>
            </tr>






<% if session("Banco")<>"clinic7211" then %>
            <tr class="info">
                <th colspan="500">
                    Contas a Pagar e a Receber
                </th>
            </tr>
            <tr>
                <th class="success">Contas a Receber</th>
                <%
                Data = De
                while Data<=Ate
                    response.flush()

                    Mes = month(Data)
                    Ano = year(Data)

                    sql = "select "&_
                        "(select ifnull(sum(m.Value),0) from sys_financialmovement m LEFT JOIN sys_financialinvoices i ON i.id=m.InvoiceID where m.CD='C' and m.Type='Bill' and month(m.Date)="&Mes&" and year(m.Date)="& Ano &" AND ifnull(i.CompanyUnitID,0)="& UnidadeID &") AReceber"
                        
                    set reg = db.execute( sql )
                    AReceber = reg("AReceber")

                    ARecTG = ARecTG + AReceber
                    %>
                    <td colspan="<%= colspan %>" class="text-right">
                        <%= fn(AReceber) %>
                    </td>
                    <%
                    Data = dateAdd("m", 1, Data)
                wend
                %>
            </tr>
            <tr>
                <th class="danger">Contas a Pagar</th>
                <%
                Data = De
                while Data<=Ate
                    response.flush()

                    Mes = month(Data)
                    Ano = year(Data)

                    sql = "select "&_
                        "(select ifnull(sum(m.Value),0) from sys_financialmovement m LEFT JOIN sys_financialinvoices i ON i.id=m.InvoiceID where m.CD='D' and m.Type='Bill' and month(m.Date)="&Mes&" and year(m.Date)="& Ano &" AND ifnull(i.CompanyUnitID,0)="& UnidadeID &") APagar"
                        
                    set reg = db.execute( sql )
                    APagar = reg("APagar")

                    APagTG = APagTG + APagar
                    %>
                    <td colspan="<%= colspan %>" class="text-right">
                        <%= fn(APagar) %>
                    </td>
                    <%
                    Data = dateAdd("m", 1, Data)
                wend
                %>
            </tr>
<% end if %>
        </tbody>
    </table>


<% end if %>

<script type="text/javascript">
function am(De, Ate, CD, Desc, PR){
    /*
    $("#modal-table").modal("show");
    $.get("detFC.asp?De="+De+"&Ate="+Ate+"&Desc="+Desc+"&CD="+CD +"&PR="+PR, function(data){
        $("#modal").html(data);
    });
    */
    window.open("PrintStatement.asp?R=detFC&De="+De+"&Ate="+Ate+"&Desc="+Desc+"&CD="+CD +"&PR="+PR);
}

/*
$("td").click(function(){
    var dt =  $(this).attr("data-m").toString();
    if(dt!=undefined){

        window.open('PrintStatement.asp?R=FluxoCaixa2&Tipo=Diario&TipoFC=D&De='+ dt +'&Ate=&DeM=&AteM=&UnidadeID=<%= req("UnidadeID") %>')
    }
})
*/
</script>



<%
if request.serverVariables("REMOTE_ADDR")="::1" then
    response.write("Previsto Geral C = "& fn( PrevCTG ) &" - ")
    response.write("Previsto Geral D = "& fn( PrevDTG ) &" <br> ")
    response.write("A receber Geral C = "& fn( ARecTG ) &" - ")
    response.write("A pagar Geral D = "& fn( APagTG ) )
end if
%>