<!--#include file="connect.asp"-->
<%
T = req("T")
TG = lcase(req("TG"))

if req("I")="M" then
    Guia = ref("Guia")
else
    Guia = req("I")
end if

if TG="guiaconsulta" then
    coluna = "ValorProcedimento"
elseif TG="guiasadt" then
    coluna = "TotalGeral"
    tabelaprocedimento = "tissprocedimentossadt"
elseif TG="guiahonorarios" then
    coluna = "Procedimentos"
    tabelaprocedimento = "tissprocedimentoshonorarios"
end if

if T="Glosado" then
    db.execute("update tiss"&TG&" set Glosado=1, ValorPago=0,GuiaStatus=8 WHERE id IN("&Guia&")")

    if TG = "guiasadt" OR TG="guiahonorarios" then
        db.execute("update "&tabelaprocedimento&" set ValorPago=0 WHERE GuiaID = "&Guia)
    end if
    response.write("location.reload();")
end if
if T="Pago" then
    db.execute("update tiss"&TG&" set Glosado=0, ValorPago="&coluna&", GuiaStatus=10 WHERE id IN("&Guia&")")

    if TG = "guiasadt" OR TG="guiahonorarios" then
        db.execute("update "&tabelaprocedimento&" set ValorPago=ValorTotal WHERE GuiaID = "&Guia)
    end if
    response.write("location.reload();")
end if

if ref("n")<>"" then
    GuiaID = replace(ref("n"), "ValorPago", "")
    ValorPago = ref("vp")
    sqlup = "update tiss"&TG&" set ValorPago="&treatvalzero(ValorPago)&" WHERE id IN("&GuiaID&")"


        if(TG = "guiasadt") then
            GuiaID = replace(ref("n"), "ValorPago", "")
            sql = "SELECT REPLACE(REPLACE(REPLACE(FORMAT(TotalGeral, 2), '.', '@'), ',', '.'), '@', ',') AS TotalGeral FROM tissguiasadt WHERE id = "&GuiaID&""
            ValorTotalSQLDois = db.execute(sql)
            
            valorTotal = ValorTotalSQLDois("TotalGeral")
            ValorPago = ref("vp")

            if(valorTotal = ValorPago) then
                db.execute("update tissprocedimentossadt set ValorPago=ValorTotal WHERE GuiaID ="&GuiaID&"")
            end if
        end if

    response.write("$('.guia[value="&GuiaID&"]').click();$('.guia[value="&GuiaID&"]').click();")

    db.execute(sqlup)

    set ValorTotalSQL = db.execute("SELECT "&coluna&", ValorPago FROM tiss"&TG&" WHERE id IN("&GuiaID&")")

    if not ValorTotalSQL.eof then

        if ValorTotalSQL(coluna) <= ValorTotalSQL("ValorPago") then
            db.execute("UPDATE tiss"&TG&" SET GuiaStatus =10 WHERE id IN("&GuiaID&")")
        elseif ValorPago="0" or ValorPago="" then
            'db.execute("UPDATE tiss"&TG&" SET GuiaStatus =2 WHERE id IN("&GuiaID&")")
        else
            db.execute("UPDATE tiss"&TG&" SET GuiaStatus =11 WHERE id IN("&GuiaID&")")
        end if
    end if

end if





%>
