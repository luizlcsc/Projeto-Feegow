<div id="purchasing-solicitacoes-app" style="padding-top: 11px">
    <i class="fa fa-spin fa-spinner"></i>
</div>

<!-- Production -->
<script src="https://purchasing-frontend.feegow.com/static/js/solicitacoes-0.1.0.bundle.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://purchasing-frontend.feegow.com/static/css/solicitacoes-0.1.0.css" crossorigin="anonymous">

<!-- Development -->
<!--<script src="http://localhost:3000/static/js/solicitacoes-page-0.1.0.bundle.js" crossorigin="anonymous"></script>-->

<script>
    document.querySelector('.crumb-active a').innerHTML = 'Solicitações de Compras';
    document.querySelector('.crumb-active a').href      = '?P=solicitacoescompras&Pers=1';

    const appcontainer = document.getElementById("purchasing-solicitacoes-app");
    if (typeof SolicitacoesPageModule !== 'undefined') {
        SolicitacoesPageModule.render(appcontainer);
    } else {
        appcontainer.innerHTML = '<p class="text-danger">Não foi possível carregar o módulo de Solicitações de Compras.</p>';
    }

</script>
