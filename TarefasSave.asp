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
    if referencia = "dep" then
      qAcao = "INSERT INTO `tarefas_dependencias` "&chr(13)_
      &"(`TarefaID`, `sysUserCreate`, `dependencia`, `descricao`, `responsaveis`, `finalizada`, `prazo`) VALUES "&chr(13)_
      &"('"&req("I")&"', "&session("User")&", '"&ref("dependencia")&"', '"&ref("dependenciaDescricao")&"', '"&ref("dependenciaResponsaveis")&"', '"&myDate(ref("dependenciaConclusao"))&"', '"&myDate(ref("dependenciaPrazo"))&"'); "
    else
      qAcao = "UPDATE tarefas SET TarefaPaiID='"&referencia&"'"_
      &" WHERE id = "&valor
    end if
  Case "e" 'EDITA
    qAcao = "UPDATE tarefas_dependencias SET "_
    &"dependencia='"&ref("dependencia")&"', descricao='"&ref("dependenciaDescricao")&"', responsaveis='"&ref("dependenciaResponsaveis")&"', finalizada='"&myDate(ref("dependenciaConclusao"))&"', prazo='"&myDate(ref("dependenciaPrazo"))&"', sysUserUpdate="&session("User")&" "_
    &"WHERE id = "&valor
end select

'response.write("<pre>"&qAcao&"</pre>")
db.execute(qAcao)



%>