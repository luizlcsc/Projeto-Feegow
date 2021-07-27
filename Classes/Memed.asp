<%
dominioMemed = "sandbox.memed.com.br"
%>
<script>
    var memedLoading       = false;
    var memedInitialized   = false;
    var memedOpenAfterInit = false;

    function openMemed () {
        if (!memedInitialized) {
            initMemed(true);
            return;
        }
        prescricaoMemed();
    }

    function initMemed(openAfterInit) {
        memedOpenAfterInit = openAfterInit;
        if (memedLoading) {
            return;
        }
        memedLoading = true;

        getUrl('prescription/memed/init', {},
            function (response) {

                if (response.success !== true) {
                    memedLoading = false;
                    if (memedOpenAfterInit) {
                        console.error('[INTEGRACAO MEMED] Erro ao inicializar memed.');
                        if (response.status === 401) {
                            new PNotify({
                                title: 'Acesso negado',
                                text: 'Você não tem permissão para Prescrição MEMED. Apenas usuários do tipo `profissionais` podem efetuar a prescrição.',
                                type: 'danger'
                            });
                        } else if (response.status === 403) {
                            openComponentsModal("prescription/memed/professional-index", { professionalId: <%=session("idInTable")%>, modal: true}, "Cadastro Memed", false);
                        } else {
                            new PNotify({
                                title: 'Serviço indisponível.',
                                text: 'Tente novamente mais tarde',
                                type: 'danger'
                            });
                        }
                    }
                    return;
                }

                initScriptMemed(response.token);
            }
        );
    }

    function initScriptMemed(token) {
        memedLoading = true;
        const script = document.createElement('script');
        script.setAttribute('id', 'script-memed');
        script.setAttribute('type', 'text/javascript');
        script.setAttribute('data-color', '#217dbb');
        script.setAttribute('data-token', token);
        script.src = 'https://<%=dominioMemed%>/modulos/plataforma.sinapse-prescricao/build/sinapse-prescricao.min.js';
        script.onload = function() {
            initEventsMemed();
        };
        document.body.appendChild(script);
        console.info('[INTEGRACAO MEMED] Script injetado com sucesso.');
    }

    function initEventsMemed() {
        MdSinapsePrescricao.event.add('core:moduleInit', function moduleInitHandler(module) {
            if (module.name === 'plataforma.prescricao') {
                memedLoading     = false;
                memedInitialized = true;
                console.info('[INTEGRACAO MEMED] Inicializada com sucesso.');
                if (memedOpenAfterInit) {
                    prescricaoMemed();
                }
            }
        });
    }

    function prescricaoMemed () {
        var endereco = $("#Endereco").val();
        var numero = $("#Numero").val() ? " "+$("#Numero").val() : "";

        var estado = $("#Estado").val() ? " "+$("#Estado").val() : "";

        var fullEndereco = endereco+numero;


        MdHub.command.send('plataforma.prescricao', 'setFeatureToggle', {
          removePatient: false,
          deletePatient: false,
          removePrescription: false,
          historyPrescription: false
        });


       MdHub.command.send('plataforma.prescricao', 'setPaciente', {
         nome: $("#NomePaciente").val(),
         telefone: $("#Cel1").val().replace("-","").replace("(","").replace(")","").replace(" ",""),
         endereco: fullEndereco,
         cidade: $("#Cidade").val()+estado,
         idExterno:'<%=session("Banco")%>' +  '-' + '<%=req("I")%>'
       });

       setTimeout(function() {
         MdHub.module.show('plataforma.prescricao');
         MdHub.event.add('prescricaoSalva', function prescricaoSalvaCallback(idPrescricao) {
             console.log(idPrescricao);
             // postUrl('prescription/memed/save-prescription', {
             //     prescriptionId: idPrescricao,
             //     patientId: '<%=req("I")%>'
             // }, function (data) {
				//  console.log(data);
    			// pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Prescricao|');
             //
             // });
         });
       } , 500);
    }
    initMemed();
</script>
