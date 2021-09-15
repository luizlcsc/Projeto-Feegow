<!--#include file="connect.asp"-->

<style type="text/css">
    @media print {
        td, th {
            font-size:10px;
        }
    }
</style>

<%
UnidadeID = req("UnidadeID")
Data = req("Data")
mData = mydatenull(Data)


function linhaTotais(Dinheiro, Cheque, Credito, Debito, Titulo, Classe)
    %>
    <table class="table table-condensed mt20">
        <thead>
            <tr class="<%= Classe %>">
                <th class="text-center" width="20%">Total Dinheiro</th>
                <th class="text-center" width="20%">Total Cheque</th>
                <th class="text-center" width="20%">Total Crédito</th>
                <th class="text-center" width="20%">Total Débito</th>
                <th class="text-center" width="20%">Total <%= Titulo %></th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <th class="text-right" width="20%">R$ <%= fn(Dinheiro) %></th>
                <th class="text-right" width="20%">R$ <%= fn(Cheque) %></th>
                <th class="text-right" width="20%">R$ <%= fn(Credito) %></th>
                <th class="text-right" width="20%">R$ <%= fn(Debito) %></th>
                <th class="text-right" width="20%">R$ <%= fn(Dinheiro + Cheque + Credito + Debito) %></th>
            </tr>
        </tbody>
    </table>
<hr class="short alt" />
    <%
end function

set u = db.execute("select id, NomeFantasia from (select '0' id, NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits) t where id="& UnidadeID)
if not u.eof then
    NomeFantasia = u("NomeFantasia")
end if
%>
<h2 class="text-center">Relatório de Caixa <br />
    <small> <%= req("Data") %> - <%= NomeFantasia %></small>
</h2>

<%
IF 0 THEN
    Valor = 0
    set cx = db.execute("select cx.SaldoInicial, cx.sysUser from caixa cx LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID where date(dtAbertura)="& mData &" and cx.SaldoInicial>0 AND cc.Empresa="& UnidadeID)
    if not cx.eof then
        %>
        <table class="table table-striped table-hover table-bordered table-condensed">
            <thead>
                <tr class="primary">
                    <th colspan="4">ABERTURA DE CAIXA</th>
                </tr>
                <tr class="primary">
                    <th width="20%">Forma</th>
                    <th width="35%">Descrição</th>
                    <th width="35%">Usuário</th>
                    <th width="10">Valor</th>
                </tr>
                <%
                while not cx.eof
                    %>
                    <tr>
                        <td>Dinheiro</td>
                        <td>Saldo de abertura</td>
                        <td><%= nameInTable(cx("sysUser")) %></td>
                        <td class="text-right">R$ <%= fn(cx("SaldoInicial")) %></td>
                    </tr>
                    <%
                cx.movenext
                wend
                cx.close
                set cx = nothing
                %>
            </thead>
        </table>
        <hr class="short alt" />
        <%
    end if
END IF

Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "ENTRADAS"
Classe = "success"
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="4"><%= Titulo %></th>
        </tr>
        <tr class="<%= Classe %>">
            <th width="20%">Forma</th>
            <th width="35%">Descrição</th>
            <th width="35%">Usuário</th>
            <th width="10">Valor</th>
        </tr>
    <tbody>
    <%
    Valor = 0
    if req("DetalharEntradas")="" then
        set dist = db.execute("select concat( ifnull(count(m.id), 0), ' lançamento(s)' ) Descricao, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID FROM sys_financialmovement m LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser WHERE m.Date="& mData &" AND m.UnidadeID="& UnidadeID &" AND NOT ISNULL(m.CaixaID) AND ((AccountAssociationIDDebit=7 AND AccountIDDebit=cx.id AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9))) GROUP BY pm.PaymentMethod, lu.Nome ORDER BY lu.Nome, pm.PaymentMethod")
    else
        set dist = db.execute("select m.id, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit FROM sys_financialmovement m LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser WHERE m.Date="& mData &" AND m.UnidadeID="& UnidadeID &" AND NOT ISNULL(m.CaixaID) AND ((AccountAssociationIDDebit=7 AND AccountIDDebit=cx.id AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9))) ORDER BY lu.Nome, pm.PaymentMethod")
    end if
    while not dist.eof


        if req("DetalharEntradas")="S" then
            Valor = dist("Value")
            set desc = db.execute("select group_concat(ifnull(proc.NomeProcedimento, '')) NomeProcedimento from itensdescontados idesc LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID where PagamentoID="& dist("id"))
            if not desc.eof then
                Procedimentos = desc("NomeProcedimento")
            end if
            Descricao = "<code>"& Procedimentos &"</code> " & accountName(dist("AccountAssociationIDCredit"), dist("AccountIDCredit"))
        else
            set soma = db.execute("select sum(Value) Total from sys_financialmovement where CaixaID="& dist("CaixaID") &" AND PaymentMethodID='"& dist("PaymentMethodID") &"' AND Date="& mData &" AND ((AccountAssociationIDDebit=7 AND AccountIDDebit="& dist("CaixaID") &" AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9)))")
            if not soma.eof then
                Valor = soma("Total")
            else
                Valor = 0
            end if
            Descricao = dist("Descricao")
        end if
        select case dist("PaymentMethodID")
            case 1
                Dinheiro = Dinheiro+Valor
            case 2
                Cheque = Cheque+Valor
            case 8
                Credito = Credito+Valor
            case 9
                Debito = Debito+Valor
        end select
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <td><%= dist("Nome") %></td>
            <td class="text-right">R$ <%= fn(Valor) %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing

    Balanco = Valor
    %>
    </tbody>
