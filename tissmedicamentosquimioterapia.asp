<!--#include file="connect.asp"-->
<%
if req("X")<>"" then
	db_execute("delete from tissmedicamentosquimioterapia where id="&req("X"))
end if
%>
<table width="100%" class="table table-striped table-bordered table-condensed">
  <thead>
    <tr>
      <th width="2%" align="center" nowrap> </th>
      <th width="5%" align="center" nowrap>Data</th>
      <th width="10%" align="center" nowrap>Tabela</th>
      <th width="10%" align="center" nowrap>Código</th>
      <th width="40%" align="center" nowrap>Descrição</th>
      <th width="10%" align="center" nowrap>Doses</th>
      <th width="10%" align="center" nowrap>Via Adm</th>
      <th width="10%" align="center" nowrap>Frequência</th>
      <th width="3%" align="right" nowrap><button type="button" class="btn btn-info btn-xs" onClick="itemQuimioterapia('Produto', <%=request.QueryString("I")%>, 0);"><i class="far fa-plus"></i></button></th>
    </tr>
  </thead>
  <tbody>
  <%
  set p = db.execute("select * from tissmedicamentosquimioterapia where GuiaID="&req("I")&" order by id")
  while not p.eof
  %>
    <tr id="lProdutos<%=p("id") %>">
      <input type="hidden" name="listaMedic[]" value="<%=p("id") %>" />
      <input type="hidden" name="dataMedic<%=p("id") %>" value="<%=p("DataAdministracao") %>"/>
      <input type="hidden" name="tabelaMedic<%=p("id") %>" value="<%=p("TabelaID") %>"/>
      <input type="hidden" name="codigoMedic<%=p("id") %>" value="<%=p("CodigoMedicamento") %>"/>
      <input type="hidden" name="descricaoMedic<%=p("id") %>" value="<%=p("Descricao") %>"/>      
      <input type="hidden" name="dosagemMedic<%=p("id") %>" value="<%=p("DosagemMedicamento") %>"/>
      <input type="hidden" name="viaADMMedic<%=p("id") %>" value="<%=p("ViaADM") %>"/>
      <input type="hidden" name="frequenciaMMedic<%=p("id") %>" value="<%=p("Frequencia") %>"/>
      
      <td align="center"><button type="button" class="btn btn-xs btn-success" onClick="itemQuimioterapia('Produto', <%=request.QueryString("I")%>, <%=p("id")%>);"><i class="far fa-edit"></i></button></td>
      <td align="center"><%= p("DataAdministracao") %></td>
      <td align="center"><%= p("TabelaID") %></td>
      <td align="center"><%= p("CodigoMedicamento") %></td>
      <td align="left"><%= p("Descricao") %></td>
      <td align="center"><%= p("DosagemMedicamento") %></td>
      <td align="center"><%= p("ViaADM") %></td>
      <td align="center"><%= p("Frequencia") %></td>
      <td align="center"><button type="button" class="btn btn-xs btn-danger" onClick="atualizaTabela('tissmedicamentosquimioterapia', 'tissmedicamentosquimioterapia.asp?I=<%=request.QueryString("I")%>&X=<%=p("id")%>')"><i class="far fa-remove"></i></button></td>
    </tr>
    <tr>
        <td colspan="15" class="hidden" id="Produto<%=p("id") %>"></td>
    </tr>
  <%
  p.movenext
  wend
  p.close
  set p=nothing
  %>
  <tr>
      <td id="Produto0" colspan="15"></td>
  </tr>
  </tbody>
</table>

