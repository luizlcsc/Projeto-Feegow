<!-- #include file = "connect.asp" -->
<%
ContaID = req("C")
Arquivo = req("F")
BancoConcilia = req("BancoConcilia")
%>


<script type="text/javascript">
    $(".crumb-active a").html("Conciliação");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Lista de conciliações");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<% if BancoConcilia="true" then %>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.8.4/Sortable.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Vue.Draggable/2.20.0/vuedraggable.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/vue2-datepicker@1.9.6/dist/build.min.js"></script>
<script src="https://unpkg.com/vue-select@latest"></script>
<script>
$(document).ready(function() {
    getUrl("bank-conciliation", {
        account_id:"<%=ContaID%>"
    }, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
});
</script>
<% else %>
<script>
$(document).ready(function() {
    getUrl("conciliacao/index", {
        file_name: "<%=Arquivo%>",
        account_id:"<%=ContaID%>"
    }, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
});
</script>
<% end if %>