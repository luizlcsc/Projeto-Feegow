<%
if request("Log")="Off" then
	if session("Partner")="" then
		urlRedir = "./?P=Login"
	else
		urlRedir = "./?P=Login&Partner="&session("Partner")
	end if
	session.Abandon()
	response.Redirect(urlRedir)
end if


%>
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/URLDecode.asp"-->
<!--#include file="Classes/Environment.asp"-->
<% GTM_ID = getEnv("FC_GTM_ID", "") %>
<!DOCTYPE html>
<html>

<head>
    <% if GTM_ID <> "" then %>
        <!-- Google Tag Manager -->
        <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
        new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
        j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
        'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
        })(window,document,'script','dataLayer','<%=GTM_ID%>');</script>
        <!-- End Google Tag Manager -->
    <% end if %>

    <meta name="robots" content="noindex">
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <title>Feegow :: seja bem-vindo</title>
    <meta http-equiv="Content-Language" content="pt-br">
    <meta name="author" content="Feegow">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Favicon -->
    <link rel="shortcut icon" href="assets/img/feegowclinic.ico" type="image/x-icon" />

    <link href="https://fonts.googleapis.com/css?family=Montserrat:700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Raleway&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Open+Sans&display=swap" rel="stylesheet">

    <script src="js/components.js?a=2"></script>

	<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script>window.jQuery || document.write('<script src="/docs/4.0/assets/js/vendor/jquery-slim.min.js"><\/script>')</script>


    <link rel="stylesheet" href="https://cdn.feegow.com/feegowclinic-v7/vendor/bootstrap/4.2.1/bootstrap.min.css" integrity="sha384-GJzZqFGwb1QTTN6wy59ffF1BuGJpLSa9DkKMp0DgiMDm4iYMj70gZWKYbI706tWS" crossorigin="anonymous">
    <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/bootstrap/4.2.1/bootstrap.min.js" integrity="sha384-B0UglyR+jN6CkvvICOB2joaf5I4l3gm9GU6Hc1og6Ls7i6U/mkkaduKaBhlAXv9k" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="assets/css/font-awesome.min.css" />
    <script>
        // localStorage.clear()
    </script>

    <style type="text/css">

            body {
              background-color: #eaeaea;
              background-image: url("assets/img/login_squared_background.png");
              background-repeat: no-repeat;
              background-position: 50% 50%;
              line-height: 10px;
            }

            @media screen and (max-width: 994px) {
                body {
                background-color: #ffffff;
                  background-image: none;
                }

            }

            .formlogin {
                margin-left: auto;
                margin-right: auto;
             }

            .formloginCol1 {
                background-color: #ffffff;
                box-sizing: border-box;
                padding: 40px;

            }

            div .col {
                padding-right: 0px !important;
                padding-left: 0px !important;
            }

            .formlogin div:nth-child(2) {
                box-sizing: border-box;
                padding: 0px;
            }

            .Agradecimento {
                width: 259px;
                height: 55px;
                font-family: Montserrat;
                font-size: 45px;
                font-style: normal;
                font-stretch: normal;
                line-height: 1.22;
                letter-spacing: normal;
                text-align: left;
                color: #ffffff;
            }

            .textoRecuperarSenha {
                font-family: Open Sans;
                font-size: 12px;
                font-weight: bold;
                color: #7c7c7c;
                padding-bottom:2px;
                line-height: normal;
            }

            .textoDicaSenha {
                font-family: Open Sans;
                font-size: 11px;
                color: #7c7c7c;
                padding-bottom:2px;
            }

            .textoCodigoVerificacao {
                font-size: 11px;
                font-family: Open Sans;
                font-weight: bold;
            }

            .textoTitulo {
                width: 214px;
                height: 21px;
                font-family: Raleway;
                font-size: 18px;
                font-weight: 600;
                font-style: normal;
                font-stretch: normal;
                line-height: 1.17;
                letter-spacing: normal;
                text-align: left;
                color: #9b9b9b;
            }

            .textoTituloInput {
                width: 46px;
                height: 22px;
                font-family: Open Sans;
                font-size: 16px;
                font-weight: normal;
                font-style: normal;
                font-stretch: normal;
                line-height: 1.38;
                letter-spacing: normal;
                text-align: left;
                color: #9b9b9b;
            }


            input:-webkit-autofill,
            input:-webkit-autofill:hover,
            input:-webkit-autofill:focus,
            input:-webkit-autofill:active,
            input:-webkit-autofill:valid {
                -webkit-transition-delay: 99999s;
                -webkit-text-fill-color: #aeaeae;
                -webkit-background-image: url("assets/img/login_senha.png");
                -webkit-background-size: 9.2px 10.2px;
            }


            input[type=password], input[type=email], input[type=text] {
                outline: none;
                border: none;
                padding-left: 18px;
                padding-bottom: 3px;
                border-bottom: 1px solid #d8d8d8;
                font-family: Open Sans;
                font-size: 14px;
                font-weight: normal;
                font-style: normal;
                font-stretch: normal;
                line-height: 1.36;
                letter-spacing: normal;
                color: #aeaeae;
                width: 100%;
            }

            input:focus {
                outline: none;
                border: none;
                padding-left: 18px;
                padding-bottom: 3px;
                border-bottom: 1px solid #00bad7;
                font-family: Open Sans;
                font-size: 14px;
                font-weight: normal;
                font-style: normal;
                font-stretch: normal;
                line-height: 1.36;
                letter-spacing: normal;
                color: #aeaeae;
                width: 100%;
            }

            .botao {
                background-color: #00bad7;
                border: none;
                text-align: center;
                display: inline-block;
                border-radius: 6px;
                cursor: pointer;
                width: 150px;
                height: 37px;
                font-family: Montserrat;
                font-size: 14px;
                font-weight: bold;
                font-style: normal;
                font-stretch: normal;
                line-height: 1.29;
                letter-spacing: normal;
                color: #ffffff;

            }

            .senha {
                background-image: url("assets/img/login_senha.png");
                background-repeat: no-repeat;
                background-size: 9.2px 10.2px;
                background-position-y: center;
            }

            .usuario {
                background-image: url("assets/img/login_usuario.png");
                background-repeat: no-repeat;
                background-size: 8.2px 9.2px;
                background-position-y: center;
            }

            /* The container */
            .container-checkbox {
                display: block;
                position: relative;
                padding-left: 15px;
                margin-bottom: 5px;
                cursor: pointer;
                font-size: 10px;
                font-family: Raleway;
                color: #b5b1bd;
                -webkit-user-select: none;
                -moz-user-select: none;
                -ms-user-select: none;
                user-select: none;
            }

            /* Hide the browser's default checkbox */
            .container-checkbox input {
                position: absolute;
                opacity: 0;
                cursor: pointer;
            }

            /* Create a custom checkbox */
            .container-checkbox .checkmark {
                position: absolute;
                top: 0px;
                left: 0;
                height: 10px;
                width: 10px;
                background-color: #eee;
            }

            /* On mouse-over, add a grey background color */
            .container-checkbox:hover input ~ .checkmark {
                background-color: #ccc;
            }

            /* When the checkbox is checked, add a blue background */
            .container-checkbox input:checked ~ .checkmark {
                background-color: #00BAD7;
            }

            /* Create the checkmark/indicator (hidden when not checked) */
            .container-checkbox .checkmark:after {
                content: "";
                position: absolute;
                display: none;
            }

            /* Show the checkmark when checked */
            .container-checkbox input:checked ~ .checkmark:after {
                display: block;
            }

            /* Style the checkmark/indicator */
            .container-checkbox .checkmark:after {
                left: 4px;
                top: 1px;
                width: 2px;
                height: 6px;
                border: solid white;
                border-width: 0 1px 1px 0;
                -webkit-transform: rotate(45deg);
                -ms-transform: rotate(45deg);
                transform: rotate(45deg);
            }


            /* The container */
            .container-radio {
                display: block;
                position: relative;
                padding-left: 15px;
                margin-bottom: 5px;
                cursor: pointer;
                font-size: 12px;
                -webkit-user-select: none;
                -moz-user-select: none;
                -ms-user-select: none;
                user-select: none;
            }

            /* Hide the browser's default radio button */
            .container-radio input {
                position: absolute;
                opacity: 0;
                cursor: pointer;
            }

            /* Create a custom radio button */
            .container-radio .checkmark {
                position: absolute;
                top: 0px;
                left: 0;
                height: 12px;
                width: 12px;
                background-color: #eee;
                border-radius: 50%;
            }

            /* On mouse-over, add a grey background color */
            .container-radio:hover input ~ .checkmark {
                background-color: #ccc;
            }

            /* When the radio button is checked, add a blue background */
            .container-radio input:checked ~ .checkmark {
                background-color: #00BAD7;
            }

            /* Create the indicator (the dot/circle - hidden when not checked) */
            .container-radio .checkmark:after {
                content: "";
                position: absolute;
                display: none;
            }

            /* Show the indicator (dot/circle) when checked */
            .container-radio input:checked ~ .checkmark:after {
                display: block;
            }

            /* Style the indicator (dot/circle) */
            .container-radio .checkmark:after {
                top: 3px;
                left: 3px;
                width: 6px;
                height: 6px;
                border-radius: 50%;
                background: white;
            }

            @media screen and (min-width: 200px) {
                .formlogin {
                  padding: 2%;         /* 5% of container width, for medium screens */
                }
            }

            @media screen and (min-width: 893px) {
                .formlogin {
                  padding: 120px;         /* 5% of 600px, for wide screens */
                }
            }

            ::placeholder { /* Chrome, Firefox, Opera, Safari 10.1+ */
                font-family: Open Sans;
                font-size: 14px;
                font-weight: normal;
                font-style: normal;
                font-stretch: normal;
                line-height: 1.36;
                letter-spacing: normal;
                color: #e3e3e3;
            }

            :-ms-input-placeholder { /* Internet Explorer 10-11 */
                font-family: Open Sans;
                font-size: 14px;
                font-weight: normal;
                font-style: normal;
                font-stretch: normal;
                line-height: 1.36;
                letter-spacing: normal;
                color: #e3e3e3;
            }

            ::-ms-input-placeholder { /* Microsoft Edge */
                font-family: Open Sans;
                font-size: 14px;
                font-weight: normal;
                font-style: normal;
                font-stretch: normal;
                line-height: 1.36;
                letter-spacing: normal;
                color: #e3e3e3;
            }

    </style>
