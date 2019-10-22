var templateTour = `<div class='popover tour'>
                                                                      <div class='arrow'></div>
                                                                      <h3 class='popover-title'></h3>
                                                                      <div class='popover-content'></div>
                                                                      <div class='popover-navigation'>
                                                                          <button class='btn btn-sm btn-default' data-role='prev'>Voltar</button>
                                                                          <button class='btn btn-sm btn-default' data-role='next'>Avançar</button>
                                                                           &nbsp;
                                                                          <button class='btn btn-sm btn-default' data-role='end'>Finalizar Tour</button>
                                                                      </div>

                                                                    </div>`;


function concluirTour(){

    let tourName = JSON.parse(localStorage.getItem("tour"));
    let tourConcluidos = JSON.parse(localStorage.getItem("tourConcluidos"));
    if(!tourConcluidos){
        tourConcluidos = [];
    }
    if(!(tourConcluidos.indexOf(tourName.tour) > -1)){
        tourConcluidos.push(tourName.tour);
    }

    localStorage.setItem("tourConcluidos",JSON.stringify(tourConcluidos));
    localStorage.removeItem("tour")
    tourFunctionConcluidos();
}


function startTour(tourName){
    localStorage.setItem("tour",JSON.stringify({"tour":tourName}));
    runTour();
}

let HorariosCadastro = () => {

    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [{
            element: ".menu-aba-meu-perfil-horarios",
            title: "Configurar horários de atendimento",
            content: "Clique em seu Horários de Atendimento",
            placement: 'right',
            onNext: function (tour) {
                if(tour.getCurrentStep() === 0){
                    $(".menu-aba-meu-perfil-horarios").click();
                }
            },
        },
            {
                delay:500,
                element: "#formHorarios > div > div.panel-body > div:nth-child(3) > table > thead > tr > th:nth-child(4) > button",
                title: "Configurar horários de atendimento",
                content: "Selecione o dia da semana que é possível o agendamento",
                placement: 'top',
                onShown:function(tour){
                    $("#formHorarios th button").on('click',(event)=>{
                        if(!!event.originalEvent && tour.getCurrentStep() === 1)tour.goTo(2)
                    });
                },
                onNext:function(tour) {
                    $("#formHorarios > div > div.panel-body > div:nth-child(3) > table > thead > tr > th:nth-child(4) > button").click();
                }
            },
            {
                delay:1500,
                element: "#formAddHorario h3",
                title: "Configurar horários de atendimento",
                content: "Confirme o dia de semana selecionado.",
                placement: 'left',
                onShown:function(tour){
                    $("#modal-table").on('hidden.bs.modal', function(e) {
                        tour.goTo(1);
                    });
                    $("#formAddHorario #HoraA").on('keypress',()=>{if(tour.getCurrentStep() !== 5)tour.goTo(5)});
                    $("#formAddHorario").on('submit',()=>{tour.end()});
                    $("#formAddHorario #qfhorade").on('keypress',()=>{if(tour.getCurrentStep() !== 4)tour.goTo(4)});
                }
            },
            {
                element: "#formAddHorario #qfhorade",
                title: "Configurar horários de atendimento",
                content: "Preencha o horário inicial de atendimento.",
                placement: 'bottom',
                onShown:function(tour){
                    $("#modal-table").on('hidden.bs.modal', function(e) {
                        tour.goTo(1);
                    });

                }
            },
            {
                element: "#formAddHorario #HoraA",
                title: "Configurar horários de atendimento",
                content: "Preencha o horário final de atendimento.",
                placement: 'bottom',
                onShown:function(tour){
                }
            },
            {
                element: "#formAddHorario .btn-success",
                title: "Configurar horários de atendimento",
                content: "Clique em salvar para configurar o dia da semana.",
                placement: 'top',
                onShown:function(tour){

                }
            },
        ]
    });

    $(".menu-aba-meu-perfil-horarios").on('click',(event)=>{
        if(!!event.originalEvent && tour.getCurrentStep() === 0){
            tour.goTo(1)
        }
    });

    tour.init();
    tour.restart();
    return;
}


