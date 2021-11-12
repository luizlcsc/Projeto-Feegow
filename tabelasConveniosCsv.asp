<!--#include file="connect.asp"-->
<%
csv = request.form("csv")
TabelaConvenioID = request.form("TabelaConvenioID")
splitCsv = split(csv,"|")

function clearCol(valorColuna)
    clearCol = replace(valorColuna, """", "")
    clearCol = replace(clearCol, "﻿","")
    clearCol = replace(clearCol, "'","")
    clearCol = trim(clearCol)
end function

for i = 0 to ubound(splitCsv)
    if len(splitCsv(i)) > 0 then
        colunasCsv = split(splitCsv(i),";")

        Codigo = clearCol(colunasCsv(0))
        CodigoTUSS = clearCol(colunasCsv(1))
        Procedimento = clearCol(colunasCsv(2))
        Porte = clearCol(colunasCsv(3))
        Coeficiente = clearCol(colunasCsv(4))
        CustoOperacional =clearCol(colunasCsv(5))
        Auxiliares = clearCol(colunasCsv(6))
        Filme = clearCol(colunasCsv(7))
        QuantidadeCH = clearCol(colunasCsv(8))
        ProcedimentoID = clearCol(colunasCsv(9))
        ValorReal = clearCol(colunasCsv(10))

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

        if CodigoTUSS = "" then
            CodigoTUSS = "NULL" 
        end if

        if Porte = "" then
            Porte = "NULL" 
        end if

        db_execute("INSERT INTO tabelasconveniosprocedimentos (TabelaConvenioID, ProcedimentoID, Codigo, CodigoTUSS, Procedimento, Coeficiente, Porte, CustoOperacional, Auxiliares, QuantidadeCH, ValorReal, Filme, sysUser, sysActive) "&_
                   " VALUES ("&TabelaConvenioID&", "&ProcedimentoID&", '"&Codigo&"', '"&CodigoTUSS&"','"&Procedimento&"', "&treatvalzero(Coeficiente)&", '"&Porte&"', "&treatvalzero(CustoOperacional)&", "&treatvalzero(Auxiliares)&", "&treatvalzero(QuantidadeCH)&","&treatvalzero(ValorReal)&", "&treatvalzero(Filme)&", "&session("User")&",1)")
        db_execute("DELETE FROM tabelasconveniosprocedimentos WHERE TabelaConvenioID = "&TabelaConvenioID&" AND Codigo IS NULL OR Codigo = ''")

    end if
next

%>