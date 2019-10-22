<%
db_execute("delete from tempparcelas where sysUser="&session("User"))

set parcelasGravadas = db.execute("select * from sys_financialmovement where InvoiceID="&id)
while not parcelasGravadas.eof
	db_execute("insert into tempparcelas (id, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, ValorPago, CaixaID) values ("&parcelasGravadas("id")&", "&parcelasGravadas("AccountAssociationIDCredit")&", "&parcelasGravadas("AccountIDCredit")&", "&parcelasGravadas("AccountAssociationIDDebit")&", "&parcelasGravadas("AccountIDDebit")&", "&treatvalzero(parcelasGravadas("Value"))&", "&mydatenull(parcelasGravadas("Date"))&", '"&parcelasGravadas("CD")&"', '"&parcelasGravadas("Type")&"', '"&parcelasGravadas("Currency")&"', "&treatvalzero(parcelasGravadas("Rate"))&", "&parcelasGravadas("InvoiceID")&", "&parcelasGravadas("InstallmentNumber")&", "&session("User")&", "&treatvalnull(parcelasGravadas("ValorPago"))&", "&treatvalnull(parcelasGravadas("CaixaID"))&")")
parcelasGravadas.movenext
wend
parcelasGravadas.close
set parcelasGravadas = nothing

%>