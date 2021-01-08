<!--#include file="connect.asp"-->
<%
    I = req("I")
    sql = "select * from invoicesfixas where coalesce(TipoContaFixaID <> 2,true) and id="&I
    set fx = db.execute(sql)
    if not fx.eof then
        Conta = req("N")
        Vencto = req("D")
        'cria->
        db_execute("insert into sys_financialinvoices (Name, AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser, sysDate, FixaID, FixaNumero) values ('"&rep(fx("Name"))&"', "&fx("AccountID")&", "&fx("AssociationAccountID")&", "&treatvalzero(fx("Value"))&", 1, 'BRL', "&treatvalzero(fx("CompanyUnitID"))&", "&fx("Intervalo")&", '"&fx("TipoIntervalo")&"', '"&fx("CD")&"', 1, "&treatvalzero(fx("sysUser"))&", "&mydatenull(Vencto)&", "&fx("id")&", "&Conta&")")
        set pult = db.execute("select id from sys_financialinvoices where FixaID="&fx("id")&" order by id desc LIMIT 1")
        if fx("CD")="C" then
            AccountAssociationIDDebit = fx("AssociationAccountID")
            AccountIDDebit = fx("AccountID")
            AccountAssociationIDCredit = 0
            AccountIDCredit = 0
        else
            AccountAssociationIDDebit = 0
            AccountIDDebit = 0
            AccountAssociationIDCredit = fx("AssociationAccountID")
            AccountIDCredit = fx("AccountID")
        end if
        db_execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, ValorPago, UnidadeID) values ("&AccountAssociationIDCredit&", "&AccountIDCredit&", "&AccountAssociationIDDebit&", "&AccountIDDebit&", "&treatvalzero(fx("Value"))&", "&mydatenull(Vencto)&", '"&fx("CD")&"', 'Bill', 'BRL', 1, "&pult("id")&", 1, "&fx("sysUser")&", 0, "&fx("CompanyUnitID")&")")
        db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Descricao, Executado, sysUser,CentroCustoID,Desconto,Acrescimo)  (select '"&pult("id")&"', Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Descricao, Executado, sysUser,CentroCustoID,Desconto,Acrescimo from itensinvoicefixa where InvoiceID="&fx("id")&")")
                
        db_execute("update invoicesfixas set Geradas = concat(ifnull(Geradas, ''), '|"&Conta&"|') where id="&fx("id"))
        '<- cria
    end if
%>
location.href='./?P=invoice&I=<%=pult("id") %>&A=&Pers=1&T=<%=fx("CD") %>';