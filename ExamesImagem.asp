<!--#include file="connect.asp"-->

<div class="panel-exames-imagem panel">
    <div class="panel-heading">
        <span class="panel-title"> Exames de Imagem</span>
        <span class="panel-controls"></span>
    </div>

    <div class="panel">
        <div class="panel-body">
            <div class="app">
                <i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
            </div>
            
            <script type="text/javascript">
                getUrl("pacs/viewer", {
                    patientId: "<%=req("PacienteID")%>"
                }, function(data) {
                    $(".app").hide();
                    $(".app").html(data);
                    $(".app").fadeIn('slow');
                });
            </script>           
        </div>
    </div>
</div>