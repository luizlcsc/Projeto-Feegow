/**
 * Created by Vinicius Maia on 15/03/2017.
 * Last Update André Souza on 26/09/2019.
 */
var AutorizadorTiss = function () {
        var token="";
        if(localStorage.getItem("tk")){
            token= localStorage.getItem("tk")
        }
        $.ajaxSetup({
            headers: { 'x-access-token': token }
        });

        function getUrlVars() {
            var vars = [], hash;
            var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            for (var i = 0; i < hashes.length; i++) {
                hash = hashes[i].split('=');
                vars.push(hash[0]);
                vars[hash[0]] = hash[1];
            }
            return vars;
        }
        var parent = this,
            //baseUrl = "/feegow_components/autorizador_tiss/",
            baseUrl = domain + "autorizador-tiss/", 
            //baseUrl = "http://127.0.0.1:8000/autorizador-tiss/",           
            $methods = $(".feegow-autorizador-tiss-method");
        function useNotUndefined(var1, var2) {
            if (typeof var1 === "undefined" || var1 === "") {
                return var2;
            } else {
                return var1;
            }
        }
        function defaultPostData(postData) {
            var unserialize = function (serialized) {
                if (typeof serialized === "object") {
                    return serialized;
                } else {
                   // console.log(serialized); // para fins de DEBUG
                    return JSON.parse('{"' + decodeURI((serialized).replace("+%0D%0A"," ")).replace(/%0A/,"").replace(/%0D/,"").replace(/%2C/, ",").replace(/%2F/, "/").replace(/\+/, " ").replace(/"/g, '\\"').replace(/&/g, '","').replace(/\\/g, '\\\\').replace(/=/g, '":"') + '"}');
                }
            }, data = {};
            if (typeof postData !== "undefined") {
                data = unserialize(postData);
            } else {
                var $form = parent.sadt ? $("#GuiaSADT") : $("#GuiaConsulta");
                    trimForm($form);
                data = unserialize($form.serialize());
                data.procID = $("#Contratado option:selected").text();
                data.ContratadoExecutante = $("#Contratado option:selected").text();
                data.ContratadoSolicitante = useNotUndefined($("#Contratado option:selected").text(), $("#ContratadoID option:selected").text());
                data.NomeBeneficiario = useNotUndefined($("#searchgPacienteID option:selected").text());
                data.ProfissionalSolicitante = useNotUndefined($("#gProfissionalID option:selected").text(), $("#ProfissionalSolicitanteID option:selected").text());
                data.ConselhoProfissionalSolicitanteID = useNotUndefined($("#Conselho").val(), $("#ConselhoProfissionalSolicitanteID").val());
                data.NumeroNoConselhoSolicitante = useNotUndefined($("#DocumentoConselho").val(), $("#NumeroNoConselhoSolicitante").val());
                data.UFConselhoSolicitante = useNotUndefined($("#UFConselho").val(), $("#UFConselhoSolicitante").val());
                data.CodigoCBOSolicitante = useNotUndefined($("#CodigoCBO").val(), $("#CodigoCBOSolicitante").val());
                data.CaraterAtendimentoID = 1;
                data.IdentificadorBeneficiario = $("#IdentificadorBeneficiario").val();
                // data.homolog = 0;
            }
            data.I = parseInt(parent.guideId);
            data.U = parseInt(parent.userId);
            data.sadt = parent.sadt;
            return data;
        }
        function trimForm($form) {
            var allInputs = $(":input", $form);
            allInputs.each(function () {
                $(this).val($.trim($(this).val()));
            });
        }
        function formatDate(date) {
            if(date){
                date = date.split("-");
                var dd = date[2];
                var mm = date[1];
                var yyyy = date[0];
                return dd + "/" + mm + "/" + yyyy;
            }else{
                return false;
            }
        }
       
        this.showMessage = function (text, state, title) {
            var states = {
                0: {
                    "class": "gritter-error",
                    "type": "danger",
                    "label": "Erro no envio da guia!"
                },
                1: {
                    "class": "gritter-warning",
                    "type": "warning",
                    "label": "Guia glosada!"
                },
                2: {
                    "class": "gritter-success",
                    "type": "success",
                    "label": typeof title !== "undefined" ? title : "Guia autorizada!"
                },
                3: {
                    "class": "gritter-success",
                    "type": "info",
                    "label": "Status da guia"
                }
            };
            console.log(text);
            // && !PNotify
            if (PNotify) {
                //    pnotify
                console.log('CALLING PNOTIFY')
                new PNotify({
                    title: states[state].label,
                    text: text,
                    type: states[state].type // all contextuals available(info,system,warning,etc)
                });
            } else {
                $.gritter.add({
                    // (string | mandatory) the heading of the notification
                    title: states[state].label,
                    // (string | mandatory) the text inside the notification
                    text: text,
                    class_name: states[state].class,
                    time: 5000
                });
            }
        };

        /**
         * Função para preencher os dados no formulário 
         */
        this.preenchedadosretornados = function (data){
            if (data.NumeroGuiaOperadora !== null && data.NumeroGuiaOperadora !=='')
            {
                document.getElementById('NGuiaOperadora').value = data.NumeroGuiaOperadora;
                console.log("Numero da guia atualizado: "+ data.NumeroGuiaOperadora);
            }
            if (data.senha !== null && data.senha !=='')
            {
                document.getElementById('Senha').value = data.senha;
                console.log("Senha atualizada: "+ data.senha);
            }
            if (data.StatusSolicitacao !== null && data.StatusSolicitacao !== '')
            {
                $('#GuiaStatus').prop('selectedIndex', data.StatusSolicitacao); 
                console.log("Status da guia atualizado: "+ data.StatusSolicitacao);
            }            
        }

        /**
         * Função para Autorizar Internações  
         */
        this.autorizaInternacoes = function () {
            var $btn = $methods.filter('[data-method="autorizar"]');
            $btn.attr("disabled", true);
            $.ajax({
                type: "GET",
                url: baseUrl + "solicitaInternacao",
                data: dadosGuia(),
                success: function (data) {
                    var message = "",
                    state = 0; 
                    $btn.attr("disabled", false); // reabilita o botão 
                    /* situações possíveis de retorno
                        0- Erro no envio da guia 
                        1- Guia Glosada 
                        2- Processo autorizado 
                        3- Retona o status da guia */
                    switch (data.Sucesso) {
                        case 0:
                            message = data.Mensagem;
                            state = 0;
                            break;
                        case 1: 
                            message  = data.Mensagem;
                            state = 1;
                            break;
                        case 2: 
                            if (data.QuantidadeAutorizada > data.QuantidadeSolicitada) {
                                message = 'Todos os <B>'+ data.QuantidadeAutorizada+'</B> procedimentos Autorizados!';
                            } else {
                                // exibir mensagem informando que alguns procedimentos não foram autorizados e os motivos 
                                message = 'ATENÇÃO! <BR>Alguns procedimentos não foram autorizados! <BR>';
                                message += 'Código: ' + data.CodigoGlosa + ' Motivo: ' + data.Glosa;
                                state  = 1;                                
                            }
                            message  = data.Mensagem;
                            state = 2;
                            break;
                        case 3: 
                            message  = data.Mensagem;
                            state = 3;
                            break;
                    }
                    if (data.CodigoGlosa!=''){
                        message += '<BR> Código Glosa: ' + data.CodigoGlosa + '<BR> Motivo Glosa: ' + data.Glosa;  
                    }
                    parent.showMessage(message, state);
                    parent.bloqueiaBotoes(3);
                },
                error: function () {
                    // mensagem de indisponibilidade do sistema
                    $btn.attr("disabled", false);
                    parent.showMessage("Tente autorizar pelo portal do convênio.", 0);
                }
            });
        };

        /**
         * Função para Autorizar procedimentos 
         */
        this.autorizaProcedimentos = function () {
            var $btn = $methods.filter('[data-method="autorizar"]');
            this.bloqueiaBotoesclick(0);
            $.ajax({
                type: "GET",
                url: baseUrl + "solicitaProcedimentos",
                data: defaultPostData(),
                success: function (data) {
                    var message = "",
                    state = 0; 
                    parent.bloqueiaBotoesclick(1); 
                    /* situações possíveis de retorno
                        0- Erro no envio da guia 
                        1- Guia Glosada 
                        2- Processo autorizado 
                        3- Retona o status da guia */
                    switch (data.Sucesso) {
                        case 0:
                            message = data.Mensagem;
                            state = 0;
                            break;
                        case 1: 
                            message  = data.Mensagem;
                            state = 1;
                            break;
                        case 2: 
                            if (data.QuantidadeAutorizada > data.QuantidadeSolicitada) {
                                message = 'Todos os <B>'+ data.QuantidadeAutorizada+'</B> procedimentos Autorizados!';
                            } else {
                                // exibir mensagem informando que alguns procedimentos não foram autorizados e os motivos 
                                message = 'ATENÇÃO! <BR>Alguns procedimentos não foram autorizados! <BR>';
                                message += 'Código: ' + data.CodigoGlosa + ' Motivo: ' + data.Glosa;
                                state  = 1;                                
                            }
                            //$("#NGuiaOperadora") data.NumeroGuiaPrestador;
                            
                            message  = data.Mensagem;
                            state = 2;
                            break;
                        case 3: 
                            message  = data.Mensagem;
                            state = 3;
                            break;
                    }
                    if (data.CodigoGlosa!=''){
                        message += '<BR> Código Glosa: ' + data.CodigoGlosa + '<BR> Motivo Glosa: ' + data.Glosa;  
                    }
                    parent.showMessage(message, state);
                    //parent.bloqueiaBotoes();
                },
                error: function () {
                    // mensagem de indisponibilidade do sistema
                    $btn.attr("disabled", false);
                    parent.showMessage("Tente autorizar pelo portal do convênio.", 0);
                }
            });
        };

        /**
         * Função para verificar o Status da Guia de Internação 
         */
        this.verificarStatusGuiaInternacao = function () {
            var $btn = $methods.filter('[data-method="autorizar"]');
            this.bloqueiaBotoesclick(0);
            $.ajax({
                type: "GET",
                url: baseUrl + "solicitaStatusAutorizacao?tipo_guia=3",
                data: dadosGuia(),
                success: function (data) {
                    var message = "",
                        state = 0;
                    parent.bloqueiaBotoesclick(1); 
                    /* situações possíveis de retorno
                        0- Erro no envio da guia 
                        1- Guia Glosada 
                        2- Processo autorizado 
                        3- Retona o status da guia */
                    switch (data.Sucesso) {
                        case 0:
                            message = data.Mensagem;
                            state = 0;
                            break;
                        case 1: 
                            message  = data.Mensagem;
                            state = 1;
                            break;
                        case 2: 
                            message  = data.Mensagem;
                            state = 2;
                            break;
                        case 3: 
                            message  = data.Mensagem;
                            state = 3;
                            break;
                    }
                    console.log(data);
                    if (data.CodigoGlosa!=''){
                        message += '<BR> Código Glosa: ' + data.CodigoGlosa + '<BR> Motivo Glosa: ' + data.Glosa;  
                    }
                    parent.showMessage(message, state);
                    
                    parent.bloqueiaBotoes(3);
                },
                error: function () {
                    // mensagem de indisponibilidade do sistema
                    $btn.attr("disabled", false);
                    parent.showMessage("Tente autorizar pelo portal do convênio.", 0);
                }
            });
        };

        /**
         * Função para verificar o Status da Guia
         */
        this.verificarStatusGuia = function (tipo_guia) {
            var $btn = $methods.filter('[data-method="autorizar"]');
            this.bloqueiaBotoesclick(0);
            $.ajax({
                type: "GET",
                url: baseUrl + "solicitaStatusAutorizacao?tipo_guia="+ tipo_guia,
                data: defaultPostData(),
                success: function (data) {
                    var message = "",
                        state = 0;
                    parent.bloqueiaBotoesclick(1);  
                    /* situações possíveis de retorno
                        0- Erro no envio da guia 
                        1- Guia Glosada 
                        2- Processo autorizado 
                        3- Retona o status da guia */
                    switch (data.Sucesso) {
                        case 0:
                            message = data.Mensagem;
                            state = 0;
                            break;
                        case 1: 
                            message  = data.Mensagem;
                            state = 1;
                            break;
                        case 2: 
                            message  = data.Mensagem;
                            state = 2;
                            break;
                        case 3: 
                            message  = data.Mensagem;
                            state = 3;
                            break;
                    }
                    console.log(data);
                    if (data.CodigoGlosa!=''){
                        message += '<BR> Código Glosa: ' + data.CodigoGlosa + '<BR> Motivo Glosa: ' + data.Glosa;  
                    }
                    parent.showMessage(message, state);
                    parent.bloqueiaBotoes(tipo_guia);
                    parent.preenchedadosretornados(data);                    
                },
                error: function () {
                    // mensagem de indisponibilidade do sistema
                    $btn.attr("disabled", false);
                    parent.showMessage("Tente autorizar pelo portal do convênio.", 0);
                }
            });
        };

         /**
         * Função para Solicitar o Cancelamento da guia de Internacao
         */
        this.cancelarGuiaInternacao = function () {
            var $btn = $methods.filter('[data-method="autorizar"]');
            if (confirm("Tem certeza que deseja CANCELAR ESSA GUIA?")) {
                this.bloqueiaBotoesclick(0);                 
                $.ajax({
                    type: "GET",
                    url: baseUrl + "cancelaGuia?tipo_guia=3",
                    data: dadosGuia(),
                    success: function (data) {
                        var message = "",
                            state = 0;
                        parent.bloqueiaBotoesclick(0);  
                        /* situações possíveis de retorno
                            0- Erro no envio da guia 
                            1- Guia Glosada 
                            2- Processo autorizado 
                            3- Retona o status da guia */
                        switch (data.Sucesso) {
                            case 0:
                                message = data.Mensagem;
                                state = 0;
                                break;
                            case 1: 
                                message  = data.Mensagem;
                                state = 1;
                                break;
                            case 2: 
                                message  = data.Mensagem;
                                state = 2;
                                break;
                            case 3: 
                                message  = data.Mensagem;
                                state = 3;
                                break;
                        }
                        console.log(data);
                        if (data.CodigoGlosa!=''){
                            message += '<BR> Código Glosa: ' + data.CodigoGlosa + '<BR> Motivo Glosa: ' + data.Glosa;  
                        }
                        parent.showMessage(message, state);
                        parent.bloqueiaBotoes(3);
                        parent.preenchedadosretornados(data); 
                    },
                    error: function () {
                        // mensagem de indisponibilidade do sistema
                        $btn.attr("disabled", false);
                        parent.showMessage("Tente autorizar pelo portal do convênio.", 0);
                    }
                });
            }
        };

        /**
         * Função para Solicitar o Cancelamento da guia
         */
        this.cancelarGuia = function (tipo_guia) {
            var $btn = $methods.filter('[data-method="autorizar"]');
            if (confirm("Tem certeza que deseja CANCELAR ESSA GUIA?")) {
                //$btn.attr("disabled", true);
                this.bloqueiaBotoesclick(0);
                $.ajax({
                    type: "GET",
                    url: baseUrl + "cancelaGuia?tipo_guia="+tipo_guia,
                    data: defaultPostData(),
                    success: function (data) {
                        var message = "",
                            state = 0;
                        parent.bloqueiaBotoesclick(1);  
                        /* situações possíveis de retorno
                            0- Erro no envio da guia 
                            1- Guia Glosada 
                            2- Processo autorizado 
                            3- Retona o status da guia */
                        switch (data.Sucesso) {
                            case 0:
                                message = data.Mensagem;
                                state = 0;
                                break;
                            case 1: 
                                message  = data.Mensagem;
                                state = 1;
                                break;
                            case 2: 
                                message  = data.Mensagem;
                                state = 2;
                                break;
                            case 3: 
                                message  = data.Mensagem;
                                state = 3;
                                break;
                        }
                        console.log(data);
                        if (data.CodigoGlosa!=''){
                            message += '<BR> Código Glosa: ' + data.CodigoGlosa + '<BR> Motivo Glosa: ' + data.Glosa;  
                        }
                        parent.showMessage(message, state);
                        parent.bloqueiaBotoes(tipo_guia);
                        parent.preenchedadosretornados(data); 
                    },
                    error: function () {
                        // mensagem de indisponibilidade do sistema
                        $btn.attr("disabled", false);
                        parent.showMessage("Tente autorizar pelo portal do convênio.", 0);
                    }
                });
            }
        };

        /**
         * Função que define os dados que devem ser passados pelo ajax
         * @param {*} postData 
         */
        function dadosGuia(postData) {
            var data = {};
            data.I = parseInt(parent.guideId);
            data.U = parseInt(parent.userId);
            data.sadt = parent.sadt;
            return data;
        }
         /**
         * Função para verificar as regras de negócio de com base nelas bloquear os 
         * botões de autorização, cancelamento e Verificação de Status 
         */
        this.bloqueiaBotoes = function (tipo_guia) {
            var $btnSolicitar       = $methods.filter('[data-method="autorizar"]');
            var $btnCancelaGuia     = $methods.filter('[data-method="cancelar"]');
            var $btnVerificarStatus = $methods.filter('[data-method="status"]');
            //alert('teste');
            $.ajax({
                type: "GET",
                url: baseUrl + "operacoesViaveis?tipo_guia="+tipo_guia,
                data: dadosGuia(),
                success: function (data) {
                        if (data.solicitar==1){ $btnSolicitar.show(); } else {$btnSolicitar.hide();}
                        if (data.cancelar==1){ $btnCancelaGuia.show(); } else {$btnCancelaGuia.hide();}
                        if (data.status==1){ $btnVerificarStatus.show(); } else {$btnVerificarStatus.hide();}
                        console.log(data);
                    }                    
            });            
        };       
       
        /**
         * Função de bloqueio dos botões 
         * 
         */
        this.bloqueiaBotoesclick = function (acao) {
            var $btnSolicitar       = $methods.filter('[data-method="autorizar"]');
            var $btnCancelaGuia     = $methods.filter('[data-method="cancelar"]');
            var $btnVerificarStatus = $methods.filter('[data-method="status"]');
            if (acao==1)
            {
                $btnSolicitar.attr("disabled", false); 
                //$btnSolicitar.classList.add("glyphicon-eye-open"); 
                $btnCancelaGuia.attr("disabled", false);
                //$btnCancelaGuia.classList.add("glyphicon-eye-open"); 
                $btnVerificarStatus.attr("disabled", false); 
                //$btnCancelaGuia.classList.add("glyphicon-eye-open");  
            } 
            else     
            {
                $btnSolicitar.attr("disabled", true); 
                //$btnSolicitar.classList.remove("glyphicon-eye-open"); 
                $btnCancelaGuia.attr("disabled", true);
                //$btnCancelaGuia.classList.remove("glyphicon-eye-open"); 
                $btnVerificarStatus.attr("disabled", true); 
                //$btnCancelaGuia.classList.remove("glyphicon-eye-open"); 
            }
        };  

        this.testar = function () {
            $.ajax({
                type: "GET",
                url: baseUrl ,
                data: defaultPostData(),
                success: function (data) {
                    console.log(data);
                }
            });
        };
        
        
    };