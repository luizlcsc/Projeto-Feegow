<!--#include file="connect.asp"-->
<%
    LinhaID = replace(req("LID"), "ProdutoID-produtosdokit-", "")
    ProdutoID = req("PID")
    TabelaID = ref("TabelaID")

    if TabelaID<>"" then
        set ass = db.execute("select * from tissprodutostabela where ProdutoID="&ProdutoID&" and TabelaID="&TabelaID)
        if not ass.eof then
            %>
            if( $("#Quantidade-produtosdokit-<%= LinhaID %>").val()=="" ){ $("#Quantidade-produtosdokit-<%= LinhaID %>").val(1) };
            $("#Codigo-produtosdokit-<%=LinhaID %>").val('<%=ass("Codigo") %>');
            $("#Valor-produtosdokit-<%=LinhaID %>").val('<%=fn(ass("Valor")) %>');
            <%
        else
            set ass2 = db.execute("select * from tissprodutostabela where ProdutoID="&ProdutoID)
            if not ass2.eof then
                %>
                if( $("#Quantidade-produtosdokit-<%= LinhaID %>").val()=="" ){ $("#Quantidade-produtosdokit-<%= LinhaID %>").val(1) };
                $("#Codigo-produtosdokit-<%=LinhaID %>").val('<%=ass2("Codigo") %>');
                $("#Valor-produtosdokit-<%=LinhaID %>").val('<%=fn(ass2("Valor")) %>');
                <%
            end if
        end if
    end if
%>
