<!--#include file="connect.asp"-->

<%
guiaInvoiceID = ref("guiaInvoiceID")
itemID = ref("itemID")
InvoiceID = ref("InvoiceID")

set Lote = db.execute("SELECT LoteID FROM tissguiasinvoice TI INNER JOIN tissguiasadt TG ON TI.GuiaID = TG.id WHERE TI.id = '"&guiaInvoiceID&"'") 
loteId = Lote("LoteID")

'remove a guia de dentro da invoice
db.execute("DELETE FROM tissguiasinvoice WHERE id='"&guiaInvoiceID&"'")

set Guias = db.execute("SELECT GuiaID, ItemInvoiceID FROM tissguiasinvoice WHERE invoiceid='"&InvoiceID&"'")

valorFinal = 0
while not Guias.eof
    set TotalGuias = db.execute("SELECT TotalGeral FROM tissguiasadt WHERE id='"&Guias("GuiaID")&"'")
        valorFinal = valorFinal + TotalGuias("TotalGeral")
Guias.movenext
wend
Guias.close

'atualiza valor do item de onde foi retirada a invoice
atualizaItemInv = db.execute("UPDATE itensinvoice set ValorUnitario= "&treatValZero(valorFinal)&" WHERE id= "&itemID)

'calcula o valor total da invoice
set TotalGeral = db.execute("Select SUM(ValorUnitario) As Total from itensinvoice where InvoiceID= "&InvoiceID)
totalGeral = treatVal(TotalGeral("Total"))

'atualiza a mov e a inv
atualizaMov = db.execute("UPDATE sys_financialmovement set Value="&totalGeral&" WHERE type='Bill' AND InvoiceID="&InvoiceID)

atualizaInv = db.execute("UPDATE sys_financialinvoices set Value="&totalGeral&" WHERE id="&InvoiceID)

response.write(totalGeral)

%>