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
DetalharEntradas = req("DetalharEntradas")
MC = req("MC")


function linhaTotais(Dinheiro, Cheque, Credito, Debito,Boleto,Pix,Titulo, Classe)
    %>
    <table class="table table-condensed mt20">
        <thead>
            <tr class="<%= Classe %>">
                <th class="text-center" width="10%">Total Dinheiro</th>
                <th class="text-center" width="10%">Total Cheque</th>
                <th class="text-center" width="10%">Total Crédito</th>
                <th class="text-center" width="10%">Total Débito</th>
                <th class="text-center" width="10%">Total Boleto</th>
                <th class="text-center" width="10%">Total Pix</th>
                <th class="text-center" width="20%">Total <%= Titulo %></th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <th class="text-center">R$ <%= fn(Dinheiro) %></th>
                <th class="text-center">R$ <%= fn(Cheque) %></th>
                <th class="text-center">R$ <%= fn(Credito) %></th>
                <th class="text-center">R$ <%= fn(Debito) %></th>
                <th class="text-center">R$ <%= fn(Boleto) %></th>
                <th class="text-center">R$ <%= fn(Pix) %></th>
                <th class="text-center">R$ <%= fn(Dinheiro + Cheque + Credito + Debito + Boleto + Pix) %></th>
            </tr>
        </tbody>
    </table>
<hr class="short alt" />
    <%
end function

if MC="" then
    set u = db.execute("select id, NomeFantasia from (select '0' id, NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits) t where id="& UnidadeID)
    if not u.eof then
        NomeFantasia = u("NomeFantasia")
    end if
%>
<h2 class="text-center">Relatório de Caixa <br />
    <small> <%= req("Data") %> - <%= NomeFantasia %></small>
</h2>

<%
else
    %>
    <div class="panel"><div class="panel-body">
    <%
end if


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
Boleto = 0
Pix = 0

Titulo = "ENTRADAS"
if DetalharEntradas="" then
    Titulo = Titulo & " <a class='btn btn-default btn-xs' href='./PrintStatement.asp?R=rRelatorioCaixa&Tipo="& req("Tipo") &"&Data="& req("Data") &"&UnidadeID="& req("UnidadeID") &"&DetalharEntradas=S'>DETALHAR ENTRADAS</a> "
end if
Classe = "success"
if MC="" then
    if DetalharEntradas="" then
        sql = "select concat( ifnull(count(m.id), 0), ' lançamento(s)' ) Descricao, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID FROM sys_financialmovement m LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialcurrentaccounts ca ON ca.id=cx.ContaCorrenteID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser WHERE m.Date="& mData &" AND m.UnidadeID="& UnidadeID &" AND NOT ISNULL(m.CaixaID) AND ((AccountAssociationIDDebit=7 AND AccountIDDebit=cx.id AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9,4,15))) AND ca.Empresa=m.UnidadeID GROUP BY pm.PaymentMethod, m.CaixaID ORDER BY lu.Nome, pm.PaymentMethod"
        set dist = db.execute(sql)
    else
        sql = "select m.id, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit, pac.CPF Identificacao, pac.NomePaciente NomeConta "&_
        "FROM sys_financialmovement m  "&_
        "LEFT JOIN caixa cx ON cx.id=m.CaixaID  "&_
        "LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID  "&_
        "LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser  "&_
        "LEFT JOIN pacientes pac on pac.id=m.AccountIDCredit AND m.AccountAssociationIDCredit=3 "&_
        "WHERE m.Date="& mData &" AND m.UnidadeID="& UnidadeID &" AND NOT ISNULL(m.CaixaID) AND ((AccountAssociationIDDebit=7 AND AccountIDDebit=cx.id AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9,4,15))) ORDER BY lu.Nome, pm.PaymentMethod"
        
        set dist = db.execute(sql)
    end if
    'response.write(sql)
else
    if DetalharEntradas="" then
        set dist = db.execute("select concat( ifnull(count(m.id), 0), ' lançamento(s)' ) Descricao, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID FROM sys_financialmovement m LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser WHERE m.CaixaID="& session("CaixaID") &" AND ((AccountAssociationIDDebit=7 AND AccountIDDebit=cx.id AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9,4,15))) GROUP BY pm.PaymentMethod, m.CaixaID ORDER BY lu.Nome, pm.PaymentMethod")
    else
        set dist = db.execute("select m.id, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit FROM sys_financialmovement m LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser WHERE m.CaixaID="& session("CaixaID") &" AND ((AccountAssociationIDDebit=7 AND AccountIDDebit=cx.id AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9,4,15))) ORDER BY lu.Nome, pm.PaymentMethod")
    end if