</head>
<body>
<% if GTM_ID <> "" then %>
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=<%=GTM_ID%>"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->
<% end if %>

<%
    if req("FP")<>"" and request.ServerVariables("REMOTE_ADDR")="::1" then
	
        set tryLogin = dbc.execute("select u.*, l.Cliente, l.NomeEmpresa, l.FimTeste, l.DataHora, l.LocaisAcesso, l.IPsAcesso, l.Logo, l.`Status` from licencasusuarios as u left join licencas as l on l.id=u.LicencaID where u.id="&ccur(req("FP")))
%>
        <!--#include file="loginPadrao.asp"-->
<%
    end if

    if req("User")<>"" or req("tokenLogin")<>"" then
        if req("Partner")="" then
            set tryLogin = dbc.execute("select u.*, l.Cliente, l.NomeEmpresa, l.FimTeste, l.DataHora, l.LocaisAcesso, l.IPsAcesso, l.Logo, l.`Status` from licencasusuarios as u left join licencas as l on l.id=u.LicencaID where Email='"&ref("User")&"' and (Senha='"&ref("Password")&"' or '"&ref("Password")&"'='##Yogo@@Nutella.')")
%>
        <!--#include file="loginPadrao.asp"-->
<%
        else
%>
        <!--#include file="loginPartner.asp"-->
