<%
if request.ServerVariables("SERVER_NAME")="clinic.feegow.com.br" and session("banco")="clinic5760" then
'    response.Redirect("http://clinic4.feegow.com.br/v7/?P=Login")
end if

if request.ServerVariables("HTTPS")="off" then
	if request.ServerVariables("REMOTE_ADDR")="::1" OR request.ServerVariables("REMOTE_ADDR")="127.0.0.1" OR left(request.ServerVariables("REMOTE_ADDR"), 7)="192.168" OR request.QueryString("Partner")<>"" OR SESSION("Partner")<>"" then
'		response.Redirect( "https://localhost/feegowclinic/?P="&request.QueryString("P") )
	else
        if request.ServerVariables("SERVER_NAME")="clinic7.feegow.com.br" then
    		response.Redirect( "https://clinic7.feegow.com.br/v7/?P="&request.QueryString("P") )
        end if
        if request.ServerVariables("SERVER_NAME")="clinic8.feegow.com.br" then
    		response.Redirect( "https://clinic8.feegow.com.br/v7/?P="&request.QueryString("P") )
        end if
	end if
end if

if session("User")="" and request.QueryString("P")<>"Login" and request.QueryString("P")<>"Trial" and request.QueryString("P")<>"Confirmacao" then
    QueryStringParameters = Request.QueryString

	response.Redirect("./?P=Login&qs="&Server.URLEncode(QueryStringParameters))
end if

if request.QueryString("P")<>"Login" and request.QueryString("P")<>"Trial" and request.QueryString("P")<>"Confirmacao" then
	if request.QueryString("P")<>"Home" and session("Bloqueado")<>"" then
		response.Redirect("./?P=Home&Pers=1")
	end if
%>
<!--#include file="connect.asp"-->
<!DOCTYPE html>
<html>

