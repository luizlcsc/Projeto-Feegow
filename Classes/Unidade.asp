<!--#include file="../connect.asp"-->

<%

Class Unidade

    function getUnidades()

        sql = "select sr.*, prf.Restringir, prf.Inicio, prf.Fim from procedimentosrestricaofrase prf LEFT JOIN procedimentosrestricoesexcecao pr ON prf.ExcecaoID=pr.id"&_
                      " INNER JOIN sys_restricoes sr ON sr.id=prf.RestricaoID"&_
                      " WHERE prf.ProcedimentoID="&treatvalzero(ProcedimentoID)&" AND (pr.Conta='"&Conta&"' or pr.Conta IS NULL)"
        set getRestricoes = db.execute(sql)
    end function

    function getUnitName(id)
        set UnidadeSQL = db.execute("SELECT NomeFantasia FROM (SELECT NomeFantasia,0 id FROM empresa UNION ALL"&_
        " SELECT NomeFantasia, id FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&treatvalzero(id))

        if not UnidadeSQL.eof then
            getUnitName=UnidadeSQL("NomeFantasia")
        else
            getUnitName=""
        end if
    end function

End Class
%>