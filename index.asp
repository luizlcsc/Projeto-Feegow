<%
if session("User")="" and req("P")<>"Login" and req("P")<>"Trial" and req("P")<>"Confirmacao" then
    QueryStringParameters = request.QueryString

	response.Redirect("./?P=Login&qs="&Server.URLEncode(QueryStringParameters))
end if
%>
<!--#include file="Classes/Environment.asp"-->
<%
AppEnv = getEnv("FC_APP_ENV", "local")
WootricToken = getEnv("FC_WOOTRIC_TOKEN", "")
currentVersionFolder = replace(replace(Request.ServerVariables("PATH_INFO"),"index.asp",""),"/","")


if req("P")<>"Login" and req("P")<>"Trial" and req("P")<>"Confirmacao" then
	if req("P")<>"Home" and session("Bloqueado")<>"" then
		response.Redirect("./?P=Home&Pers=1")
	end if
%>
<!--#include file="connect.asp"-->
<%
if session("PastaAplicacaoRedirect")&"" = "" then
  set licencaConsulta = db.execute("select PastaAplicacao from cliniccentral.licencas where id = "&replace(session("Banco"), "clinic", "")) 
  session("PastaAplicacaoRedirect") = licencaConsulta("PastaAplicacao")
end if

prodVersions = Array("base","main","v8","v7.6")

if AppEnv="production" and in_array(currentVersionFolder, prodVersions) then
  if session("PastaAplicacaoRedirect")<>currentVersionFolder then
    QueryStringParameters = request.QueryString

	  response.Redirect("/"&session("PastaAplicacaoRedirect")&"?"&QueryStringParameters)
  end if
end if
%>
<!DOCTYPE html>
<html>

