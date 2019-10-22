    <!--#include file="connect.asp"-->
<%

Unidades = ref("Unidades")

function formataNome(nome, primeiroNome)
    if instr(primeiroNome, " ")>0 then
        if primeiroNome then
            nome = split(nome," ")(0)
        end if
        if len(nome)>1 then
            formataNome = UCase(Left(nome,1)) & LCase(Right(nome, Len(nome) - 1))
        end if
    else
        formataNome=nome
    end if
end function

if ref("fStaID")<>"" then
    sqlSta = " AND a.StaID IN("& replace(ref("fStaID"), "|", "") &") "
end if
if ref("fProfissionalID")<>"0" then
    sqlProf = " AND a.ProfissionalID IN ("& ref("fProfissionalID") &") "
end if
if ref("fNomePaciente")<>"" then
    sqlPac = " AND pac.NomePaciente LIKE '%"& replace(ref("fNomePaciente"), " ", "%") &"%' "
end if
if ref("rTipoProcedimentoID")<>"" and ref("rTipoProcedimentoID")<>"0" then
    sqlTipoProc = " AND proc.TipoProcedimentoID="&ref("rTipoProcedimentoID")
end if
if ref("rGrupoID")<>"" and ref("rGrupoID")<>"0" then
    sqlGrupoProc = " AND proc.GrupoID="&ref("rGrupoID")
end if

if Unidades="" then
    Unidades = session("UnidadeID")&""
end if

sqlUnidade=" AND (l.UnidadeID IN("& replace(Unidades, "|", "") &") OR a.LocalID=0)"

sqlData = " a.Data>="&mydatenull(ref("DataDe"))&" and a.Data<="&mydatenull(ref("DataAte"))


%>
<div class="panel-body">
    <%
'    response.write("SELECT count(a.id)numero FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID WHERE "&sqlData&" AND StaID=7" & sqlProf&sqlUnidade)
    set NumeroConfirmadosSQL = db.execute("SELECT count(a.id)numero FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID WHERE "&sqlData&" AND a.sysActive=1 AND StaID=7" & sqlProf&sqlUnidade)
    sqlAgendados = "SELECT count(a.id)numero FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID WHERE "&sqlData&" AND a.sysActive=1 AND StaID IN (1,7)" & sqlProf&sqlUnidade

    set NumeroAgendadosSQL = db.execute(sqlAgendados)

    NumeroConfirmados=cint(NumeroConfirmadosSQL("numero"))
    NumeroAgendados=cint(NumeroAgendadosSQL("numero"))


    if NumeroAgendados=0 then
        Percentual = 0
    else
        Percentual = (NumeroConfirmados / NumeroAgendados) * 100
    end if

    if Percentual < 30 then
        PercentualClasse="danger"
    elseif Percentual < 70 then
        PercentualClasse="warning"
    else
        PercentualClasse="success"
    end if

    Percentual= round(Percentual, 0)
    %>
    <div class="row">
        <div class="col-md-4">

            <strong>Agendamentos a confirmar: <%=NumeroAgendados%></strong> <br>
            <strong>Agendamentos confirmados: <%=NumeroConfirmados%></strong> <br> <br>
            <div class="progress">
              <div class="progress-bar progress-bar-<%=PercentualClasse%>" role="progressbar" aria-valuenow="<%=Percentual%>"
              aria-valuemin="0" aria-valuemax="100" style="width:<%=Percentual%>%">
                <%=Percentual%>% Confirmada
              </div>
            </div>
        </div>

    </div>

    <table id="datatable2" class="table table-hover table-striped table-bordered">
        <thead>
            <tr>
                <th width="1%"></th>
                <th>Data</th>
                <th>Paciente</th>
                <th>Celular</th>
                <th>Profissional</th>
                <th>Procedimento</th>
                <th>Local</th>
                <th>Valor/Convênio</th>
                <th>Observações</th>
            </tr>
        </thead>
        <tbody>
            <%
            i=0
            LinhaProfissional = ""

            sqlConf = "select a.PacienteID, a.id, a.Notas, a.Data, a.id, a.ProfissionalID, a.LocalID, a.StaID, s.StaConsulta, a.Hora, pac.NomePaciente, pac.Cel1, trat.Tratamento, concat(if(isnull(pro.NomeSocial) or pro.NomeSocial='', pro.NomeProfissional, pro.NomeSocial)) NomeProfissional,"&_
                                   "esp.Especialidade, proc.NomeProcedimento, proc.TipoProcedimentoID, l.Nomelocal, eq.NomeEquipamento, a.rdValorPlano, a.ValorPlano, conv.NomeConvenio, tab.NomeTabela "&_
                                   ", (select Resposta from agendamentosrespostas where AgendamentoID=a.id limit 1) Resposta, (select EventoID from agendamentosrespostas where AgendamentoID=a.id limit 1) RespostaID "&_
                                   "FROM agendamentos a LEFT JOIN staconsulta s ON a.StaID=s.id LEFT JOIN pacientes pac ON pac.id=a.PacienteID "&_
                                   "LEFT JOIN profissionais pro ON pro.id=a.ProfissionalID "&_
                                   "LEFT JOIN tratamento trat ON trat.id=pro.TratamentoID "&_
                                   "LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN locais l ON l.id=a.LocalID "&_
                                   "LEFT JOIN equipamentos eq ON eq.id=a.EquipamentoID LEFT JOIN convenios conv ON conv.id=a.ValorPlano LEFT JOIN tabelaparticular tab ON tab.id=a.TabelaParticularID "&_
                                   "WHERE "&sqlData& sqlSta & sqlProf & sqlPac & sqlTipoProc & sqlGrupoProc & sqlUnidade &" AND a.sysActive=1 ORDER BY Data, ProfissionalID, Hora"

            set ag = db.execute(sqlConf)
            while not ag.eof
                i = i + 1
                if ag("rdValorPlano")="V" then
                    if  aut("valordoprocedimentoV")=0 then
                        Convenio = "Particular"
                    else
                        Convenio = "R$ "& fn(ag("ValorPlano"))
                    end if
                else
                    Convenio = ag("NomeConvenio")
                end if

                Celular=ag("Cel1")

                if Celular&""<>"" then
                    CelularFormatadado = "55"& replace(replace(replace(replace(Celular, "(", ""),")","")," ",""),"-","")
                end if

                PacientePrimeiroNome = formataNome(ag("NomePaciente"), True)

                if ag("NomeProfissional")&"" <> "" then
                    ProfissionalPrimeiroNome = ag("NomeProfissional")
                    ProfissionalPrimeiroNome=ag("Tratamento")&" "&ProfissionalPrimeiroNome
                end if

                if LinhaProfissional<> ag("ProfissionalID") then
                    LinhaProfissional=ag("ProfissionalID")
                    %>
