<!--#include file="../connect.asp"-->
<%
function importView(routeName, resourceName, resourceDescription, resourceIcon)
%>
<script type="text/javascript">
    $(".crumb-active a").html("<%=resourceName%>");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("<%=resourceDescription%>");
    $(".crumb-icon a span").attr("class", "far fa-<%=resourceIcon%>");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://s3.amazonaws.com/cappta.api/v2/dist/cappta-checkout.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script type="text/javascript">
    getUrl("<%=routeName%>", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>
<%
end function
%>