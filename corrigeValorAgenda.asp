<!--#include file="connect.asp"-->
<%
set AgendamentosZeradosSQL = db.execute("SELECT a.*, l.UnidadeID, proc.Valor, proc.GrupoID FROM agendamentos a INNER JOIN procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN locais l ON l.id=a.LocalID WHERE a.ValorFinal is null AND a.Data>CURDATE() ORDER BY Data ASC LIMIT 1000")

while not AgendamentosZeradosSQL.eof
    ProcedimentoID = AgendamentosZeradosSQL("TipoCompromissoID")
    AgendamentoID = AgendamentosZeradosSQL("id")
    UnidadeID = AgendamentosZeradosSQL("UnidadeID")
    Valor = AgendamentosZeradosSQL("Valor")
    TabelaID = AgendamentosZeradosSQL("TabelaParticularID")
    ProfissionalID = AgendamentosZeradosSQL("ProfissionalID")
    GrupoID = AgendamentosZeradosSQL("GrupoID")
    EspecialidadeID = AgendamentosZeradosSQL("EspecialidadeID")


    ValorFinal = calcValorProcedimento(ProcedimentoID, TabelaID, UnidadeID, ProfissionalID, EspecialidadeID, GrupoID,0)

    %>
    <%=AgendamentoID%> --
    <%=ValorFinal%>
    <br>
    <%

    db.execute("UPDATE agendamentos SET ValorFinal="&treatvalzero(ValorFinal)&" WHERE id="&AgendamentoID)


AgendamentosZeradosSQL.movenext
wend
AgendamentosZeradosSQL.close
set AgendamentosZeradosSQL=nothing
%>