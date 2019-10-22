<%
function createLog(operacao, ID, recurso, colunas, valorAnterior, valorNovo)
    if ID <> "" and recurso <> "" then
        db.execute("INSERT INTO log(Operacao, I, recurso, colunas, valorAnterior, valorAtual, sysUser) VALUES('"&operacao&"', "&ID&", '"&recurso&"', '"&colunas&"', '"&valorAnterior&"', '"&valorNovo&"',"&Session("User")&")")
        createLog = true
    else 
        createLog = false
    end if
End function
%>