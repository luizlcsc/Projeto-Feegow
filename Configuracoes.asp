<!--#include file="connect.asp"-->
<%
response.charset="utf-8"
%>

<style type="text/css">
    .nav li a {
        color:#000!important;
        padding-left:20px;
        border-bottom:1px solid #808080;
    }
</style>
<br />
<div class="nav">
    <ul class="nav sidebar-menu">
        <!--#include file="top.asp"-->
    </ul>
</div>

<script type="text/javascript">
    $(".crumb-icon a").html("<i class='fa fa-cog'></i> CONFIGURA&Ccedil;&Otilde;ES");
    $(".crumb-icon a").css("max-width", "unset");
    $(".crumb-icon a").removeClass("btn");
</script>