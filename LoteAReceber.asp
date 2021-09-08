<!--#include file="connect.asp"-->
<%
Lotes = req("Lotes")
ConvenioID = req("ConvenioID")
TG = lcase(req("T"))
CriaInvoice = req("CriaInvoice")
valorGuias =  req("V")

if TG="guiaconsulta" then
    coluna = "ValorProcedimento"
elseif TG="guiasadt" then
    coluna = "TotalGeral"
elseif TG="guiahonorarios" then
    coluna = "Procedimentos"
end if

sql = "select l.*, (select UnidadeID from tiss"&TG&" where id IN("&ref("Guia")&") LIMIT 1) UnidadeID, group_concat(Lote) LotesDescricoes from tisslotes l where id IN ("&Lotes&")"
'response.write( sql )
set plote = db.execute( sql )

if not plote.eof then
    if req("Incrementar")="" then
        db_execute("insert into sys_financialinvoices (AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser,sysDate, FormaID, ContaRectoID) values ("&req("ConvenioID")&", 6, "&treatvalzero(req("V"))&", 1, 'BRL', "&treatvalzero(plote("UnidadeID"))&", 1, 'm', 'C', 1, "&session("User")&",CURDATE(), 0, 0)")
        set pultInv = db.execute("select id from sys_financialinvoices where sysUser="&session("User")&" order by id desc limit 1")
        InvoiceID = pultInv("id")
        db_execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, UnidadeID) values (0, 0, 6, "&req("ConvenioID")&", "&treatvalzero(req("V"))&", CURDATE(), 'C', 'Bill', 'BRL', 1, "&InvoiceID&", 1, "&session("User")&", "&treatvalzero(plote("UnidadeID"))&")")
    else
        InvoiceID=req("Incrementar")
        set HaPagamentosSQL = db.execute("SELECT SUM(credito.Value)ValorPago "&_
                                          "FROM sys_financialmovement debito "&_
                                          "LEFT JOIN sys_financialdiscountpayments pagamento ON pagamento.InstallmentID=debito.id "&_
                                          "LEFT JOIN sys_financialmovement credito ON credito.id=pagamento.MovementID "&_
                                          "WHERE debito.InvoiceID="&InvoiceID)
        if HaPagamentosSQL("ValorPago")>0 then
            %>
            new PNotify({
                title: 'N&Atilde;O LAN&Ccedil;ADO!',
                text: 'Já há pagamentos lançados para esta conta.',
                type: 'danger',
                delay: 4000
            });
            <%
            Response.End
        end if
        set InvoiceSQL = db.execute("SELECT Value FROM sys_financialinvoices WHERE id="&InvoiceID)
        Valor = req("V")
        ValorConta = InvoiceSQL("Value")

        ValorAtualizado = ccur(ValorConta) + ccur(Valor)

        db_execute("update sys_financialmovement SET Value="&treatvalzero(ValorAtualizado)&" WHERE Type='Bill' AND InvoiceID="&InvoiceID)
        db_execute("update sys_financialinvoices SET Value="&treatvalzero(ValorAtualizado)&" WHERE id="&InvoiceID)
    end if
    'valida se ja ha esse registro na tissguiainvoice
    Guias = ref("Guia")

    set ValidacaoGuiaInvoiceSQL = db.execute("SELECT id FROM tissguiasinvoice WHERE GuiaID IN ("&Guias&") AND TipoGuia='"&TG&"'")

    if not ValidacaoGuiaInvoiceSQL.eof then
        %>
        new PNotify({
            title: 'N&Atilde;O LAN&Ccedil;ADO!',
            text: 'Guia já lançada para recebimemto.',
            type: 'danger',
            delay: 4000
        });
        <%
        Response.End
    end if

    db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, Executado, sysUser, ProfissionalID, Associacao, CentroCustoID) values ("& InvoiceID &", 'O', 1, 0, 0, "&treatvalzero(req("V"))&", 0, 'Lote(s): "&plote("LotesDescricoes")&"', '', "&session("User")&", 0, 0, 0)")
    
    'db_execute("update tisslotes set InvoiceID="&InvoiceID&" where id="&LoteID)
    spl = split(Guias, ",")
    set pultInvItem = db.execute("select id from itensinvoice where InvoiceID="&InvoiceID&" order by id desc limit 1")
    ItemInvoiceID = pultInvItem("id")
    for i=0 to ubound(spl)
        db_execute("insert into tissguiasinvoice (ItemInvoiceID, InvoiceID, GuiaID, TipoGuia) values ("& ItemInvoiceID &", "& InvoiceID &", "& spl(i) &", '"&TG&"')")
    next

    if CriaInvoice = 1 then
        call lancarImposto(InvoiceID,valorGuias,ConvenioID)
    end if 
    
    %>
    location.href='./?P=Invoice&Pers=1&T=C&I=<%=InvoiceID %>';
    <%
else
    %>
    new PNotify({
        title: 'N&Atilde;O LAN&Ccedil;ADO!',
        text: 'Houve um erro ao lançar conta.',
        type: 'danger',
        delay: 4000
    });
    <%
end if
%>