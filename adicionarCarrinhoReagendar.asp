<!--#include file="connect.asp"-->
<% 
id = ref("id")
PacienteID = ref("PacienteID")
sessaoAgenda = ref("sessaoAgenda")
if id <> "" then 
    db.execute("update agendacarrinho set Arquivado = now() where sysUser = " & session("User")&" AND sessaoAgenda = '"&sessaoAgenda&"'")
    sqlCarrinho = "select id, PacienteID from agendacarrinho where AgendamentoID = " & id
    set carrinho = db.execute(sqlCarrinho)
    if not carrinho.eof then 
        db.execute("update agendacarrinho set sysUser = " & session("User") & ", sessaoAgenda = '"&sessaoAgenda&"', EspecialidadeID = null, ProfissionalID = null, Arquivado = null where id = " & carrinho("id"))
        %>
        location.href="./?P=MultiplaFiltros2&Pers=1&PaciID=<%=PacienteID%>&sessaoAgenda=<%=sessaoAgenda%>"
        <%
    else
        sqlAgendamento = "select * from agendamentos a where a.id = " & id
        set agendamento = db.execute(sqlAgendamento)
        if not agendamento.eof then 
            sqlAgendaCarrinho = "insert into agendacarrinho(PacienteID, TabelaID, ProcedimentoID, ComplementoID, Zona, AgendamentoID, sysUser, sessaoAgenda) " &_ 
                " values("&treatvalzero(agendamento("PacienteID"))&", "&treatvalzero(agendamento("TabelaParticularID"))&", "&treatvalzero(agendamento("TipoCompromissoID"))&", 0, '', "&id&", "&Session("User")&",'"&sessaoAgenda&"')"
            db.execute(sqlAgendaCarrinho)
            %>
            location.href="./?P=MultiplaFiltros2&Pers=1&PaciID=<%=PacienteID%>&sessaoAgenda=<%=sessaoAgenda%>"
            <%
        end if
    end if
end if
%>
