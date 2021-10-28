 <!--#include file="connect.asp"-->
<div>
<table width="100%" class="table table-striped table-bordered table-hover table-condensed">
<thead>
    <tr class="info">
        <th colspan="5">Detalhes da Proposta</th>
        <th colspan="2"><button type="button" onclick="$('#divhist2<%= req("PropostaID") %>').css('display', 'none')" class="btn btn-block btn-xs btn-primary">Fechar</button></th>
    </tr>
    <tr>
        <th>Nome do procedimento</th>
        <th>Quantidade</th>
        <th>Valor Unitário</th>
        <th>Valor do Desconto</th>
        <th>Valor Total</th>
        <th>3x</th>
        <th>6x</th>
    </tr>
</thead>
<tbody>
<%
    set query = db.execute("select * from propostas p inner join itensproposta itp on itp.PropostaID = p.id inner join procedimentos pp ON pp.id = itp.ItemID where p.id = " & req("PropostaID"))
    if not query.eof then

    while not query.eof 
        ValorDesconto = query("Desconto")
        if query("TipoDesconto")&"" = "P" then
            ValorDesconto = query("ValorUnitario") * query("Desconto") / 100
        end if

        valorTotal = query("Quantidade") * query("ValorUnitario")

        tresVezes = valorTotal / 3
        seisVezes = valorTotal / 6
        %>
            <tr>
                <td><%=query("NomeProcedimento")%></td>
                <td><%=query("Quantidade")%></td>
                <td>R$ <%=fn(query("ValorUnitario"))%></td>
                <td>R$ <%=ValorDesconto%></td>
                <td>R$ <%=fn(valorTotal)%></td>
                <td>R$ <%=fn(tresVezes)%></td>
                <td>R$ <%=fn(seisVezes)%></td>
            </tr>
        <%
        query.movenext
    wend


    end if
%>
</tbody>
</table></div>