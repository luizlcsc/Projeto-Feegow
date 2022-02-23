<!--#include file="connect.asp"-->
<!--#include file="Classes/WhatsApp.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->
<%
PermitirSelecionarModeloWhatsApp=getConfig("PermitirSelecionarModeloWhatsApp")


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


StatusSelectDefault = "<div class='btn-group mb10'><button style='background-color:#fff' class='btn btn-sm dropdown-toggle' data-toggle='dropdown' aria-expanded='false'  > <span class='label-status'>var_icon</span>  <i class='fa fa-angle-down icon-on-right'></i></button><ul class='dropdown-menu dropdown-danger'>"
set StatusSQL=db_execute("SELECT id, StaConsulta FROM staconsulta WHERE id IN (101,6)")
while not StatusSQL.eof

    StatusSelectDefault = StatusSelectDefault&"<li class='var_active-"&StatusSQL("id")&"'><a data-value='"&StatusSQL("id")&"' onclick=""AlterarStatus('"&StatusSQL("id")&"','var_agendamento-id')"" style='cursor:pointer' class='muda-status'>"&imoon(StatusSQL("id"))& StatusSQL("StaConsulta")&"</a></option>"
StatusSQL.movenext
wend
StatusSQL.close
set StatusSQL = nothing
StatusSelectDefault= StatusSelectDefault&"</div></ul>"


