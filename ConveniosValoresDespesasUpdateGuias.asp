<!--#include file="connect.asp"-->

<%
ConvenioID = ref("ConvenioID")

set reqIds = request.form("ids")

if ConvenioID = "" or reqIds.Count = 0 then
    response.write("Parâmetros inválidos")
    response.status = 400
    response.end
end if

sqlItens = "SELECT tpt.ProdutoID, tpt.TabelaID, tpv.ConvenioID, tpt.Codigo, " &_
           "COALESCE(tpv.Valor, tpt.Valor) as Valor, tpv.Descricao " &_
           "FROM tissprodutosvalores tpv " &_
           "INNER JOIN tissprodutostabela tpt ON tpt.id = tpv.ProdutoTabelaID " &_
           "WHERE tpv.id IN (" & ref("ids") & ") AND tpv.ConvenioID = '" & ConvenioID & "'"

set rsItens = db.execute(sqlItens)

if rsItens.eof then
    response.write("Nenhum item encontrado para atualização")
    response.status = 422
    response.end
end if

countSuccess = 0

while not rsItens.eof


    sqlGuias = "SELECT DISTINCT g.id FROM tissguiasadt g " &_
               "INNER JOIN tissguiaanexa ga ON ga.GuiaID = g.id " &_
               "LEFT JOIN tisslotes l ON g.LoteID = l.id " &_
               "WHERE g.sysActive = 1 AND g.ConvenioID = '" & rsItens("ConvenioID") & "' " &_
               "AND ga.ProdutoID = '" & rsItens("ProdutoID") & "' " &_
               "AND ga.TabelaProdutoID = '" & rsItens("TabelaID") & "' " &_
               "AND (l.Enviado IS NULL OR l.Enviado = 0) "
    set rsGuias = db.execute(sqlGuias)

    while not rsGuias.eof

        guiaId = rsGuias("id")

        sqlUpdateAnexo = "UPDATE tissguiaanexa ga " &_
                         "SET ga.CodigoProduto = '" & rep(rsItens("Codigo")) & "', " &_
                         "ga.ValorUnitario = '" & rsItens("Valor") & "', " &_
                         "ga.Descricao = '" & rep(rsItens("Descricao")) & "', " &_
                         "ga.ValorTotal = ga.ValorUnitario * ga.Fator * ga.Quantidade " &_
                         "WHERE ga.GuiaID = " & guiaId  & " " &_
                         "AND ga.ProdutoID = " & rsItens("ProdutoID") & " " &_
                         "AND ga.TabelaProdutoID = " & rsItens("TabelaID")

        db.execute(sqlUpdateAnexo)

        db.execute("update tissguiasadt set " &_
            "GasesMedicinais=(select sum(ValorTotal) from tissguiaanexa where CD=1 and GuiaID=" & guiaId &"), " &_
            "Medicamentos=(select sum(ValorTotal) from tissguiaanexa where CD=2 and GuiaID=" & guiaId &"), " &_
            "Materiais=(select sum(ValorTotal) from tissguiaanexa where CD=3 and GuiaID=" & guiaId &"), " &_
            "TaxasEAlugueis=(select sum(ValorTotal) from tissguiaanexa where CD=7 and GuiaID=" & guiaId &"), " &_
            "OPME=(select sum(ValorTotal) from tissguiaanexa where CD=8 and GuiaID=" & guiaId &") " &_
            "where id =" & guiaId)

        set guia = db.execute("select * from tissguiasadt where id = " & guiaId)
        db.execute("update tissguiasadt set TotalGeral="&treatvalzero(n2z(guia("Procedimentos"))+n2z(guia("Medicamentos"))+n2z(guia("Materiais"))+n2z(guia("TaxasEAlugueis"))+n2z(guia("OPME")))&" where id=" & guiaId)

        countSuccess = countSuccess + 1

        rsGuias.movenext
    wend

    rsItens.movenext
wend

if countSuccess > 1 then
    response.write(countSuccess & " guias atualizadas.")
elseif countSuccess = 1 then
    response.write("1 guia atualizada.")
else
    response.write("Nenhum guia atualizada.")
end if

%>
