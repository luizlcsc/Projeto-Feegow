<%
if FALSE AND session("Franqueador")<>"" and "clinic"&session("FranqueadorID")=session("Banco") then

    server.Execute("FranqueadorTop.asp")

else
        IF  session("Status") = "F" THEN %>
        <%
            menuClass          = ".menu-click-pre-espera, .menu-click-espera,.menu-click-financeiro,.menu-click-tiss,.menu-click-estoque,.menu-click-relatorio,.menu-click-configuracao"
            menuRightClass     = " .menu-right-caixa button, .menu-right-tarefas button, .menu-right-notificacoes button, .menu-right-chat button"
            submenuClass       = ".sub-menu-click-agenda-agenda-de-cirurgias, .sub-menu-click-agenda-mapa-de-agenda, .sub-menu-click-agenda-equipamentos-alocados, .sub-menu-click-agenda-consultar-valores, .sub-menu-click-agenda-confirmar-agendamentos, .sub-menu-click-agenda-checkin, .sub-menu-click-agenda-pendencias, .sub-menu-click-agenda-multipla-por-filtros, .sub-menu-click-agenda-multipla, .sub-menu-click-agenda-multipla-por-locais, .sub-menu-click-agenda-semanal"
            submenuMeuPerfil   = ".menu-click-meu-perfil-muda-local, .menu-click-meu-perfil-arquivos, .menu-click-meu-perfil-minhas-faturas, .menu-click-meu-perfil-abrir-fechar-baixa, .menu-click-meu-perfil-logs-de-acoes, .menu-click-meu-perfil-ponto-eletronico"
            submenuMeuCadastro = ".sub-menu-click-base-de-conhecimento,.sub-menu-click-cadastro-propostas,.sub-menu-click-cadastro-profissionais,.sub-menu-click-cadastro-profissionais-externos,.sub-menu-click-cadastro-procedimentos,.sub-menu-click-cadastro-locais-de-atendimentos,.sub-menu-click-cadastro-laudos,.sub-menu-click-cadastro-funcionarios,.sub-menu-click-cadastro-fornecedores,.sub-menu-click-cadastro-equipamentos,.sub-menu-click-cadastro-contas-fornecedores,.sub-menu-click-cadastro-contas-correntes,.sub-menu-click-cadastro-contatos"

            abamenuMeuPerfil = ".menu-aba-meu-perfil-especialidades,.menu-aba-meu-perfil-grupo-de-profissionais,.menu-aba-meu-perfil-profissionais-externos,.menu-aba-meu-perfil-profissionais,.menu-aba-meu-perfil-meus-repasses,.menu-aba-meu-perfil-extrato,.menu-aba-meu-perfil-compartilhamento,.menu-aba-meu-perfil-permissoes,.menu-aba-meu-perfil-integracao-stone,.menu-aba-meu-perfil-assinatura-digital,.menu-aba-meu-perfil-certificado-digital,.menu-aba-meu-perfil-integracao-memed,.menu-aba-meu-perfil-integracao-google,.menu-aba-meu-perfil-procedimentos-da-agenda"
            abamenuPaciente  = ".menu-aba-pacientes-laudos-formularios,.menu-aba-pacientes-diagnosticos,.menu-aba-pacientes-textos-e-atestados,.menu-aba-pacientes-pedidos-de-exame,.menu-aba-pacientes-produtos-utilizados,.menu-aba-pacientes-linha-do-tempo,.menu-aba-pacientes-imagens,.menu-aba-pacientes-arquivos,.menu-aba-pacientes-recibos,.menu-aba-pacientes-propostas,.menu-aba-pacientes-conta"
            btns  = ".btn-inserir-funcionario"

            classesBloqueadas = menuClass&","&menuRightClass&","&submenuClass&","&submenuMeuPerfil&","&abamenuMeuPerfil&","&abamenuPaciente&","&btns&","&submenuMeuCadastro

            paginasPermitidasObj = Split("Agenda-1,Agenda-S,AgendaMultipla,Checkin,ConfirmacaoDeAgendamentos,EquipamentosAlocados,pacientes,Pacientes,Home,profissionais,Profissionais,Convenios,convenios",",")

            permissaoAPagina = false

            FOR ival=0 to ubound(paginasPermitidasObj)
                IF paginasPermitidasObj(ival) = req("P") THEN
                    permissaoAPagina = TRUE
                END IF
            NEXT
            IF NOT permissaoAPagina THEN
               Response.Redirect "?P=Home&Pers=1"
            END IF
        %>
        <style>
              <%= classesBloqueadas%>
              {
                 cursor: not-allowed !important; pointer-events: none !important; opacity: 0.5;
              }
        </style>
        <script>
            var textModal = `Este recurso é muito útil, mas, infelizmente, não está disponível nesta versão :(
                             <br/> Caso queira conhecer nossos planos e solicitar a versão completa, entre em contato com nosso time comercial!
                             <br/>
                             <div style="text-align: right"> <button class="btn btn-success btn-sm" type="button">Quero solicitar a versão completa!</button></div>`;

            $(function() {
                setTimeout(function(){
                   $("<%=btns %>").each((key,tag) =>{
                                    $(tag).parent().click(() => {$("#modal-recurso-indisponivel").modal();}).css("cursor","not-allowed");
                   });
                }, 200);
                $("<%=classesBloqueadas %>").each((key,tag) =>{
                         $(tag).parent().click(() => {$("#modal-recurso-indisponivel").modal();}).css("cursor","not-allowed");
                });
            });
        </script>
    <% END IF %>

    <%
    if device()="" then
            if Aut("|agenda")=1 or session("Table")="profissionais" then%>
    <li class="<%=classMenu %>">
        <a href="#" class="dropdown-toggle menu-click-agenda" onclick="return false;" data-toggle="dropdown">
            <%=abreSpanTitulo %> <i class="far fa-calendar hidden"></i> <span class=""> Agenda </span> <span class="caret ml5"></span> <%= fechaSpanTitulo %>
        </a>
        <ul class="dropdown-menu">
            <li class="sub-menu-click-agenda-diaria"><a href="./?P=Agenda-1&Pers=1"><i class="far fa-calendar-day"></i> Diária</a></li>
            <li class="sub-menu-click-agenda-semanal"><a href="./?P=Agenda-S&Pers=1"><i class="far fa-calendar-week"></i> Semanal</a></li>
            <%if Aut("|agenda")=1 then%>
            <li class="hidden sub-menu-click-agenda-multipla-por-locais"><a href="./?P=QuadroDisponibilidade&Pers=1"><i class="far fa-star"></i> Múltipla por Locais</a></li>
		        <%
                if Aut("|agendaV|")=1  then
                    %>
                    <li class="sub-menu-click-agenda-multipla"><a href="./?P=AgendaMultipla&Pers=1"><i class="far fa-calendar-alt"></i> Múltipla</a></li>
                    <% IF getConfig("AcessoAgendamentoOnline") <> "0" AND getConfig("AcessoAgendamentoOnline") <> "0"  THEN %>
                        <li class="sub-menu-click-agenda-multipla"><a href="javascript:void(0)" onclick="openAgendamentoOnline()">Agedamento Online</a></li>
                        <script>
                            function openAgendamentoOnline() {
                                $.get("https://api.feegow.com.br/agendamento-online/redirect-token", (data) => {
                                        window.open(`https://paciente.feegow.com.br/agendamento/<%=getConfig("AcessoAgendamentoOnline")%>/?tk=${data.content}`,'_blank');
                                });
                            }
                        </script>
                    <% END IF %>
		            <%
                end if
                ModuloCallCenter = recursoAdicional(41)=4

                if Aut("|agendaV|")=1 and ModuloCallCenter then
                    if aut("agendamultfiltros")=1 then
                    %>
                    <li class="sub-menu-click-agenda-multipla-por-filtros"><a href="./?P=MultiplaFiltros2&Pers=1"><i class="far fa-calendar-star"></i> Múltipla por Filtros <span class="label label-alert label-xs fleft">Beta</span> </a></li>
                    <%
                    end if
                end if
		        if Aut("|agendaA|")=1 or Aut("agendaaheckin")=1  or Aut("confirmaragendamentos")=1 then %>
                <li class="divider"></li>
                <%
                if Aut("agendaaheckin")=1 then
                %>
                <li class="sub-menu-click-agenda-checkin"><a href="./?P=Checkin&Pers=1"><i class="far fa-calendar-check"></i> Check-in</a></li>
                <%
                end if
                if Aut("confirmaragendamentos")=1 then
                %>
                <li  class="sub-menu-click-agenda-confirmar-agendamentos"><a href="./?P=ConfirmacaoDeAgendamentos&Pers=1"><i class="far fa-calendar-exclamation"></i> Confirmar agendamentos</a></li>
                <%
                end if
                if recursoAdicional(24) = 4 then
                %>
                <li class="sub-menu-click-agenda-consultar-valores"><a href="./?P=FilaColeta&Pers=1"><i class="far fa-flask"></i> Fila de coleta <span class="label label-system label-xs fleft">Novo</span> </a></li>
                <%
                end if
                %>
                <li class="hidden sub-menu-click-agenda-consultar-valores"><a href="./?P=ConsultaDePrecos&Pers=1"> Consultar valores <span class="label label-system label-xs fleft">Novo</span> </a></li>
		        <% end if %>
		        <%
		        if aut("agendapendencias")=1 and ModuloCallCenter then
                %>
                <li  class="sub-menu-click-agenda-pendencias"><a href="./?P=Pendencias&Pers=1"><i class="far fa-calendar-exclamation"></i> Pendências <span class="label label-alert label-xs fleft">Beta</span></a></li>
                <%
                end if
                %>
            <%end if%>
            <li class="divider"></li>
            <%if aut("|agendaequipamentosV|")=1 or Aut("|agendaV|")=1 then %>
                <li class="sub-menu-click-agenda-equipamentos-alocados"><a href="./?P=EquipamentosAlocados&Pers=1"><i class="far fa-laptop"></i> Equipamentos Alocados</a></li>
		    <% end if
		    if Aut("|agendaV|")=1 then %>
                <li class="sub-menu-click-agenda-mapa-de-agenda"><a href="./?P=Ocupacao&Pers=1"><i class="far fa-map"></i> Mapa de agenda </a></li>
		    <% end if

            if aut("agendaV")=1 then
                if session("Cir")="" then
                    set vcaCir = db.execute("select id from procedimentos where sysActive=1 and ativo='on' and TipoProcedimentoID=1 limit 1")
                    if vcaCir.eof then
                        session("Cir")=0
                    else
                        session("Cir")=1
                    end if
                end if
            end if

            AgendaCirurgica = recursoAdicional(13)

            if session("Cir")=1 and AgendaCirurgica=4 then
                %>
                <li class="sub-menu-click-agenda-agenda-de-cirurgias"><a href="./?P=listaAgendaCirurgica&Pers=1"><i class="far fa-scalpel"></i> Agenda de Cirurgias</a></li>
                <%
            end if

            if recursoAdicional(37) = 4 and aut("gestaoprotocolosV") = 1 then
            %>
            <li class="divider"></li>
            <li class="sub-menu-click-pacientes-gestaoprotocolos"><a href="./?P=gestaoprotocolos&Pers=1">Gestão de Protocolos <span class="label label-system label-xs fleft">Novo</span></a></li>
            <%
            end if
    %>
        </ul>
    </li>
    <%
        if aut("salaesperaV")=1 or aut("esperaoutrosprofissionaisV")=1 then 
    %>
    <li class="<%=classMenu %>"><a href="./?P=ListaEspera&Pers=1" class="menu-click-espera">
        <%=abreSpanTitulo %> <i class="far fa-clock-o hidden"></i> <span class=""> Espera </span> <%= fechaSpanTitulo %>
        <small style="position:absolute; top:7px; right:0" class="badge badge-danger" id="espera"></small>
        </a>
    </li>

    <%
    end if
    %>
    <%
    end if
    if aut("pacientesV")=1 or aut("pacientesI")=1 or aut("pacientesA")=1 then
    %>
    <li class="<%=classMenu %>"><a href="#" class="dropdown-toggle menu-click-pacientes" data-toggle="dropdown">
        <%=abreSpanTitulo %> <i class="far fa-user hidden"></i> <span class=""> Pacientes </span> <span class="caret ml5"></span> <%= fechaSpanTitulo %>
    
                

                                              </a>
        <ul class="dropdown-menu">
            <%
			      if aut("pacientesI")=1 then%>
                  <li>
                  <a class="sub-menu-click-paciente-incluir" href="./?P=Pacientes&I=N&Pers=1"><i class="far fa-plus"></i> Inserir</a>
                  </li>
            <%end if
			      if (aut("pacientesV")=1 or aut("pacientesA")=1) and PorteClinica <= 3 then%>
                  <li>
                  <a class="sub-menu-click-paciente-listar" href="?P=Pacientes&Pers=Follow"><i class="far fa-list"></i> Listar</a>
                  </li>
            <%end if%>
        </ul>
    </li>
    <%		end if
		    if aut("contatosV")=1 or aut("contatosI")=1 or aut("contatosA")=1 then
    %>
    <%		end if
		    if aut("lctestoque")=1 or aut("produtos")=1 or aut("requisicaoestoqueV")=1 then
                if 1=2 and (session("Banco")="clinic2803" or session("Banco")="clinic100000") then
                    %>
                    <li class="<%=classMenu %>"><a href="./?P=Estoque&Pers=1" class="menu-click-estoque"> <%=abreSpanTitulo %>  <i class="far fa-medkit hidden"></i> <span class=""> Estoque </span> <%= fechaSpanTitulo %> </a>
                    </li>
                    <%
                else
                    %>
                    <li class="<%=classMenu %>"><a href="#" class="dropdown-toggle menu-click-estoque" data-toggle="dropdown">
                        <%=abreSpanTitulo %> <i class="far fa-medkit hidden"></i> <span class=""> Estoque </span> <span class="caret ml5"></span> <%= fechaSpanTitulo %>
                

                                                              </a>
                        <ul class="dropdown-menu">
                            <%
				                    if aut("produtosI")=1 then
                            %>
                            <li>
                                <a href="?P=Produtos&I=N&Pers=1"><i class="far fa-plus"></i> Inserir </a>
                            </li>
                            <%
				                    end if
				                    if aut("produtosA")=1 or aut("produtosV")=1 then
                            %>
                            <li>
                                <a href="?P=ListaProdutos&Pers=1"><i class="far fa-list"></i> Listar </a>
                            </li>
                            <%
				                    end if
                            %>
                            <li class="divider"></li>
                            <%
				                    if aut("produtoskitsV")=1 then
                            %>
                            <li>
                                <a href="?P=ProdutosKits&Pers=Follow"><i class="far fa-medkit"></i> Kits de Produtos</a>
                            </li>
                             <%
                                    end if
                                    if aut("requisicaoestoqueV")=1 then
                             %>
                            <li>
                                <a href="?P=ListaRequisicaoEstoque&Pers=1"><i class="far fa-tasks"></i> Requisição de estoque <span class="label label-system label-xs fleft">Novo</span></a>
                            </li>
                            <%
				                    end if
				                    if aut("lctestoqueI")=1 and 1=2 then
                            %>
                            <li>
                                <a href="?P=unavailable&Pers=1"><i class=""></i> Lan&ccedil;ar Movimento</a>
                            </li>
                            <%
				                    end if
				                    if aut("lctestoqueV")=1 or aut("lctestoqueA")=1 then
                            %>
                            <li class="hidden">
                                <a href="?P=unavailable&Pers=1"><i class=""></i> Posi&ccedil;&atilde;o do Estoque</a>
                            </li>
                            <%
				                    end if
                            %>
                        </ul>
                    </li>
                    <%
                end if
		    end if
		    if aut("contasa")=1 or aut("movement")=1 or aut("repasses")=1 or aut("cappta")=1 then
    %>
    <li class="<%=classMenu %>"><a href="./?P=Financeiro&Pers=1" class="menu-click-financeiro">
        <%=abreSpanTitulo %> <i class="far fa-money hidden"></i> <span class=""> Financeiro </span> <%= fechaSpanTitulo %>
        </a></li>
    <%
		    end if
    %>

    <%
		    if aut("guias")=1 or aut("faturas")=1 then
    %>
    <li class="<%=classMenu %>"><a href="#" class="dropdown-toggle menu-click-tiss" data-toggle="dropdown">
        <%=abreSpanTitulo %> <i class="far fa-credit-card hidden"></i> <span class=""> Faturamento</span> <span class="caret ml5"></span> <%= fechaSpanTitulo %>
                                              </a>
        <ul class="dropdown-menu">
            <%
		    if aut("guiasI")=1 then
            %>
            <li>
                <a href="?P=tissguiaconsulta&I=N&Pers=1"><i class="far fa-plus"></i> Inserir Guia de Consulta</a>
            </li>
        
            <li>
                <a href="?P=tissguiasadt&I=N&Pers=1"><i class="far fa-plus"></i> Inserir Guia de SP/SADT</a>
            </li>
        
            <li>
                <a href="?P=tissGuiaHonorarios&I=N&Pers=1"><i class="far fa-plus"></i> Inserir Guia de Honorários</a>
            </li>
        
            <li>
                <a href="?P=tissguiainternacao&I=N&Pers=1"><i class="far fa-plus"></i> Inserir Guia de Sol. Internação </a>
            </li>
            
            <li>
                <a href="?P=tissguiaquimioterapia&I=N&Pers=1"><i class="far fa-plus"></i> Inserir Guia de Sol. Quimioterapia </a>
            </li>
            <%
			    end if
            %>
            <li class="divider"></li>
            <%
		    if aut("guiasV")=1 or aut("guiasA")=1 then
            %>
            <li>
                <a href="?P=tissbuscaguias&Pers=1"><i class="far fa-list"></i> Buscar Guias</a>
            </li>
            <%
            if aut("loteI")=1  then
            %>
            <li><a href="?P=tissfechalote&Pers=1"><i class="far fa-archive"></i> Fechar Lote</a></li>
            <%
            end if
            if aut("loteV")=1  then
            %>
            <li><a href="?P=tisslotes&Pers=1"><i class="far fa-folder-open"></i> Administrar Lotes</a></li>
            <%
            end if
            %>
            <li class="hidden"><a href="?P=validarlote&Pers=1"><i class="far fa-check-square"></i> Validar Lote </a></li>
            <li><a href="?P=preXML&Pers=1"><i class="far fa-upload"></i> Baixa de Retorno - XML <span class="label label-system label-xs fleft">Novo</span></a></li>
            <%
		    end if
            if aut("conveniosA")=1 then
                %>
                <li><a href="?P=ValoresItens&Pers=1"><i class="far fa-money"></i> Valores de Itens  </a> </li>
                <%
            end if
            %>

        </ul>
    </li>
    <%
		    end if

		    if aut("relatorios")=1 then
    %>
    <li class="<%=classMenu %>"><a href="./?P=Relatorios&Pers=1" class="menu-click-relatorio">
        <%=abreSpanTitulo %> <i class="far fa-bar-chart hidden"></i> <span class=""> Relat&oacute;rios</span> <%= fechaSpanTitulo %>
        </a></li>
    <%
		    end if
    %>

    <li class="<%=classMenu %>"><a href="#" class="dropdown-toggle menu-click-cadastros" data-toggle="dropdown">
        <%=abreSpanTitulo %> <i class="far fa-database"></i> <span class="hidden-sm hidden"> Cadastros</span> <%= fechaSpanTitulo %>

                         </a>
        <ul class="dropdown-navbar dropdown-menu dropdown-caret dropdown-close">
            <li class="dropdown-header"><i class="far fa-database"></i> Cadastros</li>
            <%

    end if 'fechando se device()=""
    if device="" or lcase(req("P"))="cadastros" then
            if session("Admin")=1 and getConfig("GestaoDeAvisos")=1  then
            %>
            <li><a href="./?P=Avisos&Pers=Follow"  class="sub-menu-click-cadastro-avisos" ><i class="fa fa-exclamation-triangle"></i> Avisos</a></li>
            <%
            end if

            if aut("convenios")=1 then
            %>
            <li><a class="sub-menu-click-cadastro-convenio" href="./?P=Convenios&Pers=Follow"><i class="far fa-credit-card"></i> Conv&ecirc;nios</a></li>
            <%
            end if

            if aut("contatos")=1  then
            %>
              <li class="dropdown">
                <a class="sub-menu-click-cadastro-contatos" href="?P=Contatos"><i class="far fa-user"></i> Contatos</a>
              </li>
            <%
            end if

            if aut("|sys_financialcurrentaccountsV|")=1  then
            %>
            <li><a class="sub-menu-click-cadastro-contas-correntes" href="./?P=sys_financialcurrentaccounts&Pers=Follow"><i class="far fa-university bigger-110"></i> Contas Correntes</a></li>
            <%
            end if

            if aut("|equipamentosV|")=1  then
            %>
            <li><a class="sub-menu-click-cadastro-equipamentos" href="./?P=Equipamentos&Pers=Follow"><i class="far fa-laptop"></i> Equipamentos</a></li>
            <%
            end if

            if aut("fornecedores")=1   then
            %>
            <li><a class="sub-menu-click-cadastro-fornecedores" href="./?P=Fornecedores&Pers=Follow"><i class="far fa-archive bigger-110"></i> Fornecedores</a></li>
            <%
            end if

            if aut("funcionarios")=1   then
            %>
            <li><a class="sub-menu-click-cadastro-funcionarios" href="./?P=Funcionarios&Pers=Follow"><i class="far fa-user bigger-110"></i> Funcion&aacute;rios</a></li>
            <%
            end if

            if aut("|formsl")=1   then
            %>
              <li class="dropdown">
                <a href="?P=Laudos&Pers=1" class="sub-menu-click-cadastro-laudos"><i class="far fa-file-text"></i> Laudos</a>
              </li>
              <%  if recursoAdicional(24)=4 then %>

              <% end if %>
            <%
            end if

            if aut("locais")=1  then
            %>
            <li>
                <a href="?P=Locais&Pers=Follow" class="sub-menu-click-cadastro-locais-de-atendimentos"><i class="far fa-map-marker"></i> Locais de Atendimento</a>
            </li>
            <%
            end if
            if aut("medicinaocupacional")=1 and false then
            %>
            <li><a class="sub-menu-click-cadastro-convenio" href="./?P=aso_funcao&Pers=Follow"><i class="far fa-user-plus"></i> Medicina Ocupacional</a></li>
            <%
            end if
            if aut("procedimentos")=1  then
            %>
            <li><a href="./?P=Procedimentos&Pers=Follow" class="sub-menu-click-cadastro-procedimentos"><i class="far fa-stethoscope"></i> Procedimentos</a></li>
            <%
            end if

            if aut("profissionais")=0 and aut("profissionalexterno")=1   then
            %>
            <li><a href="./?P=ProfissionalExterno&Pers=Follow" class="sub-menu-click-cadastro-profissionais-externos"><span class="far fa-user-times bigger-110"></span> Profissionais externos</a></li>
            <%
            end if

            if aut("|profissionaisV|")=1 then
            %>
            <li><a href="./?P=Profissionais&Pers=Follow"  class="sub-menu-click-cadastro-profissionais" ><i class="far fa-user-md bigger-110"></i> Profissionais</a></li>
            <%
            end if

            if getconfig("ExibirProgramasDeSaude") = 1 then
            %>
            <li><a href="./?P=programasdesaude&Pers=1"  class="sub-menu-click-cadastro-profissionais" ><i class="far fa-medkit bigger-110"></i> Programas de Saúde</a></li>
            <%
            end if

            if aut("propostasV")=1  then
            %>
            <li><a href="./?P=buscaPropostas&Pers=1"  class="sub-menu-click-cadastro-propostas" ><i class="far fa-files-o"></i> Propostas</a></li>
            <%
            end if


            if aut("basedeconhecimento")=1 and False then
            %>
            <li><a href="./?P=basedeconhecimento&Pers=Follow"  class="sub-menu-click-base-de-conhecimento" ><i class="far fa-tasks bigger-110"></i> Base de Conhecimento</a></li>
            <%
            end if

            if aut("guiamanual")=1 and false then
            %>
            <li><a href="./?P=GuiaManual&Pers=1"  class="sub-menu-click-guia-manual" ><i class="far fa-paste bigger-110"></i> Guia Manual</a></li>
            <%
            end if

            if aut("riscos")=1 and false then
            %>
            <li><a href="./?P=RiscosFuncao&Pers=1"  class="sub-menu-click-guia-manual" ><i class="far fa-exclamation-triangle bigger-110"></i> Riscos e Funções</a></li>
            <%
            end if
    end if
    if device()="" then
    %>
        </ul>
    </li>
    <li class="<%=classMenu %>"><a href="#" class="dropdown-toggle menu-click-configuracao" data-toggle="dropdown">
        <%=abreSpanTitulo %> <i class="far fa-cog"></i> <span class="hidden-md hidden-xl hidden-lg hidden-sm"> Configurações</span> <%= fechaSpanTitulo %>
                         </a>
        <ul class="dropdown-navbar dropdown-menu dropdown-caret dropdown-close">
            <li class="dropdown-header"><i class="far fa-cog"></i> Configurações</li>
            <%
    end if
    if device()="" or lcase(req("P"))="configuracoes" then
			    if aut("origens")=1 then
            %>
            <li><a href="./?P=Origens&Pers=0"><i class="far fa-list"></i> Origens</a></li>
            <%
			    end if
			    if aut("buiforms")=1  then
            %>
            <li><a href="./?P=buiforms&Pers=Follow"><i class="far fa-bar-chart"></i> Formul&aacute;rios</a></li>
            <%
			    end if
                'Foi colocado na condição a permissão aut("configimpressos")
			    if session("Admin") = 1 or aut("configimpressos")=1  then
            %>
            <li><a href="./?P=ConfigImpressos&Pers=1"><i class="far fa-file bigger-110"></i> Impressos</a></li>
            <%
			    end if
			    if aut("configrateio")=1  then
                    arqP = "RepasseLinear"
            %>
            <li><a href="./?P=<%= arqP %>&Pers=1"><i class="far fa-puzzle-piece bigger-110"></i> Regras de Repasse</a></li>
            <%
			    end if
			    if aut("eventos_emailsms")=1 then
            %>
            <li><a href="./?P=eventos_emailsms&Pers=Follow"><i class="far fa-calendar bigger-110"></i> Eventos de e-mail e SMS</a></li>
            <%
			    end if

			    if aut("chamadaporvoz")=1  then
            %>
            <li><a href="./?P=ChamadaPorVoz&Pers=1"><i class="far fa-volume-up bigger-110"></i> Chamada por Voz</a></li>
            <%
			    end if
			    if aut("sys_financialcompanyunits")=1 then
            %>
            <li><a href="./?P=empresa&Pers=1"><i class="far fa-hospital-o bigger-110"></i> Empresa</a></li>
            <%
			    end if
			    if aut("centrocusto")=1  then
            %>
            <li><a href="./?P=CentroCusto"><i class="far fa-sitemap bigger-110"></i> Centros de Custo</a></li>
            <%
			    end if
			    if aut("formasrecto")=1 then
            %>
            <li>
                <a href="?P=FormaRecto&Pers=1"><i class="far fa-credit-card"></i> Formas de Recebimento</a>
            </li>
            <%
            end if
            if session("Admin")=1 and session("OtherCurrencies")="phone" then
            %>
            <li>
                <a href="?P=chamadasresultados"><i class="far fa-phone"></i> Resultados de Contato</a>
            </li>
            <%
            end if
            if aut("feriados")=1 then
            %>
            <li>
                <a href="?P=feriados&Pers=0"><i class="far fa-road"></i> Feriados</a>
            </li>
            <%
            end if
            if aut("tabelaparticular")=1 then
            %>
            <li>
                <a href="?P=TabelaParticular&Pers=Follow"><i class="far fa-table"></i> Tabelas Particulares </a>
            </li>
            <%
            end if
            if aut("tabelasprecos")=1 then
            %>
            <li>
                <a href="?P=TabelasPreco&Pers=1"><i class="far fa-table"></i> Tabelas de Preço</a>
            </li>
            <%
            end if
            if aut("variacoesprecos")=1 then
            %>
            <li>
                <a href="?P=VariacoesPrecos&Pers=1"><i class="far fa-dollar"></i> Variações de Preços</a>
            </li>
            <%
            end if
            if aut("voucherV")=1 then
            %>
            <li><a href="./?P=voucher&Pers=Follow"  class="sub-menu-click-cadastro-voucher" ><i class="far fa-ticket-alt"></i> Voucher <span class="label label-system label-xs fleft">Novo</span></a></li>
            <%
            end if
            if aut("planocontas")=1 then
            %>
            <li>
                <a href="?P=EditaPlanoContas&Pers=1"><i class="far fa-outdent"></i> Plano de Contas</a>
            </li>
            <%
            end if
            if recursoAdicional(24) = 4 and Aut("labsconfigintegracao") = 1 then
            %>
            <li>
                <a href="?P=labsconfigintegracao"><i class="far fa-flask"></i> Integração Laboratorial</a>
            </li>
            <%
            end if
            if session("Admin")=1 then
            %>
            <li>
                <a href="?P=OutrasConfiguracoes&Pers=1"><i class="far fa-cogs"></i> Outras Configura&ccedil;&otilde;es</a>
            </li>
            <%
            end if
            if session("Banco")="clinic5459" then
            %>
            <li>
                <a href="?P=Treinamentos&Pers=1"><i class="far fa-star"></i> Treinamento</a>
            </li>
            <li>
                <a href="?P=Implantacao&Pers=1"><i class="far fa-star"></i> Implantação</a>
            </li>
            <%
            end if
    end if
    if device()="" then
            %>
        </ul>
    </li>
    <%
    end if
end if
%>
<audio id="audioNotificacao" preload="auto">
    <source src="assets/audio/chat.mp3" type="audio/mpeg">
</audio>