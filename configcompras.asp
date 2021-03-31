<div id="purchasing-config-app" style="padding-top: 11px">
    <i class="fa fa-spin fa-spinner"></i>
</div>

<!-- Production -->
<script defer src="AGUARDANDO_URL_DO_CDN/assets/js/commons.chunk.js" crossorigin="anonymous"></script>
<script defer src="AGUARDANDO_URL_DO_CDN/assets/js/config-page.bundle.js" crossorigin="anonymous"></script>
<link rel="preload" as="style"  onload="this.onload=null;this.rel='stylesheet'" href="AGUARDANDO_URL_DO_CDN/assets/css/commons.css" crossorigin="anonymous">
<link rel="preload" as="style"  onload="this.onload=null;this.rel='stylesheet'" href="AGUARDANDO_URL_DO_CDN/assets/css/config-page.css" crossorigin="anonymous">

<!-- Development -->
<!--<script src="http://localhost:3000/static/js/commons.chunk.js" crossorigin="anonymous"></script>-->
<!--<script src="http://localhost:3000/static/js/config-page.bundle.js" crossorigin="anonymous"></script>-->


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
            appcontainer.innerHTML = '<div class="alert alert-danger" role="alert">Não foi possível carregar o módulo de Configuração de Compras.</div>';
        }
        window.removeEventListener('DOMContentLoaded', listener, false);
    }
    window.addEventListener('DOMContentLoaded', listener, false);
</script>