end if

if not dist.eof then
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="<% if DetalharEntradas="S" then %>9<%else%>6<% end if %>"><%= Titulo %></th>
        </tr>
        <tr class="<%= Classe %>">
            <th >Forma</th>
            <th >Descrição</th>
            <th >Identificação</th>

            <%
            if DetalharEntradas="S" then
            %>
            <th>Procedimentos</th>
            <th>NFS-e</th>
            <th>Executantes</th>
            <th>Tabela</th>
            <%
            end if
            %>

            <th >Usuário</th>
            <th >Valor</th>
        </tr>
    <tbody>
    <%
    Valor = 0

    response.Buffer
    while not dist.eof
        response.Flush()

        Executantes=""
        NomeTabela=""
        Descricao=""
        Identificacao=""

        if FieldExists(dist, "NomeConta") then
            if dist("NomeConta")&""<>"" then
                Descricao = dist("NomeConta")&""
                Identificacao = dist("Identificacao")&""
            end if
        end if

        if MC="" then
            if DetalharEntradas="S" then
                Valor = dist("Value")
                sqlDetalhado = "select tp.NomeTabela, prof.NomeProfissional, group_concat(ifnull(proc.NomeProcedimento, '')) NomeProcedimento, ii.InvoiceID, fi.nroNFe from itensdescontados idesc LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialinvoices fi ON fi.id=ii.InvoiceID LEFT JOIN tabelaparticular tp ON tp.id=fi.TabelaID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN profissionais prof ON prof.id=ii.ProfissionalID and ii.Associacao=5 where PagamentoID="& dist("id")
                set desc = db.execute(sqlDetalhado)
                if not desc.eof then
                    Procedimentos = desc("NomeProcedimento")
                    NomeTabela = desc("NomeTabela")
                    Executantes = desc("NomeProfissional")
                    nroNFe=""
                    if desc("nroNFe")&""<>"" then
                        nroNFe = desc("nroNFe")
                    end if
                end if

                if Descricao="" then
                    Descricao = accountName(dist("AccountAssociationIDCredit"), dist("AccountIDCredit"))
                end if
                Procedimentos = "<a style='cursor:pointer' onclick=""window.open('./?P=Invoice&Pers=1&CD=C&I="& desc("InvoiceID") &"')"" >"& Procedimentos &"</code> "

            else
                set soma = db.execute("select sum(Value) Total from sys_financialmovement where CaixaID="& dist("CaixaID") &" AND PaymentMethodID='"& dist("PaymentMethodID") &"' AND Date="& mData &" AND ((AccountAssociationIDDebit=7 AND AccountIDDebit="& dist("CaixaID") &" AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9,4,15)))")
                if not soma.eof then
                    Valor = soma("Total")
                else
                    Valor = 0
                end if
                Descricao = dist("Descricao")
            end if
        else
            if DetalharEntradas="S" then
                Valor = dist("Value")
                set desc = db.execute("select group_concat(ifnull(proc.NomeProcedimento, '')) NomeProcedimento, fi.nroNFe from itensdescontados idesc LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialinvoices fi ON fi.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID where PagamentoID="& dist("id"))
                if not desc.eof then
                    Procedimentos = desc("NomeProcedimento")
                    nroNFe=""
                    if desc("nroNFe")&""<>"" then
                        nroNFe = desc("nroNFe")
                    end if
                end if

                if Descricao="" then
                    Descricao = accountName(dist("AccountAssociationIDCredit"), dist("AccountIDCredit"))
                end if
                Descricao = Descricao & nroNFe
            else
                set soma = db.execute("select sum(Value) Total from sys_financialmovement where CaixaID="& session("CaixaID") &" AND PaymentMethodID='"& dist("PaymentMethodID") &"' AND ((AccountAssociationIDDebit=7 AND AccountIDDebit="& session("CaixaID") &" AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9,4,15)))")
                if not soma.eof then
                    Valor = soma("Total")
                else
                    Valor = 0
                end if
                Descricao = dist("Descricao")
            end if
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
            case 4
                Boleto = Boleto+Valor
            case 15
                Pix = Pix+Valor
        end select
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <td><%= Identificacao %></td>
            <%
            if DetalharEntradas="S" then
            %>
            <td><%= Procedimentos %></td>
            <td><%= nroNFe %></td>
            <td><%= Executantes %></td>
            <td><%= NomeTabela %></td>
            <%
            end if
            %>
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
    <% call linhaTotais(Dinheiro, Cheque, Credito, Debito, Boleto, Pix, Titulo, Classe) %>
