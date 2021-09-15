<!--#include file="connect.asp"-->
<!--#include file="Classes\ValorProcedimento.asp"-->
<!--#include file="Classes\JSON.asp"-->
<%
if req("X")<>"" then
  PermiteExclusao=True

  set ExisteLaudoSQL = db.execute("SELECT id FROM laudos WHERE Tabela='tissprocedimentossadt' AND IDTabela="&treatvalzero(req("X")))

  if not ExisteLaudoSQL.eof then
    %>
    <script type="text/javascript">
      showMessageDialog("Já existe um laudo associado a este procedimento.", "danger", "Exclusão não permitida!");
    </script>
    <%
    PermiteExclusao=False
  end if

  if PermiteExclusao then
    db_execute("delete from tissprocedimentossadt where id="&req("X"))
    db_execute("delete from rateiorateios where ItemGuiaID="&req("X"))
      if session("Banco")<>"clinic3882" then
          db_execute("delete from tissguiaanexa where ProcGSID="&req("X"))
      end if
      %>
      <script type="text/javascript">
          atualizaTabela('tissoutrasdespesas', 'tissoutrasdespesas.asp?I=<%=req("I")%>');
      </script>
      <%
    end if
end if
%>
<table width="100%" class="table table-striped table-bordered table-condensed">
  <thead>
    <tr>
      <th width="20" align="center" nowrap><button type="button" onclick="ExibeHistoricoSADT('<%=req("I")%>')" title="Histórico de alterações" class="btn btn-default btn-xs"><i class="far fa-history"></i></button></th>
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
      <th width="30" align="center" nowrap><button type="button" class="btn btn-info btn-xs" onClick="itemSADT('Procedimentos', <%=req("I")%>, 0);"><i class="far fa-plus"></i></button></th>
    </tr>
  </thead>
  <tbody>
  <%

  IF getConfig("calculostabelas") THEN
     IF req("setPlano") <> "" AND req("setConvenio") <> "" THEN
        call updateWithPlanoAndConvenio(req("I"),req("setConvenio"),req("setPlano"))
     END IF

     recalcularEscalonamento(req("I"))
  END IF

  set p = db.execute("select * from tissprocedimentossadt where GuiaID="&req("I")&" ORDER BY FATOR DESC, id")
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
      <td align="center"><button type="button" class="btn btn-xs btn-success" onClick="itemSADT('Procedimentos', <%=req("I")%>, <%=p("id")%>);"><i class="far fa-edit"></i></button></td>
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
      <td align="center">
      <%
        set vcaRep = db.execute("select rr.id from rateiorateios rr where rr.ItemGuiaID="& p("id") &" AND NOT ISNULL(rr.ItemContaAPagar)")
        if not vcaRep.eof then
            if aut("repassesV")=1 then
            %>
            <a title="Repasses Gerados" href="javascript:repasses('ItemGuiaID', <%= p("id") %>)" type="button" class="btn btn-xs btn-dark">
                <i class="far fa-puzzle-piece"></i>
            </a>
            <%
            end if
        else
            %>
            <button type="button" class="btn btn-xs btn-danger" onClick="atualizaTabela('tissprocedimentossadt', 'tissprocedimentossadt.asp?I=<%=req("I")%>&X=<%=p("id")%>')"><i class="far fa-remove"></i></button>
            <%
        end if
      %>


      </td>
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

