<!--#include file="connect.asp"-->

<style type="text/css">
    @media print {
        td, th {
            font-size:10px;
        }
    }
</style>

<%

if req("CX")<>"" then
    CaixaID = req("CX")
else
    CaixaID = session("CaixaID")
end if

if CaixaID <> "" then

'Validar se é para oculpar os totais
OcultarTotaisFecharCaixa = "N"
if getConfig("OcultarTotaisFecharCaixa") = "1" then
    OcultarTotaisFecharCaixa = 1
end if
DetalharEntradas=req("DetalharEntradas")

function linhaTotais(Dinheiro, Cheque, Credito, Debito, Pix, Titulo, Classe)
    %>
    <table class="table table-condensed mt20">
        <thead>
            <tr class="<%= Classe %>">
                <th class="text-center" width="20%">Total Dinheiro</th>
                <th class="text-center" width="20%">Total Cheque</th>
                <th class="text-center" width="20%">Total Crédito</th>
                <th class="text-center" width="20%">Total Débito</th>
                <th class="text-center" width="20%">Total Pix</th>
                <th class="text-center" width="20%">Total <%= Titulo %></th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <th class="text-right" width="20%">R$ <%= fn(Dinheiro) %></th>
                <th class="text-right" width="20%">R$ <%= fn(Cheque) %></th>
                <th class="text-right" width="20%">R$ <%= fn(Credito) %></th>
                <th class="text-right" width="20%">R$ <%= fn(Debito) %></th>
                <th class="text-right" width="20%">R$ <%= fn(Pix) %></th>
                <th class="text-right" width="20%">R$ <%= fn(Dinheiro + Cheque + Credito + Debito + Pix) %></th>
            </tr>
        </tbody>
    </table>
<hr class="short alt" />
    <%
end function
%>
<br>
<div class="panel"><div class="panel-body">

<div class="row">
    <div class="col-md-3">
<%
if req("DetalharEntradas")<>"S" then
%>
        <a class="hidden-print btn btn-default btn-sm" href="?P=PreFechaCaixa&Pers=1&DetalharEntradas=S">
            <i class="far fa-info-circle"></i> Detalhar entradas
        </a>
<%
end if
%>
        <a class="hidden-print btn btn-info btn-sm" href="javascript:print()">
            <i class="far fa-print"></i> Imprimir
        </a>
    </div>
</div>

<br><br>
<%
if DetalharEntradas="S" then

sqlBoletos = " SELECT be.DataHora, be.DueDate, be.AmountCents, pac.NomePaciente, (be.AmountCents /100)Valor FROM boletos_emitidos be"&chr(13)&_
                                                 "                                                                                                         "&chr(13)&_
                                                 " INNER JOIN sys_financialinvoices i ON i.id=be.InvoiceID                                                 "&chr(13)&_
                                                 " LEFT JOIN pacientes pac ON pac.id=i.AccountID AND i.AssociationAccountID=3                              "&chr(13)&_
                                                 "                                                                                                         "&chr(13)&_
                                                 " WHERE i.CaixaID="&CaixaID
set BoletosEmitidosSQL = db.execute(sqlBoletos)

if not BoletosEmitidosSQL.eof then
    %>
<h5>BOLETOS GERADOS</h5>
<table class="table">
    <tr class="success">
        <th>Paciente</th>
        <th>Data e hora</th>
        <th>Vencimento</th>
        <th>Valor</th>
    </tr>
<%
while not BoletosEmitidosSQL.eof
%>
    <tr>
        <td><%=BoletosEmitidosSQL("NomePaciente")%></td>
        <td><%=BoletosEmitidosSQL("DataHora")%></td>
        <td><%=BoletosEmitidosSQL("DueDate")%></td>
        <th><%=BoletosEmitidosSQL("Valor")%></th>
    </tr>
<%
BoletosEmitidosSQL.movenext
wend
BoletosEmitidosSQL.close
set BoletosEmitidosSQL=nothing
%>
</table>
<br><br>
    <%
    end if
