<%
select case lcase(req("P"))

    case "checkin"
        StaChk = "|1|, |4|, |5|, |7|, |15|, |101|"

        if session("StatusCheckin")<>"" then
            StaChk=session("StatusCheckin")
        end if

        %>
        <li class="sidebar-label"></li>
        <li class="sidebar-label p20">
            <div class="panel mt15">
                <form id="frm-filtros">
                    <div class="panel-heading">
                        <span class="panel-title"><i class="fa fa-filter"></i> Filtros</span>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <%= quickfield("multiple", "fStaID", "Status", 12, StaChk, "select id, StaConsulta from staconsulta", "StaConsulta", "") %>
                            <%= quickfield("text", "fNomePaciente", "Paciente", 12, "", "", "", "") %>
                            <%= quickfield("simpleSelect", "fProfissionalID", "Profissional", 12, "", "select id, if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional from profissionais where sysActive=1 and ativo='on' order by if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial)", "NomeProfissional", "") %>
                        </div>
                    </div>
                    <div class="panel-footer">
                        <button class="btn btn-sm btn-primary">FILTRAR</button>
                    </div>
                </form>
            </div>
        </li>


<%
    case "confirmacaodeagendamentos"
        StaChk = "|1|,|116|"
        %>
        <li class="sidebar-label"></li>
        <li class="sidebar-label p20">
            <div class="panel mt15">
                <form id="frm-filtros">
                    <div class="panel-heading">
                        <span class="panel-title"><i class="fa fa-filter"></i> Filtros</span>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <%= quickfield("multiple", "fStaID", "Status", 12, StaChk, "select id, StaConsulta from staconsulta", "StaConsulta", "") %>
                        </div>
                        <div class="row">
			                <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 12, "|"&session("UnidadeID")&"|", "", "", "")%>
                            <%= quickfield("text", "fNomePaciente", "Paciente", 12, "", "", "", "") %>
                            <%= quickfield("simpleSelect", "fProfissionalID", "Profissional", 12, "", "select id, if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional from profissionais where sysActive=1 and ativo='on' order by if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial)", "NomeProfissional", "") %>
                            <%= quickfield("simpleSelect", "rTipoProcedimentoID", "Tipo do procedimento", 12, "", "select id, TipoProcedimento from tiposprocedimentos ", "TipoProcedimento", "") %>
                            <%= quickfield("multiple", "rGrupoID", "Grupo de procedimento", 12, "", "select id, NomeGrupo from procedimentosgrupos where sysActive=1", "NomeGrupo", "") %>
			                <%=quickField("datepicker", "DataDe", "De", 12, date(), "", "", "")%>
			                <%=quickField("datepicker", "DataAte", "Até", 12, dateAdd("d",1,date()), "", "", "")%>
                        </div>
                    </div>
                    <div class="panel-footer">
                        <button class="btn btn-sm btn-primary btn-block">FILTRAR</button>
                    </div>
                </form>
            </div>
        </li>


<%
    case "home", "areadocliente"
        if ref("Texto")<>"" then
            db_execute("insert into cliniccentral.pesquisa (LicencaID, UserID, Texto) values ("&replace(session("Banco"), "clinic", "")&", "&session("User")&", '"&ref("Texto")&"')")
            %>
            <script type="text/javascript">
                alert("Obrigado por sua interação!\n\n Logo responderemos a este chamado.");
            </script>
            <%
        end if

    if lcase(req("P"))="home" then
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
    end if
            %>

                    <script type="text/javascript">
                        function qualidometro(N)
                        {
                            $.get("Qualidometro.asp?N=" + N, function (data) { $("#divQualidometro").html( data ) })
                        }

                    </script>

<hr class="short alt hidden-xs" />
        <li class="row sidebar-stat hidden-xs">
            <div class="col-sm-12">
              <div class="panel">
                <div class="panel-heading text-center br-a br-grey">
                    <span class="panel-title">QUALIDÔMETRO</span>
                </div>
                <div class="panel-body text-center">
                  <h1 class="fs15 mt5 mbn">Como está sua satisfação com o Feegow Clinic?</h1>

                    <div class="row mt5" id="divQualidometro">
                        <% server.Execute("Qualidometro.asp") %>
                    </div>

                  
                </div>

                <% if true and recursoAdicional(12)<>4 and lcase(req("P"))="home" then %>
                <div class="panel-footer br-t p12">
                  <span class="fs11">
                        <button onclick="location.href='./?P=AreaDoCliente&Pers=1&Helpdesk=1';" class="btn btn-sm btn-block btn-primary"><i class="fa fa-question-circle"></i> ÁREA DO CLIENTE</button>
                  </span>
                </div>
                <% end if %>
              </div>


            </div>

<%
    if lcase(req("P"))="home" then
