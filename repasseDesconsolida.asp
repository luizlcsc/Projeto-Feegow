<!--#include file="connect.asp"-->
<%
function fazDesconsolida(Tipo, I, ItemDescontadoID, GrupoConsolidacao)
    if Tipo="P" then
        'response.write("delete from rateiorateios WHERE ItemInvoiceID="& I &" AND ItemDescontadoID="& ItemDescontadoID &" AND GrupoConsolidacao="& GrupoConsolidacao)
        db_execute("delete from rateiorateios WHERE ItemInvoiceID="& I &" AND ItemDescontadoID="& ItemDescontadoID &" AND GrupoConsolidacao="& GrupoConsolidacao)
    end if
    if Tipo="C" then
        db_execute("delete from rateiorateios WHERE "& I &"="& ItemDescontadoID &" AND GrupoConsolidacao="& GrupoConsolidacao)
    end if
end function

if ref("Tipo")<>"" then
    call fazDesconsolida(ref("Tipo"), ref("I"), ref("IDescID"), ref("GConsol"))
    %>
    location.reload();
    <%
end if

if ref("desconsAll")<>"" then
    spl = split(ref("desconsAll"), ", ")
    for i=0 to ubound(spl)
        spl2 = split(spl(i), "|")
        call fazDesconsolida(spl2(0), spl2(1), spl2(2), spl2(3))
    next
    %>
    location.reload();
    <%
end if

%>