end if

Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Pix = 0

Titulo = "ENTRADAS"
Classe = "success"
if req("DetalharEntradas")="" then
    set dist = db.execute("select ''Descricao, concat( ifnull(count(m.id), 0), ' lançamento(s)' ) Descricao, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID FROM sys_financialmovement m LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser WHERE m.CaixaID='"& CaixaID &"' AND ((AccountAssociationIDDebit=7 AND AccountIDDebit=cx.id AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9))) GROUP BY pm.PaymentMethod, lu.Nome ORDER BY lu.Nome, pm.PaymentMethod")
else
    set dist = db.execute(" SELECT m.Date, band.Bandeira, card.Parcelas, ''Descricao, c.CheckDate, m.id, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit         "&chr(13)&_
                          " FROM sys_financialmovement m                                                                                                                                         "&chr(13)&_
                          " LEFT JOIN sys_financialdiscountpayments disc ON disc.MovementID=m.id                                                                                                 "&chr(13)&_
                          " LEFT JOIN sys_financialmovement mov ON mov.id=disc.InstallmentID                                                                                                     "&chr(13)&_
                          " LEFT JOIN caixa cx ON cx.id=m.CaixaID                                                                                                                                "&chr(13)&_
                          " LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID                                                                                                   "&chr(13)&_
                          " LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser                                                                                                      "&chr(13)&_
                          " LEFT JOIN sys_financialreceivedchecks c ON c.MovementID=m.id                                                                                                 "&chr(13)&_
                          " LEFT JOIN sys_financialcreditcardtransaction card ON card.MovementID=m.id                                                                                                 "&chr(13)&_
                          " LEFT JOIN cliniccentral.bandeiras_cartao band ON band.id=card.BandeiraCartaoID                                                                                                 "&chr(13)&_
                          " WHERE m.CaixaID='"& CaixaID &"' AND ((m.AccountAssociationIDDebit=7 AND m.AccountIDDebit=cx.id AND m.AccountAssociationIDCredit NOT IN(1, 7)) OR (m.PaymentMethodID IN(8,9)))"&chr(13)&_
                          " ORDER BY lu.Nome, pm.PaymentMethod                                                                                                                                   ")
end if

if not dist.eof then
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="<% if DetalharEntradas="S" then response.write(9) else response.write(6) end if%>"><%= Titulo %></th>
        </tr>
        <tr class="<%= Classe %>">
            <th width="20%">Forma</th>
            <th width="35%">Descrição</th>
            <%
            if DetalharEntradas="S" then
                %>
                <th>Procedimento</th>
                <th>Data</th>
                <th>Bandeira</th>
                <th>Parcelas</th>
                <%
            end if
            %>
            <th width="35%">Usuário</th>
            <th width="10">Valor</th>
        </tr>
    <tbody>
    <%
    Valor = 0
    while not dist.eof
        Parcela=""
        if req("DetalharEntradas")="S" then
            Valor = dist("Value")
            set desc = db.execute("select group_concat(ifnull(proc.NomeProcedimento, '')) NomeProcedimento from itensdescontados idesc LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID where PagamentoID="& dist("id"))
            if not desc.eof then
                Procedimentos = desc("NomeProcedimento")
            end if
            DataCompens = dist("CheckDate")
            if isnull(DataCompens) then
                DataCompens = dist("Date")
            end if
            if not isnull(dist("Parcelas")) then
                Parcela = dist("Parcelas")&"x"
            end if

            Bandeira = dist("Bandeira")
            Descricao = accountName(dist("AccountAssociationIDCredit"), dist("AccountIDCredit"))
        else
            'response.write("select sum(Value) Total from sys_financialmovement where CaixaID="& CaixaID &" AND PaymentMethodID='"& dist("PaymentMethodID") &"' AND ((AccountAssociationIDDebit=7 AND AccountIDDebit="& CaixaID &" AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9)))")
            set soma = db.execute("select sum(Value) Total from sys_financialmovement where CaixaID="& CaixaID &" AND PaymentMethodID='"& dist("PaymentMethodID") &"' AND ((AccountAssociationIDDebit=7 AND AccountIDDebit="& CaixaID &" AND AccountAssociationIDCredit NOT IN(1, 7)) OR (PaymentMethodID IN(8,9)))")
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
            case 15
                Pix = Pix+Valor
        end select
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <%
            if DetalharEntradas="S" then
                %>
                <td><%=Procedimentos%></td>
                <td><code><%=DataCompens%></code></td>
                <td><%=Bandeira%></td>
                <td><%=Parcela%></td>
                <%
            end if
            %>
            <td><%= dist("Nome") %></td>
            <td class="text-right"><% if OcultarTotaisFecharCaixa<>"S" then  %>R$ <%= fn(Valor) %> <% end if %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing

    Balanco = Dinheiro
    '        response.write("{{"& Balanco &"}}")
    %>
    </tbody>