let HorariosDefault = ()=>{


    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [{
            element: ".menu-click-meu-perfil",
            title: "Configurar horários de atendimento",
            content: "Clique em seu usuário",
            placement: 'left',
            onShow: function (tour) {
                let interval = setInterval(()=>{
                    if($(".menu-click-meu-perfil").parent().hasClass("open")){
                        if(tour.getCurrentStep() !== 1){
                            tour.goTo(1);
                        }
                        clearInterval(interval);
                    }
                },200)
            },
            onNext: function (tour) {
                let interval = setInterval(()=>{
                    if(!$(".menu-click-meu-perfil").parent().hasClass("open")){
                        $(".menu-click-meu-perfil").parent().addClass("open");
                        tour.goTo(1);

                        clearInterval(interval);
                    }
                },200)
            },
        },{
            element: ".menu-click-meu-perfil-meu-perfil",
            title: "Configurar horários de atendimento",
            content: "Clique em meu perfil",
            placement: 'left'
        },
            {
                element: ".menu-click-meu-perfil",
                title: "Configurar horários de atendimento",
                content: "Redirecionando para meu perfil...",
                placement: 'left',
                onShow: function (tour) {
                    setTimeout(()=>{
                        window.location.href = `?P=${sessionObj.Table}&Pers=1&I=${sessionObj.idInTable}`
                    },3500)
                },
            },
        ]
    });

    $(".menu-aba-meu-perfil-horarios").on('click',(event)=>{
        if(!!event.originalEvent && tour.getCurrentStep() === 0){
            tour.goTo(1)
        }
    });

    tour.init();
    tour.restart();
}

let ConvenioCadastro = function(){
    let tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [{
            element: "#NomeConvenio",
            title: "Cadastro de Convênio",
            content: "Preencha o nome do cadastro",
            placement: 'top',
            onShow:()=>{
                $("#NomeConvenio").on('keypress',()=>{
                    if(tour.getCurrentStep() === 0){
                        tour.goTo(1);
                    }
                })
            }
        },{
            element: "#RegistroANS",
            title: "Cadastro de Convênio",
            content: "Preencha o nome do registro ANS",
            placement: 'bottom',
            onShow:()=>{
                $("#RegistroANS").on('keypress',()=>{
                    if(tour.getCurrentStep() === 1){
                        tour.goTo(2);
                    }
                })
            }
        },
            {
                element: "#rbtns button",
                title: "Cadastro de Convênio",
                content: "Clique em salvar para finalizar o cadastro.",
                placement: 'left',
            }
        ]
    });

    $("#rbtns button").on('click',()=>{tour.end();})

    tour.init();
    tour.restart();
    return;
}

let ConvenioDefault = ()=> {
    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [{
            element: ".menu-click-cadastros",
            title: "Cadastro de Convênio",
            content: "Clique no ícone de cadastros",
            placement: 'left',
            onShow: function (tour) {
                let interval = setInterval(()=>{
                    if($(".menu-click-cadastros").parent().hasClass("open")){
                        if(tour.getCurrentStep() !== 1){
                            tour.goTo(1);
                        }
                        clearInterval(interval);
                    }
                },200)
            },
            onNext: function (tour) {
                let interval = setInterval(()=>{
                    if(!$(".menu-click-cadastros").parent().hasClass("open")){
                        $(".menu-click-cadastros").parent().addClass("open");
                        if(tour.getCurrentStep() !== 1){
                            tour.goTo(1);
                        }

                        clearInterval(interval);
                    }
                },200)
            },
        },{
            element: ".sub-menu-click-cadastro-convenio",
            title: "Cadastro de Convênio",
            content: "Clique em convênios para exibir listagem de convênios",
            placement: 'left'
        },
            {
                element: ".sub-menu-click-cadastro-convenio",
                title: "Cadastro de Convênio",
                content: "Redirecionando para o cadastro de convênio...",
                placement: 'left',
                onShow: function (tour) {
                    setTimeout(()=>{
                        window.location.href = '?P=Convenios&Pers=Follow'
                    },3500)
                },
            },
        ]
    });
    tour.init();
    tour.restart();
}

