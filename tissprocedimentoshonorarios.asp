<!--#include file="connect.asp"-->
<%
if req("X")<>"" then
	db_execute("delete from tissprocedimentoshonorarios where id="&req("X"))
	db_execute("delete from rateiorateios where ItemGuiaID="&req("X"))
    db_execute("delete from tissguiaanexa where ProcGSID="&req("X"))
    %>
    <script type="text/javascript">
        atualizaTabela('tissoutrasdespesas', 'tissoutrasdespesas.asp?I=<%=req("I")%>');
    </script>
    <%
end if
%>
<table width="100%" class="table table-striped table-bordered table-condensed table-hover">
  <thead>
    <tr>
      <th width="20" align="center" nowrap> </th>
      <th width="65" align="center" nowrap>Data</th>
      <th width="65" align="center" nowrap>In&iacute;cio</th>
      <th width="60" align="center" nowrap>Fim</th>
      <th width="40" align="center" nowrap>Tabela</th>
      <th width="70" align="center" nowrap>Código</th>
      <th align="center" nowrap>Descrição</th>
      <th width="40" align="center" nowrap>Qtd</th>
      <th width="35" align="center" nowrap>Via</th>
      <th width="35" align="center" nowrap>Téc</th>
      <th width="50" align="center" nowrap>Fator</th>
      <th width="80" align="center" nowrap>Valor Unit.</th>
      <th width="60" align="center" nowrap>Valor Total</th>
      <th width="30" align="center" nowrap> </th>
      <th width="30" align="center" nowrap><button type="button" class="btn btn-info btn-xs" onClick="itemHonorarios('Procedimentos', <%=req("I")%>, 0);"><i class="far fa-plus"></i></button></th>
    </tr>
  </thead>
  <tbody>
  <%
  set p = db.execute("select * from tissprocedimentoshonorarios where GuiaID="&req("I")&" order by id")
  while not p.eof
  	'if not isnull(p("Fator")) and not isnull(p("ValorUnitario")) then
	'	ValorTotal = p("ValorTotal")*p("Fator")
	'else
		ValorTotal = p("ValorTotal")
	'end if
	if isnull(ValorTotal) then
		ValorTotal = 0
	end if
	'ValorTotal = ValorTotal* p("Quantidade")
  %>
    <tr id="lProcedimentos<%=p("id") %>">
      <input type="hidden" name="listaProc[]" value="<%=p("id") %>" />
      <input type="hidden" name="codigoProc<%=p("id") %>" value="<%=p("CodigoProcedimento") %>" />
      <input type="hidden" name="descricaoProc<%=p("id") %>" value="<%=p("Descricao") %>" />
      <input type="hidden" name="qtdProc<%=p("id") %>" value="<%=p("Quantidade") %>" />
      <input type="hidden" name="tabelaProc<%=p("id") %>" value="<%=p("TabelaID") %>" />
      <td align="center"><button type="button" class="btn btn-xs btn-success" onClick="itemHonorarios('Procedimentos', <%=req("I")%>, <%=p("id")%>);"><i class="far fa-edit"></i></button></td>
      <td align="center"><%= p("Data") %></td>
      <td align="center"><%= right(p("HoraInicio"),8) %></td>
      <td align="center"><%= right(p("HoraFim"),8) %></td>
      <td align="center"><%= p("TabelaID") %></td>
      <td align="center"><%= p("CodigoProcedimento") %></td>
      <td align="left"><%= p("Descricao") %></td>
      <td align="center"><%= p("Quantidade") %></td>
      <td align="center"><%= p("ViaID") %></td>
      <td align="center"><%= p("TecnicaID") %></td>
      <td align="center"><%= p("Fator") %></td>
      <td align="center"><% if not isnull(p("ValorUnitario")) then response.Write(formatnumber(p("ValorUnitario"), 2)) end if %></td>
      <td align="center"><%= formatnumber(ValorTotal, 2) %></td>
      <td align="center">
          <%
          sta = p("statusAutorizacao")
              if sta=0 then
                  %>
                  <button type="button" class="btn btn-xs btn-warning" onClick="autorizaProcedimentos(<%=p("id")%>)"><i class="far fa-compress"></i></button>
                  <%
              elseif sta=1 then
                  %>
                  <button type="button" class="btn btn-xs btn-default" onClick="alert('Aguardando resultado da solicitacao.')"><i class="far fa-clock-o"></i></button>
                  <%
              elseif sta=2 then
                  %>
                  <button type="button" class="btn btn-xs btn-success" onClick="alert('AUTORIZADO\n\nQuantidade autorizada: 1')"><i class="far fa-check"></i></button>
                  <%
              elseif sta=3 then
                set neg = db.execute("select * from cliniccentral.tissmotivoglosa where Codigo like '"&p("motivoNegativa")&"'")
                      if neg.eof then
                        CodigoNegativa = ""
                        descricaoNegativa = ""
                      else
                        CodigoNegativa = neg("Codigo")
                        descricaoNegativa = neg("Descricao")
                      end if
                  %>
                  <button type="button" class="btn btn-xs btn-danger" onClick="alert('NEGADO - <%=CodigoNegativa %>\n\n<%=descricaoNegativa %>')"><i class="far fa-ban"></i></button>
                  <%
              end if
              %>
      </td>
      <td align="center"><button type="button" class="btn btn-xs btn-danger" onClick="atualizaTabela('tissprocedimentoshonorarios', 'tissprocedimentoshonorarios.asp?I=<%=req("I")%>&X=<%=p("id")%>')"><i class="far fa-remove"></i></button></td>
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