function getStatusSelect(statusId, statusTitle, agendamentoId)
    tempStatusSelect = StatusSelectDefault
    tempStatusSelect = replace(tempStatusSelect, "var_active-"&status, "active")
    tempStatusSelect = replace(tempStatusSelect, "var_title", statusTitle)
    tempStatusSelect = replace(tempStatusSelect, "var_status-id", statusId)
    tempStatusSelect = replace(tempStatusSelect, "var_agendamento-id", agendamentoId)

    getStatusSelect = tempStatusSelect
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
     sqlGrupoProc = " AND proc.GrupoID IN ("&replace(ref("rGrupoID"), "|","")&")"
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
        <div class="col-md-8">
            <!--outras configuracoes-->

            <div class="row">
                <div class="col-md-3 col-md-offset-9">
                    <select data-toggle='tooltip' title='Comportamento para o envio de WhatsApp' name="TipoLinkWhatsApp" id="TipoLinkWhatsApp" class="form-control input-sm ">
                        <option value="whatsapp://send">WhatsApp Desktop</option>
                        <option value="https://web.whatsapp.com/send">WhatsApp Web</option>
                    </select>
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
                                   "esp.Especialidade, proc.NomeProcedimento, proc.id AS ProcedimentoID, tp.TipoProcedimento, proc.TipoProcedimentoID, a.TipoCompromissoID, l.Nomelocal, eq.NomeEquipamento, a.rdValorPlano, a.ValorPlano, conv.NomeConvenio, tab.NomeTabela "&_
                                   ", (select Resposta from agendamentosrespostas where AgendamentoID=a.id limit 1) Resposta, (select EventoID from agendamentosrespostas where AgendamentoID=a.id limit 1) RespostaID "&_
                                   "FROM agendamentos a LEFT JOIN staconsulta s ON a.StaID=s.id LEFT JOIN pacientes pac ON pac.id=a.PacienteID "&_
                                   "LEFT JOIN profissionais pro ON pro.id=a.ProfissionalID "&_
                                   "LEFT JOIN tratamento trat ON trat.id=pro.TratamentoID "&_
                                   "LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID "&_
                                   "LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID "&_
                                   "LEFT JOIN tiposprocedimentos tp ON tp.id=proc.TipoProcedimentoID "&_
                                   "LEFT JOIN locais l ON l.id=a.LocalID "&_
                                   "LEFT JOIN equipamentos eq ON eq.id=a.EquipamentoID "&_
                                   "LEFT JOIN convenios conv ON conv.id=a.ValorPlano LEFT JOIN tabelaparticular tab ON tab.id=a.TabelaParticularID "&_
                                   "WHERE "&sqlData& sqlSta & sqlProf & sqlPac & sqlTipoProc & sqlGrupoProc & sqlUnidade &" AND a.sysActive=1 ORDER BY Data, ProfissionalID, Hora"
            'dd(sqlConf)
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

                CelularFormatadado = ""
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
                TipoProcedimento= lcase(ag("TipoProcedimento"))
                if ag("TipoProcedimentoID")>=3 then
                    TipoProcedimentoPronome="o seu"
                end if

                'TextoWhatsApp = "Olá, "&PacientePrimeiroNome&"! Posso confirmar "&TipoProcedimentoPronome&" "&TipoProcedimento&" com "&ProfissionalPrimeiroNome&" "&DiaMensagem&" às "&Hora&"?"
                TextoWhatsApp = ""'centralWhatsApp(ag("id"),"")

                %>
                <tr data-id="<%=ag("id")%>">
                    <td>
                    <%
                    response.write(getStatusSelect(ag("StaID"), ag("StaConsulta"), ag("id")))

                    TagWhatsApp = False

                    if celularValido(Celular) then
                        TagWhatsApp= True
                    end if

                    %>
                    </td>
                    <td><a href="?P=Agenda-1&Pers=1&AgendamentoID=<%=ag("id")%>" target="_blank"><%= ag("Data") %> - <%=ft(ag("Hora"))%></a></td>
                    <td><a target="_blank" href="?P=Pacientes&Pers=1&I=<%= ag("PacienteID") %>"><%= ag("NomePaciente") %></a></td>
                    <td>
                    <%
                    if PermitirSelecionarModeloWhatsApp = 0 then
                    FormatTextoWhatsApp = replace(TextoWhatsApp, "'", "&apos;")
                    %>
                    <span <% if TagWhatsApp then %> style="color: #6495ed; text-decoration: underline; cursor: pointer;"  onclick='AlertarWhatsapp(`<%=CelularFormatadado%>`, `<%=FormatTextoWhatsApp%>`, `<%=ag("id")%>`, [<%=ag("id")&","&ag("PacienteId")&","&ag("ProfissionalID")&","&ag("LocalID")&","&ag("ProcedimentoID")%>])' <% end if%> ><span style="color:#06d755" id="wpp-<%=ag("id")%>"><% if TagWhatsApp then %><i class='far fa-whatsapp'></i><% end if %> </span> <%= Celular %></span>
                    <%
                    else
                        whatsAppFiltro_ProfissionalID = LinhaProfissional
                        whatsAppFiltro_TipoProcedimentoID = ag("TipoCompromissoID")

                        listPhonesSQL = " SELECT modelo.Descricao ,modelo.TextoSMS, eventos.Profissionais                                      "&chr(13)&_
                                        " FROM sys_smsemail modelo                                                                             "&chr(13)&_
                                        " INNER JOIN eventos_emailsms eventos ON eventos.ModeloID=modelo.id                                    "&chr(13)&_
                                        " WHERE                                                                                                "&chr(13)&_
                                        " (eventos.Profissionais LIKE '%|"&whatsAppFiltro_ProfissionalID&"|%' OR eventos.Profissionais='' OR eventos.Profissionais IS NULL) AND"&chr(13)&_
                                        " (eventos.Procedimentos LIKE '%|"&whatsAppFiltro_TipoProcedimentoID&"|%' OR eventos.Procedimentos LIKE '%|ALL|%'                          "&chr(13)&_
                                        "    OR   eventos.Procedimentos='' OR eventos.Procedimentos IS NULL)                                   "&chr(13)&_
                                        " AND eventos.`Status` LIKE '%|1|%' "&chr(13)&_
                                        " AND (eventos.Ativo=1) GROUP BY modelo.id"&_
                                        " UNION ALL "&_
                                        " SELECT se.Descricao, se.TextoSMS, ''  from configeventos ce  left join sys_smsemail se on se.id = ce.ModeloMsgWhatsapp  where ce.id = 1 "

                        set listPhones=db.execute(listPhonesSQL)
                        while not listPhones.eof
                            msgWhatsApp_titulo = listPhones("Descricao")
                            msgWhatsApp_conteudo = centralWhatsApp(ag("id"),listPhones("TextoSMS"))

                            msgWhatsApp_numero = Celular
                            msgWhatsApp_numeroFormatado = CelularFormatadado

                            whatsAppWeb_htmlContent = "<li><a href='https://api.whatsapp.com/send?phone="&msgWhatsApp_numeroFormatado&"&text="&msgWhatsApp_conteudo&"' target='_blank'>"&msgWhatsApp_titulo&"</a></li>"

                            if whatsAppWeb_html ="" then   
                                whatsAppWeb_html = whatsAppWeb_htmlContent
                            else
                                whatsAppWeb_html = whatsAppWeb_html&whatsAppWeb_htmlContent
                            end if
                        listPhones.movenext
                        wend
                        listPhones.close
                        set listPhones = nothing
                        response.write(msgTitle)
                        'response.Write("<hr>"&listPhonesSQL&"<hr>")
                        %>
                        <div class="dropdown">
                        <button id="dLabel" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <i class='far fa-whatsapp' style="color:#128C7E"></i> <%=msgWhatsApp_numero%>
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu" aria-labelledby="dLabel">
                            <%
                            response.write(whatsAppWeb_html)
                            whatsAppWeb_html = ""
                            %>
                        </ul>
                        </div>
                    <%    
                    end if
                    if not isnull(ag("Resposta")) then
                        'validar se a resposta é do tipo correto 
                        sqlmsg = "SELECT m.ConfirmarPorSMS FROM eventos_emailsms e INNER JOIN sys_smsemail m ON m.id=e.ModeloID WHERE e.id=" & ag("RespostaID")
                        set msgconfirma = db.execute(sqlmsg)
                        if isnull(ag("RespostaID")) or msgconfirma("ConfirmarPorSMS")="S" then
                        %>
                        <span data-toggle="tooltip" title="<%=ag("Resposta")%>"><i class='far fa-envelope pink'></i></span>
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

    if(localStorage.getItem("TipoLinkWhatsApp")){
        $("#TipoLinkWhatsApp").val(localStorage.getItem("TipoLinkWhatsApp"));
    }
</script>