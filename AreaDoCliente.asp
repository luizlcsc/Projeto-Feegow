<!--#include file="connect.asp"-->
<!--#include file="Classes/Connection.asp"-->
<!--#include file="Classes/ApiClient.asp"-->
<!--#include file="Classes/Environment.asp"-->
<%
Set api = new ApiClient

ServerHost = getEnv("FC_MYSQL_HOST", "")
AppEnv = getEnv("FC_APP_ENV", "local")

if AppEnv="production" then
    set dbc = newConnection("clinic5459", ServerHost)

    LicencaID=replace(session("Banco"),"clinic","")
    'LicencaID=6118

    set PacienteSQL = dbc.execute("SELECT Cliente From cliniccentral.licencas WHERE id="&LicencaID)
    if not PacienteSQL.eof then
        ClienteID=PacienteSQL("CLiente")
    end if
end if
function getLastTickets(status)
    set getLastTickets = dbc.execute("SELECT t.*, ts.Classe ClasseStatus FROM tarefas t LEFT JOIN cliniccentral.tarefasstatus ts ON ts.id=t.StaPara WHERE t.Solicitantes LIKE CONCAT('%3_"&ClienteID&"%') ORDER BY t.DtAbertura DESC LIMIT 3")
end function
%>
<script type="text/javascript">
    $(".crumb-active a").html("Área do Cliente");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Estamos aqui para lhe ajudar");
    $(".crumb-icon a span").attr("class", "far fa-question-circle");
</script>

<div class="row mt30">
    <%
    User= session("User")
    if AppEnv="production" then
    'User=734
        set t = dbc.execute("select t.*, Date(t.Inicio) Data, time(t.Inicio) Hora from clinic5459.treinamentos t "&_
        "LEFT JOIN avaliacoes a ON a.RelativoID=t.id AND a.TipoID='treinamentos' where a.id is null AND isnull(t.Nota) and t.LicencaUsuarioID="& User)

    if not t.eof then
    %>
    <div class="col-md-12">
<div class="panel br-t bw5 br-success">
    <div class="panel-body" id="avaliacao-sucesso" style="display: none">
        <br>
        <div class="alert alert-default">
            <strong><i class="far fa-check"></i> Avaliação registrada com sucesso!</strong> <br> Agradecemos sua avaliação. Sua opinião é muito importante para nós :)
        </div>
    </div>
    <div class="panel-body " id="avaliacao-preencher">
    <%

    while not t.eof
        Data = t("Data")
        if Data=date() then
            Data = " hoje "
        elseif Data=date()-1 then
            Data = " ontem "
        else
            Data =  Data &" "
        end if
        Hora = ft(t("Hora"))
        %>
        <input type="hidden" id="RelativoID" value="<%=t("id")%>">
        <input type="hidden" id="AvaliacaoNota" value="">
        <div class="br-b">
            <h1>Você recebeu um treinamento</h1> <br>
        </div>

        <div class="row">
            <div class="table-layout bg-light p15">
              <div class="col-xs-3  va-m">
                 <img class="img-thumbnail" src="https://clinic7.feegow.com.br/<%= fotoInTable(t("AnalistaID")) %>" style="float: left;" />
                <span class="ml10"><strong>Analista:</strong> <%= nameInTable(t("AnalistaID")) %></span> <br>
                <span class="ml10"><strong>Data:</strong> <%= Data %></span> <br>
                <span class="ml10"><strong>Hora:</strong> <%= Hora %></span>

            </div>
            </div>

            <div class="col-md-12 br-t">
<br>
</div>
            <div class="col-md-10">
                <h4 class="col-md-12 blue">
                    Como foi sua experiência? <br>
                    <span style="cursor:pointer" id="stars-existing" class="starrr text-warning" data-rating=''></span>
                </h4>


                <h4 class="col-md-12 blue">
                    Deixe um comentário <br>

                    <div class="row"><%= quickfield("memo", "Observacoes", " ", 12, "", "", "", " placeholder='Ajude-nos a melhorar! Deixe suas observações, críticas e sugestões sobre o treinamento recebido.' rows='6' ") %></div>
                </h4>
            </div>
        </div>

        <div class="row">
            <div class="col-md-3">
                <div class="col-md-12">
                    <button type="button" onclick="SubmitAvaliacao()" class="btn btn-block btn-success">
                        <i class="far fa-save"></i> Salvar avaliação
                    </button>
                </div>
            </div>
        </div>

        <%
    t.movenext
    wend
    t.close
    set t = nothing
    %>
    </div>
