<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")
UnidadeID = req("UnidadeID")
LocalID = req("LocalID")
AgendamentoID = req("AgendamentoID")
update = ref("update")

if LocalID=""then
    LocalID = 0
end if

if update <> "" then
    updateSplt = split(update,",")
    For i=0 To ubound(updateSplt)
        updatesql= "update agendamentos set staid=4 where id="&updateSplt(i)
        db.execute(updatesql)

        logmsql = "select * from agendamentos where id="&updateSplt(i)
        set logagendamento = db.execute(logmsql)
        if not logagendamento.eof then
            paciente = logagendamento("PacienteID")
            profissional = logagendamento("ProfissionalID")
            procedimento = logagendamento("TipoCompromissoID")
            hora = ft(logagendamento("Hora"))
            consulta = logagendamento("id")

            DataHoraFeito = now()
            if session("FusoHorario")<>"" then
                FusoHorario = session("FusoHorario")
                if FusoHorario<>-180 and FusoHorario<>-120 and FusoHorario<>-60 then
                    FusoHorario = -180
                end if

                HorasDiferencaFusoHorario= ((FusoHorario / 60) + 3) * -1

                DataHoraFeito = dateadd("h", HorasDiferencaFusoHorario, DataHoraFeito)
            end if

            insertlog = "insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID, UnidadeID) values "&_
            "('"&paciente&"', '"&profissional&"', '"&procedimento&"', '"&DataHoraFeito&"', CURDATE() , '"&hora&"', '4', '"&session("User")&"', '0', 'checkin multiplo', 'R', '"&consulta&"', "&treatvalzero(session("UnidadeID"))&")"
            
            db.execute(insertlog)
        end if
    Next

else
    agendamentosSQL = "SELECT a.id, a.ProfissionalID, a.FormaPagto, a.LocalID, a.StaID, s.StaConsulta, a.Hora,a.HoraSta, pac.NomePaciente, pac.NomeSocial NomeSocialPaciente, IF(ISNULL(pro.NomeSocial) OR pro.NomeSocial='', pro.NomeProfissional, pro.NomeSocial) NomeProfissional, esp.Especialidade, proc.NomeProcedimento, l.Nomelocal, eq.NomeEquipamento, a.rdValorPlano, a.ValorPlano, conv.NomeConvenio, tab.NomeTabela"&_
                        " FROM agendamentos a"&_
                        " LEFT JOIN staconsulta s ON a.StaID=s.id"&_
                        " LEFT JOIN pacientes pac ON pac.id=a.PacienteID"&_
                        " LEFT JOIN profissionais pro ON pro.id=a.ProfissionalID"&_
                        " LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID"&_
                        " LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID"&_
                        " LEFT JOIN locais l ON l.id=a.LocalID"&_
                        " LEFT JOIN equipamentos eq ON eq.id=a.EquipamentoID"&_
                        " LEFT JOIN convenios CONV ON conv.id=a.ValorPlano"&_
                        " LEFT JOIN tabelaparticular tab ON tab.id=a.TabelaParticularID"&_
                        " WHERE a.Data= CURDATE() "&_
                        " AND a.StaID IN(1, 7, 15) "&_
                        " AND (l.UnidadeID="&UnidadeID&" OR a.LocalID="&LocalID&")"&_
                        " AND (pac.id = "&PacienteID&")"&_
                        " AND a.id <> "&AgendamentoID&" "&_
                        " AND a.sysActive = 1 "&_
                        " ORDER BY Hora"
    set agendamentos = db.execute(agendamentosSQL)

    
    
    if not agendamentos.eof then
        %>
    <div class="row">

        <div class="col-md-12">
            <p>Este paciente possui outros agendamentos nessa data. Deseja marca-los como aguardando?</p>

            <table class="table table-striped tableCheckin">
                <thead>
                    <tr class="success">
                        <th width="1%"><input type="checkbox" id="MarcarDesmarcarTodos" onchange="checkAll(this)"></th>
                        <th>Hora</th>
                        <th>Paciente</th>
                        <th>Profissional</th>
                        <th>Especialidade</th>
                        <th>Procedimento</th>
                        <th>Local</th>
                        <th>Valor/Convênio</th>
                    </tr>
                </thead>
                <tbody>
            <%
                while not agendamentos.eof
                    if agendamentos("rdValorPlano")="V" then
                        if  aut("valordoprocedimentoV")=0 then
                            Convenio = "Particular"
                        else
                            Convenio = "R$ "& fn(agendamentos("ValorPlano"))
                        end if
                    else
                        Convenio = agendamentos("NomeConvenio")
                    end if
                    %>
                    <tr>
                    <td><input type="checkbox" class="chkAg" value="<%=agendamentos("id")%>"></td>
                    <td><%= ft(agendamentos("Hora")) %></td>
                    <td><%= agendamentos("NomePaciente") %><br /><small><%=NomeSocialPaciente%></small></td>
                    <td><%= agendamentos("NomeProfissional") %></td>
                    <td><%= agendamentos("Especialidade") %></td>
                    <td><small><%= agendamentos("NomeProcedimento") %></small></td>
                    <td><small><%= agendamentos("NomeLocal") %></small></td>
                    <td class="text-right"><%= Convenio %>&nbsp; <%= sinalAgenda(agendamentos("FormaPagto"))%></td> 
                    </tr>
                    <%
                agendamentos.movenext
                wend
                agendamentos.close
                set agendamentos=nothing
            %>
                </tbody>
            </table>

        </div>
        <div class="col-md-2">
            <button type="button" class="btn btn-primary mt20" onclick="AplicarCheckinAgendamentos(true)"><i class="far fa-check"></i> Check in Múltiplo</button>
        </div>
        <div class="col-md-2">
            <button type="button" class="btn btn-success mt20" onclick="AplicarCheckinAgendamentos(false)"><i class="far fa-check"></i> Finalizar Check in</button>
        </div>
    </div>
    <script >
        function AplicarCheckinAgendamentos(checkmultiplo) {

            let checkboxes = document.getElementsByClassName('chkAg');
            let agendamentosIDs = "";

            if(checkboxes.length){
                for (var i = 0; i < checkboxes.length; i++) {
                    if(checkboxes[i].checked){
                        agendamentosIDs+=agendamentosIDs.length>0?",":"";
                        agendamentosIDs+=checkboxes[i].value;
                    }
                }
            }

            if(checkmultiplo){
                if(agendamentosIDs.length>0)  {
                    $.post("checkinmultiplo.asp", {
                        update:agendamentosIDs
                    }).done(function(data){
                        closeComponentsModal();
                        saveAgenda();
                    });
                }else{
                    alert("Selecione algum dos agendamentos");
                }
            }else{
                closeComponentsModal();
                saveAgenda();
            }
        }

        function checkAll(ele) {
            var checkboxes = document.getElementsByClassName('chkAg');
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].type == 'checkbox') {
                    checkboxes[i].checked = ele.checked;
                }
            }
        }
    </script>
    <%
    end if
end if
%>