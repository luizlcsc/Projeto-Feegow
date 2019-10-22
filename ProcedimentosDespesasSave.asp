<!--#include file="connect.asp"-->
<%
Convenios = ref("Convenios[]")
ProdutoTabelaID = ref("PTID")
ProcedimentoID = ref("ProcedimentoID")
Qtd = ref("Qtd")

if Convenios="" then
    Convenios = "0"
end if

sqlDel = "delete pp from tissprodutosprocedimentos pp LEFT JOIN tissprocedimentosvalores pv ON pv.id=pp.AssociacaoID WHERE pp.ProdutoTabelaID="& ProdutoTabelaID & " AND ('"&Convenios&"' NOT LIKE CONCAT('%|',pv.ConvenioID,'|%')) AND pv.ProcedimentoID="&ProcedimentoID
'response.write( sqlDel )
db_execute( sqlDel )

set pcv = db.execute("select id from tissprocedimentosvalores where ProcedimentoID="& ProcedimentoID & " AND ConvenioID IN("& replace(Convenios, "|", "") &")")
while not pcv.eof
    AssociacaoID = pcv("id")

    set vca = db.execute("select id from tissprodutosprocedimentos where AssociacaoID="& AssociacaoID &" and ProdutoTabelaID="& ProdutoTabelaID &"")
    if vca.eof then
        db_execute("insert into tissprodutosprocedimentos (AssociacaoID, Quantidade, ProdutoTabelaID) values ("& AssociacaoID &", "& treatvalzero(Qtd) &", "& ProdutoTabelaID &")")
        set pult = db.execute("select id from tissprodutosprocedimentos order by id desc limit 1")
        ProdutoProcedimentoID = pult("id")
    else
        db_execute("update tissprodutosprocedimentos set Quantidade="& treatvalzero(Qtd) &" where id="& vca("id"))
        ProdutoProcedimentoID = vca("id")
    end if

    ppEnvolvidos = ppEnvolvidos &", "& ProdutoProcedimentoID

pcv.movenext
wend
pcv.close
set pcv=nothing
%>
