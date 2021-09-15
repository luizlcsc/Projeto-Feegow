<!--#include file="connect.asp"-->
<%
if req("X")<>"" then
	db_execute("delete from tissprocedimentosinterncacao where id="&req("X"))
end if
%>
<table width="100%" class="table table-striped table-bordered table-condensed">
  <thead>
    <tr>
      <th width="2%" align="center" nowrap> </th>
      <th width="5%" align="center" nowrap>Tabela</th>
      <th width="10%" align="center" nowrap>Código</th>
      <th width="40%" align="center" nowrap>Descrição</th>
      <th width="10%" align="center" nowrap>Qtde Solic</th>
      <th width="10%" align="center" nowrap>Qtde Aut</th>
      <th width="3%" align="right" nowrap><button type="button" class="btn btn-info btn-xs" onClick="itemInternacao('Procedimentos', <%=req("I")%>, 0);"><i class="far fa-plus"></i></button></th>
    </tr>
  </thead>
  <tbody>
  <%
  set p = db.execute("select * from tissprocedimentosinternacao where GuiaID="&req("I")&" order by id")
  while not p.eof
  %>
    <tr id="lProcedimentos<%=p("id") %>">
      <input type="hidden" name="listaProc[]" value="<%=p("id") %>" />
      <input type="hidden" name="codigoProc<%=p("id") %>" value="<%=p("CodigoProcedimento") %>" />
      <input type="hidden" name="descricaoProc<%=p("id") %>" value="<%=p("Descricao") %>" />
      <input type="hidden" name="qtdProc<%=p("id") %>" value="<%=p("Quantidade") %>" />
      <input type="hidden" name="qtdProcAut<%=p("id") %>" value="<%=p("QuantidadeAutorizada") %>" />
      <input type="hidden" name="tabelaProc<%=p("id") %>" value="<%=p("TabelaID") %>" />
      <td align="center"><button type="button" class="btn btn-xs btn-success" onClick="itemInternacao('Procedimentos', <%=req("I")%>, <%=p("id")%>);"><i class="far fa-edit"></i></button></td>
      <td align="center"><%= p("TabelaID") %></td>
      <td align="center"><%= p("CodigoProcedimento") %></td>
      <td align="left"><%= p("Descricao") %></td>
      <td align="center"><%= p("Quantidade") %></td>
      <td align="center"><%= p("QuantidadeAutorizada") %></td>
      <td align="center"><button type="button" class="btn btn-xs btn-danger" onClick="atualizaTabela('tissprocedimentosinternacao', 'tissprocedimentosinternacao.asp?I=<%=req("I")%>&X=<%=p("id")%>')"><i class="far fa-remove"></i></button></td>
    </tr>
    <tr>
        <td colspan="15" class="hidden" id="Procedimentos<%=p("id") %>"></td>
    </tr>
  <%
  p.movenext
  wend
  p.close
  set p=nothing
  %>
  <tr>
      <td id="Procedimentos0" colspan="15"></td>
  </tr>
  </tbody>
</table>