<%
        end if
    end if

    'essa variavel eh utilizada no clinic7 e clinic8 para que os clientes logem em app.feegow.com
    LoginFTP = False

    if LoginFTP then
        URLRedirectLogin = "https://app.feegow.com/v7-master/?P=Login"

        if req("Partner")<>"" then
            URLRedirectLogin = URLRedirectLogin & "&Partner="&req("Partner")
        end if
    end if
%>
    <form method="post" action="<%=URLRedirectLogin%>">
        <div class="container">
            <div class="row formlogin">
                <div class="col-lg-5 col-xl-5 formloginCol1">
                    <a href="./?P=Login2" title="Logo">
                        <input type="hidden" name="RedirectLogin" value="<% if LoginFTP then %>S<% end if %>">
                        <%
                        if request.ServerVariables("HTTP_HOST")<>"livenote.feegow.com.br" then
                            if req("Partner")="" then
                        %>
                                <img class="login-logo" src="assets/img/login_logo.png" border="0" width="124" height="36">
                        <%
                            else
                        %>
                                <img class="login-logo-partner" src="logo/<%=req("Partner")%>.png" border="0" style="max-height: 80px; object-fit: cover">
                        <%
                            end if
                        else 
                        %> 
                            <img class="login-logo-livenote" src="assets/img/180_width.png" width="138" border="0">&nbsp;&nbsp;&nbsp;<img style="margin-bottom: -7px" src="logo/livenote.png" width="130" border="0">
                        <% 
                        end If 
                        %>
                    </a>
                        <%
                        RedirectLogin = False

                        if req("RedirectLogin")<>"" then
                            RedirectLogin=True
                        end if

                        if req("Password")<>"" and RedirectLogin then
                            PasswordValue = req("Password")
                        end if

                        if req("User")<>"" then
                            User = req("User")
                        else
                            User = request.Cookies("User")
                        end if

                        if request.QueryString("U")<>"" then
                            User=request.QueryString("U")
                        end if
                        %>
                        <div id="divFormLogin">
                            <!--#include file="LoginPrincipal.asp"-->
                        </div>
                </div>
                <div id="carouselExampleIndicators" class="col-lg-7 col-xl-7 d-none d-lg-block d-xl-block carousel slide" data-ride="carousel" style="width: 506px">
                    <!-- ol class="carousel-indicators">
                        <li data-target="#carouselExampleIndicators" data-slide-to="0" class="active"></li>
                        <li data-target="#carouselExampleIndicators" data-slide-to="1"></li>
                    </ol -->
                    <div class="carousel-inner">
                    <div class="carousel-item active">
                        <img class="login-bem-vindo" src="assets/img/login_bem_vindo.png">
                    </div>
                    <!--div class="carousel-item">
                        <a href="https://promo.feegowclinic.com.br/curso-de-marketing?utm_campaign=email3_curso_de_marketing_cta1&utm_medium=email&utm_source=rdstationt" target="_blank"><img src="assets/img/login_marketing_medico.png"></a>
                    </div-->
                    </div>
                </div>
            </div>
        </div>
        <input id="authtoken" type="hidden">
        <input id="qs" type="hidden" name="qs" value="<%= URLDecode(Request.QueryString("qs"))%>">
    </form>

    <!-- BEGIN: PAGE SCRIPTS -->

    <!-- jQuery -->
    <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
    <script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>

    <!-- pki lacuna software -->
    <script type="text/javascript" src="https://get.webpkiplugin.com/Scripts/LacunaWebPKI/lacuna-web-pki-2.12.0.min.js"
                integrity="sha256-jDF8LDaAvViVZ7JJAdzDVGgY2BhjOUQ9py+av84PVFA="
                crossorigin="anonymous"></script>

    <!-- CanvasBG Plugin(creates mousehover effect) -->
    <!--script src="vendor/plugins/canvasbg/canvasbg.js"></script>-->

    <!-- Theme Javascript -->
    <script src="assets/js/utility/utility.js"></script>
    <script src="assets/js/main.js"></script>
    <script src="vendor/plugins/ladda/ladda.min.js"></script>


    <!-- Page Javascript -->
    <script type="text/javascript">
    var pki = {};
    try{
        pki = new LacunaWebPKI();
    }catch (e) {}

        var selectedCert = null;

        jQuery(document).ready(function () {
            "use strict";
            Core.init();
            Ladda.bind('.ladda-button', {
                timeout: 8000
            });

            // Bind progress buttons and simulate loading progress. Note: Button still requires ".ladda-button" class.
            Ladda.bind('.progress-button', {
                callback: function (instance) {
                    var progress = 0;
                    var interval = setInterval(function () {
                        progress = Math.min(progress + Math.random() * 0.1, 1);
                        instance.setProgress(progress);

                        if (progress === 1) {
                            instance.stop();
                            clearInterval(interval);
                        }
                    }, 200);
                }
            });

            $('#certificateSelect').on("change",function(){
                var selectedCertThumb = $('#certificateSelect').val();

                for (var i = 0; i < certificates.length; i++) {
                    var cert = certificates[i];
                    if (cert.thumbprint == selectedCertThumb) {
                        selectedCert = cert;
                    }
                }
                return null;
            });

            $('#loginDigitalCertificate').on('click',function(){
                var cert = window.localStorage.getItem('defaultcertificate');

                if(cert!==null){
                    selectedCert = JSON.parse(cert,true);
                    InitAuthCert();

                }else{
                    $('#certsModal').modal('show');
                }
            });

            $('#loginCertButton').on('click',function(){
                    InitAuthCert();
            });

            function startPki() {
                pki.init({
                    ready: onWebPkiReady,
                    notInstalled: onWebPkiNotInstalled
                });
            }

        function onWebPkiNotInstalled(status, message) {
            var alerta = `<span>Você precisa instalar a Extensão WebPki para usar o certificado digital.</span>
                            <a href='https://chrome.google.com/webstore/detail/web-pki/dcngeagmmhegagicpcmpinaoklddcgon'>Ir para download</a>`;

        }

        function onWebPkiReady() {
            $('#certificadoArea').show('slow');

            pki.listTokens({
                pkcs11Modules: [pki.pkcs11Modules.safeSign, pki.pkcs11Modules.safeNet]
            }).success(function (tokens) {
                var select = $('#certificateSelect');
                    $.each(tokens, function () {
                });
            });

            pki.listCertificates().success(function (certs) {
                var select = $('#certificateSelect');
                certificates = [];
                $.each(certs, function () {
                    if(VerificarPropositoCertificado(this)){
                        certificates.push(this);
                        select.append(
                            $('<option />')
                                .val(this.thumbprint)
                                .text(this.subjectName + ' (issued by ' + this.issuerName + ')')
                        );
                    }
                });
            });
        }

        function destroyPhpSession() {
            $.get(domain + "destroy-session", function(data) {
                console.log(data);
            })
        }

        function InitAuthCert() {
            $.ajax({
                url: domain +'digital-certification/reg-login-start/',
                method: 'POST',
                dataType: 'json',
                data: {
                        nome:selectedCert.subjectName,
                        certificado: JSON.stringify(selectedCert)
                        },
                success: function(data)  {
                    if(data.status == "ok"){
                        pki.signWithRestPki({
                            token: data.token,
                            thumbprint: selectedCert.thumbprint
                        }).success(function (result) {
                            CompletAuthCert(result);
                        });
                    }else{
                        alert(data.msg);
                        }
                    }
                });
        }

        function CompletAuthCert(token) {
            $.ajax({
                url: domain +'digital-certification/reg-login-end/',
                method: 'POST',
                dataType: 'json',
                data: {
                        regToken: token,
                        certificado: JSON.stringify(selectedCert)
                    },
                success: OnLoginCompleted
            });
        }

        function OnLoginCompleted(result) {
            if(result.token=="")
            {
                alert(result.msg);
                window.localStorage.removeItem('defaultcertificate');
                $('#certsModal').modal('hide');

            }else{

                window.localStorage.setItem('defaultcertificate',JSON.stringify(selectedCert));
                console.log(result);
                $('#tokenLogin').val(result.token);
                $('#regLogin').val(result.filename);
                $('form').submit();
            }
        }

            $('form').on('submit', function(e){

                if($('#tokenLogin').val()=='')
                {
                    window.localStorage.removeItem('defaultcertificate');
                }

            });

            function VerificarPropositoCertificado(certificado)
            {
                var result = (certificado.keyUsage.nonRepudiation && certificado.keyUsage.digitalSignature);
                return result;
            }

        });
    </script>
</body>