</div>
</div>
<%
end if
end if
%>
          <!-- FAQ Left Column -->
          <div class="col-md-9">

            <div class="panel br-t bw5 br-grey">

              <div class="panel-body pn">
                <div class="p25 br-b">
                  <h2 class="fw200 mb20 mt10">Precisa de suporte? Estamos aqui para lhe ajudar.</h2>
                  <div class="input-group input-hero mb30 hidden">
                    <span class="input-group-addon">
                      <i class="far fa-search"></i>
                    </span>
                    <input type="text" id="icon-filter" class="form-control" placeholder="Procurar...">
                  </div>
                </div>
                <div class="table-layout bg-light">
                  <div class="col-xs-3 text-center va-m">
                    <span class="far fa-slideshare fs80 text-warning-light"></span>
                  </div>
                  <div class="col-xs-9 br-l">
                    <h5 class="text-muted pl5 mt20 mb20"> Videoaulas </h5>
                    <ul class="fs15 list-divide-items mb30">


                    <%
                    'set TopicosTreinamentoSQL = dbc.execute("SELECT * FROM treinamento WHERE Principal=1 AND sysActive=1 order by id DESC LIMIT 5")
                    set VideoAulaSQL = db.execute("SELECT * FROM cliniccentral.videoaula WHERE Principal=1 order by id DESC LIMIT 5")

                    while not VideoAulaSQL.eof
                    %>
                     <li>
                        <a target="_blank" class="link-unstyled" href="https://www.youtube.com/watch?v=<%=VideoAulaSQL("URL")%>" title="<%=VideoAulaSQL("Informacoes")%>">
                          <i class="far fa-film text-primary fa-lg pr10"></i> <%=VideoAulaSQL("Informacoes")%></a>
                      </li>
                    <%
                    VideoAulaSQL.movenext
                    wend
                    VideoAulaSQL.close
                    set VideoAulaSQL=nothing
                    %>

                    </ul>
                  </div>
                </div>
                <div class="p25 br-t">
                  <h5 class="text-muted mb20 mtn"> Perguntas recentes </h5>
                  <div class="panel-group accordion accordion-lg" id="accordion1">

                    <%
                        set RespostasSQL = dbc.execute("SELECT * FROM cliniccentral.perguntas WHERE sysActive=1 ORDER BY sysDate DESC LIMIT 5")

                        while not RespostasSQL.eof
                            idTopico = RespostasSQL("id")
                        %>
                      <div class="panel">
                        <div class="panel-heading">
                          <a class="accordion-toggle accordion-icon link-unstyled collapsed" data-toggle="collapse" data-parent="#accordion1" href="#<%=idTopico%>">
                            <i class="far fa-plus"></i> <%=RespostasSQL("DescricaoPergunta")%>
                            <span class="label hidden label-muted label-sm ph15 mt15 mr5 pull-right">189</span>
                          </a>
                        </div>
                        <div id="<%=idTopico%>" class="panel-collapse collapse" style="height: 0px;">
                          <div class="panel-body">
                              <%=RespostasSQL("Resposta")%>
                          </div>
                        </div>
                      </div>
                      <%
                      RespostasSQL.movenext
                      wend
                      RespostasSQL.close
                      set RespostasSQL=nothing
                      %>

                  </div>
                </div>
                <div class="table-layout br-t bg-light">
                  <div class="col-xs-6">
                    <h5 class="text-muted pl5 mt20 mb20"> Novidades </h5>
                    <ul class="fs15 list-divide-items mb30">
                    <%
                    set NovidadesSQL = db.execute("SELECT n.*, nt.TipoNovidade  " &_
                                                  "FROM cliniccentral.novidades n  " &_
                                                  "LEFT JOIN cliniccentral.novidades_permissoes np ON n.id = np.NovidadeID " &_
                                                  "LEFT JOIN cliniccentral.novidades_tipos nt ON nt.id = n.Tipo " &_
                                                  "WHERE n.Tipo IN (1, 3) AND Ativo=1 " &_
                                                  "GROUP BY n.id " &_
                                                  "ORDER BY n.DataHora DESC LIMIT 5")

                    while not NovidadesSQL.eof
                    %>
                      <li>
                        <span class="link-unstyled" href="#" title="">
                          <i class="far fa-exclamation-circle text-info fa-lg pr10"></i>
                          <%=NovidadesSQL("Titulo")%></span>
                      </li>
                  <%
                  NovidadesSQL.movenext
                  wend
                  NovidadesSQL.close
                  set NovidadesSQL=nothing
                  %>

                    </ul>
                  </div>
                  <div class="col-xs-6 br-l">
                    <h5 class="text-muted pl5 mt20 mb20"> Últimas correções </h5>
                   <ul class="fs15 list-divide-items mb30">
                       <%
                       set NovidadesSQL = db.execute("SELECT n.*, nt.TipoNovidade  " &_
                                                     "FROM cliniccentral.novidades n  " &_
                                                     "LEFT JOIN cliniccentral.novidades_permissoes np ON n.id = np.NovidadeID " &_
                                                     "LEFT JOIN cliniccentral.novidades_tipos nt ON nt.id = n.Tipo " &_
                                                     "WHERE n.Tipo IN (2,4) AND Ativo=1  " &_
                                                     "GROUP BY n.id " &_
                                                     "ORDER BY n.DataHora DESC LIMIT 5")

                       while not NovidadesSQL.eof
                       %>
                         <li>
                           <span class="link-unstyled" href="#" title="">
                             <i class="far fa-bug text-info fa-lg pr10"></i>
                             <%=NovidadesSQL("Titulo")%></span>
                         </li>
                     <%
                     NovidadesSQL.movenext
                     wend
                     NovidadesSQL.close
                     set NovidadesSQL=nothing
                     %>

                       </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- FAQ Right Column -->
          <div class="col-md-3">
            <%
            if aut("chamadossistemaI")=1 and session("ExibeChatAtendimento")=True then
            %>
            <div class="mb15">
              <button onclick="javascript:window.fcWidget.open();window.fcWidget.show();" type="button" class="btn btn-primary btn-block pv10 fw600 mb10"><i class="far fa-plus"></i> Abrir Chamado</button>
            </div>
            <%
            end if

            %>
            <div class="mb15">
              <button data-toggle="modal" data-target="#modal-horarios-atendimentos" type="button" class="btn btn-info btn-block pv10 fw600"><i class="far fa-headphones"></i> Entre em contato</button>
            </div>

