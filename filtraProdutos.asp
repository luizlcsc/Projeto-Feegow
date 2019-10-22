<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-body">
        <%= quickfield("text", "CodigoDeBarras", "", 12, "", "", "", " placeholder='Busque pelo código de barras...' ") %>
    </div>
</div>

<script type="text/javascript">
$(document).ready(function(){
    $("#CodigoDeBarras").keydown(function(e) {
         if(event.keyCode == 13) {


            if($(this).val()!=''){
                $.get("baixaProdutoPeloCodigoDeBarras.asp?cbi="+$(this).val(), function(data){
                    eval(data);
                });
            }
              event.preventDefault();
              return false;
            }

    });
});
</script>