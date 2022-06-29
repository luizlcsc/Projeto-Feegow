<!--#include file="connect.asp"-->
<%
spl = split(req("ID"), "_")
Associacao = spl(0)
ContaID = spl(1)

if Associacao = 3 then
    'Busca a tabela cadastrada no cadastro do Paciente para ser usada na tela de conta 
    set rs = db.execute("select tabela from pacientes where id=" & ContaID)
    if not rs.eof then
        TabelaID = rs("tabela")
        rs.close
        set rs = nothing
        %>
        $("#invTabelaID").val("<%=TabelaID%>").change();
        <%
    else 
        %>
        $("#invTabelaID").val("0").change();
        <%  
    end if
else 
     %>
     $("#invTabelaID").val("0").change();
    <% 
end if
%>