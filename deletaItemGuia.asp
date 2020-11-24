<!--#include file="connect.asp"-->

<%
itemGuiaId = ref("itemGuiaId")

set Lote = db.execute("SELECT LoteID FROM tissguiasinvoice TI INNER JOIN tissguiasadt TG ON TI.GuiaID = TG.id WHERE TI.id = '"&itemGuiaId&"'") 
loteId = Lote("LoteID")

db.execute("DELETE FROM tissguiasinvoice WHERE id='"&itemGuiaId&"'")   

set TotalGeral = db.execute("SELECT SUM(TotalGeral) AS Total FROM tissguiasadt WHERE LoteID = '"&loteId&"'") 
totalGeral = TotalGeral("Total")

set TotalPago = db.execute("SELECT SUM(ValorPago) AS TotalPago FROM tissguiasadt TG INNER JOIN tissguiasinvoice TI ON TG.id = TI.GuiaID WHERE LoteID = '"&loteId&"'")
totalPago = TotalPago("TotalPago")

total = formatnumber(totalGeral - totalPago, 2)

'set Total = db.execute("SELECT SUM(TotalGeral) - SUM(ValorPago) AS Total  FROM tissguiasadt WHERE LoteID = '"&loteId&"'") 
'totalGeral = Total("Total")
totalGeral = formatnumber(totalGeral,2)

response.write(total)

%>