<head>
  <meta name="robots" content="noindex">
  <meta name="msapplication-TitleColor" content="#3595d9">
  <meta name="theme-color" content="#3595d9">

  <style type="text/css">

    @font-face {
         font-family: "Open Sans";
         src: url('https://cdn.feegow.com/feegowclinic-v7/assets/fonts/open-sans/OpenSans-Regular.ttf');
    }
    .fake{
        height: 39px;
        width: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
        border: 1px solid #dddddd;
        border-radius: 0 4px 4px 0;
    }
    .tooltip{
          z-index:99999999; overflow: visible !important;overflow: visible !important;
      }
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
      #footer-whats{
          background-color: red;
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
          #content_wrapper{
            position: initial!important;
            margin-left: 0!important;
          }
          .navbar.navbar-fixed-top + #sidebar_left + #content_wrapper{
            padding-top:0!important;
          }
          #sidebar_left{
            display:none;
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
          /* ### BUG MOBILE
          margin-top:100px!important;
          */
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

  <link type="text/css" rel="stylesheet" href="https://cdn.feegow.com/feegowclinic-v7/assets/js/qtip/jquery.qtip.css" />
  <!-- Meta, title, CSS, favicons, etc. -->
  <meta charset="utf-8">
  <title>Feegow</title>
  <meta http-equiv="Content-Language" content="pt-br">
  <meta name="author" content="Feegow">

    <% if device<>"" then %>
        <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0, user-scalable=0, minimum-scale=1.0, maximum-scale=1.0">
    <% else %>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <% end if %>

  <link rel="stylesheet" type="text/css" href="https://cdn.feegow.com/feegowclinic-v7/assets/fonts/icomoon/icomoon.css">
  <link rel="stylesheet" type="text/css" href="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/magnific/magnific-popup.css">
  <link rel="stylesheet" type="text/css" href="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/footable/css/footable.core.min.css">
  <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.15.4/css/all.css" integrity="sha384-rqn26AG5Pj86AF4SO72RK5fyefcQ/x32DNQfChxWvbXIyXFePlEktwD18fEz+kQU" crossorigin="anonymous">

  <link rel="stylesheet" href="https://cdn.feegow.com/feegowclinic-v7/assets/css/datepicker.css" />
  <link rel="stylesheet" type="text/css" href="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/fullcalendar/fullcalendar.min.css">
  <link rel="stylesheet" type="text/css" href="./assets/skin/default_skin/css/fgw.css?version=8.0.14.0">
  <link rel="stylesheet" type="text/css" href="./assets/admin-tools/admin-forms/css/admin-forms.css">
  <link rel="shortcut icon" href="./assets/img/feegowclinic.ico" type="image/x-icon" />
  <link href="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/select2/css/core.css" rel="stylesheet" type="text/css">
  <link href="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/select2/select2-bootstrap.css" rel="stylesheet" type="text/css">
  <link rel="stylesheet" href="https://cdn.feegow.com/feegowclinic-v7/assets/css/old.css" />
  <link rel="stylesheet" type="text/css" href="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/ladda/ladda.min.css">

  <link href="https://cdn.feegow.com/feegowclinic-v7/assets/fonts/material-design-icons/css/materialdesignicons.min.css" rel="stylesheet">

  <style>
  /*===============================================
    Custom Scrollbar
  ================================================= */
  /* width */
  ::-webkit-scrollbar {
  width: 10px;
  }

  /* Track */
  ::-webkit-scrollbar-track {
  background: #f1f1f1;
  }

  /* Handle */
  ::-webkit-scrollbar-thumb {
  background: #888;
  }

  /* Handle on hover */
  ::-webkit-scrollbar-thumb:hover {
  background: #555;
  }
  </style>
  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!--[if lt IE 9]>
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/html5shiv.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/respond.min.js"></script>
  <![endif]-->
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/jquery/jquery-1.12.4.min.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/select2/select2.min.js"></script>
  <script src="js/components.js?v=1.1.6"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/datatables/media/js/jquery.dataTables.js"></script>

    <%if aut("capptaI") then%>
    <script src="assets/js/feegow-cappta.js"></script>
    <%end if%>

  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/select2/select2.full.min.js"></script>
  <%
  if req("P")="Laudo" and session("Banco")<>"clinic5703" and session("Banco")<>"clinic8039" then
  %>
    <script type="text/javascript" src="https://cdn.feegow.com/feegowclinic-v7/ckeditornew2/ckeditor.js"></script>
  <%
  else
  %>
  <script type="text/javascript" src="https://cdn.feegow.com/feegowclinic-v7/ckeditornew/ckeditor.js"></script>
  <%
  end if
  %>
  <script src="https://cdn.feegow.com/feegowclinic-v7/ckeditornew/adapters/jquery.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/footable/js/footable.all.min.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/vue-2.5.17.min.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/js/list.min.js"></script>
  <script type="text/javascript" src="https://cdn.feegow.com/feegowclinic-v7/vendor/wootric/wootric-sdk.js"></script>
  

  <%
    if session("MasterPwd") <> "S" then
  %>

  <!-- begin Wootric code -->
  <script type="text/javascript">   
    let dataCadastro = <% if session("DataCadastro")<>"" then response.write(session("DataCadastro")) else response.write("null") end if %>;
    
    const token = "<%=WootricToken%>";

    if (token == null) {
      console.error("account_token está vazio!");
    }

    // window.wootric_survey_immediately = true; // Shows survey immediately for testing purposes. TODO: Comment out for production.

    window.wootricSettings = {
      admin: "<% if session("Admin")=1 then response.write("Sim") else response.write("Não") end if %>",
      nomeUnidade: "<%=session("NomeEmpresa")%>",
      tipoUsuario: "<%=lcase(Session("Table"))%>",
      licencaID: "<%=LicenseID%>",
      numeroUsuarios: "<%=session("UsuariosContratadosS")%>",
      razaoSocial: "<%=session("RazaoSocial")%>",
      statusLicenca: "<%=StatusLicenca%>",
      urlSistema: window.location.href,
      pastaRedicionamento: '<%= session("PastaAplicacaoRedirect") %>',
      email: '<%=session("Email")%>', // TODO: Required to uniquely identify a user. Email is recommended but this can be any unique identifier.
      external_id: "<%=session("User")%>", // TODO: Reference field for external integrations only. Send it along with email. OPTIONAL
      created_at: dataCadastro, // TODO: The current logged in user's sign-up date as a 10 digit Unix timestamp in seconds. OPTIONAL
      account_token: token // This is your unique account token.
    };

    window.wootric('run');
  </script>
  <!-- end Wootric code -->

  <% end if %>


  <script type="text/javascript">

        const pastas =  ['/base/','/main/','/v7.6/'];

        const redirVersao = () => {
            try{
              var PastaAplicacaoRedirect = '<%=session("PastaAplicacaoRedirect")%>'
              var __currentPage = window.location.href;

              let __force = false;

              if(sessionStorage.hasOwnProperty('force')){
                  __force = true;
              }

              if(window.location.href.includes("force")){
                  __force = true;
                  sessionStorage.setItem("force","1");
              }


              if(!window.location.href.includes(PastaAplicacaoRedirect) && !__force && !window.location.href.includes("localhost") ){
                 pastas.forEach((item) => {
                      __currentPage = __currentPage.replace(item,`/${PastaAplicacaoRedirect}/`)
                  });

                  if(__currentPage != window.location.href){
                    window.location.href = (__currentPage);
                  }
              }
            }catch (e) {

            }
        }

        <%
        if AppEnv="production" then
        %>
        redirVersao();
        <%
        end if
        %>
  </script>

  <!-- FooTable Addon -->
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/footable/js/footable.filter.min.js"></script>
    <script type="text/javascript">
        var ModalOpened = false;

        var feegow_components_path = "<%=componentslegacyurl%>";
        <%
        if request.ServerVariables("REMOTE_ADDR")="::1" OR request.ServerVariables("REMOTE_ADDR")="127.0.0.1" OR instr(request.ServerVariables("REMOTE_ADDR"), "192.168.0.") then
        %>
        feegow_components_path="<%=componentslegacyurl%>index.php/";
        <%
        end if
        %>

      
        initComponents({
          apiUrl: '<%=getEnv("FC_API_URL","")%>'
        });

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
                    var cog = '<span class="feegow-selectinsert-config"><a href="' + redirectTo + '" class="btn btn-xs btn-primary" style="float: right;margin: 5px;"><i class="fal fa-cog"></i></a></span>',
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
                                cs: ($('#'+campoSuperior).is(':visible')) ? $('#'+campoSuperior).val() : "",
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

                $(".proposta-item-procedimentos .select2-container").css("max-width", "200px")
                $("#invoiceItens .select2-container").css("max-width", "400px")
            });
        }
    </script>
      <link rel="stylesheet" type="text/css" href="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/bstour/bootstrap-tour.css">
</head>

