<!--#include file="connect.asp"-->
<h1>Configurações de Procedimentos</h1>
<div class="panel">
    <div class="panel-body">
    <%
    response.buffer

    set conv = db.execute("select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio")
    while not conv.eof
        ConvenioID = conv("id")
        %>
        <h2><%= ucase(conv("NomeConvenio")) %></h2>
        <%
        sql = "select gps.ProcedimentoID, proc.NomeProcedimento from tissprocedimentossadt gps left join tissguiasadt gs ON gs.id=gps.GuiaID LEFT JOIN procedimentos proc ON proc.id=gps.ProcedimentoID where gs.ConvenioID="& conv("id") &" GROUP BY gps.ProcedimentoID ORDER BY proc.NomeProcedimento"
    '    response.write(sql)
        set guias = db.execute( sql )
        if not guias.eof then
            %>
            <table class="table table-condensed table-bordered">
                <thead>
                    <tr class="info">
                        <th width="25%">Procedimento</th>
                        <th width="20%">Tabela</th>
                        <th width="15%">Código</th>
                        <th width="25%">Descrição</th>
                        <th width="7%">Téc.</th>
                        <th width="10%">Valor</th>
                    </tr>
                </thead>
                <tbody>
            <%
            while not guias.eof
                response.flush()
                    ProcedimentoID = guias("ProcedimentoID")
                    set pcv = db.execute("select pcv.id AssociacaoID, t.Descricao NomeTabela, pct.Codigo, pct.Descricao, pcv.TecnicaID, pcv.Valor from tissprocedimentosvalores pcv LEFT JOIN tissprocedimentostabela pct ON pct.id=pcv.ProcedimentoTabelaID LEFT JOIN tisstabelas t ON t.id=pct.TabelaID where ProcedimentoID="& ProcedimentoID &" and ConvenioID="& ConvenioID &"")
                    while not pcv.eof
                        AssociacaoID = pcv("AssociacaoID")
                        %>
                        <tr>
                            <td><%= left(guias("NomeProcedimento")&"", 25) %></td>
                            <td><%= left(pcv("NomeTabela")&"", 20) %></td>
                            <td><%= pcv("Codigo") %></td>
                            <td><%= pcv("Descricao") %></td>
                            <td><%= pcv("TecnicaID") %></td>
                            <td class="text-right"><%= fn(pcv("Valor")) %></td>
                        </tr>
                        <%
                        'sqlKit = "select * from procedimentoskits where ProcedimentoID="& ProcedimentoID &" and Casos like '%|"& ConvenioID &"|%'"
                        sqlKit = "select * from procedimentoskits where ProcedimentoID="& ProcedimentoID
                        'response.write( sqlKit )
                        set kit = db.execute( sqlKit )

                        set pp = db.execute("select p.NomeProduto, pt.TabelaID, pt.Codigo, pt.Valor, pt.id ProdutoTabelaID from tissprodutosprocedimentos pp LEFT JOIN tissprodutostabela pt ON pt.id=pp.ProdutoTabelaID LEFT JOIN produtos p ON p.id=pt.ProdutoID WHERE AssociacaoID="& AssociacaoID &" order by p.NomeProduto")
                        if not pp.eof or not kit.eof then
                            %>
                            <tr>
                                <td></td>
                                <td colspan="5">
                                    <table class="table table-condensed table-bordered">
                                        <thead>
                                            <tr>
                                                <th width="40%">Item</th>
                                                <th width="20%">Tabela</th>
                                                <th width="10%">Código</th>
                                                <th>Valor</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        <%
                                        if not pp.eof then
                                            while not pp.eof
                                                Valor = pp("Valor")
                                                if not isnull(pp("ProdutoTabelaID")) then
                                                    sqlPV = "select Valor from tissprodutosvalores where ConvenioID="& ConvenioID &" and ProdutoTabelaID="& pp("ProdutoTabelaID")
                                                    'response.write( sqlPV )
                                                    set pv = db.execute( sqlPV)
                                                    if not pv.eof then
                                                        Valor = pv("Valor")
                                                    end if
                                                    %>
                                                    <tr>
                                                        <td><%= pp("NomeProduto") %></td>
                                                        <td><%= zeroEsq(pp("TabelaID"), 2) %></td>
                                                        <td><%= pp("Codigo") %></td>
                                                        <td class="text-right"><%= fn(Valor) %></td>
                                                    </tr>
                                                    <%
                                                end if
                                            pp.movenext
                                            wend
                                            pp.close
                                            set pp=nothing
                                        end if

                                        if not kit.eof then
                                            set pdk = db.execute("select p.NomeProduto, pt.Codigo, pt.Valor, pt.TabelaID, pt.id ProdutoTabelaID FROM produtosdokit pdk LEFT JOIN produtos p ON p.id=pdk.ProdutoID LEFT JOIN tissprodutostabela pt ON pt.ProdutoID=p.id WHERE NOT ISNULL(p.NomeProduto) AND KitID="& kit("id") &" ORDER BY p.NomeProduto")
                                            while not pdk.eof
                                                Valor = pdk("Valor")
                                                if not isnull(pdk("ProdutoTabelaID")) then
                                                    set pv = db.execute("select * from tissprodutosvalores pv where pv.ConvenioID="& ConvenioID &" and pv.ProdutoTabelaID="& pdk("ProdutoTabelaID"))
                                                    if not pv.eof then
                                                        Valor = pv("Valor")
                                                    end if
                                                end if
                                                if Valor>0 then
                                                    %>
                                                    <tr>
                                                        <td><%= pdk("NomeProduto") %> [kit]</td>
                                                        <td><%= zeroEsq(pdk("TabelaID"), 2) %></td>
                                                        <td><%= pdk("Codigo") %></td>
                                                        <td class="text-right"><%= fn(Valor) %></td>
                                                    </tr>
                                                    <%
                                                end if
                                            pdk.movenext
                                            wend
                                            pdk.close
                                            set pdk = nothing
                                        end if
                                        %>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <%
                        end if
                    pcv.movenext
                    wend
                    pcv.close
                    set pcv=nothing
            guias.movenext
            wend
            guias.close
            set guias=nothing
                    %>
                </tbody>
            </table>
            <%
        end if
    conv.movenext
    wend
    conv.close
    set conv = nothing

    %>
    </div>
</div>