let ConvenioListagem = ()=>{
    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [
            {element: "#table-",
                title: "Cadastro de Convênio",
                content: "Visualize os convênios cadastrados",
                placement: 'top'
            },
            {element: ".topbar-right",
                title: "Cadastro de Convênio",
                content: "Clique inserir para acessar a tela de cadastro de convênio",
                placement: 'left'
            },{
                element: "#topbar",
                title: "Cadastro de Convênio",
                content: "Redirecionando para a tela de cadastro de convênio...",
                placement: 'bottom',
                onShow: function (tour) {
                    setTimeout(()=>{
                        window.location.href = '?P=Convenios&I=N&Pers=1'
                    },3500)
                },
            },
        ]
    });
    tour.init();
    tour.restart();
    return ;
}


let PacienteDefault = () =>{
    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [{
            element: ".menu-click-pacientes",
            title: "Cadastro de Paciente",
            content: "Clique no menu pacientes",
            placement: 'left',
            onShow: function (tour) {
                let interval = setInterval(()=>{
                    if($(".menu-click-pacientes").parent().hasClass("open")){
                        if(tour.getCurrentStep() !== 1){
                            tour.goTo(1);
                        }
                        clearInterval(interval);
                    }
                },200)
            },
            onNext: function (tour) {
                let interval = setInterval(()=>{
                    if(!$(".menu-click-pacientes").parent().hasClass("open")){
                        $(".menu-click-pacientes").parent().addClass("open");
                        if(tour.getCurrentStep() !== 1){
                            tour.goTo(1);
                        }

                        clearInterval(interval);
                    }
                },200)
            },
        },{
            element: ".sub-menu-click-paciente-incluir",
            title: "Cadastro de Paciente",
            content: "Clique em inserir paciente",
            placement: 'left'
        },
            {
                element: ".sub-menu-click-paciente-incluir",
                title: "Cadastro de Paciente",
                content: "Redirecionando para o cadastro de paciente...",
                placement: 'left',
                onShow: function (tour) {
                    setTimeout(()=>{
                        window.location.href = '?P=pacientes&I=N&Pers=1'
                    },4000)
                },
            },
        ]
    });
    tour.init();
    tour.restart();
}


let AgendamentoDefault = () =>{
    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [{
            element: ".menu-click-agenda",
            title: "Inserir um Agendamento",
            content: "Clique em Agenda",
            placement: 'bottom',
            onShow: function (tour) {
                let interval = setInterval(()=>{
                    if($(".menu-click-agenda").parent().hasClass("open")){
                        if(tour.getCurrentStep() !== 1){
                            tour.goTo(1);
                        }
                        clearInterval(interval);
                    }
                },200)
            },
            onNext: function (tour) {
                let interval = setInterval(()=>{
                    if(!$(".menu-click-agenda").parent().hasClass("open")){
                        $(".menu-click-agenda").parent().addClass("open");
                        tour.goTo(1);

                        clearInterval(interval);
                    }
                },200)
            },
        },{
            element: ".sub-menu-click-agenda-diaria",
            title: "Inserir um Agendamento",
            content: "Inserir para acessar a tela de agenda.",
            placement: 'right'
        },
            {
                element: ".sub-menu-click-agenda-diaria",
                title: "Configurar horários de atendimento",
                content: "Redirecionando para meu perfil...",
                placement: 'left',
                onShow: function (tour) {
                    setTimeout(()=>{
                        window.location.href = "?P=Agenda-1&Pers=1"
                    },3500)
                },
            },
        ]
    });
    tour.init();
    tour.restart();
}


