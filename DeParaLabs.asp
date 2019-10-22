<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<link rel="stylesheet" href="https://unpkg.com/vue-multiselect@2.1.0/dist/vue-multiselect.min.css">
<script type="text/javascript">
    $(".crumb-active a").html("Relacionamento de Procedimentos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("São marcos");
    $(".crumb-icon a span").attr("class", "fa fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script src="https://unpkg.com/vue-multiselect@2.1.0"></script>
<script type="text/javascript">
    Vue.component('vue-multiselect', window.VueMultiselect.default)
<%
Input = req("Input")
%>
    getUrl("labs-integration/matrix/proc-relation", {
        input: "<%=Input%>"
    }, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>