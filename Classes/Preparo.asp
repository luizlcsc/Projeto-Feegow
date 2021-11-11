<!--#include file="../connect.asp"-->

<%

Class Preparo

    function getPreparo(ProfissionalID, ProcedimentoID)
        Conta = "5_"&ProfissionalID

        sql = "select sr.*, prf.Dias, prf.Horas, prf.Inicio, prf.Fim from procedimentospreparofrase prf LEFT JOIN procedimentospreparosexcecao pr ON prf.ExcecaoID=pr.id"&_
                      " INNER JOIN sys_preparos sr ON sr.id=prf.PreparoID"&_
                      " WHERE prf.ProcedimentoID="&treatvalzero(ProcedimentoID)&" AND (pr.Conta='"&Conta&"' or pr.Conta IS NULL)"

        set getPreparo = db.execute(sql)
    end function

    function renderPreparo(Descricao, Tipo, Inicio, Fim, Dias, Horas)
        content = "<strong>"&Descricao&":</strong><br>"

        if Tipo=1 then
            input = ""
        elseif Tipo=2 then
            input = "i"
        elseif Tipo=3 then
            input = Dias&" dias"
        elseif Tipo=4 then
            input = Horas&" horas"
        end if

        content=content&input

        renderPreparo=content
    end function

End Class
%>