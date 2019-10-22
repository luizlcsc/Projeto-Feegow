<!--#include file="connect.asp"-->

<table class="table table-condensed">
    <thead>
        <tr>
            <th width="6%">Qtd.</th>
            <th width="10%">Código</th>
            <th width="30%">Item</th>
            <th width="15%">Tabela</th>
            <th width="15%">CD</th>
            <th width="10%">Un. Medida</th>
            <th>Convênios</th>
        </tr>
    </thead>
    <tbody>
    <%
    ProcedimentoID = req("I")
    addPT = req("PT")
    if addPT<>"" then
        sqlAdd = "select '1' Qtd, '0' PPID, ptAdd.Codigo, ptAdd.Valor, ptAdd.id, pAdd.NomeProduto, tbAdd.Descricao NomeTabela, tcdAdd.Descricao CD, umAdd.Descricao Medida from tissprodutostabela ptAdd LEFT JOIN produtos pAdd ON pAdd.id=ptAdd.ProdutoID lEFT JOIN tisstabelas tbAdd ON tbAdd.id=ptAdd.TabelaID LEFT JOIN cliniccentral.tisscd tcdAdd ON tcdAdd.id=pAdd.CD LEFT JOIN cliniccentral.tissunidademedida umAdd ON umAdd.id=pAdd.ApresentacaoUnidade where ptAdd.id="& addPT &"	UNION ALL "
    end if
    sql = sqlAdd & "select pp.Quantidade Qtd, pp.id PPID, pt.Codigo, pt.Valor, pt.id, p.NomeProduto, tb.Descricao NomeTabela, tcd.Descricao CD, um.Descricao Medida from tissprodutosprocedimentos pp LEFT JOIN tissprocedimentosvalores pcv ON pcv.id=pp.AssociacaoID LEFT JOIN tissprodutostabela pt ON pt.id=pp.ProdutoTabelaID LEFT JOIN produtos p ON p.id=pt.ProdutoID lEFT JOIN tisstabelas tb ON tb.id=pt.TabelaID LEFT JOIN cliniccentral.tisscd tcd ON tcd.id=p.CD LEFT JOIN cliniccentral.tissunidademedida um ON um.id=p.ApresentacaoUnidade WHERE NOT isnull(pt.id) AND ProcedimentoID="& ProcedimentoID &" GROUP BY pt.id"

    'response.write( sql )
    set pp = db.execute(sql)
    while not pp.eof
        ValorPT = pp("Valor")
        ProdutoTabelaID = pp("id")
        Convenios = ""
        PPID = pp("PPID")

        set convs = db.execute("select group_concat( concat('|', pcv.ConvenioID, '|')) ConveniosEnv from tissprocedimentosvalores pcv left join tissprodutosprocedimentos pp ON pp.AssociacaoID=pcv.id where pcv.ProcedimentoID="& ProcedimentoID &" and pp.ProdutoTabelaID="& ProdutoTabelaID)
        if not convs.EOF then
            convenios = convs("ConveniosEnv")
        end if
        %>
        <tr>
            <td>
                <%= quickfield("text", "Qtd"&PPID, "", 12, pp("Qtd"), "", "", " onchange=""pps('"&ProdutoTabelaID&"', '"&PPID&"', $(this).parents('tr').find('.multisel').val())"" ") %>
            </td>
            <td><%= pp("Codigo") %></td>
            <td><%= pp("NomeProduto") %></td>
            <td><%= pp("NomeTabela") %></td>
            <td><%= pp("CD") %></td>
            <td><%= pp("Medida") %></td>
            <td>
                <select onchange="pps('<%=ProdutoTabelaID%>', <%= PPID %>, $(this).val())" multiple class="multisel tag-input-style">
                    <%
'                    sqlConv = "select c.id, c.NomeConvenio, pv.Valor from convenios c LEFT JOIN tissprodutosvalores pv ON (pv.ConvenioID=c.id AND pv.ProdutoTabelaID="&ProdutoTabelaID&") WHERE c.sysActive=1 GROUP BY c.id ORDER BY c.NomeConvenio"
                    sqlConv = "select c.id, c.NomeConvenio, pv.Valor from tissprocedimentosvalores pcv LEFT JOIN convenios c ON c.id=pcv.ConvenioID LEFT JOIN tissprodutosvalores pv ON (pv.ConvenioID=c.id AND pv.ProdutoTabelaID="&ProdutoTabelaID&") WHERE c.id IS NOT NULL AND c.Ativo='on' AND sysActive=1 AND pcv.ProcedimentoID="&ProcedimentoID&" ORDER BY c.NomeConvenio"
                    'response.write( sqlConv )
                    set conv = db.execute( sqlConv )
                    while not conv.eof
                        ValorPV = conv("Valor")
                        if isnull(ValorPV) then
                            Valor = ValorPT
                        else
                            Valor = ValorPV
                        end if
                        %>
                        <option value="|<%= conv("id") %>|" <%if instr(Convenios, "|"& conv("id") &"|") then response.write(" selected ") end if %> ><%= conv("NomeConvenio") &" - R$ "& fn(Valor) %></option>
                        <%
                    conv.movenext
                    wend
                    conv.close
                    set conv=nothing
                    %>
                </select>
            </td>
        </tr>
        <%
    pp.movenext
    wend
    pp.close
    set pp=nothing
    %>
    </tbody>
</table>

<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->
</script>