<%
end if







Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "TRANSFERÊNCIAS DE ENTRADA"
Classe = "success"
Valor = 0
if MC="" then
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=7 AND m.AccountAssociationIDCredit=1 AND m.Date="& mData &" AND cc.Empresa="& UnidadeID &" ORDER BY lu.Nome, pm.PaymentMethod")
else
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=7 AND m.AccountAssociationIDCredit=1 AND m.AccountIDDebit="& session("CaixaID") &" ORDER BY lu.Nome, pm.PaymentMethod")
end if
if not dist.eof then
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
            case 4
                Boleto = Boleto+Valor
            case 15
                Pix = Pix+Valor
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
    <%= linhaTotais(Dinheiro, Cheque, Credito, Debito, Boleto, Pix, Titulo, Classe) %>
<%
end if






Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "TRANSFERÊNCIAS ENTRE CAIXINHAS"
Classe = "dark"
Valor = 0
if MC="" then
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=7 AND m.AccountAssociationIDCredit=7 AND m.Date="& mData &" AND cc.Empresa="& UnidadeID &" ORDER BY lu.Nome, pm.PaymentMethod")
else
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=7 AND m.AccountAssociationIDCredit=7 AND m.CaixaID="& session("CaixaID") &" ORDER BY lu.Nome, pm.PaymentMethod")
end if
if not dist.eof then
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
            case 4
                Boleto = Boleto+Valor
            case 15
                Pix = Pix+Valor
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
    <%= linhaTotais(Dinheiro, Cheque, Credito, Debito, Boleto, Pix, Titulo, Classe) %>
<%
end if

Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "SAÍDAS"
Classe = "warning"
if MC="" then
    sql = "select m.name,m.id, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit, COALESCE(forn.NomeFornecedor, prof.NomeProfissional) NomeConta,  COALESCE(forn.CPF, prof.CPF) Identificacao  "&_
    "FROM sys_financialmovement m  "&_
    "LEFT JOIN caixa cx ON cx.id=m.CaixaID  "&_
    "LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID  "&_
    "LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser  "&_
    "LEFT JOIN fornecedores forn ON forn.id= m.AccountIDDebit AND m.AccountAssociationIDDebit=2 "&_
    "LEFT JOIN profissionais prof ON prof.id= m.AccountIDDebit AND m.AccountAssociationIDDebit=5 "&_
    "WHERE m.AccountAssociationIDCredit=7 AND m.AccountIDCredit=cx.id AND m.AccountAssociationIDDebit NOT IN(1,7) AND m.Date="& mData &"  "&_
    "AND m.UnidadeID="& UnidadeID &" AND NOT ISNULL(m.CaixaID) AND NOT ISNULL(m.PaymentMethodID) ORDER BY lu.Nome, pm.PaymentMethod"
else
    sql  = "select m.name, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit, COALESCE(forn.NomeFornecedor, prof.NomeProfissional) NomeConta,  COALESCE(forn.CPF, prof.CPF) Identificacao "&_
    "FROM sys_financialmovement m "&_
    "LEFT JOIN caixa cx ON cx.id=m.CaixaID "&_
    "LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID "&_
    "LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser "&_
    "LEFT JOIN fornecedores forn ON forn.id= m.AccountIDDebit AND m.AccountAssociationIDDebit=2 "&_
    "LEFT JOIN profissionais prof ON prof.id= m.AccountIDDebit AND m.AccountAssociationIDDebit=5 "&_
    "WHERE m.AccountAssociationIDCredit=7 AND m.AccountIDCredit=cx.id AND m.AccountAssociationIDDebit NOT IN(1,7) "&_
    "AND m.CaixaID="& session("CaixaID") &" AND NOT ISNULL(m.CaixaID) AND NOT ISNULL(m.PaymentMethodID) "&_
    "ORDER BY lu.Nome, pm.PaymentMethod"
