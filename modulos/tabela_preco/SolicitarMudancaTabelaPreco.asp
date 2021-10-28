<!--#include file="../../connect.asp"-->
<%

linhas = ref("linhas[]")
linhas = split(linhas, ", ")




%>
<table class="table table-hover">
    <tr class="primary">
        <th>#</th>
        <th>Procedimento</th>
        <th>Valor anterior</th>
        <th>Valor proposto</th>
        <th>Diferença</th>
    </tr>

    <%
    Total=0
    procedimentosAlterados = 0
    for i=0 to ubound(linhas)
        linha = linhas(i)

        nome_procedimento = ref("alteracoes["&i&"][nome]")
        procedimento_id = ref("alteracoes["&i&"][procedimento_id]")
        valorAnterior = ccur(ref("alteracoes["&i&"][valor_anterior]"))
        valorProposto = ccur(ref("alteracoes["&i&"][valor_proposto]"))

        
        diferenca = valorProposto - valorAnterior
        Total = Total + diferenca

        if valorAnterior<>valorProposto then
            procedimentosAlterados = procedimentosAlterados + 1
        %>
        <tr>
            <td><code><%=procedimento_id%></code></td>
            <td><%=nome_procedimento%></td>
            <td><%=fn(valorAnterior)%></td>
            <td><%=fn(valorProposto)%></td>
            <td><%=fn(diferenca)%></td>


        </tr>
        <%
        end if
    next
    %>
    <tr class="dark">
        <td colspan="4"></td>
        <th><%=fn(Total)%></th>
    </tr>
</table>

<div class="mt15">
<%

if procedimentosAlterados = 0 then
    %>
    <div class="alert alert-warning "><strong>Atenção!</strong> Nenhum procedimento foi alterado.</div>
    <%
else
    %>

    <p>Preencha abaixo para confirmar a solicitação:</p>

    <div class="row">
        <%= quickField("memo", "MotivoSolicitacaoTabela", "Motivo", 8, "", "", "", "") %>
    </div>

    <%
end if

%>
</div>