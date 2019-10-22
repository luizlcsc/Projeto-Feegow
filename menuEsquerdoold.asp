<%
select case lcase(req("P"))
    case "home"
        if ref("Texto")<>"" then
            db_execute("insert into cliniccentral.pesquisa (LicencaID, UserID, Texto) values ("&replace(session("Banco"), "clinic", "")&", "&session("User")&", '"&ref("Texto")&"')")
            %>
            <script type="text/javascript">
                alert("Obrigado por sua interação!\n\n Logo responderemos a este chamado.");
            </script>
            <%
        end if

        %>
        <li class="sidebar-label"></li>
        <%
        if lcase(session("table"))="profissionais" then
            %>
        <li class="sidebar-label">Pacientes de Hoje</li>

        <%
            cpd = 0
            set pacDia = db.execute("select a.StaID, a.Hora, a.PacienteID, p.NomePaciente, ifnull(p.Foto, '') Foto from agendamentos a left join pacientes p on a.PacienteID=p.id where a.Data=curdate() and a.ProfissionalID="&session("idInTable")&" order by Hora")
            while not pacDia.eof
                cpd = cpd+1
                Foto = pacDia("Foto")
                if Foto="" then
                    Foto = "/assets/img/user.png"
                else
                    Foto = "/uploads/"& Foto
                end if

                if cpd>10 then
                    cpdH = " hidden"
                else
                    cpdH = ""
                end if
                %>
            <li class="pacdia <%=cpdH %>">
                <a href="./?P=pacientes&I=<%=pacDia("PacienteID") %>&Pers=1">
                    <%=imoon(pacDia("StaID")) %>
                    <span class="sidebar-title"> <%=left(pacDia("NomePaciente")&"", 40) %></span>
                <span class="sidebar-title-tray">
                <span class="label label-xs bg-white"><%=ft(pacDia("Hora")) %></span>
              </span>
                </a>
            </li>            <%
            pacDia.movenext
            wend
            pacDia.close
            set pacDia=nothing
            if cpd>10 then
                %>
            <li class="vertodos">
                <a href="javascript:void(0)" onclick="$('.vertodos').addClass('hidden'); $('.pacdia').removeClass('hidden');"><span class="fa fa-chevron-down"></span> <span class="sidebar-title"> Ver Todos</span>
                <span class="sidebar-title-tray">
                <span class="label label-xs bg-primary"><%= cpd %></span>
              </span>
                </a>
            </li>            <%
            end if
        end if
            %>
<hr class="short alt hidden-xs" />
        <li class="row sidebar-stat hidden-xs">
            <div class="col-sm-12">
                    <form method="post" action="">
              <div class="panel panel-tile text-center br-a br-grey">
                <div class="panel-body">
                  <h1 class="fs20 mt5 mbn">O que você deseja?</h1>
                  <h6 class="text-system">Interaja com nossa equipe de desenvolvimento.</h6>
                    <textarea required name="Texto" placeholder="Digite aqui suas sugestões, dúvidas e críticas." class="form-control" rows="5"></textarea>
                  
                </div>
                <div class="panel-footer br-t p12">
                  <span class="fs11">
                        <button class="btn btn-sm btn-block btn-primary"><i class="fa fa-send"></i> ABRIR CHAMADO</button>                    
                  </span>
                </div>
              </div>
                    </form>

                            <%
                    set pesquisa = db.execute("select * from cliniccentral.pesquisa where UserID="&session("User") &" and Fechado=0")

                    if not pesquisa.EOF then
                            %>
                    <div class="panel panel-tile text-center br-a br-grey">
                        <div class="panel-body">
                            <h4><strong>Seus chamados</strong>
                                <br />

                            </h4>
                            <ul class="list-group">
                            <%
                            while not pesquisa.EOF
                            %>
                                <li class="list-group-item">
                                    <em>"<%=trim(pesquisa("Texto"))%>"</em>
    <br>
                                        <small><em>Aberto em <strong><%=pesquisa("DataHora")%></strong></em></small>
<br>
<br>
                                    <%
                                    if pesquisa("Resposta1") <> "" then
                                        %>
                                        <small>Resposta em <%=pesquisa("DataResposta")%> :</small> <br>
                                        <strong>"<%=trim(pesquisa("Resposta1"))%>"</strong>
                                        <%
                                    end if
                                    %>

                                </li>
                                        <%
                                pesquisa.movenext
                                wend
                                pesquisa.close
                                set pesquisa = nothing
                            %>
                            </ul>
                        </div>
                    </div>
                    <%
                    end if
                    %>
            </div>

            <div class="panel hidden">
                <div class="panel-body">
                    <h4><strong></strong>
                        <br />
                        <small>Abra agora um chamado com nossa equipe de desenvolvimento, e faça conosco um Feegow cada vez melhor.</small>
                    </h4>
                        <br />
                </div>
            </div>
        </li>
        <%
    case "equipamentosalocados"
        %>
        <li class="sidebar-label pt20">Equipamento</li>
        <li class="row sidebar-stat">
            <div class="fs11 col-sm-12">
                <div class="input-group">
                    <span class="input-group-addon img-thumbnail" id="FotoProfissional" style="background-image: url(assets/img/user.png); background-size: 100%"></span>
                    <%
            if aut("|agendaV|")=1 then
                    %>
                    <select name="EquipamentoID" id="EquipamentoID" class="form-control select2-single">
                        <%
                set Prof = db.execute("select id, NomeEquipamento, '#CCC' Cor, UnidadeID from equipamentos where sysActive=1 order by NomeEquipamento")
                while not Prof.EOF
                        %>
                        <option style="border-left: <%=Prof("Cor")%> 10px solid; background-color: #fff;" value="<%=Prof("id")%>" <%=selected%>><%=ucase(Prof("NomeEquipamento"))%><%=getNomeLocalUnidade(Prof("UnidadeID"))%></option>
                        <%
                Prof.movenext
                wend
                Prof.close
                set Prof = nothing
                        %>
                    </select>
                    <span class="input-group-addon img-thumbnail" id="ObsAgenda" data-content="" title="" data-placement="right" data-rel="popover" class="btn btn-xs tooltip-info pull-right" data-original-title="Observações da Agenda">
                        <i class='fa fa-info-circle'></i>
                    </span>
                    <%
            end if
                    %>
                </div>
                <input type="hidden" name="Data" id="Data" value="<%=date()%>" />
            </div>
                <hr />
        </li>
         <li class="row sidebar-stat tray-bin btn-dimmer mb20">
        <%
                if aut("horarios")=1 then
                    %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:location.href='?P=Equipamentos&I='+$('#EquipamentoID').val()+'&Pers=1&Aba=Horarios';">
                            <span class="fa fa-calendar"></span>
                            <small class="">Grade</small>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
        <%
                end if
                %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:imprimir();">
                            <span class="fa fa-print"></span>
                            <span class="sidebar-title">Imprimir</span>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
		        <%
                if aut("|agendaI|")=1 then
                %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" id="AbrirEncaixe" href="javascript:void(0);">
                            <span class="fa fa-external-link"></span>
                            <span class="sidebar-title">Encaixe</span>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
		        <%
                end if
                if aut("bloqueioagendaI")=1 then
                %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:abreBloqueio(0, $('#Data').val(), '');">
                            <span class="fa fa-lock"></span>
                            <span class="sidebar-title">Bloqueio</span>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
                <%
		        end if
                    %>
            </li>
            <li class="row sidebar-stat">
                <div class="fs11 col-xs-12" id="divCalendario">
                    <div class="panel panel-body pn bs-component">
                        <%server.Execute("AgendamentoCalendarioEquipamento.asp")%>
                    </div>
                </div>
            </li>