let PacienteCadastro = ()=>{
    let tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [{
            element: "#NomePaciente",
            title: "Cadastro de Paciente",
            content: "Preencha o nome do paciente",
            placement: 'top',
            onShow:()=>{
                $("#NomePaciente").on('keypress',()=>{
                    if(tour.getCurrentStep() === 0){
                        tour.goTo(1);
                    }
                })
            }
        },{
            element: "#CPF",
            title: "Cadastro de Paciente",
            content: "Preencha o nome do registro CPF",
            placement: 'bottom',
            onShow:()=>{
                $("#CPF").on('keypress',()=>{
                    if(tour.getCurrentStep() === 1){
                        tour.goTo(2);
                    }
                })
            }
        },
            {
                element: "#rbtns #Salvar",
                title: "Cadastro de Paciente",
                content: "Clique em salvar para finalizar o cadastro de paciente.",
                placement: 'left',
            }
        ]
    });

    $("#rbtns button").on('click',()=>{tour.end();})

    tour.init();
    tour.restart();
}

let AgendamentoInserir = ()=>{
    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [{
            delay:1000,
            element: "#lMenu > li:nth-child(2) > div > div > span:nth-child(4)",
            title: "Inserir um Agendamento",
            content: "Selecione o PROFISSIONAL que irá atender o paciente",
            placement: 'right',
            onShow: function (tour) {
                $("#ProfissionalID").on("change",(event)=>{tour.goTo(1)});
            },
        },
            {
                delay:1000,
                element: ".table-agenda button:first",
                title: "Inserir um Agendamento",
                content: "Clique em inserir para acessar a tela de agenda.",
                placement: 'right',
                onNext:function (tour) {
                    $(".table-agenda button").click();
                },
                onShow: function (tour) {
                    $(".table-agenda button").on("click",(event)=>{if(tour.getCurrentStep() != 2)tour.goTo(2)});
                },
            },
            {
                delay:1000,
                element: "#PacienteID",
                title: "Inserir um Agendamento",
                content: "Inserir para acessar a tela de agenda.",
                placement: 'bottom',
                onShow: function (tour) {
                    $("#PacienteID").on("change",(event)=>{tour.goTo(3)});
                },
            },
            {
                element: "#btnSalvarAgenda",
                title: "Inserir um Agendamento",
                content: "Confirme o agendamento clicando em salvar.",
                placement: 'bottom',
                onShow: function (tour) {
                    $("#btnSalvarAgenda").on("click",(event)=>{tour.end()});
                },
            },
        ]
    });

    var interval = setInterval(()=>{
        if($("#PacienteID").length > 0){
            tour.goTo(2);
            clearInterval(interval);
        }
    },1000);

    tour.init();
    tour.restart();
}


let AtenderDefault = () =>{
    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [{
            element: ".menu-click-pacientes",
            title: "Atendimento de Paciente",
            content: "Clique no menu pacientes",
            placement: 'left',
            onShow: function (tour) {
                let interval = setInterval(()=>{
                    if($(".menu-click-pacientes").parent().hasClass("open")){
                        if(tour.getCurrentStep() !== 1){
                            tour.goTo(1);
                        }
                        clearInterval(interval);
                    }
                },200)
            },
            onNext: function (tour) {
                let interval = setInterval(()=>{
                    if(!$(".menu-click-pacientes").parent().hasClass("open")){
                        $(".menu-click-pacientes").parent().addClass("open");
                        if(tour.getCurrentStep() !== 1){
                            tour.goTo(1);
                        }

                        clearInterval(interval);
                    }
                },200)
            },
        },{
            element: ".sub-menu-click-paciente-listar",
            title: "Atendimento de Paciente",
            content: "Clique em listar paciente",
            placement: 'left'
        },
            {
                element: ".sub-menu-click-paciente-incluir",
                title: "Atendimento de Paciente",
                content: "Redirecionando para o cadastro de paciente...",
                placement: 'left',
                onShow: function (tour) {
                    setTimeout(()=>{
                        window.location.href = '?P=Pacientes&Pers=Follow'
                    },4000)
                },
            },
        ]
    });
    tour.init();
    tour.restart();
}

