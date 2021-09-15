<div id="purchasing-config-app" style="padding-top: 11px">
    <i class="far fa-spin fa-spinner"></i>
</div>

<!-- Production -->
<script src="https://purchasing-frontend.feegow.com/static/js/config-page-0.1.0.bundle.js" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://purchasing-frontend.feegow.com/static/css/config-page-0.1.0.css" crossorigin="anonymous">

<!-- Development -->
<!--<script src="http://localhost:3000/static/js/config-page-0.1.0.bundle.js" crossorigin="anonymous"></script>-->


<script>
    document.querySelector('.crumb-active a').innerHTML = 'Configuração de Compras';
    const listener = function() {
        const appcontainer = document.getElementById("purchasing-config-app");
        if (typeof ConfigPageModule !== 'undefined') {
            ConfigPageModule.render(appcontainer);

            const menu = document.createElement('div');
            document.getElementById("lMenu").prepend(menu)
            ConfigPageModule.renderNav(menu);
        } else {
            appcontainer.innerHTML = '<p class="text-danger">Não foi possível carregar o módulo de Configuração de Compras.</p>';
        }
        window.removeEventListener('DOMContentLoaded', listener, false);
    }
    window.addEventListener('DOMContentLoaded', listener, false);
</script>