<script type="text/javascript">
    $("#toggle_sidemenu_l").click(function () {
        setTimeout(function () { $(".select2-single").select2() }, 400);
        
    });
</script>
        <%
    case "agenda-1", "agenda-s"
        %>
        <li class="sidebar-label pt20">Profissional</li>
        <li class="row sidebar-stat">
            <div class="fs11 col-sm-12">
                <div class="input-group">
                    <span class="input-group-addon img-thumbnail" id="FotoProfissional" style="background-image: url(assets/img/user.png); background-size: 100%"></span>
                    <%
            if aut("|agendaV|")=1 then
                    %>
                    <select name="ProfissionalID" id="ProfissionalID" class="form-control select2-single">
                        <%
                set Prof = db.execute("select id, NomeProfissional, Cor from Profissionais where ativo='on' order by NomeProfissional")
                while not Prof.EOF
				    if lcase(session("table"))="profissionais" and session("idInTable")=Prof("id") then
					    selected = " selected=""selected"""
				    else
					    if session("UltimaAgenda")=cstr(Prof("id")) then
						    selected = " selected=""selected"""
					    else
						    selected = ""
					    end if
				    end if
                        %>
                        <option style="border-left: <%=Prof("Cor")%> 10px solid; background-color: #fff;" value="<%=Prof("id")%>" <%=selected%>><%=ucase(Prof("NomeProfissional"))%></option>
                        <%
                Prof.movenext
                wend
                Prof.close
                set Prof = nothing
                        %>
                    </select>
                    <span class="input-group-addon img-thumbnail" id="ObsAgenda" data-content="" title="" data-placement="right" data-rel="popover" class="btn btn-xs tooltip-info pull-right" data-original-title="Observações da Agenda">
                        <i class='fa fa-info-circle'></i>
                    </span>
                    <%
            else
                    %>
                    <br>
                    <%=nameInTable(session("User"))%>
                    <input type="hidden" name="ProfissionalID" id="ProfissionalID" value="<%=session("idInTable")%>" />
                    <%
            end if
                    %>
                </div>
                <input type="hidden" name="Data" id="Data" value="<%=date()%>" />
            </div>
                <hr class="hidden-xs" />
                <br class="visible-xs" />
        </li>
         <li class="row sidebar-stat tray-bin btn-dimmer mb20">
        <%
                if aut("horarios")=1 then
                    %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:location.href='?P=Profissionais&I='+$('#ProfissionalID').val()+'&Pers=1&Aba=Horarios';">
                            <span class="fa fa-calendar"></span>
                            <small class="">Grade</small>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
        <%
                end if
                %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:imprimir();">
                            <span class="fa fa-print"></span>
                            <span class="sidebar-title">Imprimir</span>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
		        <%
                if aut("|agendaI|")=1 then
                %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" id="AbrirEncaixe" href="javascript:void(0);">
                            <span class="fa fa-external-link"></span>
                            <span class="sidebar-title">Encaixe</span>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
		        <%
                end if
                if aut("bloqueioagendaI")=1 then
                %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:abreBloqueio(0, $('#Data').val(), '');">
                            <span class="fa fa-lock"></span>
                            <span class="sidebar-title">Bloqueio</span>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
                <%
		        end if
                    %>
            </li>
            <li class="row sidebar-stat">
                <div class="fs11 col-xs-12" id="divCalendario">
                    <div class="panel panel-body pn bs-component">
                        <%server.Execute("AgendamentoCalendario.asp")%>
                    </div>
                </div>
            </li>
            <li class="row sidebar-stat">
                <div class="fs11 col-md-12">
                    <div class="panel">
                        <div class="panel-heading">
                            <ul id="myTab" class="nav panel-tabs-border panel-tabs panel-tabs-left">
                                <li class="active">
                                    <a href="#notas" data-toggle="tab"><i class="green fa fa-file-text bigger-110"></i> Notas</a>
                                </li>
                                <li>
                                    <a href="#fila" data-toggle="tab" onclick="filaEspera('');"><i class="green fa fa-male bigger-110"></i> Espera</a>
                                </li>
                            </ul>
                        </div>
                        <div class="panel-body">
                            <div class="tab-content pn br-n">
                                <div id="notas" class="tab-pane in active">
                                    <textarea id="AgendaObservacoes" name="AgendaObservacoes" rows="7" class="form-control"></textarea>
                                </div>
                                <div id="fila" class="tab-pane">
                                    Carregando...
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </li>
<script type="text/javascript">
    $("#toggle_sidemenu_l").click(function () {
        setTimeout(function () { $(".select2-single").select2() }, 400);
        
    });