let AtenderListagem = ()=>{


    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [
            {
                element: "#table- > tbody > tr:nth-child(1) > td:nth-child(3)",
                title: "Atendimento de Paciente",
                content: "Selecione o paciente",
                placement: 'top'
            },
            {
                element: "#table- > tbody > tr:nth-child(1) > td:nth-child(3) a",
                title: "Atendimento de Paciente",
                content: "Redirecionando para a tela do paciente...",
                placement: 'bottom',
                onShow: function (tour) {
                    window.location.href = $("#table- > tbody > tr:nth-child(1) > td:nth-child(3) a").attr('href');
                },
            },
        ]
    });
    tour.init();
    tour.restart();
    return ;
}


let AtenderAtendimento = () =>{
    var tour = new Tour({
        template: templateTour,
        backdrop: false, // can mask content in a modal
        storage: false, // can use localstorage
        onEnd: function(tour) { // On Tour Complete
            concluirTour();
        },
        steps: [
            {
                element: "#divContador",
                title: "Atendimento de Paciente",
                content: "Clique em iniciar atendimento",
                placement: 'right',
                next:false,
                onShow : (tour)=>{
                    $("#divContador button .fa-play").parent().on('click',()=>{
                        if(tour.getCurrentStep() === 0){
                            tour.goTo(1);
                        }
                    });
                },
                onNext:(tour)=>{
                    if(!($("#divContador button .fa-stop").length > 0)){
                        $("#divContador button .fa-play").click()
                    }
                }
            },
            {
                element: "#divContador",
                title: "Atendimento de Paciente",
                content: "Observe que o sistema está cronomentrado o atendimento.",
                placement: 'right',
                onShow:(tour)=>{
                    setTimeout(()=>{
                        if(tour.getCurrentStep() === 1){
                            tour.goTo(2);
                        }
                    },3000);
                }
            },{
                element: ".menu-aba-pacientes-anamneses",
                title: "Atendimento de Paciente",
                content: "Clique em Anamnese e Evoluções",
                placement: 'right',
                onShow:(tour)=>{
                    $(".menu-aba-pacientes-anamneses").on('click',()=>{
                        if(tour.getCurrentStep() === 2){
                            tour.goTo(3);
                        }
                    });
                },
                onNext:(tour)=>{
                    $(".menu-aba-pacientes-anamneses").click();
                }
            },{
                delay:1000,
                element: ".timeline-add button",
                title: "Atendimento de Paciente",
                content: "Inclua Anamnese e Evoluções",
                placement: 'top',
                onNext:()=>{
                    let t = setTimeout(() => {
                        if(!$('#pront .btn-group').hasClass('open')){
                            $('#pront .btn-group').addClass('open');
                            clearTimeout(t);
                        }
                    })
                }
            },{
                delay:1000,
                element: ".timeline-add .open ul li:nth-child(1) a",
                title: "Atendimento de Paciente",
                content: "Inclua Anamnese e Evoluções",
                placement: 'top',
                onNext:()=>{
                   $(".timeline-add .open ul li:nth-child(1) a").click()
                }
            },
            {
                delay:1000,
                element: "#iProntCont li:nth-child(1) .campoInput",
                title: "Atendimento de Paciente",
                content: "Preencha a ficha do paciente.",
                placement: 'top',
            },
            {
                element: ".panel-footer .btn-save-form",
                title: "Atendimento de Paciente",
                content: "Clique em salvar",
                placement: 'top',
            },
            {
                element: "#divContador button .fa-stop",
                title: "Atendimento de Paciente",
                content: "Clique em Finalizar ",
                placement: 'top',
                onNext:(tour) =>{
                    if(!($("#frmFimAtendimento").length > 0)){
                        $("#divContador button .fa-stop").click()
                    }
                }
            }
            ,{
                element: "#btnSaveInf",
                title: "Atendimento de Paciente",
                content: "Clique em finalizar atendimento.",
                placement: 'top',
                onShown:(tour)=>{
                    $("#btnSaveInf").on('click',()=>{
                        tour.end();
                    });
                }
            },
        ]
    });



    let time2 = setInterval(() => {
        if($("#iProntCont input").length > 0){
            tour.goTo(5);
            clearInterval(time2)

            $("#iProntCont li:nth-child(1) .campoInput").on('keypress',() => {
                if(tour.getCurrentStep() !== 6){
                    tour.goTo(6);
                }
            });
            $(".panel-footer .btn-save-form").on('click',() => {
                if(tour.getCurrentStep() !== 7){
                    tour.goTo(7);
                }
            });
        }
    },1000);

    let time1 = setInterval(() => {
        console.log($(".timeline-add").length);
        if($(".timeline-add button").length > 0){
            if(tour.getCurrentStep() != 3){
                tour.goTo(3);
                clearInterval(time1)
            }
        }

    },1000);

    let time = setInterval(() => {
        if($(".timeline-add .open ul li:nth-child(1) a").length > 0){
            if(tour.getCurrentStep() !== 4){
                tour.goTo(4);
                clearInterval(time)
            }
        }

    },1000);

    let timeOut3 = setInterval(()=>{
        if($("#divContador button .fa-stop").length > 0){
            if(tour.getCurrentStep() == 0){
                tour.goTo(1);
            }
            clearInterval(timeOut3);
        }
    },100);

    let timeOut = setInterval(()=>{
        if($("#frmFimAtendimento").length > 0){
            if(tour.getCurrentStep() !== 7){
                tour.goTo(8);
            }
        }
    },1000);

    let timeOut2 = setInterval(()=>{
        if($("#modal-table .tour-tour-element").length > 0){
            clearInterval(timeOut);
            clearInterval(timeOut2);
        }
    },100);


    tour.init();
    tour.restart();
    return ;
}


