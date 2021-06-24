<!--#include file="connect.asp"-->
<%
csv = request.form("csv")
TabelaConvenioID = request.form("TabelaConvenioID")
splitCsv = split(csv,"|")

for i = 0 to ubound(splitCsv)
    if len(splitCsv(i)) > 0 then
        colunasCsv = split(splitCsv(i),";")

        Codigo = colunasCsv(0)
        CodigoTUSS = colunasCsv(1)
        Procedimento = colunasCsv(2)
        Porte = colunasCsv(3)
        Coeficiente = colunasCsv(4)
        CustoOperacional = colunasCsv(5)
        Auxiliares = colunasCsv(6)
        Filme = colunasCsv(7)
        QuantidadeCH = colunasCsv(8)
        ProcedimentoID = colunasCsv(9)
        ValorReal = colunasCsv(10)

        if ProcedimentoID = "" then
            ProcedimentoID = "NULL"
        end if

        if Coeficiente = "" then
            Coeficiente = "NULL"
        end if
        
        if CustoOperacional = "" then
            CustoOperacional = "NULL"
        end if

        if Auxiliares = "" then
            Auxiliares = "NULL"
        end if

        if Filme = "" then
            Filme = "NULL"
        end if

        if ValorReal = "" then
            ValorReal = "NULL"
        end if

        if QuantidadeCH = "" then
            QuantidadeCH = "NULL"
        end if

        db_execute("INSERT INTO tabelasconveniosprocedimentos (TabelaConvenioID, ProcedimentoID, Codigo, CodigoTUSS, Procedimento, Coeficiente, Porte, CustoOperacional, Auxiliares, QuantidadeCH, ValorReal, Filme, sysUser, sysActive) "&_
                   " VALUES ("&TabelaConvenioID&", "&ProcedimentoID&", '"&Codigo&"', '"&CodigoTUSS&"','"&Procedimento&"', "&Coeficiente&", '"&Porte&"', "&CustoOperacional&", "&Auxiliares&", "&QuantidadeCH&","&ValorReal&", "&Filme&", "&session("User")&",1)")
        db_execute("DELETE FROM tabelasconveniosprocedimentos WHERE TabelaConvenioID = "&TabelaConvenioID&" AND Codigo IS NULL OR Codigo = ''")

    end if
next

%>