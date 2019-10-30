<!--#include file="connect.asp"-->
<%
I = req("I")
ContaCorrente = ref("ContaCorrente")
if ref("ContaCorrente") <> "" then
    
    splCC = split(ContaCorrente, "_")
    AssociationAccountID = splCC(0)
    AccountID = splCC(1)
else 
    ContaCorrente = ""
    AssociationAccountID = "null"
    AccountID = "null"
end if 

set cheque = db.execute("select * from sys_financialReceivedChecks where id="&I)

if cheque("AccountAssociationID")=7 then
	CaixaID = cheque("AccountID")
end if

if AssociationAccountID <> "null" then
    if ccur(AssociationAccountID)=7 then
        CaixaID = AccountID
    end if
end if 

if ContaCorrente<>cheque("AccountAssociationID")&"_"&cheque("AccountID") then
    sqlInsert = "INSERT into sys_financialmovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, " &_ 
                "AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Rate, CaixaID, ChequeID, sysUser) " &_ 
                " VALUES ('Cheque transferido', "&treatvalnull(cheque("AccountAssociationID"))&", "&treatvalnull(cheque("AccountID"))&", " &_ 
                " "&AssociationAccountID&", "&AccountID&", 2, "&treatvalzero(cheque("Valor"))&", "&mydatenull(ref("DataMovimentacao"))&", ''," &_ 
                " 'Transfer', 1, "&treatvalnull(CaixaID)&", "&cheque("id")&", "&session("User")&")"
	db_execute(sqlInsert)
end if
if ref("StatusID")= 4 then
    datacompensacao  =  "'" & year(ref("DataCompensacao")) & "-" &month(ref("DataCompensacao")) & "-" & day(ref("DataCompensacao")) & "'"
else 
    datacompensacao  =  "null"
end if 
sqlupdate  = " UPDATE sys_financialReceivedChecks SET BankID='"&ref("BankID")&"', " &_
       " CheckNumber='" &ref("CheckNumber")&"', Holder='"&ref("Holder")&"', " &_ 
       " Document='"&ref("Document")&"', CheckDate='"&myDate(ref("CheckDate"))&"', " &_ 
       " AccountAssociationID="&AssociationAccountID&", AccountID="&AccountID&", " &_ 
       " BorderoID="&treatvalnull(ref("BorderoID"))&", StatusID='"&ref("StatusID")&"' , " &_ 
       " Branch='"&ref("Branch")&"' , Account='"&ref("Account")&"', DataCompensacao= "& datacompensacao &"  where id="&I
db_execute(sqlupdate)

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