</table>
    <%     if OcultarTotaisFecharCaixa<>"S" then
        call linhaTotais(Dinheiro, Cheque, Credito, Debito, Pix, Titulo, Classe)
        end if
end if







Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "TRANSFERÊNCIAS RECEBIDAS"
Classe = "success"
Valor = 0
set dist = db.execute("select m.id, pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, m.Value, m.AccountAssociationIDCredit, m.AccountIDCredit FROM sys_financialmovement m "&_
    " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=m.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
    " WHERE m.AccountAssociationIDDebit=7 AND m.AccountIDDebit="& treatvalzero(CaixaID) &" AND m.AccountAssociationIDCredit IN(1, 7) ORDER BY lu.Nome, pm.PaymentMethod")
if not dist.eof then
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="4"><%= Titulo %></th>
        </tr>
        <tr class="<%= Classe %>">
            <th width="5%">#</th>
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
        end select
        %>
        <tr>
            <td><code>#<%= dist("id") %></code></td>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <td><%= dist("Nome") %></td>
            <td class="text-right"><% if OcultarTotaisFecharCaixa<>"S" then  %>R$ <%= fn(Valor) %> <% end if %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing

    '        response.write("{{"& Balanco &"+"& Dinheiro &"}}")
    Balanco = Balanco + Dinheiro
    %>
    </tbody>
</table>
    <%     if OcultarTotaisFecharCaixa<>"S" then
        call linhaTotais(Dinheiro, Cheque, Credito, Debito, Pix, Titulo, Classe)
        end if %>
<%
end if











Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "SAÍDAS"
Classe = "warning"
set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser WHERE m.AccountAssociationIDCredit=7 AND m.AccountIDCredit="& CaixaID &" AND m.AccountAssociationIDDebit NOT IN(1, 7) AND NOT ISNULL(m.PaymentMethodID) ORDER BY lu.Nome, pm.PaymentMethod")
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
        end select
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <td><%= dist("Nome") %></td>
            <td class="text-right"><% if OcultarTotaisFecharCaixa<>"S" then  %>R$ <%= fn(Valor) %> <% end if %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing

    '        response.write("{{"& Balanco &"+"& Dinheiro &"}}")
    Balanco = Balanco+Dinheiro
    %>
    </tbody>
</table>
    <%     if OcultarTotaisFecharCaixa<>"S" then
      call linhaTotais(Dinheiro, Cheque, Credito, Debito, Pix, Titulo, Classe)
            end if %>
<%
end if










Dinheiro = 0
Cheque = 0
Credito = 0
Debito = 0
Titulo = "TRANSFERÊNCIAS DE SAÍDA"
Classe = "warning"
set dist = db.execute("select pm.PaymentMethod, m.PaymentMethodID, lu.Nome, m.CaixaID, (m.Value*-1) Value, m.AccountAssociationIDDebit, m.AccountIDDebit FROM sys_financialmovement m "&_
    " LEFT JOIN caixa cx ON cx.id=m.CaixaID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_financialcurrentaccounts cc ON cc.id=cx.ContaCorrenteID "&_
    " WHERE m.AccountAssociationIDDebit IN(1, 7) AND m.AccountAssociationIDCredit=7 AND m.AccountIDCredit="& CaixaID &" AND m.Name NOT LIKE 'Fechamento Cx - %' ORDER BY lu.Nome, pm.PaymentMethod")
