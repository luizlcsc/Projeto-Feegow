<!--#include file="connect.asp"-->
<%
De = req("De")
Ate = req("Ate")
ProcedimentosGrupos = req("ProcedimentosGrupos")
ProcedimentosTipos = req("ProcedimentosTipos")
AgendadoPor = req("AgendadoPor")
Tipo = req("Tipo")

if AgendadoPor<>"" then
    sqlAgendadoPor = " and lm.Usuario IN ("& AgendadoPor &") "
end if

db.execute("delete from cliniccentral.rel_agendamentosporusuario where sysUser="& session("User"))

set age = db.execute("insert into cliniccentral.rel_agendamentosporusuario (sysUser, Data, Hora, DataAG, HoraAG, Usuario, ProcedimentoIDage, AgendamentoID, UnidadeID, ProcedimentoID, ProfissionalID, TipoProcedimentoID, GrupoID, idAgendamento) select '"&session("User")&"', lm.DataHora, lm.DataHora, a.Data, a.Hora, lm.Usuario, lm.ProcedimentoID, lm.ConsultaID, ifnull(l.UnidadeID, 0) UnidadeID, a.TipoCompromissoID, a.ProfissionalID, proc.TipoProcedimentoID, proc.GrupoID, a.id idAgendamento from logsmarcacoes lm left join agendamentos a on a.id=lm.ConsultaID left join locais l on l.id=a.LocalID left join procedimentos proc on proc.id=a.TipoCompromissoID where date(DataHora) between "& mydatenull(De) &" and "& mydatenull(Ate) & sqlAgendadoPor &" and ARX='A' AND Sta IN (1,4,7) limit 10000")

if Tipo="S" then
    %><!--#include file="rAgendamentosPorUsuarioSintetico.asp"--><%
else
    %><!--#include file="rAgendamentosPorUsuarioAnalitico.asp"--><%
end if
%>