end if
'response.write(sql)
set dist = db.execute(sql)
if not dist.eof then
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="7"><%= Titulo %></th>
        </tr>
        <tr class="<%= Classe %>">
            <th width="20%">Forma</th>
            <th width="10%">Descrição</th>
            <th width="10%">Conta</th>
            <th width="10%">Plano de contas</th>
            <th width="10%">Identificação</th>
            <th width="35%">Usuário</th>
            <th width="10">Valor</th>
        </tr>
    <tbody>
    <%
    while not dist.eof
        NomeConta=""
        Identificacao=""

        if FieldExists(dist, "NomeConta") then
            if dist("NomeConta")&""<>"" then
                NomeConta = dist("NomeConta")&""
                Identificacao = dist("Identificacao")&""
            end if
        end if

        Valor = dist("Value")
        PlanoContas = ""
        

        if NomeConta="" then
            NomeConta = accountName(dist("AccountAssociationIDDebit"), dist("AccountIDDebit"))
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
            case 4
                Boleto = Boleto+Valor
            case 15
                Pix = Pix+Valor
        end select
        set cat = db.execute("select group_concat(DISTINCT ifnull(Descricao, '') SEPARATOR ', ') Descricao, group_concat(DISTINCT ex.Name) planoContas from itensdescontados idesc LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialexpensetype ex ON ex.id=ii.CategoriaID WHERE idesc.PagamentoID="& dist("id")&" ")
        Descricao = "<code>"& dist("name") &" - " & cat("Descricao") &"</code>"
        PlanoContas = cat("planoContas")&""
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <td><%= NomeConta %></td>
            <td><%= PlanoContas %></td>
            <td><%= Identificacao %></td>
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
    <%= linhaTotais(Dinheiro, Cheque, Credito, Debito, Boleto, Pix, Titulo, Classe) %>
<%
end if










Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "TRANSFERÊNCIAS DE SAÍDA"
Classe = "warning"
if MC="" then
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=1 AND m.AccountAssociationIDCredit=7 AND m.Date="& mData &" AND cc.Empresa="& UnidadeID &" AND NOT m.Name LIKE 'Fechamento Cx - %' ORDER BY lu.Nome, pm.PaymentMethod")
else
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=1 AND m.AccountAssociationIDCredit=7 AND m.CaixaID="& session("CaixaID") &" ORDER BY lu.Nome, pm.PaymentMethod")
end if
if not dist.eof then
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
            case 4
                Boleto = Boleto+Valor
            case 15
                Pix = Pix+Valor
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
    <% call linhaTotais(Dinheiro, Cheque, Credito, Debito, Boleto, Pix, Titulo, Classe)
end if 


Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "TRANSFERÊNCIAS DE ENTRADAS"
Classe = "warning"
if MC="" then
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=7 AND m.AccountAssociationIDCredit=1 AND m.Date="& mData &" AND cc.Empresa="& UnidadeID &" ORDER BY lu.Nome, pm.PaymentMethod")
else
    set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
        " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
        " WHERE m.AccountAssociationIDDebit=7 AND m.AccountAssociationIDCredit=1 AND m.CaixaID="& session("CaixaID") &" ORDER BY lu.Nome, pm.PaymentMethod")
end if

if not dist.eof then
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
            case 4
                Boleto = Boleto+Valor
            case 15
                Pix = Pix+Valor
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
    <% call linhaTotais(Dinheiro, Cheque, Credito, Debito, Boleto, Pix, Titulo, Classe)
end if 

    
if MC="1" then %>

    <h5>FECHAMENTO DE CAIXA</h5>
    <%= linhaTotais(Balanco, Cheque, Credito, Debito, Boleto, Pix, "FECHAMENTO DE CAIXA", "alert") %>



<hr />

<% if req("CX")="" then %>

<form id="frmCx" method="post">
    <input type="hidden" name="Dinheiro" value="<%= Balanco %>" />
    <input type="hidden" name="Cheque" value="<%= Cheque %>" />
    <input type="hidden" name="Credito" value="<%= Credito %>" />
    <input type="hidden" name="Debito" value="<%= Debito %>" />
    <div class="alert alert-alert row" id="divDinheiroInformado">
        <%= quickfield("currency", "DinheiroInformado", "Quantia em dinheiro", 2, "0,00", "", "", "  ") %>
        <div class="col-md-2">
            <button class="btn btn-success mt25">FECHAR CAIXA</button>
        </div>
    </div>