if not dist.eof then
%>

<table class="table table-striped table-hover table-bordered table-condensed">
    <thead>
        <tr class="<%= Classe %>">
            <th colspan="5"><%= Titulo %></th>
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
        end select
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <td><%= dist("Nome") %></td>
            <td class="text-right"><% if OcultarTotaisFecharCaixa<>"S" then  %>R$ <%= fn(Valor) %> <% end if %></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing

    '        response.write("{{"& Balanco &"+"& Valor &"}}")
    Balanco = Balanco+Dinheiro
    %>
    </tbody>
</table>
    <%      if OcultarTotaisFecharCaixa<>"S" then
        call linhaTotais(Dinheiro, Cheque, Credito, Debito, Pix, Titulo, Classe)
        end if
end if


Titulo = "TRANSFERÊNCIAS SOLICITADAS"
Classe = "warning"
set dist = db.execute("SELECT ft.*, pm.PaymentMethod FROM filatransferencia ft INNER JOIN sys_financialpaymentmethod pm ON pm.id=ft.PaymentMethodID WHERE CaixaID="&CaixaID)
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
            <th width="35%">Status</th>
            <th width="10">Valor</th>
        </tr>
    <tbody>
    <%
    while not dist.eof
        AprovadorPor=""

        StatusSolicitacao="Pendente"
        if dist("Aprovado")&""="1" then
            StatusSolicitacao="Aprovada"
        end if
        if dist("Aprovado")&""="1" then
            StatusSolicitacao="Rejeitada"
        end if

        Descricao=dist("Descricao")
        %>
        <tr>
            <td><%= dist("PaymentMethod") %></td>
            <td><%= Descricao %></td>
            <th><%= StatusSolicitacao %></th>
            <td class="text-right"><%=fn(dist("Value"))%></td>
        </tr>
        <%
    dist.movenext
    wend
    dist.close
    set dist = nothing

    %>
    </tbody>
</table>
    <%
end if


%>

<h5>FECHAMENTO DE CAIXA</h5>
<%     if OcultarTotaisFecharCaixa<>"S" then
        call    linhaTotais(Balanco, Cheque, Credito, Debito, Pix, "FECHAMENTO DE CAIXA", "alert")
        end if %>


<% if req("CX")="" then %>
<hr />
<form id="frmCx" method="post" class="hidden-print">
    <input type="hidden" name="Dinheiro" value="<%= Balanco %>" />
    <input type="hidden" name="Cheque" value="<%= Cheque %>" />
    <input type="hidden" name="Credito" value="<%= Credito %>" />
    <input type="hidden" name="Debito" value="<%= Debito %>" />
    <input type="hidden" name="Pix" value="<%= Pix %>" />

    <div class="row" id="divDinheiroInformado">
       <div class="col-md-12">
            <div class="panel">
               <div class="panel-body">
                   <%= quickfield("currency", "DinheiroInformado", "Quantia em dinheiro", 2, "0,00", "", "", "  ") %>
                   <div class="col-md-2">
                       <button class="btn btn-success mt25"><i class="far fa-check"></i> FECHAR CAIXA</button>
                   </div>
               </div>
            </div>

        </div>
    </div>
</form>
<% end if %>

</div></div>
<% end if %>

<script type="text/javascript">
    $(".crumb-active a").html("Fechamento de Caixa");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "far fa-inbox");
    $("#rbtns").html('<a onclick="print();" class="btn btn-sm btn-info pull-right"><i class="far fa-print"></i><span class="menu-text"> Imprimir</span></a>');

    $("#frmCx").submit(function(){
        $.post("fechaCaixa.asp", $(this).serialize(), function(data){ eval(data) });
        return false;
    });

</script>