<body>
        <%
        if session("Logo")="" then
            Logo = "assets/img/login_logo.svg"
        else
            Logo = "https://cdn.feegow.com/logos/"&session("Logo")
        end if
        %>

      <%
      if session("Partner")<>"" then
        %>
        <!--#include file="divPartner.asp"-->
        <%
      end if

      if device()<>"" then %>
        <div onclick="fechar(); fecharSubmenu()" id="cortina" class="fade in" style="backdrop-filter:blur(5px);width:100%; height:100%; display:table; background:rgba(128,128,128,0.4); z-index:10002; position:fixed; top:0; left:0; display:none"></div>
        <div id="topApp" style="position:fixed; z-index:10000000000; top:0; width:100%; height:65px;" class=" bg-primary darker pt10">
            <div id="menu" style="position:absolute; width:260px; height:1000px; top:0; left:-260px; z-index:10000000001; background:#fff">
                <div class="row">
                    <div class="col-md-12">
                            <div class="bg-primary leftMenuLogoContent" >
                                <img src="https://cdn.feegow.com/feegowclinic-v7/assets/img/logo_white.png" width="120" class="ml15 mt25" border="0">
                            </div>
                            <div class="m10">
                                <ul class="nav pt15">
                                    <%
                                    set men = db.execute("select * from cliniccentral.menu where App=1 order by id")
                                    while not men.eof
                                        %>
                                        <li>
                                            <a href="<%= men("URL") %>" class="btn btn-block text-left text-dark" style="border:none" onclick='fechar()'>
                                                <i class="far fa-<%= men("Icone") %>"></i>
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
            </div>

            <div class="row">
                <div class="col-xs-4">
                    <button class="btn btn-transparent btn-block ml15 btn-menu-mobile" onclick="abrir()" style="text-align:left;border:none!important;font-size: 18px;color: #6a6a6a;"><i class="far fa-bars"></i></button>
                </div>
                <div class="col-xs-8">
                    <img class="logol" src="<%=logo%>" height="38">


                </div>
            </div>
        </div>








        <div id="bottomApp" >


              <!-- Sidebar Widget - Search (hidden) -->
              <form class="mn pn" role="search">
                <label for="sidebar-search">
                    <div class="sidebar-widget search-widget mn" id="sidebar-search-content">
                    <div class="input-group">
                      <span class="input-group-addon">
                        <i class="far fa-search"></i>
                      </span>
                    <input type="text" id="sidebar-search" autocomplete="off" name="q" class="form-control" placeholder="Busca rápida...">
                    <input name="P" value="Busca" type="hidden">
                    <input name="Pers" value="1" type="hidden">

                    </div>
                </div>
              </label>
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

    <div id="disc" class="alert alert-danger text-center hidden" style="position: fixed;z-index:9999;width:100%;border-radius: 0;box-shadow: 0 3px 18px rgb(0 0 0 / 10%);backdrop-filter: blur(10px);background-color: #ee5253d9;"></div>

        <div id="modalCaixa" class="modal fade" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content" id="modalCaixaContent">
                Carregando...
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div>


    <%
    recursoUnimed = recursoAdicional(12)
    classContext = ""

    if recursoUnimed=4 then
        classContext = "color-context-unimed"
    %>
    <style>
        .color-context-unimed .bg-primary.darker{
            border-image-source: linear-gradient(to right, #008654 0%, #00ac6c 100%) !important;
        }
        .color-context-unimed #sidebar_left.sidebar-light .sidebar-menu > li > a > span:nth-child(1){
            color: #00ac6c;
        }

        .color-context-unimed .dropdown li i, .dropdown-menu li i{
            color: #00ac6c
        }
    </style>

    <%
    end if
    %>
  <aside id="main" class="<%=classContext%> <% if device()<>"" then response.write("mobile-content") end if %> ">
    <%
    if device()="" then %>
    <header class="navbar navbar-fixed-top navbar-shadow bg-primary darker">
      <div class="navbar-branding dark bg-primary">
        <a class="navbar-brand" href="./?P=Home&Pers=1">
          <img class="logol" src="<%=Logo %>" height="36" />
        </a>
                  <i id="toggle_sidemenu_l" class="far fa-bars"></i>

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
              <span class="far fa-phone fs14 va-m"></span>
            </button>
            <div class="dropdown-menu dropdown-persist w350 animated animated-shorter fadeIn" role="menu">
              <div class="panel mbn">
                  <div class="panel-menu">
                     <span class="panel-icon"><i class="far fa-phone"></i></span>
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
                                    <span class="far fa-<%=canais("icone") %>"></span>
                                  </div>
                                  <div class="timeline-desc">
                                    <span><a href="#" onclick="btb(<%=canais("id") %>, <%=canais("Prompt") %>)"><%=canais("NomeCanal") %></a></span>
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
                    <button  onclick="location.href='./?P=Chamadas&Pers=1'" type="button" class="btn btn-xs btn-default"> <i class="far fa-phone-square"></i> Contatos Realizados </button>
                    <button  onclick="location.href='./?P=Funil&Pers=1'" type="button" class="btn btn-xs btn-default"> <i class="far fa-filter"></i> Funil de Vendas </button>
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
            <button class="btn btn-sm btn-menu-left" type="button" onclick="Caixa();" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Meu Caixa">
              <span class="far fa-inbox fs14 va-m"></span>

                  <span class="badge badge-success" id="badge-caixa"><%if session("CaixaID")<>"" then%>$<%end if%></span>

            </button>
          </div>
        </li>
		<%
		end if
		%>





        <li id="liTarefasX" class="dropdown menu-merge menu-right-tarefas">
          <div class="navbar-btn btn-group">
            <button id="notifTarefas" data-toggle="dropdown" class="btn btn-sm dropdown-toggle btn-menu-left" onclick="notifTarefas();" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Tarefas">
              <span class="far fa-tasks fs14 va-m"></span>
            </button>
            <div class="dropdown-menu dropdown-persist w350 animated animated-shorter fadeIn" role="menu">
              <div class="panel mbn">
                  <div class="panel-menu">
                     <span class="panel-icon"><i class="far fa-tasks"></i></span>
                     <span class="panel-title fw600"> Controle de Tarefas</span>
                      <button class="btn btn-default light btn-xs pull-right" type="button" title="Adicionar Tarefa" onclick="location.href='./?P=Tarefas&I=N&Pers=1'"><i class="far fa-plus"></i></button>
                  </div>
                  <div class="panel-body panel-scroller scroller-navbar pn">
                    <div class="tab-content br-n pn">
                      <div id="divNotiftarefas" class="tab-pane alerts-widget active" role="tabpanel">

                      </div>


                    </div>
                  </div>
                  <div class="panel-footer text-center p7">
                    <button type="button" class="btn btn-default btn-sm btn-menu-left" onclick="location.href='./?P=listaTarefas&Tipo=R&Pers=1'">
                    <i class="far fa-list"></i> Listar tarefas
                    </button>
                    <%
                    if session("Banco")="clinic5459" then
                    %>
                    <button type="button" class="btn btn-default btn-sm btn-menu-left" onclick="location.href='./?P=listaTarefas&Tipo=R&Pers=1&MeusTickets=1'">
                    <i class="far fa-list"></i> Meus Tickets
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
            <button data-toggle="dropdown" class="btn btn-sm dropdown-toggle btn-menu-left" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Notificações">
              <span id="bell" class="far fa-bell<%=animadoGerais%> fs14 va-m"></span>
              <span class="badge badge-danger" id="badge-bell"></span>
            </button>
            <div class="dropdown-menu dropdown-persist w350 animated animated-shorter fadeIn" role="menu">
              <div class="panel mbn">
                  <div class="panel-menu">
                     <span class="panel-icon"><i class="far fa-bell"></i></span>
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
        <%
        if aut("|chat") then
        %>
		<li class="dropdown menu-merge menu-right-chat">
					<div class="navbar-btn btn-group">
	          <button id="toggle_sidemenu_r" class="btn btn-sm btn-menu-left" onclick="chatUsers()" data-rel="tooltip" data-placement="bottom" title="" data-original-title="Conversa">
		          <span class="far fa-comments"></span>
              <span class="badge badge-danger" id="badge-chat"></span>
		          <!-- <span class="caret"></span> -->
	          </button>
	        </div>
		</li>

        <%
        end if
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

                  <i class="far fa-question-circle"></i>
                  <!-- <span class="caret"></span> -->
              </button>
            </div>
        </li>
        <%
        end if
        %>
        <li class="menu-divider hidden-xs hidden-sm hidden-md">
          <i class="far fa-circle"></i>
        </li>
        <li class="dropdown menu-merge">
          <a href="#" class="dropdown-toggle fw600 p15 menu-click-meu-perfil" data-toggle="dropdown">
          	<img src="<%=session("photo") %>" class="mw30 br64" style="height: 30px;width: 100%;object-fit: cover;">
          	<span class="hidden-xs hidden-sm hidden-md pl15"> <%=left(session("NameUser"), 15) %> </span>
            <span class="caret caret-tp hidden-xs hidden-sm hidden-md"></span>
          </a>
          <ul class="dropdown-menu list-group dropdown-persist w250" role="menu" style="overflow-y: auto; max-height: 500px">
                            <%
                            msgDisabled = "Meu Perfil"
							if session("Partner")="" then
							    set franqueadaUsuario = db.execute("select * from cliniccentral.licencasusuarios where id = "&session("User")&" and LicencaID = "&LicenseID)
							    disabled = " "

							    if franqueadaUsuario.eof then
							        disabled = " pointer-events:none; "
							        msgDisabled = " Para acessar seu Perfil, acessar a licença principal"
							    end if
							%>
								<li class="list-group-item menu-click-meu-perfil-meu-perfil">
									<a class="animated animated-short fadeInUp" href="?P=<%=session("Table")%>&Pers=1&I=<%=session("idInTable")%>" style="<%=disabled%>">
										<i class="far fa-user"></i>
										<%=msgDisabled%>
									</a>
								</li>
                <%if session("banco")="clinic100000" or session("banco")="clinic5459" then %>
                  <li class="list-group-item menu-click-meu-perfil-ponto-eletronico">
                    <a class="animated animated-short fadeInUp" href="?P=Ponto&Pers=1">
                      <i class="far fa-hand-o-up"></i>
                      Ponto Eletrônico
                    </a>
                  </li>
                  <%
                end if
                if session("Admin")=1 then %>
                  <li class="list-group-item menu-click-meu-perfil-logs-de-acoes">
                    <a class="animated animated-short fadeInUp" href="?P=Logs&Pers=1">
                      <i class="far fa-history"></i>
                      Logs de Ações
                    </a>
                  </li>
                  <%
                end if
                if aut("aberturacaixinha")=1 then
								  %>
                  <li class="list-group-item menu-click-meu-perfil-abrir-fechar-baixa">
                    <a class="animated animated-short fadeInUp" href="javascript:Caixa()">
                      <i class="far fa-inbox"></i>
                      Abrir/Fechar Caixa
                    </a>
                  </li>
                  <%
                end if

                    IF session("QuantidadeFaturasAbertas") = "" THEN
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
                    if aut("EmissaoFaturaFeegow")=1 then
                      %>
                      <li class="list-group-item menu-click-meu-perfil-minhas-faturas">
                          <a class="animated animated-short fadeInUp" href="?P=AreaDoCliente&Pers=1">
                              <i class="far fa-barcode"></i>
                              Minhas Faturas
                              <% IF session("QuantidadeFaturasAbertas") > "0" THEN %>
                                  <span class="badge badge-danger" id="badge-bell"><%=session("QuantidadeFaturasAbertas")%></span>
                              <% END IF %>
                          </a>
                      </li>
                      <%
                    end if
                  if aut("gerenciamentodearquivos")= 1 then
                  %>
                    <li class="list-group-item menu-click-meu-perfil-arquivos">
                        <a class="animated animated-short fadeInUp" href="?P=Files&Pers=1">
                            <i class="far fa-file"></i>
                            Arquivos
                        </a>
                    </li>
                  <%
                  end if
      else

                  if session("Admin")=1 then
                  %>
                  <li class="list-group-item">
                    <a class="red animated animated-short fadeInUp" href="?P=Licencas&Pers=1">
                      <i class="far fa-hospital-o"></i>
                      Licenças
                    </a>
                  </li>
                  <li class="list-group-item">
                    <a class="red animated animated-short fadeInUp" href="?P=Operadores&Pers=1">
                      <i class="far fa-user"></i>
                      Operadores
                    </a>
                  </li>
                  <%
							end if
              %>

              <li class="list-group-item">
                <a class="green animated animated-short fadeInUp" href="?P=ConfirmAll&Pers=1&Data=<%= date() %>">
                  <i class="far fa-calendar"></i>
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
								        set UnidadeSQL = db.execute("SELECT id, NomeFantasia FROM (SELECT 0 id, IFNULL(NomeFantasia, NomeEmpresa) NomeFantasia FROM empresa  UNION ALL SELECT id, IFNULL(NomeFantasia, UnitName) NomeFantasia FROM sys_financialcompanyunits where sysActive=1)t where id="&session("UnidadeID"))

                                        if not UnidadeSQL.eof then
                                            idUnidade=UnidadeSQL("id")
                                            nomeUnidade=UnidadeSQL("NomeFantasia")

                                            if nomeUnidade&"" <> "" then
								        %>
                                        <li class="list-group-item menu-click-meu-perfil-muda-local">
                                            <a class="animated animated-short fadeInUp">
                                                <i class="fa <%if ccur(idUnidade)&""=session("UnidadeID") then%>fa-check-square-o<%else%>fa-square-o<%end if%>"></i>
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
                                                <i class="far fa-building"></i>
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
                                        <i class="far fa-list"></i>
                                        Listar Licenciados
                                    </a>
                                </li>
                                <%
                                end if
                                %>









            <li class="dropdown-footer">
              <a href="./?P=Login&Log=Off" class="btn-logoff">
              <span class="far fa-power-off pr5"></span> Sair </a>
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
      <div class="sidebar-left-content nano-content" style="margin-right: -17px;">

        <!-- Start: Sidebar Header -->
        <header class="sidebar-header">


          <!-- Sidebar Widget - Search (hidden) -->
              <form class="mn pn" role="search">
                  <label for="sidebar-search">
          <div class="sidebar-widget search-widget mn" id="sidebar-search-content">
            <div class="input-group">
              <span class="input-group-addon">
                <i class="far fa-search"></i>
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

      <!-- Start: Topbar -->
      <header id="topbar" class="alt affix no-print <% if device()<>"" then response.write("topbar-mobile") end if %>">
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
              <a class="btn btn-sm mn" onclick="abrirSubmenu()" style="border:none;text-decoration:underline;max-width:120px; overflow:hidden">
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
            <div class="nano-content sidebar-light" id="submenu" style="background-color:#fff!important; height:450px; position:fixed; width:260px; margin-right:-260px; right:0; top:65px; z-index:10003">
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
<div id="importa-replicar"></div>

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
					<td> <button type="button" class="btn btn-success btn-xs" onclick="staImport(1, <%= pendImp("id") %>, 'ATENÇÃO: Você está informando que conferiu a importação do CADASTRO DE <%= ucase(pendImp("recursoConferir")&"")%>, cujos dados encontram-se importados corretamente. ')"><i class="far fa-thumbs-up"></i> CONFERIDO</button></td>
					<td> <button type="button" class="btn btn-danger btn-xs" onclick="staImport(0, <%= pendImp("id") %>, 'ATENÇÃO: Você está informando que a importação do CADASTRO DE <%= ucase(pendImp("recursoConferir")&"")%> não está em conformidade com o banco de dados enviado. \nNossa equipe de importação será notificada disso e entrará em contato.\n Caso prefira, você também pode entrar em contato a qualquer momento com nossa equipe de importação no telefone (21) 2018-0123.')"><i class="far fa-thumbs-up"></i> ALGO DEU ERRADO</button></td>
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
								if req("P")="" then
									response.Redirect("?P=Home&Pers=1")
								end if
								if req("Pers")="1" then
								  FileName = req("P")&".asp"
								else
								  FileName = "DefaultContent.asp"
								end if
								set fs=nothing


								IF FileName = "Home.asp" THEN
                  if getConfig("HomeOtimizada")="1" or PorteClinica > 3 or AppEnv<>"production" then
								      FileName = "HomeModoFranquia.asp"
                  end if
								END IF

								if req("Mod")<>"" then
								    FileName = "modulos/"&req("Mod") &"/"& FileName
								end if
                FileNameFullPath = getEnv("FC_SRC_PATH","c://inetpub/wwwroot/") & currentVersionFolder & "/" & FileName

                set fs=Server.CreateObject("Scripting.FileSystemObject")
                fileExists = fs.FileExists(FileNameFullPath)

                if not fileExists then
                  response.write("404: Página não encontrada.")
                else
								  server.Execute(FileName)
                end if
								%>

								<!-- PAGE CONTENT ENDS -->
					            <%=fechaDiv %><!-- /.page-content -->


      </section>
      <!-- End: Content -->

    <% if device()="" then %>
      <!-- Begin: Page Footer -->

      <%
      if session("AtendimentoTelemedicina")&""<>"" and req("P")="Pacientes"  then
      %>
    <!--#include file="react/telemedicina/main.asp"-->
    <%
    end if
    %>

      <footer id="content-footer" class="affix no-print">
        <div class="row">
          <div class="col-md-6 hidden-xs">
                <!--#include file="Classes/Base64.asp"-->

              <script type="text/javascript">
              function vidau(v){
                  dva = $("#videoaula");
                  dva.css("display", "block");
                  dva.html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
                  $.get(v, function(data){
                    dva.html( data );
                    });
                }
              </script>

              <div class="bs-component">
                  <div class="btn-group">

                  <button type="button" class="btn btn-xs btn-success light" data-toggle="tooltip" data-placement="top" title="Tutoriais em vídeo"
                  onclick='vidau(`VideoTutorial.asp?refURL=<%=Base64Encode(request.QueryString())%>`, true, `Central de Vídeos`,``,`xl`,``)'>
                  <i class="far fa-video-camera"></i> Vídeo-aula
                  </button>

                      <%if session("Admin")<>1 AND recursoAdicional(12)=4 then%>
                      <%else%>

                      <button type="button" onclick="location.href='./?P=AreaDoCliente&Pers=1'" data-toggle="tooltip" data-placement="top"  title="Central de ajuda" class="btn btn-xs btn-default">
                          <i class="far fa-question-circle"></i> Suporte
                      </button>
                      <%end if%>
                      <button type="button" class="btn btn-xs btn-default">
                        <%
                        Versao = session("Versao")
                        if Versao="" then
                          Versao="8.0"
                        end if
                        %>
                          Feegow  <%=Versao%>
                      </button>
                      <%

                        ChamadaDeSenha = recursoAdicional(2)

                        if ChamadaDeSenha=4 then
                          %>
                            <button type="button" class="btn btn-xs btn-default callTicketBtn" onclick="callTicket()" disabled>
                                <i class="far fa-users"></i> Chamar senha
                            </button>
                            <%
                        end if
                        %>
                     <%
                           if recursoAdicional(17)=4 then
                          %>
                            <button type="button" class="btn btn-xs btn-default" onclick="facialRecognition()">
                                <i class="far fa-smile"></i> Reconhecimento facial
                            </button>
                            <%
                            end if
                            %>
                            <% IF False THEN %>
                                <span class="btn btn-warning btn-xs internetFail" style="display:none">Sua internet parece estar lenta</span>
                            <% END IF %>

                            <button type="button" onclick=" openComponentsModal('ReportarBug.asp', {tela:'<%=req("P")%>',query:''}, false, false, false, 'md');"  class="btn btn-xs btn-default" data-toggle="tooltip" data-placement="top"   >
                              <span class="far fa-bug"></span> Reportar bug
                            </button>

                            <% IF (session("Admin")="1") and (req("P")="Home") and False THEN
                                TemRecursoWhatsApp= recursoAdicional(31)=4
                                if TemRecursoWhatsApp then
                            %>
                            <script>localStorage.setItem("Admin",true);</script>
                            <button class="btn btn-xs btn-success light" id="footer-whats" onclick="location.href='?P=OutrasConfiguracoes&Pers=1&whatsApp=true'"  data-rel="tooltip" data-placement="right" title="" data-original-title="" >
                                <span class="far fa-whatsapp"></span>
                            </button>
                            <%
                                END IF
                            END IF %>
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
              <span class="far fa-arrow-up"></span>
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
              <a href="#sidebar-right-tab1" data-toggle="tab">Notificações Chat</a>
            </li>
            <li>
              <a href="#sidebar-right-tab2" data-toggle="tab">Tutorial</a>
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
                    <strong><i class="far fa-angle-down"></i></strong>
                    Primeiros passos</h5>
                </div>
                <style>


                    @font-face {
                         font-family: rubidBold;
                         src: url('https://cdn.feegow.com/feegowclinic-v7/assets/recurso-indisponivel/Fonte/Rubik-Bold.ttf');
                    }
                    @font-face {
                         font-family: rubid;
                         src: url('https://cdn.feegow.com/feegowclinic-v7/assets/recurso-indisponivel/Fonte/Rubik-Regular.ttf');
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
                          background: url("https://cdn.feegow.com/feegowclinic-v7/assets/img/icone-video-vermelho.png");
                          width: 22px;
                          height: 22px;
                          margin-top: 8px;
                          display: block;
                    }
                    .ativeTour .icon-circle-tour-video{
                          background: url("https://cdn.feegow.com/feegowclinic-v7/assets/img/icone-video-verde.png");
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
          </div>
          <!-- end: .tab-content -->
        </div>
      </div>
    </aside>
    <!-- End: Right Sidebar -->

  </div>


<%
if session("AlterarSenha") <> "0" then
  %>
  <!--#include file="AlteraSenhaForcada.asp"-->
  <%
end if
%>

<%if session("ChatSuporte")="S" then%>
<script src="https://feegow.futurotec.com.br/futurofone_chat/www/core/js/embedChatJs/chat.js"></script>
<script>
ffchat.addChat({
url: 'https://feegow.futurotec.com.br',
btn_minimizar: true,
titulo: 'Chat Online',
titulo_login: 'Feegow',
hash_chat: 'FFCHAT01'
});
</script>
<%end if%>


  <!-- End: Main -->

  <!-- BEGIN: PAGE SCRIPTS -->

  <!-- jQuery -->

  <!-- HighCharts Plugin -->
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/highcharts/highcharts.js"></script>

  <!-- FullCalendar Plugin + moment Dependency -->
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/fullcalendar/lib/moment.min.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/fullcalendar/fullcalendar.min.js"></script>

  <!-- jQuery Validate Plugin-->
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/admin-tools/admin-forms/js/jquery.validate.min.js"></script>

  <!-- jQuery Validate Addon -->
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/admin-tools/admin-forms/js/additional-methods.min.js"></script>

  <!-- Theme Javascript -->
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/utility/utility.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/demo/demo.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/main.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/admin-tools/admin-forms/js/jquery.spectrum.min.js"></script>

  <!-- Widget Javascript -->
  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/demo/widgets.js"></script>

  <!-- Notificações (Alerts, Confirms, etc)  -->
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/pnotify/pnotify.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/pnotify/pnotify.confirm.min.js"></script>


  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/ladda/ladda.min.js"></script>
  <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/magnific/jquery.magnific-popup.js"></script>

    <!-- old sms -->
    	<script type="text/javascript" src="https://cdn.feegow.com/feegowclinic-v7/assets/js/qtip/jquery.qtip.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/typeahead-bs2.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/vendor/jquery/jquery.maskMoney.js" type="text/javascript"></script>

		<!-- page specific plugin scripts -->
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery-ui-1.10.3.custom.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.ui.touch-punch.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.gritter.min.js"></script>
        <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.slimscroll.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.hotkeys.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/bootstrap-wysiwyg.min.js"></script>
        <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.easy-pie-chart.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.sparkline.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/flot/jquery.flot.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/flot/jquery.flot.pie.min.js"></script>
			<!-- table scripts -->
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.dataTables.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/bootbox.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.dataTables.bootstrap.js"></script>


		<!--[if lte IE 8]>
		  <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/excanvas.min.js"></script>
		<![endif]-->

		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/chosen.jquery.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/fuelux/fuelux.spinner.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/date-time/bootstrap-datepicker.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/date-time/bootstrap-timepicker.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/date-time/moment.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/date-time/daterangepicker.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/bootstrap-colorpicker.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.knob.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.autosize.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.inputlimiter.1.3.1.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/jquery.maskedinput.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/bootstrap-tag.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/x-editable/bootstrap-editable.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/x-editable/ace-editable.min.js"></script>
        <script type="text/javascript" src="https://cdn.feegow.com/feegowclinic-v7/assets/js/bootstrap-datetimepicker.min.js"></script>
        <script type="text/javascript" src="https://cdn.feegow.com/feegowclinic-v7/assets/js/bootstrap-datetimepicker.pt-BR.js"></script>
        <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/tracking-min.js"></script>
        <script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/face-min.js"></script>

		<!-- ace scripts -->

		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/ace-elements.min.js"></script>
		<script src="https://cdn.feegow.com/feegowclinic-v7/assets/js/ace.min.js"></script>
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

function whasappVerifyConnection()
{
    	$.ajax({
    		type: "GET",
    		url: domain + '',
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

function reloadTitle(){
    var pageName = $(".crumb-active").text();

    if(pageName.length > 5){
        document.title = "Feegow - "+pageName;
    }
}

$(".crumb-active").bind('DOMSubtreeModified', reloadTitle);

$(document).ready(function() {
    reloadTitle();

    var $iptSearch = $("#sidebar-search");
    var $contentSearch = $("#sidebar-search-content");

    $iptSearch.focus(function(){
        $contentSearch.addClass("active");
    }).blur(function(){
        $contentSearch.removeClass("active");
    });

    var lenMenu = $(".sidebar-menu li").length
    setTimeout(function() {
        if(lenMenu === 0){
            $("#toggle_sidemenu_l").click()
        }
    }, 200);


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
					strAtendimentos = strAtendimentos&"<a id=""agePac"&PacienteID&""" class=""btn btn-default btn-xs"" style='floar:right' href=""?P=Pacientes&Pers=1&I="&PacienteID&""">Voltar para: "&pac("NomePaciente")&"</a>"
				end if
			end if
		end if
	next

	if contaAtendimentos=1 and lcase(req("P"))="pacientes" and req("I")<>cstr(PacienteID) then
		Exibe = "S"
	elseif contaAtendimentos=1 and lcase(req("P"))<>"pacientes" then
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
			text: '<%= replace(strAtendimentos&"", "'", "") %>',
			image: 'https://cdn.feegow.com/feegowclinic-v7/assets/img/Doctor.png',
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

'or recursoAdicional(9) = 4 or recursoAdicional(21) = 4 or recursoAdicional(4) = 4 
    if session("OtherCurrencies")="phone" then
	    %>
	    setTimeout(function(){constante()}, 5500);
	    setInterval(function(){constante()}, 27000);
	    <%
    else
	    %>
	    setTimeout(function(){constante()}, 4000);
	    setInterval(function(){constante()}, 25000);
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
        $("#modalCaixa").modal(backdrop);
        $("#modalCaixaContent").html(data);
    });
}
</script>
    <!-- old sms << -->
    <style>
    .voltarTo{
        height: 44px;
        width: 100%;
        background: rgba(0,0,0,.5);
        z-index: 10000;
        position: absolute;
        bottom: 0;
        color: #DDDDDD;
        padding: 12px;
    }
    .voltarTo a{
        color: #DDDDDD;
    }
    </style>
    <% IF session("BancoOld") <> "" THEN %>
    <script>
        $("body").append(`<div class='voltarTo'>
           <a href="sys_financialCompanyUnits.asp?back=1"><i class="far fa-backward"></i>  Voltar a Licença da Franquiadora</a>
        </div>`);
    </script>

    <% END IF %>

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

<div style="position:fixed; width:100%; z-index:200000; bottom:0; height:25px; background-color:rgb(235 0 78 / 71%); color:#FFF; padding:8px; display:none; box-shadow: 0 3px 18px rgb(0 0 0 / 10%);backdrop-filter: blur(10px); " id="legend">
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
			<div class="chat-popup" id="chat_<%=chatID%>"></div>
            <%
		end if
	end if
next
%>
</div>

<div id="videoaula" style="position:fixed; left:10px; width:95%; height:600px; top:10px; border-radius:5px; background-color:#fff; border:1px solid #ccc; display:none; box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19); z-index:9999"></div>

<%
if session("OtherCurrencies")="phone" or recursoAdicional(9) = 4 then
    %>
    <div id="calls" class="modal-draggable" style="position:fixed; right:10px; bottom:10px; width:350px; ;"></div>
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
                    authenticate("-<%= session("User") * (9878 + Day(now())) %>Z", "-<%= replace(session("Banco"), "clinic", "") * (9878 + Day(now())) %>Z", "<%=session("Partner")%>");
                }else{
					if(localStorage.getItem("tk")){
						$.ajaxSetup({
							headers: { 'x-access-token': localStorage.getItem("tk") }
						});
					}
				}
			});

			<% IF req("limitExceeded")="1" THEN %>
                _type = '<%=req("P")%>';
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
            <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/bstour/bootstrap-tour.js"></script>
            <script src="src/tour.js"></script>
            <!--#include file="RecursoBloqueado.asp"-->

