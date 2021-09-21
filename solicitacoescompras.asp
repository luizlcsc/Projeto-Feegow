<div id="app-container" style="padding-top: 11px">
    <i class="far fa-spin fa-spinner"></i>
</div>

<!-- Production -->
<script src="https://purchasing-frontend.feegow.com/static/js/solicitacoes-0.1.0.bundle.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://purchasing-frontend.feegow.com/static/css/solicitacoes-0.1.0.css" crossorigin="anonymous">

<!-- Development -->
<!--<script src="http://localhost:3000/static/js/solicitacoes-0.1.0.bundle.js" crossorigin="anonymous"></script>-->

<script>
    const appLoader = function() {
        const appcontainer = document.getElementById("app-container");
        const apptopbar    = document.getElementById("topbar");
        const appmenu      = document.createElement('div');

        document.getElementById("lMenu").prepend(appmenu);
        apptopbar.innerHTML = '';

        if (typeof SolicitacoesModule !== 'undefined') {
            SolicitacoesModule.render(appcontainer, apptopbar, appmenu);
        } else {
            appcontainer.innerHTML = '<p class="text-danger">Não foi possível carregar o módulo de Solicitações de Compras.</p>';
        }
        window.removeEventListener('DOMContentLoaded', appLoader, false);
    }
    window.addEventListener('DOMContentLoaded', appLoader, false);

</script>
