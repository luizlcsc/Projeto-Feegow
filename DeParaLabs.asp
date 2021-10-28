<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<link rel="stylesheet" href="https://unpkg.com/vue-multiselect@2.1.0/dist/vue-multiselect.min.css">
<script type="text/javascript">
    $(".crumb-active a").html("Relacionamento de Procedimentos");
    $(".crumb-link").removeClass("hidden");
    <%
        idLab = "1"
        if req("labid")&""<>"" then
            idLab = req("labid")
        end if
        set dadoslab = db.execute("SELECT id, NomeLaboratorio FROM cliniccentral.labs WHERE id ="&idLab)
        if not dadoslab.eof then
    %>
         $(".crumb-link").html("<%=dadoslab("NomeLaboratorio")%>");
    <% else %>
        $(".crumb-link").html("Laboratório não especificado");
    <%  end if  %>
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script src="https://unpkg.com/vue-multiselect@2.1.0"></script>
<script type="text/javascript">
    Vue.component('vue-multiselect', window.VueMultiselect.default)
<%
Input = req("Input")
select Case idLab
    case 1
     labnome = "matrix"
    case 2
     labnome = "diagbrasil"
    case 3
     labnome = "alvaro"
    case 4
     labnome = "hermespardini"
End Select
%>
    getUrl("labs-integration/<%=labnome %>/proc-relation", {
        input: "<%=Input%>", labid:"<%=idLab%>"
    }, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>