<tr>
    <th colspan="9" class="text-center"><i><strong><%=ucase(ProfissionalPrimeiroNome)%></strong></i></th>
</tr>
                    <%
                end if

                DiaMensagem = "no dia "& ag("Data")
                if ag("Data")=dateadd("d", 1, date()) then
                    DiaMensagem="amanhã"
                elseif ag("Data")=date() then
                    DiaMensagem="hoje"
                end if

                Hora = ""

                if not isnull(ag("Hora")) then
                    Hora = left(formatdatetime(ag("Hora"),4),"5")
                end if

                TipoProcedimentoPronome = "a sua"

                if not isnull(ag("TipoProcedimentoID")) then
                    set TipoProcedimentoSQL = db.execute("SELECT id, TipoProcedimento FROM tiposprocedimentos WHERE id="&treatvalzero(ag("TipoProcedimentoID")))
                    if not TipoProcedimentoSQL.eof then
                        TipoProcedimento= lcase(TipoProcedimentoSQL("TipoProcedimento"))

                        if TipoProcedimentoSQL("id")>=3 then
                            TipoProcedimentoPronome="o seu"
                        end if
                    end if
                end if

                TextoWhatsApp = "Olá, "&PacientePrimeiroNome&"! Posso confirmar "&TipoProcedimentoPronome&" "&TipoProcedimento&" com "&ProfissionalPrimeiroNome&" "&DiaMensagem&" às "&Hora&"?"

                %>
                <tr data-id="<%=ag("id")%>">
                    <td>
                    <%
                    StatusSelect = "<div class='btn-group mb10'><button style='background-color:#fff' class='btn btn-sm dropdown-toggle' data-toggle='dropdown' aria-expanded='false'  > <span class='label-status'><img data-toggle='tooltip' title='"&ag("StaConsulta")&"' src='assets/img/"&ag("StaID")&".png' /></span>  <i class='fa fa-angle-down icon-on-right'></i></button><ul class='dropdown-menu dropdown-danger'>"
                    set StatusSQL=db.execute("SELECT id, StaConsulta FROM staconsulta WHERE id IN (1,11,7)")
                    while not StatusSQL.eof
                        Active=""
                        if StatusSQL("id")=ag("StaID") then
                            Active=" active "
                        end if

                        StatusSelect = StatusSelect&"<li class='"&Active&"'><a data-value='"&StatusSQL("id")&"' style='cursor:pointer' class='muda-status'><img src='assets/img/"&StatusSQL("id")&".png'> "&StatusSQL("StaConsulta")&"</a></option>"
                    StatusSQL.movenext
                    wend
                    StatusSQL.close
                    set StatusSQL = nothing
                    StatusSelect= StatusSelect&"</div></ul>"

                    response.write(StatusSelect)
                    %>
                    </td>
                    <td><a href="?P=Agenda-1&Pers=1&AgendamentoID=<%=ag("id")%>" target="_blank"><%= ag("Data") %> - <%=ft(ag("Hora"))%></a></td>
                    <td><a target="_blank" href="?P=Pacientes&Pers=1&I=<%= ag("PacienteID") %>"><%= ag("NomePaciente") %></a></td>
                    <td><a target="_blank" href="https://api.whatsapp.com/send?phone=<%=CelularFormatadado%>&text=<%=TextoWhatsApp%>"><%= Celular %></a>
                    <%
                    if not isnull(ag("Resposta")) then
                        'validar se a resposta é do tipo correto 
                        sqlmsg = "SELECT m.ConfirmarPorSMS FROM eventos_emailsms e INNER JOIN sys_smsemail m ON m.id=e.ModeloID WHERE e.id=" & ag("RespostaID")
                        set msgconfirma = db.execute(sqlmsg)
                        if isnull(ag("RespostaID")) or msgconfirma("ConfirmarPorSMS")="S" then
                        %>
                        <span data-toggle="tooltip" title="<%=ag("Resposta")%>"><i class='fa fa-envelope pink'></i></span>
                        <%
                        end if
                    end if
                    %>
                    </td>
                    <td><%= ag("NomeProfissional") %></td>
                    <td><small><%= ag("NomeProcedimento") %></small></td>
                    <td><small><%= ag("NomeLocal") %></small></td>
                    <td class="text-right"><%= Convenio %></td>
                    <td><small><%= ag("Notas") %></small></td>
                </tr>
                <%
            ag.movenext
            wend
            ag.close
            set ag = nothing
                %>
        </tbody>
        <tfoot>
            <tr>
                <th colspan="9"><%=i%> agendamentos</th>
            </tr>
        </tfoot>
    </table>
</div>
<script >

    $('[data-toggle="tooltip"]').tooltip();
</script>