<%
            if session("ExibeFaturas") and AppEnv="production" then
%>

            <div class="panel mb10">
              <div class="panel-heading">
                <span class="panel-icon">
                  <i class="far fa-barcode"></i>
                </span>
                <span class="panel-title"> Minhas Faturas</span>

                <span class="panel-controls">
                    <a class="panel-control-collapse hidden" href="#"></a>

                   <div >
                       <a href="./?P=ClExtratoSMS&Pers=1" class="btn btn-default btn-xs "><i class="far fa-envelope"></i> Extrato de SMS</a>
                   </div>

                </span>
              </div>


                <%

                i=0


                set FaturasSQL = dbc.execute("select * from clinic5459.sys_financialinvoices where CD ='C' AND AccountID = '"&ClienteID&"' AND AssociationAccountID=3 order by sysDate desc LIMIT 2")
                ExibeLinha=False
                if not FaturasSQL.eof then
                %>
                 <div class="panel-body text-muted p10">
                <%
                    FaturasQuitadasExibidas=0
                    while not FaturasSQL.eof
                        id=FaturasSQL("id")
                        Status=""
                        Valor=FaturasSQL("Value")
                        Vencimento=FaturasSQL("sysDate")


                        exibe="N"
                        CId = FaturasSQL("id")
                        %>
                        <!--#include file="minhasFaturasCalculo.asp"-->
                        <%
                        VencimentoOriginal=FaturasSQL("sysDate")
                        if cdate(Vencimento)<dateadd("d",4,date()) then
                            exibe="S"
                        end if
                        if  cdate(Vencimento) < cdate("2019-01-01") then
                            exibe="N"
                        end if

                        if exibe="S" then
                            'if classe="danger" then
                                ExibeLinha=True
                            'end if

                            boletoURL = "#"
                            set boleto = dbc.execute("select * from clinic5459.iugu_invoices WHERE BillID ='"& MovID&"' ORDER BY DataHora DESC Limit 1")
                            if not boleto.eof then
                                boletoURL = boleto("FaturaURL")
                            end if

                            IF boletoURL = "#" THEN
                                'response.write("select * from clinic5459.boletos_emitidos WHERE MovementID ="& MovID&" ORDER BY DataHora DESC Limit 1")
                                set boleto2 = dbc.execute("select * from clinic5459.boletos_emitidos WHERE MovementID ='"& MovID&"' ORDER BY DataHora DESC Limit 1")
                                if not boleto2.eof then
                                    boletoURL = boleto2("InvoiceURL")
                                end if
                            END IF
                    %>
                                <ul class="list-unstyled <% if i>0 then %>br-t<%end if%> pt10">
                                  <div class="mb10 " style="float: right;">
                                          <a target="_blank" <% if boletoURL="#" then %> disabled <%end if %> href="<%=boletoURL%>"  class="btn-block btn btn-default btn-xs <% if msg="QUITADA" then %> hidden <% end if %>"><i class="far fa-barcode"></i> Imprimir boleto</a>
                                          <a class="btn-block btn btn-primary btn-xs mt5" href="<%=api.getApiEndpoint("billing/detailing/by-invoice","ClientID="&ClienteID&"&InvoiceID="&id&"&licenca="&licencaId)%>"
                                          target="_blank" ><i class="far fa-info-circle"></i> Ver detalhamento</a>
                                    </div>
                                   <li>Valor:
                                     <strong class="text-dark"> R$ <%=fn(Valor)%></strong>
                                   </li>
                                   <li>Vencimento:
                                     <strong class="text-dark"> <%=Vencimento%></strong>
                                   </li>

                                   <li>Status:
                                    <span class="label arrowed arrowed-in arrowed-right-in label-sm label-<%=classe%>"><%=msg%></span>
                                   </li>


                                 </ul>
                      <%
                            end if
                        i=i+1
                      FaturasSQL.movenext
                      wend
                      FaturasSQL.close
                      set FaturasSQL=nothing

                        if not ExibeLinha then
                        %>
                        Nenhuma fatura pendente :)
                        <%
                        end if
                      %>
                   </div>
                      <%
                  else
                    %>
                 <div class="panel-body text-muted p10">
                    Nenhuma fatura pendente :)
                </div>
                    <%
                  end if
                  %>

            </div>