%>
            <div class="col-sm-12">
                <button onclick="getNews(0)" class="btn btn-sm btn-block btn-system"><i class="fa fa-plus"></i> VER NOVIDADES</button>
            </div>
            <div id="feedbackButton" style="margin-top: 10px; visibility: hidden" class="col-sm-12">
                <button onclick="openPendingTables()" class="btn btn-sm btn-block btn-warning"><i class="fa fa-warning"></i> VER ALTERAÇÕES</button>
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
            <%
              end if
            %>
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
            if aut("|agendaequipamentosV|")=1 then
                    %>
                    <select name="EquipamentoID" id="EquipamentoID" class="form-control select2-single">
                        <%
                set Prof = db.execute("select id, NomeEquipamento, '#CCC' Cor, UnidadeID from equipamentos where ativo='on' and sysActive=1 order by NomeEquipamento")
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
                    <div class="col-xs-12">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:location.href='?P=Equipamentos&I='+$('#EquipamentoID').val()+'&Pers=1&Aba=Horarios';">
                            <span class="fa fa-calendar"></span>
                            <small class="">Grade</small>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
        <%
                end if
                if 1=2 then
                %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:imprimir();">
                            <span class="fa fa-print"></span>
                            <span class="sidebar-title">Imprimir</span>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
		        <%
		        end if
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
                        sqlAtivo=" AND ativo='on'"
                        if session("Admin")=1 and session("Banco")="clinic5445" then
                            sqlAtivo=""
                        end if



                    sqlLimitarProfissionais =""
                    if lcase(session("table"))="funcionarios" then
                        set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
                        if not FuncProf.EOF then
                           profissionais=FuncProf("Profissionais")
                           if not isnull(profissionais) and profissionais<>"" then
                               profissionaisExibicao = replace(profissionais, "|", "")
                               sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
                           end if
                        end if
                    elseif lcase(session("table"))="profissionais" then
                        set FuncProf = db.execute("SELECT AgendaProfissionais FROM profissionais WHERE id="&session("idInTable"))

                        if not FuncProf.EOF then
                            profissionais=FuncProf("AgendaProfissionais")
                            if not isnull(profissionais) and profissionais<>"" then
                               profissionaisExibicao = replace(profissionais, "|", "")
                               sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
                           end if
                        end if
                    end if


                    set Prof = db.execute("select id, LEFT(NomeProfissional, 20)NomeProfissional, NomeSocial, Cor, Ativo from profissionais where (NaoExibirAgenda != 'S' OR NaoExibirAgenda is null OR NaoExibirAgenda='') AND sysActive=1  "&sqlAtivo&" "&sqlLimitarProfissionais&" order by Ativo DESC,NomeProfissional")
                    while not Prof.EOF
                    if req("ProfissionalID")="" then
				        if lcase(session("table"))="profissionais" and session("idInTable")=Prof("id") then
					        selected = " selected=""selected"""
				        else
					        if session("UltimaAgenda")=cstr(Prof("id")) then
						        selected = " selected=""selected"""
					        else
						        selected = ""
					        end if
				        end if
                    else
                        if req("ProfissionalID")=Prof("id")&"" and req("ProfissionalID")<>"" then
                            selected = " selected=""selected"" "
                        else
                            selected = ""
                        end if
                    end if

				    optionAtivo = ""
				    if Prof("Ativo")<>"on" then
				        optionAtivo="INATIVO - "
				    end if

				    NomeProfissional = Prof("NomeProfissional")
				    if Prof("NomeSocial")&"" <> "" then
				         NomeProfissional=Prof("NomeSocial")
				    end if

                        %>
                        <option style="border-left: <%=Prof("Cor")%> 10px solid; background-color: #fff;" value="<%=Prof("id")%>" <%=selected%>><%=optionAtivo%><%=ucase(NomeProfissional)%></option>
                        <%
                Prof.movenext
                wend
                Prof.close
                set Prof = nothing
                        %>
                    </select>
                    <span class="input-group-addon img-thumbnail" onclick="oa( $('#ProfissionalID').val() )" title="Observações da Agenda" style="cursor:pointer">
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
            if req("Data")="" then
                iniData = date()
            else
                iniData = req("Data")
            end if
                    %>
                </div>
                <input type="hidden" name="Data" id="Data" value="<%= iniData %>" />
            </div>
                <hr class="hidden-xs" />
                <br class="visible-xs" />
        </li>
         <li class="row sidebar-stat tray-bin btn-dimmer mb20">
        <%
                if aut("horarios")=1 then
                    %>
                    <div class="col-xs-<%if req("P")<>"Agenda-S" then %>6<% else%>12<%end if%>">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:location.href='?P=Profissionais&I='+$('#ProfissionalID').val()+'&Pers=1&Aba=Horarios';">
                            <span class="fa fa-calendar"></span>
                            <small class="">Grade</small>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
        <%
                end if
                if req("P")<>"Agenda-S" then
                %>
                    <div class="col-xs-6">
                        <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:imprimir();">
                            <span class="fa fa-print"></span>
                            <span class="sidebar-title">Imprimir</span>
                            <span class="sidebar-title-tray"></span>
                        </a>
                    </div>
		        <%
		        end if
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
		        if req("P")<>"Agenda-S" then
                    if aut("agendaaltmultA") then
                    %>
                        <div class="col-xs-12">
                            <a class="btn btn-primary btn-gradient btn-alt btn-block item-active" href="javascript:altMult($('#ProfissionalID').val(), $('#Data').val());">
                                <span class="fa fa-exchange"></span>
                                <span class="sidebar-title">Alterações em massa</span>
                                <span class="sidebar-title-tray"></span>
                            </a>
                        </div>

                    <%
                    end if
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
    <%
                    if aut("|agendaI|")=1 and (session("Banco")<>"clinic5760" and session("Banco")<>"clinic6118" and session("Banco")<>"clinic105") then
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
                    if aut("bloqueioagendaI")=1  then
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
            <div class="col-md-12 mt10 fs11 checkbox-custom checkbox-warning">
                <input type="checkbox" id="HVazios" value="S" onclick="loadAgenda()" name="HVazios" <% if session("HVazios")="S" then response.write(" checked ") end if %> /><label for="HVazios"> Somente horários vazios</label>
            </div>
        <div class="fs11 col-xs-12 mt10" id="divCalendario">
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
                         <li>
                            <a href="#fila" data-toggle="tab" onclick="filaEspera('',0);"><i class="green fa fa-male bigger-110"></i> Espera</a>
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
                <%=quickField("multiple", "Equipamentos", "Visualizar Equipamentos", 12, "", "SELECT id, NomeEquipamento FROM equipamentos WHERE ativo='on' and sysActive=1 ORDER BY NomeEquipamento", "NomeEquipamento", " empty ") %>
                </div>
            </li>

                <input type="hidden" id="hData" name="hData" value="<%=date() %>" />
                </form>
        <%
    case "locais", "locaisgrupos", "mapasalas"

    %>
    <li>
        <a href="?P=Locais&Pers=Follow"><span class="fa fa-map-marker bigger-110"></span> <span class="sidebar-title">Locais de Atendimento</span></a>
    </li>
    <li>
        <a href="?P=LocaisGrupos"><span class="fa fa-crosshairs bigger-110"></span> <span class="sidebar-title">Grupos de Locais</span></a>
    </li>
    <li>
        <a href="?P=MapaSalas&Pers=1"><span class="fa fa-street-view bigger-110"></span> <span class="sidebar-title">Mapa de Locais</span></a>
    </li>
    <%
    case "eventos_emailsms", "sys_smsemail", "configeventos"
        %>
        <li>
            <a href="?P=eventos_emailsms&Pers=Follow"><span class="fa fa-calendar bigger-110"></span> <span class="sidebar-title">Eventos</span></a>
        </li>
        <%
        if aut("sys_smsemail")=1 then
        %>
        <li>
            <a href="?P=sys_smsemail&Pers=Follow"><span class="fa fa-files-o bigger-110"></span> <span class="sidebar-title">Modelos</span></a>
        </li>
        <%
        end if
        if session("Admin")=1 then
        %>
        <li>
            <a href="?P=ConfigEventos&Pers=1"><span class="fa fa-cogs bigger-110"></span> <span class="sidebar-title">Configurações</span></a>
        </li>

        <%
        end if

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
                <a data-toggle="tab" class="mainTab menu-aba-pacientes-dados-principais" href="#Dados">
                    <span class="blue fa fa-user bigger-110"></span>
                    <span class="sidebar-title">Dados Principais</span>
                </a>
            </li>
            <% IF session("Banco")="clinic5459" or session("Banco")="clinic100000" or session("Banco")="clinic105" THEN %>
             <li>
                <a data-toggle="tab" class="tab menu-aba-pacientes-laudos-formularios" href="#resumoclinico" onclick="loadResumoClinico()">
                    <span class="fa fa-heart-o bigger-110"></span>
                    <span class="sidebar-title">Resumo Clínico</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totallf"></span>
                    </span>
                </a>
            </li>
            <% END IF %>
		    <%
            if aut("aso")=1 and false then
		    %>
            <li>
                <a data-toggle="tab" class="tab" id="abaForms" href="#forms" onclick="pront('timeline.asp?L=<%=session("Banco")%>&PacienteID=<%=req("I")%>&Tipo=|AsoPaciente|');">
                    <span class="fa fa-bar-chart bigger-110"></span>
                    <span class="sidebar-title">Medicina ocupacional</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalaso"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
		    if aut("formsae")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab menu-aba-pacientes-anamneses" id="abaForms" href="#forms" onclick="pront('timeline.asp?L=<%=session("Banco")%>&PacienteID=<%=req("I")%>&Tipo=|AE|');">
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
                <a data-toggle="tab" class="tab menu-aba-pacientes-laudos-formularios" href="#forms" onclick="pront('timeline.asp?L=<%=session("Banco")%>&PacienteID=<%=req("I")%>&Tipo=|L|');">
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
                <a data-toggle="tab" class="tab menu-aba-pacientes-diagnosticos" id="tabDiagnosticos" href="#pront" onclick="pront('timeline.asp?L=<%=session("Banco")%>&PacienteID=<%=req("I")%>&Tipo=|Diagnostico|');">
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
                <a data-toggle="tab" class="tab menu-aba-pacientes-prescricoes" id="abaPrescricoes" href="#pront" onclick="pront('timeline.asp?L=<%=session("Banco")%>&PacienteID=<%=req("I")%>&Tipo=|Prescricao|');">
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
                <a data-toggle="tab" class="tab menu-aba-pacientes-textos-e-atestados" id="abaAtestados" href="#pront" onclick="pront('timeline.asp?L=<%=session("Banco")%>&PacienteID=<%=req("I")%>&Tipo=|Atestado|');">
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
                <a data-toggle="tab" class="tab menu-aba-pacientes-pedidos-de-exame" id="abaPedidos" href="#pront" onclick="pront('timeline.asp?L=<%=session("Banco")%>&PacienteID=<%=req("I")%>&Tipo=|Pedido|');">
                    <span class="fa fa-hospital-o bigger-110"></span>
                    <span class="sidebar-title">Pedidos de Exame</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalpedidos"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
            recursoPermissaoUnimed = recursoAdicional(12)

		    if recursoPermissaoUnimed=4 or session("Banco")="clinic100000" then
		    %>
            <li>
                <a data-toggle="tab" class="tab menu-aba-pacientes-resultados-de-exames" id="abaResultadosExames" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|ResultadosExames|');">
                    <span class="fa fa-list-alt bigger-110"></span>
                    <span class="sidebar-title">Resultados de Exames</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalresultadosexame"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
		    if aut("vacinapacienteV")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab menu-aba-pacientes-resultados-de-exames" id="abaVacinas" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|VacinaPaciente|');">
                    <span class="glyphicon glyphicon-pushpin"></span>
                    <span class="sidebar-title">Vacinas</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalvacinas"></span>
                    </span>
                </a>
            </li>
		    <%
		    end if
            %>
            <li>
                <a data-toggle="tab" class="tab menu-aba-pacientes-produtos-utilizados" id="abaProdutdosUtilizados" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|ProdutosUtilizados|');">
                    <span class="fa fa-medkit bigger-110"></span>
                    <span class="sidebar-title">Produtos Utilizados</span>
                    <span class="sidebar-title-tray">
                      <span class="label label-xs bg-primary" id="totalprodutosutilizados"></span>
                    </span>

                </a>
            </li>
            <%

            if recursoAdicional(20) = 4  then

                set certiDidital = db.execute("SELECT * FROM cliniccentral.digitalcertificates where UsuarioID = "&session("User")&" and LicencaID = "&replace(session("Banco"), "clinic", "")&" and sysActive = 1")

                if not certiDidital.eof then
                %>
                <li>
                    <a data-toggle="tab" class="tab menu-aba-pacientes-assinatura-digital"  id="abaAssinarturaDigital" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|AssinaturaDigital|');">
                        <span class="fa fa-shield"></span>
                        <span class="sidebar-title">Assinatura digital
                            <span class="label label-system label-xs fleft">Novo</span>
                        </span>
                    </a>
                </li>

                <%
                end if
            end if

		    if aut("formsae")=1 then
		    %>
		    <li>
                <a data-toggle="tab" class="tab menu-aba-pacientes-linha-do-tempo" id="abaTimeline" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|Prescricao|');">
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
                <a data-toggle="tab" class="tab menu-aba-pacientes-imagens" id="tabImagens" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Imagens|');">
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
                <a data-toggle="tab" class="tab menu-aba-pacientes-arquivos" id="tabArquivos" href="#pront" onclick="pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Arquivos|');">
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
            if (session("Banco")="clinic2901" or session("Banco")="clinic6776" or session("Banco")="clinic8039" or session("Banco")="clinic3656" or session("Banco")="clinic100000" or session("Banco")="clinic105" or session("Banco")="clinic5676" or session("Banco")="clinic5299") and 1=1 then
                %>
                <li>
                    <a data-toggle="tab" class="tab menu-aba-pacientes-odontograma" href="#pront" onclick="pront('Odontograma.asp?I=<%=req("I")%>')">
                        <span class="fa fa-life-bouy bigger-110"></span>
                        <span class="sidebar-title">Odontograma</span>
                    </a>
                </li>
                <%
            end if
		    %>
            <li>
                <a data-toggle="tab" class="tab menu-aba-pacientes-agendamentos" href="#pront" onclick="pront('HistoricoPaciente.asp?PacienteID=<%=req("I")%>');">
                    <span class="fa fa-calendar bigger-110"></span>
                    <span class="sidebar-title">Agendamentos</span>
                </a>
            </li>
		    <%
		    end if
		    if aut("recibos")=1 then
		    %>
            <li>
                <a data-toggle="tab" class="tab menu-aba-pacientes-recibos" href="#divRecibos" onclick="pront('Recibos.asp?PacienteID=<%=req("I")%>')">
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
                <a data-toggle="tab" class="tab menu-aba-pacientes-propostas" id="tabPropostas" href="#divPropostas" onclick="pront('ListaPropostas.asp?PacienteID=<%=req("I")%>')">
                    <span class="fa fa-files-o"></span>
                    <span class="sidebar-title">Propostas</span>
                </a>
            </li>
            <%
		    end if
		    if aut("contapac")=1 then
		    %>
		    <li>
                <a data-toggle="tab" class="tab menu-aba-pacientes-conta" id="tabExtrato" href="#divHistorico" onclick="ajxContent('divHistorico', '<%=req("I")%>&A=<%=req("A") %>', '1', 'pront')">
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

            if (lcase(session("Table"))="profissionais" and aut("buscaprontuarioV")=1) or session("Admin")=1 then
                %>
                <div class="col-xs-12">
                    <a class="btn btn-alert btn-success btn-alt btn-block item-active" href="?P=BuscaProntuario&Pers=1">Busca no prontuário</a>
                </div>
                <%
            end if
            %>
            </li>
            <%
        end if
    case "laudos" , "frases"
        %>
        <li>
            <a  href="?P=Laudos&Pers=1"><span class="fa fa-file-text"></span> <span class="sidebar-title">Laudos</span></a>
        </li>
        <li>
            <a  href="?P=Frases&Pers=0"><span class="fa fa-paragraph"></span> <span class="sidebar-title">Cadastro de frases <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>

        <%
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
    case "procedimentos", "pacotes", "procedimentosgrupos"
        if isnumeric(req("I")) and req("I")<>"" and lcase(req("P"))<>"procedimentosgrupos" and lcase(req("P"))<>"pacotes" then
        %>
        <li class="sidebar-label pt20"></li>
        <li class="active">
            <a data-toggle="tab" href="#divCadastroPrincipal"><span class="fa fa-stethoscope bigger-110"></span> <span class="sidebar-title">Cadastro Principal</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divOpcoesAgenda"><span class="fa fa-calendar"></span> <span class="sidebar-title">Opções de Agenda</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divMateriais" onclick="ajxContent('procedimentoskits', <%=req("I") %>, 1, 'procedimentoskits')"><span class="fa fa-medkit"></span> <span class="sidebar-title">Kits</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divEquipe" onclick="ajxContent('procedimentosdespesas', '<%=req("I") %>', 1, 'divEquipe')"><span class="fa fa-credit-card"></span> <span class="sidebar-title">Despesas Anexas <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divEquipe" onclick="ajxContent('procedimentosequipe', '<%=req("I") %>', 1, 'divEquipe')"><span class="fa fa-users"></span> <span class="sidebar-title">Equipe e Participantes</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divEquipe" onclick="ajxContent('procedimentospreparo', '<%=req("I") %>', 1, 'divEquipe')"><span class="fa fa-list-alt"></span> <span class="sidebar-title">Preparos</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divEquipe" onclick="ajxContent('procedimentosrestricao', '<%=req("I") %>', 1, 'divEquipe')"><span class="fa fa-exclamation-circle"></span> <span class="sidebar-title">Restrições</span></a>
        </li>


        <li>
            <a data-toggle="tab" href="#divLaudos"><span class="fa fa-file-text"></span> <span class="sidebar-title">Laudos</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divVacina"><span class="fa fa-calendar"></span> <span class="sidebar-title">Vacina <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <%
        else
            %>
            <li>
                <a href="./?P=Procedimentos&Pers=Follow"><span class="fa fa-stethoscope"></span> <span class="sidebar-title">Procedimentos</span></a>
            </li>
            <li>
                <a href="./?P=Pacotes&Pers=Follow"><span class="fa fa-stethoscope"></span> <span class="sidebar-title">Pacotes</span></a>
            </li>
            <%
            if recursoAdicional(24)=4 then
                set labAutenticacao = db.execute("SELECT * FROM labs_autenticacao WHERE UnidadeID="&treatvalzero(session("UnidadeID")))
                if not labAutenticacao.eof then
                %>
            <li>
                <a> <span class="fa fa-link"></span> <span class="sidebar-title">Relacionamento laboratório</span> </a>
            </li>
            <li>                
            <%
                set dadoslab = db.execute("SELECT id, NomeLaboratorio FROM cliniccentral.labs ")
                while not dadoslab.eof
                %>
                <li>
                    <a  href="?P=DeParaLabs&Pers=1&labid=<%=dadoslab("id")%>">
                        &nbsp;&nbsp;&nbsp;<span class="fa fa-angle-double-right"></span> <span class="sidebar-title" title="Procedimentos <=> Exames (<%=dadoslab("NomeLaboratorio")%>)"><%=dadoslab("NomeLaboratorio")%>&nbsp; <span class="label label-system label-xs fleft">Novo</span></span>
                    </a>
                </li>
                <% 
                dadoslab.movenext
                wend
            %>
            </li>
            <%
                end if
            end if
            if session("Admin")=1 then
                %>
                <li>
                    <a href="./?P=ProcedimentosGrupos&Pers=Follow"><span class="fa fa-stethoscope"></span> <span class="sidebar-title">Grupos de Procedimentos</span></a>
                </li>
                <%
            end if
        end if

    case "fornecedores"
        if isnumeric(req("I")) and req("I")<>"" then
            %>

            <li class="sidebar-label pt20"></li>
            <li class="active">
                <a data-toggle="tab" href="#divCadastroPrincipal"><span class="fa fa-user-md bigger-110"></span> <span class="sidebar-title">Cadastro Principal</span></a>
            </li>
            <li class="hidden">
                <a data-toggle="tab" href="#divContratos" onclick="ajxContent('ContratosAnexos&T=<%=request.QueryString("P")%>', '<%=req("I")%>', 1, 'divContratos')"><span class="fa fa-file"></span><span class="sidebar-title"></span>Contratos</a>
            </li>
            <%
            SplitStoneStatus = recursoAdicional(15)
            if SplitStoneStatus=4 then %>
                <% if aut("integracaostone")=1 then %>
                <li>
                    <a   class="menu-aba-meu-perfil-integracao-stone" data-toggle="tab" href="#divAcesso" onclick="ajxContent('IntegracaoStone', '<%=req("I")%>', 1, 'divAcesso', '&associationId=2');">
                        <span class="fa fa-code-fork"></span> <span class="sidebar-title">Integração Stone </span></a>
                </li>
                <% end if %>
                <% if aut("splitpagamentoV")=1 then %>
                <li>
                    <a   class="menu-aba-meu-perfil-splits-recebidos" data-toggle="tab" href="#divAcesso" onclick="ajxContent('Splits', '<%=req("I")%>', 1, 'divAcesso', '&associationId=2&accountId=<%=req("I")%>');">
                        <span class="fa fa-usd"></span> <span class="sidebar-title">Splits recebidos</span></a>
                </li>
                <% end if %>
            <%
            end if
            %>
            <li>
                <a  class="menu-aba-meu-perfil-procedimentos-da-agenda" data-toggle="tab" href="#divPermissoes" id="gtProcAgenda" onclick="ajxContent('ProfProcAgenda', '<%=req("I")%>', 1, 'divPermissoes', '&tela=Fornecedores');">
            	    <span class="fa fa-stethoscope"></span> <span class="sidebar-title">Procedimentos</span></a>
            </li>
        <%
        end if

    case "profissionais", "profissionalexterno", "profissionaisgrupos", "especialidades"
        if isnumeric(req("I")) and req("I")<>"" and lcase(req("P"))<>"profissionalexterno" and lcase(req("P"))<>"profissionaisgrupos" and lcase(req("P"))<>"especialidades" then
            %>
            <li class="sidebar-label pt20"></li>
            <li <%=ativoCadastro%>>
                <a data-toggle="tab" href="#divCadastroProfissional"><span class="fa fa-user-md bigger-110"></span> <span class="sidebar-title">Cadastro do Profissional</span></a>
            </li>
            <li>
                <a  class="menu-aba-meu-perfil-procedimentos-da-agenda" data-toggle="tab" href="#divPermissoes" id="gtProcAgenda" onclick="ajxContent('ProfProcAgenda', '<%=req("I")%>', 1, 'divPermissoes');">
            	    <span class="fa fa-stethoscope"></span> <span class="sidebar-title">Procedimentos da Agenda</span></a>
            </li>
            <%
		    if aut("horarios")=1 then
		    %>
            <li <%=ativoHorarios%>>
                <a  class="menu-aba-meu-perfil-horarios" data-toggle="tab" href="#divHorarios" onclick="ajxContent('Horarios<%if versaoAgenda()=1 then%>-1<%end if%>', '<%=request.QueryString("I")%>', 1, 'divHorarios');">
            	    <span class="fa fa-clock-o"></span> <span class="sidebar-title">Hor&aacute;rios de Atendimento</span></a>
            </li>
            <%
		    end if
		    if (session("Admin")=1) or (lcase(request.QueryString("P"))=lcase(session("Table")) and session("idInTable")=ccur(request.QueryString("I")) and aut("senhapA")=1) or (aut("usuariosA")=1) then
		    %>
            <li>
                <a  class="menu-aba-meu-perfil-dados-acesso" data-toggle="tab" href="#divAcesso" onclick="ajxContent('DadosAcesso&T=<%=request.QueryString("P")%>', '<%=request.QueryString("I")%>', 1, 'divAcesso');">
            	    <span class="fa fa-key"></span> <span class="sidebar-title">Dados de Acesso</span></a>
            </li>
            <%
		    end if
		    if (session("Admin")=1) or (lcase(request.QueryString("P"))=lcase(session("Table")) and session("idInTable")=ccur(request.QueryString("I"))) then
		        if aut("googleagenda") then
            %>
            <li>
                <a  class="menu-aba-meu-perfil-integracao-google" data-toggle="tab" href="#divAcesso" onclick="ajxContent('IntegracaoAgenda', '<%=req("I")%>', 1, 'divAcesso');">
            	    <span class="fa fa-calendar"></span> <span class="sidebar-title">Integração Google</span></a>
            </li>
            <%
    		    end if
		        if aut("memed") then
            %>
            <li>
                <a  class="menu-aba-meu-perfil-integracao-memed" data-toggle="tab" href="#divAcesso" onclick="ajxContent('IntegracaoMemed', '<%=req("I")%>', 1, 'divAcesso');">
                    <span class="fa fa-flask"></span> <span class="sidebar-title">Integração Memed <span class="label label-system label-xs fleft">Novo</span> </span></a>
            </li>

            <%
		        end if
		    end if
		    if lcase(request.QueryString("P"))=lcase(session("Table")) and session("idInTable")=ccur(request.QueryString("I")) then
		    %>
            <li>
                <a  class="menu-aba-meu-perfil-certificado-digital" data-toggle="tab" href="#divAcesso" onclick="ajxContent('ConfigCertificadoDigital', '<%=req("I")%>', 1, 'divAcesso');">
                    <span class="fa fa-credit-card"></span> <span class="sidebar-title">Certificado digital <span class="label label-system label-xs fleft">Novo</span> </span></a>
            </li>
            <li>
                <a  class="menu-aba-meu-perfil-assinatura-digital" data-toggle="tab" href="#divAcesso" onclick="ajxContent('AssinaturaLoteAtendimento', '<%=req("I")%>', 1, 'divAcesso');">
                    <span class="fa fa-shield"></span> <span class="sidebar-title">Assinatura digital <span class="label label-system label-xs fleft">Novo</span> </span></a>
            </li>
            <%
		    end if

            SplitStoneStatus = recursoAdicional(15)
            if SplitStoneStatus=4 then %>
                <% if aut("integracaostone")=1 then %>
                <li>
                    <a   class="menu-aba-meu-perfil-integracao-stone" data-toggle="tab" href="#divAcesso" onclick="ajxContent('IntegracaoStone', '<%=req("I")%>', 1, 'divAcesso', '&associationId=5');">
                        <span class="fa fa-code-fork"></span> <span class="sidebar-title">Integração Stone </span></a>
                </li>
                <% end if %>
                <% if aut("splitpagamentoV")=1 then %>
                <li>
                    <a   class="menu-aba-meu-perfil-splits-recebidos" data-toggle="tab" href="#divAcesso" onclick="ajxContent('Splits', '<%=req("I")%>', 1, 'divAcesso', '&associationId=5&accountId=<%=req("I")%>');">
                        <span class="fa fa-usd"></span> <span class="sidebar-title">Splits recebidos</span></a>
                </li>
                <% end if %>
            <%
            end if

		    if session("Admin")=1 then
		    %>
            <li>
                <a  class="menu-aba-meu-perfil-permissoes" data-toggle="tab" href="#divPermissoes" id="gtPermissoes" onclick="ajxContent('Permissoes&T=<%=request.QueryString("P")%>', '<%=request.QueryString("I")%>', 1, 'divPermissoes');">
            	    <span class="fa fa-lock"></span> <span class="sidebar-title">Permiss&otilde;es</span></a>
            </li>

            <li class="">
                <a class="menu-aba-meu-perfil-compartilhamento " data-toggle="tab" href="#divPermissoes" id="gtPermissoes" onclick="ajxContent('CompartilharProntuario&T=<%=request.QueryString("P")%>', '<%=request.QueryString("I")%>', 1, 'divPermissoes');">
            	    <span class="fa fa-share-alt"></span> <span class="sidebar-title">Compartilhamento </span><span class="label label-system label-xs fleft">Novo</span></a>
            </li>

            <%
            end if
            I = req("I")
            if I&"" = "" or not isnumeric(I&"") then
                I=0
            end if
            if aut("proprioextratoV") and lcase(session("Table"))="profissionais" and session("idInTable")&""=I then
		    %>
            <li >
                <a class="menu-aba-meu-perfil-extrato" href="./?P=Extrato&Pers=1&T=5_<%= req("I") %>" id="gtExtrato">
            	    <span class="fa fa-money"></span> <span class="sidebar-title">Extrato</span></a>
            </li>
            <li >
                <a class="menu-aba-meu-perfil-meus-repasses" href="./?P=RepassesAConferir&Pers=1&AccountID=5_<%= req("I") %>&B=1" id="gtRepasses">
            	    <span class="fa fa-exchange"></span> <span class="sidebar-title">Meus repasses</span></a>
            </li>
            <%
		    end if
        else

            %>
            <li>
                <a class="menu-aba-meu-perfil-profissionais" href="?P=Profissionais&Pers=Follow"><span class="fa fa-user-md bigger-110"></span> <span class="sidebar-title">Profissionais</span></a>
            </li>
            <li>
                <a class="menu-aba-meu-perfil-profissionais-externos" href="?P=ProfissionalExterno&Pers=Follow"><span class="fa fa-user-times bigger-110"></span> <span class="sidebar-title">Profissionais Externos</span></a>
            </li>
            <% if lcase(req("P"))="profissionalexterno" then %>
            <li>
                <a  class="menu-aba-meu-perfil-procedimentos-da-agenda" data-toggle="tab" href="#divPermissoes" id="gtProcAgenda" onclick="ajxContent('ProfProcAgenda', '<%=req("I")%>', 1, 'divPermissoes', '&tela=ProfissionalExterno');">
            	    <span class="fa fa-stethoscope"></span> <span class="sidebar-title">Procedimentos</span></a>
            </li>
            <% end if %>
            <li>
                <a class="menu-aba-meu-perfil-grupo-de-profissionais" href="?P=ProfissionaisGrupos&Pers=Follow"><span class="fa fa-users bigger-110"></span> <span class="sidebar-title">Grupos de Profissionais</span></a>
            </li>
            <li>
                <a class="menu-aba-meu-perfil-especialidades" href="?P=Especialidades&Pers=Follow"><span class="fa fa-stethoscope bigger-110"></span> <span class="sidebar-title">Especialidades</span></a>
            </li>
            <%
        end if
    case "funcionarios", "cargo", "departamento"
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
                <a data-toggle="tab" href="#divAcesso" onclick="ajxContent('DadosAcesso&T=<%=request.QueryString("P")%>', '<%=request.QueryString("I")%>', 1, 'divAcesso');">
                    <span class="fa fa-key"></span> <span class="sidebar-title">Dados de Acesso</span></a>
            </li>
            <%
		    end if
		    if session("Admin")=1 then
		    %>
            <li>
                <a data-toggle="tab" href="#divPermissoes" id="gtPermissoes" onclick="ajxContent('Permissoes&T=<%=request.QueryString("P")%>', '<%=request.QueryString("I")%>', 1, 'divPermissoes');">
                    <span class="fa fa-lock"></span> <span class="sidebar-title">Permiss&otilde;es</span></a>
            </li>
            <%
		    end if
        end if
		if aut("cargoI")=1 and false then
        %>
            <li><a href="./?P=cargo&Pers=Follow" >
                <span class="fa fa-plus"></span> Cargos</a>
            </li>
        <% end if %>
        <% if aut("departamentoI")=1 and false then %>
            <li> <a  href="./?P=departamento&Pers=Follow">
                <span class="fa fa-plus"></span> Departamentos</a></li>
        <% end if %>
        <% if aut("funcoesI")=1  and false then %>
            <li><a href="./?P=funcoes&Pers=Follow">
                <span class="fa fa-plus"></span> Funções</a></li>
        <% end if %>
        <% if aut("agenciaintegradoraI")=1 and false then %>
            <li><a href="./?P=agenciaintegradora&Pers=Follow">
             <span class="fa fa-plus"></span> Agências Integradoras</a></li>
        <% end if %>
    <%
    case "tabelasconvenios","tabelasportes"
            %>
                <li>
                    <a href="?P=tabelasconvenios&Pers=Follow"><span class="fa fa-credit-card"></span> <span class="sidebar-title">Tabelas de Conv&ecirc;nio</span></a>
                </li>
                 <li>
                    <a href="?P=tabelasportes&Pers=Follow"><span class="fa fa-credit-card"></span> <span class="sidebar-title">Tabelas de Portes</span></a>
                </li>
            <%
    case "convenios"
        if not (isnumeric(req("I")) and req("I")<>"")then %>
                <li>
                    <a href="?P=tabelasconvenios&Pers=Follow"><span class="fa fa-credit-card"></span> <span class="sidebar-title">Tabelas de Conv&ecirc;nio</span></a>
                </li>
                 <li>
                    <a href="?P=tabelasportes&Pers=Follow"><span class="fa fa-credit-card"></span> <span class="sidebar-title">Tabelas de Portes</span></a>
                </li>
        <% end if

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
            <li>
                <a data-toggle="tab" href="#divNumeracao" onclick="ajxContent('ConvenioSequenciaNumeracao&ConvenioID=<%=request.QueryString("I")%>', '', '1', 'divNumeracao')">
                    <span class="fa fa-sort-numeric-asc"></span> <span class="sidebar-title">Numeração das guias</span></a>
            </li>
            <li><a data-toggle="tab" href="#divRegras" onclick="setTimeout(function(){$('.select2-single').select2()}, 1000)"><span class="fa fa-cogs"></span> <span class="sidebar-title">Regras</span></a></li>
            <li><a data-toggle="tab" href="#divWS"><span class="fa fa-plug"></span> <span class="sidebar-title">Webservices TISS</span></a></li>
            <li><a data-toggle="tab" href="#divValoresPlanos" onclick="ajxContent('ValoresPlanosContratado&ConvenioID=<%=request.QueryString("I")%>', '', '1', 'divValoresPlanos')">
                    <span class="fa fa-money"></span> <span class="sidebar-title">Inflator / Deflator</span>
                </a>
            </li>
            <li><a data-toggle="tab" href="#divValoresPlanos" onclick="ajxContent('EscalonamentosConvenio&ConvenioID=<%=request.QueryString("I")%>', '', '1', 'divValoresPlanos')">
                    <span class="fa fa-money"></span> <span class="sidebar-title">Escalonamento</span>
                </a>
            </li>
            <% IF getConfig("calculostabelas") = "1" THEN %>
                 <li><a data-toggle="tab" href="#divValoresPlanos" onclick="ajxContent('ImpostosConvenio&ConvenioID=<%=request.QueryString("I")%>', '', '1', 'divValoresPlanos')">
                        <span class="fa fa-money"></span> <span class="sidebar-title">Imposto por Operadora</span>
                    </a>
                </li>
            <% END IF %>

            <% IF getConfig("calculostabelas") <> "1" THEN %>
                <li><a data-toggle="tab" href="#divValoresImpostos"  onclick="ajxContent('ValoresImpostosConvenio&ConvenioID=<%=request.QueryString("I")%>', '', '1', 'divValoresImpostos')">
                        <span class="fa fa-money"></span> <span class="sidebar-title">Impostos</span>
                    </a>
                </li>
            <% END IF %>
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
                <a data-toggle="tab" href="#divHorarios" onclick="ajxContent('Horarios<%if versaoAgenda()=1 then%>-1<%end if%>', '<%=req("I")*(-1)%>', 1, 'divHorarios');">
                    <span class="fa fa-clock-o"></span> <span class="sidebar-title">Grade de Hor&aacute;rios</span></a>
            </li>
            <%
	        end if
        end if
    case "configimpressos"
        %>
        <li class="sidebar-label pt20"></li>
        <li class="active">
            <a data-toggle="tab" href="#divPapelTimbrado"><span class="fa fa-file-o"></span><span class="sidebar-title"></span> Papel Timbrado</a>
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
        <hr style="margin:10px !important;">
        <%
        if 0 then
        %>
        <li>
            <a data-toggle="tab" href="#divRecibos"><span class="fa fa-edit"></span><span class="sidebar-title"></span> Recibos Avulsos</a>
        </li>
        <%
        end if
        %>

        <% if recursoAdicional(15) then %>
        <li>
            <a data-toggle="tab" href="#divRecibosHM"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Recibos de Honorário Médico (Split)</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divRecibosRPS"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> RPS (Split)</a>
        </li>

        <% end if %>
        <li>
            <a data-toggle="tab" href="#divRecibosIntegrados"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Recibos Integrados (A Receber)</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divRecibosIntegradosAPagar"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Recibos Integrados (A Pagar)</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divAgendamentos"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Agendamentos</a>
        </li>
        <li><a data-toggle="tab" href="#divPropostas"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Propostas</a></li>

        <li>
            <a data-toggle="tab" href="#divLaudosProtocolo"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Protocolo dos Laudos</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divEtiquetaAgendamento"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Etiqueta dos Agendamentos</a>
        </li>
        <li>
            <a data-toggle="tab" href="#divTermoCancelamento"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Termo de Cancelamento</a>
        </li>
        <hr style="margin:10px !important;">

        <li><a data-toggle="tab" href="#divProcedimentos" onclick="ajxContent('procedimentosmodelosimpressos', '', 'Follow', 'divProcedimentos')"><span class="fa fa-files-o"></span><span class="sidebar-title"></span> Procedimentos</a></li>
        <li><a data-toggle="tab" href="#divContratos" onclick="ajxContent('contratosmodelos', '', 'Follow', 'divContratos')"><span class="fa fa-files-o"></span><span class="sidebar-title"></span> Contratos</a></li>
        <li><a data-toggle="tab" href="#divLaudos" onclick="ajxContent('laudosmodelos', '', 'Follow', 'divLaudos')"><span class="fa fa-files-o"></span><span class="sidebar-title"></span> Laudos</a></li>
        <li><a data-toggle="tab" href="#divEncaminhamentos" onclick="ajxContent('encaminhamentosmodelos', '', 'Follow', 'divEncaminhamentos')"><span class="fa fa-files-o"></span><span class="sidebar-title"></span> Encaminhamentos</a></li>

        <%
    case "sys_financialcompanyunits", "empresa", "nfe_origens"
        %>
        <li class="sidebar-label pt20"></li>
        <li>
            <a href="./?P=empresa&Pers=1"><span class="fa fa-hospital-o"></span><span class="sidebar-title"></span> Empresa Principal</a>
        </li>
        <li>
            <a href="./?P=sys_financialcompanyunits&Pers=Follow"><span class="fa fa-hospital-o"></span><span class="sidebar-title"></span> Unidades / Filiais</a>
        </li>
        <%
        set RecursosAdicionaisSQL = db.execute("SELECT RecursosAdicionais FROM sys_config WHERE id=1")
        if not RecursosAdicionaisSQL.eof then
            RecursosAdicionais=RecursosAdicionaisSQL("RecursosAdicionais")
            if session("Admin")=1 AND instr(RecursosAdicionais, "|NFe|") then
         %>
        <hr style="margin:10px !important;">
        <li>
            <a href="./?P=nfe_origens&Pers=Follow"><span class="fa fa-file-text"></span><span class="sidebar-title"></span> Serviço Nota Fiscal</a>
        </li>
        <%
            end if
        end if
    case "outrasconfiguracoes", "novasconfiguracoes"
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
        <li style="display: none;">
            <a data-toggle="tab" href="#divPesquisaSatisfacao" onclick="ajxContent('PesquisaSatisfacao', '', 1, 'divPesquisaSatisfacao');">
            	<span class="fa fa-smile-o"></span> <span class="sidebar-title">Pesquisa de satisfação  <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divApiPublica" onclick="ajxContent('ApiPublica', '', 1, 'divApiPublica');">
                <span class="fa fa-cloud-upload"></span> <span class="sidebar-title">API Pública  </span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divTriagem" onclick="ajxContent('ConfigTriagem', '', 1, 'divTriagem');">
            	<span class="fa fa-stethoscope"></span> <span class="sidebar-title">Triagem  <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divTotem" onclick="ajxContent('ConfigTotem', '', 1, 'divTotem');">
                <span class="fa fa-laptop"></span> <span class="sidebar-title">Totem e Guichês <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divIntegracoes" onclick="ajxContent('configGerais', '', 1, 'divIntegracoes');">
            	<span class="fa fa-cogs"></span> <span class="sidebar-title">Configurações Gerais</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divChamadaTVConfiguracoes" onclick="ajxContent('ChamadaTVConfiguracoes', '', 1, 'divChamadaTVConfiguracoes');">
                <span class="fa fa-bullhorn"></span> <span class="sidebar-title">Chamada de TV <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divChamadaTVConfiguracoes" onclick="ajxContent('chamadaPacsConfiguracoes', '', 1, 'divChamadaTVConfiguracoes');">
                <span class="fa fa-laptop"></span> <span class="sidebar-title">Configurações Pacs <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divLaudosOnline" onclick="ajxContent('LaudosOnline', '', 1, 'divLaudosOnline');">
                <span class="fa fa-flask"></span> <span class="sidebar-title">Laudos Online <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <li>
         <a data-toggle="tab" href="#divIntegracoes" onclick="ajxContent('novasConfiguracoes', '', 1, 'divIntegracoes');">
                <span class="fa fa-cogs"></span> <span class="sidebar-title">Outras configurações</span></a>
        </li>
        <% IF  recursoAdicional(21)  THEN %>
            <li>
               <a href="?P=chamadasmotivoscontato">
                    <span class="fa fa-phone"></span> <span class="sidebar-title">Configuração PABX</span></a>
            </li>
        <% END IF %>
        <% IF  true  THEN %>
            <li>
               <a href="?P=ConfiguracaoDeCompra&Pers=1">
                    <span class="fa fa-shopping-cart"></span> <span class="sidebar-title">Configuração de Compra</span></a>
            </li>
        <% END IF %>
        <li>
        <a data-toggle="tab" href="#divProcedimentoLaboratorio" onclick="ajxContent('ProcedimentoLaboratorio', '', 1, 'divProcedimentoLaboratorio');">
            <span class="fa fa-flask"></span> <span class="sidebar-title">Procedimentos Laboratorios</a>
        </li>
        
         <li>
            <a data-toggle="tab" href="#divWhatsapp" onclick="ajxContent('IntegracaoWhatsapp', '', 1, 'divWhatsapp');">
            <span class="fa fa-whatsapp"></span> <span class="sidebar-title">Integração Whatsapp <span class="label label-system label-xs fleft">Novo</span></span></a>
        </li>
        <%
    case "chamadasmotivoscontato","chamadascategorias"
    %>
        <li>
           <a href="?P=chamadasmotivoscontato">
                <span class="fa fa-phone"></span> <span class="sidebar-title">Motivo de Chamadas</span></a>
        </li>
        <li>
           <a href="?P=chamadascategorias">
                <span class="fa fa-phone"></span> <span class="sidebar-title">Categoria de Chamadas</span></a>
        </li>
    <%
    case "produtos"
        if req("Pers")="1" then
            %>
            <li class="sidebar-label pt20">Opções de Configurações</li>
            <li class="active">
                <a data-toggle="tab" href="#divCadastroProduto" onclick="atualizaLanctos();"><span class="fa fa-medkit"></span> <span class="sidebar-title"> Cadastro</span></a>
            </li>

            <%
            if aut("estoquemovimentacaoV")=1 then
            %>
            <li>
                <a data-toggle="tab" href="#divLancamentos" onclick="ajxContent('Lancamentos', '<%=req("I")%>', 1, 'divLancamentos');"><span class="fa fa-exchange icon-rotate-90"></span> <span class="sidebar-title">Movimentação</span></a>
            </li>
            <%
            end if
            %>
            <li id="InteracoesEstoque" class="Modulo-Medicamento">
                <a data-toggle="tab" href="#divInteracoesEstoque" onclick="ajxContent('InteracoesEstoque', '<%=req("I")%>', 1, 'divInteracoesEstoque');"><span class="fa fa-folder"></span> <span class="sidebar-title">Interações</span></a>
            </li>

            <li id="ConversaoEstoque" class="Modulo-Medicamento">
                <a data-toggle="tab" href="#divConversaoEstoque"><span class="fa fa-retweet"></span> <span class="sidebar-title">Conversão</span></a>
            </li>
            <%
        end if
    case "financeiro", "invoice","configuracaodecompra","solicitacaodecompraaprovacao","solicitacaodecompralista", "solicitacaodecompra", "contascd", "recorrentes", "recorrente", "conferenciacaixa", "caixas", "splits" , "importret" , "boletosemitidos" , "marketplace" ,  "microteflogs" ,"importarconcicartao" , "emissaodeboletos" , "splitscancelamento" , "concilia" , "concicols" , "bancoconcilia" , "stoneconcilia" , "conciliacaoprovedor" ,  "repasses", "regerarrepasses", "extrato", "chequesrecebidos", "cartaocredito", "faturacartao", "detalhamentofatura", "buscapropostas", "gerarrateio", "propostas", "pacientespropostas", "repassesaconferir", "repassesconferidos", "arquivoretorno", "notafiscal", "notafiscalnew","fechamentodedata", "descontopendente"
              %>
              <li class="sidebar-label pt20">Financeiro</li>
    	<!--#include file="MenuFinanceiro.asp"-->
    <%
    case "listafranquias", "listausuarios"
    if req("Pers")="1" then
        %>
        <li>
            <a href="./?P=ListaFranquias&Pers=1"><span class="fa fa-hospital-o"></span> <span class="sidebar-title"> Lista de Licenciados</span></a>
        </li>
        <li>
            <a href="./?P=ListaUsuarios&Pers=1"><span class="fa fa-user"></span> <span class="sidebar-title">Lista de Usuários</span></a>
        </li>
        <%
    end if
    case "estoque"
        %>
        <!--#include file="MenuEstoque.asp"-->
        <%
    case "listaprodutos", "produtoscategorias", "produtoslocalizacoes", "produtosfabricantes"
        %><li class="sidebar-label pt20">Tipos de Itens</li><%
        set getTipoProduto = db.execute("SELECT * FROM cliniccentral.produtostipos")
        while not getTipoProduto.eof
            TipoProduto = req("TipoProduto")&""
            if TipoProduto&""="" then
                TipoProduto = 0
            end if
            %>
            <li <%if getTipoProduto("id")=ccur(TipoProduto) then%>class="active"<%end if%> >
                <a href="./?P=ListaProdutos&Pers=1&TipoProduto=<%=getTipoProduto("id")%>"><span class="<%=getTipoProduto("Icone")&""%>"></span> <span class="sidebar-title">  <%=getTipoProduto("TipoProduto")&""%></span></a>
            </li>
            <%
        getTipoProduto.movenext
        wend
        getTipoProduto.close
        set getTipoProduto=nothing
        %>
        <hr style="margin:10px !important;">
        <li class="sidebar-label pt20">Configurações</li>
        <li <%if req("P")="ProdutosCategorias" then%>class="active"<%end if%>>
            <a href="./?P=ProdutosCategorias&Pers=0"><span class="fa fa-puzzle-piece"></span> <span class="sidebar-title"> Categorias</span></a>
        </li>
        <li <%if req("P")="ProdutosLocalizacoes" then%>class="active"<%end if%>>
            <a href="./?P=ProdutosLocalizacoes&Pers=0"><span class="fa fa-map-marker"></span> <span class="sidebar-title"> Localizações</span></a>
        </li>
        <li <%if req("P")="ProdutosFabricantes" then%>class="active"<%end if%>>
            <a href="./?P=ProdutosFabricantes&Pers=0"><span class="fa fa-sitemap"></span> <span class="sidebar-title"> Fabricantes</span></a>
        </li>


        <%
    case "relatorios"
        %>
        <li class="sidebar-label pt20">Relatórios</li>
        <%
        favoritosSQL =  "select r.id,r.NomeModelo, r.RelatorioID,rl.Arquivo,rl.Ct "&_
                            " from cliniccentral.relatorios_preferencias_modelo as r"&_
                            " join cliniccentral.relatorios rl on rl.id = r.RelatorioID "&_
                            " where r.Atalho=1 and r.LicencaID = "&replace(session("Banco"),"clinic","")&" and r.sysActive = 1"
        set relatoriosFav = db.execute(favoritosSQL)
        if not relatoriosFav.eof then
        %>

         <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-star"></span>
                <span class="sidebar-title"> Favoritos </span>
                <span class="caret"></span>
            </a>

            <ul class="nav sub-nav">
            <%
            catNome =""
            while not relatoriosFav.eof

            if catNome <> relatoriosFav("Ct") then
            %>
            <li class="ml15"><i class="fa fa-tag"></i> <%=relatoriosFav("Ct")%> </li>
            <%
            catNome = relatoriosFav("Ct")
            end if
            %>
                <li>
                    <a href="javascript:openNewReport('<%=relatoriosFav("Arquivo")%>','<%=relatoriosFav("id")%>');">
                        <i class="fa fa-double-angle-right"></i>
                        <%=relatoriosFav("NomeModelo")%>
                    </a>
                </li>
            <%
            relatoriosFav.movenext
            wend
            relatoriosFav.close
            %>
            </ul>
        </li>
        <%end if%>
        <%if aut("relatoriospacienteperfilV")=1 then %>
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

                <li class="hidden">
                    <a href="javascript:callReport('rpSatisfacao');">
                        <i class="fa fa-double-angle-right"></i>
                        Satisfação dos Pacientes <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>

            </ul>
        </li>
        <%end if%>
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
                        Consultas e Retornos
                    </a>
                </li>

                <li>
                    <a href="#" onClick="callReport('OcupacaoMultipla');">
                        <i class="fa fa-double-angle-right"></i>
                        Taxa de Ocupação
                    </a>
                </li>

                <li>
                    <a href="#" onClick="callReport('UraReport');">
                        <i class="fa fa-double-angle-right"></i>
                        Relatório URA
                    </a>
                </li>
                <%
                if recursoAdicional(24)=4 then
                    set labAutenticacao = db.execute("SELECT * FROM labs_autenticacao WHERE UnidadeID="&treatvalzero(session("UnidadeID")))
                    if not labAutenticacao.eof then
                    %>
                <li>
                    <a href="#" onClick="callReport('RelatorioLabs');">
                        <i class="fa fa-double-angle-right"></i>
                        Mapa Laboratório
                    </a>
                </li>

                <%
                end if
                    end if
                end if
                %>
                <%
                if aut("|agendaV|")=1 or lcase(session("Table"))="profissionais" then
                %>
                <li>
                    <a href="https://clinic.feegow.com.br/components/public/reports/r/duration-of-service" target="_blank">
                        <i class="fa fa-double-angle-right"></i>
                        Duração do Atendimento
                    </a>
                </li>
                <%
                end if

                if aut("|relatoriosagendaV|")=1 then
                %>
                <li class="hidden">
                    <a href="#" onClick="callReport('AgendamentosPorUsuario');">
                        <i class="fa fa-double-angle-right"></i>
                        Agendamentos por usuário
                    </a>
                </li>
                <li class="hidden">
                    <a href="#" onClick="callReport('ProdutividadeSintetico');">
                        <i class="fa fa-double-angle-right"></i>
                        Produtividade - Sintético
                    </a>
                </li>
                <li>
                    <a href="https://clinic.feegow.com.br/components/public/reports/r/productivity" target="_blank">
                        <i class="fa fa-double-angle-right"></i>
                        Produtividade - Analítico
                    </a>
                </li>
                <%
                end if
                %>
            </ul>
        </li>
        <%if aut("|relatoriosproducaoV|") then %>
        <li>
            <a href="#" class="accordion-toggle menu-open">
                <span class="fa fa-area-chart"></span>
                <span class="sidebar-title"> Faturamento </span>

                <span class="caret"></span>
            </a>

            <ul class="nav sub-nav">
                <%
				if aut("|relatoriosproducaoV|")=1 or lcase(session("Table"))="profissionais" then
				%>
                <li>
                    <a href="#" onClick="javascript:callReport('ProducaoMedica');">
                        <i class="fa fa-double-angle-right"></i>
                        Produção - Analítico
                    </a>
                </li>
                <li class="hidden">
                    <a href="#" onClick="javascript:callReport('ProducaoSintetico');">
                        <i class="fa fa-double-angle-right"></i>
                        Produção - Sintético
                    </a>
                </li>
                <li>
                    <a href="#" onClick="javascript:callReport('ProducaoExterna');">
                        <i class="fa fa-double-angle-right"></i>
                        Produção Externa
                    </a>
                </li>
                <li>
                    <a href="#" onClick="javascript:callReport('ProducaoPorGrupo');">
                        <i class="fa fa-double-angle-right"></i>
                        Produção por Grupo
                    </a>
                </li>
                <%
				end if
                if aut("guiasV") then
                    %>
                    <li>
                        <a href="#" onClick="javascript:callReport('GuiasPagas');">
                            <i class="fa fa-double-angle-right"></i>
                            Guias Pagas
                        </a>
                    </li>
                    <%
                end if
                if aut("|relatoriosproducaoV|")>0 then
                    %>
                    <li>
                        <a href="#" onClick="javascript:callReport('VendasParticular');">
                            <i class="fa fa-double-angle-right"></i>
                             Vendas - Particular
                        </a>
                    </li>
                    <li>
                        <a href="#" onClick="javascript:callReport('ServicosPorExecucao');">
                            <i class="fa fa-double-angle-right"></i>
                             Serviços por Execução
                        </a>
                    </li>
                    <li>
                        <a href="https://clinic.feegow.com.br/components/public/reports/r/guides" target="_blank">
                            <i class="fa fa-double-angle-right"></i>
                             Guias Fora de Lote
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
        <%if aut("relatoriosfinanceiroV") or aut("relatoriosfinanceirocaixaV") then %>
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
                <li>
                    <a href="#" onClick="javascript:callReport('RelatorioCaixa');">
                        <i class="fa fa-double-angle-right"></i>
                        Relatório de Caixa
                    </a>
                </li>
                <li>
                    <a href="#" onClick="javascript:callReport('FCaixa');">
                        <i class="fa fa-double-angle-right"></i>
                        Fechamento de Caixa
                    </a>
                </li>
                <li>
                    <a href="#" onClick="javascript:callReport('FCofre');">
                        <i class="fa fa-double-angle-right"></i>
                        Fechamento de Cofre
                    </a>
                </li>
                <% if session("Banco")="clinic6118" or session("Banco")="clinic5760" or session("Banco")="clinic4285" or session("Banco")="clinic100000" then %>
                <li>
                    <a href="#" onClick="javascript:callReport('AnaliseCompleta');">
                        <i class="fa fa-double-angle-right"></i>
                        Análise Completa
                    </a>
                </li>
                <% end if %>
                <li class="hidden">
                    <a href="#" onClick="javascript:callReport('CaixaPorUsuario');">
                        <i class="fa fa-double-angle-right"></i>
                        Caixa por Usuário
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
                <li>
                    <a href="?P=fluxodecaixa&Pers=1" target="_blank">
                        <i class="fa fa-double-angle-right"></i>
                        Fluxo de Caixa <small><small>(Desenvolvimento)</small></small>
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

                <li class="hidden">
                    <a href="javascript:callReport('Plano', 'DESPESAS&U=<%=session("Unidades")%>');">
                        <i class="fa fa-double-angle-right"></i>
                        Análise de Despesas
                    </a>
                </li>
                <li>
                    <a href="javascript:callReport('PlanoDesp', 'DESPESAS&U=<%=session("Unidades")%>');">
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
                        Serviços a Executar
                    </a>
                </li>
                <li class="hidden">
                    <a href="https://clinic.feegow.com.br/components/public/reports/r/medical-transfer" target="_blank">
                        <i class="fa fa-double-angle-right"></i>
                        Repasses - Analítico
                    </a>
                </li>
                <li>
                    <a href="javascript:callReport('repassesAnalitico');">
                        <i class="fa fa-double-angle-right"></i>
                        Repasses - Analítico
                    </a>
                </li>
                <li class="hidden">
                    <a href="javascript:callReport('DRE');">
                        <i class="fa fa-double-angle-right"></i>
                        DRE
                    </a>
                </li>
                <li class="hidden">
                    <a href="javascript:callReport('SCP');">
                        <i class="fa fa-double-angle-right"></i>
                        Apuração de SCP <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
                <li <% if scp()=0 then %>class="hidden"<% end if %>>
                    <a href="javascript:callReport('receitaPorTipo');">
                        <i class="fa fa-double-angle-right"></i>
                        Receita por Tipo
                    </a>
                    <a href="javascript:callReport('servicosPorNota');">
                        <i class="fa fa-double-angle-right"></i>
                        Serviços por Nota
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
                <%
                if 1=2 then
                %>
                <li>
                    <a href="https://clinic.feegow.com.br/components/public/reports/r/medical-report">
                        <i class="fa fa-double-angle-right"></i>
                        Laudos Sintético
                    </a>
                </li>
                <%
                end if
                if aut("|relatoriosformulariosV|")=1 and lcase(session("Table"))="profissionais" then
                %>
                <li>
                    <a href="javascript:callReport('relatorioForms');">
                        <i class="fa fa-document"></i>
                        Formulários
                    </a>
                </li>
                <%
                end if
                %>
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
                    <a href="https://clinic.feegow.com.br/components/public/reports/r/proposal" target="_blank">
                        <i class="fa fa-double-angle-right"></i>
                        Propostas Emitidas
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
                        Posição
                    </a>
                </li>
                <li>
                    <a href="https://clinic.feegow.com.br/components/public/reports/r/stock-movement" target="_blank">
                        <i class="fa fa-double-angle-right"></i>
                        Movimentação
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
                            <%
                        end if
                    end if
                    %>
                    <button class="btn-xs btn-link btn AlterarLocalAtual" type="button" title="Alterar local"><i class="fa fa-edit"></i> Alterar local</button>
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
    case "laudo"

        LaudoID = req("I")

        if LaudoID<>"" then

            sqlLaudo = "select proc.FormulariosLaudo, l.FormID, l.StatusID, l.Restritivo, l.PacienteID, l.ProfissionalID, l.Associacao , "&_
                       " COALESCE(ii.ItemID, tpsadt.ProcedimentoID) ProcedimentoID "&_
                       " FROM laudos l  "&_
                       " LEFT JOIN itensinvoice ii ON ii.id=l.IDTabela AND l.Tabela='itensinvoice' "&_
                       " LEFT JOIN tissprocedimentossadt tpsadt ON tpsadt.id=l.IDTabela AND l.Tabela='tissprocedimentossadt' "&_
                       " LEFT JOIN procedimentos proc ON proc.id=COALESCE(ii.ItemID, tpsadt.ProcedimentoID) "&_
                       " WHERE l.id="& LaudoID
            set pLaudo = db.execute( sqlLaudo )
            if not pLaudo.eof then
                FormulariosLaudo = replace(pLaudo("FormulariosLaudo")&"", "|", "")

                if FormulariosLaudo<>"" then
                    sqlFormulariosLaudo = " AND id IN("& FormulariosLaudo &") "
                end if
                FormID = pLaudo("FormID")
                StatusID = pLaudo("StatusID")
                Restritivo = pLaudo("Restritivo")
                PacienteID = pLaudo("PacienteID")
                ProfissionalID = pLaudo("ProfissionalID")
                Associacao = pLaudo("Associacao")

                ProfissionalID = Associacao&"_"&ProfissionalID
                if not isnull(ProfissionalID) then
                    'disabledProf = " disabled "
                end if
            end if
        end if

        if session("Admin")=0 and disabledProf="" and aut("formslA")=0 then
            disabledProf= " disabled "
        end if

        if lcase(session("Table"))<>"profissionais" and aut("|formslA|")=0 then
            disabled = " disabled title='Somente profissionais de saúde podem alterar o status do laudo' "
        end if
        %>
        <li class="sidebar-label">Edição do Laudo</li>
        <li class="row sidebar-stat tray-bin stretch hidden-xs">
            <div class="fs11 col-md-12">
                <%= quickfield("simpleSelect", "FormularioID", "Formulário", 12, FormID, "select id, Nome from buiforms WHERE Tipo=4 "& sqlFormulariosLaudo &" ORDER BY Nome", "Nome", "" & disabled) %>
            </div>
        </li>

        <li class="active">
            <a data-toggle="tab" href="#folha"><span class="fa fa-file-text bigger-110"></span> <span class="sidebar-title">Cadastro Principal</span></a>
        </li>
        <li>
            <a data-toggle="tab" href="#divAnexos" onclick="ajxContent('Imagens&PacienteID=<%= PacienteID %>', 0, 1, 'ImagensPaciente')"><span class="fa fa-file"></span> <span class="sidebar-title">Anexos e Textos</span></a>
        </li>
        <li>
            <a href="javascript:entrega()"><span class="fa fa-print"></span> <span class="sidebar-title">Entrega</span></a>
        </li>
        <li>
            <a href="javascript:protocolo()"><span class="fa fa-print"></span> <span class="sidebar-title">Imprimir Protocolo</span></a>
        </li>

        <li class="divider mb10"></li>
        <li>
            <div class="row p10">
                <%= quickfield("simpleSelect", "StatusID", "Status", 12, StatusID, "select id, Status from laudostatus order by Ordem", "Status", " no-select2 semVazio "& disabled) %>
            </div>
        </li>

        <li class="p10">
                <div class="checkbox-custom checkbox-danger"><input type="checkbox" id="Restritivo" name="Restritivo" onchange="saveLaudo('Restritivo')" value="1" <% if Restritivo then response.write(" checked ") end if %> /><label for="Restritivo">Marcar como restritivo</label></div>
        </li>
        <li>
            <div class="row p10">
                <%
                    sql = "select id, NomeProfissional from (select CONCAT('5_',id)id,IF(NomeSocial is null or NomeSocial='',NomeProfissional,NomeSocial)NomeProfissional from profissionais where sysActive=1 AND Ativo='on' UNION ALL SELECT CONCAT('8_',id)id,NomeFornecedor FROM fornecedores WHERE TipoPrestadorID IN (1))t ORDER BY NomeProfissional"
                   response.write( quickfield("simpleSelect", "ProfissionalID", "Laudador", 12, ProfissionalID, sql, "NomeProfissional", " no-select2 "& disabledProf) )
                %>
            </div>
        </li>
        <li  class="p10">
            <button type="button" class="btn btn-default btn-sm" onclick="javascript:LogLaudos()">
                <i class="fa fa-history"></i>
                 Logs
            </button>
            <%
                if recursoAdicional(24)=4 and LaudoID<>"" then
                    set labAutenticacao = db.execute("SELECT * FROM labs_autenticacao WHERE UnidadeID="&treatvalzero(session("UnidadeID")))
                    if not labAutenticacao.eof then
                        sql = "SELECT ls.InvoiceID, ls.labid FROM labs_solicitacoes ls INNER JOIN laudos l ON ls.InvoiceID = l.IDTabela WHERE l.Tabela = 'sys_financialinvoices' and l.id ="&LaudoID
                        set solicInfo = db.execute(sql)
                        if not solicInfo.eof then
                            InvoiceID = solicInfo("InvoiceID")
                            labid = solicInfo("labid")
            %>
            <button type="button" id="syncInvoiceResultsButton" class="btn btn-primary btn-sm" onclick="javascript:syncLabResult([<%=InvoiceID%>],<%=labid%>)">
                            <i class="fa fa-flask"></i>
                             Sincronizar resultados 
                        </button>
            <%
                        end if
                    end if
                end if
            %>
        </li>

        <%
            case "aso_empresa", "aso_categoria_risco_operacional", "aso_texto", "aso_funcao"
