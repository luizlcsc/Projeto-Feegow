<!--#include file="connect.asp"-->
<%
function makePrecoLogAllTable (table)
    ' table = req("tabela")

    changeActive = "update logPlanoContas set sysActive=0 where sysActive=1 and tabela ='"&table&"'"
    db.execute(changeActive)

    newLog = "INSERT INTO logPlanoContas (sysUser,tabela) VALUES("&session("User")&",'"&table&"');" 

    db.execute(newLog)
    codigoSql = "select id from logPlanoContas order by id desc limit 1"
    codigoResposta = db.execute(codigoSql)
    codigo = codigoResposta("id")

    sqlCopy = "insert into logPlanoContasItens(IdOriginal,Codigo, Name, Category, Ordem, Rateio, sysActive, sysUser, Nivel, Tipo,DhUP) (select id as IdOriginal, "&codigo&" as codigo, Name, Category, Ordem, Rateio, sysActive, sysUser, Nivel, Tipo,now() from "&table&");"

    ' response.write(sqlCopy)
    db.execute(sqlCopy)

end function

%>