let TourObject = {
    "convenio":{
        "default": ConvenioDefault,
        "listagem": ConvenioListagem,
        "cadastro": ConvenioCadastro,
    },
    "paciente":{
        "default": PacienteDefault,
        "cadastro": PacienteCadastro,
    },
    "agendamento":{
        "default":AgendamentoDefault,
        "inserir":AgendamentoInserir,
    },
    "horarios":{
            default: HorariosDefault,
            cadastro: HorariosCadastro
    },
    "atender":{
        default: AtenderDefault,
        listagem: AtenderListagem,
        atender: AtenderAtendimento
    }
}


let getConfigTour = ()=>{
    let tourStorage = JSON.parse(localStorage.getItem("tour"));
    if(tourStorage && tourStorage.tour === 'HorarioAtendimento'){
        if(window.location.search.indexOf('?P=profissionais&Pers=1&I=') === 0){
            return ['horarios','cadastro'];
        }
        return ['horarios','default'];
    }

    if(tourStorage && tourStorage.tour === 'Agendamento'){
        if(window.location.search.indexOf("?P=Agenda-1&Pers=1") === 0){
            return ['agendamento','inserir'];
        }
        return ['agendamento','default'];
    }

    if((tourStorage && tourStorage.tour === 'AtenderPaciente')){
        if(window.location.search.indexOf("?P=Pacientes&I=") === 0){
            return ['atender','atender'];
        }
        if(window.location.search.indexOf('?P=Pacientes&Pers=Follow') === 0){
            return ['atender','listagem'];
        }
        return ['atender','default'];
    }

    if((tourStorage && tourStorage.tour === 'convenio')){
        if(window.location.search.indexOf('?P=convenios&I=') === 0){
            return ['convenio','cadastro'];
        }
        if(window.location.search == '?P=Convenios&Pers=Follow'){
            return ['convenio','listagem'];
        }
        return ['convenio','default'];
    }

    if((tourStorage && tourStorage.tour === 'paciente')){
        if(window.location.search.indexOf('?P=pacientes&I=') === 0){
            return ['paciente','cadastro'];
        }
        return ['paciente','default'];
    }
}

function runTour(){
    let conf = getConfigTour();
    if(conf){
        TourObject[conf[0]][conf[1]]();
    }
}

function tourFunctionConcluidos(){
    let _tourConcluidos = JSON.parse(localStorage.getItem('tourConcluidos'));
    if(_tourConcluidos)
    {
        _tourConcluidos.forEach((item)=>{
            $(`[tourName=${item}]`).addClass("ativeTour");
        })
    }
}

runTour();
tourFunctionConcluidos();
