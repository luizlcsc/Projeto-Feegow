<!--#include file="connect.asp"-->
<%
PacienteID = Request.QueryString("PacienteID")
ProfissionalID = Request.QueryString("ProfissionalID")
TipoCompromissoID = Request.QueryString("TipoCompromissoID")
'contaCorrente = Request.QueryString("contaCorrente")
'unidade = Request.QueryString("unidade")

'sysFormasrectoId = Request.QueryString("sysFormasrectoId")

db.execute("SET SESSION group_concat_max_len = 1000000; ")

set vcaIIPaga = db.execute("select i.FormaID, ii.InvoiceID as InvoiceID, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorItem, ifnull((select sum(Valor) from itensdescontados where ItemID=ii.id), 0) TotalQuitado from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
        " WHERE i.AccountID="& PacienteID &" and AssociationAccountID=3 "&_
        " AND ii.ItemID="& TipoCompromissoID &" ")

Response.ContentType = "application/json" 

 if not vcaIIPaga.eof then
    FormaID = vcaIIPaga("FormaID")
    InvoiceID = vcaIIPaga("InvoiceID")    
    response.write("{""formaid"":"&FormaID&", ""InvoiceID"": "&InvoiceID&"}")
    response.end
 else 
    response.write("{formaid:0, InvoiceID: 0}")
    response.end
 end if
%>