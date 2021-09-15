<!--#include file="connect.asp"-->
<%
if req("X")<>"" then
	db_execute("delete from cirurgiaanexos where id="&req("X"))
end if
%>
<table width="100%" class="table table-striped table-bordered table-condensed">
  <thead>
    <tr>
      <th width="20" align="center" nowrap> </th>
      <th width="65" align="center" nowrap>CD</th>
      <th width="40" align="center" nowrap>Data</th>
      <th width="70" align="center" nowrap>Tabela</th>
      <th align="center" nowrap>C&oacute;d. Item</th>
      <th align="center" nowrap>Descri&ccedil;&atilde;o</th>
      <th width="40" align="center" nowrap>Qtd</th>
      <th width="50" align="center" nowrap>Fator</th>
      <th width="80" align="center" nowrap>Valor Unit.</th>
      <th width="60" align="center" nowrap>Valor Total</th>
      <th width="30" align="center" nowrap> <button type="button" class="btn btn-info btn-xs" onClick="itemCirurgia('Despesas', <%=req("I")%>, 0);"><i class="far fa-plus"></i></button></th>
    </tr>
  </thead>
  <tbody>
  <%
  set p = db.execute("select * from cirurgiaanexos where GuiaID="&req("I"))
  while not p.eof
  %>
    <tr id="lDespesas<%=p("id") %>">
      <td align="center"><button type="button" class="btn btn-xs btn-success" onClick="itemCirurgia('Despesas', <%=req("I")%>, <%=p("id")%>);"><i class="far fa-edit"></i></button></td>
      <td align="center"><%= p("CD") %></td>
      <td align="center"><%= p("Data") %></td>
      <td align="center"><%= p("TabelaProdutoID") %></td>
      <td align="left"><%= p("CodigoProduto") %></td>
      <td align="left"><%= p("Descricao") %></td>
      <td align="center"><%= p("Quantidade") %></td>
      <td align="center"><%= p("Fator") %></td>
      <td align="right"><%= fn(p("ValorUnitario")) %></td>
      <td align="right"><%= fn(p("ValorTotal")) %></td>
      <td align="center"><button type="button" class="btn btn-xs btn-danger" onClick="atualizaTabela('tissoutrasdespesas', 'tissoutrasdespesas.asp?I=<%=req("I")%>&X=<%=p("id")%>')"><i class="far fa-remove"></i></button></td>
    </tr>
    <tr>
        <td colspan="11" class="hidden" id="Despesas<%=p("id") %>"></td>
    </tr>
  <%
  p.movenext
  wend
  p.close
  set p=nothing
  %>
  <tr>
      <td id="Despesas0" colspan="11"></td>
  </tr>
  </tbody>
</table>