<%
            end if


            if aut("chamadossistemaV")=1 then
%>


            <div class="panel mb10 hidden">
              <div class="panel-heading">
                <span class="panel-icon">
                  <i class="far fa-life-ring"></i>
                </span>
                <span class="panel-title"> Seus últimos chamados</span>
              </div>


                <%

                i=0


                'set UltimosChamadosAbertosSQL = getLastTickets("")

                if false then
                %>
                 <div class="panel-body text-muted p10">
                <%
                    while not UltimosChamadosAbertosSQL.eof
                        id=UltimosChamadosAbertosSQL("id")
                        Status=UltimosChamadosAbertosSQL("StaPara")
                        Titulo=UltimosChamadosAbertosSQL("Titulo")
                        ClasseStatus=UltimosChamadosAbertosSQL("ClasseStatus")
                        DtAbertura=UltimosChamadosAbertosSQL("DtAbertura")
                    %>
                                <ul class="list-unstyled <% if i>0 then %>br-t<%end if%> pt10">
                                   <li>Título:
                                     <strong class="text-dark"> <%=Titulo%></strong>
                                   </li>
                                   <li>Abertura: <%=DtAbertura%></li>
                                   <li>Status:
                                     <strong class="text-<%=ClasseStatus%>"><%=Status%></strong>
                                   </li>
                                  <li>
                                  ID:
                                    <code>#<%=id%></code>

                                    <div style="float: right;">
                                        <a href="?P=tarefas&I=<%=id%>&Pers=1&Helpdesk=1" class="btn btn-link btn-xs"><i class="far fa-external-link"></i> Ver mais</a>
                                    </div>
                                 </ul>
                      <%
                        i=i+1
                      UltimosChamadosAbertosSQL.movenext
                      wend
                      UltimosChamadosAbertosSQL.close
                      set UltimosChamadosAbertosSQL=nothing

                      %>
                   </div>
                       <div class="list-group fs14 fw600">
                          <a class="text-center list-group-item" href="?P=listaTarefas&Pers=1&Helpdesk=1">
                            <span style="font-weight: 400">Ver todos os chamados</span></a>
                      </div>
                      <%
                  else
                    %>
                 <div class="panel-body text-muted p10">
                    Nenhum chamado aberto :)
                </div>
                    <%
                  end if
                  %>

            </div>

            <%
            end if


            if aut("autorizacaodeacessosuporte")=1 then
