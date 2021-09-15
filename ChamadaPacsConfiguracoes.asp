<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>

<% if recursoAdicional(27)=4 then %>
    <script type="text/javascript">
        let token = localStorage.getItem('tk');
        getUrl("pacs/config", {tk: token}, function(data) {
            $(".app").hide();
            $(".app").html(data);
            $(".app").fadeIn('slow');
        });
    </script>
<% else %>   
    <p>Item não ativado</p>
<% end if%>


