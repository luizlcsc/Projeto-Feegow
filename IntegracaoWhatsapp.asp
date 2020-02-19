<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<div class="app" style="padding-top: 11px;">
    Carregando ...
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>

<% IF recursoAdicional(31)=4 THEN %>
<script type="text/javascript">
    getUrl("chat-pro/show", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>
<% else %>   
    <p>Item não ativado</p>
<% end if%>

