<!--#include file="connect.asp"-->
<%
PacienteID = ref("PacienteID")
CarrinhoID = ref("CarrinhoID")

set CarrinhoSQL = db.execute("SELECT id, ProcedimentoID FROM agendacarrinho WHERE id="&CarrinhoID&" AND Arquivado IS NULL")
if not CarrinhoSQL.eof then
    ProcedimentoID = CarrinhoSQL("ProcedimentoID")

    set AgendamentoSQL = db.execute("SELECT id, ProfissionalID, EspecialidadeID, TabelaParticularID FROM agendamentos WHERE PacienteID="&PacienteID&" AND "&_
     " TipoCompromissoID="&ProcedimentoID&" "&_
     "ORDER BY id DESC limit 1")
     
    if not AgendamentoSQL.eof then
        AgendamentoID=AgendamentoSQL("id")
        EspecialidadeID=AgendamentoSQL("EspecialidadeID")
        TabelaID=AgendamentoSQL("TabelaParticularID")
        ProfissionalID=AgendamentoSQL("ProfissionalID")

        db.execute("UPDATE agendacarrinho SET AgendamentoID="&AgendamentoID&", EspecialidadeID="&treatvalnull(EspecialidadeID)&", ProfissionalID="&treatvalnull(ProfissionalID)&", TabelaID="&treatvalnull(TabelaID)&" WHERE id="&CarrinhoID)

    end if
end if
%>