%>




                <%

                i=0


                set SolicitacaoAcessoSQL = dbc.execute("SELECT m.*, p.Foto, LEFT(p.NomeProfissional, 15) NomeProfissional, CONCAT(mm.Motivo, ' #',IFNULL(m.Ticket,'0'))DescricaoSolicitacao FROM cliniccentral.admin_senhas_master m "&_
                                                       "JOIN clinic5459.sys_users u ON u.id=m.usuarioId "&_
                                                       "JOIN clinic5459.profissionais p ON p.id=u.idInTable AND u.`Table`='profissionais' "&_
                                                       "JOIN admin_senhas_master_motivo mm ON mm.id=m.MotivoID "&_
                                                       " "&_
                                                       "WHERE m.LicencaID="&LicenseId&" "&_
                                                       "AND m.Status!='N/A' "&_
                                                       "AND DATE(m.DataHora)=CURDATE()")

                if not SolicitacaoAcessoSQL.eof then
                %>
                <div class="panel mb10">
                  <div class="panel-heading">
                    <span class="panel-icon">
                      <i class="far fa-life-ring"></i>
                    </span>
                    <span class="panel-title"> Solicitação de acesso</span>
                  </div>
                 <div class="panel-body text-muted p10">
                <%
                    while not SolicitacaoAcessoSQL.eof
                        SolicitacaoID=SolicitacaoAcessoSQL("id")
                        Status=SolicitacaoAcessoSQL("Status")
                        FotoAnalista=SolicitacaoAcessoSQL("Foto")
                        NomeAnalista=SolicitacaoAcessoSQL("NomeProfissional")
                        Titulo=SolicitacaoAcessoSQL("DescricaoSolicitacao")
                        ClasseStatus=" label label-warning"
                        DtAbertura=SolicitacaoAcessoSQL("DataHora")

                        if Status = "PENDENTE" then
                            ClasseStatus = " badge badge-warning"
                        end if
                        if Status = "APROVADO" then
                            ClasseStatus = " badge badge-success"
                        end if
                        if Status = "RECUSADO" then
                            ClasseStatus = " badge badge-danger"
                        end if

                        UrlFoto = "https://functions.feegow.com/load-image?licenseId=5459&folder=Perfil&file="&FotoAnalista

                    %>
                                <ul class="list-unstyled <% if i>0 then %>br-t<%end if%> pt10">
                                    <li>
                                        <img  class="img-thumbnail" src="<%= UrlFoto %>" style="float: left;height: 60px;border-radius: 50%;margin-right: 15px;" />
                                    </li>
                                   <li>Analista:
                                     <strong class="text-dark"> <%=NomeAnalista%></strong>
                                   </li>
                                   <li>Título:
                                     <strong class="text-dark"> <%=Titulo%></strong>
                                   </li>
                                   <li>Solicitação: <%=DtAbertura%></li>
                                   <li>Status:
                                     <strong class="text-<%=ClasseStatus%>"><%=Status%></strong>
                                   </li>
                                  <li>
                                    <%
                                    if Status="PENDENTE" then
                                    %>
                                      <div class="checkbox-custom checkbox-primary">
                                          <input type="checkbox" name="AceiteSolicitacao<%=SolicitacaoID%>" id="AceiteSolicitacao<%=SolicitacaoID%>" value="S">
                                          <label for="AceiteSolicitacao<%=SolicitacaoID%>" class="checkbox" style="font-weight: 500">
                                          Autorizo o acesso da equipe de apoio ao cliente da Feegow a minha licença mediante solicitação de ajuda feita previamente.
                                          </label>
                                      </div>

                                      <div class="text-center">
                                        <button onclick="AcaoSolicitacaoAcesso('<%=SolicitacaoID%>','CONFIRMAR')" class="btn btn-xs btn-outline-success" type="button">
                                            <i class="far fa-check"></i> Confirmar
                                        </button>

                                        <button onclick="AcaoSolicitacaoAcesso('<%=SolicitacaoID%>','RECUSAR')" class="btn btn-xs btn-outline-danger" type="button">
                                            <i class="far fa-times"></i> Recusar
                                        </button>
                                      </div>
                                    <%
                                    end if
                                    %>
                                  </li>
                                 </ul>
                      <%
                        i=i+1
                      SolicitacaoAcessoSQL.movenext
                      wend
                      SolicitacaoAcessoSQL.close
                      set SolicitacaoAcessoSQL=nothing

                      %>
                   </div>
               </div>
                      <%
                  end if
                  %>


            <%
            end if
            %>

            <div class="panel mb10">
              <div class="panel-heading">
                <span class="panel-icon">
                  <i class="far fa-life-ring"></i>
                </span>
                <span class="panel-title"> Recursos</span>
              </div>

              <div class="list-group fs14 fw600">
                <a class="list-group-item" href="mailto:sucesso@feegow.com.br">
                  &nbsp;<i class="far fa-envelope fa-fw text-primary"></i>&nbsp;&nbsp; Envie um e-mail</a>
                <a data-toggle="modal" data-target="#modal-horarios-atendimentos" class="list-group-item" href="#">
                  &nbsp;<i class="far fa-phone fa-fw text-primary"></i>&nbsp;&nbsp; Ligue para nós</a>

                  <a  class="list-group-item" href="https://www.youtube.com/channel/UChS9aIWBsx3Nvpgws0D0Txg/videos">
                  &nbsp;<i class="far fa-film fa-fw text-primary"></i>&nbsp;&nbsp; Vídeos explicativos</a>
                <a class="list-group-item hidden" href="#">
                  &nbsp;<i class="far fa-phone fa-fw text-primary"></i>&nbsp;&nbsp; Solicite uma ligação</a>
              </div>
            </div>

                  

        </div>

        <div class="col-md-12"> 
          <div class="text-center">
            <small style="color:#929292" id="version">-</small>
          </div>
        </div>  

