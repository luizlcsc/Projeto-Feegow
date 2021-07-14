<!--#include file="connect.asp"-->
<%
ContratoID = req("I")
InvoiceID = req("InvoiceID")
ModeloID = req("ModeloID")
Associacao = req("Associacao")
ContaID = split(req("ContaID"), "_")
if ContratoID="" then
    db_execute("insert into contratos (InvoiceID, Associacao, ContaID, Contrato, sysUser, ModeloID) values ("& InvoiceID &", "&ContaID(0)&", "&ContaID(1)&", '"&refhtml("Contrato")&"', "&session("User")&", "&treatvalzero(ModeloID)&")")
    set pult = db.execute("select id from contratos order by id desc limit 1")
    ContratoID = pult("id")
else
    db_execute("update contratos set Contrato='"&ref("Contrato")&"' where id="&ContratoID)
end if
%>
$("#modal").html('<iframe src="printContrato.asp?I=<%=ContratoID %>" width="100%" height="600"></iframe>');