<%
end if
%>

<%
'-> GESTÃO DE AVISOS
if getConfig("GestaoDeAvisos")=1 then
  if session("AvisoCarregado")="" and session("UnidadeID")&""<>"-1" then
    'Admin?
    if session("Admin")=1 then
      sqlAdmin = " OR a.Perfis LIKE '%|Administrador|%' "
    end if
    'Perfil
    sqlPerfil = " OR a.Perfis LIKE '%|"& session("Table") &"|%' "

    'RegraID
    if session("ModoFranquia")=1 then
      set pRegra = db.execute("select regra from usuarios_regras where unidade="& session("UnidadeID") &" and usuario="& session("User"))
      if not pRegra.eof then
        RegraID = pRegra("regra")
        sqlRegra = " OR a.Perfis LIKE '%|"& RegraID &"|%' "
      end if
    else
        set UserSQL = db.execute("SELECT RegraID FROM sys_users WHERE id="&session("User"))
        if not UserSQL.eof then
            sqlRegra = " OR a.Perfis LIKE '%|"& UserSQL("RegraID") &"|%' "
        end if
    end if

    'EspecialidadeID
    if lcase(session("Table")&"")="profissionais" then
      set pesp = db.execute("select especialidadeID from profissionais WHERE id="& session("idInTable") &" UNION ALL select EspecialidadeID from profissionaisespecialidades where ProfissionalID="& session("idInTable"))
      while not pesp.eof
        sqlEsp = sqlEsp & " OR a.Especialidades LIKE '%|"& pesp("EspecialidadeID") &"|%' "
      pesp.movenext
      wend
      pesp.close
      set pesp = nothing
    end if


    sql = "select a.*, al.sysDate DataLeitura from avisos a "&_
          "LEFT JOIN avisosleitura al ON (al.AvisoID=a.id AND al.sysUser="& session("User") &" AND al.UnidadeID="& session("UnidadeID") &") "&_
          "WHERE UnidadesLicencas LIKE '%|"& session("UnidadeID") &"|%' AND CURDATE() BETWEEN DATE(a.Inicio) AND DATE(a.Fim) "&_
          "AND (0 "& sqlAdmin & sqlRegra & sqlPerfil & sqlEsp &") AND ISNULL(al.id)"

    dim divsAviso(10)
    ShowAvisoID = 0

    set vcaAviso = db.execute( sql )
    while not vcaAviso.eof
      TipoExibicao = vcaAviso("TipoExibicao")
      if TipoExibicao=1 and req("P")<>"Home" then
        response.redirect("./?P=Home&Pers=1")
      else

        divsAviso(vcaAviso("TipoExibicao")) = divsAviso(vcaAviso("TipoExibicao")) & "<div>"& vcaAviso("Texto") &"</div>"
        ShowAvisoID = vcaAviso("id")

        if vcaAviso("TipoExibicao")=2 then
          divsAviso(vcaAviso("TipoExibicao")) = divsAviso(vcaAviso("TipoExibicao")) & "<hr class='short alt'><div class='text-right p10'><button type='button' class='btn btn-primary' onclick=""ajxContent('AvisosLido', "& vcaAviso("id") &", 1, '', ''); $(this).fadeOut(); $('#modal-table').modal('hide');""><i class='fa fa-check'></i> MARCAR COMO LIDO</button></div>"
        end if

        session("AvisoCarregado")=1
      end if
    vcaAviso.movenext
    wend
    vcaAviso.close
    set vcaAviso = nothing

  end if
