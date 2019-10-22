<!--#include file="connect.asp"-->
<%
ParcelasID = ref("ParcelasID")
APartirDe = ccur(req("ParcelaID"))
spl = split(ParcelasID, ", ")

DataMatriz = ref("Date"&APartirDe)
Intervalo = ref("Recurrence")
TipoIntervalo = ref("RecurrenceType")

for i=0 to ubound(spl)
    EstaParcela = ccur(spl(i))
    if (EstaParcela>APartirDe and EstaParcela>0) or (EstaParcela<APartirDe and EstaParcela<0) then
        DataMatriz = dateAdd(TipoIntervalo, Intervalo, DataMatriz)
        %>
        $("#Date<%=EstaParcela %>").val("<%=DataMatriz %>");
        <%
    end if
next
%>