</form>

<% end if %>

</div></div>

<script type="text/javascript">
    $(".crumb-active a").html("Fechamento de Caixa");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "far fa-inbox");

    $("#frmCx").submit(function(){
        $.post("fechaCaixa.asp", $(this).serialize(), function(data){ eval(data) });
        return false;
    });

</script>

<% else 










    Dinheiro = 0
    Cheque = 0
    Credito = 0
    Debito = 0
    Titulo = "FECHAMENTO DE CAIXA"
    Classe = "alert"
    if MC="" then
        sqlDist = "select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
                              " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
                              " WHERE m.AccountAssociationIDDebit=1 AND m.AccountAssociationIDCredit=7 AND m.Date="& mData &" AND cc.Empresa="& UnidadeID &" AND m.Name LIKE 'Fechamento Cx - %' ORDER BY lu.Nome, pm.PaymentMethod"

        set dist = db.execute(sqlDist)
    else
        sqlDist="select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
                            " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
                            " WHERE m.AccountAssociationIDDebit=1 AND m.AccountAssociationIDCredit=7 AND m.CaixaID="& session("CaixaID") &" ORDER BY lu.Nome, pm.PaymentMethod"
        set dist = db.execute(sqlDist)
    end if
    if not dist.eof then
    %>

    <table class="table table-striped table-hover table-bordered table-condensed">
        <thead>
            <tr class="<%= Classe %>">
                <th colspan="6"><%= Titulo %></th>
            </tr>
            <tr class="<%= Classe %>">
                <th width="20%">Forma</th>
                <th width="35%">Descrição</th>
                <th width="35%">Usuário</th>
                <th width="10">Valor Calculado</th>
                <th width="10">Valor Informado</th>
                <th width="10">Diferença</th>
            </tr>
        <tbody>
        <%
        tCalculado = 0
        tInformado = 0
        ValorInformado = 0
        tDiferenca = 0
        while not dist.eof
            Descricao = accountName(dist("AccountAssociationIDDebit"), dist("AccountIDDebit"))
            Valor = dist("Value")
            ValorInformado = 0
            select case dist("PaymentMethodID")
                case 1
                    Dinheiro = Dinheiro+Valor
                    set fc = db.execute("select DinheiroInformado from fechamentocaixa where CaixaID="& dist("CaixaID"))
                    if not fc.eof then
                        ValorInformado = fc("DinheiroInformado")
                    else
                        ValorInformado = ""
                    end if
                case 2
                    Cheque = Cheque+Valor
                case 8
                    Credito = Credito+Valor
                case 9
                    Debito = Debito+Valor
            end select
            tCalculado = tCalculado + Valor
            if isnull(ValorInformado) or ValorInformado="" then
                ValorInformado = 0
            end if
            tInformado = tInformado + ValorInformado
            Diferenca = Valor - ValorInformado
            tDiferenca = tDiferenca + Diferenca
            %>
            <tr>
                <td><%= dist("PaymentMethod") %></td>
                <td><%= Descricao %></td>
                <td><a href="./?P=PreFechaCaixa&Pers=1&CX=<%= dist("CaixaID") %>&DetalharEntradas=<%= DetalharEntradas %>" target="_blank"><%= dist("Nome") %></a></td>
                <td class="text-right">R$ <%= fn(Valor) %></td>
                <td class="text-right">
                    <% if ValorInformado<>"" then %>
                    R$ <%= fn(ValorInformado) %>
                    <% else %>
                    -
                    <% end if %>

                </td>
                <td class="text-right"><%= fn(Diferenca) %></td>
            </tr>
            <%
        dist.movenext
        wend
        dist.close
        set dist = nothing

        Balanco = Balanco+Valor
        %>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="3"></td>
                <th class="text-right" nowrap>R$ <%= fn(tCalculado) %></th>
                <th class="text-right" nowrap>R$ <%= fn(tInformado) %></th>
                <th class="text-right" nowrap>R$ <%= fn(tDiferenca) %></th>
            </tr>
        </tfoot>
    </table>
        <% call linhaTotais(tInformado, Cheque, Credito, Debito, Boleto, Pix, Titulo, Classe)
    end if 


end if %>
<%'= session("User") %>