<!--#include file="connect.asp"-->
<%
spl = split(req("CA"), "_")
Associacao = spl(0)
ContaID = spl(1)

if Associacao=2 then
    set vca = db.execute("select autoPlanoContas, limitarPlanoContas from fornecedores where id="&ContaID)
    if not vca.eof then

        LimitarPlanoContas=vca("limitarPlanoContas")

        if req("ApenasLimitar")<>"true" then

            autoPlanoContas = vca("autoPlanoContas")
            spl = split(autoPlanoContas, ", ")
            tm = 0

            for i=0 to ubound(spl)
                pc = replace(spl(i), "|", "")
                %>
                javascript:setTimeout(function(){ itens('O', 'I', 0, <%= pc %>) }, <%= tm %>);
                <%
                tm = tm+2000
            next
        end if
    end if
    %>
    $("#LimitarPlanoContas").val("<%=LimitarPlanoContas%>");
    <%
elseif Associacao=5 or Associacao=4 then
    if Associacao=5 then
        tabela = "profissionais"
    else
        tabela = "funcionarios"
    end if

    set CentroCustoSQL = db.execute("SELECT CentroCustoID FROM "&tabela&" WHERE id="&ContaID&" AND CentroCustoID IS NOT NULL" )
    if not CentroCustoSQL.eof then
        CentroCustoID = CentroCustoSQL("CentroCustoID")

        %>
        $("#CentroCustoBase").val("<%=CentroCustoID%>");
        <%
    end if
end if
%>