</table>
    <%= linhaTotais(Dinheiro, Cheque, Credito, Debito, Titulo, Classe) %>









<%

Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "TRANSFERÊNCIAS DE ENTRADA"
Classe = "success"
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="4"><%= Titulo %></th>
        </tr>
        <tr class="<%= Classe %>">
            <th width="20%">Forma</th>
            <th width="35%">Descrição</th>
            <th width="35%">Usuário</th>
            <th width="10">Valor</th>
        </tr>
    <tbody>
    <%
    Valor = 0
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=7 AND m.AccountAssociationIDCredit=1 AND m.Date="& mData &" AND cc.Empresa="& UnidadeID &" ORDER BY lu.Nome, pm.PaymentMethod")
    while not dist.eof
        Descricao = accountName(dist("AccountAssociationIDCredit"), dist("AccountIDCredit"))
        Valor = dist("Value")
        select case dist("PaymentMethodID")
            case 1
                Dinheiro = Dinheiro+Valor
            case 2
                Cheque = Cheque+Valor
            case 8
                Credito = Credito+Valor
            case 9
                Debito = Debito+Valor
        end select
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <td><%= dist("Nome") %></td>
            <td class="text-right">R$ <%= fn(Valor) %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing

    Balanco = Balanco + Valor
    %>
    </tbody>
</table>
    <%= linhaTotais(Dinheiro, Cheque, Credito, Debito, Titulo, Classe) %>









<%

Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "TRANSFERÊNCIAS ENTRE CAIXINHAS"
Classe = "dark"
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="4"><%= Titulo %></th>
        </tr>
        <tr class="<%= Classe %>">
            <th width="20%">Forma</th>
            <th width="35%">De</th>
            <th width="35%">Para</th>
            <th width="10">Valor</th>
        </tr>
    <tbody>
    <%
    Valor = 0
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=7 AND m.AccountAssociationIDCredit=7 AND m.Date="& mData &" AND cc.Empresa="& UnidadeID &" ORDER BY lu.Nome, pm.PaymentMethod")
    while not dist.eof
        De = accountName(dist("AccountAssociationIDCredit"), dist("AccountIDCredit"))
        Para = accountName(dist("AccountAssociationIDDebit"), dist("AccountIDDebit"))
        Valor = dist("Value")
        select case dist("PaymentMethodID")
            case 1
                Dinheiro = Dinheiro+Valor
            case 2
                Cheque = Cheque+Valor
            case 8
                Credito = Credito+Valor
            case 9
                Debito = Debito+Valor
        end select
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= De %></td>
            <td><%= Para %></td>
            <td class="text-right">R$ <%= fn(Valor) %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing
    %>
    </tbody>
</table>
    <%= linhaTotais(Dinheiro, Cheque, Credito, Debito, Titulo, Classe) %>









<%

Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "SAÍDAS"
Classe = "warning"
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="4"><%= Titulo %></th>
        </tr>
        <tr class="<%= Classe %>">
            <th width="20%">Forma</th>
            <th width="35%">Descrição</th>
            <th width="35%">Usuário</th>
            <th width="10">Valor</th>
        </tr>
    <tbody>
    <%
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser WHERE m.AccountAssociationIDCredit=7 AND m.AccountIDCredit=cx.id AND m.AccountAssociationIDDebit NOT IN(1,7) AND m.Date="& mData &" AND m.UnidadeID="& UnidadeID &" AND NOT ISNULL(m.CaixaID) AND NOT ISNULL(m.PaymentMethodID) ORDER BY lu.Nome, pm.PaymentMethod")
    while not dist.eof
        Descricao = accountName(dist("AccountAssociationIDDebit"), dist("AccountIDDebit"))
        Valor = dist("Value")
        select case dist("PaymentMethodID")
            case 1
                Dinheiro = Dinheiro+Valor
            case 2
                Cheque = Cheque+Valor
            case 8
                Credito = Credito+Valor
            case 9
                Debito = Debito+Valor
        end select
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <td><%= dist("Nome") %></td>
            <td class="text-right">R$ <%= fn(Valor) %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing

    Balanco = Balanco+Valor
    %>
    </tbody>
</table>
    <%= linhaTotais(Dinheiro, Cheque, Credito, Debito, Titulo, Classe) %>










<%

Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "TRANSFERÊNCIAS DE SAÍDA"
Classe = "warning"
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="4"><%= Titulo %></th>
        </tr>
        <tr class="<%= Classe %>">
            <th width="20%">Forma</th>
            <th width="35%">Descrição</th>
            <th width="35%">Usuário</th>
            <th width="10">Valor</th>
        </tr>
    <tbody>
    <%
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=1 AND m.AccountAssociationIDCredit=7 AND m.Date="& mData &" AND cc.Empresa="& UnidadeID &" ORDER BY lu.Nome, pm.PaymentMethod")
    while not dist.eof
        Descricao = accountName(dist("AccountAssociationIDDebit"), dist("AccountIDDebit"))
        Valor = dist("Value")
        select case dist("PaymentMethodID")
            case 1
                Dinheiro = Dinheiro+Valor
            case 2
                Cheque = Cheque+Valor
            case 8
                Credito = Credito+Valor
            case 9
                Debito = Debito+Valor
        end select
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <td><%= dist("Nome") %></td>
            <td class="text-right">R$ <%= fn(Valor) %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing

    Balanco = Balanco+Valor
    %>
    </tbody>
</table>
    <%= linhaTotais(Dinheiro, Cheque, Credito, Debito, Titulo, Classe) %>




<% if Balanco>0 then %>
<div class="alert alert-danger hidden">
    <i class="far fa-exclamation-circle"></i> R$ <%= fn(Balanco) %> pendentes de destinação.
</div>
<% end if %>