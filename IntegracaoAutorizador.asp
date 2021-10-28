<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
    <div class="app" style="padding-top: 11px;">
        Carregando ...
    </div>

        <script type="text/javascript">
            getUrl("autorizadoronline/lista-convenios-servicos", {}, function(data) {
                $(".app").hide();
                $(".app").html(data);
                $(".app").fadeIn('slow');
            });
        </script> 