%>
		<li>
            <a href="?P=aso_funcao&Pers=Follow"><span class="fa fa-users"></span> <span class="sidebar-title">Funções</span></a>
        </li>
        <li>
            <a href="?P=aso_categoria_risco_operacional&Pers=Follow"><span class="fa fa-exclamation-triangle"></span> <span class="sidebar-title">Riscos operacionais</span></a>
        </li>
        <li>
            <a href="?P=aso_empresa&Pers=Follow"><span class="fa fa-building"></span> <span class="sidebar-title">Empresas</span></a>
        </li>
        <li>
            <a href="?P=aso_texto&Pers=Follow"><span class="fa fa-align-justify"></span> <span class="sidebar-title">Texto padrão</span></a>
        </li>
<%
    case "treinamentos"
        %>
        <li class="sidebar-label"></li>
        <%
        if session("Admin")=1 then
            %>
            <li>
                <a target="_blank" href="./?P=Treinamento"><span class="fa fa-list"></span> <span class="sidebar-title">Editar treinamento</span></a>
            </li>
            <%
        end if
        PrimeiroID = ""
        set pt = db.execute("select * from treinamentos where AnalistaID="& session("User") &" and isnull(Fim)")
        if not pt.eof then
            PerfilEmpresaID = pt("PerfilEmpresaID")
            PerfilPersonaID = pt("PerfilPersonaID")
            OutrasCaracteristicas = pt("OutrasCaracteristicas")&""
            if OutrasCaracteristicas<>"" then
                sqlOutrasCaracteristicas = " AND (OutrasCaracteristicas='' OR ISNULL(OutrasCaracteristicas) "
                splOutrasCaracteristicas = split(OutrasCaracteristicas, ", ")
                for i=0 to ubound(splOutrasCaracteristicas)
                    mioloOutrasCaracteristicas = mioloOutrasCaracteristicas & " OR OutrasCaracteristicas LIKE '%"& splOutrasCaracteristicas(i) &"%' "
                next
                'mioloOutrasCaracteristicas = right(mioloOutrasCaracteristicas, len(mioloOutrasCaracteristicas)-4)
                sqlOutrasCaracteristicas = sqlOutrasCaracteristicas & mioloOutrasCaracteristicas &") "
            end if
            set telas = db.execute("select t.id, t.Recurso, tg.NomeGrupo from treinamento t LEFT JOIN treinamento_grupo tg ON tg.id=t.GrupoID where t.sysActive=1 AND t.Recurso<>'' AND LENGTH(t.Detalhamento)>12 AND (t.PerfisEmpresa='' OR ISNULL(t.PerfisEmpresa) OR t.PerfisEmpresa LIKE '%|"& PerfilEmpresaID &"|%') AND (t.Persona='' OR ISNULL(t.Persona) OR t.Persona LIKE '%|"& PerfilPersonaID &"|%') "& sqlOutrasCaracteristicas &" order by ifnull(tg.Ordem,100), ifnull(t.Ordem,100)")

            ultimoGrupo = ""
            while not telas.eof
                if req("T")="" AND PrimeiroID="" then
                    response.Redirect("./?P=Treinamentos&Pers=1&T="& telas("id"))
                end if
                GrupoTreinamento = telas("NomeGrupo")
                PrimeiroID = "N"
                if classActive<>"" then
                    Proximo = telas("id")
                        %>
                        <script>
                            $(document).ready(function(){
                                $("#proximo").attr("onclick", "location.href='./?P=Treinamentos&Pers=1&T=<%= Proximo %>';");
                            });
                        </script>
                        <%
                    classActive = ""
                end if
                if req("T")=telas("id")&"" then
                    classActive = " class='active' "
                    if Anterior="" then
                        %>
                        <script>
                            $(document).ready(function(){
                                $("#anterior").css("display", "none");
                            });
                        </script>
                        <%
                    end if
                    %>
                    <script>
                        $(document).ready(function(){
                            $("#anterior").attr("onclick", "location.href='./?P=Treinamentos&Pers=1&T=<%= Anterior %>';");
                        });
                    </script>
                    <%
                end if

                if ultimoGrupo<>GrupoTreinamento&"" then
                    %>
                    <li class="sidebar-label pt20"><%=GrupoTreinamento&""%></li>
                    <%
                end if

                ultimoGrupo=GrupoTreinamento&""
                %>
                <li <%= classActive %>>
                    <a href="./?P=Treinamentos&Pers=1&T=<%= telas("id") %>"><span class="fa fa-file-text bigger-110"></span> <span class="sidebar-title"><%= telas("Recurso") %></span></a>
                </li>
                <%
                Anterior = telas("id")
            telas.movenext
            wend
            telas.close
            set telas = nothing
    end if
