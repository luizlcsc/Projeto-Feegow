<div id="purchasing-solicitacoes-app" style="padding-top: 11px">
    <i class="fa fa-spin fa-spinner"></i>
</div>

<!-- Production -->
<script src="AGUARDANDO_URL_DO_CDN/assets/js/commons.chunk.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="AGUARDANDO_URL_DO_CDN/assets/css/commons.css" crossorigin="anonymous">

<script src="AGUARDANDO_URL_DO_CDN/assets/js/solicitacoes-page.bundle.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="AGUARDANDO_URL_DO_CDN/assets/css/solicitacoes-page.css" crossorigin="anonymous">

<!-- Development -->
<!--<script src="http://localhost:3000/static/js/commons.chunk.js" crossorigin="anonymous"></script>-->
<!--<script src="http://localhost:3000/static/js/solicitacoes-page.bundle.js" crossorigin="anonymous"></script>-->

<script>
    document.querySelector('.crumb-active a').innerHTML = 'Solicitações de Compras';
    document.querySelector('.crumb-active a').href      = '?P=solicitacoescompras&Pers=1';

    const appcontainer = document.getElementById("purchasing-solicitacoes-app");
    if (typeof SolicitacoesPageModule !== 'undefined') {
        SolicitacoesPageModule.render(appcontainer);
    } else {
        appcontainer.innerHTML = '<div class="alert alert-danger" role="alert">Não foi possível carregar o módulo de Solicitações de Compras.</div>';
    }

</script>
