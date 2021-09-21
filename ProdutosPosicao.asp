<!--#include file="connect.asp"-->
<%
set reg = db.execute("select p.*, u.* from produtos as p left join cliniccentral.tissunidademedida as u on p.ApresentacaoUnidade=u.id where p.id="&req("I"))
if len(reg("descricao"))>6 then
	unidade = right(reg("Descricao"), len(reg("Descricao"))-6 ) &"(s)"
end if
%>
<table width="100%" class="table table-striped table-bordered table-hover">
    <thead>
        <tr class="success">
            <th colspan="4">Posi&ccedil;&atilde;o de Estoque</th>
        </tr>
        <tr>
            <th>Lote</th>
            <th>Validade</th>
            <th>Quantidade</th>
            <th class="no-padding" width="75"><button class="btn btn-info btn-block btn-sm btnLancto" type="button"<%=disabled%> onclick="lancar(<%=req("I")%>, 'E', '', '');"><i class="far fa-level-down"></i> Entrada</button></th>
        </tr>
    </thead>
    <tbody>
        <%
        set lanc = db.execute("select distinct Validade, Lote from estoquelancamentos where ProdutoID="&req("I"))
        while not lanc.eof
            Quantidade = quantidadeEstoque(req("I"), lanc("Lote"), lanc("Validade"))
            if Quantidade>0 then
                %>
                <tr>
                    <td><%=lanc("Lote")%></td>
                    <td><%=lanc("Validade")%></td>
                    <td><%=Quantidade &" "& lcase(unidade)%></td>
                    <td class="pn"><button class="btn btn-danger mn btn-block btn-sm btnLancto" type="button"<%=disabled%> onclick="lancar(<%=req("I")%>, 'S', '<%=lanc("Lote")%>', '<%=lanc("Validade")%>');"><i class="far fa-level-up"></i> Sa&iacute;da</button></td>
                </tr>
                <%
            end if
        lanc.movenext
        wend
        lanc.close
        set lanc = nothing
        %>
    </tbody>
</table>