end if

  '<- GESTÃO DE AVISOS
  %>
<script type="text/javascript">
<%

if ShowAvisoID&""<>"0" and ShowAvisoID&""<>"" then
%>
  openComponentsModal( 'CarregaAviso.asp', {AvisoID: '<%=ShowAvisoID%>'}, "Novo aviso");
<%
end if
%>
</script>

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
<% Elseif req("P")="Trial" then%>
	<!--#include file="Trialxxx.asp"-->
<% Elseif req("P")="Confirmacao" then%>
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

<script src="https://cdn.feegow.com/feegowclinic-v7/vendor/sweetalert/sweetalert2@11.js"></script>
<script>

function chatNotificacao(titulo, mensagem) {
    let options = {
      body: mensagem,
      icon: "https://cdn.feegow.com/feegowclinic-v7/assets/img/logo_white_icon.png",
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
<%
PermiteChat = True
if session("ExibeChatAtendimento")=False or req("P")="Login" then
    PermiteChat= False
end if

if req("PrintPage")="1" then
    PermiteChat=False
end if

if PermiteChat then
%>
<script>
  <%
  StatusLicenca = session("Status")

  if StatusLicenca="C" then
    StatusLicenca="Contratado"
  elseif StatusLicenca="T" then
    StatusLicenca="Avaliação"
  elseif StatusLicenca="F" then
    StatusLicenca="Free"
  end if
  %>
  function initFreshChat() {
    window.fcWidget.init({
      token: "e1b3be37-181a-4a60-b341-49f3a7577268",
      host: "https://wchat.freshchat.com",
      config: {
        content:{
            headers: {
            csat_question: 'Com relação ao atendimento do seu Analista de Sucesso, você achou bom?',
          }
        }
      }
    });

    // To set unique user id in your system when it is available
    window.fcWidget.setExternalId("<%=session("User")%>");

    // To set user name
    window.fcWidget.user.setFirstName("<%=session("NameUser")%>");
    window.fcWidget.user.setEmail("<%=session("Email")%>");


    // To set user properties
    window.fcWidget.user.setProperties({
      admin: "<% if session("Admin")=1 then response.write("Sim") else response.write("Não") end if %>",
      nomeUnidade: "<%=session("NomeEmpresa")%>",
      tipoUsuario: "<%=lcase(Session("Table"))%>",
      licencaID: "<%=LicenseID%>",
      numeroUsuarios: "<%=session("UsuariosContratadosS")%>",
      razaoSocial: "<%=session("RazaoSocial")%>",
      statusLicenca: "<%=StatusLicenca%>",
      urlSistema: window.location.href,
      pastaRedicionamento: '<%= session("PastaAplicacaoRedirect") %>'
    });

  }
  // Copy the below lines under window.fcWidget.init inside initFreshChat function in the above snippet

  function initialize(i,t){var e;i.getElementById(t)?initFreshChat():((e=i.createElement("script")).id=t,e.async=!0,e.src="https://wchat.freshchat.com/js/widget.js",e.onload=initFreshChat,i.head.appendChild(e))}function initiateCall(){initialize(document,"freshchat-js-sdk")}window.addEventListener?window.addEventListener("load",initiateCall,!1):window.attachEvent("load",initiateCall,!1);
</script>
<%
end if
%>
<% IF (session("Admin")="1") and (req("P")="Home") and TemRecursoWhatsApp THEN %>
<script src="assets/js/whatsApp/whatsAppStatus.js?cache_prevent=9"></script>
<% END IF %>

<% 
FC_FIREBASE_API_KEY =getEnv("FC_FIREBASE_API_KEY","")
IF FC_FIREBASE_API_KEY<>"" THEN%>
<script type="module">
  // Import the functions you need from the SDKs you need
  import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.10/firebase-app.js";
  import { getAnalytics } from "https://www.gstatic.com/firebasejs/9.6.10/firebase-analytics.js";
  // TODO: Add SDKs for Firebase products that you want to use
  // https://firebase.google.com/docs/web/setup#available-libraries

  // Your web app's Firebase configuration
  // For Firebase JS SDK v7.20.0 and later, measurementId is optional
  const firebaseConfig = {
    apiKey: "<%=FC_FIREBASE_API_KEY%>",
    authDomain: "feegow-software-clinico.firebaseapp.com",
    databaseURL: "https://feegow-software-clinico.firebaseio.com",
    projectId: "feegow-software-clinico",
    storageBucket: "feegow-software-clinico.appspot.com",
    messagingSenderId: "594612638261",
    appId: "1:594612638261:web:e2b7bdeef63cca1c8a177c",
    measurementId: "G-B70MMEKG33"
  };

  // Initialize Firebase
  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
</script>
<% END IF %>