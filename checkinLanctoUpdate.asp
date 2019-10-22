<!--#include file="connect.asp"-->

<%
on error resume next

valorAll = ref("valor")
procedimentoAll = ref("procedimento")
AgendamentoIDAll = ref("AgendamentoID")


AgendamentoIDs = split(AgendamentoIDAll, "|")
valors = split(valorAll, "|")
procedimentos = split(procedimentoAll, "|")

for i = 0 to ubound(AgendamentoIDs) 
    AgendamentoID = AgendamentoIDs(i)
    valor = valors(i)
    procedimento = procedimentos(i)
    if AgendamentoID <> "" then 
        spl2 = split(AgendamentoID, "_")
        ID = spl2(0)
        AgendamentoProcedimentoID = spl2(1)
        if ID<>"" and AgendamentoProcedimentoID = "" then
            set ag = db.execute("select a.id, a.ProfissionalID, a.Data, a.rdValorPlano, a.ValorPlano, a.PacienteID, TipoCompromissoID, a.EspecialidadeID, a.LocalID, a.TabelaParticularID FROM agendamentos a where a.id="& ID)
            if not ag.eof then
                db.execute("update  agendamentos set ValorPlano = "&treatvalzero(valor)&" where id="& ID)
            end if
        end if

        if AgendamentoProcedimentoID<>"" then
            set agProcedimento = db.execute("select a.rdValorPlano, a.ValorPlano, a.TipoCompromissoID FROM agendamentosprocedimentos a where a.id="& AgendamentoProcedimentoID)
            if not agProcedimento.eof then
                db.execute("update  agendamentosprocedimentos set ValorPlano = "&treatvalzero(valor)&" where id="& AgendamentoProcedimentoID)
            end if
        end if
    end if
next

%>