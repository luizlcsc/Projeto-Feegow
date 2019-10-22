<!--#include file="connect.asp"-->
<%
I = req("I")
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

db_execute("update sys_financialReceivedChecks set BankID='"&ref("BankID")&"', CheckNumber='"&ref("CheckNumber")&"', Holder='"&ref("Holder")&"', Document='"&ref("Document")&"', CheckDate='"&myDate(ref("CheckDate"))&"', AccountAssociationID="&AssociationAccountID&", AccountID="&AccountID&", BorderoID="&treatvalnull(ref("BorderoID"))&", StatusID='"&ref("StatusID")&"' , Branch='"&ref("Branch")&"' , Account='"&ref("Account")&"' where id="&I)

%>
<% IF ref("StatusID") = 3 THEN %>
    <% set chequeMov = db.execute("select * from sys_financialReceivedChecks where id="&I) %>

        <% IF chequeMov.EOF THEN %>
            $("#modal-table").modal("hide");
            location.reload();
            <% response.end %>
        <%  END IF%>

    let I = <%= chequeMov("MovementID")%>;
    $.post("xMov.asp", {I:I,DeletarCheck:"FALSE"}, function(data){
         //eval(data)
         $("#modal-table").modal("hide");
         location.reload();
    });
    <% response.end %>
<% END IF %>

$("#modal-table").modal("hide");
location.reload();