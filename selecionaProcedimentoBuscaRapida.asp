<!--#include file="connect.asp"-->
<%
codigo = req("codigo")
tabela = req("tabela")
selectID=req("selectID")

if selectID="CodigoProcedimento" then

    ProcedimentoID=0
    sql = "select COUNT(pv.id)Qtd,pv.ProcedimentoID, p.NomeProcedimento from tissprocedimentostabela pt LEFT JOIN tissprocedimentosvalores pv on pv.ProcedimentoTabelaID=pt.id LEFT JOIN procedimentos p on p.id=pv.ProcedimentoID where pt.Codigo='"&codigo&"' AND p.sysActive=1 AND p.Ativo='on' And PV.ProcedimentoID is not null and pt.TabelaID="&treatvalnull(tabela)&" GROUP BY pv.ProcedimentoID ORDER BY Qtd DESC LIMIT 1"
    'response.write(sql)
    set vcaCodigo = db.execute(sql)
        if not vcaCodigo.eof then
            ProcedimentoID=vcaCodigo("ProcedimentoID")
            NomeProcedimento=vcaCodigo("NomeProcedimento")
        end if
    %>
    $("#gProcedimentoID").html("<option value='<%=ProcedimentoID%>'><%=NomeProcedimento%></option>").change();


    <%
end if
    %>