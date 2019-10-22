<!--#include file="../connect.asp"-->

<%

Class Restricao

    function getRestricoes(ProfissionalID, ProcedimentoID)
        Conta = "5_"&ProfissionalID

        sql = "select sr.*, prf.Restringir, prf.Inicio, prf.Fim from procedimentosrestricaofrase prf LEFT JOIN procedimentosrestricoesexcecao pr ON prf.ExcecaoID=pr.id"&_
                      " INNER JOIN sys_restricoes sr ON sr.id=prf.RestricaoID"&_
                      " WHERE prf.ProcedimentoID="&treatvalzero(ProcedimentoID)&" AND (pr.Conta='"&Conta&"' or pr.Conta IS NULL)"
        set getRestricoes = db.execute(sql)
    end function

    function renderRestricao(Descricao, Tipo, RestricaoID, Restringir, Inicio, Fim, TextoSim, TextoNao)
        input = ""

        required = ""
        if Restringir<>"" and Restringir<>"0" then
            required = " required "
        end if

        onchange = " onchange=""verificaRestricao(this, '"&Restringir&"', '"&Inicio&"', '"&Fim&"', '"&TextoSim&"', '"&TextoNao&"')"" "

        if Tipo=1 then
            input = quickField("text", "Restricao-"&RestricaoID, Descricao, 3, "", "", "", ""&required&onchange)
        elseif Tipo=2 then
            input = quickField("number", "Restricao-"&RestricaoID, Descricao, 3, "", "", "", " min='"&min&"' max='"&max&"' "&required&onchange)
        elseif Tipo=3 then
            input = quickField("selectRadio", "Restricao-"&RestricaoID, Descricao, 3, "", "select 'S'id, 'Sim' Resposta UNION ALL SELECT 'N'id, 'Não'Resposta", "Resposta", ""&required&onchange)
        end if

        renderRestricao=input
    end function

End Class
%>