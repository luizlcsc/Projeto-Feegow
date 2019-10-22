<!--#include file="connect.asp"-->
<%

ids = split(ref("cheques"), ", ")

for ii=0 to ubound(ids)
    I = ids(ii)
    ContaCorrente = ref("ContaCorrente")
    splCC = split(ContaCorrente, "_")
    AssociationAccountID = splCC(0)
    AccountID = splCC(1)
    set cheque = db.execute("select * from sys_financialReceivedChecks where id="&I)

    if cheque("AccountAssociationID")=7 then
        CaixaID = cheque("AccountID")
    end if

    if ccur(AssociationAccountID)=7 then
        CaixaID = AccountID
    end if

    if ContaCorrente<>cheque("AccountAssociationID")&"_"&cheque("AccountID") then
        db_execute("insert into sys_financialmovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Rate, CaixaID, ChequeID, sysUser) values ('Cheque transferido', "&cheque("AccountAssociationID")&", "&cheque("AccountID")&", "&AssociationAccountID&", "&AccountID&", 2, "&treatvalzero(cheque("Valor"))&", "&mydatenull(ref("DataMovimentacao"))&", '', 'Transfer', 1, "&treatvalnull(CaixaID)&", "&cheque("id")&", "&session("User")&")")
    end if

    db_execute("update sys_financialReceivedChecks set  AccountAssociationID="&AssociationAccountID&", AccountID="&AccountID&", StatusID='"&ref("StatusID")&"' , Account='"&ref("Account")&"' where id="&I)
next
%>
$("#modal-table").modal("hide");
location.reload();