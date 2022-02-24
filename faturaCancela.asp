

<!--#include file="connect.asp"-->

<%
    set ItemExec = db.execute("SELECT InvoiceID FROM itensinvoice WHERE InvoiceID = " & req("I") & " AND Executado IN ('S')")
    if not ItemExec.eof then
        erro = "Você não pode excluir contas que contenham itens executados."
    %>
        <div class="alert alert-danger col-md-10">
            <i class="far fa-exclamation-circle"></i> <%= erro %>
        </div>
    <%
    else
    %>
        <form method="post" action="./?P=ContasCD&T=<%=req("T")%>&Pers=1&X=<%=req("I")%>" id="faturaCancela">
            <div class="panel-heading">
                <span class="panel-title">Cancelamento de Fatura</span>
            </div>
            <div class="panel-body">
                <%= quickfield("memo", "MotivoCancelamento", "Informe o motivo do cancelamento da conta", 12, "", "", "", " required ") %>
            </div>
            <div class="panel-footer text-right">
                <button class="btn btn-danger"><i class="far fa-ban"></i> CONFIRMAR CANCELAMENTO</button>
            </div>
        </form>
    <%
    end if

%>

