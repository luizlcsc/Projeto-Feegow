<!--#include file="Environment.asp"-->

<script>

    let memedLoading        = false;
    let memedError          = false;
    let memedInitialized    = false;
    let memedOpenAfterInit  = null;
    let memedTipo           = null;
    let memedClassic        = false;
    let memedUploadTemplate = false;

    // variáveis do ASP
    <%
    memedSessionKey = session("User")&"" & session("UnidadeID")&""
    memedUploadTemplate = false
    if session("MemedSessionKey")&"" <> memedSessionKey then
        session("MemedSessionKey") = memedSessionKey
    %>
        localStorage.removeItem('MEMED_TEMPLATE_UPLOADED');
    <% end if %>

    const MEMED_PACIENTE_ID               = '<%=req("I")%>';
    const MEMED_UNIDADE_ID                = '<%=session("UnidadeID")%>';
    const MEMED_PROFESSIONAL_ID           = '<%=session("idInTable")%>';
    const MEMED_LICENSE_ID                = '<%=replace(session("Banco"), "clinic","")%>';
    const MEMED_NUMERO_PRONTUARIO         = '<%=session("Banco")%>' +  '-' + '<%=req("I")%>';
    const MEMED_EXIBIR_OPCOES_RECEITUARIO = <% if getConfig("MemedExibirOpcoesReceituario")=1 then response.write("true") else response.write("false") end if %>;
    const MEMED_EXIBIR_HISTORICO          = <% if getConfig("MemedExibirHistorico")=1 then response.write("true") else response.write("false") end if %>;
    const MEMED_EXIBIR_PROTOCOLOS         = <% if getConfig("MemedExibirProtocolos")=1 then response.write("true") else response.write("false") end if %>;

    function openMemed (type) {
        const tiposValidos = ['prescricao', 'exame'];
        if (!tiposValidos.includes(type)) {
            throw new Error("Tipo inválido.");
        }

        memedTipo = type;

        if (memedClassic) {
            openClassicPrescription();
            return;
        }

        if (memedLoading) {
            new PNotify({
                title: 'Aguarde',
                text: 'Inicializando...',
                type: 'info',
                delay: 500
            });
            memedOpenAfterInit = newPrescricaoMemed;
            return;
        }

        if (!memedInitialized) {
            initMemed(newPrescricaoMemed);
            return;
        }

        newPrescricaoMemed();
    }

    function openClassicPrescription() {
        if (memedTipo === 'exame') {
            iPront('Pedido', MEMED_PACIENTE_ID, 0, '', '');
        } else {
            iPront('Prescricao', MEMED_PACIENTE_ID, 0, '', '');
        }
    }

    function setMemedLoading(loading) {
        memedLoading = loading;
        const elBtnConfig = $('#btn-config-prescricao');
        if (elBtnConfig) {
            elBtnConfig.toggleClass('loading', loading);
            if (loading) {
                elBtnConfig.attr('disabled', 'disabled');
            } else {
                elBtnConfig.removeAttr('disabled');
            }
        }
    }

    function setMemedError(error) {
        memedError = error;
        const elBtnConfig = $('#btn-config-prescricao');
        if (elBtnConfig) {
            elBtnConfig.toggleClass('error', error);
        }
    }

    function initMemed(openAfterInit) {
        memedOpenAfterInit = openAfterInit;
        if (memedLoading) {
            return;
        }
        setMemedLoading(true);

        getUrl('prescription/memedv2/init', {
            unidadeId: MEMED_UNIDADE_ID
        },
            function (response) {

                if (response.success !== true) {
                    setMemedLoading(false);
                    setMemedError(true);

                    if (memedOpenAfterInit) {
                        if (response.status === 403) {
                            openConfigMemed();
                        } else {
                            //como fallback em caso de erro, abre a prescrição clássica
                            memedClassic = true;
                            openClassicPrescription();
                        }
                    }
                    return;
                }

                initScriptMemed(response.data);
            }
        );
    }
    initMemed();

    function openConfigMemed() {
        openComponentsModal("prescription/memedv2/register", {
            professionalId: MEMED_PROFESSIONAL_ID,
            unidadeId: MEMED_UNIDADE_ID,
            modal: true

        }, "Cadastro Memed", false);
    }

    function initScriptMemed(data) {
        if (!data || !data.token || !data.domain) {
            return;
        }

        setMemedError(false);
        memedClassic = !data.sysActive;

        if (memedClassic && memedOpenAfterInit) {
            memedOpenAfterInit = openClassicPrescription;
        }

        if (memedInitialized) {
            return;
        }

        setMemedLoading(true);
        const script = document.createElement('script');
        script.setAttribute('id', 'script-memed');
        script.setAttribute('type', 'text/javascript');
        script.setAttribute('data-color', '#217dbb');
        script.setAttribute('data-token', data.token);
        script.src = `https://${data.domain}/modulos/plataforma.sinapse-prescricao/build/sinapse-prescricao.min.js`;
        script.onload = function() {
            initEventsMemed(data.workplace);
        };

        document.body.appendChild(script);
        console.info('[INTEGRACAO MEMED] Script injetado com sucesso.');

        updateMemedPrintTemplate();
    }

    function initEventsMemed(workplace) {
        MdSinapsePrescricao.event.add('core:moduleInit', function moduleInitHandler(module) {
            if (module.name === 'plataforma.prescricao') {
                setMemedLoading(false);
                memedInitialized = true;

                if (workplace) {
                    MdHub.command.send('plataforma.prescricao', 'setWorkplace', workplace);
                }

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
    }

    function updateMemedPrintTemplate() {
        if (!localStorage.getItem('MEMED_TEMPLATE_UPLOADED')) {
            console.info('[INTEGRACAO MEMED] Enviando Papel timbrado...');
            postUrl('prescription/memedv2/update-print-template', {
                professionalId: MEMED_PROFESSIONAL_ID,
                unidadeId: MEMED_UNIDADE_ID,
            }, function() {
                console.info('[INTEGRACAO MEMED] Papel timbrado enviado com sucesso.');
            });
            localStorage.setItem('MEMED_TEMPLATE_UPLOADED', 'true');
        }
    }

    function setFeaturesMemed() {
        const features = memedTipo === 'exame' ?
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

        return MdHub.command.send('plataforma.prescricao', 'setFeatureToggle', {...features, ...{
            removePatient: false,
            deletePatient: false,
            editPatient: false,
            optionsPrescription: MEMED_EXIBIR_OPCOES_RECEITUARIO,
            historyPrescription: MEMED_EXIBIR_HISTORICO,
            showProtocol: MEMED_EXIBIR_PROTOCOLOS,
        }});
    }

    function setAdditionalDataMemed(){
        return MdHub.command.send('plataforma.prescricao', 'setAdditionalData', {
            licenseId: MEMED_LICENSE_ID,
            numeroProntuario: MEMED_NUMERO_PRONTUARIO,
            tipo: memedTipo,
        });
    }

    function setPacienteMemed() {
        const nome         = $("#NomePaciente").val();
        const endereco     = $("#Endereco").val();
        const numero       = $("#Numero").val() ? " "+$("#Numero").val() : "";
        const estado       = $("#Estado").val() ? " "+$("#Estado").val() : "";
        const cidade       = $("#Cidade").val()+estado;
        const telefone     = $("#Cel1").val() ? $("#Cel1").val().replace(/\D/g,'') : ($("#Cel2").val() ? $("#Cel2").val().replace(/\D/g,'') : null);
        const fullEndereco = endereco+numero;
        const peso         = $('#Peso').val()   ? parseFloat($('#Peso').val().replace('.', '').replace(',', '.')) : null;
        const altura       = $('#Altura').val() ? parseFloat($('#Altura').val().replace('.', '').replace(',', '.')) : null;

        const dadosPaciente = {
            nome: nome,
            telefone: telefone,
            endereco: fullEndereco,
            cidade: cidade,
            peso: peso,
            altura: altura,
            idExterno: MEMED_NUMERO_PRONTUARIO
        };
        return MdHub.command.send('plataforma.prescricao', 'setPaciente', dadosPaciente);
    }

    async function newPrescricaoMemed() {
        setMemedLoading(true);
        await setFeaturesMemed();
        await setPacienteMemed();
        await setAdditionalDataMemed();
        await MdHub.command.send('plataforma.prescricao', 'newPrescription');
        MdHub.module.show('plataforma.prescricao');
        setMemedLoading(false);
    }

    function savePrescricaoMemed(id) {
        postUrl('prescription/memedv2/save-prescription', {
             prescriptionId: id,
             patientId: MEMED_PACIENTE_ID
         }, function (data) {
            const tipo = memedTipo === 'exame' ? 'Pedido' : 'Prescricao';
            if (data.success) {
                pront(`timeline.asp?PacienteID=${MEMED_PACIENTE_ID}&Tipo=|${tipo}|`);
            } else {
                new PNotify({
                    title: 'Erro ao gravar a prescrição.',
                    text: 'Não foi possível gravar a prescrição',
                    type: 'danger'
                });
            }
         });
    }

    async function viewPrescricaoMemed(id, tipo) {
        if (memedLoading) {
            new PNotify({
                title: 'Aguarde',
                text: 'Inicializando...',
                type: 'info',
                delay: 500
            });
            return;
        }
        if (!memedInitialized) {
            initMemed(function () {
                viewPrescricaoMemed(id, tipo);
            });
            return;
        }

        memedTipo = tipo;
        await setFeaturesMemed();
        await setPacienteMemed();
        await setAdditionalDataMemed();
        MdHub.command.send('plataforma.prescricao', 'viewPrescription', id);
    }

    function deletePrescricaoMemedExcluida(id) {
        const tipo = memedTipo === 'exame' ? 'Pedido' : 'Prescricao';
        postUrl('prescription/memedv2/delete-prescription', {deletedMemedId: id}, function () {
            pront(`timeline.asp?PacienteID=${MEMED_PACIENTE_ID}&Tipo=|${tipo}|`);
        });
    }

    function deletePrescricaoMemed(id, tipo) {
        if (confirm(`Tem certeza de que deseja apagar ${tipo === 'exame' ? 'este pedido de exame' : 'esta prescrição'}?`)) {
            postUrl('prescription/memedv2/delete-prescription', {prescriptionId: id, tipo: tipo}, function () {
                if (tipo === 'exame') {
                    pront(`timeline.asp?PacienteID=${MEMED_PACIENTE_ID}&Tipo=|Pedido|`);
                } else {
                    pront(`timeline.asp?PacienteID=${MEMED_PACIENTE_ID}&Tipo=|Prescricao|`);
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
