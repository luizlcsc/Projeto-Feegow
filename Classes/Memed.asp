<%
dominioMemed = "sandbox.memed.com.br"
dominioApiMemed = "sandbox.api.memed.com.br"
%>
<script>
    var memedLoading       = false;
    var memedInitialized   = false;
    var memedOpenAfterInit = null;
    var memedToken         = null;

    function openMemed () {
        if (!memedInitialized) {
            initMemed(prescricaoMemed);
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
    initMemed();

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
        memedToken = token;
        document.body.appendChild(script);
        console.info('[INTEGRACAO MEMED] Script injetado com sucesso.');
    }

    function initEventsMemed() {
        MdSinapsePrescricao.event.add('core:moduleInit', function moduleInitHandler(module) {
            if (module.name === 'plataforma.prescricao') {
                memedLoading     = false;
                memedInitialized = true;

                MdHub.command.send('plataforma.prescricao', 'setFeatureToggle', {
                    removePatient: false,
                    deletePatient: false,
                    editPatient: false,
                    removePrescription: false,
                    historyPrescription: false,
                    copyMedicalRecords: false,
                });

                MdHub.event.add('prescricaoSalva', onPrescricaoMemedSalva);

                console.info('[INTEGRACAO MEMED] Inicializada com sucesso.');
                if (memedOpenAfterInit && typeof memedOpenAfterInit === 'function') {
                    memedOpenAfterInit();
                }
            }
        });
    }

    function prescricaoMemed () {
        const nome = $("#NomePaciente").val();
        const endereco = $("#Endereco").val();
        const numero = $("#Numero").val() ? " "+$("#Numero").val() : "";
        const estado = $("#Estado").val() ? " "+$("#Estado").val() : "";
        const cidade = $("#Cidade").val()+estado;
        const telefone = $("#Cel1").val().replace("-","").replace("(","").replace(")","").replace(" ","");
        const fullEndereco = endereco+numero;

        MdHub.command.send('plataforma.prescricao', 'setPaciente', {
            nome: nome,
            telefone: telefone,
            endereco: fullEndereco,
            cidade: cidade,
            idExterno:'<%=session("Banco")%>' +  '-' + '<%=req("I")%>'
        }).then(function() {
            MdHub.module.show('plataforma.prescricao');
            MdHub.command.send('plataforma.prescricao', 'newPrescription');
        });
    }

    function onPrescricaoMemedSalva(idPrescricao) {
        postUrl('prescription/memed/save-prescription', {
             prescriptionId: idPrescricao,
             patientId: '<%=req("I")%>'
         }, function (data) {
            pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Prescricao|');
         });
    }

    function viewPrescricaoMemed(id) {
        if (memedLoading) {
            new PNotify({
                title: 'Aguarde...',
                text: 'O serviço Memed está sendo inicializado.',
                type: 'warning',
                delay: 250
            });
            return;
        }
        if (!memedInitialized) {
            initMemed(function () {
                viewPrescricaoMemed(id);
            });
            return;
        }

        MdHub.command.send('plataforma.prescricao', 'viewPrescription', id);
    }

    function deletePrescricaoMemed(id) {
        if(confirm('Tem certeza de que deseja apagar esta prescrição?')) {
            postUrl('prescription/memed/delete-prescription', {prescriptionId: id}, function (data) {
                console.log(data);
                pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Prescricao|');
            });
        }
    }
    
</script>
