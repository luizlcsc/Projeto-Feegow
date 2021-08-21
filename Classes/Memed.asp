<!--#include file="Environment.asp"-->
<%
'if getEnv("FC_APP_ENV","local")="production" then
'    dominioMemed = "memed.com.br"
'    dominioApiMemed = "api.memed.com.br"
'else
    dominioMemed = "sandbox.memed.com.br"
    dominioApiMemed = "sandbox.api.memed.com.br"
'end if
%>
<script>
    var memedLoading       = false;
    var memedInitialized   = false;
    var memedOpenAfterInit = null;
    var memedToken         = null;
    var memedTipo          = null;

    function openMemed (exame) {
        const fnOpen = exame ? exameMemed : prescricaoMemed;
        if (!memedInitialized) {
            initMemed(fnOpen);
            return;
        }
        fnOpen();
    }

    function initMemed(openAfterInit) {
        memedOpenAfterInit = openAfterInit;
        if (memedLoading) {
            return;
        }
        memedLoading = true;

        getUrl('prescription/memedv2/init', {},
            function (response) {

                if (response.success !== true) {
                    memedLoading = false;
                    if (memedOpenAfterInit) {
                        if (response.status === 401) {
                            new PNotify({
                                title: 'Acesso negado',
                                text: 'Você não tem permissão para MEMED. Apenas usuários do tipo `profissionais` podem acessar.',
                                type: 'danger'
                            });
                        } else if (response.status === 403) {
                            openComponentsModal("prescription/memedv2/register", { professionalId: <%=session("idInTable")%>, modal: true}, "Cadastro Memed", false);
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

                MdHub.event.add('prescricaoSalva', function(id) {
                    console.info('[INTEGRACAO MEMED] Evento: prescricaoSalva', id);
                    savePrescricaoMemed(id);
                });
                MdHub.event.add('prescricaoImpressa', function(data) {
                    console.info('[INTEGRACAO MEMED] Evento: prescricaoImpressa', data);
                    setTimeout(function() {
                        savePrescricaoMemed(data.prescricao.id);
                    }, 500);
                });
                MdHub.event.add('prescricaoExcluida', function(idPrescricao) {
                    console.info('[INTEGRACAO MEMED] Evento: prescricaoExcluida', idPrescricao);
                    deletePrescricaoMemedExcluida(idPrescricao);
                });

                console.info('[INTEGRACAO MEMED] Inicializada com sucesso.');
                if (memedOpenAfterInit && typeof memedOpenAfterInit === 'function') {
                    memedOpenAfterInit();
                }
            }
        });

        window.addEventListener("beforeunload", function (event) {
            MdHub.command.send('plataforma.sdk', 'logout');
        });
    }

    function setFeaturesMemed(exame) {
        const features = exame ?
            {
                autocompleteIndustrialized: false,
                autocompleteManipulated: false,
                autocompleteCompositions: false,
                autocompletePeripherals: false,
                autocompleteExams: true
            } :
            {
                autocompleteIndustrialized: true,
                autocompleteManipulated: true,
                autocompleteCompositions: true,
                autocompletePeripherals: true,
                autocompleteExams: false
            };

        memedTipo = exame ? 'exame' : 'prescricao';

        return Promise.all([
            MdHub.command.send('plataforma.prescricao', 'setFeatureToggle', {...features, ...{
                removePatient: false,
                deletePatient: false,
                editPatient: false,
                removePrescription: false,
                historyPrescription: false,
                copyMedicalRecords: false,
                showProtocol: false,
            }}),
            MdHub.command.send('plataforma.prescricao', 'setAdditionalData', {
                licenseId: <%=replace(session("Banco"), "clinic","")%>,
                numeroProntuario: '<%=session("Banco")%>' +  '-' + '<%=req("I")%>',
                tipo: memedTipo,
            })
        ]);
    }

    function setPacienteMemed() {
        const nome = $("#NomePaciente").val();
        const endereco = $("#Endereco").val();
        const numero = $("#Numero").val() ? " "+$("#Numero").val() : "";
        const estado = $("#Estado").val() ? " "+$("#Estado").val() : "";
        const cidade = $("#Cidade").val()+estado;
        const telefone = $("#Cel1").val().replace("-","").replace("(","").replace(")","").replace(" ","");
        const fullEndereco = endereco+numero;

        return MdHub.command.send('plataforma.prescricao', 'setPaciente', {
            nome: nome,
            telefone: telefone,
            endereco: fullEndereco,
            cidade: cidade,
            idExterno:'<%=session("Banco")%>' +  '-' + '<%=req("I")%>'
        });
    }

    function prescricaoMemed() {
        Promise.all([setFeaturesMemed(false), setPacienteMemed()]).then(function() {
            setTimeout(function() {
                MdHub.module.show('plataforma.prescricao');
                MdHub.command.send('plataforma.prescricao', 'newPrescription');
            }, 500);
        });
    }

    function exameMemed() {
        Promise.all([setFeaturesMemed(true), setPacienteMemed()]).then(function() {
            setTimeout(function() {
                MdHub.module.show('plataforma.prescricao');
                MdHub.command.send('plataforma.prescricao', 'newPrescription');
            }, 500);
        });
    }

    function savePrescricaoMemed(id) {
        postUrl('prescription/memedv2/save-prescription', {
             prescriptionId: id,
             patientId: '<%=req("I")%>'
         }, function (data) {
            const tipo = memedTipo === 'exame' ? 'Pedido' : 'Prescricao';
            if (data.success) {
                pront(`timeline.asp?PacienteID=<%=req("I")%>&Tipo=|${tipo}|`);
            } else {
                new PNotify({
                    title: 'Erro ao gravar a prescrição.',
                    text: 'Não foi possível gravar a prescrição',
                    type: 'danger'
                });
            }
         });
    }

    function viewPrescricaoMemed(id, tipo) {
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
                viewPrescricaoMemed(id, tipo);
            });
            return;
        }

        Promise.all([
            setFeaturesMemed(tipo === 'exame'),
            setPacienteMemed(),
        ]).then(function() {
            setTimeout(function() {
                MdHub.command.send('plataforma.prescricao', 'viewPrescription', id);
            }, 500);
        });
    }

    function deletePrescricaoMemedExcluida(id) {
        const tipo = memedTipo === 'exame' ? 'Pedido' : 'Prescricao';
        postUrl('prescription/memedv2/delete-prescription', {deletedMemedId: id}, function () {
            pront(`timeline.asp?PacienteID=<%=req("I")%>&Tipo=|${tipo}|`);
        });
    }

    function deletePrescricaoMemed(id, tipo) {
        if (confirm(`Tem certeza de que deseja apagar ${tipo === 'exame' ? 'este pedido de exame' : 'esta prescrição'}?`)) {
            postUrl('prescription/memedv2/delete-prescription', {prescriptionId: id, tipo: tipo}, function () {
                if (tipo === 'exame') {
                    pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Pedido|');
                } else {
                    pront('timeline.asp?PacienteID=<%=req("I")%>&Tipo=|Prescricao|');
                }
            });
        }
    }
    
