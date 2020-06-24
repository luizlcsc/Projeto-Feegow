<!--#include file="connect.asp"-->
<%
acao       = req("acao")
referencia = req("ref")
valor      = req("v")
select Case acao:
  Case "r" 'REMOVE
    separaValor=Split(valor,",")

    for each valorX in separaValor
      removeWhereSQL = " id = "&valorX&" AND TarefaPaiID="&referencia

      if removeWhere="" then
        removeWhere = " WHERE ("& removeWhereSQL&") "
      else
        removeWhere = removeWhere&" OR ("&removeWhereSQL&")"
      end if

    next   
    
    qAcao = "UPDATE tarefas SET TarefaPaiID=''"_
    &removeWhere

  Case "a" 'ADICIONA
    qAcao = "UPDATE tarefas SET TarefaPaiID='"&referencia&"'"_
    &" WHERE id = "&valor
end select

'response.write("<pre>"&qAcao&"</pre>")
db.execute(qAcao)



%>