<!-- Modal -->
<div id="modal-horarios-atendimentos" class="modal fade" role="dialog">
  <div class="modal-dialog">

    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Horários de atendimento</h4>
      </div>
      <div class="modal-body">
        <div class="row">
            <div class="col-md-12">
            <table class="table table-striped" border="0">
                <tbody>
                    <tr>
                        <td colspan="3">
                            <h4 class="no-margin blue">Telefônico <small>» seg. a sex. das 8h às 19h</small></h4>
                        </td>
                    </tr>
                    <tr>
                        <td valign="top"><span class="textotel"><strong>SP</strong> 11 3136.0479<br>

                            <strong>RJ</strong> 21 2018.0123
                            <br>
                            <strong>PR</strong> 41 2626.1434 </span>
                            <br>
                            <br>
                        </td>
                        <td class="textotel" valign="top">
                            <strong>RS</strong> 51 2626.3019<br>
                            <strong>BA</strong> 71 2626.0047</td>
                        <td valign="top" class="textotel"><strong>MG</strong> 31 2626.8010
                            <br>
                            <strong>DF</strong> 61 2626.1004<br>
                        </td>
                    </tr>
                </tbody>
            </table>
            </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
      </div>
    </div>

  </div>
</div>
<script src="assets/js/estrela.js" type="text/javascript"></script>
<script >
function SubmitAvaliacao() {
    var $avaliacaoPreencher = $("#avaliacao-preencher"),
        $avaliacaoSucesso = $("#avaliacao-sucesso");

    $.post("SalvaAvaliacao.asp", {
        RelativoID: $("#RelativoID").val(),
        TipoID: "treinamentos",
        Nota: $('#AvaliacaoNota').val(),
        Obs: $('#Observacoes').val(),
    })
    $avaliacaoPreencher.fadeOut(function() {
      $avaliacaoSucesso.fadeIn();
    });


}
$('#stars-existing').on('starrr:change', function(e, value){
  $('#AvaliacaoNota').val(value);
});

<%
if session("Versao")="" then
%>
$.get("./version-git.php",{auto:1}, function(version){
    version = JSON.parse(version);

    $("#version").html("Feegow Clinic : " + version);
});
<%
end if
%>

function AcaoSolicitacaoAcesso(SolicitacaoID, Acao){
    const AceiteOK = $("#AceiteSolicitacao"+SolicitacaoID).prop('checked')

    if(!AceiteOK && Acao === "CONFIRMAR"){
        showMessageDialog("Você precisa realizar o aceite para confirmar o acesso.");
    }else{
        $.post("AcaoSolicitacaoAcesso.asp", {SolicitacaoID: SolicitacaoID, Acao: Acao}, function(data){
            if(Acao === "CONFIRMAR"){
                showMessageDialog("Solicitação de acesso aprovada com sucesso.", "success");
            }
            if(Acao === "RECUSAR"){
                showMessageDialog("Solicitação de acesso recusada com sucesso.", "warning");
            }

            setTimeout(function(){
                location.reload();
            }, 500);
        });
    }
}

</script>
