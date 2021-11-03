<!--#include file="connect.asp"-->
<%
response.charset="utf-8"
%>

<style type="text/css">
    .nav li a {
        color:#000!important;
        padding-left:20px;
    }
    #menu-config.nav li i {
        color: #45AAF2;
        margin-right: 15px;
    }
    #menu-config{
        background-color: #fff;
        border-radius: 8px;
    }
</style>
<br />
<div class="nav"  id="menu-config">
    <ul class="nav sidebar-menu">
        <!--#include file="top.asp"-->
    </ul>
</div>

<script type="text/javascript">
    $(".crumb-icon a").html("<i class='far fa-cog'></i> CONFIGURA&Ccedil;&Otilde;ES");
    $(".crumb-icon a").css("max-width", "unset");
    $(".crumb-icon a").removeClass("btn");
</script>