<head>
    <meta name="robots" content="noindex">
  <style type="text/css">
       @media print
       {
           .no-print, .no-print *
           {
               display: none !important;
           }
       }

      .form-control {
          min-width:80px;
      }
      .dockmodal-body{
          overflow: hidden!important;
          padding:0 0 0 10px!important;
      }
      body {
          min-height:auto!important;
      }
      .tray-center {
          padding-bottom:60px;
      }
      .btn-spee{
          position:absolute; 
          bottom:12px; 
          right:-18px; 
          display:none!important;
          z-index:100000000000;
      }
      .qf:hover > .btn-spee{
          display:block!important;
      }
	.select-insert li {
		margin:0;
		padding:0;
	}
	.select-insert li {
		cursor:pointer;
		list-style-type:none;
		margin:0;
		padding:3px;
		font-size:14px;
		color:#000;
		background-color:#FFF;
	}
	.select-insert li:hover {
		background-color:#999;
	}
   a[href]:after {
     content: ""!important;
   }
   .rt{
       position:relative!important;
       top:0!important;
   }
   #calls{
       max-height:400px;
       overflow-y:auto;
   }
   textarea::placeholder{
       font-style:italic;
       color:#CCC;
   }
   .ui-pnotify {
       margin-top: 33px!important;
   }
   @media print{
       #content{
           margin-left:-250px!important;
       }
   }

   <% if device()<>"" then %>

    @media (max-width: 815px){
      .timeline-item .panel .panel-body {
          width:100%!important;
          overflow-x:scroll!important;
          padding:15px!important;
      }
      .timeline-item code {
          display:block!important;
          line-height:20px!important;
          #border:1px #999 solid!important;
          margin-top:5px!important;
      }
    }

   body {
       margin-top:100px!important;
   }

   body.sb-l-m #content_wrapper {
    margin-left: 0!important;
    }

   body.sb-l-m #topbar.affix {
    width: auto;
    margin-left: 0!important;
    }
      body.sb-l-m #topbar.affix {
          top: 0 !important;
      }

      #topbar .breadcrumb {
          padding:0!important;
      }
      #topbar .breadcrumb .crumb-active {
    display:block!important;
    font-size:unset!important;
}
    #topbar .breadcrumb .crumb-active > a {
        font-size: unset !important;
    }

    #topbar {
        padding-top:70px!important;
    }

      .sidebar-light {
          color: #777;
          background-color: #fafafa!important;
          border-right: 1px solid #DDD;
      }
      body.sb-l-m .sidebar-menu > li > a > .sidebar-title {
          background-color: #fafafa!important;
          color: #777;
          font-size:12px!important;
          border-left: none!important;
      }

      #timeline.timeline-single > .row > .col-sm-6 {
          padding:0!important;
      }

    <% end if %>


  .blinking{
      animation:blinkingText 1.2s infinite;
  }
  @keyframes blinkingText{
      0%{     color: #FFF;    }
      60%{    color: transparent; }
      100%{   color: #FFF;    }
  }
  </style>

  <link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
  <!-- Meta, title, CSS, favicons, etc. -->
  <meta charset="utf-8">
  <title>Feegow Software :: <%=session("NameUser")%></title>
  <meta http-equiv="Content-Language" content="pt-br">
  <meta name="author" content="Feegow">

    <% if device<>"" then %>
        <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, user-scalable=0, minimum-scale=1.0, maximum-scale=1.0">
    <% else %>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <% end if %>

  <link rel="stylesheet" type="text/css" href="assets/fonts/icomoon/icomoon.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/magnific/magnific-popup.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/footable/css/footable.core.min.css">

  <link rel="stylesheet" href="assets/css/datepicker.css" />
  <link rel="stylesheet" type="text/css" href="vendor/plugins/fullcalendar/fullcalendar.min.css">
  <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">
  <link rel="stylesheet" type="text/css" href="assets/admin-tools/admin-forms/css/admin-forms.css">
  <link rel="shortcut icon" href="assets/img/feegowclinic.ico" type="image/x-icon" />
  <link href="vendor/plugins/select2/css/core.css" rel="stylesheet" type="text/css"> 
  <link href="vendor/plugins/select2/select2-bootstrap.css" rel="stylesheet" type="text/css"> 
  <link rel="stylesheet" href="assets/css/old.css" />
  <link rel="stylesheet" type="text/css" href="vendor/plugins/ladda/ladda.min.css">

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!--[if lt IE 9]>
  <script src="assets/js/html5shiv.js"></script>
  <script src="assets/js/respond.min.js"></script>
<![endif]-->
  <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
  <script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
  <script src="vendor/plugins/select2/select2.min.js"></script>
  <script src="js/components.js?a=30"></script>
  <script src="feegow_components/assets/feegow-theme/vendor/plugins/datatables/media/js/jquery.dataTables.js"></script>

<%if aut("capptaI") then%>
    <script src="assets/js/feegow-cappta.js"></script>
  <%end if%>

  <script src="vendor/plugins/select2/select2.full.min.js"></script>
  <%
  if req("P")="Laudo" and session("Banco")<>"clinic5703" and session("Banco")<>"clinic8039" then
  %>
    <script type="text/javascript" src="ckeditornew2/ckeditor.js"></script>
  <%
  else
  %>
  <script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
  <%
  end if
  %>
  <script src="ckeditornew/adapters/jquery.js"></script>
  <script src="vendor/plugins/footable/js/footable.all.min.js"></script>
  <script src="assets/js/vue-2.5.17.min.js"></script>
  <script src="//cdnjs.cloudflare.com/ajax/libs/list.js/1.5.0/list.min.js"></script>


  <!-- FooTable Addon -->
  <script src="vendor/plugins/footable/js/footable.filter.min.js"></script>
    <script type="text/javascript">
        var ModalOpened = false;

        var feegow_components_path = "/feegow_components/";
        <%
        if request.ServerVariables("REMOTE_ADDR")="::1" OR request.ServerVariables("REMOTE_ADDR")="127.0.0.1" OR instr(request.ServerVariables("REMOTE_ADDR"), "192.168.0.") then
        %>
        feegow_components_path="/feegow_components/index.php/";
        <%
        end if
        %>

        var sessionObj = {
            Table:'<%=session("Table")%>',
            idInTable:'<%=session("idInTable")%>'
        };

        function s2aj(nome, recurso, coluna, campoSuperior, placeholder, oti){
            $.fn.select2.amd.require([
              "select2/core",
              "select2/utils",
              "select2/compat/matcher"
            ], function (Select2, Utils, oldMatcher) {
                var $ajax = $("#"+nome);
                //$ajax.css("display", "none");
                //        $.fn.select2.defaults.set("width", "100%");
                function formatRepo(repo) {
                    if (repo.loading) return repo.text;

                    if(repo.id==-1){
                        if(repo.buscado==""){
                            var markup = "Digite... <div class='select2-result-repository clearfix'>" +
                              "<div class='select2-result-repository__meta'>" +
                                "<div class='select2-result-repository__title'></div>";
                            "</div></div>";
                            markup = "Digite...";
                        }else{
                            var markup = "Nenhum resultado. <button type='button' class='btn btn-success btn-xs btn-inserir-si'>INSERIR</button><div class='select2-result-repository clearfix'>" +
                                      "<div class='select2-result-repository__meta'>" +
                                        "<div class='select2-result-repository__title'></div>";
                                    "</div></div>";

                            if(parseInt(repo.permission) === 0){
                                markup = "";
                                showNoResults();
                            }
                        }
                    }else{
                        if(typeof repo.full_name !== "undefined"){
                            var nascimento = "";
                            if (typeof repo.birth !== "undefined"){
                                nascimento = " - <u>" + repo.birth + "</u>"
                            }
                            var markup = "<div class='select2-result-repository clearfix'>" +
                              "<div class='select2-result-repository__meta'>" +
                                "<div class='select2-result-repository__title'>" + repo.full_name + nascimento +"</div>";
                            "</div></div>";
                        }
                    }
                    return markup;
                }
                function formatRepoSelection(repo) {
                    return repo.full_name || repo.text;
                }
                function showCog(redirectTo) {
                    "use strict";
                    var cog = '<span class="feegow-selectinsert-config"><a href="' + redirectTo + '" class="btn btn-xs btn-primary" style="float: right;margin: 10px;"><i class="fa fa-cog"></i></a></span>',
                        configSelector = ".feegow-selectinsert-config",
                        $dropdown = $(".select2-dropdown");

                    if ($dropdown.find(configSelector).length === 0) {
                        $dropdown.append(cog);
                    }
                    return true;
                }

                function showNoResults() {
                    "use strict";
                    var message = "<span class='m10 feegow-selectinsert-none'>Nenhum resultado.</span>",
                        configSelector = ".feegow-selectinsert-none";
                    setTimeout(function() {
                        var $dropdown = $(".select2-dropdown");
                        $dropdown.find(".btn-inserir-si").parents("li").css("display","none");

                        $dropdown.find("li:empty").css("display","none");

                        if ($dropdown.find("li").length <= 2){
                            if ($dropdown.find(configSelector).length === 0) {
                                $dropdown.append(message);
                            }
                        }
                    },100);

                    return true;
                }

                $ajax.select2({
                    //closeOnSelect: false,
                    placeholder: placeholder,
                    tags: true,

                    ajax: {
                        method: "post",
                        url: "sir.asp",
                        dataType: 'json',
                        delay: 250,
                        data: function (params) {
                            return {
                                q: params.term, // search term
                                page: params.page,
                                t: recurso,
                                c: coluna,
                                cs: $('#'+campoSuperior).is(':visible') ? $('#'+campoSuperior).val() : "",
                                exibir: $ajax.attr("data-exibir"),
                                oti: oti,
                                ProfissionalID: $("#ProfissionalID").val(),
                                EquipamentoID: $("#EquipamentoID").val(),
                                nascimento: $("#ageNascimento").val(),
                                encaixe: $("#Encaixe").attr("checked"),
                                hora: $("#Hora").val(),
                                data: $("#Data").val()
                            };
                        },
                        processResults: function (data, params) {
                            params.page = params.page || 1;
                            if(data.ins){
                                showCog(data.ins);
                            }
                            setTimeout(function() {
                                $(".load-more").remove();
                            }, 300);
                            return {
                                results: data.items,
                                pagination: {
                                    more: (params.page * 30) < data.total_count
                                },

                            };
                        },
                        cache: true
                    },
                    escapeMarkup: function (markup) { return markup; },
                    minimumInputLength: 0,
                    templateResult: formatRepo,
                    templateSelection: formatRepoSelection
                });

                $(".proposta-item-procedimentos .select2-selection").css("max-width", "200px")
                $("#invoiceItens .select2-selection").css("max-width", "400px")
            });
        }
    </script>
      <link rel="stylesheet" type="text/css" href="vendor/plugins/bstour/bootstrap-tour.css">

</head>

<body>
      <%
      if session("Partner")<>"" then
        %>
        <!--#include file="divPartner.asp"-->
        <%
      end if

      if device()<>"" then %>

        <div id="topApp" style="position:fixed; z-index:10000000000; top:0; width:100%; height:65px;" class="bg-primary darker pt20">
            <div id="menu" style="position:absolute; width:260px; height:1000px; top:0; left:-260px; z-index:10000000001; background:#fff">
                <div class="row">
                    <div class="col-md-12">
                            <div class="bg-primary" style="height:80px">
                                <img src="assets/img/logo_white.png" width="120" class="ml15 mt25" border="0">
                            </div>
                            <ul class="nav pt15">
                                <%
                                set men = db.execute("select * from cliniccentral.menu where App=1 order by id")
                                while not men.eof
                                    %>
                                    <li>
                                        <a href="<%= men("URL") %>" class="btn btn-block text-left text-dark" style="border:none" onclick='fechar()'>
                                            <i class="fa fa-<%= men("Icone") %>"></i>
                                            <%= men("Rotulo") %>
                                        </a>
                                    </li>
                                    <%
                                men.movenext
                                wend
                                men.close
                                set men=nothing
                                %>
                            </ul>

                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-xs-4">
                    <button class="btn btn-primary btn-block ml5 bg-primary darker" onclick="abrir()" style="border:none!important"><i class="fa fa-list"></i> MENU</button>
                </div>
                <div class="col-xs-8">





































                </div>
            </div>
        </div>

        <div onclick="fechar(); fecharSubmenu()" id="cortina" style="width:100%; height:100%; display:table; background:rgba(0,0,0,0.4); z-index:10002; position:fixed; top:0; left:0; display:none"></div>






        <div id="bottomApp" style="position:fixed; z-index:100000000000; width:100%; bottom:0; height:50px; background:#3498db;">
            <form class="mn pt5" role="search">
                <div class="col-xs-12">
                    <div class="input-group">
                        <input type="text" class="form-control" placeholder="Busca rápida..." autocomplete="off" name="q">
                        <input name="P" value="Busca" type="hidden">
                        <input name="Pers" value="1" type="hidden">
                        <span class="input-group-btn">
                            <button class="btn btn-default">&nbsp;<i class="fa fa-search"></i>&nbsp;</button>
                        </span>
                    </div>
                    <!-- /input-group -->
                </div>
            </form>
        </div>

        <script type="text/javascript">



        function abrir() {
            fecharSubmenu();
            $( "#menu" ).animate({
            left: "0",
            }, 400, function() {
            // Animation complete.
            });
            $("#cortina").css("display", "block");
        }
        function fechar() {
            $( "#menu" ).animate({
            left: "-260px",
            }, 400, function() {
            // Animation complete.
            });
            $("#cortina").css("display", "none");
        }
        </script>
    <% end if %>



    <div id="disc" class="alert alert-danger text-center hidden" style="position:absolute; z-index:9999; width:100%"></div>

        <div id="modalCaixa" class="modal fade" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content" id="modalCaixaContent">
                Carregando...
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div>

  <aside id="main">
    <%
    recursoUnimed = recursoAdicional(12)
    if device()="" then %>
    <header class="navbar navbar-fixed-top navbar-shadow bg-primary darker" <% if recursoUnimed=4 then %>
    style="background-color: #006600!important;"
 <%end if %> >
      <div class="navbar-branding dark bg-primary" <% if recursoUnimed=4 then %> style="background-color: #005028!important;" <% end if %>>
        <a class="navbar-brand" href="./?P=Home&Pers=1">
                    <%
					if session("Logo")="" then
						Logo = "assets/img/logo_white.png"
					else
						Logo = "/logo/"&session("Logo")
					end if
					%>
          <img class="logol" src="<%=Logo %>" height="32" />
        </a>
                  <span id="toggle_sidemenu_l" class="ad ad-lines"></span>

      </div>
      <ul class="nav navbar-nav navbar-left">


          <%if device()="" then
                classMenu = "dropdown menu-merge hidden-xs apahover text-center"
                abreSpanTitulo = "<span class='sidebar-title'>"
                fechaSpanTitulo = "</span>"
               %>
          <!--#include file="top.asp"-->
          <%end if %>
      </ul>
              <form class="navbar-form navbar-left navbar-search hidden-lg hidden-md hidden-sm hidden-xl" role="search">
                <div class="form-group">
                  <input type="text" autocomplete="off" name="q" class="form-control" placeholder="Busca rápida...">
                </div>
                <input name="P" value="Busca" type="hidden">
                <input name="Pers" value="1" type="hidden">
              </form>

     <ul class="nav navbar-nav navbar-right">

        <%if session("OtherCurrencies")="phone" or recursoAdicional(9)=4 then %>

        <li class="dropdown menu-merge hidden-md hidden-xs">
          <div class="navbar-btn btn-group">
            <button data-toggle="dropdown" class="btn btn-sm dropdown-toggle" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Interações">
              <span class="fa fa-phone fs14 va-m"></span>
            </button>
            <div class="dropdown-menu dropdown-persist w350 animated animated-shorter fadeIn" role="menu">
              <div class="panel mbn">
                  <div class="panel-menu">
                     <span class="panel-icon"><i class="fa fa-phone"></i></span>
                     <span class="panel-title fw600"> Gerenciamento de Contatos</span>
                  </div>
                  <div class="panel-body panel-scroller scroller-navbar scroller-overlay scroller-pn pn">
                      <ol class="timeline-list">

                        <%
                            set canais = db.execute("select * from chamadascanais order by id")
                            while not canais.eof
                                %>
                                <li class="timeline-item">
                                  <div class="timeline-icon bg-dark light">
                                    <span class="fa fa-<%=canais("icone") %>"></span>
                                  </div>
                                  <div class="timeline-desc">
                                    <b><a href="#" onclick="btb(<%=canais("id") %>, <%=canais("Prompt") %>)"><%=canais("NomeCanal") %></a></b>
                                  </div>
                                </li>
                                <%
                            canais.movenext
                            wend
                            canais.close
                            set canais=nothing
                        %>

                      </ol>

                  </div>
                  <div class="panel-footer text-center p7">
                    <button  onclick="location.href='./?P=Chamadas&Pers=1'" type="button" class="btn btn-xs btn-default"> <i class="fa fa-phone-square"></i> Contatos Realizados </button>
                    <button  onclick="location.href='./?P=Funil&Pers=1'" type="button" class="btn btn-xs btn-default"> <i class="fa fa-filter"></i> Funil de Vendas </button>
                  </div>
              </div>
            </div>
          </div>
        </li>
		<%
        end if


		if aut("aberturacaixinha") then
		%>
        <li id="licaixa" title="Abrir/Fechar caixa" class="dropdown menu-merge hidden-sm hidden-xs menu-right-caixa">
          <div class="navbar-btn btn-group">
            <button class="btn btn-sm" type="button" onclick="Caixa();" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Meu Caixa">
              <span class="fa fa-inbox fs14 va-m"></span>

                  <span class="badge badge-success" id="badge-caixa"><%if session("CaixaID")<>"" then%>$<%end if%></span>

            </button>
          </div>
        </li>
		<%
		end if
		%>





        <li id="liTarefasX" class="dropdown menu-merge menu-right-tarefas">
          <div class="navbar-btn btn-group">
            <button id="notifTarefas" data-toggle="dropdown" class="btn btn-sm dropdown-toggle" onclick="notifTarefas();" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Tarefas">
              <span class="fa fa-tasks fs14 va-m"></span>
            </button>
            <div class="dropdown-menu dropdown-persist w350 animated animated-shorter fadeIn" role="menu">
              <div class="panel mbn">
                  <div class="panel-menu">
                     <span class="panel-icon"><i class="fa fa-tasks"></i></span>
                     <span class="panel-title fw600"> Controle de Tarefas</span>
                      <button class="btn btn-default light btn-xs pull-right" type="button" title="Adicionar Tarefa" onclick="location.href='./?P=Tarefas&I=N&Pers=1'"><i class="fa fa-plus"></i></button>
                  </div>
                  <div class="panel-body panel-scroller scroller-navbar pn">
                    <div class="tab-content br-n pn">
                      <div id="divNotiftarefas" class="tab-pane alerts-widget active" role="tabpanel">

                      </div>


                    </div>
                  </div>
                  <div class="panel-footer text-center p7">
                    <button type="button" class="btn btn-default btn-sm" onclick="location.href='./?P=listaTarefas&Tipo=R&Pers=1'">
                    <i class="fa fa-list"></i> Listar tarefas 
                    </button>
                    <%
                    if session("Banco")="clinic5459" then
                    %>
                    <button type="button" class="btn btn-default btn-sm" onclick="location.href='./?P=listaTarefas&Tipo=R&Pers=1&MeusTickets=1'">
                    <i class="fa fa-list"></i> Meus Tickets
                    </button>
                    <%
                    end if
                    %>
                  </div>
              </div>
            </div>
          </div>
        </li>



        <li class="dropdown menu-merge menu-right-notificacoes" id="box-bell">
          <div class="navbar-btn btn-group">
            <button data-toggle="dropdown" class="btn btn-sm dropdown-toggle" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Notificações">
              <span id="bell" class="fa fa-bell<%=animadoGerais%> fs14 va-m"></span>
              <span class="badge badge-danger" id="badge-bell"></span>
            </button>
            <div class="dropdown-menu dropdown-persist w350 animated animated-shorter fadeIn" role="menu">
              <div class="panel mbn">
                  <div class="panel-menu">
                     <span class="panel-icon"><i class="fa fa-bell"></i></span>
                     <span class="panel-title fw600"> Notificações</span>
                  </div>
                  <div class="panel-body panel-scroller scroller-navbar pn">
                    <div class="tab-content br-n pn">
                      <div id="Notificacoes" class="tab-pane alerts-widget active" role="tabpanel">
                          Nenhuma notificação.
                      </div>


                    </div>
                  </div>
                  <div class="panel-footer text-center p7">

                  </div>
              </div>
            </div>
          </div>
        </li>
		<li class="dropdown menu-merge menu-right-chat">
					<div class="navbar-btn btn-group">
	          <button id="toggle_sidemenu_r" class="btn btn-sm" onclick="chatUsers()" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Conversa">
		          <span class="fa fa-comments"></span>
              <span class="badge badge-danger" id="badge-chat"></span>
		          <!-- <span class="caret"></span> -->
	          </button>
	        </div>
		</li>

        <%
        if session("Status")="T" or session("Status")="F" then
        %>
        <script>
            if(localStorage.getItem('tourIsOpen') === null){
                localStorage.setItem('tourIsOpen','1');
            }
        </script>
		<li class="dropdown menu-merge">
                    <div class="navbar-btn btn-group">
              <button id="toggle_sidemenu_tours" class="btn btn-sm" onclick="chatUsers()" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Tutorial">

                  <i class="fa fa-question-circle"></i>
                  <!-- <span class="caret"></span> -->
              </button>
            </div>
        </li>
        <%
        end if
        %>
        <li class="menu-divider hidden-xs hidden-sm hidden-md">
          <i class="fa fa-circle"></i>
        </li>
        <li class="dropdown menu-merge">
          <a href="#" class="dropdown-toggle fw600 p15 menu-click-meu-perfil" data-toggle="dropdown">
          	<img src="<%=session("photo") %>" class="mw30 br64">
          	<span class="hidden-xs hidden-sm hidden-md pl15"> <%=left(session("NameUser"), 15) %> </span>
            <span class="caret caret-tp hidden-xs hidden-sm hidden-md"></span>
          </a>
          <ul class="dropdown-menu list-group dropdown-persist w250" role="menu" style="overflow-y: auto; max-height: 500px">







                            <%
							if session("Partner")="" then
							%>
								<li class="list-group-item menu-click-meu-perfil-meu-perfil">
									<a class="animated animated-short fadeInUp" href="?P=<%=session("Table")%>&Pers=1&I=<%=session("idInTable")%>">
										<i class="fa fa-user"></i>
										Meu Perfil
									</a>
								</li>
                                <%if session("banco")="clinic100000" or session("banco")="clinic5459" then %>
								<li class="list-group-item menu-click-meu-perfil-ponto-eletronico">
									<a class="animated animated-short fadeInUp" href="?P=Ponto&Pers=1">
										<i class="fa fa-hand-o-up"></i>
										Ponto Eletrônico
									</a>
								</li>
                                 <%
                                 end if
                                if session("Admin")=1 then'(session("banco")="clinic2803" or session("banco")="clinic100000" or session("banco")="clinic332") and session("Admin")=1 then %>
								<li class="list-group-item menu-click-meu-perfil-logs-de-acoes">
									<a class="animated animated-short fadeInUp" href="?P=Logs&Pers=1">
										<i class="fa fa-history"></i>
										Logs de Ações
									</a>
								</li>
								
                                 <%
                                 end if
								 'teste
								 if aut("aberturacaixinha")=1 then
								 %>
								   <li class="list-group-item menu-click-meu-perfil-abrir-fechar-baixa">
									<a class="animated animated-short fadeInUp" href="javascript:Caixa()">
										<i class="fa fa-inbox"></i>
										Abrir/Fechar Caixa
									</a>
								   </li>
								 <%
                                 end if
                                 if session("Admin")=1 then

                                 IF session("QuantidadeFaturasAbertas") = "" THEN
                                    set shellExec = createobject("WScript.Shell")
                                    Set objSystemVariables = shellExec.Environment("SYSTEM")
                                    AppEnv = objSystemVariables("APP_ENV")

                                    if AppEnv="production" then

								 %>
                                    <!--#include file="connectCentral.asp"-->
                                    <%session("QuantidadeFaturasAbertas") = "0"
                                    set quantidadeFatura =  dbc.execute(" SELECT COUNT(*) as quant FROM clinic5459.sys_financialinvoices                                                                                      "&chr(13)&_
                                               " LEFT JOIN clinic5459.sys_financialmovement         ON sys_financialmovement.InvoiceID = sys_financialinvoices.id                                        "&chr(13)&_
                                               "                                        AND sys_financialmovement.Type = 'Bill'                                                               "&chr(13)&_
                                               " LEFT JOIN clinic5459.sys_financialdiscountpayments ON sys_financialdiscountpayments.InstallmentID = sys_financialmovement.ID                            "&chr(13)&_
                                               " WHERE sys_financialinvoices.CD ='C' AND AccountID = (SELECT Cliente FROM cliniccentral.licencas WHERE ID = "&replace(session("Banco"), "clinic", "")&") AND AssociationAccountID=3"&chr(13)&_
                                               " and sys_financialinvoices.sysDate > '2019-01-01'                                                                                             "&chr(13)&_
                                               " AND sys_financialinvoices.Value > coalesce(clinic5459.sys_financialdiscountpayments.DiscountedValue,0);                                                ")
                                     IF NOT quantidadeFatura.EOF THEN
                                        session("QuantidadeFaturasAbertas") = quantidadeFatura("quant")
                                     END IF
                                     END IF
                                 END IF


                                 %>
                                    <li class="list-group-item menu-click-meu-perfil-minhas-faturas">
                                        <a class="animated animated-short fadeInUp" href="?P=AreaDoCliente&Pers=1">
                                            <i class="fa fa-barcode"></i>
                                            Minhas Faturas
                                            <% IF session("QuantidadeFaturasAbertas") > "0" THEN %>
                                                <span class="badge badge-danger" id="badge-bell"><%=session("QuantidadeFaturasAbertas")%></span>
                                            <% END IF %>
                                        </a>
                                    </li>
                                  <%
                                  end if
                                 ' if ( session("Banco")="clinic811" or session("Banco")="clinic105" ) AND lcase(session("table"))="profissionais" then
                                 if aut("gerenciamentodearquivos")= 1 then
                                  %>
                                    <li class="list-group-item menu-click-meu-perfil-arquivos">
                                        <a class="animated animated-short fadeInUp" href="?P=Files&Pers=1">
                                            <i class="fa fa-file"></i>
                                            Arquivos
                                        </a>
                                    </li>
							      <%
                                  end if
                                 ' end if
							else
								if session("Admin")=1 then
								%>
								<li class="list-group-item">
									<a class="red animated animated-short fadeInUp" href="?P=Licencas&Pers=1">
										<i class="fa fa-hospital-o"></i>
										Licenças
									</a>
								</li>
								<li class="list-group-item">
									<a class="red animated animated-short fadeInUp" href="?P=Operadores&Pers=1">
										<i class="fa fa-user"></i>
										Operadores
									</a>
								</li>
                                 <%
								end if
								%>

								<li class="list-group-item">
									<a class="green animated animated-short fadeInUp" href="?P=ConfirmAll&Pers=1&Data=<%= date() %>">
										<i class="fa fa-calendar"></i>
										Confirmação Geral
									</a>
								</li>
								<%
							end if


							licencas = session("Licencas")

							if licencas<>"" and instr(licencas,",")>0 then

							    set LicencasSQL = db.execute("SELECT id, NomeEmpresa FROM cliniccentral.licencas WHERE id IN ("&replace(licencas,"|","")&")")

%>

							    <li class="list-group-item animated animated-short fadeInUp p10">
							        <strong class="text-center" style="color: #737373; ">Licenças</strong>
                                </li>
<%
							    while not LicencasSQL.eof

							        LicencaIDLoop = LicencasSQL("id")&""

							    %>
                                <li class="animated animated-short fadeInUp">
                                    <a href='./?P=ChangeCp&LicID=<%=LicencaIDLoop%>&Pers=1'>
                                        <i class="fa <%if LicencaIDLoop=replace(session("Banco"),"clinic","") then%>fa-check-square-o<%else%>fa-square-o<%end if%>"></i>
                                        <%= LicencasSQL("NomeEmpresa") %>
                                    </a>
                                </li>
							    <%
							    LicencasSQL.movenext
							    wend
							    LicencasSQL.close
							    set LicencasSQL=nothing
							end if
							  	  %>


                                <%
								if not isnull(session("Unidades")) and session("Unidades")<>"" then

								    'verifica se o usuario possui apenas uma unidade e nao exibe o "Altera unidade"

								    if instr(session("Unidades"),",")=0 then
								        set UnidadeSQL = db.execute("SELECT id, NomeFantasia FROM (SELECT 0 id, IFNULL(NomeFantasia, NomeEmpresa) NomeFantasia FROM empresa  UNION ALL SELECT id, IFNULL(NomeFantasia, UnitName) NomeFantasia FROM sys_financialcompanyunits where sysActive=1)t")

                                        if not UnidadeSQL.eof then
                                            idUnidade=UnidadeSQL("id")
                                            nomeUnidade=UnidadeSQL("NomeFantasia")

                                            if nomeUnidade&"" <> "" then
								        %>
                                        <li class="list-group-item menu-click-meu-perfil-muda-local">
                                            <a class="animated animated-short fadeInUp">
                                                <i class="fa <%if ccur(idUnidade)=session("UnidadeID") then%>fa-check-square-o<%else%>fa-square-o<%end if%>"></i>
                                                <%= nomeUnidade %>
                                            </a>
                                        </li>
								        <%
								            end if
								        end if
                                    else
                                        %>
                                        <li class="list-group-item">
                                            <a class="animated animated-short fadeInUp" href="javascript:abreModalUnidade(false);">
                                                <i class="fa fa-building"></i>
                                                Alterar Unidade
                                            </a>
                                        </li>
                                        <%
								    end if

								end if

                                'response.write( session("sTopo") )

                                if session("Franquia")<>"" then
								%>
                                <li class="list-group-item">
                                    <a  class="animated animated-short fadeInUp" href="?P=ListaFranquias&Pers=1">
                                        <i class="fa fa-list"></i>
                                        Listar Licenciados
                                    </a>
                                </li>
                                <%
                                end if
                                %>









            <li class="dropdown-footer">
              <a href="./?P=Login&Log=Off" class="">
              <span class="fa fa-power-off pr5"></span> Sair </a>
            </li>
          </ul>
        </li>
      </ul>

    </header>
    <% end if %>
    <!-- End: Header -->

    <!-----------------------------------------------------------------+
       "#sidebar_left" Helper Classes:
    -------------------------------------------------------------------+
       * Positioning Classes:
        '.affix' - Sets Sidebar Left to the fixed position

       * Available Skin Classes:
         .sidebar-dark (default no class needed)
         .sidebar-light
         .sidebar-light.light
    -------------------------------------------------------------------+
       Example: <aside id="sidebar_left" class="affix sidebar-light">
       Results: Fixed Left Sidebar with light/white background
    ------------------------------------------------------------------->

    <!-- Start: Sidebar -->
            <%if device()="" then %>
    <aside id="sidebar_left" class="hidden-print nano nano-light affix sidebar-default has-scrollbar sidebar-light light">

      <!-- Start: Sidebar Left Content -->
      <div class="sidebar-left-content nano-content">

        <!-- Start: Sidebar Header -->
        <header class="sidebar-header">


          <!-- Sidebar Widget - Search (hidden) -->
              <form class="mn pn" role="search">
                  <label for="sidebar-search">
          <div class="sidebar-widget search-widget mn">
            <div class="input-group">
              <span class="input-group-addon">
                <i class="fa fa-search"></i>
              </span>
              <input type="text" id="sidebar-search" autocomplete="off" name="q" class="form-control" placeholder="Busca rápida...">
                <input name="P" value="Busca" type="hidden">
                <input name="Pers" value="1" type="hidden">

            </div>
          </div>
                      </label>
                  </form>

        </header>
        <ul class="nav sidebar-menu" id="lMenu">
            <!--#include file="menuEsquerdo.asp"-->
        </ul>
        <!-- End: Sidebar Menu -->

        <input type="hidden" style="font-size:24px" id="speeFLD" value="" />
      </div>
      <!-- End: Sidebar Left Content -->

    </aside>
    <!-- End: Sidebar Left -->
            <%end if %>

    <!-- Start: Content-Wrapper -->
    <section id="content_wrapper">

      <!-- Start: Topbar-Dropdown -->
      <div id="topbar-dropmenu" class="alt">
        <div class="topbar-menu row">
          <div class="col-xs-4 col-sm-2">
            <a href="#" class="metro-tile bg-primary light">
              <span class="glyphicon glyphicon-inbox text-muted"></span>
              <span class="metro-title">Messages</span>
            </a>
          </div>
          <div class="col-xs-4 col-sm-2">
            <a href="#" class="metro-tile bg-info light">
              <span class="glyphicon glyphicon-user text-muted"></span>
              <span class="metro-title">Users</span>
            </a>
          </div>
          <div class="col-xs-4 col-sm-2">
            <a href="#" class="metro-tile bg-success light">
              <span class="glyphicon glyphicon-headphones text-muted"></span>
              <span class="metro-title">Support</span>
            </a>
          </div>
          <div class="col-xs-4 col-sm-2">
            <a href="#" class="metro-tile bg-system light">
              <span class="glyphicon glyphicon-facetime-video text-muted"></span>
              <span class="metro-title">Videos</span>
            </a>
          </div>
          <div class="col-xs-4 col-sm-2">
            <a href="#" class="metro-tile bg-warning light">
              <span class="fa fa-gears text-muted"></span>
              <span class="metro-title">Settings</span>
            </a>
          </div>
          <div class="col-xs-4 col-sm-2">
            <a href="#" class="metro-tile bg-alert light">
              <span class="glyphicon glyphicon-picture text-muted"></span>
              <span class="metro-title">Pictures</span>
            </a>
          </div>
        </div>
      </div>
      <!-- End: Topbar-Dropdown -->

      <!-- Start: Topbar -->
      <header id="topbar" class="alt affix no-print">
        <div class="topbar-left">

        <% if device()="" then %>
          <ol class="breadcrumb">
            <li class="crumb-active hidden-xs">
              <a></a>
            </li>
            <li class="crumb-icon hidden-xs">
              <a>
                <span class="glyphicon glyphicon-"></span>
              </a>
            </li>
            <li class="crumb-link hidden hidden-sm hidden-xs">
              <a></a>
            </li>
            <li class="crumb-trail hidden"></li>
          </ol>
        <% else %>
          <ol class="breadcrumb">
            <li class="crumb-icon pn">
              <a class="btn btn-sm mn" onclick="abrirSubmenu()" style="max-width:90px; overflow:hidden">
                <span class="glyphicon glyphicon-"></span>
              </a>
            </li>
          </ol>
        <% end if %>
        </div>
        <div class="topbar-right">
          <div class="ib" id="rbtns">

          </div>
        </div>
      </header>
      <!-- End: Topbar -->
      <!-- Begin: Content -->
      <section id="content" class="table-layout animated fadeIn">

          <% if device()<>"" then %>
            <div class="nano-content sidebar-light" id="submenu" style="background-color:#f3f3f3; height:450px; border:1px solid #ccc; position:fixed; width:260px; margin-right:-260px; right:0; top:65px; z-index:10003">
                <ul id="poney" class="nav sidebar-menu" style="height:300px; overflow:scroll">
                    <!--#include file="menuEsquerdo.asp"-->
                </ul>
            </div>
            <script type="text/javascript">
                function abrirSubmenu() {
                  $( "#submenu" ).animate({
                    "margin-right": "0",
                  }, 400, function() {
                    // Animation complete.
                  });
                  $("#cortina").css("display", "block");
                }
                function fecharSubmenu() {
                  $( "#submenu" ).animate({
                    "margin-right": "-260px",
                  }, 400, function() {
                    // Animation complete.
                  });
                  $("#cortina").css("display", "none");
                }


                var alturaSubmenu =  $(window).height() - $("#topApp").outerHeight() - $("#bottomApp").outerHeight() ;
                $("#submenu, #poney").css("height", alturaSubmenu + "px");


            </script>
          <% end if %>



<%
            larguraConteudo = 12
          abreDiv = "<aside class='tray tray-center'><div class='col-xs-"&larguraConteudo&"'>"
          fechaDiv = "</aside>"
              response.Write(abreDiv)

          %>
<div id="modal-youtube-tour" class="modal fade" role="dialog" aria-hidden="true">
    <div class="modal-lg modal-dialog">
        <div class="modal-content"  >
          <div class="modal-body text-center">

          </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<div id="modal-descontos-pendentes" class="modal fade" role="dialog" aria-hidden="true">
    <div class="modal-lg modal-dialog">
        <div class="modal-content"  >
          <div class="modal-body" id="div-descontos-pendentes">
            Carregando...
          </div>

        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>


<% if session("pendImport")<>"" then %>
	<div id="pendImp" style="width:600px; position:fixed; bottom:70px; right:20px; z-index:100000000000000000000000000; background-color:#fff; padding: 10px; border:1px solid #CCC; -webkit-box-shadow: 4px 4px 8px -3px rgba(140,138,140,1); -moz-box-shadow: 4px 4px 8px -3px rgba(140,138,140,1); box-shadow: 4px 4px 8px -3px rgba(140,138,140,1);">
		<h3>IMPORTAÇÃO REALIZADA!</h3>
		<h5>Dependemos da sua validação para os seguintes itens importados:</h5>
		<table class="table table-striped table-bordered table-hover">
			<%
			set pendImp = db.execute("select * from cliniccentral.bancosconferir where isnull(concluido) and LicencaID="& replace(session("Banco"), "clinic", ""))
			while not pendImp.eof
				%>
				<tr id="pendImp<%= pendImp("id") %>">
					<td>
						<%= ucase(pendImp("recursoConferir")&"") %>
					</td>
					<td> <button type="button" class="btn btn-success btn-xs" onclick="staImport(1, <%= pendImp("id") %>, 'ATENÇÃO: Você está informando que conferiu a importação do CADASTRO DE <%= ucase(pendImp("recursoConferir")&"")%>, cujos dados encontram-se importados corretamente. ')"><i class="fa fa-thumbs-up"></i> CONFERIDO</button></td>
					<td> <button type="button" class="btn btn-danger btn-xs" onclick="staImport(0, <%= pendImp("id") %>, 'ATENÇÃO: Você está informando que a importação do CADASTRO DE <%= ucase(pendImp("recursoConferir")&"")%> não está em conformidade com o banco de dados enviado. \nNossa equipe de importação será notificada disso e entrará em contato.\n Caso prefira, você também pode entrar em contato a qualquer momento com nossa equipe de importação no telefone (21) 2018-0123.')"><i class="fa fa-thumbs-up"></i> ALGO DEU ERRADO</button></td>
				</tr>
				<%
			pendImp.movenext
			wend
			pendImp.close
			set pendImp = nothing
			%>
		</table>
		<hr class="short alt">
		<div>Caso queira falar com nossa equipe sobre sua importação, por favor ligue para (21) 2018-0123.
		<br>
		Responsáveis: Allan, Hadassa ou Yuri.</div>
	</div>
	<script type="text/javascript">
		function staImport(Sta, I, msg){
			if(confirm(msg)){
				$.get("importResult.asp?Sta="+Sta+"&I="+I, function(data){ eval(data) });
			}
		}
	</script>
<% end if %>

                     <%
                           if session("Status")="I" then
                          %>
<div class="row">
    <div class="col-md-12">
        <div class="alert alert-danger mt20"><strong>Atenção!</strong> O time Feegow está trabalhando no desenvolvimento da sua área em nosso sistema. Pensando no melhor aproveitamento deste processo, pedimos a você que, por enquanto, não mexa nas configurações, <strong>não adicione ou exclua dados</strong>.</div>
    </div>
</div>
                            <%
                            end if
                            %>
								<!-- PAGE CONTENT BEGINS -->
								<%
								if request.QueryString("P")="" then
									response.Redirect("?P=Home&Pers=1")
								end if
								if request.QueryString("Pers")="1" then
								  FileName = request.QueryString("P")&".asp"
								else
								  FileName = "DefaultContent.asp"
								end if
								set fs=nothing
                
								server.Execute(FileName)
								%>

								<!-- PAGE CONTENT ENDS -->
					            <%=fechaDiv %><!-- /.page-content -->


      </section>
      <!-- End: Content -->

    <% if device()="" then %>
      <!-- Begin: Page Footer -->

      <%
      if session("AtendimentoTelemedicina")&""<>"" and Request.QueryString("P")="Pacientes"  then
      %>
    <!--#include file="react/telemedicina/main.asp"-->
    <%
    end if
    %>

      <footer id="content-footer" class="affix no-print">
        <div class="row">
          <div class="col-md-6 hidden-xs">


              <div class="bs-component">
                <!--#include file="Classes/Base64.asp"-->
                  <div class="btn-group">

                  <button type="button" class="btn btn-xs btn-success light" data-toggle="tooltip" data-placement="top" title="Tutoriais em vídeo"
                  onclick='openComponentsModal(`VideoTutorial.asp?refURL=<%=Base64Encode(request.QueryString())%>`, true, `Central de Vídeos`,``,`xl`,``)'>
                  <i class="fa fa-video-camera"></i> Vídeo-aula
                  </button>         

                      <%if session("Admin")<>1 AND recursoAdicional(12)=4 then%>
                      <%else%>

                      <button type="button" onclick="location.href='./?P=AreaDoCliente&Pers=1'" class="btn btn-xs btn-default">
                          <i class="fa fa-question-circle"></i> Suporte
                      </button>
                      <%end if%>
                      <button type="button" class="btn btn-xs btn-default">
                          Feegow Clinic : v. 7.0
                      </button>
                      <%

                        ChamadaDeSenha = recursoAdicional(2)

                        if ChamadaDeSenha=4 then
                          %>
                            <button type="button" class="btn btn-xs btn-default callTicketBtn" onclick="callTicket()" disabled>
                                <i class="fa fa-users"></i> Chamar senha
                            </button>
                            <%
                        end if
                        %>
                     <%
                           if recursoAdicional(17)=4 then
                          %>
                            <button type="button" class="btn btn-xs btn-default" onclick="facialRecognition()">
                                <i class="fa fa-smile"></i> Reconhecimento facial
                            </button>
                            <%
                            end if
                            %>
                            <% IF session("Banco")<>"clinic7126" THEN %>
                                <span class="btn btn-warning btn-xs internetFail" style="display:none">Sua internet parece estar lenta</span>
                            <% END IF %>
                  </div>
              </div>



              <input type="hidden" id="timeInat" value="0" />
              <script type="text/javascript">
                  setInterval(function () {
                      var timeInat = parseInt($("#timeInat").val()) + 5000;
                      $("#timeInat").val(timeInat);
                      if (timeInat > 40000) {
                          $(".internetFail").fadeIn();
                      }
                      else{
                          $(".internetFail").fadeOut();
                      }
                  }, 5000);
              </script>
          </div>
          <div class="col-md-6 text-right">
              <%
              if session("Status")="I" and false then
                %>
                <span class="label label-danger" style="position:relative; right: 200px;"><strong>Atenção!</strong> Essa licença está em processo de implantação, qualquer dado lançado poderá ser apagado.</span>
                <%
              end if
              %>
            <span class="footer-meta"><b><%=session("NomeEmpresa")%></b></span>
            <a href="#content" class="footer-return-top">
              <span class="fa fa-arrow-up"></span>
            </a>
          </div>
        </div>
      </footer>
      <!-- End: Page Footer -->
    <% end if %>

    </section>
    <!-- End: Content-Wrapper -->

    <!-- Start: Right Sidebar -->
    <aside id="sidebar_right" class="nano affix has-scrollbar">

      <!-- Start: Sidebar Right Content -->
      <div class="sidebar-right-content nano-content">

        <div class="tab-block sidebar-block br-n" style="margin-top: 31px">
          <ul class="nav nav-tabs tabs-border nav-justified hidden">
            <li class="active">
              <a href="#sidebar-right-tab1" data-toggle="tab">Tab 1</a>
            </li>
            <li>
              <a href="#sidebar-right-tab2" data-toggle="tab">Tab 2</a>
            </li>
            <li>
              <a href="#sidebar-right-tab3" data-toggle="tab">Tab 3</a>
            </li>
          </ul>
          <div class="tab-content br-n" style="padding: 0px">
            <div id="sidebar-right-tab1" class="tab-pane active" style="margin: 35px 12px;">
                <div id="notifchat">Carregando...</div>
            </div>
            <div id="sidebar-right-tab2" class="tab-pane">

                <%
                if session("Status")="T" or session("Status")="F" then
                %>
                <div style="text-align: center; background: #1b74b0; color: #ffffff;margin: 20px 0px; padding: 10px">
                    <h5 style="font-size: 17px">
                    <strong><i class="fa fa-angle-down"></i></strong>
                    Primeiros passos</h5>
                </div>
                <style>


                    @font-face {
                         font-family: rubidBold;
                         src: url('assets/recurso-indisponivel/Fonte/Rubik-Bold.ttf');
                    }
                    @font-face {
                         font-family: rubid;
                         src: url('assets/recurso-indisponivel/Fonte/Rubik-Regular.ttf');
                    }

                    .icon-circle-tour{
                       color:#ff6c5a;
                       padding-right: 20px;
                       flex: 10%;text-align: left
                    }

                    .ativeTour .checkbox-custom input[type=checkbox] + label:after,.ativeTour .checkbox-custom input[type=radio] + label:after {
                        position: absolute;
                        font-family: "FontAwesome" !important;;
                        color:#15d093 ;
                        content: "\f00c";
                        font-size: 12px;
                        top: 4px;
                        left: 4px;
                        width: 0;
                        height: 0;
                        transform: rotate(-13deg);
                    }

                    .startTour .checkbox-custom input[type=checkbox] + label:after,.ativeTour .checkbox-custom input[type=radio] + label:after {
                       position: absolute;
                       font-family: "FontAwesome" !important;
                       color: #1b74b0;
                       content: "\f04b";
                       font-size: 12px;
                       top: 3px;
                       left: 7px;
                       width: 0;
                       height: 0;
                    }

                    .startTour .icon-circle-tour{
                       color:#1b74b0;
                       padding-right: 20px;
                       flex: 10%;text-align: left
                    }

                    .ativeTour .icon-circle-tour{
                       color:#15d093;
                       padding-right: 20px;
                       flex: 10%;text-align: left
                    }

                     .icon-circle-tour span{
                         display: block;
                         margin: 5px auto 15px;
                         font-size: 24px;
                    }
                    .text-tour{
                        color: #6e6565;
                        font-family: rubidBold !important;;
                        font-size: 14px;
                        flex: 80%;padding-top: 8px;
                    }

                    .radio-custom label:before, .checkbox-custom label:before {
                        border-color: #a3a3a3;
                    }

                    .ativeTour .radio-custom label:before,.ativeTour .checkbox-custom label:before {
                        border-color: #15d093;
                    }

                    .startTour .radio-custom label:before,.startTour .checkbox-custom label:before {
                        border-color: #1b74b0;
                    }

                    .icon-circle-tour-video{
                          background: url("assets/img/icone-video-vermelho.png");
                          width: 22px;
                          height: 22px;
                          margin-top: 8px;
                          display: block;
                    }
                    .ativeTour .icon-circle-tour-video{
                          background: url("assets/img/icone-video-verde.png");
                    }

                </style>
                <div id="notifchat">
                    <script>
                        function modalVideo(tag) {

                           let iframe = `<iframe id="player" type="text/html" width="800" height="500"
                                                        src="https://www.youtube.com/embed/${tag}?enablejsapi=1"
                                                        frameborder="0"></iframe>`;

                           $("#modal-youtube-tour .modal-body").html(iframe);
                           $("#modal-youtube-tour").modal();

                        }
                    </script>
                    <div class="panel mbn panel-chat">
                            <div id="chatUsers" class="tab-content br-n pn">
                                <ul class="media-list list" role="menu">
                                    <li class="media" style="cursor:pointer" tourName="convenio" >
                                        <div class="bs-component" style="margin-left: 20px;">
                                            <div style="display: flex;" >
                                             <div style="flex: 10%;padding-top: 8px;text-align: left" onclick="startTour('convenio')">
                                                <div class="checkbox-custom mb5" style=" pointer-events: none !important;">
                                                    <input type="checkbox"  id="checkboxExample1">
                                                    <label for="checkboxExample1">&nbsp</label>
                                                </div>
                                             </div>
                                             <div class="text-tour" onclick="startTour('convenio')">
                                                 Adicionar um convênio
                                              </div>
                                              <div class="icon-circle-tour">
                                                    <div onclick="modalVideo('q2NdBbqwh9U')" class="icon-circle-tour-video">&nbsp;</div>
                                              </div>
                                            </div>
                                       </div>
                                    </li>

                                    <li class="media " style="cursor:pointer"  tourName="paciente" >
                                        <div class="bs-component" style="margin-left: 20px;">
                                            <div style="display: flex;">
                                             <div style="flex: 10%;padding-top: 8px;text-align: left" onclick="startTour('paciente')">
                                                <div class="checkbox-custom mb5" style="pointer-events: none !important;">
                                                    <input type="checkbox"  id="checkboxExample8">
                                                    <label for="checkboxExample8">&nbsp</label>
                                                </div>
                                             </div>
                                             <div class="text-tour" onclick="startTour('paciente')">
                                                 Cadastrar Paciente
                                              </div>
                                                 <div  class="icon-circle-tour">
                                                   <div onclick="modalVideo('_K7c9ip_S18');" class="icon-circle-tour-video">&nbsp;</div>
                                              </div>
                                            </div>
                                       </div>
                                    </li>
                                    <li class="media" style="cursor:pointer" tourName="HorarioAtendimento">
                                        <div class="bs-component" style="margin-left: 20px;">
                                            <div style="display: flex;">
                                             <div style="flex: 10%;padding-top: 8px;text-align: left"  onclick="startTour('HorarioAtendimento')">
                                                <div class="checkbox-custom mb5" style=" pointer-events: none !important;">
                                                    <input type="checkbox"  id="checkboxExample8">
                                                    <label for="checkboxExample8">&nbsp</label>
                                                </div>
                                             </div>
                                             <div class="text-tour" style="padding-top: 0px"  onclick="startTour('HorarioAtendimento')">
                                                Configurar horários de atendimento
                                              </div>
                                                 <div class="icon-circle-tour">
                                                  <div onclick="modalVideo('23Lya4tN_ss');" class="icon-circle-tour-video">&nbsp;</div>
                                              </div>
                                            </div>
                                       </div>
                                    </li>
                                      <li class="media" style="cursor:pointer" tourName="Agendamento" >
                                        <div class="bs-component" style="margin-left: 20px;">
                                            <div style="display: flex;">
                                             <div style="flex: 10%;padding-top: 8px;text-align: left" onclick="startTour('Agendamento')">
                                                <div class="checkbox-custom mb5" style=" pointer-events: none !important;">
                                                    <input type="checkbox"  id="checkboxExample8">
                                                    <label for="checkboxExample8">&nbsp</label>
                                                </div>
                                             </div>
                                             <div class="text-tour" onclick="startTour('Agendamento')">
                                               Inserir um agendamento
                                              </div>
                                              <div class="icon-circle-tour">
                                                     <div onclick="modalVideo('bNPwMGcoCVc');" class="icon-circle-tour-video">&nbsp;</div>
                                              </div>
                                            </div>
                                       </div>
                                    </li>
                                    <li class="media" style="cursor:pointer"  tourName="AtenderPaciente" >
                                        <div class="bs-component" style="margin-left: 20px;">
                                            <div style="display: flex;">
                                             <div style="flex: 10%;padding-top: 8px;text-align: left" onclick="startTour('AtenderPaciente')">
                                                <div class="checkbox-custom mb5" style=" pointer-events: none !important;">
                                                    <input type="checkbox"  id="checkboxExample8">
                                                    <label for="checkboxExample8">&nbsp</label>
                                                </div>
                                             </div>
                                             <div class="text-tour" onclick="startTour('AtenderPaciente')">
                                                Atender um paciente
                                              </div>
                                                 <div class="icon-circle-tour">
                                                    <div onclick="modalVideo('62JHa3LndOY');" class="icon-circle-tour-video">&nbsp;</div>
                                              </div>
                                            </div>
                                       </div>
                                    </li>

                                </ul>
                                <!-- <img width="100%" style="width: 100%;height: 100%" src="https://i.pinimg.com/originals/ff/bb/3a/ffbb3afc87b0a7b5809453f4b7d0bf88.gif"> -->
                            </div>
                    </div>
                </div>
                <%
                end if
                %>
            </div>
            <div id="sidebar-right-tab3" class="tab-pane"></div>
          </div>
          <!-- end: .tab-content -->
        </div>
      </div>
    </aside>
    <!-- End: Right Sidebar -->

  </div>

<%if session("ChatSuporte")="S" then%>
<!-- BEGIN JIVOSITE CODE {literal} -->
<script type='text/javascript'>
(function(){ var widget_id = '3j2XOJKoQb';var d=document;var w=window;function l(){
var s = document.createElement('script'); s.type = 'text/javascript'; s.async = true; s.src = '//code.jivosite.com/script/widget/'+widget_id; var ss = document.getElementsByTagName('script')[0]; ss.parentNode.insertBefore(s, ss);}if(d.readyState=='complete'){l();}else{if(w.attachEvent){w.attachEvent('onload',l);}else{w.addEventListener('load',l,false);}}})();</script>
<!-- {/literal} END JIVOSITE CODE -->

<%end if%>


  <!-- End: Main -->

  <!-- BEGIN: PAGE SCRIPTS -->

  <!-- jQuery -->

  <!-- HighCharts Plugin -->
  <script src="vendor/plugins/highcharts/highcharts.js"></script>
<%
    'desabilitando pra ver no que da
    if 1=2 then %>

  <!-- JvectorMap Plugin + US Map (more maps in plugin/assets folder) -->
  <script src="vendor/plugins/jvectormap/jquery.jvectormap.min.js"></script>
  <script src="vendor/plugins/jvectormap/assets/jquery-jvectormap-us-lcc-en.js"></script>

  <!-- Bootstrap Tabdrop Plugin -->
  <script src="vendor/plugins/tabdrop/bootstrap-tabdrop.js"></script>
<%end if %>
  <!-- FullCalendar Plugin + moment Dependency -->
  <script src="vendor/plugins/fullcalendar/lib/moment.min.js"></script>
  <script src="vendor/plugins/fullcalendar/fullcalendar.min.js"></script>

  <!-- jQuery Validate Plugin-->
  <script src="assets/admin-tools/admin-forms/js/jquery.validate.min.js"></script>

  <!-- jQuery Validate Addon -->
  <script src="assets/admin-tools/admin-forms/js/additional-methods.min.js"></script>

  <!-- Theme Javascript -->
  <script src="assets/js/utility/utility.js"></script>
  <script src="assets/js/demo/demo.js"></script>
  <script src="assets/js/main.js"></script>
  <script src="assets/admin-tools/admin-forms/js/jquery.spectrum.min.js"></script>

  <!-- Widget Javascript -->
  <script src="assets/js/demo/widgets.js"></script>

  <script src="vendor/plugins/pnotify/pnotify.js"></script>
  <script src="vendor/plugins/ladda/ladda.min.js"></script>
  <script src="vendor/plugins/magnific/jquery.magnific-popup.js"></script>

    <!-- old sms -->
    	<script type="text/javascript" src="assets/js/qtip/jquery.qtip.js"></script>
		<script src="assets/js/typeahead-bs2.min.js"></script>
		<script src="assets/js/jquery.maskMoney.js" type="text/javascript"></script>

		<!-- page specific plugin scripts -->
		<script src="assets/js/jquery-ui-1.10.3.custom.min.js"></script>
		<script src="assets/js/jquery.ui.touch-punch.min.js"></script>
		<script src="assets/js/jquery.gritter.min.js"></script>
        <script src="assets/js/jquery.slimscroll.min.js"></script>
		<script src="assets/js/jquery.hotkeys.min.js"></script>
		<script src="assets/js/bootstrap-wysiwyg.min.js"></script>
        <script src="assets/js/jquery.easy-pie-chart.min.js"></script>
		<script src="assets/js/jquery.sparkline.min.js"></script>
		<script src="assets/js/flot/jquery.flot.min.js"></script>
		<script src="assets/js/flot/jquery.flot.pie.min.js"></script>
			<!-- table scripts -->
		<script src="assets/js/jquery.dataTables.min.js"></script>
		<script src="assets/js/bootbox.min.js"></script>
		<script src="assets/js/jquery.dataTables.bootstrap.js"></script>


		<!--[if lte IE 8]>
		  <script src="assets/js/excanvas.min.js"></script>
		<![endif]-->

		<script src="assets/js/chosen.jquery.min.js"></script>
		<script src="assets/js/fuelux/fuelux.spinner.min.js"></script>
		<script src="assets/js/date-time/bootstrap-datepicker.min.js"></script>
		<script src="assets/js/date-time/bootstrap-timepicker.min.js"></script>
		<script src="assets/js/date-time/moment.min.js"></script>
		<script src="assets/js/date-time/daterangepicker.min.js"></script>
		<script src="assets/js/bootstrap-colorpicker.min.js"></script>
		<script src="assets/js/jquery.knob.min.js"></script>
		<script src="assets/js/jquery.autosize.min.js"></script>
		<script src="assets/js/jquery.inputlimiter.1.3.1.min.js"></script>
		<script src="assets/js/jquery.maskedinput.min.js"></script>
		<script src="assets/js/bootstrap-tag.min.js"></script>
		<script src="assets/js/x-editable/bootstrap-editable.min.js"></script>
		<script src="assets/js/x-editable/ace-editable.min.js"></script>
        <script type="text/javascript" src="assets/js/bootstrap-datetimepicker.min.js"></script>
        <script type="text/javascript" src="assets/js/bootstrap-datetimepicker.pt-BR.js"></script>
        <script src="assets/js/tracking-min.js"></script>
        <script src="assets/js/face-min.js"></script>

		<!-- ace scripts -->

		<script src="assets/js/ace-elements.min.js"></script>
		<script src="assets/js/ace.min.js"></script>
	<script type="text/javascript">
/*	    function fajx() {
	        ninput = $("#isi" ).val().replace("select2-", "");
	        $.post("sii.asp", {
	            v:$("#isival").val(),
	            t:ninput,
	            campoSuperior:$("#"+ninput).attr("data-campoSuperior"),
	            showColumn:$("#"+ninput).attr("data-showColumn"),
	            resource:$("#"+ninput).attr("data-resource")
	        }, function (data) {
	            $("#" + ninput ).select2("close");
	            eval( data );
	        });
	    }


	    $(document).ready(function(){
	        $(".dropdown").hover(function(){
	            $(this).addClass("open");
	        });
	        $(".dropdown").mouseleave(function(){
	            $(this).removeClass("open");
	        });
	    });
*/
	<!--#include file="jQueryFunctions.asp"-->

function itemSubform(tbn, act, reg, cln, idc, frm){
	$.ajax({
		type: "POST",
		url: "callSubform.asp?tbn="+tbn+"&act="+act+"&reg="+reg+"&cln="+cln+"&idc="+idc+"&frm="+frm,
		data: $('#'+frm).serialize(),
		success: function( data )
		{
			$("#div"+tbn).html(data);
		}
	});
}

function ajxContent(P, I, Pers, Div, ParametrosAdicionais){
    if(!ParametrosAdicionais){
        ParametrosAdicionais="";
    }

	$.ajax({
		type: "POST",
		url: "ajxContent.asp?P="+P+"&I="+I+"&Pers="+Pers+"&q=<%=TirarAcento(req("q"))%>&Div="+Div+ParametrosAdicionais,
		success: function( data )
		{
			//alert(data);
			$("#"+Div).html(data);
		}
	});
}

function callTicket (pacienteId) {
        var license = '<%= session("Banco") %>';
        var licenseId = license.replace("clinic", "");
        openComponentsModal('totem-queue/admin/home-vue', {pacienteId: pacienteId}, false, true, false, "lg")
}

function facialRecognition () {
	    openComponentsModal('facerecognition/get-face', false, false, true, false, "lg")
}

function openSelecionarLicenca(isbackdrop=true){
    let backdrop={};
    if(isbackdrop){
        backdrop={backdrop: 'static', keyboard: false};
    }
  $.post("loginescolhelicenca.asp", '', function(data){
      $("#modalCaixa").modal(backdrop);
      $("#modalCaixaContent").html(data);
  });
}

function openRedefinirSenha(){
     openComponentsModal("RedefinirSenha.asp",{
              T:'<%=session("Table")%>',
              I:'<%=session("idInTable")%>',
            },"Alteração de senha",true, 
              function(){
                $("#frmAcesso").submit();
              },"md",false);
}

$(document).ready(function() {
    $(".callTicketBtn").attr("disabled", false);
    $(".facialRecogButton").attr("disabled", false);

    //SEQUENCIA DE MODAIS DE ABERTURA AUTOMATICA

    <%
    if session("SelecionarLicenca")&"" = "1"  then %>
    if (!ModalOpened){
      ModalOpened = true;
      openSelecionarLicenca();
    }
    <% end if%>
    
    <% if session("UnidadeID")=-1 then %>
    if (!ModalOpened){
      ModalOpened = true;
        abreModalUnidade();
    }
    <% end if %>
    
    <% if session("AlterarSenha") = 1 then %>
    if (!ModalOpened){
      ModalOpened = true;
      openRedefinirSenha();
    }
    <% end if%>

});

var mensagemPaciente = true;
<%
if session("Atendimentos")<>"" then
	splAtendimentos = split(session("Atendimentos"), "|")
	contaAtendimentos = 0
	for z=0 to ubound(splAtendimentos)
		if splAtendimentos(z)<>"" and isnumeric(splAtendimentos(z)) then
			set atendimento = db.execute("select * from atendimentos where id="&splAtendimentos(z))
			if not atendimento.EOF then
				PacienteID = atendimento("PacienteID")
				set pac = db.execute("select NomePaciente from pacientes where id="&PacienteID)
				if not pac.eof then
					contaAtendimentos = contaAtendimentos+1
					strAtendimentos = strAtendimentos&"<a id=""agePac"&PacienteID&""" class=""btn btn-warning btn-xs btn-block"" href=""?P=Pacientes&Pers=1&I="&PacienteID&""">Voltar para: "&pac("NomePaciente")&"</a>"
				end if
			end if
		end if
	next

	if contaAtendimentos=1 and lcase(request.QueryString("P"))="pacientes" and request.QueryString("I")<>cstr(PacienteID) then
		Exibe = "S"
	elseif contaAtendimentos=1 and lcase(request.QueryString("P"))<>"pacientes" then
		Exibe = "S"
	elseif contaAtendimentos>1 then
		Exibe = "S"
	else
		Exibe = "N"
	end if

	if Exibe="S" then
	%>
	new PNotify({
			title: 'Atendimento<%if contaAtendimentos>1 then%>s<%end if%> em curso',
			text: '<%=strAtendimentos%>',
			image: 'assets/img/Doctor.png',
			icon: '',
			sticky: true,
			type: 'system',
			hide: false
		});
	<%
	end if
end if
%>

var constanteRetornou = true;

function constante(){
    if(constanteRetornou){
        constanteRetornou = false;
        $.ajax({
            type:"POST",
            url:"constante.asp?AgAberto="+ $("#AgAberto").val() +"&P=<%= req("P") %>",
            data: {
                qs: '<%=Server.URLEncode(Request.QueryString)%>'
            },
            success:function(data){
                constanteRetornou = true;
                eval(data);
            }
        });
	}
}

function callSta(callID, StaID){
	$.get("callSta.asp?callID="+callID+"&StaID="+StaID, function(data){ eval(data) });
}

<%

    if session("OtherCurrencies")="phone" then
	    %>
	    setTimeout(function(){constante()}, 1500);
	    setInterval(function(){constante()}, 7000);
	    <%
    else
	    %>
	    setTimeout(function(){constante()}, 3000);
	    setInterval(function(){constante()}, 18000);
	    <%
    End If

%>


function callTalk(D, P, Da, Div){
	$.ajax({
		type:"POST",
		url:"pageCallTalk.asp?D="+D+"&P="+P+"&Da="+Da,
		success:function(data){
			$("#"+Div).html(data);
			//$("#"+Div).animate({ scrollTop: 90000 }, "slow");
			$("#"+Div).slimScroll({ scrollTo: '900000' });
		}
	});
}

function statusChat(I){
  let De = I;
  let Para = '<%=session("user")%>';

  $.ajax({
		type:"POST",
		url:"chatStatus.asp?De="+De+"&Para="+Para+"&Visualizado=1",
		success:function(data){
			eval(data);
		}
	});
}

function chatUpdate(I){
  $.get("UpdateChat.asp?ChatID="+I, function(data){
    $("#body_"+I).html(data);
    $("#body_"+I).slimScroll({ scrollTo:'900000'});
    chatBlink(I,true);
  });
}

function chatBlink(I,isBlink){
      if (isBlink){
        $("#chat_"+I).parent().prev().find(".title-text").addClass("blinking");
      }else{
        $("#chat_"+I).parent().prev().find(".title-text").removeClass("blinking");
      }
}

function callWindow(I, T){
/*	$.ajax({
		type:"POST",
		url:"callJanelaChat.asp?ChatID="+I,
		success:function(data){
			$("#chat_"+I).html(data);
			$("#chat_"+I).css("display", "block");
			$("#body_"+I).slimScroll({ scrollTo: '900000' });
			openChat(I);
		}
	});
    $("#chat_"+I).dockmodal({
        initialState: "docked",
        title: T,
        width: 300,
        height: 400,
        showPopout: false
    });
    */

    $.get("callJanelaChat.asp?ChatID="+I, function(data){
        $("#chat_"+I).html(data).dockmodal({
            initialState: "docked",
            title: T,
            width: 300,
            height: 400,
            showPopout:false,
            restore: function(e,dialog){
              chatBlink(I,false);
              statusChat(I);
            },
            close: function (e, dialog) {
                        // do something when the button is clicked
                // alert("fechou");
                //$("#chat_"+I).html("");
                $("#chat_"+I).css("display", "none");
                closeChat(I);
            },
            open: function (e, dialog) {
                $("#chat_"+I).css("display", "block");
                $("#body_"+I).slimScroll({ scrollTo: '900000' });
                openChat(I);
                // do something when the button is clicked
                // alert("abriu");
            }
        });
    });
    //closeChat(<%=chatID%>); colocar isso quando fechar o chat pra gravar a sessao de que ta fechado

}
function closeChat(I){
	$("#chat_"+I).css("display", "none");
	$.ajax({
	   type:"POST",
	   url:"chatSessions.asp?T=C&I="+I,
	   success:function(data){
		   }
	});
}
function openChat(I){
	$("#chat_"+I).css("display", "block");
	$("#body_"+I).slimScroll({ scrollTo: '900000' });
	$.ajax({
	   type:"POST",
	   url:"chatSessions.asp?T=O&I="+I,
	   success:function(data){
		   }
	});
}
function chatUsers(){
  let pesquiArgs="";

  if($("#txtPesquisar").length==1){
    pesquiArgs = $("#txtPesquisar").val()  =="" ? "": "?Pesq="+$("#txtPesquisar").val();
  }

	$.ajax({
		type:"POST",
		url:"chatNotificacoes.asp"+pesquiArgs,
		success:function(data){

      $("#notifchat").html(data);
		}
	});
}

function notifTarefas(){
	$.ajax({
		type:"POST",
		url:"notifTarefas.asp",
		success:function(data){
			$("#divNotiftarefas").html(data);
		}
	});
}

/*$(document).ready(function(){
	$(".chat").submit(function(){
		$.ajax({
			type:"POST",
			url:"saveChat.asp",
			data:$(this).serialize(),
			success:function(data){
				$(".cx-mensagem").val('');
				eval(data);
			}
		});
		return false;
	});
});*/

function Caixa(){
	$.post("Caixa.asp", '', function(data, status){ $("#modalCaixa").modal("show"); $("#modalCaixaContent").html(data); });
}
function btb(T, ppt, Contato) {
    if(ppt==1){
        bootbox.prompt("Digite o telefone com DDD ou E-mail", function(result) {
            if (result === null) {
                //Example.show("Prompt dismissed");
            } else {
                ajxContent('GenerateCall&Contato='+Contato+'&Numero='+result, T, 1, 'calls');
            }
        });
    }else if(ppt==0){
        ajxContent('GenerateCall&Contato='+Contato+'&Numero=', T, 1, 'calls');
    }else{
        ajxContent('GenerateCall&Contato='+Contato+'&Numero='+ppt, T, 1, 'calls');
    }

}


function mfp(im){
    $.magnificPopup.open({
        removalDelay: 500,
        closeOnBgClick:false,
        //modal: true,
        items: {
            src: im
        },
        // overflowY: 'hidden', //
        callbacks: {
            beforeOpen: function(e) {
                this.st.mainClass = "mfp-zoomIn";
            }
        }
    });

}

function mfpform(im){
    $.magnificPopup.open({
        removalDelay: 500,
        closeOnBgClick:false,
        modal: true,
        items: {
            src: im
        },
        // overflowY: 'hidden', //
        callbacks: {
            beforeOpen: function(e) {
                this.st.mainClass = "mfp-zoomIn";
            }
        }
    });

}


$('[data-rel=tooltip]').tooltip();


function abreModalUnidade(backdrop=true){
    if(backdrop){
        //backdrop={backdrop: 'static', keyboard: false};
    }else{
        backdrop={};
    }
    $.post("LoginEscolheUnidade.asp", '', function(data){
        $(document).ready(function() {
            $("#modalCaixa").modal(backdrop);
            $("#modalCaixaContent").html(data);
        });
    });
}
</script>
    <!-- old sms << -->




  <script type="text/javascript">
  jQuery(document).ready(function() {

    "use strict";

    // Init Demo JS
    //Demo.init();


    // Init Theme Core
    Core.init();


    // Init Widget Demo JS
    // demoHighCharts.init();

    // Because we are using Admin Panels we use the OnFinish
    // callback to activate the demoWidgets. It's smoother if
    // we let the panels be moved and organized before
    // filling them with content from various plugins

    // Init plugins used on this page
    // HighCharts, JvectorMap, Admin Panels

    // Init Admin Panels on widgets inside the ".admin-panels" container






    $('.admin-panels').adminpanel({
      grid: '.admin-grid',
      draggable: true,
      preserveGrid: true,
      // mobile: true,
      onStart: function() {
        // Do something before AdminPanels runs
      },
      onFinish: function() {
        $('.admin-panels').addClass('animated fadeIn').removeClass('fade-onload');

        // Init the rest of the plugins now that the panels
        // have had a chance to be moved and organized.
        // It's less taxing to organize empty panels
        demoHighCharts.init();
        runVectorMaps(); // function below
      },
      onSave: function() {
        $(window).trigger('resize');
      }
    });


    // Init plugins for ".calendar-widget"
    // plugins: FullCalendar
    //
    $('#calendar-widget').fullCalendar({
      // contentHeight: 397,
      editable: true,
      events: [{
          title: 'Sony Meeting',
          start: '2015-05-1',
          end: '2015-05-3',
          className: 'fc-event-success',
        }, {
          title: 'Conference',
          start: '2015-05-11',
          end: '2015-05-13',
          className: 'fc-event-warning'
        }, {
          title: 'Lunch Testing',
          start: '2015-05-21',
          end: '2015-05-23',
          className: 'fc-event-primary'
        },
      ],
      eventRender: function(event, element) {
        // create event tooltip using bootstrap tooltips
        $(element).attr("data-original-title", event.title);
        $(element).tooltip({
          container: 'body',
          delay: {
            "show": 100,
            "hide": 200
          }
        });
        // create a tooltip auto close timer
        $(element).on('show.bs.tooltip', function() {
          var autoClose = setTimeout(function() {
            $('.tooltip').fadeOut();
          }, 3500);
        });
      }
    });


    // Init plugins for ".task-widget"
    // plugins: Custom Functions + jQuery Sortable
    //
    var taskWidget = $('div.task-widget');
    var taskItems = taskWidget.find('li.task-item');
    var currentItems = taskWidget.find('ul.task-current');
    var completedItems = taskWidget.find('ul.task-completed');

    // Init jQuery Sortable on Task Widget
    taskWidget.sortable({
      items: taskItems, // only init sortable on list items (not labels)
      handle: '.task-menu',
      axis: 'y',
      connectWith: ".task-list",
      update: function( event, ui ) {
        var Item = ui.item;
        var ParentList = Item.parent();

        // If item is already checked move it to "current items list"
        if (ParentList.hasClass('task-current')) {
            Item.removeClass('item-checked').find('input[type="checkbox"]').prop('checked', false);
        }
        if (ParentList.hasClass('task-completed')) {
            Item.addClass('item-checked').find('input[type="checkbox"]').prop('checked', true);
        }

      }
    });

    // Custom Functions to handle/assign list filter behavior
    taskItems.on('click', function(e) {
      e.preventDefault();
      var This = $(this);
      var Target = $(e.target);

      if (Target.is('.task-menu') && Target.parents('.task-completed').length) {
        This.remove();
        return;
      }

      if (Target.parents('.task-handle').length) {
		      // If item is already checked move it to "current items list"
		      if (This.hasClass('item-checked')) {
		        This.removeClass('item-checked').find('input[type="checkbox"]').prop('checked', false);
		      }
		      // Otherwise move it to the "completed items list"
		      else {
		        This.addClass('item-checked').find('input[type="checkbox"]').prop('checked', true);
		      }
      }

    });


    $(document).bind('keydown', function(e) {
        if(e.ctrlKey && (e.which == 74)) {
            e.preventDefault();
            return false;
        }
    });

      //    $(".select2-single").select2();


      // Init Ladda Plugin on buttons
    Ladda.bind('.ladda-button', {
        timeout: 2000
    });

      // Bind progress buttons and simulate loading progress. Note: Button still requires ".ladda-button" class.
    Ladda.bind('.progress-button', {
        callback: function(instance) {
            var progress = 0;
            var interval = setInterval(function() {
                progress = Math.min(progress + Math.random() * 0.1, 1);
                instance.setProgress(progress);

                if (progress === 1) {
                    instance.stop();
                    clearInterval(interval);
                }
            }, 200);
        }
    });
  });

  </script>
  <!-- END: PAGE SCRIPTS -->

<div style="position:fixed; width:100%; z-index:200000; bottom:0; height:25px; background-color:#903; color:#FFF; padding:3px; display:none" id="legend">
	<marquee id="legendText"></marquee>
</div>
<iframe width="250" id="speak" name="speak" height="195" scrolling="no" style="position:fixed; bottom:0; left:0; display:none" frameborder="0" src="about:blank"></iframe>

<div class="hidden">
<%
splChatWindows = split(session("UsersChat"), "|")
for i=0 to ubound(splChatWindows)
	if splChatWindows(i)<>"A" and splChatWindows(i)<>"" then
		if instr(splChatWindows(i), "A") then
			chatID = replace(splChatWindows(i), "A", "")
			De = session("User")
			Para = chatID
			scrollBaixo = scrollBaixo&"$(""#body_"&chatID&""").slimScroll({ scrollTo: '900000' });"
      set buscaChatName = db.execute("select lu.Nome from sys_users u left join cliniccentral.licencasusuarios lu ON lu.id=u.id where u.id="&Para)

      Nome=""
      if not buscaChatName.eof then
        Nome = buscaChatName("Nome")
      end if
			%>
			<div class="widget-box pull-right" id="chat_<%=chatID%>" style="height:350px; width:100%; margin:0 7px 0 7px;">
			<!--#include file="janelaChat.asp"-->
            </div>
            <script>
                callWindow(<%=ChatID%>, '<%=Nome%>');
            </script>
			<%
		else
			De = session("User")
			Para = chatID
			chatID = splChatWindows(i)
			%>
			<div id="chat_<%=chatID%>"></div>
            <%
		end if
	end if
next
%>
</div>
<%
if session("OtherCurrencies")="phone" then
    %>
    <div id="calls" style="position:fixed; right:10px; bottom:10px; width:350px; border-radius:10px; background-color:#fff; border:1px solid #ccc; display:none; box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);"></div>
    <script type="text/javascript">
        function recontatar(I){
            $.get("constante.asp?Recontatar="+I, function(data){
                eval(data);
            })
        }
    </script>

    <%
end if
%>
			<script type="text/javascript">
			$(document).ready(function(){
			<%=scrollBaixo%>



                if("false"==="<%=session("AutenticadoPHP")%>"){
                    authenticate("-<%= session("User") * (9878 + Day(now())) %>Z", "-<%= replace(session("Banco"), "clinic", "") * (9878 + Day(now())) %>Z");
                }else{
					if(localStorage.getItem("tk")){
						$.ajaxSetup({
							headers: { 'x-access-token': localStorage.getItem("tk") }
						});
					}
				}
			});

			<% IF request.QueryString("limitExceeded")="1" THEN %>
                _type = '<%=request.QueryString("P")%>';
			    if(!sessionStorage.getItem("limitExceeded"+_type)){sessionStorage.setItem("limitExceeded"+_type,1);}

               let _msgModal = {};
                _msgModal['pacientes'] ={
                    msg:`Você atingiu o limite máximo de pacientes, ficamos super felizes com o sucesso da sua clínica!<br/>Caso queira conhecer nossos planos e solicitar a versão completa, entre em contato com nosso time comercial!`,
                    titulo: "Parabens você atingiu 100 pacientes!",
                    redirect: "?P=pacientes&Pers=Follow",
                }

                _msgModal['profissionais'] ={
                msg:`Você atingiu o limite máximo de profissionais, ficamos super felizes com o sucesso da sua clínica!<br/>Caso queira conhecer nossos planos e solicitar a versão completa, entre em contato com nosso time comercial!`,
                titulo: "Você possui 1 profissional!",
                redirect: "?P=pacientes&Pers=Follow",
            }

                let objMsgModal = _msgModal[_type];
                openModal(`${objMsgModal.msg}<br/> <div style="text-align: right">
                                        <button class="btn btn-success btn-sm" type="button">Quero solicitar a versão completa!</button>
                </div>`,objMsgModal.titulo);


			<% END IF %>



			</script>
            <!--#include file="speech.asp"-->
<%
if session("Status")="T" or session("Status")="F" then
%>
            <script src="vendor/plugins/bstour/bootstrap-tour.js"></script>
            <script src="src/tour.js"></script>
            <!--#include file="RecursoBloqueado.asp"-->

<%
end if
%>
</body>
<%
if device()<>"" then
    %>
<script >
$("body").addClass("sb-l-m");
</script>
    <%
end if
%>
</html>
<% Elseif request.QueryString("P")="Trial" then%>
	<!--#include file="Trialxxx.asp"-->
<% Elseif request.QueryString("P")="Confirmacao" then%>
	<%=server.Execute("Confirmacao.asp")%>
<% Else %>
	<!--#include file="Login.asp"-->
<% End If %>

<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-54670639-4"></script>
<script>
 window.dataLayer = window.dataLayer || [];
 function gtag(){dataLayer.push(arguments);}
 gtag('js', new Date());

 gtag('config', 'UA-54670639-4');
</script>

<script>
function chatNotificacao(titulo, mensagem) {
    let options = {
      body: mensagem,
      icon: "https://clinic7.feegow.com.br/v7/assets/img/logo_white_icon.png",
      silent: true
  };
  // Verifica se o browser suporta notificações
  if (!("Notification" in window)) {
    alert("Este browser não suporta notificações de Desktop");
  }
  // Let's check whether notification permissions have already been granted
  else if (Notification.permission === "granted") {
    // If it's okay let's create a notification
    let notification = new Notification(titulo, options);
  }
  // Otherwise, we need to ask the user for permission
  else if (Notification.permission !== 'denied') {
    Notification.requestPermission(function (permission) {
      // If the user accepts, let's create a notification
      if (permission === "granted") {
        let notification = new Notification(titulo, options);
      }
    });
  }
  // At last, if the user has denied notifications, and you
  // want to be respectful there is no need to bother them any more.
}

</script>