end select

if session("AutoConsolidar")="" then
    session("AutoConsolidar")="N"
    set conf = db.execute("select AutoConsolidar from sys_config where AutoConsolidar='S'")
    if not conf.eof then
        session("AutoConsolidar") = "S"
    end if
end if

if session("AutoConsolidar")="S" then
    %>
    <iframe id="AutoConsolidar" width="100%" height="300" style="visibility:hidden" src="about:blank" height="200"></iframe>
    <%
end if
if Proximo="" then
    %>
    <script>
        $(document).ready(function(){
            $("#proximo").css("display", "none");
        });
    </script>
    <%
end if
%>
<script>


function __loadMsgs(){
            $("#myModalMsgs").remove()
            $("body").append(`
             <div id="myModalMsgs" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
               <div class="modal-dialog modal-lg">
                 <div class="modal-content p10">
                   <div style="text-align: center; margin-bottom: 100px" class="row">
                           <div class="col-md-12">
                               <i class="fa fa-2x fa-circle-o-notch fa-spin" style="color: rgba(0,0,0,0.2); margin-top: 50px"></i>
                           </div>
                       </div>
                 </div>
               </div>
             </div>`);
             $("#myModalMsgs").modal('show')
             $("#myModalMsgs").modal('show')
         fetch(domain+"/sistemas-de-mensagens?tk="+localStorage.getItem("tk"),
                {headers: {
                      "x-access-token":localStorage.getItem("tk"),
                       'Accept': 'application/json',
                       'Content-Type': 'application/json'
               }
         })
         .then((r) => r.text())
         .then((r) => {
            $("#myModalMsgs .modal-content").html(r)
        });


}
</script>