</script>


<%
    case "agendamultipla"
    %>
    <li class="sidebar-label pt20"></li>
    <li class="row sidebar-stat">
        <div class="fs11 col-xs-12" id="divCalendario">
            <div class="panel panel-body pn bs-component">
                <%server.Execute("AgendamentoCalendarioMultipla.asp")%>
            </div>
        </div>
    </li>

    <li class="row sidebar-stat mb20">
        <div class="fs11 col-md-12">
            <div class="panel">
                <div class="panel-heading">
                    <ul id="myTab" class="nav panel-tabs-border panel-tabs panel-tabs-left">
                        <li class="active">
                            <a href="#notas" data-toggle="tab"><i class="green fa fa-file-text bigger-110"></i> Notas</a>
                        </li>
                    </ul>
                </div>
                <div class="panel-body">
                    <div class="tab-content pn br-n">
                        <div id="notas" class="tab-pane in active">
                            <textarea id="AgendaObservacoes" name="AgendaObservacoes" rows="7" class="form-control"></textarea>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </li>
    <%
    case "agendamultiplaXXXXX"
        %>
            <form id="frmFiltros">
            <li class="sidebar-label pt20"></li>
            <li class="row sidebar-stat">
                <div class="fs11 col-xs-12" id="divCalendario">
                    <div class="panel panel-body pn bs-component">
                        <%server.Execute("AgendamentoCalendarioMultipla.asp")%>
                    </div>
                </div>
            </li>


            <li class="row sidebar-stat">
                <div class="fs11 col-sm-12">
                <%=quickField("select", "filtroProcedimentoID", "Procedimento", 12, "", "select '' id, '-' NomeProcedimento UNION ALL select id, NomeProcedimento from procedimentos where sysActive=1 and OpcoesAgenda!=3 order by NomeProcedimento", "NomeProcedimento", " empty ") %>
                </div>
            </li>
            <li class="row sidebar-stat">
                <div class="fs11 col-sm-12">
                <%=quickField("multiple", "Especialidade", "Especialidades", 12, "", "SELECT t.EspecialidadeID id, IFNULL(e.nomeEspecialidade, e.especialidade) especialidade FROM (	SELECT EspecialidadeID from profissionais WHERE ativo='on'	UNION ALL	select pe.EspecialidadeID from profissionaisespecialidades pe LEFT JOIN profissionais p on p.id=pe.ProfissionalID WHERE p.Ativo='on') t LEFT JOIN especialidades e ON e.id=t.EspecialidadeID WHERE NOT ISNULL(especialidade) GROUP BY t.EspecialidadeID ORDER BY especialidade", "especialidade", " empty ") %>
                </div>
            </li>
            <li class="row sidebar-stat">
                <div class="fs11 col-sm-12">
                <%=quickField("multiple", "Convenio", "Convênios", 12, "", "select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio", "NomeConvenio", " empty ") %>
                </div>
            </li>
            <li class="row sidebar-stat">
                <div class="fs11 col-sm-12">
                <%=quickField("empresaMulti", "Unidades", "Unidades", 12, "", "", "", "") %>
                </div>
            </li>



            <li class="row sidebar-stat">
                <div class="fs11 col-sm-12">
                <%=quickField("multiple", "Locais", "Visualizar Locais", 12, "", "SELECT id, NomeLocal FROM locais WHERE sysActive=1 ORDER BY NomeLocal", "NomeLocal", " empty ") %>
                </div>
            </li>

            <li class="row sidebar-stat">
                <div class="fs11 col-sm-12">
                <%=quickField("multiple", "Equipamentos", "Visualizar Equipamentos", 12, "", "SELECT id, NomeEquipamento FROM equipamentos WHERE sysActive=1 ORDER BY NomeEquipamento", "NomeEquipamento", " empty ") %>
                </div>
            </li>

                <input type="hidden" id="hData" name="hData" value="<%=date() %>" />
                </form>
        <%
    case "pacientes"
        if isnumeric(req("I")) and req("I")<>"" then
            %>
            <li class="sidebar-label pt20"></li>
            <li class="row sidebar-stat tray-bin stretch hidden-xs">
                <div class="fs11 col-md-12" id="divContador">
                    <%server.Execute("atender.asp")%>
                </div>
            </li>
            <li>
                <a data-toggle="tab" class="mainTab" href="#Dados">
                    <span class="blue fa fa-user bigger-110"></span>
                    <span class="sidebar-title">Dados Principais</span>
                </a>
            </li>
		    <%
		    if aut("formsae")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab" id="abaForms" href="#forms" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|AE|');">
                    <span class="fa fa-bar-chart bigger-110"></span>
                    <span class="sidebar-title">Anamnese e Evolu&ccedil;&otilde;es</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalae"></span>
                    </span>
                    <%
				    'set ct = db.execute("select count(id) total  from buiformspreenchidos where PacienteID="&PacienteID)
				    'response.Write( ct("Total") )
				    %>
                </a>
            </li>
		    <%
		    end if
		    if aut("formsl")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab" href="#forms" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|L|');">
                    <span class="fa fa-align-justify bigger-110"></span>
                    <span class="sidebar-title">Laudos e Formul&aacute;rios</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totallf"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
		    if aut("diagnosticos")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab" id="tabDiagnosticos" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Diagnostico|');">
                    <span class="fa fa-stethoscope bigger-110"></span>
                    <span class="sidebar-title">Diagn&oacute;sticos &raquo; <small>CID-10</small></span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totaldiagnosticos"></span>
                    </span>
                </a>
            </li>
            <%
		    end if
		    if aut("prescricoes")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab" id="abaPrescricoes" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Prescricao|');">
                    <span class="fa fa-flask bigger-110"></span>
                    <span class="sidebar-title">Prescri&ccedil;&otilde;es</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalprescricoes"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
		    if aut("atestados")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab" id="abaAtestados" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Atestado|');">
                    <span class="fa fa-file-text-o bigger-110"></span>
                    <span class="sidebar-title">Textos e Atestados</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalatestados"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
		    if aut("pedidosexame")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab" id="abaPedidos" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Pedido|');">
                    <span class="fa fa-hospital-o bigger-110"></span>
                    <span class="sidebar-title">Pedidos de Exame</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalpedidos"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if

		    if aut("formsae")=1 then
		    %>
		    <li>
                <a data-toggle="tab" class="tab" id="abaTimeline" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|Prescricao|');">
                    <span class="fa fa-line-chart bigger-110"></span>
                    <span class="sidebar-title">Linha do tempo</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary"></span>
                    </span>

                </a>
            </li>
		    <%
		    end if

		    if aut("imagens")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab" id="tabImagens" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Imagens|');">
                    <span class="fa fa-camera bigger-110"></span>
                    <span class="sidebar-title">Imagens</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalimagens"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
		    if aut("arquivos")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab" id="tabArquivos" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Arquivos|');">
                    <span class="fa fa-file bigger-110"></span>
                    <span class="sidebar-title">Arquivos</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalarquivos"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
		    if aut("agenda")=1 then
            'ODONTOGRAMA
            if (session("Banco")="clinic2901" or session("Banco")="clinic100000" or session("Banco")="clinic105") and 1=1 then
                %>
                <li>
                    <a data-toggle="tab" class="tab" href="#pacienteCalls" onclick="ajxContent('Odontograma', '<%=req("I")%>', '1', 'pacienteCalls')">
                        <span class="fa fa-life-bouy bigger-110"></span>
                        <span class="sidebar-title">Odontograma</span>
                    </a>
                </li>
                <%
            end if
		    %>
            <li>
                <a data-toggle="tab" class="tab" href="#pront" onclick="pront('HistoricoPaciente.asp?PacienteID=<%=req("I")%>');">
                    <span class="fa fa-calendar bigger-110"></span>
                    <span class="sidebar-title">Agendamentos</span>
                </a>
            </li>
		    <%
		    end if
		    if aut("recibos")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab" href="#divRecibos" onclick="pront('Recibos.asp?PacienteID=<%=req("I")%>')">
                    <span class="fa fa-edit bigger-110"></span>
                    <span class="sidebar-title">Recibos</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalrecibos"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
		    if aut("propostas")=1 then
		    %>
		    <li>
                <a data-toggle="tab" class="tab" id="tabPropostas" href="#divPropostas" onclick="pront('ListaPropostas.asp?PacienteID=<%=req("I")%>')">
                    <span class="fa fa-files-o"></span>
                    <span class="sidebar-title">Propostas</span>
                </a>
            </li>
            <%
		    end if
		    if aut("contapac")=1 then
		    %>
		    <li>
                <a data-toggle="tab" class="tab" id="tabExtrato" href="#divHistorico" onclick="ajxContent('divHistorico', '<%=req("I")%>&A=<%=req("A") %>', '1', 'pront')">
                    <span class="fa fa-money"></span>
                    <span class="sidebar-title">Conta</span>
                </a>
            </li>
            <%
		    end if
            if session("OtherCurrencies")="phone" then
                %>
                <li>
                    <a data-toggle="tab" class="tab" href="#pacienteCalls" onclick="pront('pacienteCalls.asp?I=<%= req("I") %>&Contato=3_<%=req("I")%>')">
                        <span class="fa fa-phone bigger-110"></span>
                        <span class="sidebar-title">Interações</span>
                    </a>
                </li>
                <%
            end if

        elseif req("Pers")="Follow" then 'Listando os pacientes
		    %>
            <li class="sidebar-label pt20">Outros pacientes</li>
            <li class="row sidebar-stat tray-bin btn-dimmer mb20">
            <%if req("sysActive")<>"" then %>
                <div class="col-xs-12">
                <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="?P=<%=req("P")%>&Pers=Follow"> ATIVOS</a>
                    </div>
            <%
            end if
            if req("sysActive")<>"-1" then
            %>
                <div class="col-xs-12">
                <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="?P=<%=request.QueryString("P")%>&Pers=Follow&sysActive=-1"> INATIVOS</a>
                    </div>
            <%
            end if
            if session("OtherCurrencies")="phone" then
                if req("sysActive")<>"-2" then
                %>
                <div class="col-xs-12">
                    <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="?P=<%=request.QueryString("P")%>&Pers=Follow&sysActive=-2"> LEADS</a>
                </div>
                <%
                end if
                if req("sysActive")<>"-3" then
                %>
                <div class="col-xs-12">
                <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="?P=<%=request.QueryString("P")%>&Pers=Follow&sysActive=-3"> PRÉ-CADASTROS</a>
                    </div>
                <%
                end if
            end if
            %>
            </li>
            <%
        end if
    case "newform"
        %>
        <li class="sidebar-label pt20"></li>
        <li class="row sidebar-stat tray-bin stretch">
            <div class="fs11 col-md-12">
                <%
                GrupoID = 0
                %>
                <!--#include file="menuForms.asp"-->
            </div>
        </li>
        <%

    case "busca"
        %>
        <li class="sidebar-label pt20"></li>
        <%
    case "procedimentos"
        if isnumeric(req("I")) and req("I")<>"" then
        %>
        <li class="sidebar-label pt20"></li>
        <li class="active">
            <a data-toggle="tab" href="#divCadastroPrincipal"><span class="fa fa-stethoscope bigger-110"></span> <span class="sidebar-title">Cadastro Principal</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divConfirmacoes"><span class="fa fa-mobile-phone"></span> <span class="sidebar-title">E-mails e SMS</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divOpcoesAgenda"><span class="fa fa-calendar"></span> <span class="sidebar-title">Opções de Agenda</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divMateriais" onclick="ajxContent('procedimentoskits', <%=req("I") %>, 1, 'procedimentoskits')"><span class="fa fa-medkit"></span> <span class="sidebar-title">Kits</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divEquipe" onclick="ajxContent('procedimentosdespesas', <%=req("I") %>, 1, 'divEquipe')"><span class="fa fa-credit-card"></span> <span class="sidebar-title">Despesas Anexas <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divEquipe" onclick="ajxContent('procedimentosequipe', <%=req("I") %>, 1, 'divEquipe')"><span class="fa fa-users"></span> <span class="sidebar-title">Equipe e Participantes</span></a>
        </li>

        <li>
            <a class="lembrete-pre-pos-menu" data-toggle="tab" href="#divLembretePrePos" onclick="ajxContent('procedimentoslembreteprepos', <%=req("I") %>, 1, 'divLembretePrePos')"><span class="fa fa-bell"></span> <span class="sidebar-title">Lembrete Pré/Pós</span></a>
        </li>
        <%
        end if
    case "profissionais"
        if isnumeric(req("I")) and req("I")<>"" then
            %>
            <li class="sidebar-label pt20"></li>
            <li<%=ativoCadastro%>>
                <a data-toggle="tab" href="#divCadastroProfissional"><span class="fa fa-user-md bigger-110"></span> <span class="sidebar-title">Cadastro do Profissional</span></a>
            </li>
            <%
		    if aut("horarios")=1 then
		    %>
            <li<%=ativoHorarios%>>
                <a data-toggle="tab" href="#divHorarios" onclick="ajxContent('Horarios<%if versaoAgenda()=1 then%>-1<%end if%>', <%=request.QueryString("I")%>, 1, 'divHorarios');">
            	    <span class="fa fa-clock-o"></span> <span class="sidebar-title">Hor&aacute;rios de Atendimento</span></a>
            </li>
            <%
		    end if
		    if (session("Admin")=1) or (lcase(request.QueryString("P"))=lcase(session("Table")) and session("idInTable")=ccur(request.QueryString("I")) and aut("senhapA")=1) or (aut("usuariosA")=1) then
		    %>
            <li>
                <a data-toggle="tab" href="#divAcesso" onclick="ajxContent('DadosAcesso&T=<%=request.QueryString("P")%>', <%=request.QueryString("I")%>, 1, 'divAcesso');">
            	    <span class="fa fa-key"></span> <span class="sidebar-title">Dados de Acesso</span></a>
            </li>
            <%
		    end if
		    if (session("Admin")=1) or (lcase(request.QueryString("P"))=lcase(session("Table")) and session("idInTable")=ccur(request.QueryString("I"))) then
		    %>
            <li>
                <a data-toggle="tab" href="#divAcesso" onclick="ajxContent('IntegracaoAgenda', <%=req("I")%>, 1, 'divAcesso');">
            	    <span class="fa fa-calendar"></span> <span class="sidebar-title">Integração Google</span></a>
            </li>
            <%
		    end if
		    if session("Admin")=1 then
		    %>
            <li>
                <a data-toggle="tab" href="#divPermissoes" id="gtPermissoes" onclick="ajxContent('Permissoes&T=<%=request.QueryString("P")%>', <%=request.QueryString("I")%>, 1, 'divPermissoes');">
            	    <span class="fa fa-lock"></span> <span class="sidebar-title">Permiss&otilde;es</span></a>
            </li>
            <%
		    end if
        end if
    case "funcionarios"
        if isnumeric(req("I")) and req("I")<>"" then
            %>
            <li class="sidebar-label pt20"></li>
            <li class="active">
                <a data-toggle="tab" href="#divCadastroFuncionario"><span class="fa fa-user"></span> <span class="sidebar-title">Cadastro do Funcion&aacute;rio</span></a>
            </li>
            <%
		    if (session("Admin")=1) or (lcase(request.QueryString("P"))=lcase(session("Table")) and session("idInTable")=ccur(request.QueryString("I")) and aut("senhapA")=1) or (aut("usuariosA")=1) then
		    %>
            <li>
                <a data-toggle="tab" href="#divAcesso" onclick="ajxContent('DadosAcesso&T=<%=request.QueryString("P")%>', <%=request.QueryString("I")%>, 1, 'divAcesso');">
                    <span class="fa fa-key"></span> <span class="sidebar-title">Dados de Acesso</span></a>
            </li>
            <%
		    end if
		    if session("Admin")=1 then
		    %>
            <li>
                <a data-toggle="tab" href="#divPermissoes" id="gtPermissoes" onclick="ajxContent('Permissoes&T=<%=request.QueryString("P")%>', <%=request.QueryString("I")%>, 1, 'divPermissoes');">
                    <span class="fa fa-lock"></span> <span class="sidebar-title">Permiss&otilde;es</span></a>
            </li>
            <%
		    end if
        end if
    case "convenios"
        if isnumeric(req("I")) and req("I")<>"" then
            %>
            <li class="sidebar-label pt20"></li>
            <li class="active">
                <a data-toggle="tab" href="#divCadastroConvenio"><span class="fa fa-credit-card"></span> <span class="sidebar-title">Cadastro do Conv&ecirc;nio</span></a>
            </li>
            <li>
                <a data-toggle="tab" href="#divValores" onclick="ajxContent('ConveniosValoresProcedimentos&ConvenioID=<%=request.QueryString("I")%>', '', '1', 'divValores')">
                    <span class="fa fa-usd"></span> <span class="sidebar-title">Valores por Procedimento</span></a>
            </li>
            <li><a data-toggle="tab" href="#divRegras" onclick="setTimeout(function(){$('.select2-single').select2()}, 1000)"><span class="fa fa-cogs"></span> <span class="sidebar-title">Regras</span></a></li>
            <li><a data-toggle="tab" href="#divWS"><span class="fa fa-plug"></span> <span class="sidebar-title">Webservices TISS</span></a></li>
            <%
        end if
    case "equipamentos"
        if isnumeric(req("I")) and req("I")<>"" then
            %>
            <li class="sidebar-label pt20"></li>
            <li class="active">
                <a data-toggle="tab" href="#divCadastroEquipamento">
                    <span class="fa fa-laptop"></span> <span class="sidebar-title">Cadastro do Equipamento</span></a>
            </li>
            <%
	        if aut("horarios")=1 then
	        %>
            <li<%=ativoHorarios%>>
                <a data-toggle="tab" href="#divHorarios" onclick="ajxContent('Horarios<%if versaoAgenda()=1 then%>-1<%end if%>', <%=req("I")*(-1)%>, 1, 'divHorarios');">
                    <span class="fa fa-clock-o"></span> <span class="sidebar-title">Grade de Hor&aacute;rios</span></a>
            </li>
            <%
	        end if
        end if
    case "configimpressos"
        %>
        <li class="sidebar-label pt20"></li>
        <li class="active">
            <a data-toggle="tab" href="#divPapelTimbrado"><span class="fa fa-file"></span><span class="sidebar-title"></span> Papel Timbrado</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divPrescricoes"><span class="fa fa-flask"></span><span class="sidebar-title"></span> Prescri&ccedil;&otilde;es</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divAtestados"><span class="fa fa-foursquare"></span><span class="sidebar-title"></span> Atestados</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divPedidos"><span class="fa fa-hospital-o"></span><span class="sidebar-title"></span> Pedidos de Exame</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divRecibos"><span class="fa fa-edit"></span><span class="sidebar-title"></span> Recibos Avulsos</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divRecibosIntegrados"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Recibos Integrados (A Receber)</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divRecibosIntegradosAPagar"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Recibos Integrados (A Pagar)</a>
        </li>
        <li><a data-toggle="tab" href="#divPropostas"><span class="fa fa-files-o"></span><span class="sidebar-title"></span> Propostas</a></li>
        <li><a data-toggle="tab" href="#divContratos" onclick="ajxContent('contratosmodelos', '', 'Follow', 'divContratos')"><span class="fa fa-file"></span><span class="sidebar-title"></span> Contratos</a></li>
        <%
    case "sys_financialcompanyunits", "empresa"
        %>
        <li class="sidebar-label pt20"></li>
        <li>
            <a href="./?P=empresa&Pers=1"><span class="fa fa-hospital-o"></span><span class="sidebar-title"></span> Empresa Principal</a>
        </li>
        <li>
            <a href="./?P=sys_financialcompanyunits&Pers=Follow"><span class="fa fa-hospital-o"></span><span class="sidebar-title"></span> Unidades / Filiais</a>
        </li>
        <%
    case "outrasconfiguracoes"
        %>
        <li class="sidebar-label pt20">Opções de Configurações</li>
        <li class="hidden">
            <a data-toggle="tab" href="#divGeral"><span class="fa fa-cog"></span> <span class="sidebar-title">Geral</span> </a>
        </li>
        <li class="active">
            <a data-toggle="tab" href="#divIP">
            	<span class="fa fa-street-view"></span> <span class="sidebar-title">Locais de Acesso</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divOmissao" onclick="ajxContent('omitirCampos', '', 1, 'divOmissao');">
            	<span class="fa fa-eye-slash"></span> <span class="sidebar-title">Omissão de Dados</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divCamposObrigatorios" onclick="ajxContent('camposObrigatorios', '', 1, 'divCamposObrigatorios');">
            	<span class="fa fa-asterisk"></span> <span class="sidebar-title">Campos Obrigatórios</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divOmissao" onclick="ajxContent('conectados', '', 1, 'divOmissao');">
            	<span class="fa fa-user"></span> <span class="sidebar-title">Usu&aacute;rios Conectados</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divPesquisaSatisfacao" onclick="ajxContent('PesquisaSatisfacao', '', 1, 'divPesquisaSatisfacao');">
            	<span class="fa fa-smile-o"></span> <span class="sidebar-title">Pesquisa de satisfação  <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divIntegracoes" onclick="ajxContent('configGerais', '', 1, 'divIntegracoes');">
            	<span class="fa fa-cogs"></span> <span class="sidebar-title">Configurações Gerais</span></a>
        </li>
        <%
    case "produtos"
        if req("Pers")="1" then
            %>
            <li class="sidebar-label pt20">Opções de Configurações</li>
            <li class="active">
                <a data-toggle="tab" href="#divCadastroProduto" onclick="atualizaLanctos();"><span class="fa fa-medkit"></span> <span class="sidebar-title"> Cadastro do Produto</span></a>
            </li>
            <li>
                <a data-toggle="tab" href="#divLancamentos" onclick="ajxContent('Lancamentos', <%=request.QueryString("I")%>, 1, 'divLancamentos');"><span class="fa fa-exchange icon-rotate-90"></span> <span class="sidebar-title">Movimentação</span></a>
            </li>
            <%
        end if
    case "financeiro", "invoice", "contascd", "recorrentes", "recorrente", "caixas", "repasses", "regerarrepasses", "extrato", "chequesrecebidos", "cartaocredito", "faturacartao", "detalhamentofatura", "buscapropostas", "gerarrateio", "propostas", "pacientespropostas", "repassesaconferir", "repassesconferidos", "arquivoretorno", "notafiscal"
        %>
        <li class="sidebar-label pt20">Financeiro</li>
    	<!--#include file="MenuFinanceiro.asp"-->
        <%
    case "estoque"
        %>
        <!--#include file="MenuEstoque.asp"-->
        <%
    case "relatorios"
        %>
        <li class="sidebar-label pt20">Relatórios</li>
        <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-user"></span>
                <span class="sidebar-title"> Pacientes </span>

                <span class="caret"></span>
            </a>

            <ul class="nav sub-nav">
                <li>
                    <a href="javascript:callReport('rpPerfil');">
                        <i class="fa fa-double-angle-right"></i>
                        Por Perfil
                    </a>
                </li>


                <li class="hidden">
                    <a href="javascript:callReport('CadastrosEfetuadosPorPeriodo');">
                        <i class="fa fa-double-angle-right"></i>
                        Por Data de Cadastro
                    </a>
                </li>

                <li>
                    <a href="javascript:callReport('rpSatisfacao');">
                        <i class="fa fa-double-angle-right"></i>
                        Satisfação dos Pacientes <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>

            </ul>
        </li>

        <li class="open hidden">
            <a href="#" class="dropdown-toggle">
                <i class="fa fa-stethoscope"></i>
                <span class="menu-text"> Prontuário </span>

                <b class="arrow icon-angle-down"></b>
            </a>

            <ul class="submenu" style="display:block">
                <li>
                    <a href="javascript:callReport('rpCID');">
                        <i class="fa fa-double-angle-right"></i>
                        Por CID
                    </a>
                </li>


                <li>
                    <a href="javascript:callReport('rpPrescricoes');">
                        <i class="fa fa-double-angle-right"></i>
                        Prescrições
                    </a>
                </li>

                <li>
                    <a href="javascript:callReport('rpForms');">
                        <i class="fa fa-double-angle-right"></i>
                        Filtros de Formulários
                    </a>
                </li>
            </ul>
        </li>
        <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-calendar"></span>
                <span class="sidebar-title"> Agenda </span>

                <span class="caret"></span>
            </a>

            <ul class="nav sub-nav">
                <%
                if aut("|agendaV|")=1 or lcase(session("Table"))="profissionais" then
                %>

                <li>
                    <a href="#" onClick="callReport('DetalhesAtendimentos');">
                        <i class="fa fa-double-angle-right"></i>
                        Agendamentos e Atendimentos
                    </a>
                </li>
                <li class="hidden">
                    <a href="#" onClick="callReport('rpAgendamentos');">
                        <i class="fa fa-double-angle-right"></i>
                        Consultas e Retornos <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>

                <li class="hidden">
                    <a href="#" onClick="callReport('rpCancelamentos');">
                        <i class="fa fa-double-angle-right"></i>
                        Cancelamentos <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>

                <%
                end if
                %>
                <%
                if aut("|agendaV|")=1 or lcase(session("Table"))="profissionais" then
                %>
                <li>
                    <a href="#" onClick="callReport('ProdutividadeAtendimento');">
                        <i class="fa fa-double-angle-right"></i>
                        Duração do Atendimento <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
                <%
                end if

                if aut("|relatoriosagendaV|")=1 then
                %>
                <li>
                    <a href="#" onClick="callReport('AgendamentosPorUsuario');">
                        <i class="fa fa-double-angle-right"></i>
                        Agendamentos por usuário <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
                <%
                end if
                %>
            </ul>
        </li>
        <%if aut("relatoriosfaturamentoV") then %>
        <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-area-chart"></span>
                <span class="sidebar-title"> Faturamento </span>

                <span class="caret"></span>
            </a>

            <ul class="nav sub-nav">
                <%
				if aut("|agendaV|")=1 or lcase(session("Table"))="profissionais" then
				%>
                <li>
                    <a href="#" onClick="javascript:callReport('ProducaoMedica');">
                        <i class="fa fa-double-angle-right"></i>
                        Produção - Analítico
                    </a>
                </li>
                <li>
                    <a href="#" onClick="javascript:callReport('ProducaoSintetico');">
                        <i class="fa fa-double-angle-right"></i>
                        Produção - Sintético
                    </a>
                </li>
                <li>
                    <a href="#" onClick="javascript:callReport('ProducaoExterna');">
                        <i class="fa fa-double-angle-right"></i>
                        Produção Externa <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
                <%
                if session("Banco")="clinic5445" or session("Banco")="clinic100000" then
                %>
                <li>
                    <a href="#" onClick="javascript:callReport('RepasseAnalitico');">
                        <i class="fa fa-double-angle-right"></i>
                        Repasse - Analítico <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
				<%
				end if
				end if
                if aut("guiasV") then
                    %>
                    <li>
                        <a href="#" onClick="javascript:callReport('GuiasPagas');">
                            <i class="fa fa-double-angle-right"></i>
                            Guias Pagas <span class="label label-system label-xs fleft">Novo</span>
                        </a>
                    </li>
                    <%
                end if
                if aut("relatoriosfaturamentoV")>0 then
                    %>
                    <li>
                        <a href="#" onClick="javascript:callReport('VendasParticular');">
                            <i class="fa fa-double-angle-right"></i>
                             Vendas - Particular <span class="label label-system label-xs fleft">Novo</span>
                        </a>
                    </li>
                    <li>
                        <a href="#" onClick="javascript:callReport('ServicosPorExecucao');">
                            <i class="fa fa-double-angle-right"></i>
                             Serviços por Execução <span class="label label-system label-xs fleft">Novo</span>
                        </a>
                    </li>
                    <li>
                        <a href="#" onClick="javascript:callReport('GuiasForaDeLote');">
                            <i class="fa fa-double-angle-right"></i>
                             Guias Fora de Lote <span class="label label-system label-xs fleft">Novo</span>
                        </a>
                    </li>
                    <%
                end if
				%>

                <li class="hidden">
                    <a href="javascript:callReport('rpAgrupado');">
                        <i class="fa fa-double-angle-right"></i>
                        Faturamento Agrupado
                    </a>
                </li>

                <li class="hidden">
                    <a href="javascript:callReport('FaturamentoSintetico');">
                        <i class="fa fa-double-angle-right"></i>
                        Faturamento Sintético
                    </a>
                </li>
            </ul>
        </li>
        <%end if %>
        <%if aut("relatoriosfinanceiroV") then %>
        <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-inbox"></span>
                <span class="sidebar-title"> Caixa </span>

                <span class="caret"></span>
            </a>

            <ul class="nav sub-nav">



                <li>
                    <a href="javascript:callReport('CaixaSintetico', '&U=<%=session("Unidades")%>&Cx=S');">
                        <i class="fa fa-double-angle-right"></i>
                        Caixa - Sintético
                    </a>
                </li>
                <li>
                    <a href="#" onClick="javascript:callReport('ParticularAnalitico');">
                        <i class="fa fa-double-angle-right"></i>
                        Caixa - Analítico
                    </a>
                </li>


                <li class="hidden">
                    <a href="javascript:callReport('rpDMed');">
                        <i class="fa fa-double-angle-right"></i>
                        D-Med
                    </a>
                </li>
            </ul>
        </li>
        <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-money"></span>
                <span class="sidebar-title"> Financeiro </span>

                <span class="caret"></span>
            </a>

            <ul class="nav sub-nav">
                <li>
                    <a href="javascript:callReport('rpFluxoCaixa');">
                        <i class="fa fa-double-angle-right"></i>
                        Fluxo de Caixa
                    </a>
                </li>

                <li class="hidden">
                    <a href="javascript:callReport('rpFluxoCaixaMensal');">
                        <i class="fa fa-double-angle-right"></i>
                        Fluxo de Caixa Mensal
                    </a>
                </li>

                <li>
                    <a href="javascript:callReport('CaixaSintetico', '&U=<%=session("Unidades")%>');">
                        <i class="fa fa-double-angle-right"></i>
                        Movimentação - Sintético
                    </a>
                </li>

                <li>
                    <a href="javascript:callReport('Plano', 'DESPESAS&U=<%=session("Unidades")%>');">
                        <i class="fa fa-double-angle-right"></i>
                        Análise de Despesas
                    </a>
                </li>
                <li>
                    <a href="javascript:callReport('AnaliseReceitas', 'RECEITAS&U=<%=session("Unidades")%>');">
                        <i class="fa fa-double-angle-right"></i>
                        Análise de Receitas
                    </a>
                </li>


                <li>
                    <a href="javascript:callReport('rpCreditos');">
                        <i class="fa fa-double-angle-right"></i>
                        Créditos Pendentes
                    </a>
                </li>

                <li>
                    <a href="javascript:callReport('rpDebitos');">
                        <i class="fa fa-double-angle-right"></i>
                        Débitos Pendentes
                    </a>
                </li>
                <li>
                    <a href="javascript:callReport('aExecutar');">
                        <i class="fa fa-double-angle-right"></i>
                        Serviços a Executar <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
                <li class=""hidden">
                    <a href="javascript:callReport('DRE');">
                        <i class="fa fa-double-angle-right"></i>
                        DRE <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
            </ul>
        </li>
        <%end if %>
        <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-bar-chart"></span>
                <span class="sidebar-title"> Formulários </span>

                <span class="caret"></span>
            </a>
            <ul class="nav sub-nav">
                <li>
                    <a href="javascript:callReport('rpLaudo');">
                        <i class="fa fa-double-angle-right"></i>
                        Laudos Sintético
                    </a>
                </li>
            </ul>
        </li>
        <%
        if aut("propostasV") then
        %>
        <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-files-o"></span>
                <span class="sidebar-title"> Propostas </span>

                <span class="caret"></span>
            </a>
            <ul class="nav sub-nav">
                <li>
                    <a href="javascript:callReport('propostasSintetico');">
                        <i class="fa fa-double-angle-right"></i>
                        Propostas Emitidas <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
            </ul>
        </li>
        <%
        end if
        if aut("estoqueV") then
        %>
        <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-medkit"></span>
                <span class="sidebar-title"> Estoque </span>

                <span class="caret"></span>
            </a>
            <ul class="nav sub-nav">
                <li>
                    <a href="javascript:callReport('rEstoquePosicao');">
                        <i class="fa fa-double-angle-right"></i>
                        Posição <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
                <li>
                    <a href="javascript:callReport('rEstoqueMovimentacao');">
                        <i class="fa fa-double-angle-right"></i>
                        Movimentação <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
            </ul>
        </li>
        <%
        end if
    case "listaespera"
        if session("Table")="profissionais" then
            if aut("|horariosA|")=1 then
            %>
            <li class="sidebar-label">LOCAL DE ATENDIMENTO</li>
            <li class="sidebar-widget">
                    <%
                    set ExcecaoSQL = db.execute("SELECT LocalID FROM assperiodolocalxprofissional WHERE ProfissionalID="&session("idInTable")&" AND CURDATE() BETWEEN DataDe AND DataA ORDER BY id DESC LIMIT 1")

                    if ExcecaoSQL.eof then
                        set GradeSQL = db.execute("SELECT LocalID FROM assfixalocalxprofissional WHERE ProfissionalID="&session("idInTable")&" AND DiaSemana = (DAYOFWEEK(CURDATE()))")

                        if GradeSQL.eof then
                            set HorarioInicioSQL = db.execute("SELECT a.LocalID FROM agendamentos a WHERE a.Data = CURDATE() AND a.ProfissionalID="&session("idInTable")&" ORDER BY a.Hora ASC LIMIT 1")
                            if not HorarioInicioSQL.eof then
                                LocalAtualID = HorarioInicioSQL("LocalID")
                            end if
                        else
                            LocalAtualID = GradeSQL("LocalID")
                        end if
                    else
                        LocalAtualID = ExcecaoSQL("LocalID")
                    end if

                    if LocalAtualID<>"" then
                        set LocalSQL = db.execute("SELECT l.NomeLocal FROM locais l WHERE l.id="&LocalAtualID)
                        if not LocalSQL.eof then
                            %>
                            Você está em <strong><%=LocalSQL("NomeLocal")%></strong>
                            <button class="btn-xs btn-link btn AlterarLocalAtual" type="button" title="Alterar local"><i class="fa fa-edit"></i> Alterar local</button>
                            <%
                        end if
                    end if
                    %>
            </li>
            <%
            end if
            set vcaobs = db.execute("select * from agendaobservacoes where ProfissionalID="& session("idInTable") &" and Data=curdate()")
            if not vcaobs.eof then
                %>
                <li class="sidebar-label">NOTAS DO DIA</li>
                <li class="sidebar-widget">
                    <%= replace(vcaobs("Observacoes"), chr(10), "<br>") %>
                </li>
                <%
            end if
        end if
end select


%>