</script>
<style>
    @font-face {
        font-family: 'Infra';
        src: url('assets/fonts/infra/infra-light.woff') format('woff');
        font-weight: 200;
        font-style: normal
    }

    @font-face {
        font-family: 'Infra';
        src: url('assets/fonts/infra/infra-regular.woff') format('woff');
        font-weight: 400;
        font-style: normal
    }
    @font-face {
        font-family: 'Infra';
        src: url('assets/fonts/infra/infra-medium.woff') format('woff');
        font-weight: 500;
        font-style: normal
    }
    @font-face {
        font-family: 'Infra';
        src: url('assets/fonts/infra/infra-semiBold.woff') format('woff');
        font-weight: 600;
        font-style: normal
    }
    .memed-items {
        font-family: 'Infra';
        list-style: none;
        margin: 0;
        padding: 0;
        margin: 0 0 80px;
        max-width: 800px;
    }
    .memed-items > li {
        border-bottom: 1px solid;
        border-top: 1px solid;
        border-color: transparent;
        font-size: 16px;
        padding: 14px 20px 19px;
        position: relative;
    }
    .memed-items > li p {
        font-weight: normal;
        margin-bottom: 5px;
    }
    .memed-items > li ul {
        margin-top: 10px;
    }
    .memed-items > li .nome {
        cursor: default;
        font-size: 16px;
        font-weight: 600;
        margin: 0;
        text-decoration: none;
    }
    .memed-items > li .quantidade {
        float: right;
    }
    .memed-items > li .descricao {
        cursor: default;
        font-size: 16px;
        margin-left: 17px
    }
    .memed-items > li[data-tipo="alopático"] .composicao {
        color: rgb(130, 130, 130);
        font-size: 12px;
        padding-left: 16px;
    }

    .memed-items > li .posologia {
        background-color: transparent;
        border: none;
        font-size: 16px;
        font-weight: normal;
        line-height: 1.2;
        min-height: 30px;
        overflow: hidden;
        resize: none;
        width: 85%;
    }
    .memed-items > li .posologia:disabled {
        background: transparent;
    }

</style>
