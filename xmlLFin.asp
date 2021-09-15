<!--#include file="connect.asp"-->
<%
spl = split(ref("lancar"), ", ")
for i=0 to ubound(spl)
    spl2 = split(spl(i), "|")
    TG = spl2(0)
    Tabela = "tiss"& TG
    id = spl2(1)
    ValorLiberado = ccur(spl2(2))

    TotalLiberado = TotalLiberado + ValorLiberado

    if req("gInvoice")="1" then
        if ConvenioID="" then
            set pconv = db.execute("select ConvenioID, UnidadeID from "& Tabela &" where id="& id)
            ConvenioID = pconv("ConvenioID")
            db_execute("insert into sys_financialinvoices (AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser, FormaID, ContaRectoID, nroNFe, dataNFe, valorNFe) values ("& ConvenioID &", 6, "&treatvalzero(ref("TotalInvoice"))&", 1, 'BRL', "& treatvalzero(pconv("UnidadeID")) &", 1, 'm', 'C', 1, "&session("User")&", 0, 0, "& treatvalnull(ref("NumeroNF")) &", "& mydatenull(ref("DataNF")) &", "& treatvalnull(ref("ValorNF")) &")")
            set pultInv = db.execute("select id from sys_financialinvoices where sysUser="&session("User")&" order by id desc limit 1")
            InvoiceID = pultInv("id")
            db_execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, UnidadeID) values (0, 0, 6, "& ConvenioID &", "&treatvalzero(ref("TotalInvoice"))&", CURDATE(), 'C', 'Bill', 'BRL', 1, "& InvoiceID &", 1, "&session("User")&", "&treatvalzero(pconv("UnidadeID"))&")")
            db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, Executado, sysUser, ProfissionalID, Associacao, CentroCustoID) values ("& InvoiceID &", 'O', 1, 0, 0, "&treatvalzero(ref("TotalInvoice"))&", 0, 'Guias de Convênio', '', "&session("User")&", 0, 0, 0)")
            set pultInvItem = db.execute("select id from itensinvoice where InvoiceID="&InvoiceID&" order by id desc limit 1")
            ItemInvoiceID = pultInvItem("id")
        end if
        db_execute("insert into tissguiasinvoice (ItemInvoiceID, InvoiceID, GuiaID, TipoGuia) values ("& ItemInvoiceID &", "& InvoiceID &", "& id &", '"&TG&"')")
    end if
    
next

%>



<div class="panel mbn">
    <div class="panel-body">
        <% if req("gInvoice")="" then %>
            <%= quickfield("text", "NumeroNF", "N&uacute;mero da NF", 4, "", "", "", "") %>
            <%= quickfield("datepicker", "DataNF", "Data da NF", 4, "", "", "", "") %>
            <%= quickfield("currency", "ValorNF", "Valor da NF", 4, "", "", "", "") %>
        <% else %>
            <span class="panel-title text-center">Lançado com sucesso no contas a receber!</span>
        <% end if %>
    </div>
    <div class="panel-heading">
        <% if req("gInvoice")="" then %>
            <span class="panel-title">Lançar no contas a receber - R$ <%= fn(TotalLiberado) %></span>
            <span class="panel-controls">
                <button class="btn btn-sm btn-system" id="gInvoice">LANÇAR</button>
            </span>
        <% else %>
            <span class="panel-title">
                <a href="./?P=Invoice&Pers=1&CD=C&I=<%= InvoiceID %>" class="btn btn-sm btn-success"><i class="far fa-money"></i>VER CONTA</a>
            </span>
        <% end if %>
    </div>
</div>
<input type="hidden" id="TotalInvoice" name="TotalInvoice" value="<%= TotalLiberado %>" />

<script type="text/javascript">

    $("#gInvoice").click(function () {
        $.post("xmlLFin.asp?gInvoice=1", $("input[name=lancar], #NumeroNF, #DataNF, #ValorNF, #TotalInvoice").serialize(), function (data) {
            $("#divLancar").html(data);
        });
    });

    <!--#include file="JQueryFunctions.asp"-->
</script>