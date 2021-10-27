<!--#include file="connect.asp"-->
<!--#include file="testeFuncao.asp"-->
<%
ProfissionalID = req("ProfissionalID")

NomeProfissional = ""
Especialidade = ""
CRM = ""
TEL = ""

set prof = db.execute("select NomeProfissional, especialidade, DocumentoConselho, Tel1, Tel2, Cel1, Cel2 from profissionais as p inner join especialidades as e ON e.id = p.EspecialidadeID where p.id="&ProfissionalID)
if not prof.eof then
	NomeProfissional = prof("NomeProfissional")
    Especialidade = prof("especialidade")
    CRM = prof("DocumentoConselho")
    if prof("Tel1") <> "" then
        TEL = prof("Tel1")
    elseif prof("Cel1") <> "" then
        TEL = prof("Cel1")
    elseif prof("Tel2") <> "" then
        TEL = prof("Tel2")
    else
        TEL = prof("Cel2")
    end if
end if
%>

<div class="panel">
    <div class="panel-heading">
	    <span class="panel-title"><i class="far fa-calendar"></i> Nome: <%=NomeProfissional%>
        </span>
    </div>
    <div class="panel-body">
        <div class="col-md-4">Especialidade: <%=Especialidade%></div>
        <div class="col-md-4">CRM: <%=CRM%></div>
        <div class="col-md-4">Telefone: <%=TEL %></div>

        <div class="col-md-12">
            <h3>Agendamentos</h3>
            <%
            set agendamento = db.execute("select l.NomeLocal, a.Tempo, a.Data dataagendamento, a.Hora as horaagendamento, p.NomePaciente, p.Nascimento " &_
                " ,a.TabelaParticularID, p.Tabela " &_ 
                " from agendamentos as a LEFT JOIN pacientes p ON p.id = a.PacienteID LEFT JOIN locais l ON l.id = a.LocalID where a.ProfissionalID = " & ProfissionalID & " ORDER BY a.Data DESC, a.Hora DESC")
            %>
            <table class="table table-bordered table-striped">
                <tr>
                    <th>Data</th>
                    <th>Dia da Semana</th>
                    <th>Intervalo</th>
                    <th>Tabela</th>
                    <th>Paciente</th>
                    <th>Unidade</th>
                </tr>
                <% 
                    while not agendamento.eof  
                    Tabela = null
                    if agendamento("TabelaParticularID") <> null then
                        Tabela = agendamento("TabelaParticularID")
                    elseif agendamento("Tabela") <> null  then
                        Tabela = agendamento("Tabela")
                    end if

                    NomeTabela = ""
                    if Tabela <> null then
                        set tbl = db.execute("select NomeTabela from tabelaparticular where id = " & Tabela)
                        if not tbl.eof  then 
                            NomeTabela = tbl("NomeTabela")
                        end if
                    end if
                %>
                <tr>
                    <td><%=agendamento("dataagendamento") %> - <%=formatdatetime(agendamento("horaagendamento"), 4) %></td>
                    <td><%=nomeDiaSemana(weekday(agendamento("dataagendamento"))) %></td>
                    <td><%=agendamento("Tempo") %></td>
                    <td></td>
                    <td><%=agendamento("NomePaciente") %> -  <%=agendamento("Nascimento") %></td>
                    <td><%=agendamento("NomeLocal") %></td>
                </tr>
                <% 
                agendamento.movenext 
                wend %>
            </table>
        </div>
    </div>
</div>